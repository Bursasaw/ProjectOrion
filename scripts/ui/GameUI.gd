extends Control
class_name GameUI

# Game UI - Handles all user interface interactions and game state display
# Manages panels, buttons, and real-time updates

# UI Panel references
@onready var top_panel = $TopPanel
@onready var bottom_panel = $BottomPanel
@onready var right_panel = $RightPanel
@onready var inventory_panel = $InventoryPanel
@onready var character_panel = $CharacterPanel
@onready var menu_panel = $MenuPanel
@onready var combat_panel = $CombatPanel
@onready var dialogue_panel = $DialoguePanel
@onready var quest_panel = $QuestPanel
@onready var settings_panel = $SettingsPanel
@onready var world_map_panel = $WorldMapPanel
@onready var puzzle_panel = $PuzzlePanel

# Player info references
@onready var player_name_label = $TopPanel/TopPanelContainer/PlayerInfo/PlayerName
@onready var level_label = $TopPanel/TopPanelContainer/PlayerInfo/PlayerStats/Level
@onready var hp_label = $TopPanel/TopPanelContainer/PlayerInfo/PlayerStats/HP
@onready var mp_label = $TopPanel/TopPanelContainer/PlayerInfo/PlayerStats/MP

# Game info references
@onready var location_label = $RightPanel/RightPanelContainer/LocationLabel
@onready var world_label = $RightPanel/RightPanelContainer/WorldLabel
@onready var time_label = $RightPanel/RightPanelContainer/TimeLabel
@onready var status_list = $RightPanel/RightPanelContainer/StatusEffects/StatusList

# Game log and action buttons
@onready var game_log = $BottomPanel/BottomPanelContainer/GameLog
@onready var move_button = $BottomPanel/BottomPanelContainer/ActionButtons/MoveButton
@onready var interact_button = $BottomPanel/BottomPanelContainer/ActionButtons/InteractButton
@onready var combat_button = $BottomPanel/BottomPanelContainer/ActionButtons/CombatButton
@onready var cast_button = $BottomPanel/BottomPanelContainer/ActionButtons/CastButton

# Control buttons
@onready var menu_button = $TopPanel/TopPanelContainer/GameControls/MenuButton
@onready var inventory_button = $TopPanel/TopPanelContainer/GameControls/InventoryButton
@onready var character_button = $TopPanel/TopPanelContainer/GameControls/CharacterButton
@onready var world_button = $TopPanel/TopPanelContainer/GameControls/WorldButton
@onready var save_button = $TopPanel/TopPanelContainer/GameControls/SaveButton
@onready var quest_button = $TopPanel/TopPanelContainer/GameControls/QuestButton

# Menu panel buttons
@onready var resume_button = $MenuPanel/MenuContainer/ResumeButton
@onready var menu_save_button = $MenuPanel/MenuContainer/SaveButton
@onready var load_button = $MenuPanel/MenuContainer/LoadButton
@onready var settings_button = $MenuPanel/MenuContainer/SettingsButton
@onready var quit_button = $MenuPanel/MenuContainer/QuitButton

# Combat panel references
@onready var combat_log = $CombatPanel/CombatContainer/CombatLog
@onready var attack_button = $CombatPanel/CombatContainer/CombatActions/AttackButton
@onready var spell_button = $CombatPanel/CombatContainer/CombatActions/SpellButton
@onready var item_button = $CombatPanel/CombatContainer/CombatActions/ItemButton
@onready var flee_button = $CombatPanel/CombatContainer/CombatActions/FleeButton

# Dialogue panel references
@onready var speaker_label = $DialoguePanel/DialogueContainer/SpeakerLabel
@onready var dialogue_text = $DialoguePanel/DialogueContainer/DialogueText
@onready var dialogue_choices = $DialoguePanel/DialogueContainer/DialogueChoices
@onready var choice1_button = $DialoguePanel/DialogueContainer/DialogueChoices/Choice1
@onready var choice2_button = $DialoguePanel/DialogueContainer/DialogueChoices/Choice2
@onready var choice3_button = $DialoguePanel/DialogueContainer/DialogueChoices/Choice3

# Inventory panel references
@onready var inventory_grid = $InventoryPanel/InventoryContainer/InventoryGrid
@onready var close_inventory_button = $InventoryPanel/InventoryContainer/CloseInventoryButton

# Character panel references
@onready var character_stats = $CharacterPanel/CharacterContainer/CharacterStats
@onready var close_character_button = $CharacterPanel/CharacterContainer/CloseCharacterButton

