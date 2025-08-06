extends Node
class_name EmotionalStateManager

# Emotional State Manager - Handles emotional states affecting combat
# Manages emotional states, their effects, and narrative integration

signal emotional_state_changed(actor, old_state: String, new_state: String, description: String)
signal emotional_effect_applied(actor, state: String, effect: String, description: String)
signal emotional_narrative_triggered(actor, state: String, narrative: String)

# Emotional states and their properties
var emotional_states = {
	"determined": {
		"attack": 1.2,
		"defense": 1.1,
		"description": "Filled with resolve",
		"narrative": "Your determination fuels your strength, making every strike count",
		"world_bonus": {
			"aelria": 1.3,
			"elysion": 1.2,
			"sylithar": 1.1,
			"krynn": 1.2,
			"terra": 1.1,
			"aethra": 1.1,
			"ombra": 1.2,
			"nokturn": 1.1,
			"tauron": 1.0
		}
	},
	"fearful": {
		"speed": 1.3,
		"defense": 0.8,
		"description": "Driven by fear",
		"narrative": "Fear sharpens your reflexes, but weakens your resolve",
		"world_bonus": {
			"nokturn": 1.4,
			"ombra": 1.3,
			"aelria": 1.2,
			"elysion": 1.1,
			"sylithar": 1.1,
			"krynn": 1.0,
			"terra": 1.0,
			"aethra": 1.1,
			"tauron": 0.9
		}
	},
	"angry": {
		"attack": 1.4,
		"magic_defense": 0.7,
		"description": "Consumed by rage",
		"narrative": "Rage flows through your veins, amplifying your attacks but clouding your magical defenses",
		"world_bonus": {
			"krynn": 1.6,
			"aelria": 1.5,
			"elysion": 1.3,
			"sylithar": 1.2,
			"terra": 1.3,
			"aethra": 1.2,
			"ombra": 1.4,
			"nokturn": 1.3,
			"tauron": 1.1
		}
	},
	"calm": {
		"magic_attack": 1.3,
		"accuracy": 1.2,
		"description": "Centered and focused",
		"narrative": "Inner peace enhances your magical abilities and precision",
		"world_bonus": {
			"elysion": 1.5,
			"sylithar": 1.4,
			"aelria": 1.3,
			"krynn": 1.2,
			"terra": 1.2,
			"aethra": 1.3,
			"ombra": 1.2,
			"nokturn": 1.1,
			"tauron": 1.1
		}
	},
	"desperate": {
		"critical_chance": 1.5,
		"defense": 0.6,
		"description": "Fighting for survival",
		"narrative": "Desperation drives you to take risks, increasing critical hits but leaving you vulnerable",
		"world_bonus": {
			"aelria": 1.7,
			"ombra": 1.6,
			"elysion": 1.4,
			"sylithar": 1.3,
			"krynn": 1.4,
			"terra": 1.3,
			"aethra": 1.3,
			"nokturn": 1.4,
			"tauron": 1.2
		}
	},
	"confident": {
		"attack": 1.1,
		"magic_attack": 1.1,
		"accuracy": 1.1,
		"description": "Self-assured and composed",
		"narrative": "Confidence flows through you, enhancing all your abilities slightly",
		"world_bonus": {
			"aelria": 1.2,
			"elysion": 1.2,
			"sylithar": 1.1,
			"krynn": 1.1,
			"terra": 1.1,
			"aethra": 1.1,
			"ombra": 1.2,
			"nokturn": 1.1,
			"tauron": 1.0
		}
	},
	"focused": {
		"accuracy": 1.4,
		"magic_attack": 1.2,
		"description": "Intensely focused on the task",
		"narrative": "Your focus is razor-sharp, making every action precise and magical",
		"world_bonus": {
			"sylithar": 1.5,
			"elysion": 1.4,
			"aelria": 1.3,
			"krynn": 1.2,
			"terra": 1.2,
			"aethra": 1.3,
			"ombra": 1.3,
			"nokturn": 1.2,
			"tauron": 1.1
		}
	},
	"reckless": {
		"attack": 1.5,
		"defense": 0.5,
		"speed": 1.2,
		"description": "Throwing caution to the wind",
		"narrative": "Recklessness amplifies your attacks but leaves you dangerously exposed",
		"world_bonus": {
			"krynn": 1.7,
			"aelria": 1.6,
			"elysion": 1.4,
			"sylithar": 1.3,
			"terra": 1.4,
			"aethra": 1.3,
			"ombra": 1.5,
			"nokturn": 1.4,
			"tauron": 1.2
		}
	},
	"serene": {
		"magic_attack": 1.4,
		"magic_defense": 1.3,
		"healing": 1.2,
		"description": "At peace with the world",
		"narrative": "Serenity enhances your magical abilities and healing powers",
		"world_bonus": {
			"elysion": 1.6,
			"sylithar": 1.5,
			"aelria": 1.4,
			"krynn": 1.3,
			"terra": 1.3,
			"aethra": 1.4,
			"ombra": 1.3,
			"nokturn": 1.2,
			"tauron": 1.1
		}
	}
}

