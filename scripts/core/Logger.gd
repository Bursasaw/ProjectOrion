extends Node

# Logger - Centralized logging utility
# Handles debug output, error logging, and production logging control

enum LogLevel {
	DEBUG,
	INFO,
	WARNING,
	ERROR,
	CRITICAL
}

# Logging configuration
var log_level: LogLevel = LogLevel.INFO
var enable_debug_output: bool = true
var enable_file_logging: bool = false
var log_file_path: String = "user://game.log"

# Log colors for different levels
var log_colors = {
	LogLevel.DEBUG: "gray",
	LogLevel.INFO: "white", 
	LogLevel.WARNING: "yellow",
	LogLevel.ERROR: "red",
	LogLevel.CRITICAL: "purple"
}

func _ready():
	"""Initialize logger"""
	if enable_file_logging:
		clear_log_file()

func set_log_level(level: LogLevel):
	"""Set the current log level"""
	log_level = level

func set_debug_output(enabled: bool):
	"""Enable or disable debug output"""
	enable_debug_output = enabled

func log_message(level: LogLevel, message: String, context: String = ""):
	"""Log a message with the specified level"""
	if level < log_level:
		return
	
	var timestamp = Time.get_datetime_string_from_system()
	var level_name = LogLevel.keys()[level]
	var formatted_message = "[%s] [%s] %s" % [timestamp, level_name, message]
	
	if context != "":
		formatted_message += " (Context: %s)" % context
	
	# Console output
	if enable_debug_output:
		var color = log_colors.get(level, "white")
		print_rich("[color=%s]%s[/color]" % [color, formatted_message])
	
	# File logging
	if enable_file_logging:
		write_to_log_file(formatted_message)

func debug(message: String, context: String = ""):
	"""Log a debug message"""
	log_message(LogLevel.DEBUG, message, context)

func info(message: String, context: String = ""):
	"""Log an info message"""
	log_message(LogLevel.INFO, message, context)

func warning(message: String, context: String = ""):
	"""Log a warning message"""
	log_message(LogLevel.WARNING, message, context)

func error(message: String, context: String = ""):
	"""Log an error message"""
	log_message(LogLevel.ERROR, message, context)

func critical(message: String, context: String = ""):
	"""Log a critical message"""
	log_message(LogLevel.CRITICAL, message, context)

func write_to_log_file(message: String):
	"""Write a message to the log file"""
	var file = FileAccess.open(log_file_path, FileAccess.WRITE_READ)
	if file:
		file.seek_end()
		file.store_line(message)
		file.close()

func clear_log_file():
	"""Clear the log file"""
	var file = FileAccess.open(log_file_path, FileAccess.WRITE)
	if file:
		file.store_string("")
		file.close()

func get_log_file_path() -> String:
	"""Get the current log file path"""
	return log_file_path

func set_log_file_path(path: String):
	"""Set the log file path"""
	log_file_path = path

# Convenience methods for common logging patterns
func log_system_init(system_name: String):
	"""Log system initialization"""
	info("%s initialized" % system_name, system_name)

func log_system_error(system_name: String, error_message: String):
	"""Log system error"""
	error("%s: %s" % [system_name, error_message], system_name)

func log_game_event(event_name: String, details: String = ""):
	"""Log game events"""
	info("Game event: %s %s" % [event_name, details], "GameEvent")

func log_combat_action(actor: String, action: String, target: String = ""):
	"""Log combat actions"""
	info("%s uses %s on %s" % [actor, action, target], "Combat")

func log_inventory_change(item_id: String, quantity: int, action: String):
	"""Log inventory changes"""
	info("%s %d %s" % [action, quantity, item_id], "Inventory")

func log_quest_progress(quest_id: String, progress: String):
	"""Log quest progress"""
	info("Quest %s: %s" % [quest_id, progress], "Quest")

func log_world_change(world_name: String, location: String = ""):
	"""Log world changes"""
	info("Changed to world: %s, location: %s" % [world_name, location], "World") 
