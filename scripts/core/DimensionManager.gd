extends Node
class_name DimensionManager

# Dimension Manager - Handles combat across multiple dimensions
# Manages dimension shifts, parallel actions, dimensional merging, and void crossing

signal dimension_shift_triggered(dimension: String, effects: Dictionary, description: String)
signal dimension_narrative_triggered(dimension: String, narrative: String)
signal dimension_merge_triggered(dimensions: Array, power_amplification: float)

# Combat across multiple dimensions
var dimensional_combat = {
	"dimension_shift": {
		"world_transition": true,
		"elemental_change": true,
		"description": "Shift between dimensions",
		"narrative": "The fabric of reality tears as you shift between dimensions. The battlefield transforms as you move from one world to another, each with its own laws of physics and magical properties.",
		"effects": {
			"world_transition": true,
			"elemental_change": true,
			"reality_bend": 1.4,
			"damage_multiplier": 1.3
		}
	},
	"parallel_actions": {
		"multiple_timelines": true,
		"probability": 0.6,
		"description": "Actions across multiple timelines",
		"narrative": "You exist simultaneously across multiple timelines, performing actions in parallel universes. Each action echoes through the multiverse, creating a cascade of effects that amplify your power.",
		"effects": {
			"multiple_timelines": true,
			"probability": 0.6,
			"action_multiplier": 2.0,
			"damage_variance": 1.5
		}
	},
	"dimensional_merging": {
		"combine_worlds": true,
		"power_amplification": 2.0,
		"description": "Merge multiple dimensions",
		"narrative": "You force multiple dimensions to merge, creating a chaotic but powerful fusion of realities. The combined power of multiple worlds flows through you, amplifying your abilities beyond normal limits.",
		"effects": {
			"combine_worlds": true,
			"power_amplification": 2.0,
			"reality_distortion": true,
			"damage_multiplier": 2.5
		}
	},
	"void_crossing": {
		"bypass_reality": true,
		"description": "Attack crosses dimensional barriers",
		"narrative": "Your attack transcends the boundaries of reality itself, crossing through the void between dimensions. It bypasses all conventional defenses and strikes with the raw power of dimensional energy.",
		"effects": {
			"bypass_reality": true,
			"defense_ignore": true,
			"void_damage": 1.8,
			"accuracy": 1.2
		}
	},
	"dimensional_echo": {
		"reality_resonance": true,
		"description": "Create dimensional echoes",
		"narrative": "Your actions create echoes that resonate across multiple dimensions. Each attack ripples through the multiverse, amplifying in power as it bounces between realities.",
		"effects": {
			"reality_resonance": true,
			"echo_damage": 1.6,
			"amplification": 1.4,
			"area_effect": true
		}
	},
	"dimensional_lock": {
		"reality_anchor": true,
		"description": "Anchor reality in place",
		"narrative": "You anchor the current dimension in place, preventing dimensional shifts and creating a stable battlefield. This allows you to fight on your own terms without interference from other realities.",
		"effects": {
			"reality_anchor": true,
			"stability": 1.5,
			"defense_bonus": 1.3,
			"status_resistance": 1.4
		}
	},
	"dimensional_rupture": {
		"reality_break": true,
		"description": "Break dimensional barriers",
		"narrative": "You force a rupture in the dimensional fabric, creating a tear in reality itself. This allows you to draw power from the void between dimensions and unleash devastating attacks.",
		"effects": {
			"reality_break": true,
			"void_power": 1.7,
			"damage_multiplier": 1.8,
			"reality_damage": 2.0
		}
	},
	"dimensional_synergy": {
		"multiverse_harmony": true,
		"description": "Harmonize with multiverse",
		"narrative": "You achieve perfect harmony with the multiverse, allowing all dimensions to work in concert. Your abilities are amplified by the collective power of infinite realities.",
		"effects": {
			"multiverse_harmony": true,
			"universal_power": 2.2,
			"all_enhancements": true,
			"damage_multiplier": 2.0
		}
	}
}

# Active dimensional states
var active_dimensions: Dictionary = {}
var dimensional_energy: int = 100
var max_dimensional_energy: int = 100
var dimension_history: Array = []

# Dimensional cooldowns
var dimension_cooldowns: Dictionary = {}