# Active emotional states for actors
var active_emotional_states: Dictionary = {}

# Emotional state history
var emotional_history: Array = []

# Emotional state transitions
var emotional_transitions = {
	"determined": ["confident", "focused", "angry"],
	"fearful": ["desperate", "calm", "determined"],
	"angry": ["reckless", "determined", "calm"],
	"calm": ["serene", "focused", "confident"],
	"desperate": ["determined", "reckless", "fearful"],
	"confident": ["determined", "focused", "serene"],
	"focused": ["calm", "serene", "confident"],
	"reckless": ["angry", "desperate", "determined"],
	"serene": ["calm", "confident", "focused"]
}

func set_emotional_state(actor, state: String, world: String = "") -> bool:
	"""Set emotional state for an actor"""
	if not emotional_states.has(state):
		print("EmotionalStateManager: Invalid emotional state: %s" % state)
		return false
	
	var old_state = get_emotional_state(actor)
	var state_data = emotional_states[state].duplicate()
	
	# Apply world bonus if available
	if world != "" and state_data.has("world_bonus") and state_data["world_bonus"].has(world):
		var world_bonus = state_data["world_bonus"][world]
		for key in state_data:
			if key != "description" and key != "narrative" and key != "world_bonus":
				if state_data[key] is float or state_data[key] is int:
					state_data[key] *= world_bonus
		print("EmotionalStateManager: Applied %s world bonus to %s state" % [world, state])
	
	# Store actor's emotional state
	var actor_id = get_actor_id(actor)
	active_emotional_states[actor_id] = {
		"state": state,
		"data": state_data,
		"world": world
	}
	
	var description = "Changed to %s state" % state
	if world != "":
		description += " (enhanced by %s)" % world
	
	print("EmotionalStateManager: %s - %s" % [actor_id, description])
	emotional_state_changed.emit(actor, old_state, state, description)
	
	# Add to history
	emotional_history.append({
		"turn": get_current_turn(),
		"actor": actor_id,
		"old_state": old_state,
		"new_state": state,
		"world": world,
		"description": description
	})
	
	return true

func get_emotional_state(actor) -> String:
	"""Get current emotional state for an actor"""
	var actor_id = get_actor_id(actor)
	if active_emotional_states.has(actor_id):
		return active_emotional_states[actor_id]["state"]
	return "neutral"

func get_emotional_effects(actor) -> Dictionary:
	"""Get emotional effects for an actor"""
	var actor_id = get_actor_id(actor)
	if active_emotional_states.has(actor_id):
		return active_emotional_states[actor_id]["data"]
	return {}

