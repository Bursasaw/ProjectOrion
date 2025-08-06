extends Node
class_name GearManager

# Gear Manager - Handles gear progression system inspired by SWGOH
# Manages gear tiers, gear materials, gear requirements, and gear bonuses

signal gear_equipped(actor: String, gear_tier: int, gear_slot: String)
signal gear_upgraded(actor: String, old_tier: int, new_tier: int)
signal gear_material_used(material_type: String, amount: int, remaining: int)

# Gear progression system inspired by SWGOH
var gear_tiers = {
	1: {
		"name": "Basic Gear",
		"description": "Basic equipment for beginners",
		"narrative": "Simple but reliable gear that provides basic protection and enhancement.",
		"stats": {"health": 50, "attack": 10, "defense": 5},
		"materials_required": {"basic_material": 5}
	},
	2: {
		"name": "Improved Gear",
		"description": "Enhanced equipment with better stats",
		"narrative": "Improved gear that offers better protection and more significant stat boosts.",
		"stats": {"health": 100, "attack": 20, "defense": 10, "speed": 5},
		"materials_required": {"basic_material": 10, "improved_material": 3}
	},
	3: {
		"name": "Advanced Gear",
		"description": "Advanced equipment with specialized bonuses",
		"narrative": "Advanced gear that provides specialized bonuses and significant stat improvements.",
		"stats": {"health": 200, "attack": 40, "defense": 20, "speed": 10, "critical_chance": 5},
		"materials_required": {"improved_material": 8, "advanced_material": 2}
	},
	4: {
		"name": "Expert Gear",
		"description": "Expert-level equipment with powerful effects",
		"narrative": "Expert gear that provides powerful effects and substantial stat improvements.",
		"stats": {"health": 400, "attack": 80, "defense": 40, "speed": 15, "critical_chance": 10, "critical_damage": 20},
		"materials_required": {"advanced_material": 6, "expert_material": 3}
	},
	5: {
		"name": "Master Gear",
		"description": "Master-level equipment with exceptional bonuses",
		"narrative": "Master gear that provides exceptional bonuses and massive stat improvements.",
		"stats": {"health": 800, "attack": 160, "defense": 80, "speed": 25, "critical_chance": 15, "critical_damage": 40},
		"materials_required": {"expert_material": 8, "master_material": 4}
	},
	6: {
		"name": "Legendary Gear",
		"description": "Legendary equipment with game-changing effects",
		"narrative": "Legendary gear that provides game-changing effects and unparalleled stat improvements.",
		"stats": {"health": 1600, "attack": 320, "defense": 160, "speed": 40, "critical_chance": 25, "critical_damage": 60},
		"materials_required": {"master_material": 12, "legendary_material": 6}
	}
}

# Gear slots
var gear_slots = {
	"weapon": {"name": "Weapon", "description": "Primary weapon slot", "primary_stat": "attack"},
	"armor": {"name": "Armor", "description": "Body armor slot", "primary_stat": "defense"},
	"helmet": {"name": "Helmet", "description": "Head protection slot", "primary_stat": "defense"},
	"gloves": {"name": "Gloves", "description": "Hand protection slot", "primary_stat": "attack"},
	"boots": {"name": "Boots", "description": "Foot protection slot", "primary_stat": "speed"},
	"accessory": {"name": "Accessory", "description": "Special accessory slot", "primary_stat": "critical_chance"}
}

# Actor gear configurations
var actor_gear: Dictionary = {}
var gear_materials: Dictionary = {}
var gear_history: Array = []

# Material types and their descriptions
var material_types = {
	"basic_material": {"name": "Basic Material", "description": "Common crafting material", "rarity": "common"},
	"improved_material": {"name": "Improved Material", "description": "Enhanced crafting material", "rarity": "uncommon"},
	"advanced_material": {"name": "Advanced Material", "description": "Advanced crafting material", "rarity": "rare"},
	"expert_material": {"name": "Expert Material", "description": "Expert-level crafting material", "rarity": "epic"},
	"master_material": {"name": "Master Material", "description": "Master-level crafting material", "rarity": "legendary"},
	"legendary_material": {"name": "Legendary Material", "description": "Legendary crafting material", "rarity": "mythic"}
}

