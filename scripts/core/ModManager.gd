extends Node
class_name ModManager

# Mod Manager - Handles mod system inspired by SWGOH
# Manages mod sets, mod slots, mod optimization, and mod bonuses

signal mod_equipped(actor: String, mod_type: String, mod_level: int)
signal mod_optimized(actor: String, optimization_type: String, improvement: float)
signal mod_set_completed(actor: String, set_type: String, bonus_activated: bool)

# Mod system inspired by SWGOH
var mod_sets = {
	"speed": {
		"pieces_required": 4,
		"bonus": "Speed +10%",
		"description": "Increases speed by 10%",
		"narrative": "Speed mods enhance your agility and turn frequency."
	},
	"health": {
		"pieces_required": 2,
		"bonus": "Health +10%",
		"description": "Increases maximum health by 10%",
		"narrative": "Health mods make you more resilient to damage."
	},
	"defense": {
		"pieces_required": 2,
		"bonus": "Defense +10%",
		"description": "Increases defense by 10%",
		"narrative": "Defense mods reduce incoming damage."
	},
	"attack": {
		"pieces_required": 4,
		"bonus": "Attack +10%",
		"description": "Increases attack power by 10%",
		"narrative": "Attack mods amplify your offensive capabilities."
	},
	"critical_chance": {
		"pieces_required": 2,
		"bonus": "Critical Chance +8%",
		"description": "Increases critical hit chance by 8%",
		"narrative": "Critical chance mods make your attacks more devastating."
	},
	"critical_damage": {
		"pieces_required": 4,
		"bonus": "Critical Damage +30%",
		"description": "Increases critical damage by 30%",
		"narrative": "Critical damage mods make your critical hits more powerful."
	},
	"potency": {
		"pieces_required": 2,
		"bonus": "Potency +10%",
		"description": "Increases ability to apply status effects by 10%",
		"narrative": "Potency mods improve your ability to inflict status conditions."
	},
	"tenacity": {
		"pieces_required": 2,
		"bonus": "Tenacity +10%",
		"description": "Increases resistance to status effects by 10%",
		"narrative": "Tenacity mods make you more resistant to enemy status effects."
	}
}

# Mod slot types
var mod_slots = {
	"square": {"primary_stats": ["attack"], "secondary_stats": ["speed", "health", "defense", "critical_chance"]},
	"arrow": {"primary_stats": ["speed", "attack", "health", "defense"], "secondary_stats": ["critical_chance", "critical_damage", "potency", "tenacity"]},
	"diamond": {"primary_stats": ["defense"], "secondary_stats": ["speed", "attack", "health", "critical_chance"]},
	"triangle": {"primary_stats": ["critical_chance", "critical_damage", "attack", "health", "defense"], "secondary_stats": ["speed", "potency", "tenacity"]},
	"circle": {"primary_stats": ["health"], "secondary_stats": ["speed", "attack", "defense", "critical_chance"]},
	"cross": {"primary_stats": ["potency", "tenacity", "attack", "health", "defense"], "secondary_stats": ["speed", "critical_chance", "critical_damage"]}
}

# Actor mod configurations
var actor_mods: Dictionary = {}
var mod_history: Array = []

# Mod optimization settings
var optimization_targets = {
	"speed": {"priority": 10, "description": "Maximize speed for turn frequency"},
	"attack": {"priority": 8, "description": "Maximize attack for damage output"},
	"health": {"priority": 6, "description": "Maximize health for survivability"},
	"defense": {"priority": 5, "description": "Maximize defense for damage reduction"},
	"critical_chance": {"priority": 7, "description": "Maximize critical chance for damage"},
	"critical_damage": {"priority": 9, "description": "Maximize critical damage for burst"},
	"potency": {"priority": 4, "description": "Maximize potency for status effects"},
	"tenacity": {"priority": 3, "description": "Maximize tenacity for status resistance"}
}

func _ready():
	"""Initialize mod manager"""
	print("ModManager: Initialized")

