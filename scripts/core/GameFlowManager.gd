extends Node
class_name GameFlowManager

# Game Flow Manager - Handles the text-based RPG game flow
# Manages story progression, scene transitions, and player choices

signal story_progressed(chapter: String, scene: String)
signal choice_made(choice_id: String, result: Dictionary)
signal scene_changed(scene_id: String, scene_data: Dictionary)

# Game state
var current_chapter: String = "prologue"
var current_scene: String = "sanctum_entrance"
var current_location: String = "Arcanum Sanctum"
var current_world: String = "Terra"
var game_time: int = 1
var game_day: int = 1

# Story progression
var completed_scenes: Array[String] = []
var active_quests: Array[String] = []
var story_flags: Dictionary = {}
var player_choices: Dictionary = {}

# Scene data
var scene_data: Dictionary = {
	"sanctum_entrance": {
		"name": "Arcanum Sanctum Entrance",
		"description": "You stand before the ancient Arcanum Sanctum, its towering spires reaching into the sky. The air crackles with untamed magic, and you feel the weight of destiny upon your shoulders.",
		"choices": [
			{
				"id": "enter_sanctum",
				"text": "Enter the Sanctum",
				"next_scene": "sanctum_chamber",
				"requirements": {}
			},
			{
				"id": "examine_surroundings",
				"text": "Examine your surroundings",
				"next_scene": "sanctum_entrance_examine",
				"requirements": {}
			},
			{
				"id": "meditate",
				"text": "Meditate and attune to the magic",
				"next_scene": "sanctum_entrance_meditate",
				"requirements": {}
			}
		],
		"world": "Terra",
		"location": "Arcanum Sanctum"
	},
	"sanctum_chamber": {
		"name": "Chamber of Elements",
		"description": "You enter a vast chamber where the four elements dance in harmony. Ancient runes glow softly on the walls, and you sense a presence watching you.",
		"choices": [
			{
				"id": "approach_elder",
				"text": "Approach the Elder Magus",
				"next_scene": "elder_dialogue",
				"requirements": {}
			},
			{
				"id": "examine_runes",
				"text": "Study the ancient runes",
				"next_scene": "rune_study",
				"requirements": {}
			},
			{
				"id": "test_magic",
				"text": "Test your magical abilities",
				"next_scene": "magic_test",
				"requirements": {}
			}
		],
		"world": "Terra",
		"location": "Arcanum Sanctum"
	},
	"elder_dialogue": {
		"name": "The Elder Magus",
		"description": "A wise figure materializes before you, his robes shimmering with arcane energy. 'Welcome, Seeker. I am Elder Magus Thorne. The Veil calls to you, does it not?'",
		"choices": [
			{
				"id": "accept_quest",
				"text": "I accept the call of the Veil",
				"next_scene": "quest_acceptance",
				"requirements": {}
			},
			{
				"id": "ask_questions",
				"text": "Tell me more about the Veil",
				"next_scene": "veil_explanation",
				"requirements": {}
			},
			{
				"id": "decline",
				"text": "I need time to consider",
				"next_scene": "quest_decline",
				"requirements": {}
			}
		],
		"world": "Terra",
		"location": "Arcanum Sanctum"
	},
	"quest_acceptance": {
		"name": "The Journey Begins",
		"description": "The Elder Magus smiles. 'Excellent. The Veil is weakening, and only one with your potential can restore the ancient alliance. Your first trial awaits in the Chamber of Elements.'",
		"choices": [
			{
				"id": "begin_trial",
				"text": "Begin the trial",
				"next_scene": "elemental_trial",
				"requirements": {}
			},
			{
				"id": "prepare_first",
				"text": "I need to prepare first",
				"next_scene": "preparation_room",
				"requirements": {}
			}
		],
		"world": "Terra",
		"location": "Arcanum Sanctum"
	},
	"elemental_trial": {
		"name": "Trial of Elements",
		"description": "The chamber transforms around you. Four elemental orbs float in the corners - fire, water, earth, and air. You must demonstrate your mastery of the elements.",
		"choices": [
			{
				"id": "fire_mastery",
				"text": "Channel fire magic",
				"next_scene": "fire_trial",
				"requirements": {}
			},
			{
				"id": "water_mastery",
				"text": "Channel water magic",
				"next_scene": "water_trial",
				"requirements": {}
			},
			{
				"id": "earth_mastery",
				"text": "Channel earth magic",
				"next_scene": "earth_trial",
				"requirements": {}
			},
			{
				"id": "air_mastery",
				"text": "Channel air magic",
				"next_scene": "air_trial",
				"requirements": {}
			}
		],
		"world": "Terra",
		"location": "Arcanum Sanctum"
	}
}

