extends Node
class_name TurnMeterManager

# Turn Meter Manager - Handles turn meter system inspired by SWGOH
# Manages speed-based turn meter, turn meter manipulation, and turn meter effects

signal turn_meter_changed(actor: String, old_meter: float, new_meter: float)
signal turn_meter_manipulation(actor: String, manipulation_type: String, amount: float)
signal turn_meter_speed_boost(actor: String, speed_bonus: float, description: String)

# Turn meter system inspired by SWGOH
var turn_meter_mechanics = {
	"speed_based_meter": {
		"base_speed": 100,
		"meter_per_turn": 0.25,
		"description": "Speed determines turn meter gain",
		"narrative": "Your speed determines how quickly you fill your turn meter. Faster characters act more frequently in battle."
	},
	"turn_meter_manipulation": {
		"gain_meter": 0.5,
		"reduce_meter": -0.3,
		"drain_meter": -0.7,
		"description": "Manipulate turn meter directly",
		"narrative": "You can directly manipulate turn meters, gaining advantage or denying enemies their turns."
	},
	"speed_boost": {
		"temporary_boost": 1.5,
		"permanent_boost": 1.2,
		"description": "Boost speed temporarily or permanently",
		"narrative": "Speed boosts can be temporary bursts or permanent enhancements to your turn frequency."
	},
	"turn_meter_effects": {
		"stun": {"meter_loss": -1.0, "description": "Complete turn meter loss"},
		"slow": {"meter_loss": -0.5, "description": "Significant turn meter loss"},
		"haste": {"meter_gain": 0.5, "description": "Turn meter gain"},
		"freeze": {"meter_stop": true, "description": "Turn meter stops filling"}
	}
}

# Active turn meters for each actor
var actor_turn_meters: Dictionary = {}
var actor_speeds: Dictionary = {}
var turn_meter_history: Array = []

# Turn meter manipulation cooldowns
var meter_manipulation_cooldowns: Dictionary = {}

func _ready():
	"""Initialize turn meter manager"""
	print("TurnMeterManager: Initialized")

func initialize_actor_turn_meter(actor_name: String, base_speed: float = 100.0):
	"""Initialize turn meter for an actor"""
	actor_turn_meters[actor_name] = 0.0
	actor_speeds[actor_name] = base_speed
	print("TurnMeterManager: Initialized turn meter for %s (Speed: %.1f)" % [actor_name, base_speed])

func update_turn_meter(actor_name: String, speed_modifier: float = 1.0):
	"""Update turn meter based on speed"""
	if not actor_turn_meters.has(actor_name):
		initialize_actor_turn_meter(actor_name)
	
	var old_meter = actor_turn_meters[actor_name]
	var base_speed = actor_speeds[actor_name]
	var effective_speed = base_speed * speed_modifier
	
	# Calculate meter gain based on speed
	var meter_gain = (effective_speed / 100.0) * turn_meter_mechanics["speed_based_meter"]["meter_per_turn"]
	actor_turn_meters[actor_name] = min(actor_turn_meters[actor_name] + meter_gain, 1.0)
	
	var new_meter = actor_turn_meters[actor_name]
	
	# Add to history
	turn_meter_history.append({
		"turn": get_current_turn(),
		"actor": actor_name,
		"old_meter": old_meter,
		"new_meter": new_meter,
		"speed": effective_speed,
		"meter_gain": meter_gain
	})
	
	# Emit signal
	turn_meter_changed.emit(actor_name, old_meter, new_meter)
	
	print("TurnMeterManager: %s turn meter %.1f -> %.1f (Speed: %.1f)" % [actor_name, old_meter, new_meter, effective_speed])
	
	return new_meter

func manipulate_turn_meter(actor_name: String, manipulation_type: String, amount: float) -> bool:
	"""Manipulate turn meter directly"""
	if not actor_turn_meters.has(actor_name):
		print("TurnMeterManager: Actor %s not found" % actor_name)
		return false
	
	var old_meter = actor_turn_meters[actor_name]
	var new_meter = old_meter
	
	match manipulation_type:
		"gain":
			new_meter = min(old_meter + amount, 1.0)
		"reduce":
			new_meter = max(old_meter + amount, 0.0)
		"drain":
			new_meter = max(old_meter + amount, 0.0)
		"set":
			new_meter = clamp(amount, 0.0, 1.0)
		_:
			print("TurnMeterManager: Unknown manipulation type: %s" % manipulation_type)
			return false
	
	actor_turn_meters[actor_name] = new_meter
	
	# Add to history
	turn_meter_history.append({
		"turn": get_current_turn(),
		"actor": actor_name,
		"manipulation_type": manipulation_type,
		"old_meter": old_meter,
		"new_meter": new_meter,
		"amount": amount
	})
	
	# Emit signal
	turn_meter_manipulation.emit(actor_name, manipulation_type, amount)
	
	print("TurnMeterManager: %s turn meter %s by %.1f (%.1f -> %.1f)" % [actor_name, manipulation_type, amount, old_meter, new_meter])
	
	return true

