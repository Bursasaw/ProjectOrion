extends Node
class_name QuantumManager

# Quantum Manager - Handles quantum superposition mechanics in combat
# Manages superposition, quantum entanglement, wave function collapse, and quantum tunneling

signal quantum_state_triggered(state: String, probability: float, description: String)
signal quantum_narrative_triggered(state: String, narrative: String)
signal quantum_collapse_triggered(old_state: String, new_state: String, effects: Dictionary)

# Quantum superposition mechanics
var quantum_states = {
	"superposition": {
		"multiple_actions": true,
		"probability": 0.7,
		"description": "Multiple actions exist simultaneously",
		"narrative": "You exist in a state of quantum superposition, where multiple possible actions occur simultaneously. Reality itself becomes uncertain as you perform multiple actions at once, each with its own probability of success.",
		"effects": {
			"action_multiplier": 2.0,
			"accuracy": 0.8,
			"critical_chance": 1.4,
			"damage_variance": 1.3
		}
	},
	"quantum_entanglement": {
		"team_synergy": 2.0,
		"description": "Quantum-linked actions",
		"narrative": "Your consciousness becomes quantum-entangled with your allies, creating a shared mental state. Your actions are perfectly synchronized, amplifying each other's abilities through quantum resonance.",
		"effects": {
			"team_damage": 2.0,
			"coordination": 1.5,
			"shared_effects": true,
			"synergy_bonus": 1.8
		}
	},
	"wave_function_collapse": {
		"reality_shift": true,
		"description": "Reality itself shifts",
		"narrative": "The quantum wave function collapses, causing reality itself to shift and change. The battlefield transforms as probabilities collapse into certainty, creating new possibilities and altering the very fabric of existence.",
		"effects": {
			"reality_shift": true,
			"random_effects": true,
			"damage_multiplier": 1.6,
			"status_application": true
		}
	},
	"quantum_tunneling": {
		"bypass_defenses": true,
		"description": "Attack bypasses all defenses",
		"narrative": "Your attack exists in a quantum state that allows it to tunnel through all defenses. Like a particle passing through an impenetrable barrier, your strike ignores armor, shields, and magical protections.",
		"effects": {
			"defense_ignore": true,
			"armor_penetration": 1.0,
			"magic_penetration": 1.0,
			"accuracy": 1.2
		}
	},
	"quantum_uncertainty": {
		"probability_manipulation": true,
		"description": "Manipulate probability itself",
		"narrative": "You manipulate the fundamental uncertainty of quantum mechanics, bending probability to your will. Critical hits become more likely, dodges more frequent, and the impossible becomes merely improbable.",
		"effects": {
			"critical_chance": 1.8,
			"dodge_chance": 1.6,
			"luck_bonus": 1.5,
			"probability_shift": true
		}
	},
	"quantum_coherence": {
		"state_preservation": true,
		"description": "Maintain quantum coherence",
		"narrative": "You maintain perfect quantum coherence, preserving your quantum state across multiple actions. Your abilities remain amplified and your quantum effects persist longer than normal.",
		"effects": {
			"effect_duration": 2.0,
			"state_preservation": true,
			"amplification": 1.4,
			"resistance": 1.3
		}
	},
	"quantum_decoherence": {
		"enemy_disruption": true,
		"description": "Disrupt enemy quantum states",
		"narrative": "You force quantum decoherence upon your enemies, disrupting their quantum states and causing their abilities to fail. Their attacks become uncertain and their defenses collapse into classical reality.",
		"effects": {
			"enemy_disruption": true,
			"accuracy_reduction": 0.6,
			"defense_reduction": 0.7,
			"status_application": true
		}
	},
	"quantum_superposition_field": {
		"area_effect": true,
		"description": "Create quantum field",
		"narrative": "You create a field of quantum superposition that affects the entire battlefield. All combatants exist in multiple states simultaneously, creating a chaotic but predictable pattern of quantum effects.",
		"effects": {
			"area_effect": true,
			"quantum_field": true,
			"random_effects": true,
			"damage_multiplier": 1.3
		}
	}
}

# Active quantum states
var active_quantum_states: Dictionary = {}
var quantum_energy: int = 100
var max_quantum_energy: int = 100
var quantum_history: Array = []

# Quantum state cooldowns
var quantum_cooldowns: Dictionary = {}

