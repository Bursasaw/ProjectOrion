extends Node
class_name QuestIntegration

# Quest Integration - Connects quest system with game flow
# Handles quest triggers, completion, and rewards

signal quest_started(quest_id: String, quest_data: Dictionary)
signal quest_completed(quest_id: String, rewards: Dictionary)
signal quest_failed(quest_id: String, reason: String)

# Quest triggers
var quest_triggers: Dictionary = {
	"sanctum_trials": {
		"trigger_scene": "sanctum_chamber",
		"trigger_choice": "approach_elder",
		"auto_start": true
	},
	"restore_alliance": {
		"trigger_scene": "quest_acceptance",
		"trigger_choice": "accept_quest",
		"auto_start": true
	},
	"shadow_crystals": {
		"trigger_scene": "nokturn_market",
		"trigger_choice": "talk_merchant",
		"auto_start": false
	}
}

# Quest objectives tracking
var active_quests: Dictionary = {}
var completed_quests: Array[String] = []

# Game managers
var quest_manager: QuestManager
var game_flow_manager: GameFlowManager
var game_manager: GameManager

func _ready():
	# Get game managers
	quest_manager = get_node("/root/QuestManager")
	game_flow_manager = get_node("/root/GameFlowManager")
	game_manager = get_node("/root/GameManager")
	
	# Connect to game flow signals
	if game_flow_manager:
		game_flow_manager.choice_made.connect(_on_choice_made)
		game_flow_manager.scene_changed.connect(_on_scene_changed)

func _on_choice_made(choice_id: String, result: Dictionary):
	"""Handle choice made and check for quest triggers"""
	_check_quest_triggers(choice_id)

func _on_scene_changed(scene_id: String, scene_data: Dictionary):
	"""Handle scene changes and check for quest triggers"""
	_check_quest_triggers("scene_change", scene_id)

func _check_quest_triggers(choice_id: String, scene_id: String = ""):
	"""Check if any quests should be triggered"""
	for quest_id in quest_triggers.keys():
		var trigger = quest_triggers[quest_id]
		
		# Check if this quest is already active or completed
		if quest_id in active_quests or quest_id in completed_quests:
			continue
		
		# Check if trigger conditions are met
		var should_trigger = false
		
		if scene_id != "":
			# Scene-based trigger
			if trigger.get("trigger_scene") == scene_id:
				should_trigger = true
		else:
			# Choice-based trigger
			if trigger.get("trigger_choice") == choice_id:
				should_trigger = true
		
		if should_trigger:
			_start_quest(quest_id)

func _start_quest(quest_id: String):
	"""Start a quest"""
	if quest_manager:
		var quest_data = quest_manager.get_quest_data(quest_id)
		if quest_data:
			active_quests[quest_id] = {
				"data": quest_data,
				"objectives": quest_data.get("objectives", []).duplicate(),
				"progress": {}
			}
			
			# Initialize progress tracking
			for objective in active_quests[quest_id]["objectives"]:
				active_quests[quest_id]["progress"][objective.get("id", "")] = 0
			
			quest_started.emit(quest_id, quest_data)
			print("Started quest: ", quest_id)

func update_quest_progress(quest_id: String, objective_id: String, progress: int = 1):
	"""Update quest objective progress"""
	if quest_id in active_quests:
		var quest = active_quests[quest_id]
		if objective_id in quest["progress"]:
			quest["progress"][objective_id] += progress
			
			# Check if objective is complete
			var objective = _find_objective(quest_id, objective_id)
			if objective and quest["progress"][objective_id] >= objective.get("target", 1):
				_complete_objective(quest_id, objective_id)
			
			print("Updated quest progress: ", quest_id, " - ", objective_id, " = ", quest["progress"][objective_id])

func _find_objective(quest_id: String, objective_id: String) -> Dictionary:
	"""Find an objective in a quest"""
	if quest_id in active_quests:
		var objectives = active_quests[quest_id]["objectives"]
		for objective in objectives:
			if objective.get("id") == objective_id:
				return objective
	return {}

func _complete_objective(quest_id: String, objective_id: String):
	"""Complete a quest objective"""
	var quest = active_quests[quest_id]
	var objective = _find_objective(quest_id, objective_id)
	
	if objective:
		objective["current"] = objective.get("target", 1)
		print("Completed objective: ", quest_id, " - ", objective_id)
		
		# Check if all objectives are complete
		if _are_all_objectives_complete(quest_id):
			_complete_quest(quest_id)

func _are_all_objectives_complete(quest_id: String) -> bool:
	"""Check if all objectives in a quest are complete"""
	if quest_id in active_quests:
		var quest = active_quests[quest_id]
		var objectives = quest["objectives"]
		
		for objective in objectives:
			var objective_id = objective.get("id", "")
			var current = quest["progress"].get(objective_id, 0)
			var target = objective.get("target", 1)
			
			if current < target:
				return false
		
		return true
	return false

func _complete_quest(quest_id: String):
	"""Complete a quest and give rewards"""
	if quest_id in active_quests:
		var quest = active_quests[quest_id]
		var quest_data = quest["data"]
		var rewards = quest_data.get("rewards", {})
		
		# Give rewards
		if game_manager and game_manager.player_data:
			var player_data = game_manager.player_data
			
			# Experience
			if rewards.has("experience"):
				player_data.add_experience(rewards.get("experience", 0))
			
			# Gold
			if rewards.has("gold") and game_manager.inventory_manager:
				game_manager.inventory_manager.add_gold(rewards.get("gold", 0))
			
			# Items
			if rewards.has("items"):
				for item_id in rewards.get("items", []):
					if game_manager.inventory_manager:
						game_manager.inventory_manager.add_item(item_id)
			
			# Reputation
			if rewards.has("reputation"):
				for faction in rewards.get("reputation", {}):
					# TODO: Implement reputation system
					pass
		
		# Move quest to completed
		completed_quests.append(quest_id)
		active_quests.erase(quest_id)
		
		quest_completed.emit(quest_id, rewards)
		print("Completed quest: ", quest_id)

func get_active_quests() -> Array:
	"""Get list of active quest IDs"""
	return active_quests.keys()

func get_quest_progress(quest_id: String) -> Dictionary:
	"""Get progress for a specific quest"""
	if quest_id in active_quests:
		return active_quests[quest_id]["progress"]
	return {}

func is_quest_active(quest_id: String) -> bool:
	"""Check if a quest is currently active"""
	return quest_id in active_quests

func is_quest_completed(quest_id: String) -> bool:
	"""Check if a quest has been completed"""
	return quest_id in completed_quests 