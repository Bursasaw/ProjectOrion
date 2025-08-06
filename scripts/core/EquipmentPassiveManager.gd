extends Node
class_name EquipmentPassiveManager

# Equipment Passive Manager - Handles equipment passive effects
# Manages passive bonuses, penalties, and narrative descriptions

signal passive_effect_applied(effect_type: String, item_name: String, description: String)
signal passive_effect_removed(effect_type: String, item_name: String)
signal passive_effect_triggered(effect_type: String, target, effect: String)

# Equipment passive effects and their properties
var equipment_passives = {
	"elemental_resonance": {
		"elemental_damage": 1.2,
		"description": "Harmonizes with your elemental affinity",
		"narrative": "The equipment resonates with your elemental nature, amplifying your power",
		"world_bonus": {
			"sylithar": 1.3,
			"krynn": 1.2,
			"elysion": 1.1,
			"terra": 1.1,
			"aethra": 1.2,
			"ombra": 1.4,
			"nokturn": 1.1,
			"tauron": 1.0,
			"aelria": 1.3
		}
	},
	"multiverse_attunement": {
		"base_bonus": 1.3,
		"description": "Attuned to your world of origin",
		"narrative": "The equipment is perfectly attuned to your home world's energy",
		"world_bonus": {
			"aelria": 1.5,
			"elysion": 1.4,
			"sylithar": 1.3,
			"krynn": 1.3,
			"terra": 1.2,
			"aethra": 1.2,
			"ombra": 1.4,
			"nokturn": 1.2,
			"tauron": 1.1
		}
	},
	"ancient_technology": {
		"tech_damage": 1.4,
		"description": "Forgotten technology from the Ancients",
		"narrative": "Ancient technology hums with forgotten power, enhancing your capabilities",
		"world_bonus": {
			"tauron": 1.6,
			"elysion": 1.5,
			"aelria": 1.4,
			"sylithar": 1.3,
			"krynn": 1.3,
			"terra": 1.2,
			"aethra": 1.3,
			"ombra": 1.4,
			"nokturn": 1.2
		}
	},
	"void_corruption": {
		"void_damage": 1.5,
		"penalty": {"void_resistance": 0.8},
		"description": "Corrupted by void energy",
		"narrative": "Void energy courses through the equipment, powerful but dangerous",
		"world_bonus": {
			"ombra": 1.8,
			"aelria": 1.6,
			"nokturn": 1.4,
			"elysion": 1.3,
			"sylithar": 1.3,
			"krynn": 1.2,
			"terra": 1.1,
			"aethra": 1.2,
			"tauron": 1.1
		}
	},
	"dragon_essence": {
		"dragon_damage": 1.6,
		"description": "Infused with dragon essence",
		"narrative": "The essence of ancient dragons empowers your equipment",
		"world_bonus": {
			"krynn": 1.8,
			"aelria": 1.5,
			"elysion": 1.4,
			"sylithar": 1.3,
			"terra": 1.2,
			"aethra": 1.3,
			"ombra": 1.4,
			"nokturn": 1.2,
			"tauron": 1.1
		}
	},
	"crystal_resonance": {
		"crystal_damage": 1.3,
		"description": "Resonates with crystalline structures",
		"narrative": "Crystalline energy flows through your equipment, creating harmonic resonance",
		"world_bonus": {
			"sylithar": 1.6,
			"aelria": 1.4,
			"elysion": 1.3,
			"krynn": 1.2,
			"terra": 1.1,
			"aethra": 1.2,
			"ombra": 1.3,
			"nokturn": 1.1,
			"tauron": 1.0
		}
	},
	"shadow_veil": {
		"shadow_damage": 1.4,
		"stealth_bonus": 0.3,
		"description": "Cloaked in shadow energy",
		"narrative": "Shadows wrap around your equipment, concealing and empowering",
		"world_bonus": {
			"nokturn": 1.7,
			"ombra": 1.5,
			"aelria": 1.3,
			"elysion": 1.2,
			"sylithar": 1.2,
			"krynn": 1.1,
			"terra": 1.0,
			"aethra": 1.1,
			"tauron": 1.0
		}
	},
	"reality_bending": {
		"reality_damage": 1.7,
		"description": "Bends reality itself",
		"narrative": "Your equipment warps reality, creating impossible effects",
		"world_bonus": {
			"aelria": 2.0,
			"ombra": 1.8,
			"elysion": 1.5,
			"sylithar": 1.4,
			"krynn": 1.3,
			"terra": 1.2,
			"aethra": 1.3,
			"nokturn": 1.3,
			"tauron": 1.1
		}
	}
}

