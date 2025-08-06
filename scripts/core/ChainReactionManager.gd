extends Node
class_name ChainReactionManager

# Chain Reaction Manager - Handles chain reaction system in combat
# Manages elemental chains, world chains, species chains, and void chains

signal chain_reaction_triggered(chain_type: String, multiplier: float, description: String)
signal chain_narrative_triggered(chain_type: String, narrative: String)
signal chain_cascade_triggered(chains: Array, total_multiplier: float)

# Chain reaction system
var chain_reactions = {
	"elemental_chain": {
		"fire_ice_lightning": 3.0,
		"description": "Elemental cascade",
		"narrative": "The elements themselves conspire against your enemies! Fire melts ice, creating steam that conducts lightning with devastating efficiency. The elemental chain reaction amplifies your power exponentially.",
		"effects": {
			"elemental_damage": 3.0,
			"chain_multiplier": 2.5,
			"area_effect": true,
			"status_application": true
		}
	},
	"world_chain": {
		"nokturn_elysion_ombra": 2.5,
		"description": "World energies collide",
		"narrative": "The very fabric of the multiverse trembles as world energies collide! The ancient magic of Elysion, the shadow power of Nokturn, and the void essence of Ombra create a cataclysmic chain reaction.",
		"effects": {
			"world_damage": 2.5,
			"reality_distortion": true,
			"multiverse_power": 2.0,
			"void_corruption": 1.8
		}
	},
	"species_chain": {
		"sylph_dwarf_titan": 2.0,
		"description": "Species synergy explosion",
		"narrative": "The natural abilities of different species harmonize perfectly! The ethereal grace of the Sylph, the unyielding strength of the Dwarf, and the divine power of the Titan create an unstoppable force.",
		"effects": {
			"species_synergy": 2.0,
			"team_damage": 2.2,
			"coordination": 1.8,
			"morale_bonus": 1.5
		}
	},
	"void_chain": {
		"reality_cascade": true,
		"description": "Reality itself begins to unravel",
		"narrative": "Reality itself begins to unravel as void energy cascades through the battlefield! The fabric of existence tears apart, creating a chain reaction that threatens to consume everything in its path.",
		"effects": {
			"reality_cascade": true,
			"void_damage": 3.5,
			"reality_break": true,
			"unpredictable_effects": true
		}
	},
	"time_chain": {
		"temporal_cascade": 2.8,
		"description": "Time itself cascades",
		"narrative": "Time itself becomes a weapon as temporal energy cascades through the battlefield! Past, present, and future collide in a chain reaction that bends the very flow of time to your will.",
		"effects": {
			"temporal_damage": 2.8,
			"time_dilation": 2.0,
			"temporal_rewind": true,
			"future_sight": 1.5
		}
	},
	"quantum_chain": {
		"quantum_cascade": 3.2,
		"description": "Quantum probability cascade",
		"narrative": "Quantum probability itself cascades as multiple realities collapse into one! Every possible outcome becomes a weapon, creating a chain reaction that defies the laws of physics.",
		"effects": {
			"quantum_damage": 3.2,
			"probability_manipulation": true,
			"reality_shift": 2.5,
			"quantum_entanglement": 2.0
		}
	},
	"dimensional_chain": {
		"dimensional_cascade": 3.5,
		"description": "Dimensional barriers collapse",
		"narrative": "Dimensional barriers collapse as the multiverse itself becomes a weapon! The boundaries between worlds shatter, creating a chain reaction that draws power from infinite realities.",
		"effects": {
			"dimensional_damage": 3.5,
			"dimension_shift": true,
			"multiverse_power": 3.0,
			"reality_merge": 2.5
		}
	},
	"ultimate_chain": {
		"all_systems_cascade": 4.0,
		"description": "All systems cascade together",
		"narrative": "Every system, every power, every reality cascades together in perfect harmony! This is the ultimate chain reaction, where all your abilities combine into a force that transcends the multiverse itself.",
		"effects": {
			"ultimate_damage": 4.0,
			"all_enhancements": true,
			"reality_transcendence": true,
			"multiverse_harmony": 3.5
		}
	}
}