func trigger_quantum_state(state: String, target = null) -> bool:
	"""Trigger a quantum state"""
	if not quantum_states.has(state):
		print("QuantumManager: Invalid quantum state: %s" % state)
		return false
	
	var state_data = quantum_states[state]
	var cost = state_data.get("cost", 30)
	
	# Check if we have enough quantum energy
	if quantum_energy < cost:
		print("QuantumManager: Insufficient quantum energy - need %d, have %d" % [cost, quantum_energy])
		return false
	
	# Check cooldown
	if quantum_cooldowns.has(state):
		var last_used = quantum_cooldowns[state]
		var current_turn = get_current_turn()
		if current_turn - last_used < get_cooldown_turns(state):
			print("QuantumManager: Quantum state %s on cooldown" % state)
			return false
	
	# Apply quantum energy cost
	quantum_energy -= cost
	
	# Apply effects based on quantum state
	var effects_applied = apply_quantum_effects(state, target)
	
	# Set cooldown
	quantum_cooldowns[state] = get_current_turn()
	
	# Add to history
	quantum_history.append({
		"turn": get_current_turn(),
		"state": state,
		"cost": cost,
		"target": target.character_name if target else "none",
		"description": state_data["description"],
		"narrative": state_data["narrative"]
	})
	
	# Emit signals
	quantum_state_triggered.emit(state, state_data.get("probability", 0.5), state_data["description"])
	quantum_narrative_triggered.emit(state, state_data["narrative"])
	quantum_collapse_triggered.emit("normal", state, effects_applied)
	
	print("QuantumManager: Triggered %s - Cost: %d, Energy remaining: %d" % [state, cost, quantum_energy])
	
	return true

