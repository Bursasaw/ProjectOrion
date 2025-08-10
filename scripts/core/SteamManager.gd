extends Node

# Steam Manager - Handles Steam integration using GodotSteam
# Manages achievements, cloud saves, Steam API, and Steam-specific features
# Version 0.12.0 - Enhanced with additional security validation

# signal _achievement_unlocked(achievement_id: String)  # Unused signal - commented out
signal steam_initialized()
signal steam_error(error_message: String)
signal statistics_updated(stat_name: String, value: int)
signal steam_security_violation(violation_type: String, details: String)
signal steam_authentication_failed(reason: String)

# Steam API state
var steam_init_complete: bool = false
var steam_available: bool = false
var app_id: int = 0  # Will be set via GodotSteam methods

# Achievement tracking
var achievements: Dictionary = {}
var unlocked_achievements: Array[String] = []

# Cloud save integration
var cloud_saves_enabled: bool = true

# Statistics tracking
var statistics: Dictionary = {}

# Security components
var security_validator: SecurityValidator
var network_security: NetworkSecurity
var steam_session_ticket: String = ""
var steam_auth_session: Dictionary = {}
var steam_security_log: Array[Dictionary] = []

func is_steam_available() -> bool:
	"""Check if Steam class is available and initialized"""
	# Use runtime check to avoid parse-time errors
	return steam_available

func _ready():
	"""Initialize Steam manager"""
	print("SteamManager: Initializing...")
	
	# Initialize security components
	security_validator = SecurityValidator.new()
	network_security = NetworkSecurity.new()
	
	initialize_steam()

func initialize_steam():
	"""Initialize Steam API using proper GodotSteam methods"""
	# Use runtime class loading to avoid parse-time errors
	var steam_class = null
	
	# Try to get the Steam class at runtime
	if ClassDB.class_exists("Steam"):
		steam_class = ClassDB.instantiate("Steam")
		if steam_class == null:
			print("SteamManager: Failed to instantiate Steam class")
			steam_available = false
			steam_error.emit("Failed to instantiate Steam class")
			return
	else:
		print("SteamManager: Steam class not available - GodotSteam module not loaded")
		steam_available = false
		steam_error.emit("Steam module not available")
		return
	
	# Initialize Steam using the instantiated class
	var init_result = steam_class.steamInitEx(0, true)  # 0 = auto-detect, true = embed callbacks
	
	if init_result.has("status") and init_result["status"] == steam_class.STEAM_API_INIT_RESULT_OK:
		print("SteamManager: Steam initialized successfully")
		steam_available = true
		steam_init_complete = true
		
		# Get the current App ID that was auto-detected or set
		app_id = steam_class.get_current_app_id()
		print("SteamManager: Current App ID: %d" % app_id)
		
		# Set up Steam callbacks
		setup_steam_callbacks(steam_class)
		
		# Load achievements
		load_achievements()
		
		# Load statistics
		load_statistics()
		
		# Get user info
		var user_name = steam_class.getPersonaName()
		var user_id = steam_class.getSteamID()
		print("SteamManager: Logged in as %s (ID: %d)" % [user_name, user_id])
		
		# Validate Steam session
		if not _validate_steam_session(steam_class):
			steam_authentication_failed.emit("Steam session validation failed")
			return
		
		# Log successful authentication
		_log_security_event("steam_authenticated", {
			"user_name": user_name,
			"user_id": user_id,
			"app_id": app_id
		})
		
		steam_initialized.emit()
	else:
		print("SteamManager: Failed to initialize Steam")
		steam_available = false
		var error_msg = "Failed to initialize Steam"
		if init_result.has("verbal"):
			error_msg = init_result["verbal"]
		steam_error.emit(error_msg)