func apply_speed_boost(actor_name: String, boost_type: String, duration: int = 1) -> bool:
	"""Apply speed boost to an actor"""
	if not actor_speeds.has(actor_name):
		print("TurnMeterManager: Actor %s not found" % actor_name)
		return false
	
	var old_speed = actor_speeds[actor_name]
	var boost_multiplier = 1.0
	
	match boost_type:
		"temporary":
			boost_multiplier = turn_meter_mechanics["speed_boost"]["temporary_boost"]
		"permanent":
			boost_multiplier = turn_meter_mechanics["speed_boost"]["permanent_boost"]
		_:
			print("TurnMeterManager: Unknown boost type: %s" % boost_type)
			return false
	
	var new_speed = old_speed * boost_multiplier
	actor_speeds[actor_name] = new_speed
	
	# Add to history
	turn_meter_history.append({
		"turn": get_current_turn(),
		"actor": actor_name,
		"boost_type": boost_type,
		"old_speed": old_speed,
		"new_speed": new_speed,
		"duration": duration
	})
	
	# Emit signal
	turn_meter_speed_boost.emit(actor_name, boost_multiplier, "Speed boosted by %.1fx" % boost_multiplier)
	
	print("TurnMeterManager: %s speed boost %s (%.1f -> %.1f)" % [actor_name, boost_type, old_speed, new_speed])
	
	return true

func apply_turn_meter_effect(actor_name: String, effect_type: String) -> bool:
	"""Apply turn meter effect to an actor"""
	if not actor_turn_meters.has(actor_name):
		print("TurnMeterManager: Actor %s not found" % actor_name)
		return false
	
	var effect_data = turn_meter_mechanics["turn_meter_effects"].get(effect_type, {})
	if effect_data.is_empty():
		print("TurnMeterManager: Unknown effect type: %s" % effect_type)
		return false
	
	var old_meter = actor_turn_meters[actor_name]
	var new_meter = old_meter
	
	if effect_data.has("meter_loss"):
		new_meter = max(old_meter + effect_data["meter_loss"], 0.0)
	elif effect_data.has("meter_gain"):
		new_meter = min(old_meter + effect_data["meter_gain"], 1.0)
	elif effect_data.has("meter_stop"):
		# Stop meter from filling (implement as needed)
		pass
	
	actor_turn_meters[actor_name] = new_meter
	
	# Add to history
	turn_meter_history.append({
		"turn": get_current_turn(),
		"actor": actor_name,
		"effect_type": effect_type,
		"old_meter": old_meter,
		"new_meter": new_meter,
		"description": effect_data["description"]
	})
	
	print("TurnMeterManager: %s turn meter effect %s (%.1f -> %.1f)" % [actor_name, effect_type, old_meter, new_meter])
	
	return true

func get_turn_meter(actor_name: String) -> float:
	"""Get current turn meter for an actor"""
	return actor_turn_meters.get(actor_name, 0.0)

func get_actor_speed(actor_name: String) -> float:
	"""Get current speed for an actor"""
	return actor_speeds.get(actor_name, 100.0)

func is_turn_ready(actor_name: String) -> bool:
	"""Check if an actor's turn meter is full"""
	return get_turn_meter(actor_name) >= 1.0

func consume_turn(actor_name: String):
	"""Consume turn meter when actor takes their turn"""
	if not actor_turn_meters.has(actor_name):
		return
	
	var old_meter = actor_turn_meters[actor_name]
	actor_turn_meters[actor_name] = 0.0
	
	# Add to history
	turn_meter_history.append({
		"turn": get_current_turn(),
		"actor": actor_name,
		"action": "consume_turn",
		"old_meter": old_meter,
		"new_meter": 0.0
	})
	
	print("TurnMeterManager: %s consumed turn (%.1f -> 0.0)" % [actor_name, old_meter])

func get_turn_order() -> Array:
	"""Get actors sorted by turn meter (highest first)"""
	var actors = []
	
	for actor_name in actor_turn_meters.keys():
		actors.append({
			"name": actor_name,
			"meter": actor_turn_meters[actor_name],
			"speed": actor_speeds[actor_name]
		})
	
	# Sort by turn meter (highest first), then by speed (highest first)
	actors.sort_custom(func(a, b): 
		if a["meter"] != b["meter"]:
			return a["meter"] > b["meter"]
		return a["speed"] > b["speed"]
	)
	
	return actors

func get_current_turn() -> int:
	"""Get current turn number (placeholder)"""
	# In a real implementation, this would get the current turn from CombatManager
	return 1

func clear_turn_meters():
	"""Clear all turn meters"""
	actor_turn_meters.clear()
	actor_speeds.clear()
	print("TurnMeterManager: All turn meters cleared")

func get_turn_meter_statistics() -> Dictionary:
	"""Get turn meter system statistics"""
	return {
		"active_actors": actor_turn_meters.size(),
		"total_history": turn_meter_history.size(),
		"average_speed": calculate_average_speed(),
		"highest_meter": get_highest_turn_meter(),
		"ready_actors": count_ready_actors()
	}

func calculate_average_speed() -> float:
	"""Calculate average speed of all actors"""
	if actor_speeds.is_empty():
		return 0.0
	
	var total_speed = 0.0
	for speed in actor_speeds.values():
		total_speed += speed
	
	return total_speed / actor_speeds.size()

func get_highest_turn_meter() -> float:
	"""Get the highest turn meter among all actors"""
	if actor_turn_meters.is_empty():
		return 0.0
	
	var highest = 0.0
	for meter in actor_turn_meters.values():
		highest = max(highest, meter)
	
	return highest

func count_ready_actors() -> int:
	"""Count actors with full turn meters"""
	var ready_count = 0
	for meter in actor_turn_meters.values():
		if meter >= 1.0:
			ready_count += 1
	
	return ready_count 