# Active chain reactions
var active_chains: Dictionary = {}
var chain_energy: int = 100
var max_chain_energy: int = 100
var chain_history: Array = []

# Chain reaction cooldowns
var chain_cooldowns: Dictionary = {}

func trigger_chain_reaction(chain_type: String, target = null) -> bool:
	"""Trigger a chain reaction"""
	if not chain_reactions.has(chain_type):
		print("ChainReactionManager: Invalid chain reaction: %s" % chain_type)
		return false
	
	var chain_data = chain_reactions[chain_type]
	var cost = chain_data.get("cost", 50)
	
	# Check if we have enough chain energy
	if chain_energy < cost:
		print("ChainReactionManager: Insufficient chain energy - need %d, have %d" % [cost, chain_energy])
		return false
	
	# Check cooldown
	if chain_cooldowns.has(chain_type):
		var last_used = chain_cooldowns[chain_type]
		var current_turn = get_current_turn()
		if current_turn - last_used < get_cooldown_turns(chain_type):
			print("ChainReactionManager: Chain reaction %s on cooldown" % chain_type)
			return false
	
	# Apply chain energy cost
	chain_energy -= cost
	
	# Apply effects based on chain reaction
	var _effects_applied = apply_chain_effects(chain_type, target)
	
	# Set cooldown
	chain_cooldowns[chain_type] = get_current_turn()
	
	# Add to history
	chain_history.append({
		"turn": get_current_turn(),
		"chain_type": chain_type,
		"cost": cost,
		"target": target.character_name if target else "none",
		"description": chain_data["description"],
		"narrative": chain_data["narrative"]
	})
	
	# Emit signals
	var multiplier = get_chain_multiplier(chain_type)
	chain_reaction_triggered.emit(chain_type, multiplier, chain_data["description"])
	chain_narrative_triggered.emit(chain_type, chain_data["narrative"])
	chain_cascade_triggered.emit([chain_type], multiplier)
	
	print("ChainReactionManager: Triggered %s - Cost: %d, Energy remaining: %d" % [chain_type, cost, chain_energy])
	
	return true

