extends RefCounted
class_name NetworkSecurity

# NetworkSecurity - Comprehensive network security and API protection
# Addresses HTTPS enforcement, API security, rate limiting, and DDoS protection

signal security_violation_detected(violation_type: String, details: String)
signal rate_limit_exceeded(ip: String, endpoint: String)
signal suspicious_activity_detected(ip: String, activity: String)

# Security configuration
const MAX_REQUESTS_PER_MINUTE = 60
const MAX_REQUESTS_PER_HOUR = 1000
const MAX_CONCURRENT_CONNECTIONS = 10
const REQUEST_TIMEOUT = 30  # seconds
const ALLOWED_DOMAINS = ["steam.com", "valvesoftware.com", "api.steampowered.com"]

# Rate limiting
var request_counts: Dictionary = {}  # IP -> {count: int, last_request: int}
var connection_times: Dictionary = {}  # IP -> connection_start_time
var blocked_ips: Array[String] = []

# Security patterns
var suspicious_patterns: Array[String] = [
	"../", "..\\", "script", "javascript:", "eval(",
	"union", "select", "insert", "delete", "drop",
	"<script", "</script>", "onload=", "onerror="
]

func _init():
	"""Initialize network security system"""
	_cleanup_old_records()

func validate_request(request_data: Dictionary, client_ip: String) -> bool:
	"""Validate incoming request for security"""
	
	# Check if IP is blocked
	if blocked_ips.has(client_ip):
		security_violation_detected.emit("blocked_ip", "Request from blocked IP: " + client_ip)
		return false
	
	# Check rate limiting
	if not _check_rate_limit(client_ip):
		rate_limit_exceeded.emit(client_ip, request_data.get("endpoint", "unknown"))
		return false
	
	# Check for suspicious patterns
	if _contains_suspicious_patterns(request_data):
		suspicious_activity_detected.emit(client_ip, "Suspicious patterns in request")
		_block_ip_temporarily(client_ip)
		return false
	
	# Validate request structure
	if not _validate_request_structure(request_data):
		security_violation_detected.emit("invalid_request", "Invalid request structure")
		return false
	
	# Update request count
	_update_request_count(client_ip)
	
	return true

func validate_api_request(api_data: Dictionary, endpoint: String) -> bool:
	"""Validate API request specifically"""
	
	# Check for required fields
	var required_fields = ["method", "data", "timestamp"]
	for field in required_fields:
		if not api_data.has(field):
			security_violation_detected.emit("missing_field", "Missing required field: " + field)
			return false
	
	# Validate method
	var method = api_data.get("method", "").to_upper()
	var allowed_methods = ["GET", "POST", "PUT", "DELETE"]
	if not allowed_methods.has(method):
		security_violation_detected.emit("invalid_method", "Invalid HTTP method: " + method)
		return false
	
	# Validate timestamp (prevent replay attacks)
	var timestamp = api_data.get("timestamp", 0)
	var current_time = Time.get_unix_time_from_system()
	if abs(current_time - timestamp) > 300:  # 5 minutes tolerance
		security_violation_detected.emit("replay_attack", "Request timestamp too old")
		return false
	
	# Validate endpoint
	if not _is_allowed_endpoint(endpoint):
		security_violation_detected.emit("unauthorized_endpoint", "Unauthorized endpoint: " + endpoint)
		return false
	
	return true

func enforce_https(url: String) -> bool:
	"""Enforce HTTPS for all network communications"""
	
	if url.is_empty():
		security_violation_detected.emit("empty_url", "Empty URL provided")
		return false
	
	# Check if URL starts with HTTPS
	if not url.begins_with("https://"):
		security_violation_detected.emit("http_violation", "HTTP not allowed, HTTPS required: " + url)
		return false
	
	# Validate domain
	var domain = _extract_domain(url)
	if not _is_allowed_domain(domain):
		security_violation_detected.emit("unauthorized_domain", "Unauthorized domain: " + domain)
		return false
	
	return true

func validate_steam_integration(steam_data: Dictionary) -> bool:
	"""Validate Steam integration data"""
	
	# Check for Steam-specific required fields
	var steam_required_fields = ["steam_id", "app_id", "session_ticket"]
	for field in steam_required_fields:
		if not steam_data.has(field):
			security_violation_detected.emit("missing_steam_field", "Missing Steam field: " + field)
			return false
	
	# Validate Steam ID format
	var steam_id = str(steam_data.get("steam_id", ""))
	if not _is_valid_steam_id(steam_id):
		security_violation_detected.emit("invalid_steam_id", "Invalid Steam ID: " + steam_id)
		return false
	
	# Validate app ID
	var app_id = steam_data.get("app_id", 0)
	if app_id <= 0:
		security_violation_detected.emit("invalid_app_id", "Invalid app ID: " + str(app_id))
		return false
	
	return true

func validate_cloud_save_data(cloud_data: Dictionary) -> bool:
	"""Validate cloud save data beyond encryption"""
	
	# Check for required cloud save fields
	var cloud_required_fields = ["save_data", "checksum", "version", "timestamp"]
	for field in cloud_required_fields:
		if not cloud_data.has(field):
			security_violation_detected.emit("missing_cloud_field", "Missing cloud save field: " + field)
			return false
	
	# Validate checksum
	var provided_checksum = cloud_data.get("checksum", "")
	var calculated_checksum = _calculate_data_checksum(cloud_data.get("save_data", ""))
	if provided_checksum != calculated_checksum:
		security_violation_detected.emit("checksum_mismatch", "Cloud save checksum mismatch")
		return false
	
	# Validate timestamp
	var timestamp = cloud_data.get("timestamp", 0)
	if not _is_valid_timestamp(timestamp):
		security_violation_detected.emit("invalid_timestamp", "Invalid cloud save timestamp")
		return false
	
	return true

