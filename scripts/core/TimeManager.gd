extends Node
class_name TimeManager

# Time Manager - Handles time manipulation mechanics in combat
# Manages time dilation, temporal rewind, future sight, and time freeze abilities

signal time_manipulation_triggered(mechanic: String, cost: int, description: String)
signal time_narrative_triggered(mechanic: String, narrative: String)
signal time_state_changed(old_state: String, new_state: String, duration: int)

# Time state tracking
var current_time_state: String = "normal"
var previous_time_state: String = "normal"

# Time manipulation mechanics
var time_mechanics = {
	"time_dilation": {
		"action_speed": 2.0,
		"duration": 3,
		"cost": 50,
		"description": "Time slows around you",
		"narrative": "The fabric of time itself bends to your will. Seconds stretch into minutes as you move with impossible speed, your actions accelerated while the world around you crawls at a snail's pace.",
		"effects": {
			"action_speed": 2.0,
			"dodge": 1.5,
			"accuracy": 1.3,
			"critical_chance": 1.2
		}
	},
	"temporal_rewind": {
		"undo_last_action": true,
		"cost": 100,
		"description": "Reverse the flow of time",
		"narrative": "Time flows backward as you reach into the past, undoing your last action. The battlefield rewinds like a broken clock, giving you a second chance at your previous decision.",
		"effects": {
			"undo_action": true,
			"health_restore": 0.5,
			"status_clear": true,
			"position_reset": true
		}
	},
	"future_sight": {
		"see_enemy_actions": true,
		"duration": 2,
		"cost": 30,
		"description": "Peer into possible futures",
		"narrative": "Your consciousness expands beyond the present moment, glimpsing into the near future. You see the enemy's next moves before they happen, allowing you to prepare perfect counters.",
		"effects": {
			"enemy_prediction": true,
			"dodge": 1.4,
			"accuracy": 1.5,
			"critical_chance": 1.3
		}
	},
	"time_freeze": {
		"freeze_enemies": true,
		"duration": 1,
		"cost": 80,
		"description": "Freeze time for enemies",
		"narrative": "Time itself stops for your enemies, freezing them in place like statues. You move freely through the frozen battlefield, taking advantage of their temporal paralysis.",
		"effects": {
			"enemy_freeze": true,
			"free_actions": 2,
			"damage_multiplier": 1.5,
			"status_application": true
		}
	},
	"temporal_acceleration": {
		"speed_multiplier": 3.0,
		"duration": 2,
		"cost": 60,
		"description": "Accelerate your own time",
		"narrative": "Your personal timeline accelerates, making you move so fast that you become a blur. Multiple actions blur together as you strike with impossible speed.",
		"effects": {
			"speed_multiplier": 3.0,
			"action_points": 2,
			"attack_speed": 2.5,
			"movement": 2.0
		}
	},
	"time_paradox": {
		"reality_distortion": true,
		"cost": 150,
		"description": "Create a temporal paradox",
		"narrative": "You create a temporal paradox, bending reality itself. The laws of causality bend and break as you manipulate the very fabric of time and space.",
		"effects": {
			"reality_distortion": true,
			"random_effects": true,
			"damage_multiplier": 2.0,
			"status_immunity": true
		}
	},
	"chrono_surge": {
		"burst_actions": 3,
		"duration": 1,
		"cost": 70,
		"description": "Surge of temporal energy",
		"narrative": "Temporal energy surges through your body, granting you a burst of superhuman speed and reflexes. Time seems to stand still as you execute a flurry of actions.",
		"effects": {
			"burst_actions": 3,
			"speed": 2.0,
			"accuracy": 1.4,
			"critical_chance": 1.5
		}
	},
	"temporal_barrier": {
		"damage_reduction": 0.3,
		"duration": 4,
		"cost": 40,
		"description": "Create a temporal barrier",
		"narrative": "You create a barrier of distorted time around yourself, slowing incoming attacks to a crawl. Damage is reduced as attacks pass through the temporal field.",
		"effects": {
			"damage_reduction": 0.3,
			"defense": 1.6,
			"magic_defense": 1.4,
			"status_resistance": 1.3
		}
	}
}

# Active time manipulation states
var active_time_effects: Dictionary = {}
var time_energy: int = 100
var max_time_energy: int = 100
var time_history: Array = []

# Time manipulation cooldowns
var time_cooldowns: Dictionary = {}

