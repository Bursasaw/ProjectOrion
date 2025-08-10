extends Node
class_name ReinforcementLearningAI

# Reinforcement Learning AI System
# Implements Q-learning for adaptive AI behavior

signal rl_action_selected(action, state_key, q_value)
signal rl_learning_update(state_key, action_key, old_q, new_q)
signal rl_episode_completed(episode_reward, episode_length)

# RL Configuration
var learning_rate: float = 0.1
var discount_factor: float = 0.9
var exploration_rate: float = 0.15
var min_exploration_rate: float = 0.05
var exploration_decay: float = 0.995

# Q-Learning Table
var q_table: Dictionary = {}
var state_visits: Dictionary = {}

# Episode Tracking
var current_episode: Dictionary = {}
var episode_rewards: Array[float] = []
var episode_lengths: Array[int] = []

# Performance Metrics
var total_rewards: float = 0.0
var episodes_completed: int = 0
var average_reward: float = 0.0
var average_episode_length: float = 0.0

func _ready():
	"""Initialize the RL AI system"""
	print("ReinforcementLearningAI: Initialized")
	load_rl_data()

func get_state_key(combat_situation) -> String:
	"""Convert combat situation to state key"""
	var state = {
		"self_health_ratio": combat_situation.self_health_ratio,
		"enemies_alive": combat_situation.enemies_alive,
		"allies_alive": combat_situation.allies_alive,
		"current_weather": combat_situation.weather,
		"surface_type": combat_situation.surface_type,
		"turn_number": combat_situation.turn_number,
		"action_points_remaining": combat_situation.action_points_remaining
	}
	return str(state)

func select_action_with_rl(combat_situation, available_actions: Array) -> CombatAction:
	"""Select action using Q-learning with exploration"""
	var state_key = get_state_key(combat_situation)
	
	# Update exploration rate
	update_exploration_rate()
	
	# Exploration vs exploitation
	if randf() < exploration_rate:
		var random_action = available_actions[randi() % available_actions.size()]
		rl_action_selected.emit(random_action, state_key, 0.0)
		return random_action
	
	# Exploit learned knowledge
	var best_action = null
	var best_q_value = -INF
	
	for action in available_actions:
		var action_key = "%s_%s" % [state_key, action.name]
		var q_value = q_table.get(action_key, 0.0)
		
		if q_value > best_q_value:
			best_q_value = q_value
			best_action = action
	
	if best_action:
		rl_action_selected.emit(best_action, state_key, best_q_value)
		return best_action
	else:
		# Fallback to random action
		var random_action = available_actions[randi() % available_actions.size()]
		rl_action_selected.emit(random_action, state_key, 0.0)
		return random_action

func update_q_value(state_key: String, action_name: String, reward: float, next_state_key: String):
	"""Update Q-value using Q-learning formula"""
	var action_key = "%s_%s" % [state_key, action_name]
	var current_q = q_table.get(action_key, 0.0)
	
	# Get maximum Q-value for next state
	var max_next_q = get_max_q_value(next_state_key)
	
	# Q-learning update formula: Q(s,a) = Q(s,a) + α[r + γ*max(Q(s',a')) - Q(s,a)]
	var new_q = current_q + learning_rate * (reward + discount_factor * max_next_q - current_q)
	
	# Update Q-table
	q_table[action_key] = new_q
	
	# Track state visits
	if not state_visits.has(state_key):
		state_visits[state_key] = 0
	state_visits[state_key] += 1
	
	# Emit learning signal
	rl_learning_update.emit(state_key, action_key, current_q, new_q)
	
	print("ReinforcementLearningAI: Updated Q-value for %s: %.2f -> %.2f" % [action_key, current_q, new_q])

func get_max_q_value(_state_key: String) -> float:
	"""Get maximum Q-value for a given state"""
	# This would need to be implemented based on available actions
	# For now, return 0.0 as placeholder
	return 0.0