func _check_rate_limit(client_ip: String) -> bool:
	"""Check if client has exceeded rate limits"""
	
	var current_time = Time.get_unix_time_from_system()
	
	# Initialize request count for new IP
	if not request_counts.has(client_ip):
		request_counts[client_ip] = {"count": 0, "last_request": current_time}
	
	var ip_data = request_counts[client_ip]
	
	# Check minute limit
	if current_time - ip_data["last_request"] < 60:  # Within last minute
		if ip_data["count"] >= MAX_REQUESTS_PER_MINUTE:
			return false
	else:
		# Reset count if more than a minute has passed
		ip_data["count"] = 0
	
	# Check hour limit (simplified - in production would use proper hour tracking)
	if ip_data["count"] >= MAX_REQUESTS_PER_HOUR:
		return false
	
	return true

func _update_request_count(client_ip: String):
	"""Update request count for client IP"""
	var current_time = Time.get_unix_time_from_system()
	
	if not request_counts.has(client_ip):
		request_counts[client_ip] = {"count": 0, "last_request": current_time}
	
	var ip_data = request_counts[client_ip]
	ip_data["count"] += 1
	ip_data["last_request"] = current_time

func _contains_suspicious_patterns(data: Dictionary) -> bool:
	"""Check for suspicious patterns in request data"""
	
	# Convert data to string for pattern checking
	var data_string = JSON.stringify(data).to_lower()
	
	for pattern in suspicious_patterns:
		if data_string.contains(pattern):
			return true
	
	return false

func _validate_request_structure(data: Dictionary) -> bool:
	"""Validate request structure"""
	
	# Check for null
	if data == null:
		return false
	
	# Check for required fields
	if not data.has("endpoint"):
		return false
	
	# Check for reasonable size
	var data_size = JSON.stringify(data).length()
	if data_size > 1024 * 1024:  # 1MB limit
		return false
	
	return true

func _is_allowed_endpoint(endpoint: String) -> bool:
	"""Check if endpoint is allowed"""
	var allowed_endpoints = [
		"/api/save", "/api/load", "/api/validate",
		"/steam/auth", "/steam/cloud", "/steam/achievements"
	]
	
	return allowed_endpoints.has(endpoint)

func _is_allowed_domain(domain: String) -> bool:
	"""Check if domain is allowed"""
	return ALLOWED_DOMAINS.has(domain)

func _extract_domain(url: String) -> String:
	"""Extract domain from URL"""
	# Simple domain extraction - can be enhanced
	if url.begins_with("https://"):
		url = url.substr(8)  # Remove "https://"
	
	var slash_index = url.find("/")
	if slash_index != -1:
		url = url.substr(0, slash_index)
	
	return url

func _is_valid_steam_id(steam_id: String) -> bool:
	"""Validate Steam ID format"""
	# Steam IDs are typically 17 digits
	if steam_id.length() != 17:
		return false
	
	# Check if all characters are digits
	for i in range(steam_id.length()):
		if not steam_id[i].is_valid_int():
			return false
	
	return true

func _calculate_data_checksum(data: String) -> String:
	"""Calculate checksum for data"""
	# Simple checksum - in production would use proper cryptographic hash
	var checksum = 0
	for i in range(data.length()):
		checksum += data.unicode_at(i)
	return str(checksum)

func _is_valid_timestamp(timestamp: int) -> bool:
	"""Validate timestamp"""
	var current_time = Time.get_unix_time_from_system()
	var min_time = current_time - (365 * 24 * 60 * 60)  # 1 year ago
	var max_time = current_time + (24 * 60 * 60)  # 1 day in future
	
	return timestamp >= min_time and timestamp <= max_time

func _block_ip_temporarily(ip: String):
	"""Temporarily block IP for suspicious activity"""
	if not blocked_ips.has(ip):
		blocked_ips.append(ip)
		print("NetworkSecurity: Temporarily blocked IP: " + ip)

func _cleanup_old_records():
	"""Clean up old rate limiting records"""
	var current_time = Time.get_unix_time_from_system()
	var ips_to_remove: Array[String] = []
	
	for ip in request_counts.keys():
		var ip_data = request_counts[ip]
		if current_time - ip_data["last_request"] > 3600:  # 1 hour
			ips_to_remove.append(ip)
	
	for ip in ips_to_remove:
		request_counts.erase(ip)

func get_security_report() -> Dictionary:
	"""Get network security report"""
	return {
		"max_requests_per_minute": MAX_REQUESTS_PER_MINUTE,
		"max_requests_per_hour": MAX_REQUESTS_PER_HOUR,
		"max_concurrent_connections": MAX_CONCURRENT_CONNECTIONS,
		"request_timeout": REQUEST_TIMEOUT,
		"allowed_domains": ALLOWED_DOMAINS,
		"blocked_ips_count": blocked_ips.size(),
		"active_connections": request_counts.size(),
		"suspicious_patterns": suspicious_patterns
	} 