func _ready():
	"""Initialize gear manager"""
	initialize_gear_materials()
	print("GearManager: Initialized with default materials")

func reset_materials_for_testing():
	"""Reset materials to default amounts for testing"""
	initialize_gear_materials()
	print("GearManager: Materials reset for testing")

func initialize_gear_materials():
	"""Initialize gear materials with default amounts"""
	for material_type in material_types.keys():
		gear_materials[material_type] = 100  # Start with 100 of each material

func equip_gear(actor_name: String, gear_slot: String, gear_tier: int) -> bool:
	"""Equip gear to an actor"""
	if not gear_slots.has(gear_slot):
		print("GearManager: Invalid gear slot: %s" % gear_slot)
		return false
	
	if not gear_tiers.has(gear_tier):
		print("GearManager: Invalid gear tier: %d" % gear_tier)
		return false
	
	# Check if we have enough materials
	var tier_data = gear_tiers[gear_tier]
	var materials_required = tier_data.get("materials_required", {})
	
	for material_type in materials_required.keys():
		var required_amount = materials_required[material_type]
		var available_amount = gear_materials.get(material_type, 0)
		
		if available_amount < required_amount:
			print("GearManager: Insufficient %s - need %d, have %d" % [material_type, required_amount, available_amount])
			return false
	
	# Consume materials
	for material_type in materials_required.keys():
		var required_amount = materials_required[material_type]
		gear_materials[material_type] -= required_amount
		
		# Emit signal
		gear_material_used.emit(material_type, required_amount, gear_materials[material_type])
	
	# Equip the gear
	if not actor_gear.has(actor_name):
		actor_gear[actor_name] = {}
	
	actor_gear[actor_name][gear_slot] = gear_tier
	
	# Add to history
	gear_history.append({
		"turn": get_current_turn(),
		"actor": actor_name,
		"action": "equip_gear",
		"gear_slot": gear_slot,
		"gear_tier": gear_tier,
		"materials_used": materials_required
	})
	
	# Emit signal
	gear_equipped.emit(actor_name, gear_tier, gear_slot)
	
	print("GearManager: Equipped tier %d gear to %s in %s slot" % [gear_tier, actor_name, gear_slot])
	
	return true

func upgrade_gear(actor_name: String, gear_slot: String) -> bool:
	"""Upgrade gear in a specific slot"""
	if not actor_gear.has(actor_name) or not actor_gear[actor_name].has(gear_slot):
		print("GearManager: No gear found in slot %s for actor %s" % [gear_slot, actor_name])
		return false
	
	var current_tier = actor_gear[actor_name][gear_slot]
	var new_tier = current_tier + 1
	
	if not gear_tiers.has(new_tier):
		print("GearManager: Cannot upgrade beyond tier %d" % current_tier)
		return false
	
	# Check if we have enough materials for upgrade
	var tier_data = gear_tiers[new_tier]
	var materials_required = tier_data.get("materials_required", {})
	
	for material_type in materials_required.keys():
		var required_amount = materials_required[material_type]
		var available_amount = gear_materials.get(material_type, 0)
		
		if available_amount < required_amount:
			print("GearManager: Insufficient %s for upgrade - need %d, have %d" % [material_type, required_amount, available_amount])
			return false
	
	# Consume materials
	for material_type in materials_required.keys():
		var required_amount = materials_required[material_type]
		gear_materials[material_type] -= required_amount
		
		# Emit signal
		gear_material_used.emit(material_type, required_amount, gear_materials[material_type])
	
	# Upgrade the gear
	actor_gear[actor_name][gear_slot] = new_tier
	
	# Add to history
	gear_history.append({
		"turn": get_current_turn(),
		"actor": actor_name,
		"action": "upgrade_gear",
		"gear_slot": gear_slot,
		"old_tier": current_tier,
		"new_tier": new_tier,
		"materials_used": materials_required
	})
	
	# Emit signal
	gear_upgraded.emit(actor_name, current_tier, new_tier)
	
	print("GearManager: Upgraded %s gear in %s slot (Tier %d -> %d)" % [actor_name, gear_slot, current_tier, new_tier])
	
	return true

