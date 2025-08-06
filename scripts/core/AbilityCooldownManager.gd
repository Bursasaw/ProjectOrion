extends Node
class_name AbilityCooldownManager

# Ability Cooldown Manager - Handles ability cooldown system inspired by SWGOH
# Manages ability cooldowns, cooldown reduction, and cooldown manipulation

signal ability_used(actor: String, ability_name: String, cooldown_turns: int)
signal cooldown_reduced(actor: String, ability_name: String, reduction: int)
signal cooldown_reset(actor: String, ability_name: String)

# Ability cooldown system inspired by SWGOH
var ability_cooldowns = {
	"basic_attack": {
		"cooldown": 0,
		"description": "Basic attack with no cooldown",
		"narrative": "A simple but effective attack that can be used every turn."
	},
	"special_ability": {
		"cooldown": 3,
		"description": "Special ability with moderate cooldown",
		"narrative": "A powerful special ability that requires time to recharge."
	},
	"ultimate_ability": {
		"cooldown": 6,
		"description": "Ultimate ability with long cooldown",
		"narrative": "A devastating ultimate ability that takes time to prepare."
	},
	"healing_ability": {
		"cooldown": 4,
		"description": "Healing ability with moderate cooldown",
		"narrative": "A restorative ability that needs time to recharge."
	},
	"buff_ability": {
		"cooldown": 5,
		"description": "Buff ability with moderate cooldown",
		"narrative": "An empowering ability that enhances your allies."
	},
	"debuff_ability": {
		"cooldown": 4,
		"description": "Debuff ability with moderate cooldown",
		"narrative": "A weakening ability that hampers your enemies."
	},
	"area_attack": {
		"cooldown": 5,
		"description": "Area attack with moderate cooldown",
		"narrative": "A devastating area attack that affects multiple targets."
	},
	"defensive_ability": {
		"cooldown": 3,
		"description": "Defensive ability with short cooldown",
		"narrative": "A protective ability that shields you from harm."
	}
}

# Actor ability cooldowns
var actor_cooldowns: Dictionary = {}
var cooldown_history: Array = []

# Cooldown reduction mechanics
var cooldown_reduction_mechanics = {
	"haste": {"reduction": 1, "description": "Reduces cooldowns by 1 turn"},
	"time_acceleration": {"reduction": 2, "description": "Reduces cooldowns by 2 turns"},
	"cooldown_reset": {"reduction": -1, "description": "Resets all cooldowns"},  # -1 means reset
	"partial_reduction": {"reduction": 0.5, "description": "Reduces cooldowns by 50%"}
}

func _ready():
	"""Initialize ability cooldown manager"""
	print("AbilityCooldownManager: Initialized")

func initialize_actor_cooldowns(actor_name: String):
	"""Initialize cooldowns for an actor"""
	actor_cooldowns[actor_name] = {}
	
	for ability_name in ability_cooldowns.keys():
		actor_cooldowns[actor_name][ability_name] = 0
	
	print("AbilityCooldownManager: Initialized cooldowns for %s" % actor_name)

func use_ability(actor_name: String, ability_name: String) -> bool:
	"""Use an ability and set its cooldown"""
	if not ability_cooldowns.has(ability_name):
		print("AbilityCooldownManager: Unknown ability: %s" % ability_name)
		return false
	
	if not actor_cooldowns.has(actor_name):
		initialize_actor_cooldowns(actor_name)
	
	# Check if ability is on cooldown
	var current_cooldown = actor_cooldowns[actor_name].get(ability_name, 0)
	if current_cooldown > 0:
		print("AbilityCooldownManager: %s is on cooldown for %d turns" % [ability_name, current_cooldown])
		return false
	
	# Set cooldown
	var cooldown_turns = ability_cooldowns[ability_name]["cooldown"]
	actor_cooldowns[actor_name][ability_name] = cooldown_turns
	
	# Add to history
	cooldown_history.append({
		"turn": get_current_turn(),
		"actor": actor_name,
		"action": "use_ability",
		"ability_name": ability_name,
		"cooldown_set": cooldown_turns
	})
	
	# Emit signal
	ability_used.emit(actor_name, ability_name, cooldown_turns)
	
	print("AbilityCooldownManager: %s used %s (Cooldown: %d turns)" % [actor_name, ability_name, cooldown_turns])
	
	return true