func setup_steam_callbacks(steam_class):
	"""Set up Steam API callbacks"""
	if not is_steam_available():
		print("SteamManager: Steam not available, skipping callback setup")
		return
	
	if steam_class != null:
		steam_class.connect("user_achievement_stored", _on_achievement_stored)
		steam_class.connect("user_stats_received", _on_user_stats_received)
		steam_class.connect("user_stats_stored", _on_user_stats_stored)
		print("SteamManager: Steam callbacks set up")
	else:
		print("SteamManager: Steam class not available for callbacks")

func load_achievements():
	"""Load achievement definitions"""
	achievements = {
		"first_quest": {
			"name": "First Steps",
			"description": "Complete your first quest",
			"icon": "achievement_first_quest"
		},
		"combat_master": {
			"name": "Combat Master",
			"description": "Win 10 battles",
			"icon": "achievement_combat"
		},
		"explorer": {
			"name": "Explorer",
			"description": "Visit 5 different locations",
			"icon": "achievement_explorer"
		},
		"collector": {
			"name": "Collector",
			"description": "Collect 20 different items",
			"icon": "achievement_collector"
		},
		"level_10": {
			"name": "Experienced",
			"description": "Reach level 10",
			"icon": "achievement_level"
		},
		"story_complete": {
			"name": "Story Teller",
			"description": "Complete the main story",
			"icon": "achievement_story"
		},
		"multiverse_explorer": {
			"name": "Multiverse Explorer",
			"description": "Visit all 9 worlds",
			"icon": "achievement_multiverse"
		},
		"magic_master": {
			"name": "Magic Master",
			"description": "Learn 50 different spells",
			"icon": "achievement_magic"
		},
		"relationship_master": {
			"name": "Relationship Master",
			"description": "Maximize 5 character relationships",
			"icon": "achievement_relationships"
		},
		"crafting_master": {
			"name": "Crafting Master",
			"description": "Craft 100 items",
			"icon": "achievement_crafting"
		}
	}
	print("SteamManager: Loaded %d achievements" % achievements.size())

func load_statistics():
	"""Load and initialize Steam statistics"""
	statistics = {
		"total_quests_completed": 0,
		"total_battles_won": 0,
		"total_items_collected": 0,
		"total_spells_learned": 0,
		"total_worlds_visited": 0,
		"total_crafting_attempts": 0,
		"total_playtime_hours": 0,
		"highest_level_reached": 0,
		"total_relationships_maxed": 0,
		"total_secrets_found": 0
	}
	
	# Note: requestCurrentStats() may not be available as a static method
	# Statistics will be loaded when first accessed
	print("SteamManager: Statistics initialized")

func unlock_achievement(achievement_id: String) -> bool:
	"""Unlock a Steam achievement"""
	if not is_steam_available():
		print("SteamManager: Steam not available, achievement not unlocked")
		return false
	
	if not achievements.has(achievement_id):
		print("SteamManager: Unknown achievement: %s" % achievement_id)
		return false
	
	print("SteamManager: Achievement unlock disabled for compatibility")
	return false
	
	# NOTE: Steam achievement unlocking is temporarily disabled to prevent parse-time errors
	# The following code will be re-enabled once the Steam class loading issue is resolved
	#
	# if Steam.setAchievement(achievement_id):
	# 	print("SteamManager: Achievement unlocked: %s" % achievement_id)
	# 	unlocked_achievements.append(achievement_id)
	# 	achievement_unlocked.emit(achievement_id)
	# 	return true
	# else:
	# 	print("SteamManager: Failed to unlock achievement: %s" % achievement_id)
	# 	return false

func check_achievement(_achievement_id: String) -> bool:
	"""Check if an achievement is unlocked"""
	if not is_steam_available():
		print("SteamManager: Steam not available, cannot check achievement")
		return false
	
	print("SteamManager: Achievement check disabled for compatibility")
	return false
	
	# NOTE: Steam achievement checking is temporarily disabled to prevent parse-time errors
	# The following code will be re-enabled once the Steam class loading issue is resolved
	#
	# var unlocked = Steam.getAchievement(_achievement_id)
	# if unlocked:
	# 	if not _achievement_id in unlocked_achievements:
	# 		unlocked_achievements.append(_achievement_id)
	# 	return true
	# return false

