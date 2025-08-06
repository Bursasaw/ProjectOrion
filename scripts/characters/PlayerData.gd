extends Resource
class_name PlayerData

# Signals
signal level_up_signal(new_level: int)
signal skill_learned(skill_name: String)
signal inventory_updated()
signal stats_changed()

# Basic character info
var character_name: String = "Arius"
var character_class: String = "Seeker"
var level: int = 1
var experience: int = 0
var experience_to_next_level: int = 100

# Core stats
var strength: int = 10
var dexterity: int = 10
var constitution: int = 10
var intelligence: int = 10
var wisdom: int = 10
var charisma: int = 10

# Derived stats
var health_points: int = 100
var max_health_points: int = 100
var magic_points: int = 50
var max_magic_points: int = 50
var attack_power: int = 20
var magic_power: int = 20
var defense: int = 15
var magic_defense: int = 15
var speed: int = 12

# Skills and abilities
var learned_skills: Array[String] = []
var skill_points: int = 0
var skill_tree: Dictionary = {}

# Inventory and economy
var inventory: Dictionary = {}  # item_id -> quantity
var max_inventory_size: int = 50
var gold: int = 0

# Equipment
var equipped_weapon = null
var equipped_armor = null
var equipped_accessories = []

# Social and reputation
var reputation: Dictionary = {}
var relationships: Dictionary = {}

# Quest and exploration
var active_quests: Array[String] = []
var completed_quests: Array[String] = []

# World exploration
var visited_locations: Array[String] = []
var discovered_secrets: Array[String] = []

func _init():
	initialize_default_stats()

func initialize_default_stats():
	"""Initialize player with default starting stats"""
	character_name = "Arius"
	character_class = "Seeker"
	level = 1
	experience = 0
	experience_to_next_level = 100
	
	# Set base stats
	strength = 10
	dexterity = 10
	constitution = 10
	intelligence = 12  # Slightly higher for magic user
	wisdom = 12
	charisma = 10
	
	# Calculate derived stats
	calculate_derived_stats()
	
	# Initialize starting skills
	learned_skills = ["Basic Magic", "Light Healing"]
	skill_points = 5
	
	# Initialize starting inventory
	inventory = {}
	gold = 50
	
	# Initialize reputation
	reputation = {
		"Order of the Arcane": 0,
		"Order of the Void": 0,
		"Order of the Balance": 0
	}

func calculate_derived_stats():
	"""Calculate derived stats based on core stats"""
	max_health_points = 100 + (constitution * 10)
	max_magic_points = 50 + (intelligence * 5)
	health_points = max_health_points
	magic_points = max_magic_points
	attack_power = strength * 2
	magic_power = intelligence * 2
	defense = int(constitution * 1.5)
	magic_defense = int(wisdom * 1.5)
	speed = int(dexterity * 1.2)

func get_stats() -> Dictionary:
	"""Get all current player stats as a dictionary"""
	return {
		"name": character_name,
		"class": character_class,
		"level": level,
		"experience": experience,
		"experience_to_next_level": experience_to_next_level,
		"strength": strength,
		"dexterity": dexterity,
		"constitution": constitution,
		"intelligence": intelligence,
		"wisdom": wisdom,
		"charisma": charisma,
		"health_points": health_points,
		"max_health_points": max_health_points,
		"magic_points": magic_points,
		"max_magic_points": max_magic_points,
		"attack_power": attack_power,
		"magic_power": magic_power,
		"defense": defense,
		"magic_defense": magic_defense,
		"speed": speed
	}

func update_stats(new_stats: Dictionary):
	"""Update player stats from a dictionary"""
	if new_stats.has("strength"):
		strength = new_stats["strength"]
	if new_stats.has("dexterity"):
		dexterity = new_stats["dexterity"]
	if new_stats.has("constitution"):
		constitution = new_stats["constitution"]
	if new_stats.has("intelligence"):
		intelligence = new_stats["intelligence"]
	if new_stats.has("wisdom"):
		wisdom = new_stats["wisdom"]
	if new_stats.has("charisma"):
		charisma = new_stats["charisma"]
	
	# Recalculate derived stats
	calculate_derived_stats()
	
	# Emit signal
	stats_changed.emit()