# Active passive effects on equipment
var active_passive_effects: Dictionary = {}

# Equipment passive tracking
var equipment_passive_tracking: Dictionary = {}

func apply_passive_effect_to_item(item_name: String, effect_type: String, world: String = "") -> bool:
	"""Apply a passive effect to an item"""
	if not equipment_passives.has(effect_type):
		print("EquipmentPassiveManager: Invalid passive effect type: %s" % effect_type)
		return false
	
	var effect_data = equipment_passives[effect_type].duplicate()
	
	# Apply world bonus if available
	if world != "" and effect_data.has("world_bonus") and effect_data["world_bonus"].has(world):
		var world_bonus = effect_data["world_bonus"][world]
		for key in effect_data:
			if key != "description" and key != "narrative" and key != "world_bonus" and key != "penalty":
				if effect_data[key] is float or effect_data[key] is int:
					effect_data[key] *= world_bonus
		print("EquipmentPassiveManager: Applied %s world bonus to %s effect" % [world, effect_type])
	
	active_passive_effects[item_name] = effect_data
	equipment_passive_tracking[item_name] = effect_type
	
	print("EquipmentPassiveManager: Applied %s passive effect to %s" % [effect_type, item_name])
	passive_effect_applied.emit(effect_type, item_name, effect_data["description"])
	
	return true

func remove_passive_effect_from_item(item_name: String) -> bool:
	"""Remove passive effect from an item"""
	if not active_passive_effects.has(item_name):
		return false
	
	var effect_type = equipment_passive_tracking.get(item_name, "unknown")
	
	active_passive_effects.erase(item_name)
	equipment_passive_tracking.erase(item_name)
	
	print("EquipmentPassiveManager: Removed passive effect from %s" % item_name)
	passive_effect_removed.emit(effect_type, item_name)
	
	return true

func get_passive_effect_for_item(item_name: String) -> Dictionary:
	"""Get passive effect data for an item"""
	if active_passive_effects.has(item_name):
		return active_passive_effects[item_name]
	
	return {}

func apply_passive_effects_to_actor(actor) -> Dictionary:
	"""Apply all passive effects from equipped items to an actor"""
	var effects_applied = {}
	
	if not actor.has_method("get_equipment"):
		return effects_applied
	
	var equipment = actor.get_equipment()
	
	for item_name in equipment:
		var passive_effect = get_passive_effect_for_item(item_name)
		if passive_effect.size() > 0:
			var effect_applied = apply_single_passive_effect(actor, passive_effect, item_name)
			if effect_applied.size() > 0:
				effects_applied[item_name] = effect_applied
	
	return effects_applied