func get_achievement_progress(_achievement_id: String) -> Dictionary:
	"""Get achievement progress using GodotSteam"""
	if not is_steam_available():
		return {"progress": 0.0, "unlocked": false}
	
	print("SteamManager: Achievement progress check disabled for compatibility")
	return {"progress": 0.0, "unlocked": false}
	
	# NOTE: Steam achievement progress checking is temporarily disabled to prevent parse-time errors
	# The following code will be re-enabled once the Steam class loading issue is resolved
	#
	# var unlocked = Steam.getAchievement(_achievement_id)
	# return {
	# 	"progress": 1.0 if unlocked else 0.0,
	# 	"unlocked": unlocked
	# }

func set_achievement_progress(_achievement_id: String, _progress: float):
	"""Set achievement progress (simplified for GodotSteam compatibility)"""
	if not is_steam_available():
		print("SteamManager: Steam not available, achievement progress not set")
		return
	
	print("SteamManager: Achievement progress setting disabled for compatibility")
	return
	
	# NOTE: Steam achievement progress setting is temporarily disabled to prevent parse-time errors
	# The following code will be re-enabled once the Steam class loading issue is resolved
	#
	# if _progress >= 1.0:
	# 	Steam.setAchievement(_achievement_id)
	# 	print("SteamManager: Achievement unlocked: %s" % _achievement_id)
	# else:
	# 	print("SteamManager: Achievement progress set: %s = %.2f" % [_achievement_id, _progress])

# ===== STATISTICS FUNCTIONS (Verified to exist in GodotSteam) =====

func set_statistic(_stat_name: String, _value: int) -> bool:
	"""Set a Steam statistic"""
	if not is_steam_available():
		print("SteamManager: Steam not available, statistic not set")
		return false
	
	print("SteamManager: Statistic setting disabled for compatibility")
	return false
	
	# NOTE: Steam statistic setting is temporarily disabled to prevent parse-time errors
	# The following code will be re-enabled once the Steam class loading issue is resolved
	#
	# if Steam.setStatInt(_stat_name, _value):
	# 	statistics[_stat_name] = _value
	# 	statistics_updated.emit(_stat_name, _value)
	# 	print("SteamManager: Statistic set: %s = %d" % [_stat_name, _value])
	# 	return true
	# else:
	# 	print("SteamManager: Failed to set statistic: %s" % _stat_name)
	# 	return false

func get_statistic(_stat_name: String) -> int:
	"""Get a Steam statistic"""
	if not is_steam_available():
		print("SteamManager: Steam not available, cannot get statistic")
		return 0
	
	print("SteamManager: Statistic getting disabled for compatibility")
	return 0
	
	# NOTE: Steam statistic getting is temporarily disabled to prevent parse-time errors
	# The following code will be re-enabled once the Steam class loading issue is resolved
	#
	# var value = Steam.getStatInt(_stat_name)
	# statistics[_stat_name] = value
	# return value

func increment_statistic(stat_name: String, increment: int = 1):
	"""Increment a Steam statistic"""
	var current_value = get_statistic(stat_name)
	set_statistic(stat_name, current_value + increment)

func store_statistics() -> bool:
	"""Store statistics to Steam"""
	if not is_steam_available():
		print("SteamManager: Steam not available, statistics not stored")
		return false
	
	print("SteamManager: Statistics storing disabled for compatibility")
	return false
	
	# NOTE: Steam statistics storing is temporarily disabled to prevent parse-time errors
	# The following code will be re-enabled once the Steam class loading issue is resolved
	#
	# if Steam.storeStats():
	# 	print("SteamManager: Statistics stored successfully")
	# 	return true
	# else:
	# 	print("SteamManager: Failed to store statistics")
	# 	return false

# ===== CLOUD SAVE FUNCTIONS (Verified to exist in GodotSteam) =====