func apply_emotional_effects_to_actor(actor) -> Dictionary:
	"""Apply emotional effects to an actor"""
	var effects_applied = {}
	var emotional_data = get_emotional_effects(actor)
	
	if emotional_data.size() == 0:
		return effects_applied
	
	# Apply attack bonus
	if emotional_data.has("attack"):
		if actor.has_method("add_attack_bonus"):
			actor.add_attack_bonus(emotional_data["attack"])
		effects_applied["attack"] = emotional_data["attack"]
		print("EmotionalStateManager: Applied %.1fx attack bonus from %s state" % [emotional_data["attack"], get_emotional_state(actor)])
	
	# Apply defense bonus
	if emotional_data.has("defense"):
		if actor.has_method("add_defense_bonus"):
			actor.add_defense_bonus(emotional_data["defense"])
		effects_applied["defense"] = emotional_data["defense"]
		print("EmotionalStateManager: Applied %.1fx defense bonus from %s state" % [emotional_data["defense"], get_emotional_state(actor)])
	
	# Apply magic attack bonus
	if emotional_data.has("magic_attack"):
		if actor.has_method("add_magic_attack_bonus"):
			actor.add_magic_attack_bonus(emotional_data["magic_attack"])
		effects_applied["magic_attack"] = emotional_data["magic_attack"]
		print("EmotionalStateManager: Applied %.1fx magic attack bonus from %s state" % [emotional_data["magic_attack"], get_emotional_state(actor)])
	
	# Apply magic defense bonus
	if emotional_data.has("magic_defense"):
		if actor.has_method("add_magic_defense_bonus"):
			actor.add_magic_defense_bonus(emotional_data["magic_defense"])
		effects_applied["magic_defense"] = emotional_data["magic_defense"]
		print("EmotionalStateManager: Applied %.1fx magic defense bonus from %s state" % [emotional_data["magic_defense"], get_emotional_state(actor)])
	
	# Apply speed bonus
	if emotional_data.has("speed"):
		if actor.has_method("add_speed_bonus"):
			actor.add_speed_bonus(emotional_data["speed"])
		effects_applied["speed"] = emotional_data["speed"]
		print("EmotionalStateManager: Applied %.1fx speed bonus from %s state" % [emotional_data["speed"], get_emotional_state(actor)])
	
	# Apply accuracy bonus
	if emotional_data.has("accuracy"):
		if actor.has_method("add_accuracy_bonus"):
			actor.add_accuracy_bonus(emotional_data["accuracy"])
		effects_applied["accuracy"] = emotional_data["accuracy"]
		print("EmotionalStateManager: Applied %.1fx accuracy bonus from %s state" % [emotional_data["accuracy"], get_emotional_state(actor)])
	
	# Apply critical chance bonus
	if emotional_data.has("critical_chance"):
		if actor.has_method("add_critical_chance_bonus"):
			actor.add_critical_chance_bonus(emotional_data["critical_chance"])
		effects_applied["critical_chance"] = emotional_data["critical_chance"]
		print("EmotionalStateManager: Applied %.1fx critical chance bonus from %s state" % [emotional_data["critical_chance"], get_emotional_state(actor)])
	
	# Apply healing bonus
	if emotional_data.has("healing"):
		if actor.has_method("add_healing_bonus"):
			actor.add_healing_bonus(emotional_data["healing"])
		effects_applied["healing"] = emotional_data["healing"]
		print("EmotionalStateManager: Applied %.1fx healing bonus from %s state" % [emotional_data["healing"], get_emotional_state(actor)])
	
	# Emit effect applied signal
	if effects_applied.size() > 0:
		emotional_effect_applied.emit(actor, get_emotional_state(actor), str(effects_applied), emotional_data.get("description", ""))
	
	return effects_applied

func get_emotional_narrative(actor) -> String:
	"""Get narrative description of actor's emotional state"""
	var emotional_data = get_emotional_effects(actor)
	
	if emotional_data.has("narrative"):
		var narrative = emotional_data["narrative"]
		var actor_id = get_actor_id(actor)
		var world = ""
		
		if active_emotional_states.has(actor_id):
			world = active_emotional_states[actor_id]["world"]
		
		if world != "":
			narrative += " The energy of %s amplifies your emotional state." % world
		
		emotional_narrative_triggered.emit(actor, get_emotional_state(actor), narrative)
		return narrative
	
	return "No emotional state"

func get_available_transitions(actor) -> Array:
	"""Get available emotional state transitions for an actor"""
	var current_state = get_emotional_state(actor)
	var available = []
	
	if emotional_transitions.has(current_state):
		for transition_state in emotional_transitions[current_state]:
			available.append({
				"state": transition_state,
				"description": emotional_states[transition_state]["description"],
				"narrative": emotional_states[transition_state]["narrative"]
			})
	
	return available

func trigger_emotional_transition(actor, new_state: String, world: String = "") -> bool:
	"""Trigger an emotional state transition"""
	var available_transitions = get_available_transitions(actor)
	
	for transition in available_transitions:
		if transition["state"] == new_state:
			return set_emotional_state(actor, new_state, world)
	
	print("EmotionalStateManager: Invalid transition to %s from current state" % new_state)
	return false

func get_actor_id(actor) -> String:
	"""Get unique identifier for an actor"""
	if actor.has_method("get_character_name"):
		return actor.get_character_name()
	elif actor.has_method("get_name"):
		return actor.get_name()
	else:
		return str(actor)

func get_current_turn() -> int:
	"""Get current turn number (placeholder)"""
	# In a real implementation, this would get the current turn from CombatManager
	return 1

func clear_emotional_state(actor):
	"""Clear emotional state for an actor"""
	var actor_id = get_actor_id(actor)
	if active_emotional_states.has(actor_id):
		var old_state = active_emotional_states[actor_id]["state"]
		active_emotional_states.erase(actor_id)
		print("EmotionalStateManager: Cleared emotional state for %s" % actor_id)
		emotional_state_changed.emit(actor, old_state, "neutral", "Emotional state cleared")

func get_emotional_statistics() -> Dictionary:
	"""Get emotional state system statistics"""
	return {
		"active_states": active_emotional_states.size(),
		"total_states": emotional_states.size(),
		"history_entries": emotional_history.size(),
		"available_transitions": emotional_transitions.size()
	} 