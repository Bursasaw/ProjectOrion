extends Node
class_name MomentumManager

# Momentum Manager - Handles momentum points and combo mechanics
# Manages momentum gain, spending, and narrative integration

signal momentum_gained(amount: int, source: String, description: String)
signal momentum_spent(amount: int, action: String, description: String)
signal combo_triggered(combo_type: String, damage_multiplier: float, description: String)
signal momentum_state_changed(current_momentum: int, max_momentum: int)

# Momentum mechanics configuration
var momentum_mechanics = {
	"momentum_points": 0,
	"max_momentum": 10,
	"momentum_gain": {
		"successful_hit": 1,
		"critical_hit": 2,
		"elemental_advantage": 1,
		"team_synergy": 1,
		"world_alignment": 1,
		"perfect_timing": 2,
		"counter_attack": 2,
		"defensive_mastery": 1
	},
	"momentum_spend": {
		"combo_attack": 3,
		"ultimate_skill": 8,
		"team_synergy": 5,
		"reality_bending": 7,
		"void_mastery": 6,
		"ancient_power": 9,
		"dragon_essence": 8,
		"crystal_resonance": 4
	}
}

# Combo attack types and their properties
var combo_attacks = {
	"elemental_burst": {
		"cost": 3,
		"damage_multiplier": 1.8,
		"description": "Unleash a devastating elemental burst",
		"narrative": "Elements converge in a spectacular display of power",
		"world_bonus": {
			"sylithar": 2.2,
			"krynn": 2.0,
			"elysion": 1.9,
			"terra": 1.8,
			"aethra": 1.9,
			"ombra": 2.1,
			"nokturn": 1.8,
			"tauron": 1.7,
			"aelria": 2.3
		}
	},
	"reality_shift": {
		"cost": 7,
		"damage_multiplier": 2.5,
		"description": "Bend reality itself to your will",
		"narrative": "Reality warps and distorts as you channel impossible power",
		"world_bonus": {
			"aelria": 3.0,
			"ombra": 2.8,
			"elysion": 2.6,
			"sylithar": 2.5,
			"krynn": 2.4,
			"terra": 2.3,
			"aethra": 2.4,
			"nokturn": 2.5,
			"tauron": 2.2
		}
	},
	"void_cascade": {
		"cost": 6,
		"damage_multiplier": 2.2,
		"description": "Unleash a cascade of void energy",
		"narrative": "Void energy erupts in a torrent of destructive power",
		"world_bonus": {
			"ombra": 2.8,
			"aelria": 2.6,
			"nokturn": 2.4,
			"elysion": 2.3,
			"sylithar": 2.2,
			"krynn": 2.1,
			"terra": 2.0,
			"aethra": 2.1,
			"tauron": 2.0
		}
	},
	"dragon_roar": {
		"cost": 8,
		"damage_multiplier": 2.8,
		"description": "Channel the ancient power of dragons",
		"narrative": "The essence of ancient dragons flows through you",
		"world_bonus": {
			"krynn": 3.2,
			"aelria": 3.0,
			"elysion": 2.9,
			"sylithar": 2.8,
			"terra": 2.7,
			"aethra": 2.8,
			"ombra": 2.9,
			"nokturn": 2.7,
			"tauron": 2.6
		}
	},
	"crystal_symphony": {
		"cost": 4,
		"damage_multiplier": 1.6,
		"description": "Create a symphony of crystalline power",
		"narrative": "Crystalline energy resonates in perfect harmony",
		"world_bonus": {
			"sylithar": 2.0,
			"aelria": 1.9,
			"elysion": 1.8,
			"krynn": 1.7,
			"terra": 1.6,
			"aethra": 1.7,
			"ombra": 1.8,
			"nokturn": 1.6,
			"tauron": 1.5
		}
	},
	"ancient_awakening": {
		"cost": 9,
		"damage_multiplier": 3.0,
		"description": "Awaken ancient power within",
		"narrative": "Ancient power surges through your being",
		"world_bonus": {
			"elysion": 3.5,
			"aelria": 3.3,
			"tauron": 3.2,
			"sylithar": 3.1,
			"krynn": 3.0,
			"terra": 2.9,
			"aethra": 3.0,
			"ombra": 3.1,
			"nokturn": 2.9
		}
	},
	"shadow_dance": {
		"cost": 5,
		"damage_multiplier": 1.9,
		"description": "Dance through shadows with deadly precision",
		"narrative": "Shadows become your weapon as you move with lethal grace",
		"world_bonus": {
			"nokturn": 2.4,
			"ombra": 2.3,
			"aelria": 2.1,
			"elysion": 2.0,
			"sylithar": 1.9,
			"krynn": 1.8,
			"terra": 1.7,
			"aethra": 1.8,
			"tauron": 1.7
		}
	},
	"tech_surge": {
		"cost": 6,
		"damage_multiplier": 2.1,
		"description": "Surge with technological power",
		"narrative": "Advanced technology amplifies your capabilities",
		"world_bonus": {
			"tauron": 2.6,
			"aelria": 2.4,
			"elysion": 2.3,
			"sylithar": 2.2,
			"krynn": 2.1,
			"terra": 2.0,
			"aethra": 2.1,
			"ombra": 2.2,
			"nokturn": 2.0
		}
	}
}

# Current momentum state
var current_momentum: int = 0
var max_momentum: int = 10
var momentum_history: Array = []

# Narrative integration
var momentum_narratives = {
	"low": "Your resolve builds slowly",
	"medium": "Momentum surges through your veins",
	"high": "Power flows freely through your being",
	"max": "You are unstoppable, a force of nature"
}