func save_to_cloud(_save_data: Dictionary, _slot: int = 1) -> bool:
	"""Save data to Steam Cloud"""
	if not is_steam_available():
		print("SteamManager: Steam not available, cloud save not available")
		return false
	
	print("SteamManager: Cloud save disabled for compatibility")
	return false
	
	# NOTE: Steam cloud save is temporarily disabled to prevent parse-time errors
	# The following code will be re-enabled once the Steam class loading issue is resolved
	#
	# var save_file = "save_%d.json" % _slot
	# var json_string = JSON.stringify(_save_data)
	#
	# if Steam.fileWrite(save_file, json_string.to_utf8_buffer()):
	# 	print("SteamManager: Cloud save successful: %s" % save_file)
	# 	return true
	# else:
	# 	print("SteamManager: Cloud save failed: %s" % save_file)
	# 	return false

func load_from_cloud(_slot: int = 1) -> Dictionary:
	"""Load data from Steam Cloud"""
	if not is_steam_available():
		print("SteamManager: Steam not available, cloud load not available")
		return {}
	
	print("SteamManager: Cloud load disabled for compatibility")
	return {}
	
	# NOTE: Steam cloud load is temporarily disabled to prevent parse-time errors
	# The following code will be re-enabled once the Steam class loading issue is resolved
	#
	# var save_file = "save_%d.json" % _slot
	#
	# if not Steam.fileExists(save_file):
	# 	print("SteamManager: Cloud save not found: %s" % save_file)
	# 	return {}
	#
	# var file_size = Steam.getFileSize(save_file)
	# var file_data = Steam.fileRead(save_file, file_size)
	#
	# if file_data.size() > 0:
	# 	var json_string = file_data.get_string_from_utf8()
	# 	var json = JSON.new()
	# 	var parse_result = json.parse(json_string)
	#
	# 	if parse_result == OK:
	# 		var save_data = json.data
	# 		print("SteamManager: Cloud load successful: %s" % save_file)
	# 		return save_data
	# 	else:
	# 		print("SteamManager: Failed to parse cloud save data")
	# 		return {}
	# else:
	# 	print("SteamManager: Cloud save file is empty")
	# 	return {}

func delete_cloud_save(_slot: int = 1) -> bool:
	"""Delete a cloud save"""
	if not is_steam_available():
		print("SteamManager: Steam not available, cloud delete not available")
		return false
	
	print("SteamManager: Cloud delete disabled for compatibility")
	return false
	
	# NOTE: Steam cloud delete is temporarily disabled to prevent parse-time errors
	# The following code will be re-enabled once the Steam class loading issue is resolved
	#
	# var save_file = "save_%d.json" % _slot
	#
	# if Steam.fileDelete(save_file):
	# 	print("SteamManager: Cloud save deleted: %s" % save_file)
	# 	return true
	# else:
	# 	print("SteamManager: Failed to delete cloud save: %s" % save_file)
	# 	return false

func get_cloud_save_timestamp(_slot: int = 1) -> int:
	"""Get the timestamp of a cloud save"""
	if not is_steam_available():
		print("SteamManager: Steam not available, cannot get timestamp")
		return 0
	
	print("SteamManager: Cloud timestamp disabled for compatibility")
	return 0
	
	# NOTE: Steam cloud timestamp is temporarily disabled to prevent parse-time errors
	# The following code will be re-enabled once the Steam class loading issue is resolved
	#
	# var save_file = "save_%d.json" % _slot
	#
	# if Steam.fileExists(save_file):
	# 	return Steam.getFileTimestamp(save_file)
	# else:
	# 	return 0

# ===== UTILITY FUNCTIONS (Verified to exist in GodotSteam) =====

func get_user_name() -> String:
	"""Get the current Steam user's name"""
	if not is_steam_available():
		return "Unknown"
	
	print("SteamManager: User name disabled for compatibility")
	return "Unknown"
	
	# NOTE: Steam user name is temporarily disabled to prevent parse-time errors
	# The following code will be re-enabled once the Steam class loading issue is resolved
	#
	# return Steam.getPersonaName()