func gain_experience(amount: int):
	"""Gain experience points and check for level up"""
	experience += amount
	
	# Check for level up
	while experience >= experience_to_next_level:
		level_up()

func level_up():
	"""Handle level up logic"""
	experience -= experience_to_next_level
	level += 1
	
	# Increase experience needed for next level
	experience_to_next_level = int(experience_to_next_level * 1.5)
	
	# Gain skill points
	skill_points += 3
	
	# Small stat increases
	strength += 1
	dexterity += 1
	constitution += 1
	intelligence += 1
	wisdom += 1
	charisma += 1
	
	# Recalculate derived stats
	calculate_derived_stats()
	
	# Emit signals
	level_up_signal.emit(level)
	stats_changed.emit()
	
	print("Level up! You are now level %d" % level)

func learn_skill(skill_name: String) -> bool:
	"""Learn a new skill if player has enough skill points"""
	if skill_points > 0 and not learned_skills.has(skill_name):
		learned_skills.append(skill_name)
		skill_points -= 1
		skill_learned.emit(skill_name)
		print("Learned skill: %s" % skill_name)
		return true
	return false

func has_skill(skill_name: String) -> bool:
	"""Check if player has learned a specific skill"""
	return learned_skills.has(skill_name)

func get_skill_points() -> int:
	"""Get current skill points"""
	return skill_points

func add_item(item) -> bool:
	"""Add an item to inventory"""
	if not item:
		return false
	
	var item_id = item.item_id
	if not item_id:
		return false
	
	if inventory.has(item_id):
		inventory[item_id] += 1
	else:
		inventory[item_id] = 1
	
	inventory_updated.emit()
	return true

func remove_item(item) -> bool:
	"""Remove an item from inventory"""
	if not item:
		return false
	
	var item_id = item.item_id
	if not item_id or not inventory.has(item_id):
		return false
	
	if inventory[item_id] > 1:
		inventory[item_id] -= 1
	else:
		inventory.erase(item_id)
	
	inventory_updated.emit()
	return true

func get_inventory():
	"""Get current inventory"""
	return inventory

func get_inventory_size() -> int:
	"""Get current inventory size"""
	return inventory.size()

func get_max_inventory_size() -> int:
	"""Get maximum inventory size"""
	return max_inventory_size

func get_experience_points() -> int:
	"""Get current experience points (alias for experience)"""
	return experience

func set_experience_points(value: int):
	"""Set experience points (alias for experience)"""
	experience = value

func add_gold(amount: int):
	"""Add gold to player"""
	gold += amount

func spend_gold(amount: int) -> bool:
	"""Spend gold if player has enough"""
	if gold >= amount:
		gold -= amount
		return true
	return false

func get_gold() -> int:
	"""Get current gold amount"""
	return gold

func update_reputation(faction: String, amount: int):
	"""Update reputation with a specific faction"""
	if not reputation.has(faction):
		reputation[faction] = 0
	reputation[faction] += amount

func get_reputation(faction: String) -> int:
	"""Get reputation with a specific faction"""
	if reputation.has(faction):
		return reputation[faction]
	return 0

func add_quest(quest_id: String):
	"""Add a quest to active quests"""
	if not active_quests.has(quest_id):
		active_quests.append(quest_id)

func complete_quest(quest_id: String):
	"""Complete a quest"""
	if active_quests.has(quest_id):
		active_quests.erase(quest_id)
		completed_quests.append(quest_id)

func get_active_quests() -> Array[String]:
	"""Get list of active quests"""
	return active_quests

func get_completed_quests() -> Array[String]:
	"""Get list of completed quests"""
	return completed_quests

func visit_location(location: String):
	"""Mark a location as visited"""
	if not visited_locations.has(location):
		visited_locations.append(location)

func discover_secret(secret_id: String):
	"""Mark a secret as discovered"""
	if not discovered_secrets.has(secret_id):
		discovered_secrets.append(secret_id)

func has_visited(location: String) -> bool:
	"""Check if player has visited a location"""
	return visited_locations.has(location)

func has_discovered_secret(secret_id: String) -> bool:
	"""Check if player has discovered a secret"""
	return discovered_secrets.has(secret_id) 
