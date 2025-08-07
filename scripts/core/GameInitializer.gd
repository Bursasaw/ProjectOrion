extends Node
class_name GameInitializer

# Game Initializer - Sets up the game on startup
# Initializes all systems and starts the game flow

signal game_initialized()
signal initialization_failed(error: String)

# Game managers
var game_flow_manager: GameFlowManager
var enemy_encounter_manager: EnemyEncounterManager
var quest_integration: QuestIntegration
var game_ui: GameUI

func _ready():
	# Wait a frame to ensure all nodes are ready
	await get_tree().process_frame
	
	# Initialize game systems
	_initialize_game_systems()
	
	# Start the game
	_start_game()

func _initialize_game_systems():
	"""Initialize all game systems"""
	print("Initializing game systems...")
	
	# Get references to managers
	game_flow_manager = get_node_or_null("/root/GameFlowManager")
	enemy_encounter_manager = get_node_or_null("/root/EnemyEncounterManager")
	quest_integration = get_node_or_null("/root/QuestIntegration")
	game_ui = get_node_or_null("/root/GameUI")
	
	# Check if all required systems are available
	if not game_flow_manager:
		initialization_failed.emit("GameFlowManager not found")
		return
	
	if not enemy_encounter_manager:
		initialization_failed.emit("EnemyEncounterManager not found")
		return
	
	if not game_ui:
		initialization_failed.emit("GameUI not found")
		return
	
	print("All game systems found and ready")

func _start_game():
	"""Start the game flow"""
	print("Starting game...")
	
	# Start a new game
	if game_flow_manager:
		game_flow_manager.start_new_game()
	
	# Emit initialization complete
	game_initialized.emit()
	print("Game initialization complete!")

func restart_game():
	"""Restart the game"""
	print("Restarting game...")
	
	if game_flow_manager:
		game_flow_manager.start_new_game()
	
	print("Game restarted!")

func load_saved_game(save_data: Dictionary):
	"""Load a saved game"""
	print("Loading saved game...")
	
	if game_flow_manager:
		game_flow_manager.load_game_state(save_data)
	
	print("Saved game loaded!")

func get_game_state() -> Dictionary:
	"""Get the current game state for saving"""
	if game_flow_manager:
		return game_flow_manager.save_game_state()
	return {}

func is_game_ready() -> bool:
	"""Check if the game is ready to play"""
	return game_flow_manager != null and enemy_encounter_manager != null and game_ui != null 