func apply_chain_effects(chain_type: String, target = null) -> Dictionary:
	"""Apply chain reaction effects"""
	var effects_applied = {}
	var chain_data = chain_reactions.get(chain_type, {})
	var effects = chain_data.get("effects", {})
	
	if not target:
		return effects_applied
	
	# Apply elemental damage
	if effects.has("elemental_damage"):
		if target.has_method("add_elemental_damage"):
			target.add_elemental_damage(effects["elemental_damage"])
		effects_applied["elemental_damage"] = effects["elemental_damage"]
		print("ChainReactionManager: Applied %.1fx elemental damage from %s" % [effects["elemental_damage"], chain_type])
	
	# Apply chain multiplier
	if effects.has("chain_multiplier"):
		if target.has_method("add_chain_multiplier"):
			target.add_chain_multiplier(effects["chain_multiplier"])
		effects_applied["chain_multiplier"] = effects["chain_multiplier"]
		print("ChainReactionManager: Applied %.1fx chain multiplier from %s" % [effects["chain_multiplier"], chain_type])
	
	# Apply area effect
	if effects.has("area_effect"):
		if target.has_method("add_area_effect"):
			target.add_area_effect(effects["area_effect"])
		effects_applied["area_effect"] = effects["area_effect"]
		print("ChainReactionManager: Applied area effect from %s" % chain_type)
	
	# Apply status application
	if effects.has("status_application"):
		if target.has_method("add_status_application"):
			target.add_status_application(effects["status_application"])
		effects_applied["status_application"] = effects["status_application"]
		print("ChainReactionManager: Applied status application from %s" % chain_type)
	
	# Apply world damage
	if effects.has("world_damage"):
		if target.has_method("add_world_damage"):
			target.add_world_damage(effects["world_damage"])
		effects_applied["world_damage"] = effects["world_damage"]
		print("ChainReactionManager: Applied %.1fx world damage from %s" % [effects["world_damage"], chain_type])
	
	# Apply reality distortion
	if effects.has("reality_distortion"):
		if target.has_method("add_reality_distortion"):
			target.add_reality_distortion(effects["reality_distortion"])
		effects_applied["reality_distortion"] = effects["reality_distortion"]
		print("ChainReactionManager: Applied reality distortion from %s" % chain_type)
	
	# Apply multiverse power
	if effects.has("multiverse_power"):
		if target.has_method("add_multiverse_power"):
			target.add_multiverse_power(effects["multiverse_power"])
		effects_applied["multiverse_power"] = effects["multiverse_power"]
		print("ChainReactionManager: Applied %.1fx multiverse power from %s" % [effects["multiverse_power"], chain_type])
	
	# Apply void corruption
	if effects.has("void_corruption"):
		if target.has_method("add_void_corruption"):
			target.add_void_corruption(effects["void_corruption"])
		effects_applied["void_corruption"] = effects["void_corruption"]
		print("ChainReactionManager: Applied %.1fx void corruption from %s" % [effects["void_corruption"], chain_type])
	
	# Apply species synergy
	if effects.has("species_synergy"):
		if target.has_method("add_species_synergy"):
			target.add_species_synergy(effects["species_synergy"])
		effects_applied["species_synergy"] = effects["species_synergy"]
		print("ChainReactionManager: Applied %.1fx species synergy from %s" % [effects["species_synergy"], chain_type])
	
	# Apply team damage
	if effects.has("team_damage"):
		if target.has_method("add_team_damage"):
			target.add_team_damage(effects["team_damage"])
		effects_applied["team_damage"] = effects["team_damage"]
		print("ChainReactionManager: Applied %.1fx team damage from %s" % [effects["team_damage"], chain_type])
	
	# Apply coordination
	if effects.has("coordination"):
		if target.has_method("add_coordination"):
			target.add_coordination(effects["coordination"])
		effects_applied["coordination"] = effects["coordination"]
		print("ChainReactionManager: Applied %.1fx coordination from %s" % [effects["coordination"], chain_type])
	
	# Apply morale bonus
	if effects.has("morale_bonus"):
		if target.has_method("add_morale_bonus"):
			target.add_morale_bonus(effects["morale_bonus"])
		effects_applied["morale_bonus"] = effects["morale_bonus"]
		print("ChainReactionManager: Applied %.1fx morale bonus from %s" % [effects["morale_bonus"], chain_type])
	
	# Apply reality cascade
	if effects.has("reality_cascade"):
		if target.has_method("add_reality_cascade"):
			target.add_reality_cascade(effects["reality_cascade"])
		effects_applied["reality_cascade"] = effects["reality_cascade"]
		print("ChainReactionManager: Applied reality cascade from %s" % chain_type)
	
	# Apply void damage
	if effects.has("void_damage"):
		if target.has_method("add_void_damage"):
			target.add_void_damage(effects["void_damage"])
		effects_applied["void_damage"] = effects["void_damage"]
		print("ChainReactionManager: Applied %.1fx void damage from %s" % [effects["void_damage"], chain_type])
	
	# Apply reality break
	if effects.has("reality_break"):
		if target.has_method("add_reality_break"):
			target.add_reality_break(effects["reality_break"])
		effects_applied["reality_break"] = effects["reality_break"]
		print("ChainReactionManager: Applied reality break from %s" % chain_type)
	
	# Apply unpredictable effects
	if effects.has("unpredictable_effects"):
		if target.has_method("add_unpredictable_effects"):
			target.add_unpredictable_effects(effects["unpredictable_effects"])
		effects_applied["unpredictable_effects"] = effects["unpredictable_effects"]
		print("ChainReactionManager: Applied unpredictable effects from %s" % chain_type)
	
	# Apply temporal damage
	if effects.has("temporal_damage"):
		if target.has_method("add_temporal_damage"):
			target.add_temporal_damage(effects["temporal_damage"])
		effects_applied["temporal_damage"] = effects["temporal_damage"]
		print("ChainReactionManager: Applied %.1fx temporal damage from %s" % [effects["temporal_damage"], chain_type])
	
	# Apply time dilation
	if effects.has("time_dilation"):
		if target.has_method("add_time_dilation"):
			target.add_time_dilation(effects["time_dilation"])
		effects_applied["time_dilation"] = effects["time_dilation"]
		print("ChainReactionManager: Applied %.1fx time dilation from %s" % [effects["time_dilation"], chain_type])
	
	# Apply temporal rewind
	if effects.has("temporal_rewind"):
		if target.has_method("add_temporal_rewind"):
			target.add_temporal_rewind(effects["temporal_rewind"])
		effects_applied["temporal_rewind"] = effects["temporal_rewind"]
		print("ChainReactionManager: Applied temporal rewind from %s" % chain_type)
	
	# Apply future sight
	if effects.has("future_sight"):
		if target.has_method("add_future_sight"):
			target.add_future_sight(effects["future_sight"])
		effects_applied["future_sight"] = effects["future_sight"]
		print("ChainReactionManager: Applied %.1fx future sight from %s" % [effects["future_sight"], chain_type])
	
	# Apply quantum damage
	if effects.has("quantum_damage"):
		if target.has_method("add_quantum_damage"):
			target.add_quantum_damage(effects["quantum_damage"])
		effects_applied["quantum_damage"] = effects["quantum_damage"]
		print("ChainReactionManager: Applied %.1fx quantum damage from %s" % [effects["quantum_damage"], chain_type])
	
	# Apply probability manipulation
	if effects.has("probability_manipulation"):
		if target.has_method("add_probability_manipulation"):
			target.add_probability_manipulation(effects["probability_manipulation"])
		effects_applied["probability_manipulation"] = effects["probability_manipulation"]
		print("ChainReactionManager: Applied probability manipulation from %s" % chain_type)
	
	# Apply reality shift
	if effects.has("reality_shift"):
		if target.has_method("add_reality_shift"):
			target.add_reality_shift(effects["reality_shift"])
		effects_applied["reality_shift"] = effects["reality_shift"]
		print("ChainReactionManager: Applied %.1fx reality shift from %s" % [effects["reality_shift"], chain_type])
	
	# Apply quantum entanglement
	if effects.has("quantum_entanglement"):
		if target.has_method("add_quantum_entanglement"):
			target.add_quantum_entanglement(effects["quantum_entanglement"])
		effects_applied["quantum_entanglement"] = effects["quantum_entanglement"]
		print("ChainReactionManager: Applied %.1fx quantum entanglement from %s" % [effects["quantum_entanglement"], chain_type])
	
	# Apply dimensional damage
	if effects.has("dimensional_damage"):
		if target.has_method("add_dimensional_damage"):
			target.add_dimensional_damage(effects["dimensional_damage"])
		effects_applied["dimensional_damage"] = effects["dimensional_damage"]
		print("ChainReactionManager: Applied %.1fx dimensional damage from %s" % [effects["dimensional_damage"], chain_type])
	
	# Apply dimension shift
	if effects.has("dimension_shift"):
		if target.has_method("add_dimension_shift"):
			target.add_dimension_shift(effects["dimension_shift"])
		effects_applied["dimension_shift"] = effects["dimension_shift"]
		print("ChainReactionManager: Applied dimension shift from %s" % chain_type)
	
	# Apply reality merge
	if effects.has("reality_merge"):
		if target.has_method("add_reality_merge"):
			target.add_reality_merge(effects["reality_merge"])
		effects_applied["reality_merge"] = effects["reality_merge"]
		print("ChainReactionManager: Applied %.1fx reality merge from %s" % [effects["reality_merge"], chain_type])
	
	# Apply ultimate damage
	if effects.has("ultimate_damage"):
		if target.has_method("add_ultimate_damage"):
			target.add_ultimate_damage(effects["ultimate_damage"])
		effects_applied["ultimate_damage"] = effects["ultimate_damage"]
		print("ChainReactionManager: Applied %.1fx ultimate damage from %s" % [effects["ultimate_damage"], chain_type])
	
	# Apply all enhancements
	if effects.has("all_enhancements"):
		if target.has_method("add_all_enhancements"):
			target.add_all_enhancements(effects["all_enhancements"])
		effects_applied["all_enhancements"] = effects["all_enhancements"]
		print("ChainReactionManager: Applied all enhancements from %s" % chain_type)
	
	# Apply reality transcendence
	if effects.has("reality_transcendence"):
		if target.has_method("add_reality_transcendence"):
			target.add_reality_transcendence(effects["reality_transcendence"])
		effects_applied["reality_transcendence"] = effects["reality_transcendence"]
		print("ChainReactionManager: Applied reality transcendence from %s" % chain_type)
	
	# Apply multiverse harmony
	if effects.has("multiverse_harmony"):
		if target.has_method("add_multiverse_harmony"):
			target.add_multiverse_harmony(effects["multiverse_harmony"])
		effects_applied["multiverse_harmony"] = effects["multiverse_harmony"]
		print("ChainReactionManager: Applied %.1fx multiverse harmony from %s" % [effects["multiverse_harmony"], chain_type])
	
	return effects_applied