func apply_quantum_effects(state: String, target = null) -> Dictionary:
	"""Apply quantum state effects"""
	var effects_applied = {}
	var state_data = quantum_states.get(state, {})
	var effects = state_data.get("effects", {})
	
	if not target:
		return effects_applied
	
	# Apply action multiplier
	if effects.has("action_multiplier"):
		if target.has_method("add_action_multiplier"):
			target.add_action_multiplier(effects["action_multiplier"])
		effects_applied["action_multiplier"] = effects["action_multiplier"]
		print("QuantumManager: Applied %.1fx action multiplier from %s" % [effects["action_multiplier"], state])
	
	# Apply accuracy bonus/penalty
	if effects.has("accuracy"):
		if target.has_method("add_accuracy_bonus"):
			target.add_accuracy_bonus(effects["accuracy"])
		effects_applied["accuracy"] = effects["accuracy"]
		print("QuantumManager: Applied %.1fx accuracy bonus from %s" % [effects["accuracy"], state])
	
	# Apply critical chance bonus
	if effects.has("critical_chance"):
		if target.has_method("add_critical_chance_bonus"):
			target.add_critical_chance_bonus(effects["critical_chance"])
		effects_applied["critical_chance"] = effects["critical_chance"]
		print("QuantumManager: Applied %.1fx critical chance bonus from %s" % [effects["critical_chance"], state])
	
	# Apply damage variance
	if effects.has("damage_variance"):
		if target.has_method("add_damage_variance"):
			target.add_damage_variance(effects["damage_variance"])
		effects_applied["damage_variance"] = effects["damage_variance"]
		print("QuantumManager: Applied %.1fx damage variance from %s" % [effects["damage_variance"], state])
	
	# Apply team damage bonus
	if effects.has("team_damage"):
		if target.has_method("add_team_damage_bonus"):
			target.add_team_damage_bonus(effects["team_damage"])
		effects_applied["team_damage"] = effects["team_damage"]
		print("QuantumManager: Applied %.1fx team damage bonus from %s" % [effects["team_damage"], state])
	
	# Apply coordination bonus
	if effects.has("coordination"):
		if target.has_method("add_coordination_bonus"):
			target.add_coordination_bonus(effects["coordination"])
		effects_applied["coordination"] = effects["coordination"]
		print("QuantumManager: Applied %.1fx coordination bonus from %s" % [effects["coordination"], state])
	
	# Apply shared effects
	if effects.has("shared_effects"):
		if target.has_method("add_shared_effects"):
			target.add_shared_effects(effects["shared_effects"])
		effects_applied["shared_effects"] = effects["shared_effects"]
		print("QuantumManager: Applied shared effects from %s" % state)
	
	# Apply synergy bonus
	if effects.has("synergy_bonus"):
		if target.has_method("add_synergy_bonus"):
			target.add_synergy_bonus(effects["synergy_bonus"])
		effects_applied["synergy_bonus"] = effects["synergy_bonus"]
		print("QuantumManager: Applied %.1fx synergy bonus from %s" % [effects["synergy_bonus"], state])
	
	# Apply reality shift
	if effects.has("reality_shift"):
		if target.has_method("add_reality_shift"):
			target.add_reality_shift(effects["reality_shift"])
		effects_applied["reality_shift"] = effects["reality_shift"]
		print("QuantumManager: Applied reality shift from %s" % state)
	
	# Apply random effects
	if effects.has("random_effects"):
		if target.has_method("add_random_effects"):
			target.add_random_effects(effects["random_effects"])
		effects_applied["random_effects"] = effects["random_effects"]
		print("QuantumManager: Applied random effects from %s" % state)
	
	# Apply damage multiplier
	if effects.has("damage_multiplier"):
		if target.has_method("add_damage_multiplier"):
			target.add_damage_multiplier(effects["damage_multiplier"])
		effects_applied["damage_multiplier"] = effects["damage_multiplier"]
		print("QuantumManager: Applied %.1fx damage multiplier from %s" % [effects["damage_multiplier"], state])
	
	# Apply status application
	if effects.has("status_application"):
		if target.has_method("add_status_application"):
			target.add_status_application(effects["status_application"])
		effects_applied["status_application"] = effects["status_application"]
		print("QuantumManager: Applied status application from %s" % state)
	
	# Apply defense ignore
	if effects.has("defense_ignore"):
		if target.has_method("add_defense_ignore"):
			target.add_defense_ignore(effects["defense_ignore"])
		effects_applied["defense_ignore"] = effects["defense_ignore"]
		print("QuantumManager: Applied defense ignore from %s" % state)
	
	# Apply armor penetration
	if effects.has("armor_penetration"):
		if target.has_method("add_armor_penetration"):
			target.add_armor_penetration(effects["armor_penetration"])
		effects_applied["armor_penetration"] = effects["armor_penetration"]
		print("QuantumManager: Applied %.1fx armor penetration from %s" % [effects["armor_penetration"], state])
	
	# Apply magic penetration
	if effects.has("magic_penetration"):
		if target.has_method("add_magic_penetration"):
			target.add_magic_penetration(effects["magic_penetration"])
		effects_applied["magic_penetration"] = effects["magic_penetration"]
		print("QuantumManager: Applied %.1fx magic penetration from %s" % [effects["magic_penetration"], state])
	
	# Apply dodge chance bonus
	if effects.has("dodge_chance"):
		if target.has_method("add_dodge_chance_bonus"):
			target.add_dodge_chance_bonus(effects["dodge_chance"])
		effects_applied["dodge_chance"] = effects["dodge_chance"]
		print("QuantumManager: Applied %.1fx dodge chance bonus from %s" % [effects["dodge_chance"], state])
	
	# Apply luck bonus
	if effects.has("luck_bonus"):
		if target.has_method("add_luck_bonus"):
			target.add_luck_bonus(effects["luck_bonus"])
		effects_applied["luck_bonus"] = effects["luck_bonus"]
		print("QuantumManager: Applied %.1fx luck bonus from %s" % [effects["luck_bonus"], state])
	
	# Apply probability shift
	if effects.has("probability_shift"):
		if target.has_method("add_probability_shift"):
			target.add_probability_shift(effects["probability_shift"])
		effects_applied["probability_shift"] = effects["probability_shift"]
		print("QuantumManager: Applied probability shift from %s" % state)
	
	# Apply effect duration
	if effects.has("effect_duration"):
		if target.has_method("add_effect_duration"):
			target.add_effect_duration(effects["effect_duration"])
		effects_applied["effect_duration"] = effects["effect_duration"]
		print("QuantumManager: Applied %.1fx effect duration from %s" % [effects["effect_duration"], state])
	
	# Apply state preservation
	if effects.has("state_preservation"):
		if target.has_method("add_state_preservation"):
			target.add_state_preservation(effects["state_preservation"])
		effects_applied["state_preservation"] = effects["state_preservation"]
		print("QuantumManager: Applied state preservation from %s" % state)
	
	# Apply amplification
	if effects.has("amplification"):
		if target.has_method("add_amplification"):
			target.add_amplification(effects["amplification"])
		effects_applied["amplification"] = effects["amplification"]
		print("QuantumManager: Applied %.1fx amplification from %s" % [effects["amplification"], state])
	
	# Apply resistance
	if effects.has("resistance"):
		if target.has_method("add_resistance"):
			target.add_resistance(effects["resistance"])
		effects_applied["resistance"] = effects["resistance"]
		print("QuantumManager: Applied %.1fx resistance from %s" % [effects["resistance"], state])
	
	# Apply enemy disruption
	if effects.has("enemy_disruption"):
		if target.has_method("add_enemy_disruption"):
			target.add_enemy_disruption(effects["enemy_disruption"])
		effects_applied["enemy_disruption"] = effects["enemy_disruption"]
		print("QuantumManager: Applied enemy disruption from %s" % state)
	
	# Apply accuracy reduction
	if effects.has("accuracy_reduction"):
		if target.has_method("add_accuracy_reduction"):
			target.add_accuracy_reduction(effects["accuracy_reduction"])
		effects_applied["accuracy_reduction"] = effects["accuracy_reduction"]
		print("QuantumManager: Applied %.1fx accuracy reduction from %s" % [effects["accuracy_reduction"], state])
	
	# Apply defense reduction
	if effects.has("defense_reduction"):
		if target.has_method("add_defense_reduction"):
			target.add_defense_reduction(effects["defense_reduction"])
		effects_applied["defense_reduction"] = effects["defense_reduction"]
		print("QuantumManager: Applied %.1fx defense reduction from %s" % [effects["defense_reduction"], state])
	
	# Apply area effect
	if effects.has("area_effect"):
		if target.has_method("add_area_effect"):
			target.add_area_effect(effects["area_effect"])
		effects_applied["area_effect"] = effects["area_effect"]
		print("QuantumManager: Applied area effect from %s" % state)
	
	# Apply quantum field
	if effects.has("quantum_field"):
		if target.has_method("add_quantum_field"):
			target.add_quantum_field(effects["quantum_field"])
		effects_applied["quantum_field"] = effects["quantum_field"]
		print("QuantumManager: Applied quantum field from %s" % state)
	
	return effects_applied

