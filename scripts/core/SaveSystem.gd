extends Node

# Save System - Handles game save and load functionality
# Manages player data, world state, and game progress persistence
# Version 0.12.0 - Simplified with JSON serialization

signal save_completed(save_name: String)
signal load_completed(save_name: String)
signal save_failed(error: String)
signal load_failed(error: String)

# Save file configuration
const SAVE_DIR = "user://saves/"
const SAVE_EXTENSION = ".save"
const MAX_SAVE_SLOTS = 10
const SAVE_VERSION = "0.12.0"

# Save data structure
var save_data = {
	"version": SAVE_VERSION,
	"timestamp": 0,
	"save_name": "",
	"playtime": 0,
	"creation_date": 0,
	"last_modified": 0,
	"player_data": {},
	"world_state": {},
	"game_progress": {},
	"settings": {},
	"inventory": {},
	"quests": {},
	"discovered_worlds": [],
	"visited_locations": [],
	"combat_history": [],
	"dialogue_history": [],
	"achievements": [],
	"statistics": {},
	"ai_data": {},
	"rl_data": {},
	"narrative_data": {},
	"quantum_data": {},
	"performance_data": {}
}

# Save statistics
var save_count: int = 0

func _ready():
	# Ensure save directory exists
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	
	# Load save statistics
	_load_save_statistics()

func save_game(slot_number: int, save_name: String = "") -> bool:
	"""Save the current game state to a slot with JSON serialization"""
	var save_path = SAVE_DIR + "slot_" + str(slot_number) + SAVE_EXTENSION
	
	# Prepare save data with metadata
	save_data["timestamp"] = Time.get_unix_time_from_system()
	save_data["save_name"] = save_name if save_name != "" else "Save " + str(slot_number)
	save_data["last_modified"] = Time.get_unix_time_from_system()
	
	# Set creation date if this is a new save
	if save_data["creation_date"] == 0:
		save_data["creation_date"] = Time.get_unix_time_from_system()
	
	# Get current game state
	var game_manager = get_node("/root/GameManager")
	if game_manager:
		save_data["player_data"] = game_manager.player_data.get_stats()
		save_data["world_state"] = {
			"current_world": game_manager.get_current_world(),
			"current_location": game_manager.get_current_location(),
			"game_state": game_manager.get_current_game_state()
		}
		
		# Get world manager data
		var world_manager = game_manager.world_manager
		if world_manager:
			save_data["discovered_worlds"] = world_manager.discovered_worlds
			save_data["visited_locations"] = world_manager.visited_locations
		
		# Get inventory data
		var inventory_manager = game_manager.inventory_manager
		if inventory_manager:
			save_data["inventory"] = inventory_manager.get_inventory_data()
		
		# Get dialogue data
		var dialogue_manager = game_manager.dialogue_manager
		if dialogue_manager:
			save_data["dialogue_history"] = dialogue_manager.get_dialogue_history()
		
		# Get combat statistics
		var combat_manager = game_manager.combat_manager
		if combat_manager:
			save_data["combat_statistics"] = {
				"victories": combat_manager.combat_victories
			}
	
	# Save data as JSON
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Game saved successfully to slot %d" % slot_number)
		
		# Update statistics
		save_count += 1
		_save_save_statistics()
	else:
		save_failed.emit("Failed to create save file")
		print("Failed to save game to slot %d" % slot_number)
		return false
	
	# Save to Steam Cloud
	var steam_manager = get_node("/root/SteamManager")
	if steam_manager and steam_manager.is_steam_available():
		if steam_manager.save_to_cloud(save_data, slot_number):
			print("Game saved to Steam Cloud: slot %d" % slot_number)
		else:
			print("Failed to save to Steam Cloud: slot %d" % slot_number)
	
	save_completed.emit(save_name)
	return true