func reduce_cooldown(actor_name: String, ability_name: String, reduction_type: String) -> bool:
	"""Reduce cooldown for an ability"""
	if not actor_cooldowns.has(actor_name):
		print("AbilityCooldownManager: Actor %s not found" % actor_name)
		return false
	
	if not ability_cooldowns.has(ability_name):
		print("AbilityCooldownManager: Unknown ability: %s" % ability_name)
		return false
	
	var reduction_data = cooldown_reduction_mechanics.get(reduction_type, {})
	if reduction_data.is_empty():
		print("AbilityCooldownManager: Unknown reduction type: %s" % reduction_type)
		return false
	
	var current_cooldown = actor_cooldowns[actor_name].get(ability_name, 0)
	var reduction_amount = reduction_data["reduction"]
	var new_cooldown = current_cooldown
	
	if reduction_amount == -1:
		# Reset cooldown
		new_cooldown = 0
	else:
		# Reduce cooldown
		new_cooldown = max(current_cooldown - reduction_amount, 0)
	
	actor_cooldowns[actor_name][ability_name] = new_cooldown
	
	# Add to history
	cooldown_history.append({
		"turn": get_current_turn(),
		"actor": actor_name,
		"action": "reduce_cooldown",
		"ability_name": ability_name,
		"reduction_type": reduction_type,
		"old_cooldown": current_cooldown,
		"new_cooldown": new_cooldown
	})
	
	# Emit signal
	if reduction_amount == -1:
		cooldown_reset.emit(actor_name, ability_name)
	else:
		cooldown_reduced.emit(actor_name, ability_name, reduction_amount)
	
	print("AbilityCooldownManager: %s cooldown reduced for %s (%d -> %d)" % [actor_name, ability_name, current_cooldown, new_cooldown])
	
	return true

func update_cooldowns(actor_name: String):
	"""Update cooldowns for an actor (called at end of turn)"""
	if not actor_cooldowns.has(actor_name):
		return
	
	for ability_name in actor_cooldowns[actor_name].keys():
		var current_cooldown = actor_cooldowns[actor_name][ability_name]
		if current_cooldown > 0:
			actor_cooldowns[actor_name][ability_name] = current_cooldown - 1
			
			# Add to history if cooldown reaches 0
			if current_cooldown - 1 == 0:
				cooldown_history.append({
					"turn": get_current_turn(),
					"actor": actor_name,
					"action": "cooldown_complete",
					"ability_name": ability_name
				})
	
	print("AbilityCooldownManager: Updated cooldowns for %s" % actor_name)

func get_ability_cooldown(actor_name: String, ability_name: String) -> int:
	"""Get current cooldown for an ability"""
	if not actor_cooldowns.has(actor_name):
		return 0
	
	return actor_cooldowns[actor_name].get(ability_name, 0)

func is_ability_ready(actor_name: String, ability_name: String) -> bool:
	"""Check if an ability is ready to use"""
	return get_ability_cooldown(actor_name, ability_name) == 0

func get_available_abilities(actor_name: String) -> Array:
	"""Get all abilities available to an actor"""
	var available = []
	
	for ability_name in ability_cooldowns.keys():
		if is_ability_ready(actor_name, ability_name):
			available.append({
				"name": ability_name,
				"description": ability_cooldowns[ability_name]["description"],
				"narrative": ability_cooldowns[ability_name]["narrative"],
				"cooldown": ability_cooldowns[ability_name]["cooldown"]
			})
	
	return available