func get_quantum_state_data(state: String) -> Dictionary:
	"""Get data for a specific quantum state"""
	return quantum_states.get(state, {})

func get_available_quantum_states() -> Array:
	"""Get all available quantum states"""
	var available = []
	
	for state in quantum_states.keys():
		var state_data = quantum_states[state]
		var cost = state_data.get("cost", 30)
		var can_afford = quantum_energy >= cost
		
		available.append({
			"state": state,
			"cost": cost,
			"description": state_data["description"],
			"narrative": state_data["narrative"],
			"can_afford": can_afford
		})
	
	return available

func get_quantum_narrative(state: String) -> String:
	"""Get narrative description for a quantum state"""
	var state_data = quantum_states.get(state, {})
	return state_data.get("narrative", "")

func get_quantum_energy() -> int:
	"""Get current quantum energy"""
	return quantum_energy

func add_quantum_energy(amount: int):
	"""Add quantum energy"""
	quantum_energy = min(quantum_energy + amount, max_quantum_energy)
	print("QuantumManager: Added %d quantum energy, total: %d" % [amount, quantum_energy])

func get_cooldown_turns(state: String) -> int:
	"""Get cooldown turns for a quantum state"""
	var cooldowns = {
		"superposition": 2,
		"quantum_entanglement": 4,
		"wave_function_collapse": 6,
		"quantum_tunneling": 3,
		"quantum_uncertainty": 3,
		"quantum_coherence": 2,
		"quantum_decoherence": 4,
		"quantum_superposition_field": 5
	}
	
	return cooldowns.get(state, 1)

func get_current_turn() -> int:
	"""Get current turn number (placeholder)"""
	# In a real implementation, this would get the current turn from CombatManager
	return 1

func clear_quantum_states():
	"""Clear all active quantum states"""
	active_quantum_states.clear()
	print("QuantumManager: All quantum states cleared")

func get_quantum_statistics() -> Dictionary:
	"""Get quantum system statistics"""
	return {
		"quantum_energy": quantum_energy,
		"max_quantum_energy": max_quantum_energy,
		"active_states": active_quantum_states.size(),
		"total_states": quantum_states.size(),
		"history_entries": quantum_history.size(),
		"cooldowns_active": quantum_cooldowns.size()
	} 