func get_actor_gear(actor_name: String) -> Dictionary:
	"""Get all gear equipped to an actor"""
	return actor_gear.get(actor_name, {})

func get_gear_stats(actor_name: String) -> Dictionary:
	"""Get total gear stats for an actor"""
	var total_stats = {}
	
	if not actor_gear.has(actor_name):
		return total_stats
	
	for gear_slot in actor_gear[actor_name].keys():
		var gear_tier = actor_gear[actor_name][gear_slot]
		var tier_data = gear_tiers.get(gear_tier, {})
		var stats = tier_data.get("stats", {})
		
		for stat_name in stats.keys():
			var stat_value = stats[stat_name]
			total_stats[stat_name] = total_stats.get(stat_name, 0) + stat_value
	
	return total_stats

func get_gear_tier_info(gear_tier: int) -> Dictionary:
	"""Get information about a specific gear tier"""
	return gear_tiers.get(gear_tier, {})

func get_gear_slot_info(gear_slot: String) -> Dictionary:
	"""Get information about a specific gear slot"""
	return gear_slots.get(gear_slot, {})

func get_available_gear_tiers() -> Array:
	"""Get all available gear tiers"""
	var available = []
	
	for tier in gear_tiers.keys():
		var tier_data = gear_tiers[tier]
		available.append({
			"tier": tier,
			"name": tier_data["name"],
			"description": tier_data["description"],
			"narrative": tier_data["narrative"],
			"stats": tier_data["stats"],
			"materials_required": tier_data["materials_required"]
		})
	
	return available

func add_materials(material_type: String, amount: int):
	"""Add materials to inventory"""
	if not material_types.has(material_type):
		print("GearManager: Unknown material type: %s" % material_type)
		return
	
	gear_materials[material_type] = gear_materials.get(material_type, 0) + amount
	print("GearManager: Added %d %s (Total: %d)" % [amount, material_type, gear_materials[material_type]])

func get_material_count(material_type: String) -> int:
	"""Get current count of a material"""
	return gear_materials.get(material_type, 0)

func get_all_materials() -> Dictionary:
	"""Get all material counts"""
	return gear_materials.duplicate()

func get_gear_statistics(actor_name: String) -> Dictionary:
	"""Get gear statistics for an actor"""
	if not actor_gear.has(actor_name):
		return {}
	
	var equipped_gear = actor_gear[actor_name]
	var total_tiers = 0
	var gear_slots_filled = equipped_gear.size()
	
	for gear_slot in equipped_gear.keys():
		total_tiers += equipped_gear[gear_slot]
	
	return {
		"total_gear": gear_slots_filled,
		"total_tiers": total_tiers,
		"average_tier": float(total_tiers) / gear_slots_filled if gear_slots_filled > 0 else 0.0,
		"gear_slots_filled": gear_slots_filled,
		"gear_slots_total": gear_slots.size(),
		"gear_stats": get_gear_stats(actor_name)
	}

func get_current_turn() -> int:
	"""Get current turn number (placeholder)"""
	# In a real implementation, this would get the current turn from CombatManager
	return 1

func clear_actor_gear(actor_name: String):
	"""Clear all gear for an actor"""
	if actor_gear.has(actor_name):
		actor_gear.erase(actor_name)
		print("GearManager: Cleared all gear for %s" % actor_name)

func get_gear_system_statistics() -> Dictionary:
	"""Get overall gear system statistics"""
	var total_actors = actor_gear.size()
	var total_gear = 0
	var total_tiers = 0
	
	for actor_name in actor_gear.keys():
		var actor_gear_data = actor_gear[actor_name]
		total_gear += actor_gear_data.size()
		
		for gear_slot in actor_gear_data.keys():
			total_tiers += actor_gear_data[gear_slot]
	
	return {
		"actors_with_gear": total_actors,
		"total_gear_equipped": total_gear,
		"total_gear_tiers": total_tiers,
		"average_gear_per_actor": float(total_gear) / total_actors if total_actors > 0 else 0.0,
		"average_tier_per_gear": float(total_tiers) / total_gear if total_gear > 0 else 0.0,
		"total_materials": gear_materials,
		"total_history": gear_history.size()
	} 