func calculate_reward(action, actor, _target, result) -> float:
	"""Calculate reward for an action based on its outcome"""
	var reward = 0.0
	
	# Base reward for action execution
	reward += 1.0
	
	# Damage dealt reward
	if result.has("damage_dealt"):
		reward += result["damage_dealt"] * 0.1
	
	# Critical hit bonus
	if result.has("critical_hit") and result["critical_hit"]:
		reward += 5.0
	
	# Elemental effectiveness bonus
	if result.has("elemental_effectiveness"):
		var effectiveness = result["elemental_effectiveness"]
		if effectiveness > 1.0:
			reward += (effectiveness - 1.0) * 10.0
	
	# Target elimination bonus
	if result.has("target_defeated") and result["target_defeated"]:
		reward += 20.0
	
	# Self-damage penalty
	if result.has("self_damage"):
		reward -= result["self_damage"] * 0.2
	
	# Action cost penalty
	if action.has_method("get_action_cost"):
		var cost = action.get_action_cost()
		reward -= cost * 0.5
	
	# Survival bonus
	var health_ratio = float(actor.health_points) / float(actor.max_health_points)
	if health_ratio < 0.3:
		reward += 10.0  # Bonus for surviving when low health
	
	return reward

func start_episode():
	"""Start a new learning episode"""
	current_episode = {
		"start_time": Time.get_unix_time_from_system(),
		"actions": [],
		"rewards": [],
		"total_reward": 0.0
	}
	print("ReinforcementLearningAI: Started new episode")

func end_episode():
	"""End the current episode and update statistics"""
	if current_episode.has("actions") and current_episode["actions"].size() > 0:
		var episode_length = current_episode["actions"].size()
		var episode_reward = current_episode["total_reward"]
		
		episode_rewards.append(episode_reward)
		episode_lengths.append(episode_length)
		
		# Update statistics
		total_rewards += episode_reward
		episodes_completed += 1
		average_reward = total_rewards / episodes_completed
		average_episode_length = calculate_average(episode_lengths)
		
		# Keep only recent episodes for statistics
		if episode_rewards.size() > 100:
			episode_rewards.pop_front()
			episode_lengths.pop_front()
		
		rl_episode_completed.emit(episode_reward, episode_length)
		print("ReinforcementLearningAI: Episode completed - Reward: %.2f, Length: %d" % [episode_reward, episode_length])

func record_action(action, state_key: String, reward: float):
	"""Record an action taken during the episode"""
	if current_episode.has("actions"):
		current_episode["actions"].append({
			"action": action.name,
			"state_key": state_key,
			"reward": reward
		})
		current_episode["rewards"].append(reward)
		current_episode["total_reward"] += reward

func update_exploration_rate():
	"""Update exploration rate with decay"""
	exploration_rate = max(min_exploration_rate, exploration_rate * exploration_decay)

func get_rl_statistics() -> Dictionary:
	"""Get RL system statistics"""
	return {
		"learning_rate": learning_rate,
		"discount_factor": discount_factor,
		"exploration_rate": exploration_rate,
		"q_table_size": q_table.size(),
		"state_visits": state_visits.size(),
		"episodes_completed": episodes_completed,
		"average_reward": average_reward,
		"average_episode_length": average_episode_length,
		"total_rewards": total_rewards
	}

func set_learning_rate(rate: float):
	"""Set the learning rate"""
	learning_rate = clamp(rate, 0.0, 1.0)
	print("ReinforcementLearningAI: Learning rate set to %.2f" % learning_rate)

func set_discount_factor(factor: float):
	"""Set the discount factor"""
	discount_factor = clamp(factor, 0.0, 1.0)
	print("ReinforcementLearningAI: Discount factor set to %.2f" % discount_factor)

func set_exploration_rate(rate: float):
	"""Set the exploration rate"""
	exploration_rate = clamp(rate, 0.0, 1.0)
	print("ReinforcementLearningAI: Exploration rate set to %.2f" % exploration_rate)

func set_min_exploration_rate(rate: float):
	"""Set the minimum exploration rate"""
	min_exploration_rate = clamp(rate, 0.0, 1.0)
	print("ReinforcementLearningAI: Min exploration rate set to %.2f" % min_exploration_rate)

