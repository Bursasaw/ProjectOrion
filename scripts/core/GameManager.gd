extends Node

# Game Manager - Core game state and scene management
# Handles game flow, state transitions, and global game data

# Note: All classes use class_name and should be globally available

signal game_state_changed(new_state: GameState)
signal world_changed(world_name: String)
signal player_stats_updated()

enum GameState {
	MAIN_MENU,
	PLAYING,
	PAUSED,
	DIALOGUE,
	INVENTORY,
	COMBAT,
	GAME_OVER
}

# Current game state
var current_state: GameState = GameState.MAIN_MENU

# Player data
var player_data

# World state (managed by WorldManager)
# var current_world: String = "Terra"  # Now managed by WorldManager
# var current_location: String = "Arcanum Sanctum"  # Now managed by WorldManager

# Game settings
var settings

# Dialogue system
var dialogue_manager

# Quest system
var quest_manager: Node

# World events
var world_events: Node

# Inventory system
var inventory_manager

# Combat system
var combat_manager

# World management
var world_manager

# Time system
var game_time: Dictionary = {
	"day": 1,
	"hour": 6,
	"minute": 0
}

func _ready():
	# Initialize core systems
	initialize_game_systems()
	
	# Load saved game data if exists
	load_game_data()
	
	# Set initial state
	change_game_state(GameState.MAIN_MENU)

func initialize_game_systems():
	"""Initialize all core game systems"""
	
	# Initialize autoloaded managers (using signals for communication)
	initialize_autoload_managers()
	
	# Initialize instanced managers
	initialize_instanced_managers()
	
	# Initialize core data
	initialize_core_data()

func initialize_autoload_managers():
	"""Initialize managers that are autoloaded"""
	# Get autoload references for managers
	dialogue_manager = get_node("/root/DialogueManager")
	quest_manager = get_node("/root/QuestManager")
	world_events = get_node("/root/WorldEvents")
	
	# Verify autoload managers are available
	if not dialogue_manager:
		print("Warning: DialogueManager autoload not found")
	if not quest_manager:
		print("Warning: QuestManager autoload not found")
	if not world_events:
		print("Warning: WorldEvents autoload not found")

func initialize_instanced_managers():
	"""Initialize managers that are created as instances"""
	# Create and add core managers using load() to avoid class loading issues
	var inventory_manager_script = load("res://scripts/core/InventoryManager.gd")
	var combat_manager_script = load("res://scripts/core/CombatManager.gd")
	var world_manager_script = load("res://scripts/world/WorldManager.gd")
	
	inventory_manager = inventory_manager_script.new()
	add_child(inventory_manager)
	
	combat_manager = combat_manager_script.new()
	add_child(combat_manager)
	
	world_manager = world_manager_script.new()
	add_child(world_manager)
	
	# Verify instanced managers are created
	if not inventory_manager:
		print("Error: Failed to create InventoryManager")
	if not combat_manager:
		print("Error: Failed to create CombatManager")
	if not world_manager:
		print("Error: Failed to create WorldManager")

func initialize_core_data():
	"""Initialize core game data"""
	# Initialize settings using load() to avoid class loading issues
	var game_settings_script = load("res://scripts/core/GameSettings.gd")
	var player_data_script = load("res://scripts/characters/PlayerData.gd")
	
	settings = game_settings_script.new()
	
	# Initialize player data
	player_data = player_data_script.new()
	player_data.initialize_default_stats()
	
	# Give player some starting items
	if inventory_manager:
		# Force load the item database
		inventory_manager.load_item_database()
		
		# Check if database loaded successfully
		if inventory_manager.item_database.size() > 0:
			inventory_manager.add_item("health_potion", 3)
			inventory_manager.add_item("mana_potion", 2)
			inventory_manager.add_gold(100)
			print("Starting items added successfully")
		else:
			print("Item database failed to load, using fallback items")
			# Use fallback items from the create_sample_items function
			inventory_manager.add_item("health_potion", 3)
			inventory_manager.add_item("mana_potion", 2)
			inventory_manager.add_gold(100)

func change_game_state(new_state: GameState):
	"""Change the current game state and emit signal"""
	var old_state = current_state
	current_state = new_state
	
	# Handle state-specific logic
	match new_state:
		GameState.MAIN_MENU:
			handle_main_menu_state()
		GameState.PLAYING:
			handle_playing_state()
		GameState.PAUSED:
			handle_paused_state()
		GameState.DIALOGUE:
			handle_dialogue_state()
		GameState.INVENTORY:
			handle_inventory_state()
		GameState.COMBAT:
			handle_combat_state()
		GameState.GAME_OVER:
			handle_game_over_state()
	
	# Emit signal for state change
	game_state_changed.emit(new_state)
	
	print("Game state changed from %s to %s" % [old_state, new_state])

func handle_main_menu_state():
	"""Handle main menu state logic"""
	# Pause game processes
	get_tree().paused = false
	
	# Show main menu UI
	var main_menu = get_tree().get_first_node_in_group("main_menu")
	if main_menu:
		main_menu.show()
		main_menu.set_process(true)