# Game managers
var game_manager
var save_system
var dialogue_manager: Node
var quest_manager: Node

# UI state
var current_panel: Control = null
var is_paused: bool = false

func _ready():
	# Get game managers
	game_manager = get_node("/root/GameManager")
	save_system = get_node("/root/SaveSystem")
	dialogue_manager = get_node("/root/DialogueManager")
	quest_manager = get_node("/root/QuestManager")
	
	# Connect button signals
	_connect_button_signals()
	
	# Connect game manager signals
	if game_manager:
		game_manager.game_state_changed.connect(_on_game_state_changed)
		game_manager.player_stats_updated.connect(_on_player_stats_updated)
		game_manager.world_changed.connect(_on_world_changed)
	
	# Connect save system signals
	if save_system:
		save_system.save_completed.connect(_on_save_completed)
		save_system.load_completed.connect(_on_load_completed)
		save_system.save_failed.connect(_on_save_failed)
		save_system.load_failed.connect(_on_load_failed)
	
	# Initialize UI
	_update_player_info()
	_update_world_info()
	_add_game_log_message("Welcome to Arcanum Origins: Before the Veil. Your journey begins here...")

func _connect_button_signals():
	# Top panel buttons
	menu_button.pressed.connect(_on_menu_button_pressed)
	inventory_button.pressed.connect(_on_inventory_button_pressed)
	character_button.pressed.connect(_on_character_button_pressed)
	world_button.pressed.connect(_on_world_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	quest_button.pressed.connect(_on_quest_button_pressed)
	
	# Action buttons
	move_button.pressed.connect(_on_move_button_pressed)
	interact_button.pressed.connect(_on_interact_button_pressed)
	combat_button.pressed.connect(_on_combat_button_pressed)
	cast_button.pressed.connect(_on_cast_button_pressed)
	
	# Menu panel buttons
	resume_button.pressed.connect(_on_resume_button_pressed)
	menu_save_button.pressed.connect(_on_menu_save_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	
	# Combat panel buttons
	attack_button.pressed.connect(_on_attack_button_pressed)
	spell_button.pressed.connect(_on_spell_button_pressed)
	item_button.pressed.connect(_on_item_button_pressed)
	flee_button.pressed.connect(_on_flee_button_pressed)
	
	# Panel close buttons
	close_inventory_button.pressed.connect(_on_close_inventory_button_pressed)
	close_character_button.pressed.connect(_on_close_character_button_pressed)
	
	# Dialogue choice buttons
	choice1_button.pressed.connect(_on_choice1_pressed)
	choice2_button.pressed.connect(_on_choice2_pressed)
	choice3_button.pressed.connect(_on_choice3_pressed)

func _update_player_info():
	"""Update player information display"""
	if game_manager and game_manager.player_data:
		var player_data = game_manager.player_data
		player_name_label.text = player_data.character_name + " - " + player_data.character_class
		level_label.text = "Level: " + str(player_data.level)
		hp_label.text = "HP: " + str(player_data.health_points) + "/" + str(player_data.max_health_points)
		mp_label.text = "MP: " + str(player_data.magic_points) + "/" + str(player_data.max_magic_points)
		
		# Update gold display if inventory manager is available
		if game_manager.inventory_manager:
			var gold_label = get_node_or_null("TopPanel/TopPanelContainer/PlayerInfo/PlayerStats/Gold")
			if not gold_label:
				# Create gold label if it doesn't exist
				var gold_container = get_node("TopPanel/TopPanelContainer/PlayerInfo/PlayerStats")
				var new_gold_label = Label.new()
				new_gold_label.name = "Gold"
				new_gold_label.text = "Gold: " + str(game_manager.inventory_manager.get_gold())
				gold_container.add_child(new_gold_label)
			else:
				gold_label.text = "Gold: " + str(game_manager.inventory_manager.get_gold())

func _update_world_info():
	"""Update world and location information"""
	if game_manager:
		location_label.text = "Location: " + game_manager.get_current_location()
		world_label.text = "World: " + game_manager.get_current_world()
		# Implement basic time system
		var game_time = game_manager.get_game_time()
		if game_time:
			time_label.text = "Time: Day %d, %02d:%02d" % [game_time["day"], game_time["hour"], game_time["minute"]]
		else:
			time_label.text = "Time: Day 1, 06:00"

func _update_status_effects():
	"""Update status effects display"""
	if game_manager and game_manager.player_data:
		var player_data = game_manager.player_data
		status_list.clear()
		
		# Add buffs
		for buff in player_data.buffs:
			status_list.add_item("+" + buff["name"] + " (" + str(buff["remaining"]) + " turns)")
		
		# Add debuffs
		for debuff in player_data.debuffs:
			status_list.add_item("-" + debuff["name"] + " (" + str(debuff["remaining"]) + " turns)")

func _add_game_log_message(message: String):
	"""Add a message to the game log"""
	game_log.append_text("\n" + message)

func _show_panel(panel: Control):
	"""Show a specific panel and hide others"""
	# Hide all panels
	inventory_panel.visible = false
	character_panel.visible = false
	menu_panel.visible = false
	combat_panel.visible = false
	dialogue_panel.visible = false
	
	# Show requested panel
	if panel:
		panel.visible = true
		current_panel = panel
	else:
		current_panel = null

func _on_game_state_changed(new_state):
	"""Handle game state changes"""
	match new_state:
		GameManager.GameState.MAIN_MENU:
			_show_panel(menu_panel)
		GameManager.GameState.PLAYING:
			_show_panel(null)
		GameManager.GameState.COMBAT:
			_show_panel(combat_panel)
		GameManager.GameState.DIALOGUE:
			_show_panel(dialogue_panel)
			_update_dialogue_display()
		GameManager.GameState.INVENTORY:
			_show_panel(inventory_panel)
		GameManager.GameState.PAUSED:
			_show_panel(menu_panel)

func _on_player_stats_updated():
	"""Handle player stats updates"""
	_update_player_info()
	_update_status_effects()

func _on_world_changed(world_name: String):
	"""Handle world changes"""
	_update_world_info()
	_add_game_log_message("You have entered " + world_name + ".")

func _update_dialogue_display():
	"""Update dialogue display with current dialogue"""
	if not dialogue_manager or not dialogue_manager.is_dialogue_active():
		return
	
	var current_dialogue = dialogue_manager.get_current_dialogue()
	if current_dialogue.is_empty():
		return
	
	# Update speaker name
	var character_info = dialogue_manager.get_character_info(dialogue_manager.get_current_character())
	if not character_info.is_empty():
		speaker_label.text = character_info.get("name", "Unknown")
	
	# Update dialogue text
	dialogue_text.text = current_dialogue.get("text", "")
	
	# Update choices
	var choices = current_dialogue.get("choices", [])
	_update_dialogue_choices(choices)

func _update_dialogue_choices(choices: Array):
	"""Update dialogue choice buttons"""
	choice1_button.visible = false
	choice2_button.visible = false
	choice3_button.visible = false
	
	if choices.size() > 0:
		choice1_button.text = choices[0].get("text", "")
		choice1_button.visible = true
	
	if choices.size() > 1:
		choice2_button.text = choices[1].get("text", "")
		choice2_button.visible = true
	
	if choices.size() > 2:
		choice3_button.text = choices[2].get("text", "")
		choice3_button.visible = true

func _update_inventory_display():
	"""Update inventory display"""
	if not game_manager or not game_manager.inventory_manager:
		return
	
	var inventory_manager = game_manager.inventory_manager
	var items = inventory_manager.get_all_items()
	
	# Clear existing inventory grid
	for child in inventory_grid.get_children():
		child.queue_free()
	
	# Add items to grid
	for item_id in items:
		var item_info = inventory_manager.get_item_info(item_id)
		var item_count = items[item_id]
		
		# Create item button
		var inventory_item_button = Button.new()
		inventory_item_button.text = "%s (%d)" % [item_info.get("name", item_id), item_count]
		inventory_item_button.custom_minimum_size = Vector2(100, 30)
		
		# Connect button signal
		inventory_item_button.pressed.connect(_on_inventory_item_pressed.bind(item_id))
		
		inventory_grid.add_child(inventory_item_button)
	
	_add_game_log_message("Inventory updated - %d different items" % items.size())

func _on_inventory_item_pressed(item_id: String):
	"""Handle inventory item button press"""
	var inventory_manager = game_manager.inventory_manager
	var item_info = inventory_manager.get_item_info(item_id)
	
	_add_game_log_message("Selected: %s - %s" % [item_info.get("name", item_id), item_info.get("description", "No description")])
	
	# Check if item is usable
	if item_info.get("usable", false):
		if inventory_manager.use_item(item_id):
			_add_game_log_message("Used %s" % item_info.get("name", item_id))
			_update_player_info()  # Refresh player stats
		else:
			_add_game_log_message("Cannot use %s" % item_info.get("name", item_id))
	else:
		_add_game_log_message("%s is not usable" % item_info.get("name", item_id))

func _on_choice1_pressed():
	"""Handle first dialogue choice"""
	if dialogue_manager:
		dialogue_manager.make_choice(0)
		_update_dialogue_display()

func _on_choice2_pressed():
	"""Handle second dialogue choice"""
	if dialogue_manager:
		dialogue_manager.make_choice(1)
		_update_dialogue_display()

func _on_choice3_pressed():
	"""Handle third dialogue choice"""
	if dialogue_manager:
		dialogue_manager.make_choice(2)
		_update_dialogue_display()

# Button event handlers
func _on_menu_button_pressed():
	game_manager.change_game_state(GameManager.GameState.PAUSED)

func _on_inventory_button_pressed():
	_add_game_log_message("Opening inventory...")
	game_manager.change_game_state(GameManager.GameState.INVENTORY)
	_update_inventory_display()

func _on_character_button_pressed():
	_show_panel(character_panel)

func _on_world_button_pressed():
	_add_game_log_message("Opening world map...")
	
	# Show world map panel
	if world_map_panel:
		world_map_panel.show_world_map()
	else:
		print("World map panel not found")

func _on_save_button_pressed():
	if save_system:
		save_system.quick_save()

func _on_quest_button_pressed():
	"""Handle quest button press"""
	_add_game_log_message("Opening quest log...")
	
	# Show quest panel
	if quest_panel:
		quest_panel.show_quest_panel()
		quest_panel.set_quest_manager(quest_manager)
	else:
		print("Quest panel not found")
		
	if quest_manager:
		print("Quest manager available")
		# Show available quests info
		var available_quests = quest_manager.get_available_quests()
		if available_quests.size() > 0:
			_add_game_log_message("Available quests: " + str(available_quests.size()))
		else:
			_add_game_log_message("No quests available at the moment.")

func _on_move_button_pressed():
	_add_game_log_message("You begin to move...")

func _on_interact_button_pressed():
	_add_game_log_message("You look around for something to interact with...")
	
	# Check if there's a character to interact with
	if dialogue_manager:
		# For now, start dialogue with Elder Magus if in Arcanum Sanctum
		if game_manager and game_manager.get_current_location() == "Arcanum Sanctum":
			dialogue_manager.start_dialogue("elder_magus")
			game_manager.change_game_state(GameManager.GameState.DIALOGUE)
	
	# Check for world events
	if game_manager and game_manager.world_events:
		var current_location = game_manager.get_current_location()
		var available_events = game_manager.world_events.get_events_for_location(current_location)
		
		if available_events.size() > 0:
			# Trigger a random event
			var random_event = available_events[randi() % available_events.size()]
			if game_manager.world_events.trigger_event(random_event, current_location):
				_add_game_log_message("Something interesting happens...")
			else:
				_add_game_log_message("You find nothing of interest.")
		else:
			_add_game_log_message("You find nothing of interest.")

func _on_combat_button_pressed():
	_add_game_log_message("Starting combat...")
	
	# Create player combat actor
	var combat_actor_script = load("res://scripts/characters/CombatActor.gd")
	var player_actor = combat_actor_script.new()
	player_actor.character_name = game_manager.player_data.character_name
	player_actor.character_class = game_manager.player_data.character_class
	player_actor.level = game_manager.player_data.level
	
	# Copy stats from player data
	var stats = game_manager.player_data.get_stats()
	player_actor.health_points = stats.get("health_points", 100)
	player_actor.max_health_points = stats.get("max_health_points", 100)
	player_actor.magic_points = stats.get("magic_points", 50)
	player_actor.max_magic_points = stats.get("max_magic_points", 50)
	player_actor.attack = stats.get("attack", 15)
	player_actor.defense = stats.get("defense", 10)
	player_actor.magic_attack = stats.get("magic_attack", 12)
	player_actor.magic_defense = stats.get("magic_defense", 8)
	player_actor.speed = stats.get("speed", 10)
	
	# Set player data reference
	player_actor.set_player_data(game_manager.player_data)
	
	# Add basic attack action
	var combat_action_script = load("res://scripts/core/CombatAction.gd")
	var attack_action = combat_action_script.new()
	attack_action.name = "Basic Attack"
	attack_action.action_type = combat_action_script.ActionType.ATTACK
	attack_action.power = 10
	attack_action.cost = 0
	attack_action.cost_type = "none"
	player_actor.add_action(attack_action)
	
	# Create enemies based on location
	var enemies = []
	var current_location = game_manager.get_current_location()
	
	match current_location:
		"Arcanum Sanctum":
			enemies.append(combat_actor_script.create_skeleton())
		"Nokturn Market":
			enemies.append(combat_actor_script.create_goblin())
			enemies.append(combat_actor_script.create_goblin())
		"Void Rift":
			enemies.append(combat_actor_script.create_void_creature())
		_:
			enemies.append(combat_actor_script.create_goblin())
	
	# Start combat
	var combat_manager = game_manager.get_node("CombatManager")
	if combat_manager:
		combat_manager.start_combat(player_actor, enemies)
		game_manager.change_game_state(GameManager.GameState.COMBAT)
		_add_game_log_message("Combat started with %d enemies!" % enemies.size())
	else:
		_add_game_log_message("Combat system not available")

func _on_cast_button_pressed():
	_add_game_log_message("You prepare to cast a spell...")

func _on_resume_button_pressed():
	game_manager.change_game_state(GameManager.GameState.PLAYING)

func _on_menu_save_button_pressed():
	if save_system:
		save_system.save_game(1, "Manual Save")

func _on_load_button_pressed():
	_add_game_log_message("Loading game...")
	
	if save_system:
		var save_info = save_system.get_save_info(1)
		if save_info.has("valid") and save_info["valid"]:
			save_system.load_game(1)
			_add_game_log_message("Game loaded successfully!")
		else:
			_add_game_log_message("No valid save data found.")
	else:
		_add_game_log_message("Save system not available.")

func _on_settings_button_pressed():
	_add_game_log_message("Opening settings...")
	
	# Show settings panel
	if settings_panel:
		settings_panel.show_settings_panel()
	else:
		print("Settings panel not found")

func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _on_attack_button_pressed():
	_add_game_log_message("You prepare to attack!")

func _on_spell_button_pressed():
	_add_game_log_message("You prepare to cast a spell!")

func _on_item_button_pressed():
	_add_game_log_message("You reach for an item...")

func _on_flee_button_pressed():
	game_manager.change_game_state(GameManager.GameState.PLAYING)
	_add_game_log_message("You attempt to flee from combat!")

func _on_close_inventory_button_pressed():
	game_manager.change_game_state(GameManager.GameState.PLAYING)

func _on_close_character_button_pressed():
	_show_panel(null)

# Save system event handlers
func _on_save_completed(save_name: String):
	_add_game_log_message("Game saved successfully: " + save_name)

func _on_load_completed(save_name: String):
	_add_game_log_message("Game loaded successfully: " + save_name)
	_update_player_info()
	_update_world_info()

func _on_save_failed(error: String):
	_add_game_log_message("Save failed: " + error)

func _on_load_failed(error: String):
	_add_game_log_message("Load failed: " + error)

# Public methods for external use
func show_dialogue(speaker: String, text: String, choices: Array[String] = []):
	"""Show dialogue panel with speaker and text"""
	speaker_label.text = speaker
	dialogue_text.text = text
	
	# Clear existing choices
	for child in dialogue_choices.get_children():
		child.queue_free()
	
	# Add new choices
	for i in range(choices.size()):
		var choice_button = Button.new()
		choice_button.text = choices[i]
		choice_button.pressed.connect(_on_dialogue_choice_pressed.bind(i))
		dialogue_choices.add_child(choice_button)
	
	_show_panel(dialogue_panel)

func _on_dialogue_choice_pressed(choice_index: int):
	"""Handle dialogue choice selection"""
	_add_game_log_message("You chose option " + str(choice_index + 1))
	_show_panel(null)
	game_manager.change_game_state(GameManager.GameState.PLAYING)

func update_combat_log(message: String):
	"""Update the combat log"""
	combat_log.append_text("\n" + message)

func show_combat_actions(actions):
	"""Show available combat actions"""
	# Clear existing action buttons
	attack_button.visible = false
	spell_button.visible = false
	item_button.visible = false
	
	# Load CombatAction script for enum access
	var combat_action_script = load("res://scripts/core/CombatAction.gd")
	
	# Show available actions
	for action in actions:
		match action.action_type:
			combat_action_script.ActionType.ATTACK:
				attack_button.visible = true
			combat_action_script.ActionType.SPELL:
				spell_button.visible = true
			combat_action_script.ActionType.ITEM:
				item_button.visible = true 