func get_chain_multiplier(chain_type: String) -> float:
	"""Get damage multiplier for a chain reaction"""
	var chain_data = chain_reactions.get(chain_type, {})
	
	# Check if chain_data has an "effects" key
	if chain_data.has("effects"):
		# Return the first multiplier found in the effects
		for key in chain_data["effects"].keys():
			if key is String and "damage" in key.to_lower():
				return chain_data["effects"][key]
	else:
		# Check direct keys for damage multipliers
		for key in chain_data.keys():
			if key is String and "damage" in key.to_lower():
				return chain_data[key]
	
	return 1.0

func get_chain_reaction_data(chain_type: String) -> Dictionary:
	"""Get data for a specific chain reaction"""
	return chain_reactions.get(chain_type, {})

func get_available_chain_reactions() -> Array:
	"""Get all available chain reactions"""
	var available = []
	
	for chain_type in chain_reactions.keys():
		var chain_data = chain_reactions[chain_type]
		var cost = chain_data.get("cost", 50)
		var can_afford = chain_energy >= cost
		
		available.append({
			"chain_type": chain_type,
			"cost": cost,
			"description": chain_data["description"],
			"narrative": chain_data["narrative"],
			"can_afford": can_afford
		})
	
	return available

func get_chain_narrative(chain_type: String) -> String:
	"""Get narrative description for a chain reaction"""
	var chain_data = chain_reactions.get(chain_type, {})
	return chain_data.get("narrative", "")