func trigger_dimensional_combat(mechanic: String, target = null) -> bool:
	"""Trigger a dimensional combat mechanic"""
	if not dimensional_combat.has(mechanic):
		print("DimensionManager: Invalid dimensional mechanic: %s" % mechanic)
		return false
	
	var mechanic_data = dimensional_combat[mechanic]
	var cost = mechanic_data.get("cost", 40)
	
	# Check if we have enough dimensional energy
	if dimensional_energy < cost:
		print("DimensionManager: Insufficient dimensional energy - need %d, have %d" % [cost, dimensional_energy])
		return false
	
	# Check cooldown
	if dimension_cooldowns.has(mechanic):
		var last_used = dimension_cooldowns[mechanic]
		var current_turn = get_current_turn()
		if current_turn - last_used < get_cooldown_turns(mechanic):
			print("DimensionManager: Dimensional mechanic %s on cooldown" % mechanic)
			return false
	
	# Apply dimensional energy cost
	dimensional_energy -= cost
	
	# Apply effects based on dimensional mechanic
	var effects_applied = apply_dimensional_effects(mechanic, target)
	
	# Set cooldown
	dimension_cooldowns[mechanic] = get_current_turn()
	
	# Add to history
	dimension_history.append({
		"turn": get_current_turn(),
		"mechanic": mechanic,
		"cost": cost,
		"target": target.character_name if target else "none",
		"description": mechanic_data["description"],
		"narrative": mechanic_data["narrative"]
	})
	
	# Emit signals
	dimension_shift_triggered.emit(mechanic, effects_applied, mechanic_data["description"])
	dimension_narrative_triggered.emit(mechanic, mechanic_data["narrative"])
	dimension_merge_triggered.emit([mechanic], 1.5)
	
	print("DimensionManager: Triggered %s - Cost: %d, Energy remaining: %d" % [mechanic, cost, dimensional_energy])
	
	return true

