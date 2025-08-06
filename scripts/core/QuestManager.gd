extends Node
# class_name QuestManager # Removed to avoid autoload conflict

# Quest Manager - Handles quest system, objectives, and progression
# Manages quest tracking, completion, rewards, and story progression

signal quest_started(quest_id: String)
signal quest_completed(quest_id: String)
signal quest_failed(quest_id: String)
signal objective_updated(quest_id: String, objective_id: String, progress: int, total: int)

# Quest data
var active_quests: Dictionary = {}
var completed_quests: Array[String] = []
var failed_quests: Array[String] = []
var quest_data: Dictionary = {}

# Quest types
enum QuestType {
	MAIN_STORY,
	SIDE_QUEST,
	COLLECTION,
	EXPLORATION,
	COMBAT,
	DIALOGUE,
	DELIVERY
}

# Quest states
enum QuestState {
	NOT_STARTED,
	ACTIVE,
	COMPLETED,
	FAILED
}

func _ready():
	"""Initialize quest manager"""
	load_quest_data()

func load_quest_data():
	"""Load quest data from JSON files"""
	var file = FileAccess.open("res://data/quests/quests.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		if parse_result == OK:
			quest_data = json.data
			print("Quest data loaded successfully")
		else:
			print("Failed to parse quest data")
		file.close()
	else:
		print("Failed to load quest data file")
		create_sample_quests()

func create_sample_quests():
	"""Create minimal fallback quests if JSON loading fails"""
	print("Using fallback quest data")
	quest_data = {
		"sanctum_trials": {
			"name": "Sanctum Trials",
			"description": "Complete the trials of the Arcanum Sanctum to prove your worth.",
			"type": "main_story",
			"objectives": [
				{
					"id": "trial_1",
					"description": "Complete the Chamber of Elements trial",
					"type": "exploration",
					"target": 1,
					"current": 0
				}
			],
			"rewards": {
				"experience": 500,
				"gold": 200,
				"items": ["alliance_talisman"]
			},
			"prerequisites": [],
			"location": "Arcanum Sanctum",
			"quest_giver": "elder_magus"
		},
		"shadow_crystals": {
			"name": "Shadow Crystal Collection",
			"description": "Collect shadow crystals for the Shadow Merchant.",
			"type": "side_quest",
			"objectives": [
				{
					"id": "collect_crystals",
					"description": "Collect 5 shadow crystals",
					"type": "collection",
					"target": 5,
					"current": 0
				}
			],
			"rewards": {
				"experience": 300,
				"gold": 150,
				"items": ["shadow_crystal"],
				"reputation": {"Nokturn": 25}
			},
			"prerequisites": [],
			"location": "Nokturn",
			"quest_giver": "shadow_merchant"
		},
		"void_investigation": {
			"name": "Void Investigation",
			"description": "Investigate the void rifts and learn about the Void Seekers.",
			"type": "side_quest",
			"objectives": [
				{
					"id": "visit_rifts",
					"description": "Visit 3 void rifts",
					"type": "exploration",
					"target": 3,
					"current": 0
				},
				{
					"id": "collect_void_essence",
					"description": "Collect void essence samples",
					"type": "collection",
					"target": 2,
					"current": 0
				}
			],
			"rewards": {
				"experience": 400,
				"gold": 200,
				"items": ["void_essence"],
				"reputation": {"Nokturn": 30}
			},
			"prerequisites": [],
			"location": "Nokturn",
			"quest_giver": "shadow_merchant"
		}
	}

func start_quest(quest_id: String) -> bool:
	"""Start a quest"""
	if not quest_data.has(quest_id):
		print("Quest not found: ", quest_id)
		return false
	
	if active_quests.has(quest_id):
		print("Quest already active: ", quest_id)
		return false
	
	# Check prerequisites
	if not check_prerequisites(quest_id):
		print("Prerequisites not met for quest: ", quest_id)
		return false
	
	# Add to active quests
	active_quests[quest_id] = {
		"state": QuestState.ACTIVE,
		"objectives": quest_data[quest_id]["objectives"].duplicate(true),
		"start_time": Time.get_unix_time_from_system()
	}
	
	# Emit signal
	quest_started.emit(quest_id)
	
	print("Started quest: ", quest_id)
	return true

func update_objective(quest_id: String, objective_id: String, progress: int = 1):
	"""Update quest objective progress"""
	if not active_quests.has(quest_id):
		return
	
	var quest = active_quests[quest_id]
	for objective in quest["objectives"]:
		if objective["id"] == objective_id:
			objective["current"] += progress
			if objective["current"] > objective["target"]:
				objective["current"] = objective["target"]
			
			# Emit signal
			objective_updated.emit(quest_id, objective_id, objective["current"], objective["target"])
			
			# Check if quest is complete
			if check_quest_completion(quest_id):
				complete_quest(quest_id)
			
			break

func check_quest_completion(quest_id: String) -> bool:
	"""Check if a quest is complete"""
	if not active_quests.has(quest_id):
		return false
	
	var quest = active_quests[quest_id]
	for objective in quest["objectives"]:
		if objective["current"] < objective["target"]:
			return false
	
	return true

func complete_quest(quest_id: String):
	"""Complete a quest and give rewards"""
	if not active_quests.has(quest_id):
		return
	
	# Move to completed quests
	active_quests[quest_id]["state"] = QuestState.COMPLETED
	completed_quests.append(quest_id)
	
	# Give rewards
	give_quest_rewards(quest_id)
	
	# Remove from active quests
	active_quests.erase(quest_id)
	
	# Emit signal
	quest_completed.emit(quest_id)
	
	# Trigger Steam achievements
	trigger_quest_achievements(quest_id)
	
	print("Completed quest: ", quest_id)

func fail_quest(quest_id: String):
	"""Fail a quest"""
	if not active_quests.has(quest_id):
		return
	
	# Move to failed quests
	active_quests[quest_id]["state"] = QuestState.FAILED
	failed_quests.append(quest_id)
	
	# Remove from active quests
	active_quests.erase(quest_id)
	
	# Emit signal
	quest_failed.emit(quest_id)
	
	print("Failed quest: ", quest_id)

func give_quest_rewards(quest_id: String):
	"""Give rewards for completing a quest"""
	if not quest_data.has(quest_id):
		return
	
	var rewards = quest_data[quest_id]["rewards"]
	var game_manager = get_node("/root/GameManager")
	
	if game_manager and game_manager.player_data:
		var player_data = game_manager.player_data
		
		# Give experience
		if rewards.has("experience"):
			player_data.gain_experience(rewards["experience"])
		
		# Give gold
		if rewards.has("gold"):
			player_data.gold += rewards["gold"]
		
		# Give items
		if rewards.has("items"):
			var inventory_manager = get_node("/root/GameManager").inventory_manager
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

func check_prerequisites(quest_id: String) -> bool:
	"""Check if quest prerequisites are met"""
	if not quest_data.has(quest_id):
		return false
	
	var prerequisites = quest_data[quest_id].get("prerequisites", [])
	for prereq in prerequisites:
		if not completed_quests.has(prereq):
			return false
	
	return true

func get_quest_info(quest_id: String) -> Dictionary:
	"""Get information about a quest"""
	if not quest_data.has(quest_id):
		return {}
	
	return quest_data[quest_id]

func get_active_quests() -> Dictionary:
	"""Get all active quests"""
	return active_quests

func get_completed_quests() -> Array[String]:
	"""Get all completed quests"""
	return completed_quests

func get_failed_quests() -> Array[String]:
	"""Get all failed quests"""
	return failed_quests

func is_quest_active(quest_id: String) -> bool:
	"""Check if a quest is active"""
	return active_quests.has(quest_id)

func is_quest_completed(quest_id: String) -> bool:
	"""Check if a quest is completed"""
	return completed_quests.has(quest_id)

func is_quest_failed(quest_id: String) -> bool:
	"""Check if a quest is failed"""
	return failed_quests.has(quest_id)

func get_available_quests() -> Array[String]:
	"""Get all quests that can be started"""
	var available: Array[String] = []
	
	for quest_id in quest_data:
		if not active_quests.has(quest_id) and not completed_quests.has(quest_id) and not failed_quests.has(quest_id):
			if check_prerequisites(quest_id):
				available.append(quest_id)
	
	return available 

func trigger_quest_achievements(quest_id: String):
	"""Trigger Steam achievements for quest completion"""
	var steam_manager = get_node("/root/SteamManager")
	if not steam_manager:
		return
	
	# First quest achievement
	if completed_quests.size() == 1:
		steam_manager.unlock_achievement("first_quest")
		print("SteamManager: First quest achievement triggered")
	
	# Story completion achievement
	if quest_id == "sanctum_trials" and quest_id in completed_quests:
		steam_manager.unlock_achievement("story_complete")
		print("SteamManager: Story completion achievement triggered")
	
	# Check for other quest-related achievements
	check_quest_progress_achievements()

func check_quest_progress_achievements():
	"""Check and trigger quest progress achievements"""
	var steam_manager = get_node("/root/SteamManager")
	if not steam_manager:
		return
	
	# Explorer achievement - check if player has visited multiple locations
	var world_manager = get_node("/root/GameManager").world_manager
	if world_manager:
		var visited_locations = world_manager.get_visited_locations()
		if visited_locations.size() >= 5:
			steam_manager.unlock_achievement("explorer")
			print("SteamManager: Explorer achievement triggered")
	
	# Collector achievement - check if player has collected many items
	var inventory_manager = get_node("/root/GameManager").inventory_manager
	if inventory_manager:
		var all_items = inventory_manager.get_all_items()
		var unique_items = 0
		for item_id in all_items:
			if all_items[item_id] > 0:
				unique_items += 1
		
		if unique_items >= 20:
			steam_manager.unlock_achievement("collector")
			print("SteamManager: Collector achievement triggered")
	
	# Level achievement - check if player reached level 10
	var game_manager = get_node("/root/GameManager")
	if game_manager and game_manager.player_data:
		var player_level = game_manager.player_data.level
		if player_level >= 10:
			steam_manager.unlock_achievement("level_10")
			print("SteamManager: Level 10 achievement triggered") 