func get_chain_energy() -> int:
	"""Get current chain energy"""
	return chain_energy

func add_chain_energy(amount: int):
	"""Add chain energy"""
	chain_energy = min(chain_energy + amount, max_chain_energy)
	print("ChainReactionManager: Added %d chain energy, total: %d" % [amount, chain_energy])

func reset_chain_energy_for_testing():
	"""Reset chain energy to maximum for testing purposes"""
	chain_energy = max_chain_energy
	print("ChainReactionManager: Reset chain energy to %d for testing" % chain_energy)

func get_cooldown_turns(chain_type: String) -> int:
	"""Get cooldown turns for a chain reaction"""
	var cooldowns = {
		"elemental_chain": 3,
		"world_chain": 5,
		"species_chain": 4,
		"void_chain": 6,
		"time_chain": 4,
		"quantum_chain": 5,
		"dimensional_chain": 6,
		"ultimate_chain": 8
	}
	
	return cooldowns.get(chain_type, 1)

func get_current_turn() -> int:
	"""Get current turn number (placeholder)"""
	# In a real implementation, this would get the current turn from CombatManager
	return 1

func clear_chain_reactions():
	"""Clear all active chain reactions"""
	active_chains.clear()
	print("ChainReactionManager: All chain reactions cleared")

func get_chain_statistics() -> Dictionary:
	"""Get chain reaction system statistics"""
	return {
		"chain_energy": chain_energy,
		"max_chain_energy": max_chain_energy,
		"active_chains": active_chains.size(),
		"total_chains": chain_reactions.size(),
		"history_entries": chain_history.size(),
		"cooldowns_active": chain_cooldowns.size()
	} 
