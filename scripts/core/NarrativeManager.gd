extends Node
# class_name NarrativeManager

# Narrative Manager - Core story progression for text-based RPG
# Handles story nodes, branching narratives, and world state changes

signal narrative_node_changed(node_id: String)
signal story_progressed(chapter: String, progress: float)
signal world_state_changed(world: String, location: String)

# Narrative state
var current_chapter: String = "prologue"
var current_node: String = "start"
var story_progress: float = 0.0
var visited_nodes: Array[String] = []

# World state tracking
var world_states: Dictionary = {}
var location_states: Dictionary = {}

# Story data
var story_data: Dictionary = {}
var chapter_data: Dictionary = {}

# Player choices tracking
var player_choices: Dictionary = {}
var story_flags: Dictionary = {}

func _ready():
	"""Initialize narrative manager"""
	load_story_data()
	initialize_world_states()

func load_story_data():
	"""Load story data from JSON files"""
	# Load main story structure
	var file = FileAccess.open("res://data/story/main_story.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		if parse_result == OK:
			story_data = json.data
			print("Story data loaded successfully")
		else:
			print("Failed to parse story data")
		file.close()
	else:
		print("Creating fallback story data")
		create_fallback_story_data()

func create_fallback_story_data():
	"""Create fallback story data for alpha testing"""
	story_data = {
		"prologue": {
			"name": "The Awakening",
			"description": "Arius awakens in the Arcanum Sanctum, drawn by mysterious visions.",
			"nodes": {
				"start": {
					"text": "You awaken in the Arcanum Sanctum, the ancient seat of magical knowledge. Visions of a fractured Veil haunt your dreams, and a sense of urgency fills your being. The air crackles with untamed magic, and you know your journey as a Seeker has begun.",
					"choices": [
						{
							"text": "Examine your surroundings",
							"next_node": "examine_sanctum",
							"effects": {"exploration": 1}
						},
						{
							"text": "Seek out the Elder Magus",
							"next_node": "find_elder",
							"effects": {"social": 1}
						},
						{
							"text": "Meditate on your visions",
							"next_node": "meditation",
							"effects": {"magic": 1}
						}
					]
				},
				"examine_sanctum": {
					"text": "The Sanctum's ancient halls are lined with magical artifacts and glowing crystals. You notice strange fluctuations in the magical energy around you, confirming your visions of the Veil's instability.",
					"choices": [
						{
							"text": "Investigate the magical fluctuations",
							"next_node": "investigate_magic",
							"effects": {"magic": 2, "exploration": 1}
						},
						{
							"text": "Continue to find the Elder Magus",
							"next_node": "find_elder",
							"effects": {"social": 1}
						}
					]
				},
				"find_elder": {
					"text": "You find Elder Magus Thalor in his study, surrounded by ancient tomes. His weathered face shows concern as he looks up from his reading.",
					"choices": [
						{
							"text": "Tell him about your visions",
							"next_node": "share_visions",
							"effects": {"social": 2, "quest": "sanctum_trials"}
						},
						{
							"text": "Ask about the Sanctum's history",
							"next_node": "ask_history",
							"effects": {"knowledge": 1}
						}
					]
				},
				"meditation": {
					"text": "As you meditate, the visions become clearer. You see rifts in the Veil, dark forces gathering, and the need for a Seeker to restore balance.",
					"choices": [
						{
							"text": "Focus on the rifts",
							"next_node": "focus_rifts",
							"effects": {"magic": 2, "quest": "investigate_rifts"}
						},
						{
							"text": "Seek guidance from the Elder",
							"next_node": "find_elder",
							"effects": {"social": 1}
						}
					]
				}
			}
		},
		"chapter_1": {
			"name": "The First Trials",
			"description": "Begin your training as a Seeker and face the first challenges.",
			"nodes": {
				"trial_chamber": {
					"text": "You enter the Chamber of Elements, the first trial of the Sanctum. The air hums with elemental energy as you prepare to prove your worth.",
					"choices": [
						{
							"text": "Channel fire magic",
							"next_node": "fire_trial",
							"effects": {"magic": 1, "element": "fire"}
						},
						{
							"text": "Channel water magic",
							"next_node": "water_trial",
							"effects": {"magic": 1, "element": "water"}
						},
						{
							"text": "Channel earth magic",
							"next_node": "earth_trial",
							"effects": {"magic": 1, "element": "earth"}
						}
					]
				}
			}
		}
	}

func initialize_world_states():
	"""Initialize world states for all realms"""
	var worlds = ["Terra", "Nokturn", "Elysion", "Sylithar", "Aethra", "Ombra", "Krynn", "Tauron", "Aelria"]
	for world in worlds:
		world_states[world] = {
			"discovered": false,
			"access_level": 0,
			"reputation": 0,
			"completed_quests": [],
			"current_events": []
		}
	
	# Set Terra as starting world
	world_states["Terra"]["discovered"] = true
	world_states["Terra"]["access_level"] = 1

func get_current_narrative_node() -> Dictionary:
	"""Get the current narrative node data"""
	if not story_data.has(current_chapter):
		return {}
	
	var chapter = story_data[current_chapter]
	if not chapter.has("nodes") or not chapter["nodes"].has(current_node):
		return {}
	
	return chapter["nodes"][current_node]

func progress_narrative(choice_index: int):
	"""Progress the narrative based on player choice"""
	var current_node_data = get_current_narrative_node()
	if current_node_data.is_empty():
		return false
	
	if choice_index >= current_node_data["choices"].size():
		print("Invalid choice index: ", choice_index)
		return false
	
	var choice = current_node_data["choices"][choice_index]
	
	# Apply choice effects
	apply_choice_effects(choice)
	
	# Move to next node
	var next_node = choice.get("next_node", "")
	if next_node:
		current_node = next_node
		visited_nodes.append(current_node)
		
		# Check if we need to change chapters
		if next_node.contains("chapter_"):
			progress_to_chapter(next_node)
		
		narrative_node_changed.emit(current_node)
		return true
	
	return false

func apply_choice_effects(choice: Dictionary):
	"""Apply the effects of a player choice"""
	var effects = choice.get("effects", {})
	
	for effect_type in effects:
		match effect_type:
			"magic":
				# Increase magic skill
				var game_manager = get_node("/root/GameManager")
				if game_manager and game_manager.player_data:
					game_manager.player_data.add_skill_points("magic", effects[effect_type])
			"social":
				# Increase social skill
				var game_manager = get_node("/root/GameManager")
				if game_manager and game_manager.player_data:
					game_manager.player_data.add_skill_points("social", effects[effect_type])
			"exploration":
				# Increase exploration skill
				var game_manager = get_node("/root/GameManager")
				if game_manager and game_manager.player_data:
					game_manager.player_data.add_skill_points("exploration", effects[effect_type])
			"quest":
				# Start a quest
				var quest_manager = get_node("/root/QuestManager")
				if quest_manager:
					quest_manager.start_quest(effects[effect_type])
			"element":
				# Unlock elemental magic
				var game_manager = get_node("/root/GameManager")
				if game_manager and game_manager.player_data:
					game_manager.player_data.unlock_element(effects[effect_type])
			"world_access":
				# Grant access to a world
				var world = effects[effect_type]
				if world_states.has(world):
					world_states[world]["discovered"] = true
					world_states[world]["access_level"] = 1
					world_state_changed.emit(world, "discovered")

func progress_to_chapter(chapter_id: String):
	"""Progress to a new chapter"""
	if story_data.has(chapter_id):
		current_chapter = chapter_id
		current_node = "start"
		story_progress += 0.1  # Increment progress
		story_progressed.emit(current_chapter, story_progress)

func get_available_choices() -> Array:
	"""Get available choices for current node"""
	var node_data = get_current_narrative_node()
	if node_data.is_empty():
		return []
	
	return node_data.get("choices", [])

func get_current_text() -> String:
	"""Get the current narrative text"""
	var node_data = get_current_narrative_node()
	return node_data.get("text", "No narrative text available.")

func set_story_flag(flag: String, value: bool):
	"""Set a story flag"""
	story_flags[flag] = value

func get_story_flag(flag: String) -> bool:
	"""Get a story flag value"""
	return story_flags.get(flag, false)

func get_world_state(world: String) -> Dictionary:
	"""Get the current state of a world"""
	return world_states.get(world, {})

func set_location_state(world: String, location: String, state: Dictionary):
	"""Set the state of a specific location"""
	if not location_states.has(world):
		location_states[world] = {}
	location_states[world][location] = state

func get_location_state(world: String, location: String) -> Dictionary:
	"""Get the state of a specific location"""
	if location_states.has(world) and location_states[world].has(location):
		return location_states[world][location]
	return {}

func save_narrative_state() -> Dictionary:
	"""Save the current narrative state"""
	return {
		"current_chapter": current_chapter,
		"current_node": current_node,
		"story_progress": story_progress,
		"visited_nodes": visited_nodes,
		"world_states": world_states,
		"location_states": location_states,
		"player_choices": player_choices,
		"story_flags": story_flags
	}

func load_narrative_state(state: Dictionary):
	"""Load a saved narrative state"""
	current_chapter = state.get("current_chapter", "prologue")
	current_node = state.get("current_node", "start")
	story_progress = state.get("story_progress", 0.0)
	visited_nodes = state.get("visited_nodes", [])
	world_states = state.get("world_states", {})
	location_states = state.get("location_states", {})
	player_choices = state.get("player_choices", {})
	story_flags = state.get("story_flags", {}) 