func get_steam_user_id() -> int:
	"""Get the current Steam user's ID"""
	if not is_steam_available():
		return 0
	
	print("SteamManager: User ID disabled for compatibility")
	return 0
	
	# NOTE: Steam user ID is temporarily disabled to prevent parse-time errors
	# The following code will be re-enabled once the Steam class loading issue is resolved
	#
	# return Steam.getSteamID()

func get_steam_app_id() -> int:
	"""Get the current Steam App ID"""
	if not is_steam_available():
		return 0
	
	print("SteamManager: App ID disabled for compatibility")
	return 0
	
	# NOTE: Steam App ID is temporarily disabled to prevent parse-time errors
	# The following code will be re-enabled once the Steam class loading issue is resolved
	#
	# return Steam.get_current_app_id()

func set_steam_app_id(_new_app_id: int):
	"""Set the Steam App ID"""
	if not is_steam_available():
		print("SteamManager: Steam not available, cannot set App ID")
		return
	
	print("SteamManager: App ID setting disabled for compatibility")
	return
	
	# NOTE: Steam App ID setting is temporarily disabled to prevent parse-time errors
	# The following code will be re-enabled once the Steam class loading issue is resolved
	#
	# Steam.set_current_app_id(_new_app_id)
	# app_id = _new_app_id
	# print("SteamManager: App ID set to: %d" % app_id)

func is_steam_running() -> bool:
	"""Check if Steam is running"""
	if not is_steam_available():
		return false
	
	print("SteamManager: Steam running check disabled for compatibility")
	return false
	
	# NOTE: Steam running check is temporarily disabled to prevent parse-time errors
	# The following code will be re-enabled once the Steam class loading issue is resolved
	#
	# return Steam.isSteamRunning()

func run_callbacks():
	"""Run Steam callbacks - should be called regularly"""
	if not is_steam_available():
		return
	
	print("SteamManager: Callbacks disabled for compatibility")
	return
	
	# NOTE: Steam callbacks are temporarily disabled to prevent parse-time errors
	# The following code will be re-enabled once the Steam class loading issue is resolved
	#
	# Steam.run_callbacks()

# ===== CALLBACK FUNCTIONS =====

func _on_achievement_stored(achievement_id: String):
	"""Callback when achievement is stored in Steam"""
	print("SteamManager: Achievement stored in Steam: %s" % achievement_id)

func _on_user_stats_received(stat_name: String, value: int):
	"""Callback when user stats are received"""
	print("SteamManager: User stats received for '%s': %d" % [stat_name, value])
	statistics_updated.emit(stat_name, value)

func _on_user_stats_stored(stat_name: String, value: int):
	"""Callback when user stats are stored"""
	print("SteamManager: User stats stored for '%s': %d" % [stat_name, value])

# ===== SECURITY VALIDATION FUNCTIONS =====

func _validate_steam_session(steam_class) -> bool:
	"""Validate Steam session for security"""
	
	# Check if Steam is running
	if not steam_class.isSteamRunning():
		steam_security_violation.emit("steam_not_running", "Steam client not running")
		return false
	
	# Validate user ID
	var user_id = steam_class.getSteamID()
	if user_id <= 0:
		steam_security_violation.emit("invalid_user_id", "Invalid Steam user ID: " + str(user_id))
		return false
	
	# Validate app ID
	if app_id <= 0:
		steam_security_violation.emit("invalid_app_id", "Invalid app ID: " + str(app_id))
		return false
	
	# Validate user name
	var user_name = steam_class.getPersonaName()
	if user_name.is_empty():
		steam_security_violation.emit("invalid_user_name", "Invalid user name")
		return false
	
	# Store session information
	steam_auth_session = {
		"user_id": user_id,
		"user_name": user_name,
		"app_id": app_id,
		"session_start": Time.get_unix_time_from_system()
	}
	
	return true

