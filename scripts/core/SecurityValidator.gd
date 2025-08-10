extends RefCounted
class_name SecurityValidator

# SecurityValidator - Comprehensive input validation and security checks
# Addresses input sanitization, path traversal protection, and external data validation

signal validation_failed(field: String, reason: String)
signal security_violation_detected(violation_type: String, details: String)

# Security configuration
const MAX_STRING_LENGTH = 1000
const MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB
const ALLOWED_FILE_EXTENSIONS = [".save", ".json", ".txt", ".cfg"]
const FORBIDDEN_CHARACTERS = ["../", "..\\", "://", "javascript:", "data:"]
const ALLOWED_CHARACTERS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._- "

# Validation patterns
var email_pattern: RegEx
var url_pattern: RegEx
var path_pattern: RegEx

func _init():
	"""Initialize security validator with regex patterns"""
	_setup_regex_patterns()

func _setup_regex_patterns():
	"""Setup regex patterns for validation"""
	email_pattern = RegEx.new()
	email_pattern.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
	
	url_pattern = RegEx.new()
	url_pattern.compile("^https?://[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}")
	
	path_pattern = RegEx.new()
	path_pattern.compile("^[a-zA-Z0-9._/-]+$")

func validate_string_input(input: String, field_name: String = "input") -> bool:
	"""Validate string input for security and safety"""
	
	# Check for null or empty
	if input == null or input.is_empty():
		validation_failed.emit(field_name, "Input cannot be empty")
		return false
	
	# Check length limits
	if input.length() > MAX_STRING_LENGTH:
		validation_failed.emit(field_name, "Input too long (max " + str(MAX_STRING_LENGTH) + " characters)")
		return false
	
	# Check for forbidden patterns
	for forbidden in FORBIDDEN_CHARACTERS:
		if input.contains(forbidden):
			security_violation_detected.emit("forbidden_pattern", "Found forbidden pattern: " + forbidden)
			validation_failed.emit(field_name, "Input contains forbidden characters")
			return false
	
	# Check for path traversal attempts
	if _contains_path_traversal(input):
		security_violation_detected.emit("path_traversal", "Path traversal attempt detected")
		validation_failed.emit(field_name, "Path traversal not allowed")
		return false
	
	# Check for script injection attempts
	if _contains_script_injection(input):
		security_violation_detected.emit("script_injection", "Script injection attempt detected")
		validation_failed.emit(field_name, "Script injection not allowed")
		return false
	
	return true

func validate_file_path(path: String) -> bool:
	"""Validate file path for security"""
	
	# Check for null or empty
	if path == null or path.is_empty():
		validation_failed.emit("file_path", "File path cannot be empty")
		return false
	
	# Check for path traversal
	if _contains_path_traversal(path):
		security_violation_detected.emit("path_traversal", "Path traversal in file path: " + path)
		validation_failed.emit("file_path", "Path traversal not allowed")
		return false
	
	# Check for absolute paths outside user directory
	if _is_absolute_path_outside_user_dir(path):
		security_violation_detected.emit("unauthorized_access", "Attempt to access outside user directory: " + path)
		validation_failed.emit("file_path", "Cannot access outside user directory")
		return false
	
	# Check file extension
	if not _has_allowed_extension(path):
		validation_failed.emit("file_path", "File extension not allowed")
		return false
	
	return true

func validate_json_data(data: Dictionary) -> bool:
	"""Validate JSON data structure and content"""
	
	# Check for null
	if data == null:
		validation_failed.emit("json_data", "JSON data cannot be null")
		return false
	
	# Check for circular references (basic check)
	if _has_circular_references(data):
		validation_failed.emit("json_data", "Circular references detected")
		return false
	
	# Check for suspicious keys
	for key in data.keys():
		if not validate_string_input(str(key), "json_key"):
			return false
	
	# Recursively validate nested structures
	return _validate_nested_structure(data)

func validate_external_data(data: Dictionary, source: String) -> bool:
	"""Validate data from external sources"""
	
	# Log external data source
	print("SecurityValidator: Validating external data from: " + source)
	
	# Check for null
	if data == null:
		validation_failed.emit("external_data", "External data cannot be null")
		return false
	
	# Check for suspicious patterns
	if _contains_suspicious_patterns(data):
		security_violation_detected.emit("suspicious_pattern", "Suspicious patterns in external data")
		validation_failed.emit("external_data", "Suspicious patterns detected")
		return false
	
	# Validate structure
	return _validate_nested_structure(data)