func load_game(slot_number: int) -> bool:
	"""Load game state from a slot with decryption and recovery"""
	var save_path = SAVE_DIR + "slot_" + str(slot_number) + SAVE_EXTENSION
	var loaded_data = {}
	
	# Try to load from Steam Cloud first
	var steam_manager = get_node("/root/SteamManager")
	if steam_manager and steam_manager.is_steam_available():
		var cloud_data = steam_manager.load_from_cloud(slot_number)
		if not cloud_data.is_empty():
			loaded_data = cloud_data
			print("Loaded from Steam Cloud: slot %d" % slot_number)
	
	# If no cloud data, try local file
	if loaded_data.is_empty():
		if not FileAccess.file_exists(save_path):
			load_failed.emit("Save file does not exist")
			return false
		
		var file = FileAccess.open(save_path, FileAccess.READ)
		if file:
			var encrypted_string = file.get_as_text()
			file.close()
			
			# Parse JSON data
			var json = JSON.new()
			var parse_result = json.parse(encrypted_string)
			if parse_result == OK:
				loaded_data = json.data
			else:
				load_failed.emit("Failed to parse save file")
				return false
		else:
			load_failed.emit("Failed to open save file")
			return false
	
	# Basic validation
	if loaded_data.is_empty():
		load_failed.emit("Invalid save data format")
		return false
	
	# Apply loaded data
	var game_manager = get_node("/root/GameManager")
	if game_manager:
		# Load player data
		if loaded_data.has("player_data"):
			game_manager.player_data.update_stats(loaded_data["player_data"])
		
		# Load world state
		if loaded_data.has("world_state"):
			var world_state = loaded_data["world_state"]
			if world_state.has("current_world"):
				game_manager.world_manager.change_world(world_state["current_world"])
			if world_state.has("current_location"):
				game_manager.world_manager.change_location(world_state["current_location"])
			if world_state.has("game_state"):
				game_manager.change_game_state(world_state["game_state"])
		
		# Load world manager data
		var world_manager = game_manager.world_manager
		if world_manager and loaded_data.has("discovered_worlds"):
			world_manager.set_discovered_worlds(loaded_data["discovered_worlds"])
		if world_manager and loaded_data.has("visited_locations"):
			world_manager.set_visited_locations(loaded_data["visited_locations"])
		
		# Load inventory data
		var inventory_manager = game_manager.inventory_manager
		if inventory_manager and loaded_data.has("inventory"):
			inventory_manager.load_inventory_data(loaded_data["inventory"])
		
		# Load dialogue data
		var dialogue_manager = game_manager.dialogue_manager
		if dialogue_manager and loaded_data.has("dialogue_history"):
			dialogue_manager.load_dialogue_history(loaded_data["dialogue_history"])
		
		# Load combat statistics
		var combat_manager = game_manager.combat_manager
		if combat_manager and loaded_data.has("combat_statistics"):
			var combat_stats = loaded_data["combat_statistics"]
			if combat_stats.has("victories"):
				combat_manager.combat_victories = combat_stats["victories"]
	
	load_completed.emit(loaded_data.get("save_name", "Unknown"))
	print("Game loaded successfully from slot %d" % slot_number)
	return true

func get_save_info(slot_number: int) -> Dictionary:
	"""Get information about a save slot"""
	var save_path = SAVE_DIR + "slot_" + str(slot_number) + SAVE_EXTENSION
	
	if not FileAccess.file_exists(save_path):
		return {"exists": false}
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		# Parse JSON data
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var loaded_save_data = json.data
			
			if not loaded_save_data.is_empty():
				return {
					"exists": true,
					"save_name": loaded_save_data.get("save_name", "Unknown"),
					"timestamp": loaded_save_data.get("timestamp", 0),
					"version": loaded_save_data.get("version", "Unknown"),
					"player_level": loaded_save_data.get("player_data", {}).get("level", 1),
					"current_world": loaded_save_data.get("world_state", {}).get("current_world", "Unknown"),
					"playtime": loaded_save_data.get("playtime", 0),
					"creation_date": loaded_save_data.get("creation_date", 0),
					"last_modified": loaded_save_data.get("last_modified", 0)
				}
	
	return {"exists": false}

func get_save_data(slot_number: int) -> Dictionary:
	"""Get the actual save data for a slot"""
	var save_path = SAVE_DIR + "slot_" + str(slot_number) + SAVE_EXTENSION
	
	if not FileAccess.file_exists(save_path):
		return {}
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		# Parse JSON data
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			print("SaveSystem: Successfully loaded save data for slot ", slot_number)
			return json.data
		else:
			print("SaveSystem: Failed to parse save data for slot ", slot_number)
	
	return {}

func delete_save(slot_number: int) -> bool:
	"""Delete a save slot"""
	var save_path = SAVE_DIR + "slot_" + str(slot_number) + SAVE_EXTENSION
	
	if FileAccess.file_exists(save_path):
		var dir = DirAccess.open(SAVE_DIR)
		if dir:
			var result = dir.remove("slot_" + str(slot_number) + SAVE_EXTENSION)
			if result == OK:
				print("Save slot %d deleted successfully" % slot_number)
				return true
	
	print("Failed to delete save slot %d" % slot_number)
	return false