func trigger_time_manipulation(mechanic: String, target = null) -> bool:
	"""Trigger a time manipulation mechanic"""
	if not time_mechanics.has(mechanic):
		print("TimeManager: Invalid time mechanic: %s" % mechanic)
		return false
	
	var mechanic_data = time_mechanics[mechanic]
	var cost = mechanic_data.get("cost", 0)
	
	# Check if we have enough time energy
	if time_energy < cost:
		print("TimeManager: Insufficient time energy - need %d, have %d" % [cost, time_energy])
		return false
	
	# Check cooldown
	if time_cooldowns.has(mechanic):
		var last_used = time_cooldowns[mechanic]
		var current_turn = get_current_turn()
		if current_turn - last_used < get_cooldown_turns(mechanic):
			print("TimeManager: Time mechanic %s on cooldown" % mechanic)
			return false
	
	# Apply time energy cost
	time_energy -= cost
	
	# Apply effects based on mechanic
	var _effects_applied = apply_time_effects(mechanic, target)
	
	# Set cooldown
	time_cooldowns[mechanic] = get_current_turn()
	
	# Add to history
	time_history.append({
		"turn": get_current_turn(),
		"mechanic": mechanic,
		"cost": cost,
		"target": target.character_name if target else "none",
		"description": mechanic_data["description"],
		"narrative": mechanic_data["narrative"]
	})
	
	# Update time state and emit signal
	previous_time_state = current_time_state
	current_time_state = mechanic
	time_state_changed.emit(previous_time_state, current_time_state, mechanic_data.get("duration", 1))
	
	# Emit signals
	time_manipulation_triggered.emit(mechanic, cost, mechanic_data["description"])
	time_narrative_triggered.emit(mechanic, mechanic_data["narrative"])
	
	print("TimeManager: Triggered %s - Cost: %d, Energy remaining: %d" % [mechanic, cost, time_energy])
	
	return true

func apply_time_effects(mechanic: String, target = null) -> Dictionary:
	"""Apply time manipulation effects"""
	var effects_applied = {}
	var mechanic_data = time_mechanics.get(mechanic, {})
	var effects = mechanic_data.get("effects", {})
	
	if not target:
		return effects_applied
	
	# Apply action speed multiplier
	if effects.has("action_speed"):
		if target.has_method("add_action_speed_bonus"):
			target.add_action_speed_bonus(effects["action_speed"])
		effects_applied["action_speed"] = effects["action_speed"]
		print("TimeManager: Applied %.1fx action speed bonus from %s" % [effects["action_speed"], mechanic])
	
	# Apply dodge bonus
	if effects.has("dodge"):
		if target.has_method("add_dodge_bonus"):
			target.add_dodge_bonus(effects["dodge"])
		effects_applied["dodge"] = effects["dodge"]
		print("TimeManager: Applied %.1fx dodge bonus from %s" % [effects["dodge"], mechanic])
	
	# Apply accuracy bonus
	if effects.has("accuracy"):
		if target.has_method("add_accuracy_bonus"):
			target.add_accuracy_bonus(effects["accuracy"])
		effects_applied["accuracy"] = effects["accuracy"]
		print("TimeManager: Applied %.1fx accuracy bonus from %s" % [effects["accuracy"], mechanic])
	
	# Apply critical chance bonus
	if effects.has("critical_chance"):
		if target.has_method("add_critical_chance_bonus"):
			target.add_critical_chance_bonus(effects["critical_chance"])
		effects_applied["critical_chance"] = effects["critical_chance"]
		print("TimeManager: Applied %.1fx critical chance bonus from %s" % [effects["critical_chance"], mechanic])
	
	# Apply speed multiplier
	if effects.has("speed_multiplier"):
		if target.has_method("add_speed_multiplier"):
			target.add_speed_multiplier(effects["speed_multiplier"])
		effects_applied["speed_multiplier"] = effects["speed_multiplier"]
		print("TimeManager: Applied %.1fx speed multiplier from %s" % [effects["speed_multiplier"], mechanic])
	
	# Apply action points bonus
	if effects.has("action_points"):
		if target.has_method("add_action_points"):
			target.add_action_points(effects["action_points"])
		effects_applied["action_points"] = effects["action_points"]
		print("TimeManager: Applied %d action points from %s" % [effects["action_points"], mechanic])
	
	# Apply attack speed bonus
	if effects.has("attack_speed"):
		if target.has_method("add_attack_speed_bonus"):
			target.add_attack_speed_bonus(effects["attack_speed"])
		effects_applied["attack_speed"] = effects["attack_speed"]
		print("TimeManager: Applied %.1fx attack speed bonus from %s" % [effects["attack_speed"], mechanic])
	
	# Apply movement bonus
	if effects.has("movement"):
		if target.has_method("add_movement_bonus"):
			target.add_movement_bonus(effects["movement"])
		effects_applied["movement"] = effects["movement"]
		print("TimeManager: Applied %.1fx movement bonus from %s" % [effects["movement"], mechanic])
	
	# Apply damage reduction
	if effects.has("damage_reduction"):
		if target.has_method("add_damage_reduction"):
			target.add_damage_reduction(effects["damage_reduction"])
		effects_applied["damage_reduction"] = effects["damage_reduction"]
		print("TimeManager: Applied %.1fx damage reduction from %s" % [effects["damage_reduction"], mechanic])
	
	# Apply defense bonus
	if effects.has("defense"):
		if target.has_method("add_defense_bonus"):
			target.add_defense_bonus(effects["defense"])
		effects_applied["defense"] = effects["defense"]
		print("TimeManager: Applied %.1fx defense bonus from %s" % [effects["defense"], mechanic])
	
	# Apply magic defense bonus
	if effects.has("magic_defense"):
		if target.has_method("add_magic_defense_bonus"):
			target.add_magic_defense_bonus(effects["magic_defense"])
		effects_applied["magic_defense"] = effects["magic_defense"]
		print("TimeManager: Applied %.1fx magic defense bonus from %s" % [effects["magic_defense"], mechanic])
	
	# Apply status resistance bonus
	if effects.has("status_resistance"):
		if target.has_method("add_status_resistance_bonus"):
			target.add_status_resistance_bonus(effects["status_resistance"])
		effects_applied["status_resistance"] = effects["status_resistance"]
		print("TimeManager: Applied %.1fx status resistance bonus from %s" % [effects["status_resistance"], mechanic])
	
	# Apply burst actions
	if effects.has("burst_actions"):
		if target.has_method("add_burst_actions"):
			target.add_burst_actions(effects["burst_actions"])
		effects_applied["burst_actions"] = effects["burst_actions"]
		print("TimeManager: Applied %d burst actions from %s" % [effects["burst_actions"], mechanic])
	
	# Apply free actions
	if effects.has("free_actions"):
		if target.has_method("add_free_actions"):
			target.add_free_actions(effects["free_actions"])
		effects_applied["free_actions"] = effects["free_actions"]
		print("TimeManager: Applied %d free actions from %s" % [effects["free_actions"], mechanic])
	
	# Apply damage multiplier
	if effects.has("damage_multiplier"):
		if target.has_method("add_damage_multiplier"):
			target.add_damage_multiplier(effects["damage_multiplier"])
		effects_applied["damage_multiplier"] = effects["damage_multiplier"]
		print("TimeManager: Applied %.1fx damage multiplier from %s" % [effects["damage_multiplier"], mechanic])
	
	# Apply status application
	if effects.has("status_application"):
		if target.has_method("add_status_application"):
			target.add_status_application(effects["status_application"])
		effects_applied["status_application"] = effects["status_application"]
		print("TimeManager: Applied status application from %s" % mechanic)
	
	# Apply reality distortion
	if effects.has("reality_distortion"):
		if target.has_method("add_reality_distortion"):
			target.add_reality_distortion(effects["reality_distortion"])
		effects_applied["reality_distortion"] = effects["reality_distortion"]
		print("TimeManager: Applied reality distortion from %s" % mechanic)
	
	# Apply random effects
	if effects.has("random_effects"):
		if target.has_method("add_random_effects"):
			target.add_random_effects(effects["random_effects"])
		effects_applied["random_effects"] = effects["random_effects"]
		print("TimeManager: Applied random effects from %s" % mechanic)
	
	# Apply status immunity
	if effects.has("status_immunity"):
		if target.has_method("add_status_immunity"):
			target.add_status_immunity(effects["status_immunity"])
		effects_applied["status_immunity"] = effects["status_immunity"]
		print("TimeManager: Applied status immunity from %s" % mechanic)
	
	return effects_applied

