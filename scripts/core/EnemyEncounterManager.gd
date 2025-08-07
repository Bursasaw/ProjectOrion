extends Node
class_name EnemyEncounterManager

# Enemy Encounter Manager - Handles text-based enemy encounters
# Manages enemy spawning, combat initiation, and encounter resolution

signal encounter_started(enemy_data: Dictionary)
signal encounter_ended(result: String, rewards: Dictionary)
signal enemy_defeated(enemy_id: String, loot: Array)

# Current encounter state
var current_encounter: Dictionary = {}
var current_enemy: Dictionary = {}
var encounter_active: bool = false
var encounter_type: String = ""

# Encounter data
var encounter_data: Dictionary = {
	"terra_forest": {
		"name": "Forest Encounter",
		"description": "As you traverse the ancient forest, you sense a presence watching you from the shadows.",
		"enemies": ["terra_enemy_1", "terra_enemy_2"],
		"encounter_chance": 0.3,
		"world": "Terra",
		"location": "Ancient Forest"
	},
	"terra_crystal_caves": {
		"name": "Crystal Cave Encounter",
		"description": "The crystal formations pulse with energy, and you hear the sound of something moving in the depths.",
		"enemies": ["terra_enemy_2", "terra_enemy_3"],
		"encounter_chance": 0.4,
		"world": "Terra",
		"location": "Crystal Caves"
	},
	"sanctum_trial": {
		"name": "Trial of Elements",
		"description": "The chamber transforms as elemental forces manifest to test your abilities.",
		"enemies": ["trial_elemental_1", "trial_elemental_2"],
		"encounter_chance": 1.0,
		"world": "Terra",
		"location": "Arcanum Sanctum"
	}
}

# Game managers
var game_manager: GameManager
var combat_manager: CombatManager
var quest_manager: QuestManager

func _ready():
	# Get game managers
	game_manager = get_node("/root/GameManager")
	combat_manager = get_node("/root/CombatManager")
	quest_manager = get_node("/root/QuestManager")

func start_encounter(encounter_id: String, forced: bool = false):
	"""Start an enemy encounter"""
	if encounter_active:
		return
	
	var encounter = encounter_data.get(encounter_id, {})
	if encounter.is_empty():
		print("Encounter not found: ", encounter_id)
		return
	
	# Check encounter chance unless forced
	if not forced and randf() > encounter.get("encounter_chance", 0.5):
		return
	
	current_encounter = encounter
	encounter_active = true
	encounter_type = encounter_id
	
	# Select random enemy from encounter
	var enemies = encounter.get("enemies", [])
	if enemies.size() > 0:
		var enemy_id = enemies[randi() % enemies.size()]
		_load_enemy(enemy_id)
	
	# Emit encounter started signal
	encounter_started.emit(current_enemy)
	
	print("Started encounter: ", encounter_id)

func _load_enemy(enemy_id: String):
	"""Load enemy data from the enemy database"""
	# Load enemy data from JSON
	var enemy_file = FileAccess.open("res://data/enemies/enemies.json", FileAccess.READ)
	if enemy_file:
		var json = JSON.new()
		var parse_result = json.parse(enemy_file.get_as_text())
		if parse_result == OK:
			var enemies = json.data
			for enemy in enemies:
				if enemy.get("id") == enemy_id:
					current_enemy = enemy
					break
		enemy_file.close()

func end_encounter(result: String, rewards: Dictionary = {}):
	"""End the current encounter"""
	if not encounter_active:
		return
	
	encounter_active = false
	
	# Emit encounter ended signal
	encounter_ended.emit(result, rewards)
	
	# Clear current encounter
	current_encounter = {}
	current_enemy = {}
	
	print("Ended encounter with result: ", result)

func get_encounter_description() -> String:
	"""Get the current encounter description"""
	if current_encounter.is_empty():
		return ""
	
	return current_encounter.get("description", "")

func get_enemy_description() -> String:
	"""Get the current enemy description"""
	if current_enemy.is_empty():
		return ""
	
	var name = current_enemy.get("name", "Unknown Enemy")
	var level = current_enemy.get("level", 1)
	var health = current_enemy.get("health", 50)
	var theme = current_enemy.get("theme", "unknown")
	
	return "You face a %s (Level %d) with %d health. It emanates %s energy." % [name, level, health, theme]

func get_combat_choices() -> Array:
	"""Get available combat choices"""
	return [
		{
			"id": "attack",
			"text": "Attack",
			"description": "Use your weapon or basic magic to attack"
		},
		{
			"id": "spell",
			"text": "Cast Spell",
			"description": "Use a powerful spell"
		},
		{
			"id": "item",
			"text": "Use Item",
			"description": "Use a potion or other item"
		},
		{
			"id": "flee",
			"text": "Flee",
			"description": "Attempt to escape the encounter"
		}
	]

func process_combat_action(action: String) -> Dictionary:
	"""Process a combat action and return the result"""
	if current_enemy.is_empty():
		return {"success": false, "message": "No enemy to fight"}
	
	var result = {
		"success": true,
		"message": "",
		"damage_dealt": 0,
		"damage_taken": 0,
		"enemy_defeated": false
	}
	
	match action:
		"attack":
			result = _process_attack()
		"spell":
			result = _process_spell()
		"item":
			result = _process_item()
		"flee":
			result = _process_flee()
	
	return result

