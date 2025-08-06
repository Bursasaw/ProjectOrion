extends Node
# class_name WorldEvents # Removed to avoid autoload conflict

# World Events - Handles random encounters, world interactions, and events
# Manages exploration events, discoveries, and world reactivity

signal event_triggered(event_id: String)
signal encounter_started(encounter_id: String)
signal discovery_made(discovery_id: String)

# Event data
var world_events: Dictionary = {}
var active_events: Array[String] = []
var completed_events: Array[String] = []

# Event types
enum EventType {
	RANDOM_ENCOUNTER,
	DISCOVERY,
	PUZZLE,
	TRAP,
	TREASURE,
	NPC_INTERACTION,
	ENVIRONMENTAL
}

func _ready():
	"""Initialize world events"""
	load_event_data()

func load_event_data():
	"""Load world event data from external JSON file"""
	var file = FileAccess.open("res://data/events/events.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var data = json.data
			world_events = data.get("events", {})
			print("World events loaded successfully from JSON")
		else:
			print("Failed to parse world events JSON")
			initialize_fallback_events()
	else:
		print("Failed to load world events file")
		initialize_fallback_events()

func initialize_fallback_events():
	"""Initialize fallback event data if JSON loading fails"""
	print("Using fallback world events")
	world_events = {
		"wisdom_insight": {
			"name": "Wisdom Insight",
			"description": "A moment of clarity reveals ancient knowledge.",
			"type": "discovery",
			"location": "Arcanum Sanctum",
			"world": "Terra",
			"rewards": {
				"experience": 25,
				"skill_points": 1
			}
		}
	}

func trigger_event(event_id: String, location: String = "") -> bool:
	"""Trigger a world event"""
	if not world_events.has(event_id):
		print("Event not found: ", event_id)
		return false
	
	var event = world_events[event_id]
	
	# Check location requirements
	if event.has("requirements") and event["requirements"].has("location"):
		if location != event["requirements"]["location"]:
			print("Event location requirement not met")
			return false
	
	# Check if event is already active
	if active_events.has(event_id):
		print("Event already active: ", event_id)
		return false
	
	# Add to active events
	active_events.append(event_id)
	
	# Emit signal
	event_triggered.emit(event_id)
	
	# Handle event type
	match event["type"]:
		"random_encounter":
			handle_encounter(event_id, event)
		"discovery":
			handle_discovery(event_id, event)
		"puzzle":
			handle_puzzle(event_id, event)
		"trap":
			handle_trap(event_id, event)
		"treasure":
			handle_treasure(event_id, event)
		"npc_interaction":
			handle_npc_interaction(event_id, event)
		"environmental":
			handle_environmental_event(event_id, event)
	
	print("Triggered event: ", event_id)
	return true

func handle_encounter(event_id: String, event: Dictionary):
	"""Handle random encounter event"""
	encounter_started.emit(event_id)
	
	# Start combat system
	if event.has("combat"):
		print("Starting combat encounter: ", event["combat"]["enemies"])
		var game_manager = get_node("/root/GameManager")
		if game_manager and game_manager.combat_manager:
			# Create enemies based on encounter data
			var enemies = []
			var combat_actor_script = load("res://scripts/characters/CombatActor.gd")
			
			for enemy_data in event["combat"]["enemies"]:
				match enemy_data["type"]:
					"goblin":
						enemies.append(combat_actor_script.create_goblin())
					"skeleton":
						enemies.append(combat_actor_script.create_skeleton())
					"void_creature":
						enemies.append(combat_actor_script.create_void_creature())
			
			# Create player actor
			var player_actor = combat_actor_script.new()
			player_actor.set_player_data(game_manager.player_data)
			
			# Start combat
			game_manager.combat_manager.start_combat(player_actor, enemies)
			game_manager.change_game_state(GameManager.GameState.COMBAT)

func handle_discovery(event_id: String, event: Dictionary):
	"""Handle discovery event"""
	discovery_made.emit(event_id)
	
	# Give rewards
	give_event_rewards(event_id, event)

func handle_puzzle(event_id: String, event: Dictionary):
	"""Handle puzzle event"""
	if event.has("puzzle"):
		var puzzle = event["puzzle"]
		print("Puzzle: ", puzzle["question"])
		
		# Show puzzle UI
		var game_manager = get_node("/root/GameManager")
		if game_manager:
			var puzzle_panel = game_manager.get_node("PuzzlePanel")
			if puzzle_panel:
				puzzle_panel.initialize_puzzle(event_id, event)
				puzzle_panel.show_puzzle_panel()
				puzzle_panel.puzzle_solved.connect(_on_puzzle_solved)
				puzzle_panel.puzzle_closed.connect(_on_puzzle_closed)
			else:
				# Fallback: auto-solve puzzle
				print("Puzzle solved automatically")
				give_event_rewards(event_id, event)
		else:
			print("Game manager not available for puzzle")

func handle_trap(event_id: String, event: Dictionary):
	"""Handle trap event"""
	if event.has("effects"):
		var effects = event["effects"]
		print("Trap effects: ", effects)
		# Apply trap effects to player
		var game_manager = get_node("/root/GameManager")
		if game_manager and game_manager.player_data:
			var player_data = game_manager.player_data
			for effect_type in effects:
				match effect_type:
					"damage":
						player_data.health_points = max(1, player_data.health_points - effects[effect_type])
						print("Player takes %d damage from trap" % effects[effect_type])
					"poison":
						# Add poison effect to player
						print("Player is poisoned")
					"blind":
						# Add blind effect to player
						print("Player is blinded")
		
		# Give rewards if trap was avoided or survived
		give_event_rewards(event_id, event)

func handle_treasure(event_id: String, event: Dictionary):
	"""Handle treasure event"""
	give_event_rewards(event_id, event)

func handle_npc_interaction(_event_id: String, event: Dictionary):
	"""Handle NPC interaction event"""
	if event.has("dialogue"):
		var dialogue = event["dialogue"]
		var dialogue_manager = get_node("/root/DialogueManager")
		if dialogue_manager:
			dialogue_manager.start_dialogue(dialogue["character"], dialogue["node"])

func handle_environmental_event(event_id: String, event: Dictionary):
	"""Handle environmental event"""
	if event.has("effects"):
		var effects = event["effects"]
		print("Environmental effects: ", effects)
		# Apply environmental effects
		var game_manager = get_node("/root/GameManager")
		if game_manager and game_manager.player_data:
			var player_data = game_manager.player_data
			for effect_type in effects:
				match effect_type:
					"healing":
						player_data.health_points = min(player_data.max_health_points, player_data.health_points + effects[effect_type])
						print("Player healed by %d from environment" % effects[effect_type])
					"mana_restore":
						player_data.magic_points = min(player_data.max_magic_points, player_data.magic_points + effects[effect_type])
						print("Player mana restored by %d from environment" % effects[effect_type])
					"experience":
						player_data.gain_experience(effects[effect_type])
						print("Player gained %d experience from environment" % effects[effect_type])
		
		# Give additional rewards
		give_event_rewards(event_id, event)

func _on_puzzle_solved(puzzle_id: String, rewards: Dictionary):
	"""Handle puzzle solved event"""
	print("Puzzle solved: ", puzzle_id)
	give_event_rewards(puzzle_id, {"rewards": rewards})

func _on_puzzle_closed():
	"""Handle puzzle closed event"""
	print("Puzzle closed")

func give_event_rewards(_event_id: String, event: Dictionary):
	"""Give rewards for completing an event"""
	if not event.has("rewards"):
		return
	
	var rewards = event["rewards"]
	var game_manager = get_node("/root/GameManager")
	
	if game_manager and game_manager.player_data:
		var player_data = game_manager.player_data
		
		# Give experience
		if rewards.has("experience"):
			player_data.gain_experience(rewards["experience"])
		
		# Give gold
		if rewards.has("gold_amount"):
			player_data.gold += rewards["gold_amount"]
		
		# Give items
		if rewards.has("items"):
			var inventory_manager = game_manager.inventory_manager
			if inventory_manager:
				for item_id in rewards["items"]:
					inventory_manager.add_item(item_id, 1)
					print("Item reward: ", item_id)
			else:
				print("Inventory manager not available for item rewards")
		
		# Update reputation
		if rewards.has("reputation"):
			for faction in rewards["reputation"]:
				if player_data.reputation.has(faction):
					player_data.reputation[faction] += rewards["reputation"][faction]

func complete_event(event_id: String):
	"""Complete an event"""
	if not active_events.has(event_id):
		return
	
	active_events.erase(event_id)
	completed_events.append(event_id)
	
	print("Completed event: ", event_id)

func get_event_info(event_id: String) -> Dictionary:
	"""Get information about an event"""
	if not world_events.has(event_id):
		return {}
	
	return world_events[event_id]

func get_event_data(event_id: String) -> Dictionary:
	"""Get event data (alias for get_event_info)"""
	return get_event_info(event_id)

func get_active_events() -> Array[String]:
	"""Get all active events"""
	return active_events

func get_completed_events() -> Array[String]:
	"""Get all completed events"""
	return completed_events

func is_event_active(event_id: String) -> bool:
	"""Check if an event is active"""
	return active_events.has(event_id)

func is_event_completed(event_id: String) -> bool:
	"""Check if an event is completed"""
	return completed_events.has(event_id)

func get_events_for_location(location: String) -> Array[String]:
	"""Get all events available for a specific location"""
	var available: Array[String] = []
	
	for event_id in world_events:
		var event = world_events[event_id]
		if event.has("location") and event["location"] == location:
			if not active_events.has(event_id) and not completed_events.has(event_id):
				available.append(event_id)
	
	return available 