func get_all_save_slots() -> Array[Dictionary]:
	"""Get information about all save slots"""
	var slots: Array[Dictionary] = []
	
	# Include auto-save slot (slot 0) and all other slots
	for i in range(0, MAX_SAVE_SLOTS + 1):
		slots.append(get_save_info(i))
	
	return slots

func _is_version_compatible(save_version: String) -> bool:
	"""Check if save version is compatible with current system"""
	# For now, accept all versions - can be enhanced with version migration
	return true

func _load_save_statistics():
	"""Load save system statistics"""
	var stats_path = SAVE_DIR + "save_statistics.json"
	
	if FileAccess.file_exists(stats_path):
		var file = FileAccess.open(stats_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				var stats = json.data
				save_count = stats.get("save_count", 0)

func _save_save_statistics():
	"""Save save system statistics"""
	var stats_path = SAVE_DIR + "save_statistics.json"
	var stats = {
		"save_count": save_count,
		"last_updated": Time.get_unix_time_from_system()
	}
	
	var file = FileAccess.open(stats_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(stats))
		file.close()

func auto_save() -> bool:
	"""Perform an automatic save"""
	return save_game(0, "Auto Save")

func quick_save() -> bool:
	"""Perform a quick save"""
	return save_game(1, "Quick Save")

# AI Data Save/Load Functions
func save_ai_data(_ai_data: Dictionary):
	"""Save AI learning data"""
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager and combat_manager.has_method("get_combat_ai") and combat_manager.get_combat_ai():
		combat_manager.get_combat_ai().save_ai_data()
	else:
		print("SaveSystem: Warning - CombatManager or CombatAI not available for AI data save")

func load_ai_data() -> Dictionary:
	"""Load AI learning data"""
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager and combat_manager.has_method("get_combat_ai") and combat_manager.get_combat_ai():
		combat_manager.get_combat_ai().load_ai_data()
	else:
		print("SaveSystem: Warning - CombatManager or CombatAI not available for AI data load")
	return {}

func save_rl_data(_rl_data: Dictionary):
	"""Save reinforcement learning data"""
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager and combat_manager.has_method("get_reinforcement_learning_ai") and combat_manager.get_reinforcement_learning_ai():
		combat_manager.get_reinforcement_learning_ai().save_rl_data()
	else:
		print("SaveSystem: Warning - CombatManager or ReinforcementLearningAI not available for RL data save")

func load_rl_data() -> Dictionary:
	"""Load reinforcement learning data"""
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager and combat_manager.has_method("get_reinforcement_learning_ai") and combat_manager.get_reinforcement_learning_ai():
		combat_manager.get_reinforcement_learning_ai().load_rl_data()
	else:
		print("SaveSystem: Warning - CombatManager or ReinforcementLearningAI not available for RL data load")
	return {}

func save_narrative_data(_narrative_data: Dictionary):
	"""Save narrative AI data"""
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager and combat_manager.has_method("get_narrative_ai") and combat_manager.get_narrative_ai():
		combat_manager.get_narrative_ai().save_narrative_data()
	else:
		print("SaveSystem: Warning - CombatManager or NarrativeAI not available for narrative data save")

func load_narrative_data() -> Dictionary:
	"""Load narrative AI data"""
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager and combat_manager.has_method("get_narrative_ai") and combat_manager.get_narrative_ai():
		combat_manager.get_narrative_ai().load_narrative_data()
	else:
		print("SaveSystem: Warning - CombatManager or NarrativeAI not available for narrative data load")
	return {}

func save_quantum_data(_quantum_data: Dictionary):
	"""Save quantum AI data"""
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager and combat_manager.has_method("get_quantum_ai") and combat_manager.get_quantum_ai():
		combat_manager.get_quantum_ai().save_quantum_data()
	else:
		print("SaveSystem: Warning - CombatManager or QuantumAI not available for quantum data save")

func load_quantum_data() -> Dictionary:
	"""Load quantum AI data"""
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager and combat_manager.has_method("get_quantum_ai") and combat_manager.get_quantum_ai():
		combat_manager.get_quantum_ai().load_quantum_data()
	else:
		print("SaveSystem: Warning - CombatManager or QuantumAI not available for quantum data load")
	return {}

func save_performance_data(_performance_data: Dictionary):
	"""Save performance optimization data"""
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager and combat_manager.has_method("get_performance_optimizer") and combat_manager.get_performance_optimizer():
		combat_manager.get_performance_optimizer().save_performance_data()
	else:
		print("SaveSystem: Warning - CombatManager or PerformanceOptimizer not available for performance data save")

func load_performance_data() -> Dictionary:
	"""Load performance optimization data"""
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager and combat_manager.has_method("get_performance_optimizer") and combat_manager.get_performance_optimizer():
		combat_manager.get_performance_optimizer().load_performance_data()
	else:
		print("SaveSystem: Warning - CombatManager or PerformanceOptimizer not available for performance data load")
	return {}

# Settings Save/Load Functions
func save_settings(settings: Dictionary) -> bool:
	"""Save settings to file"""
	var settings_path = SAVE_DIR + "settings.json"
	
	var file = FileAccess.open(settings_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(settings)
		file.store_string(json_string)
		file.close()
		print("SaveSystem: Settings saved successfully")
		return true
	
	print("SaveSystem: Failed to save settings")
	return false

func load_settings() -> Dictionary:
	"""Load settings from file"""
	var settings_path = SAVE_DIR + "settings.json"
	
	if not FileAccess.file_exists(settings_path):
		print("SaveSystem: No settings file found, using defaults")
		return {}
	
	var file = FileAccess.open(settings_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			print("SaveSystem: Settings loaded successfully")
			return json.data
	
	print("SaveSystem: Failed to load settings")
	return {}

# Enhanced Save System Functions

func get_save_statistics() -> Dictionary:
	"""Get save system statistics"""
	return {
		"save_count": save_count,
		"last_updated": Time.get_unix_time_from_system()
	}

func validate_save_file(slot_number: int) -> bool:
	"""Validate a specific save file"""
	var save_path = SAVE_DIR + "slot_" + str(slot_number) + SAVE_EXTENSION
	
	if not FileAccess.file_exists(save_path):
		return false
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		# Basic JSON validation
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		return parse_result == OK
	
	return false

func create_manual_backup(slot_number: int) -> bool:
	"""Create a manual backup of a save slot"""
	var save_path = SAVE_DIR + "slot_" + str(slot_number) + SAVE_EXTENSION
	var backup_path = SAVE_DIR + "slot_" + str(slot_number) + ".backup"
	
	if FileAccess.file_exists(save_path):
		var dir = DirAccess.open(SAVE_DIR)
		if dir:
			var result = dir.copy(save_path, backup_path)
			if result == OK:
				print("SaveSystem: Manual backup created for slot %d" % slot_number)
				return true
	
	return false

func cleanup_old_backups():
	"""Clean up old backup files"""
	var dir = DirAccess.open(SAVE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".backup"):
				var file_path = SAVE_DIR + file_name
				var file_time = FileAccess.get_modified_time(file_path)
				var current_time = Time.get_unix_time_from_system()
				
				# Remove backups older than 30 days
				if current_time - file_time > 30 * 24 * 60 * 60:
					dir.remove(file_name)
					print("SaveSystem: Removed old backup: " + file_name)
			
			file_name = dir.get_next()

func get_save_file_size(slot_number: int) -> int:
	"""Get the size of a save file in bytes"""
	var save_path = SAVE_DIR + "slot_" + str(slot_number) + SAVE_EXTENSION
	
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		if file:
			var size = file.get_length()
			file.close()
			return size
	
	return 0

func migrate_save_version(slot_number: int) -> bool:
	"""Migrate a save to the current version format"""
	var save_data = get_save_data(slot_number)
	if save_data.is_empty():
		return false
	
	# Update version
	save_data["version"] = SAVE_VERSION
	
	# Save the migrated data
	return save_game(slot_number, save_data.get("save_name", "Migrated Save"))

func export_save_data(slot_number: int, export_path: String) -> bool:
	"""Export save data to a specified path"""
	var save_data = get_save_data(slot_number)
	if save_data.is_empty():
		return false
	
	var file = FileAccess.open(export_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("SaveSystem: Save exported to " + export_path)
		return true
	
	return false

func import_save_data(import_path: String, slot_number: int) -> bool:
	"""Import save data from a specified path"""
	if not FileAccess.file_exists(import_path):
		return false
	
	var file = FileAccess.open(import_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var imported_data = json.data
			
			# Basic validation
			if not imported_data.is_empty():
				# Save to the specified slot
				return save_game(slot_number, imported_data.get("save_name", "Imported Save"))
	
	return false 