func handle_playing_state():
	"""Handle playing state logic"""
	# Resume game processes
	get_tree().paused = false
	
	# Hide UI elements that should be hidden during gameplay
	var game_ui = get_tree().get_first_node_in_group("game_ui")
	if game_ui:
		game_ui.show()
		game_ui.set_process(true)

func handle_paused_state():
	"""Handle paused state logic"""
	# Pause game processes
	get_tree().paused = true
	
	# Show pause menu
	var pause_menu = get_tree().get_first_node_in_group("pause_menu")
	if pause_menu:
		pause_menu.show()
		pause_menu.set_process(true)

func handle_dialogue_state():
	"""Handle dialogue state logic"""
	# Pause other game systems
	get_tree().paused = true
	
	# Show dialogue UI
	var dialogue_panel = get_tree().get_first_node_in_group("dialogue_panel")
	if dialogue_panel:
		dialogue_panel.show()
		dialogue_panel.set_process(true)

func handle_inventory_state():
	"""Handle inventory state logic"""
	# Pause other game systems
	get_tree().paused = true
	
	# Show inventory UI
	var inventory_panel = get_tree().get_first_node_in_group("inventory_panel")
	if inventory_panel:
		inventory_panel.show()
		inventory_panel.set_process(true)

func handle_combat_state():
	"""Handle combat state logic"""
	# Initialize combat systems
	if combat_manager:
		print("Combat state entered - combat system ready")
	# Show combat UI
	var combat_panel = get_tree().get_first_node_in_group("combat_panel")
	if combat_panel:
		combat_panel.show()
		combat_panel.set_process(true)

func handle_game_over_state():
	"""Handle game over state logic"""
	# Pause game processes
	get_tree().paused = true
	
	# Show game over screen
	var game_over_screen = get_tree().get_first_node_in_group("game_over_screen")
	if game_over_screen:
		game_over_screen.show()
		game_over_screen.set_process(true)

func start_new_game():
	"""Start a new game"""
	print("Starting new game...")
	
	# Initialize player data
	player_data.initialize_default_stats()
	
	# Set starting world and location through WorldManager
	if world_manager:
		world_manager.change_world("Terra")
		world_manager.change_location("Arcanum Sanctum")
	
	# Change to playing state
	change_game_state(GameState.PLAYING)
	
	# Load starting scene
	load_world_scene("Terra", "Arcanum Sanctum")

func load_game_data():
	"""Load saved game data"""
	var save_system = get_node("/root/SaveSystem")
	if save_system:
		var save_info = save_system.get_save_info(1)
		if save_info.has("valid") and save_info["valid"]:
			save_system.load_game(1)
		else:
			print("No valid save data found, starting fresh game")

func save_game_data():
	"""Save current game data"""
	var save_system = get_node("/root/SaveSystem")
	if save_system:
		save_system.save_game(1, "Auto Save")
		print("Game data saved successfully")

func load_world_scene(world_name: String, location: String):
	"""Load a specific world scene"""
	print("Loading world: %s, location: %s" % [world_name, location])
	
	# Update world state through WorldManager
	if world_manager:
		world_manager.change_world(world_name)
		world_manager.change_location(location)
	
	# Emit world changed signal
	world_changed.emit(world_name)
	
	# Load the appropriate scene
	var scene_path = "res://scenes/world/%s.tscn" % world_name
	if ResourceLoader.exists(scene_path):
		get_tree().change_scene_to_file(scene_path)
	else:
		print("Scene not found: %s, staying in current scene" % scene_path)

func get_player_stats() -> Dictionary:
	"""Get current player stats"""
	return player_data.get_stats()

func update_player_stats(stats: Dictionary):
	"""Update player stats"""
	player_data.update_stats(stats)
	player_stats_updated.emit()

func get_current_world() -> String:
	"""Get current world name"""
	if world_manager:
		return world_manager.get_current_world()
	return "Terra"

func get_current_location() -> String:
	"""Get current location name"""
	if world_manager:
		return world_manager.get_current_location()
	return "Arcanum Sanctum"

func get_current_game_state() -> GameState:
	"""Get current game state"""
	return current_state

func get_game_time() -> Dictionary:
	"""Get the current game time"""
	return game_time

func advance_time(minutes: int = 1):
	"""Advance the game time by the specified number of minutes"""
	game_time["minute"] += minutes
	
	# Handle hour overflow
	while game_time["minute"] >= 60:
		game_time["minute"] -= 60
		game_time["hour"] += 1
	
	# Handle day overflow
	while game_time["hour"] >= 24:
		game_time["hour"] -= 24
		game_time["day"] += 1
	
	print("Time advanced to Day %d, %02d:%02d" % [game_time["day"], game_time["hour"], game_time["minute"]])

func is_in_combat() -> bool:
	"""Check if currently in combat"""
	return current_state == GameState.COMBAT

func is_in_dialogue() -> bool:
	"""Check if currently in dialogue"""
	return current_state == GameState.DIALOGUE

func is_paused() -> bool:
	"""Check if game is paused"""
	return current_state == GameState.PAUSED 