func apply_dimensional_effects(mechanic: String, target = null) -> Dictionary:
	"""Apply dimensional combat effects"""
	var effects_applied = {}
	var mechanic_data = dimensional_combat.get(mechanic, {})
	var effects = mechanic_data.get("effects", {})
	
	if not target:
		return effects_applied
	
	# Apply world transition
	if effects.has("world_transition"):
		if target.has_method("add_world_transition"):
			target.add_world_transition(effects["world_transition"])
		effects_applied["world_transition"] = effects["world_transition"]
		print("DimensionManager: Applied world transition from %s" % mechanic)
	
	# Apply elemental change
	if effects.has("elemental_change"):
		if target.has_method("add_elemental_change"):
			target.add_elemental_change(effects["elemental_change"])
		effects_applied["elemental_change"] = effects["elemental_change"]
		print("DimensionManager: Applied elemental change from %s" % mechanic)
	
	# Apply reality bend
	if effects.has("reality_bend"):
		if target.has_method("add_reality_bend"):
			target.add_reality_bend(effects["reality_bend"])
		effects_applied["reality_bend"] = effects["reality_bend"]
		print("DimensionManager: Applied %.1fx reality bend from %s" % [effects["reality_bend"], mechanic])
	
	# Apply damage multiplier
	if effects.has("damage_multiplier"):
		if target.has_method("add_damage_multiplier"):
			target.add_damage_multiplier(effects["damage_multiplier"])
		effects_applied["damage_multiplier"] = effects["damage_multiplier"]
		print("DimensionManager: Applied %.1fx damage multiplier from %s" % [effects["damage_multiplier"], mechanic])
	
	# Apply multiple timelines
	if effects.has("multiple_timelines"):
		if target.has_method("add_multiple_timelines"):
			target.add_multiple_timelines(effects["multiple_timelines"])
		effects_applied["multiple_timelines"] = effects["multiple_timelines"]
		print("DimensionManager: Applied multiple timelines from %s" % mechanic)
	
	# Apply probability
	if effects.has("probability"):
		if target.has_method("add_probability"):
			target.add_probability(effects["probability"])
		effects_applied["probability"] = effects["probability"]
		print("DimensionManager: Applied %.1f probability from %s" % [effects["probability"], mechanic])
	
	# Apply action multiplier
	if effects.has("action_multiplier"):
		if target.has_method("add_action_multiplier"):
			target.add_action_multiplier(effects["action_multiplier"])
		effects_applied["action_multiplier"] = effects["action_multiplier"]
		print("DimensionManager: Applied %.1fx action multiplier from %s" % [effects["action_multiplier"], mechanic])
	
	# Apply damage variance
	if effects.has("damage_variance"):
		if target.has_method("add_damage_variance"):
			target.add_damage_variance(effects["damage_variance"])
		effects_applied["damage_variance"] = effects["damage_variance"]
		print("DimensionManager: Applied %.1fx damage variance from %s" % [effects["damage_variance"], mechanic])
	
	# Apply combine worlds
	if effects.has("combine_worlds"):
		if target.has_method("add_combine_worlds"):
			target.add_combine_worlds(effects["combine_worlds"])
		effects_applied["combine_worlds"] = effects["combine_worlds"]
		print("DimensionManager: Applied combine worlds from %s" % mechanic)
	
	# Apply power amplification
	if effects.has("power_amplification"):
		if target.has_method("add_power_amplification"):
			target.add_power_amplification(effects["power_amplification"])
		effects_applied["power_amplification"] = effects["power_amplification"]
		print("DimensionManager: Applied %.1fx power amplification from %s" % [effects["power_amplification"], mechanic])
	
	# Apply reality distortion
	if effects.has("reality_distortion"):
		if target.has_method("add_reality_distortion"):
			target.add_reality_distortion(effects["reality_distortion"])
		effects_applied["reality_distortion"] = effects["reality_distortion"]
		print("DimensionManager: Applied reality distortion from %s" % mechanic)
	
	# Apply bypass reality
	if effects.has("bypass_reality"):
		if target.has_method("add_bypass_reality"):
			target.add_bypass_reality(effects["bypass_reality"])
		effects_applied["bypass_reality"] = effects["bypass_reality"]
		print("DimensionManager: Applied bypass reality from %s" % mechanic)
	
	# Apply defense ignore
	if effects.has("defense_ignore"):
		if target.has_method("add_defense_ignore"):
			target.add_defense_ignore(effects["defense_ignore"])
		effects_applied["defense_ignore"] = effects["defense_ignore"]
		print("DimensionManager: Applied defense ignore from %s" % mechanic)
	
	# Apply void damage
	if effects.has("void_damage"):
		if target.has_method("add_void_damage"):
			target.add_void_damage(effects["void_damage"])
		effects_applied["void_damage"] = effects["void_damage"]
		print("DimensionManager: Applied %.1fx void damage from %s" % [effects["void_damage"], mechanic])
	
	# Apply accuracy bonus
	if effects.has("accuracy"):
		if target.has_method("add_accuracy_bonus"):
			target.add_accuracy_bonus(effects["accuracy"])
		effects_applied["accuracy"] = effects["accuracy"]
		print("DimensionManager: Applied %.1fx accuracy bonus from %s" % [effects["accuracy"], mechanic])
	
	# Apply reality resonance
	if effects.has("reality_resonance"):
		if target.has_method("add_reality_resonance"):
			target.add_reality_resonance(effects["reality_resonance"])
		effects_applied["reality_resonance"] = effects["reality_resonance"]
		print("DimensionManager: Applied reality resonance from %s" % mechanic)
	
	# Apply echo damage
	if effects.has("echo_damage"):
		if target.has_method("add_echo_damage"):
			target.add_echo_damage(effects["echo_damage"])
		effects_applied["echo_damage"] = effects["echo_damage"]
		print("DimensionManager: Applied %.1fx echo damage from %s" % [effects["echo_damage"], mechanic])
	
	# Apply amplification
	if effects.has("amplification"):
		if target.has_method("add_amplification"):
			target.add_amplification(effects["amplification"])
		effects_applied["amplification"] = effects["amplification"]
		print("DimensionManager: Applied %.1fx amplification from %s" % [effects["amplification"], mechanic])
	
	# Apply area effect
	if effects.has("area_effect"):
		if target.has_method("add_area_effect"):
			target.add_area_effect(effects["area_effect"])
		effects_applied["area_effect"] = effects["area_effect"]
		print("DimensionManager: Applied area effect from %s" % mechanic)
	
	# Apply reality anchor
	if effects.has("reality_anchor"):
		if target.has_method("add_reality_anchor"):
			target.add_reality_anchor(effects["reality_anchor"])
		effects_applied["reality_anchor"] = effects["reality_anchor"]
		print("DimensionManager: Applied reality anchor from %s" % mechanic)
	
	# Apply stability
	if effects.has("stability"):
		if target.has_method("add_stability"):
			target.add_stability(effects["stability"])
		effects_applied["stability"] = effects["stability"]
		print("DimensionManager: Applied %.1fx stability from %s" % [effects["stability"], mechanic])
	
	# Apply defense bonus
	if effects.has("defense_bonus"):
		if target.has_method("add_defense_bonus"):
			target.add_defense_bonus(effects["defense_bonus"])
		effects_applied["defense_bonus"] = effects["defense_bonus"]
		print("DimensionManager: Applied %.1fx defense bonus from %s" % [effects["defense_bonus"], mechanic])
	
	# Apply status resistance
	if effects.has("status_resistance"):
		if target.has_method("add_status_resistance"):
			target.add_status_resistance(effects["status_resistance"])
		effects_applied["status_resistance"] = effects["status_resistance"]
		print("DimensionManager: Applied %.1fx status resistance from %s" % [effects["status_resistance"], mechanic])
	
	# Apply reality break
	if effects.has("reality_break"):
		if target.has_method("add_reality_break"):
			target.add_reality_break(effects["reality_break"])
		effects_applied["reality_break"] = effects["reality_break"]
		print("DimensionManager: Applied reality break from %s" % mechanic)
	
	# Apply void power
	if effects.has("void_power"):
		if target.has_method("add_void_power"):
			target.add_void_power(effects["void_power"])
		effects_applied["void_power"] = effects["void_power"]
		print("DimensionManager: Applied %.1fx void power from %s" % [effects["void_power"], mechanic])
	
	# Apply reality damage
	if effects.has("reality_damage"):
		if target.has_method("add_reality_damage"):
			target.add_reality_damage(effects["reality_damage"])
		effects_applied["reality_damage"] = effects["reality_damage"]
		print("DimensionManager: Applied %.1fx reality damage from %s" % [effects["reality_damage"], mechanic])
	
	# Apply multiverse harmony
	if effects.has("multiverse_harmony"):
		if target.has_method("add_multiverse_harmony"):
			target.add_multiverse_harmony(effects["multiverse_harmony"])
		effects_applied["multiverse_harmony"] = effects["multiverse_harmony"]
		print("DimensionManager: Applied multiverse harmony from %s" % mechanic)
	
	# Apply universal power
	if effects.has("universal_power"):
		if target.has_method("add_universal_power"):
			target.add_universal_power(effects["universal_power"])
		effects_applied["universal_power"] = effects["universal_power"]
		print("DimensionManager: Applied %.1fx universal power from %s" % [effects["universal_power"], mechanic])
	
	# Apply all enhancements
	if effects.has("all_enhancements"):
		if target.has_method("add_all_enhancements"):
			target.add_all_enhancements(effects["all_enhancements"])
		effects_applied["all_enhancements"] = effects["all_enhancements"]
		print("DimensionManager: Applied all enhancements from %s" % mechanic)
	
	return effects_applied