# Game managers
var game_manager: GameManager
var quest_manager: QuestManager
var dialogue_manager: DialogueManager
var combat_manager: CombatManager

func _ready():
	# Get game managers
	game_manager = get_node("/root/GameManager")
	quest_manager = get_node("/root/QuestManager")
	dialogue_manager = get_node("/root/DialogueManager")
	combat_manager = get_node("/root/CombatManager")
	
	# Initialize game state
	_initialize_game_state()

func _initialize_game_state():
	"""Initialize the game state for a new game"""
	story_flags = {
		"has_met_elder": false,
		"accepted_quest": false,
		"completed_trials": false,
		"unlocked_worlds": ["Terra"]
	}
	
	player_choices = {}
	completed_scenes = []
	active_quests = []

func start_new_game():
	"""Start a new game"""
	_initialize_game_state()
	current_scene = "sanctum_entrance"
	_load_scene(current_scene)

func _load_scene(scene_id: String):
	"""Load a specific scene"""
	if scene_id in scene_data:
		current_scene = scene_id
		var scene = scene_data[scene_id]
		current_location = scene.get("location", "Unknown")
		current_world = scene.get("world", "Terra")
		
		# Emit scene change signal
		scene_changed.emit(scene_id, scene)
		
		# Update game managers
		if game_manager:
			game_manager.update_location(current_location, current_world)
		
		print("Loaded scene: ", scene_id)

func make_choice(choice_id: String):
	"""Handle player choice and progress the story"""
	var current_scene_data = scene_data.get(current_scene, {})
	var choices = current_scene_data.get("choices", [])
	
	for choice in choices:
		if choice.get("id") == choice_id:
			# Record the choice
			player_choices[choice_id] = choice
			
			# Emit choice signal
			choice_made.emit(choice_id, choice)
			
			# Progress to next scene
			var next_scene = choice.get("next_scene", "")
			if next_scene:
				_load_scene(next_scene)
			
			# Mark scene as completed
			if current_scene not in completed_scenes:
				completed_scenes.append(current_scene)
			
			break

func get_current_scene_data() -> Dictionary:
	"""Get the current scene data"""
	return scene_data.get(current_scene, {})

func get_available_choices() -> Array:
	"""Get available choices for the current scene"""
	var scene_data = get_current_scene_data()
	return scene_data.get("choices", [])

func advance_time():
	"""Advance game time"""
	game_time += 1
	if game_time > 24:
		game_time = 1
		game_day += 1

func get_game_time_string() -> String:
	"""Get formatted game time string"""
	var hour = game_time
	var period = "AM" if hour < 12 else "PM"
	if hour > 12:
		hour -= 12
	elif hour == 0:
		hour = 12
	return "Day %d, %d:00 %s" % [game_day, hour, period]

func save_game_state() -> Dictionary:
	"""Save the current game state"""
	return {
		"current_chapter": current_chapter,
		"current_scene": current_scene,
		"current_location": current_location,
		"current_world": current_world,
		"game_time": game_time,
		"game_day": game_day,
		"completed_scenes": completed_scenes,
		"active_quests": active_quests,
		"story_flags": story_flags,
		"player_choices": player_choices
	}

func load_game_state(state: Dictionary):
	"""Load a saved game state"""
	current_chapter = state.get("current_chapter", "prologue")
	current_scene = state.get("current_scene", "sanctum_entrance")
	current_location = state.get("current_location", "Arcanum Sanctum")
	current_world = state.get("current_world", "Terra")
	game_time = state.get("game_time", 1)
	game_day = state.get("game_day", 1)
	completed_scenes = state.get("completed_scenes", [])
	active_quests = state.get("active_quests", [])
	story_flags = state.get("story_flags", {})
	player_choices = state.get("player_choices", {})
	
	# Load the current scene
	_load_scene(current_scene) 