func _process_attack() -> Dictionary:
	"""Process an attack action"""
	var player_damage = 20  # Base damage, should come from player stats
	var enemy_health = current_enemy.get("health", 50)
	var enemy_defense = current_enemy.get("defense", 10)
	
	# Calculate damage
	var actual_damage = max(1, player_damage - enemy_defense)
	enemy_health -= actual_damage
	
	# Check if enemy is defeated
	var enemy_defeated = enemy_health <= 0
	
	# Enemy counter-attack
	var enemy_damage = current_enemy.get("damage", 15)
	var player_defense = 10  # Should come from player stats
	var damage_taken = max(1, enemy_damage - player_defense)
	
	var result = {
		"success": true,
		"message": "You deal %d damage to the %s!" % [actual_damage, current_enemy.get("name", "enemy")],
		"damage_dealt": actual_damage,
		"damage_taken": damage_taken,
		"enemy_defeated": enemy_defeated
	}
	
	if enemy_defeated:
		result.message += " The enemy is defeated!"
		_process_enemy_defeat()
	
	return result

func _process_spell() -> Dictionary:
	"""Process a spell action"""
	var spell_damage = 35  # Spell damage, should come from player stats
	var enemy_health = current_enemy.get("health", 50)
	var enemy_defense = current_enemy.get("defense", 10)
	
	# Spells ignore some defense
	var actual_damage = max(1, spell_damage - (enemy_defense * 0.5))
	enemy_health -= actual_damage
	
	# Check if enemy is defeated
	var enemy_defeated = enemy_health <= 0
	
	# Enemy counter-attack
	var enemy_damage = current_enemy.get("damage", 15)
	var player_defense = 10
	var damage_taken = max(1, enemy_damage - player_defense)
	
	var result = {
		"success": true,
		"message": "Your spell deals %d damage to the %s!" % [actual_damage, current_enemy.get("name", "enemy")],
		"damage_dealt": actual_damage,
		"damage_taken": damage_taken,
		"enemy_defeated": enemy_defeated
	}
	
	if enemy_defeated:
		result.message += " The enemy is defeated!"
		_process_enemy_defeat()
	
	return result

func _process_item() -> Dictionary:
	"""Process an item action"""
	# For now, just heal the player
	var heal_amount = 25
	var result = {
		"success": true,
		"message": "You use a healing potion and restore %d health!" % heal_amount,
		"damage_dealt": 0,
		"damage_taken": -heal_amount,  # Negative for healing
		"enemy_defeated": false
	}
	
	# Enemy still gets a turn
	var enemy_damage = current_enemy.get("damage", 15)
	var player_defense = 10
	var damage_taken = max(1, enemy_damage - player_defense)
	result.damage_taken = damage_taken
	
	return result

func _process_flee() -> Dictionary:
	"""Process a flee action"""
	var flee_chance = 0.6  # 60% chance to flee
	
	if randf() < flee_chance:
		end_encounter("fled", {})
		return {
			"success": true,
			"message": "You successfully flee from the encounter!",
			"damage_dealt": 0,
			"damage_taken": 0,
			"enemy_defeated": false
		}
	else:
		# Failed to flee, take damage
		var enemy_damage = current_enemy.get("damage", 15)
		var player_defense = 10
		var damage_taken = max(1, enemy_damage - player_defense)
		
		return {
			"success": false,
			"message": "You failed to flee and take %d damage!" % damage_taken,
			"damage_dealt": 0,
			"damage_taken": damage_taken,
			"enemy_defeated": false
		}

func _process_enemy_defeat():
	"""Process enemy defeat and rewards"""
	var enemy_id = current_enemy.get("id", "")
	var loot_table = current_enemy.get("loot_table", {})
	
	# Generate loot
	var loot = []
	var common_items = loot_table.get("common_items", [])
	var rare_items = loot_table.get("rare_items", [])
	var drop_rates = loot_table.get("drop_rates", {"common": 0.8, "rare": 0.2})
	
	# Add common items
	if common_items.size() > 0 and randf() < drop_rates.get("common", 0.8):
		var random_item = common_items[randi() % common_items.size()]
		loot.append(random_item)
	
	# Add rare items
	if rare_items.size() > 0 and randf() < drop_rates.get("rare", 0.2):
		var random_item = rare_items[randi() % rare_items.size()]
		loot.append(random_item)
	
	# Emit defeat signal
	enemy_defeated.emit(enemy_id, loot)
	
	# End encounter with victory
	var rewards = {
		"experience": current_enemy.get("level", 1) * 50,
		"gold": current_enemy.get("level", 1) * 10,
		"items": loot
	}
	
	end_encounter("victory", rewards)

func get_random_encounter(location: String) -> String:
	"""Get a random encounter for a location"""
	var available_encounters = []
	
	for encounter_id in encounter_data.keys():
		var encounter = encounter_data[encounter_id]
		if encounter.get("location", "") == location:
			available_encounters.append(encounter_id)
	
	if available_encounters.size() > 0:
		return available_encounters[randi() % available_encounters.size()]
	
	return ""

func is_encounter_active() -> bool:
	"""Check if an encounter is currently active"""
	return encounter_active 