func get_all_abilities(actor_name: String) -> Array:
	"""Get all abilities with their cooldown status"""
	var abilities = []
	
	for ability_name in ability_cooldowns.keys():
		var cooldown = get_ability_cooldown(actor_name, ability_name)
		var is_ready = cooldown == 0
		
		abilities.append({
			"name": ability_name,
			"description": ability_cooldowns[ability_name]["description"],
			"narrative": ability_cooldowns[ability_name]["narrative"],
			"cooldown": ability_cooldowns[ability_name]["cooldown"],
			"current_cooldown": cooldown,
			"is_ready": is_ready
		})
	
	return abilities

func get_ability_info(ability_name: String) -> Dictionary:
	"""Get information about a specific ability"""
	return ability_cooldowns.get(ability_name, {})

func get_cooldown_reduction_info(reduction_type: String) -> Dictionary:
	"""Get information about a cooldown reduction type"""
	return cooldown_reduction_mechanics.get(reduction_type, {})

func get_available_cooldown_reductions() -> Array:
	"""Get all available cooldown reduction types"""
	var available = []
	
	for reduction_type in cooldown_reduction_mechanics.keys():
		var reduction_data = cooldown_reduction_mechanics[reduction_type]
		available.append({
			"type": reduction_type,
			"reduction": reduction_data["reduction"],
			"description": reduction_data["description"]
		})
	
	return available

func reset_cooldowns_for_testing():
	"""Reset all cooldowns for testing purposes"""
	for actor_name in actor_cooldowns.keys():
		for ability_name in actor_cooldowns[actor_name].keys():
			actor_cooldowns[actor_name][ability_name] = 0
	print("AbilityCooldownManager: All cooldowns reset for testing")

func reset_all_cooldowns(actor_name: String):
	"""Reset all cooldowns for an actor"""
	if not actor_cooldowns.has(actor_name):
		return
	
	for ability_name in actor_cooldowns[actor_name].keys():
		actor_cooldowns[actor_name][ability_name] = 0
	
	# Add to history
	cooldown_history.append({
		"turn": get_current_turn(),
		"actor": actor_name,
		"action": "reset_all_cooldowns"
	})
	
	print("AbilityCooldownManager: Reset all cooldowns for %s" % actor_name)

func get_current_turn() -> int:
	"""Get current turn number (placeholder)"""
	# In a real implementation, this would get the current turn from CombatManager
	return 1

func clear_actor_cooldowns(actor_name: String):
	"""Clear all cooldowns for an actor"""
	if actor_cooldowns.has(actor_name):
		actor_cooldowns.erase(actor_name)
		print("AbilityCooldownManager: Cleared all cooldowns for %s" % actor_name)

func get_cooldown_statistics(actor_name: String) -> Dictionary:
	"""Get cooldown statistics for an actor"""
	if not actor_cooldowns.has(actor_name):
		return {}
	
	var abilities = actor_cooldowns[actor_name]
	var total_cooldowns = 0
	var ready_abilities = 0
	
	for ability_name in abilities.keys():
		var cooldown = abilities[ability_name]
		total_cooldowns += cooldown
		if cooldown == 0:
			ready_abilities += 1
	
	return {
		"total_abilities": abilities.size(),
		"ready_abilities": ready_abilities,
		"total_cooldowns": total_cooldowns,
		"average_cooldown": float(total_cooldowns) / abilities.size() if abilities.size() > 0 else 0.0
	}

func get_cooldown_system_statistics() -> Dictionary:
	"""Get overall cooldown system statistics"""
	var total_actors = actor_cooldowns.size()
	var total_abilities = 0
	var total_cooldowns = 0
	
	for actor_name in actor_cooldowns.keys():
		var actor_abilities = actor_cooldowns[actor_name]
		total_abilities += actor_abilities.size()
		
		for ability_name in actor_abilities.keys():
			total_cooldowns += actor_abilities[ability_name]
	
	return {
		"actors_with_cooldowns": total_actors,
		"total_abilities_tracked": total_abilities,
		"total_cooldowns": total_cooldowns,
		"average_abilities_per_actor": float(total_abilities) / total_actors if total_actors > 0 else 0.0,
		"average_cooldown_per_ability": float(total_cooldowns) / total_abilities if total_abilities > 0 else 0.0,
		"total_history": cooldown_history.size()
	} 