func gain_momentum(amount: int, source: String, world: String = "") -> bool:
	"""Gain momentum points"""
	if current_momentum >= max_momentum:
		return false
	
	var gain_amount = amount
	var description = "Gained %d momentum from %s" % [amount, source]
	
	# Apply world bonus if available
	if world != "":
		var world_bonus = get_world_momentum_bonus(world, source)
		gain_amount = ceil(amount * world_bonus)
		description = "Gained %d momentum from %s (enhanced by %s)" % [gain_amount, source, world]
		print("MomentumManager: World bonus applied - %s: %.1fx, result: %d" % [world, world_bonus, gain_amount])
	
	current_momentum = min(current_momentum + gain_amount, max_momentum)
	
	# Add to history
	momentum_history.append({
		"turn": get_current_turn(),
		"action": "gain",
		"amount": gain_amount,
		"source": source,
		"world": world,
		"description": description
	})
	
	print("MomentumManager: %s" % description)
	momentum_gained.emit(gain_amount, source, description)
	momentum_state_changed.emit(current_momentum, max_momentum)
	
	return true

func spend_momentum(amount: int, action: String, world: String = "") -> bool:
	"""Spend momentum points"""
	if current_momentum < amount:
		return false
	
	current_momentum -= amount
	
	var description = "Spent %d momentum on %s" % [amount, action]
	if world != "":
		description = "Spent %d momentum on %s (enhanced by %s)" % [amount, action, world]
	
	# Add to history
	momentum_history.append({
		"turn": get_current_turn(),
		"action": "spend",
		"amount": amount,
		"action_type": action,
		"world": world,
		"description": description
	})
	
	print("MomentumManager: %s" % description)
	momentum_spent.emit(amount, action, description)
	momentum_state_changed.emit(current_momentum, max_momentum)
	
	return true

func trigger_combo_attack(combo_type: String, world: String = "") -> Dictionary:
	"""Trigger a combo attack"""
	if not combo_attacks.has(combo_type):
		return {"success": false, "error": "Invalid combo type"}
	
	var combo_data = combo_attacks[combo_type].duplicate()
	var cost = combo_data["cost"]
	
	if current_momentum < cost:
		return {"success": false, "error": "Insufficient momentum"}
	
	# Apply world bonus if available
	var damage_multiplier = combo_data["damage_multiplier"]
	if world != "" and combo_data.has("world_bonus") and combo_data["world_bonus"].has(world):
		damage_multiplier = combo_data["world_bonus"][world]
		print("MomentumManager: Applied %s world bonus to %s combo" % [world, combo_type])
	
	# Spend momentum
	if not spend_momentum(cost, combo_type, world):
		return {"success": false, "error": "Failed to spend momentum"}
	
	var description = combo_data["description"]
	var narrative = combo_data["narrative"]
	
	if world != "":
		description += " (enhanced by %s)" % world
		narrative += " The power of %s amplifies your attack." % world
	
	print("MomentumManager: Triggered %s combo - Damage: %.1fx" % [combo_type, damage_multiplier])
	combo_triggered.emit(combo_type, damage_multiplier, description)
	
	return {
		"success": true,
		"damage_multiplier": damage_multiplier,
		"description": description,
		"narrative": narrative,
		"cost": cost
	}

func get_available_combos(world: String = "") -> Array:
	"""Get available combo attacks based on current momentum"""
	var available = []
	
	for combo_type in combo_attacks:
		var combo_data = combo_attacks[combo_type]
		var cost = combo_data["cost"]
		
		if current_momentum >= cost:
			var damage_multiplier = combo_data["damage_multiplier"]
			
			# Apply world bonus if available
			if world != "" and combo_data.has("world_bonus") and combo_data["world_bonus"].has(world):
				damage_multiplier = combo_data["world_bonus"][world]
			
			available.append({
				"type": combo_type,
				"cost": cost,
				"damage_multiplier": damage_multiplier,
				"description": combo_data["description"],
				"narrative": combo_data["narrative"]
			})
	
	return available

func get_momentum_narrative() -> String:
	"""Get narrative description of current momentum state"""
	var momentum_percentage = float(current_momentum) / float(max_momentum)
	
	if momentum_percentage <= 0.25:
		return momentum_narratives["low"]
	elif momentum_percentage <= 0.5:
		return momentum_narratives["medium"]
	elif momentum_percentage <= 0.75:
		return momentum_narratives["high"]
	else:
		return momentum_narratives["max"]

func get_world_momentum_bonus(world: String, _source: String) -> float:
	"""Get world-specific momentum bonus"""
	var world_bonuses = {
		"aelria": 1.5,
		"elysion": 1.3,
		"sylithar": 1.2,
		"krynn": 1.2,
		"terra": 1.1,
		"aethra": 1.2,
		"ombra": 1.4,
		"nokturn": 1.2,
		"tauron": 1.1
	}
	
	return world_bonuses.get(world, 1.0)

func get_current_turn() -> int:
	"""Get current turn number (placeholder)"""
	# In a real implementation, this would get the current turn from CombatManager
	return 1

func reset_momentum():
	"""Reset momentum to zero"""
	current_momentum = 0
	momentum_history.clear()
	print("MomentumManager: Momentum reset")
	momentum_state_changed.emit(current_momentum, max_momentum)

func reset_momentum_for_testing():
	"""Reset momentum to zero for testing purposes"""
	current_momentum = 0
	momentum_history.clear()
	print("MomentumManager: Momentum reset for testing")
	momentum_state_changed.emit(current_momentum, max_momentum)

func get_momentum_statistics() -> Dictionary:
	"""Get momentum system statistics"""
	return {
		"current_momentum": current_momentum,
		"max_momentum": max_momentum,
		"momentum_percentage": float(current_momentum) / float(max_momentum),
		"available_combos": get_available_combos().size(),
		"total_combos": combo_attacks.size(),
		"history_entries": momentum_history.size()
	} 