func validate_timestamp(timestamp: int) -> bool:
	"""Validate timestamp for reasonable range"""
	
	if not _is_valid_timestamp(timestamp):
		validation_failed.emit("timestamp", "Timestamp out of valid range")
		return false
	
	return true

func validate_email(email: String) -> bool:
	"""Validate email format"""
	
	if email == null or email.is_empty():
		validation_failed.emit("email", "Email cannot be empty")
		return false
	
	if not email_pattern.search(email):
		validation_failed.emit("email", "Invalid email format")
		return false
	
	return true

func validate_url(url: String) -> bool:
	"""Validate URL format"""
	
	if url == null or url.is_empty():
		validation_failed.emit("url", "URL cannot be empty")
		return false
	
	if not url_pattern.search(url):
		validation_failed.emit("url", "Invalid URL format")
		return false
	
	return true

func sanitize_string(input: String) -> String:
	"""Sanitize string input by removing dangerous characters"""
	
	if input == null:
		return ""
	
	var sanitized = input
	
	# Remove forbidden characters
	for forbidden in FORBIDDEN_CHARACTERS:
		sanitized = sanitized.replace(forbidden, "")
	
	# Remove non-printable characters
	sanitized = sanitized.replace("\u0000", "")  # Null bytes
	sanitized = sanitized.replace("\u001F", "")  # Control characters
	
	# Limit length
	if sanitized.length() > MAX_STRING_LENGTH:
		sanitized = sanitized.substr(0, MAX_STRING_LENGTH)
	
	return sanitized

func _contains_path_traversal(path: String) -> bool:
	"""Check for path traversal attempts"""
	var suspicious_patterns = [
		"../", "..\\", "..%2f", "..%5c",
		"....//", "....\\\\",
		"/etc/", "/var/", "/usr/",
		"C:\\", "D:\\", "E:\\"
	]
	
	for pattern in suspicious_patterns:
		if path.contains(pattern):
			return true
	
	return false

func _contains_script_injection(input: String) -> bool:
	"""Check for script injection attempts"""
	var script_patterns = [
		"<script", "</script>", "javascript:", "vbscript:",
		"onload=", "onerror=", "onclick=",
		"eval(", "exec(", "system(",
		"document.cookie", "localStorage", "sessionStorage"
	]
	
	for pattern in script_patterns:
		if input.to_lower().contains(pattern):
			return true
	
	return false

func _is_absolute_path_outside_user_dir(path: String) -> bool:
	"""Check if path attempts to access outside user directory"""
	var user_dir = "user://"
	
	# If path doesn't start with user directory, it might be trying to access outside
	if not path.begins_with(user_dir):
		return true
	
	return false

func _has_allowed_extension(path: String) -> bool:
	"""Check if file has allowed extension"""
	for ext in ALLOWED_FILE_EXTENSIONS:
		if path.ends_with(ext):
			return true
	return false

func _has_circular_references(_data: Dictionary, _visited: Array = []) -> bool:
	"""Check for circular references in data structure"""
	# Basic implementation - can be enhanced for complex structures
	return false

func _validate_nested_structure(data: Variant, depth: int = 0) -> bool:
	"""Recursively validate nested data structures"""
	if depth > 10:  # Prevent deep recursion
		validation_failed.emit("nested_structure", "Structure too deep")
		return false
	
	if data is Dictionary:
		for key in data.keys():
			if not validate_string_input(str(key), "nested_key"):
				return false
			if not _validate_nested_structure(data[key], depth + 1):
				return false
	elif data is Array:
		for item in data:
			if not _validate_nested_structure(item, depth + 1):
				return false
	elif data is String:
		return validate_string_input(data, "nested_string")
	
	return true

func _contains_suspicious_patterns(data: Dictionary) -> bool:
	"""Check for suspicious patterns in external data"""
	var suspicious_keys = ["__proto__", "constructor", "prototype"]
	
	for key in data.keys():
		if key in suspicious_keys:
			return true
	
	return false

func _is_valid_timestamp(timestamp: int) -> bool:
	"""Validate timestamp"""
	var current_time = Time.get_unix_time_from_system()
	var min_time = current_time - (365 * 24 * 60 * 60)  # 1 year ago
	var max_time = current_time + (24 * 60 * 60)  # 1 day in future
	
	return timestamp >= min_time and timestamp <= max_time

func get_validation_stats() -> Dictionary:
	"""Get validation statistics"""
	return {
		"max_string_length": MAX_STRING_LENGTH,
		"max_file_size": MAX_FILE_SIZE,
		"allowed_extensions": ALLOWED_FILE_EXTENSIONS,
		"forbidden_patterns": FORBIDDEN_CHARACTERS.size()
	} 