func get_time_mechanic_data(mechanic: String) -> Dictionary:
	"""Get data for a specific time mechanic"""
	return time_mechanics.get(mechanic, {})

func get_available_time_mechanics() -> Array:
	"""Get all available time mechanics"""
	var available = []
	
	for mechanic in time_mechanics.keys():
		var mechanic_data = time_mechanics[mechanic]
		var cost = mechanic_data.get("cost", 0)
		var can_afford = time_energy >= cost
		
		available.append({
			"mechanic": mechanic,
			"cost": cost,
			"description": mechanic_data["description"],
			"narrative": mechanic_data["narrative"],
			"can_afford": can_afford
		})
	
	return available

func get_time_narrative(mechanic: String) -> String:
	"""Get narrative description for a time mechanic"""
	var mechanic_data = time_mechanics.get(mechanic, {})
	return mechanic_data.get("narrative", "")

func get_time_energy() -> int:
	"""Get current time energy"""
	return time_energy

func add_time_energy(amount: int):
	"""Add time energy"""
	time_energy = min(time_energy + amount, max_time_energy)
	print("TimeManager: Added %d time energy, total: %d" % [amount, time_energy])

func get_cooldown_turns(mechanic: String) -> int:
	"""Get cooldown turns for a mechanic"""
	var cooldowns = {
		"time_dilation": 3,
		"temporal_rewind": 5,
		"future_sight": 2,
		"time_freeze": 4,
		"temporal_acceleration": 3,
		"time_paradox": 8,
		"chrono_surge": 4,
		"temporal_barrier": 2
	}
	
	return cooldowns.get(mechanic, 1)

func get_current_turn() -> int:
	"""Get current turn number (placeholder)"""
	# In a real implementation, this would get the current turn from CombatManager
	return 1

func clear_time_effects():
	"""Clear all active time effects"""
	active_time_effects.clear()
	print("TimeManager: All time effects cleared")

func get_time_statistics() -> Dictionary:
	"""Get time system statistics"""
	return {
		"time_energy": time_energy,
		"max_time_energy": max_time_energy,
		"active_effects": active_time_effects.size(),
		"total_mechanics": time_mechanics.size(),
		"history_entries": time_history.size(),
		"cooldowns_active": time_cooldowns.size()
	} 