func apply_single_passive_effect(actor, effect_data: Dictionary, item_name: String) -> Dictionary:
	"""Apply a single passive effect to an actor"""
	var effects_applied = {}
	
	# Apply elemental damage bonus
	if effect_data.has("elemental_damage"):
		if actor.has_method("add_elemental_damage_bonus"):
			actor.add_elemental_damage_bonus(effect_data["elemental_damage"])
		effects_applied["elemental_damage"] = effect_data["elemental_damage"]
		print("EquipmentPassiveManager: Applied %.1fx elemental damage bonus from %s" % [effect_data["elemental_damage"], item_name])
	
	# Apply world bonus
	if effect_data.has("world_bonus"):
		if actor.has_method("add_world_bonus"):
			actor.add_world_bonus(effect_data["world_bonus"])
		effects_applied["world_bonus"] = effect_data["world_bonus"]
		print("EquipmentPassiveManager: Applied world bonus from %s" % item_name)
	
	# Apply tech damage bonus
	if effect_data.has("tech_damage"):
		if actor.has_method("add_tech_damage_bonus"):
			actor.add_tech_damage_bonus(effect_data["tech_damage"])
		effects_applied["tech_damage"] = effect_data["tech_damage"]
		print("EquipmentPassiveManager: Applied %.1fx tech damage bonus from %s" % [effect_data["tech_damage"], item_name])
	
	# Apply void damage bonus
	if effect_data.has("void_damage"):
		if actor.has_method("add_void_damage_bonus"):
			actor.add_void_damage_bonus(effect_data["void_damage"])
		effects_applied["void_damage"] = effect_data["void_damage"]
		print("EquipmentPassiveManager: Applied %.1fx void damage bonus from %s" % [effect_data["void_damage"], item_name])
	
	# Apply dragon damage bonus
	if effect_data.has("dragon_damage"):
		if actor.has_method("add_dragon_damage_bonus"):
			actor.add_dragon_damage_bonus(effect_data["dragon_damage"])
		effects_applied["dragon_damage"] = effect_data["dragon_damage"]
		print("EquipmentPassiveManager: Applied %.1fx dragon damage bonus from %s" % [effect_data["dragon_damage"], item_name])
	
	# Apply crystal damage bonus
	if effect_data.has("crystal_damage"):
		if actor.has_method("add_crystal_damage_bonus"):
			actor.add_crystal_damage_bonus(effect_data["crystal_damage"])
		effects_applied["crystal_damage"] = effect_data["crystal_damage"]
		print("EquipmentPassiveManager: Applied %.1fx crystal damage bonus from %s" % [effect_data["crystal_damage"], item_name])
	
	# Apply shadow damage bonus
	if effect_data.has("shadow_damage"):
		if actor.has_method("add_shadow_damage_bonus"):
			actor.add_shadow_damage_bonus(effect_data["shadow_damage"])
		effects_applied["shadow_damage"] = effect_data["shadow_damage"]
		print("EquipmentPassiveManager: Applied %.1fx shadow damage bonus from %s" % [effect_data["shadow_damage"], item_name])
	
	# Apply reality damage bonus
	if effect_data.has("reality_damage"):
		if actor.has_method("add_reality_damage_bonus"):
			actor.add_reality_damage_bonus(effect_data["reality_damage"])
		effects_applied["reality_damage"] = effect_data["reality_damage"]
		print("EquipmentPassiveManager: Applied %.1fx reality damage bonus from %s" % [effect_data["reality_damage"], item_name])
	
	# Apply stealth bonus
	if effect_data.has("stealth_bonus"):
		if actor.has_method("add_stealth_bonus"):
			actor.add_stealth_bonus(effect_data["stealth_bonus"])
		effects_applied["stealth_bonus"] = effect_data["stealth_bonus"]
		print("EquipmentPassiveManager: Applied %.1f stealth bonus from %s" % [effect_data["stealth_bonus"], item_name])
	
	# Apply penalties
	if effect_data.has("penalty"):
		var penalties = effect_data["penalty"]
		for penalty_type in penalties:
			if actor.has_method("add_penalty"):
				actor.add_penalty(penalty_type, penalties[penalty_type])
			effects_applied["penalty_" + penalty_type] = penalties[penalty_type]
			print("EquipmentPassiveManager: Applied %.1f penalty to %s from %s" % [penalties[penalty_type], penalty_type, item_name])
	
	# Emit effect triggered signal
	if effects_applied.size() > 0:
		passive_effect_triggered.emit("passive", actor, str(effects_applied))
	
	return effects_applied

func get_passive_effect_narrative(item_name: String) -> String:
	"""Get narrative description of passive effect for an item"""
	var effect_data = get_passive_effect_for_item(item_name)
	
	if effect_data.has("narrative"):
		return effect_data["narrative"]
	
	return "No passive effect"

func get_passive_effect_description(item_name: String) -> String:
	"""Get description of passive effect for an item"""
	var effect_data = get_passive_effect_for_item(item_name)
	
	if effect_data.has("description"):
		return effect_data["description"]
	
	return "No passive effect"

func get_all_passive_effects() -> Dictionary:
	"""Get all active passive effects"""
	return active_passive_effects.duplicate()

func clear_all_passive_effects():
	"""Clear all active passive effects"""
	active_passive_effects.clear()
	equipment_passive_tracking.clear()
	print("EquipmentPassiveManager: Cleared all passive effects")

func get_passive_effect_statistics() -> Dictionary:
	"""Get passive effect system statistics"""
	return {
		"active_effects_count": active_passive_effects.size(),
		"effect_types": equipment_passive_tracking.values(),
		"available_passive_types": equipment_passives.size()
	} 