func set_exploration_decay(decay: float):
	"""Set the exploration decay rate"""
	exploration_decay = clamp(decay, 0.0, 1.0)
	print("ReinforcementLearningAI: Exploration decay set to %.3f" % exploration_decay)

func calculate_average(values: Array) -> float:
	"""Calculate average of an array of values"""
	if values.size() == 0:
		return 0.0
	
	var sum = 0.0
	for value in values:
		sum += value
	
	return sum / values.size()

func save_rl_data():
	"""Save RL learning data"""
	var save_data = {
		"q_table": q_table,
		"state_visits": state_visits,
		"episode_rewards": episode_rewards,
		"episode_lengths": episode_lengths,
		"total_rewards": total_rewards,
		"episodes_completed": episodes_completed,
		"average_reward": average_reward,
		"average_episode_length": average_episode_length,
		"learning_rate": learning_rate,
		"discount_factor": discount_factor,
		"exploration_rate": exploration_rate,
		"min_exploration_rate": min_exploration_rate,
		"exploration_decay": exploration_decay
	}
	
	var save_system = get_node("/root/SaveSystem")
	if save_system:
		save_system.save_rl_data(save_data)
		print("ReinforcementLearningAI: RL data saved")

func load_rl_data():
	"""Load RL learning data"""
	var save_system = get_node("/root/SaveSystem")
	if save_system:
		var rl_data = save_system.load_rl_data()
		if rl_data.has("q_table"):
			q_table = rl_data["q_table"]
		if rl_data.has("state_visits"):
			state_visits = rl_data["state_visits"]
		if rl_data.has("episode_rewards"):
			episode_rewards = rl_data["episode_rewards"]
		if rl_data.has("episode_lengths"):
			episode_lengths = rl_data["episode_lengths"]
		if rl_data.has("total_rewards"):
			total_rewards = rl_data["total_rewards"]
		if rl_data.has("episodes_completed"):
			episodes_completed = rl_data["episodes_completed"]
		if rl_data.has("average_reward"):
			average_reward = rl_data["average_reward"]
		if rl_data.has("average_episode_length"):
			average_episode_length = rl_data["average_episode_length"]
		if rl_data.has("learning_rate"):
			learning_rate = rl_data["learning_rate"]
		if rl_data.has("discount_factor"):
			discount_factor = rl_data["discount_factor"]
		if rl_data.has("exploration_rate"):
			exploration_rate = rl_data["exploration_rate"]
		if rl_data.has("min_exploration_rate"):
			min_exploration_rate = rl_data["min_exploration_rate"]
		if rl_data.has("exploration_decay"):
			exploration_decay = rl_data["exploration_decay"]
		
		print("ReinforcementLearningAI: RL data loaded (%d Q-values, %d episodes)" % [q_table.size(), episodes_completed])

func clear_rl_data():
	"""Clear all RL learning data"""
	q_table.clear()
	state_visits.clear()
	episode_rewards.clear()
	episode_lengths.clear()
	total_rewards = 0.0
	episodes_completed = 0
	average_reward = 0.0
	average_episode_length = 0.0
	print("ReinforcementLearningAI: All RL data cleared")

func get_best_action_for_state(state_key: String, available_actions: Array) -> CombatAction:
	"""Get the best action for a given state based on Q-values"""
	var best_action = null
	var best_q_value = -INF
	
	for action in available_actions:
		var action_key = "%s_%s" % [state_key, action.name]
		var q_value = q_table.get(action_key, 0.0)
		
		if q_value > best_q_value:
			best_q_value = q_value
			best_action = action
	
	return best_action

func get_q_value_for_action(state_key: String, action_name: String) -> float:
	"""Get Q-value for a specific state-action pair"""
	var action_key = "%s_%s" % [state_key, action_name]
	return q_table.get(action_key, 0.0)

func get_state_visit_count(state_key: String) -> int:
	"""Get visit count for a specific state"""
	return state_visits.get(state_key, 0) 