func validate_cloud_save_data(cloud_data: Dictionary) -> bool:
	"""Validate cloud save data with additional security checks"""
	
	# Use network security validator
	if not network_security.validate_cloud_save_data(cloud_data):
		steam_security_violation.emit("cloud_save_validation_failed", "Cloud save validation failed")
		return false
	
	# Additional Steam-specific validation
	if not _validate_steam_cloud_structure(cloud_data):
		steam_security_violation.emit("invalid_cloud_structure", "Invalid cloud save structure")
		return false
	
	return true

func _validate_steam_cloud_structure(cloud_data: Dictionary) -> bool:
	"""Validate Steam cloud save structure"""
	
	# Check for Steam-specific fields
	var steam_required_fields = ["steam_user_id", "steam_app_id", "cloud_timestamp"]
	for field in steam_required_fields:
		if not cloud_data.has(field):
			steam_security_violation.emit("missing_steam_field", "Missing Steam field: " + field)
			return false
	
	# Validate Steam user ID matches current session
	var cloud_user_id = cloud_data.get("steam_user_id", 0)
	var current_user_id = steam_auth_session.get("user_id", 0)
	if cloud_user_id != current_user_id:
		steam_security_violation.emit("user_id_mismatch", "Cloud save user ID mismatch")
		return false
	
	# Validate app ID
	var cloud_app_id = cloud_data.get("steam_app_id", 0)
	if cloud_app_id != app_id:
		steam_security_violation.emit("app_id_mismatch", "Cloud save app ID mismatch")
		return false
	
	return true

func validate_achievement_data(achievement_data: Dictionary) -> bool:
	"""Validate achievement data for security"""
	
	# Check for required fields
	var required_fields = ["achievement_id", "achievement_name", "unlock_time"]
	for field in required_fields:
		if not achievement_data.has(field):
			steam_security_violation.emit("missing_achievement_field", "Missing achievement field: " + field)
			return false
	
	# Validate achievement ID format
	var achievement_id = achievement_data.get("achievement_id", "")
	if not _is_valid_achievement_id(achievement_id):
		steam_security_violation.emit("invalid_achievement_id", "Invalid achievement ID: " + achievement_id)
		return false
	
	# Validate unlock time
	var unlock_time = achievement_data.get("unlock_time", 0)
	if not _is_valid_timestamp(unlock_time):
		steam_security_violation.emit("invalid_unlock_time", "Invalid achievement unlock time")
		return false
	
	return true

func _is_valid_achievement_id(achievement_id: String) -> bool:
	"""Validate achievement ID format"""
	
	# Achievement IDs should be alphanumeric with underscores
	var valid_pattern = RegEx.new()
	valid_pattern.compile("^[a-zA-Z0-9_]+$")
	
	return valid_pattern.search(achievement_id) != null

func _is_valid_timestamp(timestamp: int) -> bool:
	"""Validate timestamp"""
	var current_time = Time.get_unix_time_from_system()
	var min_time = current_time - (365 * 24 * 60 * 60)  # 1 year ago
	var max_time = current_time + (24 * 60 * 60)  # 1 day in future
	
	return timestamp >= min_time and timestamp <= max_time

func _log_security_event(event_type: String, event_data: Dictionary):
	"""Log security events for monitoring"""
	var log_entry = {
		"timestamp": Time.get_unix_time_from_system(),
		"event_type": event_type,
		"event_data": event_data
	}
	
	steam_security_log.append(log_entry)
	
	# Keep log size manageable
	if steam_security_log.size() > 1000:
		steam_security_log.pop_front()
	
	print("SteamManager: Security event logged: " + event_type)

func get_security_report() -> Dictionary:
	"""Get Steam security report"""
	return {
		"steam_available": steam_available,
		"steam_init_complete": steam_init_complete,
		"app_id": app_id,
		"session_active": not steam_auth_session.is_empty(),
		"security_log_size": steam_security_log.size(),
		"last_security_event": steam_security_log[-1] if steam_security_log.size() > 0 else {}
	} 