func get_dimensional_mechanic_data(mechanic: String) -> Dictionary:
	"""Get data for a specific dimensional mechanic"""
	return dimensional_combat.get(mechanic, {})

func get_available_dimensional_mechanics() -> Array:
	"""Get all available dimensional mechanics"""
	var available = []
	
	for mechanic in dimensional_combat.keys():
		var mechanic_data = dimensional_combat[mechanic]
		var cost = mechanic_data.get("cost", 40)
		var can_afford = dimensional_energy >= cost
		
		available.append({
			"mechanic": mechanic,
			"cost": cost,
			"description": mechanic_data["description"],
			"narrative": mechanic_data["narrative"],
			"can_afford": can_afford
		})
	
	return available

func get_dimensional_narrative(mechanic: String) -> String:
	"""Get narrative description for a dimensional mechanic"""
	var mechanic_data = dimensional_combat.get(mechanic, {})
	return mechanic_data.get("narrative", "")

func get_dimensional_energy() -> int:
	"""Get current dimensional energy"""
	return dimensional_energy

func add_dimensional_energy(amount: int):
	"""Add dimensional energy"""
	dimensional_energy = min(dimensional_energy + amount, max_dimensional_energy)
	print("DimensionManager: Added %d dimensional energy, total: %d" % [amount, dimensional_energy])

func get_cooldown_turns(mechanic: String) -> int:
	"""Get cooldown turns for a dimensional mechanic"""
	var cooldowns = {
		"dimension_shift": 3,
		"parallel_actions": 4,
		"dimensional_merging": 6,
		"void_crossing": 3,
		"dimensional_echo": 2,
		"dimensional_lock": 4,
		"dimensional_rupture": 5,
		"dimensional_synergy": 8
	}
	
	return cooldowns.get(mechanic, 1)

func get_current_turn() -> int:
	"""Get current turn number (placeholder)"""
	# In a real implementation, this would get the current turn from CombatManager
	return 1

func clear_dimensional_states():
	"""Clear all active dimensional states"""
	active_dimensions.clear()
	print("DimensionManager: All dimensional states cleared")

func clear_cooldowns_for_testing():
	"""Clear all cooldowns for testing purposes"""
	dimension_cooldowns.clear()
	print("DimensionManager: All cooldowns cleared for testing")

func get_dimensional_statistics() -> Dictionary:
	"""Get dimensional system statistics"""
	return {
		"dimensional_energy": dimensional_energy,
		"max_dimensional_energy": max_dimensional_energy,
		"active_dimensions": active_dimensions.size(),
		"total_mechanics": dimensional_combat.size(),
		"history_entries": dimension_history.size(),
		"cooldowns_active": dimension_cooldowns.size()
	} 