func equip_mod(actor_name: String, slot_type: String, mod_data: Dictionary) -> bool:
	"""Equip a mod to an actor"""
	if not mod_slots.has(slot_type):
		print("ModManager: Invalid slot type: %s" % slot_type)
		return false
	
	if not actor_mods.has(actor_name):
		actor_mods[actor_name] = {}
	
	# Validate mod data
	if not mod_data.has("set_type") or not mod_data.has("primary_stat"):
		print("ModManager: Invalid mod data")
		return false
	
	# Check if primary stat is valid for this slot
	var valid_primary_stats = mod_slots[slot_type]["primary_stats"]
	if not valid_primary_stats.has(mod_data["primary_stat"]):
		print("ModManager: Invalid primary stat %s for slot %s" % [mod_data["primary_stat"], slot_type])
		return false
	
	# Equip the mod
	actor_mods[actor_name][slot_type] = mod_data
	
	# Add to history
	mod_history.append({
		"turn": get_current_turn(),
		"actor": actor_name,
		"action": "equip_mod",
		"slot_type": slot_type,
		"mod_data": mod_data
	})
	
	# Check for mod set completion
	var set_bonus = get_mod_set_bonus(actor_name, mod_data["set_type"])
	if set_bonus.has("bonus_activated") and set_bonus["bonus_activated"]:
		mod_set_completed.emit(actor_name, mod_data["set_type"], true)
	
	# Emit signal
	mod_equipped.emit(actor_name, mod_data["set_type"], mod_data.get("level", 1))
	
	print("ModManager: Equipped %s mod to %s in %s slot" % [mod_data["set_type"], actor_name, slot_type])
	
	return true

func get_actor_mods(actor_name: String) -> Dictionary:
	"""Get all mods equipped to an actor"""
	return actor_mods.get(actor_name, {})

func get_mod_set_bonus(actor_name: String, set_type: String) -> Dictionary:
	"""Get mod set bonus for an actor"""
	if not actor_mods.has(actor_name):
		return {}
	
	var equipped_mods = actor_mods[actor_name]
	var set_count = 0
	
	for slot_data in equipped_mods.values():
		if slot_data.has("set_type") and slot_data["set_type"] == set_type:
			set_count += 1
	
	var set_data = mod_sets.get(set_type, {})
	var pieces_required = set_data.get("pieces_required", 0)
	var bonus_activated = set_count >= pieces_required
	
	return {
		"set_type": set_type,
		"pieces_equipped": set_count,
		"pieces_required": pieces_required,
		"bonus_activated": bonus_activated,
		"bonus": set_data.get("bonus", ""),
		"description": set_data.get("description", "")
	}

func get_all_mod_set_bonuses(actor_name: String) -> Array:
	"""Get all mod set bonuses for an actor"""
	var bonuses = []
	
	for set_type in mod_sets.keys():
		var bonus_data = get_mod_set_bonus(actor_name, set_type)
		if bonus_data.has("set_type"):
			bonuses.append(bonus_data)
	
	return bonuses

func optimize_mods(actor_name: String, target_stat: String) -> bool:
	"""Optimize mods for a specific target stat"""
	if not optimization_targets.has(target_stat):
		print("ModManager: Unknown optimization target: %s" % target_stat)
		return false
	
	if not actor_mods.has(actor_name):
		print("ModManager: Actor %s has no mods equipped" % actor_name)
		return false
	
	var current_mods = actor_mods[actor_name]
	var optimization_score = 0.0
	
	# Calculate current optimization score
	for slot_type in current_mods.keys():
		var mod_data = current_mods[slot_type]
		
		# Check primary stat
		if mod_data.has("primary_stat") and mod_data["primary_stat"] == target_stat:
			optimization_score += 10.0
		
		# Check secondary stats
		if mod_data.has("secondary_stats"):
			for secondary_stat in mod_data["secondary_stats"]:
				if secondary_stat == target_stat:
					optimization_score += 2.0
		
		# Check mod level (higher level = better stats)
		var mod_level = mod_data.get("level", 1)
		optimization_score += mod_level * 0.5
	
	# Add to history
	mod_history.append({
		"turn": get_current_turn(),
		"actor": actor_name,
		"action": "optimize_mods",
		"target_stat": target_stat,
		"optimization_score": optimization_score
	})
	
	# Emit signal
	mod_optimized.emit(actor_name, target_stat, optimization_score)
	
	print("ModManager: Optimized %s mods for %s (Score: %.1f)" % [actor_name, target_stat, optimization_score])
	
	return true

func level_up_mod(actor_name: String, slot_type: String) -> bool:
	"""Level up a mod in a specific slot"""
	if not actor_mods.has(actor_name) or not actor_mods[actor_name].has(slot_type):
		print("ModManager: No mod found in slot %s for actor %s" % [slot_type, actor_name])
		return false
	
	var mod_data = actor_mods[actor_name][slot_type]
	var current_level = mod_data.get("level", 1)
	var new_level = min(current_level + 1, 15)  # Max level 15
	
	mod_data["level"] = new_level
	actor_mods[actor_name][slot_type] = mod_data
	
	# Add to history
	mod_history.append({
		"turn": get_current_turn(),
		"actor": actor_name,
		"action": "level_up_mod",
		"slot_type": slot_type,
		"old_level": current_level,
		"new_level": new_level
	})
	
	print("ModManager: Leveled up %s mod in %s slot (Level %d -> %d)" % [actor_name, slot_type, current_level, new_level])
	
	return true

func get_mod_statistics(actor_name: String) -> Dictionary:
	"""Get mod statistics for an actor"""
	if not actor_mods.has(actor_name):
		return {}
	
	var equipped_mods = actor_mods[actor_name]
	var total_levels = 0
	var set_counts = {}
	
	for slot_type in equipped_mods.keys():
		var mod_data = equipped_mods[slot_type]
		total_levels += mod_data.get("level", 1)
		
		var set_type = mod_data.get("set_type", "unknown")
		set_counts[set_type] = set_counts.get(set_type, 0) + 1
	
	return {
		"total_mods": equipped_mods.size(),
		"total_levels": total_levels,
		"average_level": float(total_levels) / equipped_mods.size() if equipped_mods.size() > 0 else 0.0,
		"set_counts": set_counts,
		"mod_slots_filled": equipped_mods.size(),
		"mod_slots_total": mod_slots.size()
	}

func get_available_mod_sets() -> Array:
	"""Get all available mod sets"""
	var available = []
	
	for set_type in mod_sets.keys():
		var set_data = mod_sets[set_type]
		available.append({
			"set_type": set_type,
			"pieces_required": set_data["pieces_required"],
			"bonus": set_data["bonus"],
			"description": set_data["description"],
			"narrative": set_data["narrative"]
		})
	
	return available

func get_mod_slot_info(slot_type: String) -> Dictionary:
	"""Get information about a specific mod slot"""
	if not mod_slots.has(slot_type):
		return {}
	
	return {
		"slot_type": slot_type,
		"primary_stats": mod_slots[slot_type]["primary_stats"],
		"secondary_stats": mod_slots[slot_type]["secondary_stats"]
	}

func get_current_turn() -> int:
	"""Get current turn number (placeholder)"""
	# In a real implementation, this would get the current turn from CombatManager
	return 1

func clear_actor_mods(actor_name: String):
	"""Clear all mods for an actor"""
	if actor_mods.has(actor_name):
		actor_mods.erase(actor_name)
		print("ModManager: Cleared all mods for %s" % actor_name)

func get_mod_system_statistics() -> Dictionary:
	"""Get overall mod system statistics"""
	var total_actors = actor_mods.size()
	var total_mods = 0
	var total_levels = 0
	
	for actor_name in actor_mods.keys():
		var actor_mods_data = actor_mods[actor_name]
		total_mods += actor_mods_data.size()
		
		for slot_data in actor_mods_data.values():
			total_levels += slot_data.get("level", 1)
	
	return {
		"actors_with_mods": total_actors,
		"total_mods_equipped": total_mods,
		"total_mod_levels": total_levels,
		"average_mods_per_actor": float(total_mods) / total_actors if total_actors > 0 else 0.0,
		"average_level_per_mod": float(total_levels) / total_mods if total_mods > 0 else 0.0,
		"total_history": mod_history.size()
	} 