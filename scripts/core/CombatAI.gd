extends Node
class_name CombatAI

# Combat AI System - Advanced AI for enemy combat behavior
# Handles decision making, learning, adaptation, and narrative awareness

signal ai_action_selected(action, actor, target, reasoning)
signal ai_emotion_changed(actor, old_emotion, new_emotion)
signal ai_pattern_learned(pattern_key, frequency)
signal ai_adaptation_triggered(actor, adaptation_type)

# AI Personality Types
enum AI_Personality {
	AGGRESSIVE,    # Prioritizes damage and offensive actions
	DEFENSIVE,     # Prioritizes survival and defensive actions
	STRATEGIC,     # Balances offense/defense with tactical thinking
	SUPPORT,       # Focuses on team support and healing
	ADAPTIVE       # Changes behavior based on situation
}

# Emotional States
enum EmotionalState {
	CALM,          # Balanced state
	DETERMINED,    # Focused and resolute
	FEARFUL,       # Defensive and cautious
	ANGRY,         # Aggressive and reckless
	DESPERATE,     # High risk, high reward
	CONFIDENT      # Optimistic and bold
}

# AI Configuration
var personality: AI_Personality = AI_Personality.STRATEGIC
var current_emotion: EmotionalState = EmotionalState.CALM
var learning_enabled: bool = true
var adaptation_rate: float = 0.1
var exploration_rate: float = 0.15

# Learning and Memory Systems
var player_patterns: Dictionary = {}
var counter_strategies: Dictionary = {}
var combat_memory: Array[Dictionary] = []
var q_table: Dictionary = {}

# Decision Weights
var decision_weights: Dictionary = {
	"action_effectiveness": 0.3,
	"elemental_advantage": 0.2,
	"target_priority": 0.25,
	"team_synergy": 0.15,
	"survival_instinct": 0.1
}

# Emotional Modifiers
var emotional_modifiers: Dictionary = {
	EmotionalState.DESPERATE: {"critical_chance": 1.5, "defense": 0.7, "description": "Fighting for survival"},
	EmotionalState.FEARFUL: {"speed": 1.3, "attack": 0.8, "description": "Driven by fear"},
	EmotionalState.ANGRY: {"attack": 1.4, "magic_defense": 0.6, "description": "Consumed by rage"},
	EmotionalState.CONFIDENT: {"accuracy": 1.2, "critical_chance": 1.3, "description": "Bold and assured"},
	EmotionalState.DETERMINED: {"defense": 1.2, "magic_attack": 1.1, "description": "Filled with resolve"},
	EmotionalState.CALM: {"magic_attack": 1.1, "accuracy": 1.1, "description": "Centered and focused"}
}

# Narrative Context
var story_context: Dictionary = {}
var character_relationships: Dictionary = {}
var world_knowledge: Dictionary = {}

# Team Coordination
var team_strategies: Dictionary = {}
var coordination_level: float = 0.5

func _ready():
	"""Initialize the AI system"""
	print("CombatAI: Initialized with personality: %s" % AI_Personality.keys()[personality])
	
	# Initialize learning systems
	initialize_learning_systems()
	
	# Load AI data from save if available
	load_ai_data()

func initialize_learning_systems():
	"""Initialize all learning and memory systems"""
	player_patterns.clear()
	counter_strategies.clear()
	combat_memory.clear()
	q_table.clear()
	
	print("CombatAI: Learning systems initialized")

func make_decision(actor, enemies, allies) -> CombatAction:
	"""Main decision-making function for AI"""
	if not actor or enemies.size() == 0:
		return null
	
	# Update emotional state based on combat situation
	update_emotional_state(actor, enemies, allies)
	
	# Get available actions
	var available_actions = actor.get_available_actions()
	if available_actions.size() == 0:
		return null
	
	# Calculate scores for each action
	var action_scores = {}
	for action in available_actions:
		var score = calculate_action_score(action, actor, enemies, allies)
		action_scores[action] = score
	
	# Select best action
	var best_action = select_best_action(action_scores)
	
	# Learn from this decision
	if learning_enabled:
		learn_from_decision(actor, best_action, enemies, allies)
	
	# Emit signal with reasoning
	var reasoning = generate_decision_reasoning(best_action, action_scores[best_action])
	ai_action_selected.emit(best_action, actor, get_best_target(best_action, enemies), reasoning)
	
	return best_action

func calculate_action_score(action, actor, enemies, allies) -> float:
	"""Calculate a score for an action based on multiple factors"""
	var score = 0.0
	
	# Base action effectiveness
	score += action.power * decision_weights["action_effectiveness"]
	
	# Elemental advantage
	score += calculate_elemental_bonus(action, enemies) * decision_weights["elemental_advantage"]
	
	# Target priority
	score += calculate_target_priority(action, enemies) * decision_weights["target_priority"]
	
	# Team synergy
	score += calculate_team_synergy(action, allies) * decision_weights["team_synergy"]
	
	# Survival instinct
	score += calculate_survival_score(action, actor) * decision_weights["survival_instinct"]
	
	# Emotional modifiers
	score = apply_emotional_modifiers(score, action)
	
	# Narrative considerations
	if not is_narrative_appropriate(action, actor, enemies):
		score *= 0.5  # Reduce score for inappropriate actions
	
	return score

func calculate_elemental_bonus(action, enemies) -> float:
	"""Calculate elemental advantage bonus"""
	var total_bonus = 0.0
	
	for enemy in enemies:
		if action.element != "" and enemy.has_method("get_elemental_affinity"):
			var enemy_element = enemy.get_elemental_affinity()
			var effectiveness = get_elemental_effectiveness(action.element, enemy_element)
			total_bonus += effectiveness
	
	return total_bonus / enemies.size()

func calculate_target_priority(action, enemies) -> float:
	"""Calculate target priority score"""
	var best_target = get_best_target(action, enemies)
	if not best_target:
		return 0.0
	
	var score = 0.0
	
	# Health-based targeting
	var health_ratio = float(best_target.health_points) / float(best_target.max_health_points)
	if health_ratio < 0.3:
		score += 50  # Prioritize weak enemies
	elif health_ratio < 0.6:
		score += 30
	
	# Threat assessment
	score += best_target.attack * 0.5
	score += best_target.magic_attack * 0.3
	
	# Position-based targeting
	if best_target.has_method("get_position"):
		var position = best_target.get_position()
		if position == "front":
			score += 10  # Front-line priority
	
	return score

func calculate_team_synergy(action, allies) -> float:
	"""Calculate team synergy bonus"""
	var synergy_score = 0.0
	
	for ally in allies:
		if ally.has_method("get_character_class"):
			var ally_class = ally.get_character_class()
			var action_type = action.get_action_type_name()
			
			# Class-based synergy
			match ally_class.to_lower():
				"warrior":
					if action_type == "Attack":
						synergy_score += 10
				"mage":
					if action_type == "Spell":
						synergy_score += 10
				"cleric":
					if action_type == "Heal":
						synergy_score += 15
				"rogue":
					if action.critical_chance > 0.1:
						synergy_score += 8
	
	return synergy_score

func calculate_survival_score(action, actor) -> float:
	"""Calculate survival instinct score"""
	var score = 0.0
	var health_ratio = float(actor.health_points) / float(actor.max_health_points)
	
	# Defensive actions when low health
	if health_ratio < 0.3:
		if action.action_type == CombatAction.ActionType.BUFF or action.action_type == CombatAction.ActionType.HEAL:
			score += 30
		elif action.action_type == CombatAction.ActionType.ATTACK:
			score *= 0.7  # Reduce offensive actions when low health
	
	# Offensive actions when healthy
	elif health_ratio > 0.7:
		if action.action_type == CombatAction.ActionType.ATTACK:
			score += 20
	
	return score

func apply_emotional_modifiers(score: float, action) -> float:
	"""Apply emotional state modifiers to action score"""
	if not emotional_modifiers.has(current_emotion):
		return score
	
	var modifiers = emotional_modifiers[current_emotion]
	
	# Apply modifiers based on action type
	match action.action_type:
		CombatAction.ActionType.ATTACK:
			if modifiers.has("attack"):
				score *= modifiers["attack"]
		CombatAction.ActionType.SPELL:
			if modifiers.has("magic_attack"):
				score *= modifiers["magic_attack"]
		CombatAction.ActionType.HEAL:
			if modifiers.has("magic_attack"):
				score *= modifiers["magic_attack"]
		CombatAction.ActionType.BUFF:
			if modifiers.has("defense"):
				score *= modifiers["defense"]
	
	# Apply critical chance modifier
	if modifiers.has("critical_chance"):
		action.critical_chance *= modifiers["critical_chance"]
	
	return score

func get_best_target(action, enemies) -> CombatActor:
	"""Select the best target for an action"""
	if enemies.size() == 0:
		return null
	elif enemies.size() == 1:
		return enemies[0]
	
	var best_target = enemies[0]
	var best_score = -INF
	
	for enemy in enemies:
		var score = 0.0
		
		# Health-based targeting
		var health_ratio = float(enemy.health_points) / float(enemy.max_health_points)
		if health_ratio < 0.3:
			score += 50
		elif health_ratio < 0.6:
			score += 30
		
		# Elemental weakness
		if action.element != "" and enemy.has_method("get_elemental_affinity"):
			var enemy_element = enemy.get_elemental_affinity()
			var effectiveness = get_elemental_effectiveness(action.element, enemy_element)
			score += effectiveness * 20
		
		# Threat assessment
		score += enemy.attack * 0.5
		score += enemy.magic_attack * 0.3
		
		if score > best_score:
			best_score = score
			best_target = enemy
	
	return best_target

func select_best_action(action_scores: Dictionary) -> CombatAction:
	"""Select the best action based on scores"""
	if action_scores.size() == 0:
		return null
	
	var best_action = null
	var best_score = -INF
	
	# Exploration vs exploitation
	if randf() < exploration_rate:
		var actions = action_scores.keys()
		return actions[randi() % actions.size()]
	
	# Exploit learned knowledge
	for action in action_scores:
		var score = action_scores[action]
		if score > best_score:
			best_score = score
			best_action = action
	
	return best_action

func update_emotional_state(actor, enemies, allies):
	"""Update AI emotional state based on combat situation"""
	var old_emotion = current_emotion
	var health_ratio = float(actor.health_points) / float(actor.max_health_points)
	var allies_alive = allies.size()
	var enemies_alive = enemies.size()
	
	var new_emotion = EmotionalState.CALM
	
	if health_ratio < 0.2:
		new_emotion = EmotionalState.DESPERATE
	elif health_ratio < 0.5:
		new_emotion = EmotionalState.FEARFUL
	elif allies_alive < enemies_alive:
		new_emotion = EmotionalState.DETERMINED
	elif health_ratio > 0.8 and allies_alive > enemies_alive:
		new_emotion = EmotionalState.CONFIDENT
	elif randf() < 0.1:  # 10% chance to become angry
		new_emotion = EmotionalState.ANGRY
	
	if new_emotion != current_emotion:
		ai_emotion_changed.emit(actor, old_emotion, new_emotion)
		current_emotion = new_emotion
		
		var emotion_name = EmotionalState.keys()[new_emotion]
		print("CombatAI: %s's emotion changed to %s" % [actor.character_name, emotion_name])

func learn_from_decision(actor, action, enemies, allies):
	"""Learn from the current decision for future improvements"""
	# Check if action is valid
	if action == null:
		print("CombatAI: Warning - Cannot learn from null action decision")
		return
	
	var decision_data = {
		"actor": actor.character_name,
		"action": action.name,
		"emotion": current_emotion,
		"health_ratio": float(actor.health_points) / float(actor.max_health_points),
		"enemies_count": enemies.size(),
		"allies_count": allies.size(),
		"timestamp": Time.get_unix_time_from_system()
	}
	
	combat_memory.append(decision_data)
	
	# Keep memory size manageable
	if combat_memory.size() > 100:
		combat_memory.pop_front()
	
	# Learn player patterns if this is a player action
	if actor == get_node("/root/CombatManager").player_actor:
		learn_player_pattern(action, enemies)
		ai_adaptation_triggered.emit(actor, "pattern_learning")

func learn_player_pattern(action, enemies):
	"""Learn patterns from player actions"""
	# Check if action is valid before proceeding
	if action == null:
		print("CombatAI: Warning - Cannot learn pattern from null action")
		return
	
	var pattern_key = "%s_%s" % [action.name, enemies.size()]
	
	if not player_patterns.has(pattern_key):
		player_patterns[pattern_key] = 0
	
	player_patterns[pattern_key] += 1
	
	# Develop counter strategies
	develop_counter_strategy(action, enemies)
	
	ai_pattern_learned.emit(pattern_key, player_patterns[pattern_key])
	print("CombatAI: Learned player pattern: %s (frequency: %d)" % [pattern_key, player_patterns[pattern_key]])

func develop_counter_strategy(action, _enemies):
	"""Develop counter strategies against player actions"""
	# Check if action is valid before proceeding
	if action == null:
		print("CombatAI: Warning - Cannot develop counter strategy for null action")
		return
	
	var counter = {
		"action_type": "defensive",
		"target_priority": "self",
		"elemental_focus": get_counter_element(action.element)
	}
	
	counter_strategies[action.name] = counter
	print("CombatAI: Developed counter strategy for %s" % action.name)

func get_counter_element(element: String) -> String:
	"""Get the counter element for a given element"""
	var counter_elements = {
		"fire": "water",
		"ice": "fire", 
		"lightning": "earth",
		"water": "lightning",
		"earth": "wind",
		"wind": "ice",
		"shadow": "light",
		"light": "shadow",
		"void": "tech",
		"tech": "void"
	}
	return counter_elements.get(element, "physical")

func get_elemental_effectiveness(attack_element: String, defense_element: String) -> float:
	"""Get elemental effectiveness multiplier"""
	var combat_manager = get_node("/root/CombatManager")
	if combat_manager and combat_manager.elemental_effectiveness.has(attack_element):
		var effectiveness = combat_manager.elemental_effectiveness[attack_element]
		return effectiveness.get(defense_element, 1.0)
	return 1.0

func is_narrative_appropriate(action, actor, enemies) -> bool:
	"""Check if an action is narratively appropriate"""
	# Check if action is valid
	if action == null:
		return false
	
	# Consider story context
	if story_context.has("current_quest"):
		var quest = story_context["current_quest"]
		if quest.type == "rescue" and enemies.has(quest.target):
			return false  # Don't attack rescue target
	
	# Consider relationships
	if character_relationships.has(actor.character_name):
		var relationships = character_relationships[actor.character_name]
		for enemy in enemies:
			if relationships.has(enemy.character_name):
				var relationship = relationships[enemy.character_name]
				if relationship.type == "ally":
					return false  # Don't attack allies
	
	# Consider world knowledge
	if world_knowledge.has("current_world"):
		var world = world_knowledge["current_world"]
		if world.has("forbidden_actions"):
			if world["forbidden_actions"].has(action.name):
				return false  # Don't use forbidden actions
	
	return true

func generate_decision_reasoning(action, score: float) -> String:
	"""Generate human-readable reasoning for AI decision"""
	# Check if action is valid
	if action == null:
		return "No action selected (null action)"
	
	var reasoning = "%s chooses %s" % [action.name, action.name]
	
	if score > 50:
		reasoning += " (excellent tactical choice)"
	elif score > 30:
		reasoning += " (good strategic move)"
	elif score > 10:
		reasoning += " (reasonable option)"
	else:
		reasoning += " (desperate measure)"
	
	# Add emotional context
	var emotion_name = EmotionalState.keys()[current_emotion]
	reasoning += " while feeling %s" % emotion_name.lower()
	
	return reasoning

func set_personality(new_personality: AI_Personality):
	"""Set the AI personality type"""
	# Validate the personality value
	if new_personality < 0 or new_personality >= AI_Personality.size():
		print("CombatAI: Invalid personality value %d, keeping current personality %s" % [new_personality, AI_Personality.keys()[personality]])
		return
	
	personality = new_personality
	print("CombatAI: Personality set to %s" % AI_Personality.keys()[personality])

func set_learning_enabled(enabled: bool):
	"""Enable or disable learning"""
	learning_enabled = enabled
	print("CombatAI: Learning %s" % ("enabled" if enabled else "disabled"))

func set_adaptation_rate(rate: float):
	"""Set the adaptation rate for learning"""
	adaptation_rate = clamp(rate, 0.0, 1.0)
	print("CombatAI: Adaptation rate set to %.2f" % adaptation_rate)

func set_exploration_rate(rate: float):
	"""Set the exploration rate for decision making"""
	exploration_rate = clamp(rate, 0.0, 1.0)
	print("CombatAI: Exploration rate set to %.2f" % exploration_rate)

func get_ai_statistics() -> Dictionary:
	"""Get AI system statistics"""
	return {
		"personality": AI_Personality.keys()[personality],
		"current_emotion": EmotionalState.keys()[current_emotion],
		"learning_enabled": learning_enabled,
		"adaptation_rate": adaptation_rate,
		"exploration_rate": exploration_rate,
		"patterns_learned": player_patterns.size(),
		"counter_strategies": counter_strategies.size(),
		"combat_memory_size": combat_memory.size(),
		"q_table_size": q_table.size()
	}

func save_ai_data():
	"""Save AI learning data"""
	var save_data = {
		"player_patterns": player_patterns,
		"counter_strategies": counter_strategies,
		"combat_memory": combat_memory,
		"q_table": q_table,
		"personality": personality,
		"adaptation_rate": adaptation_rate,
		"exploration_rate": exploration_rate
	}
	
	var save_system = get_node("/root/SaveSystem")
	if save_system:
		save_system.save_ai_data(save_data)
		print("CombatAI: AI data saved")

func load_ai_data():
	"""Load AI learning data"""
	var save_system = get_node("/root/SaveSystem")
	if save_system:
		var ai_data = save_system.load_ai_data()
		if ai_data.has("player_patterns"):
			player_patterns = ai_data["player_patterns"]
		if ai_data.has("counter_strategies"):
			counter_strategies = ai_data["counter_strategies"]
		if ai_data.has("combat_memory"):
			combat_memory = ai_data["combat_memory"]
		if ai_data.has("q_table"):
			q_table = ai_data["q_table"]
		if ai_data.has("personality"):
			personality = ai_data["personality"]
		if ai_data.has("adaptation_rate"):
			adaptation_rate = ai_data["adaptation_rate"]
		if ai_data.has("exploration_rate"):
			exploration_rate = ai_data["exploration_rate"]
		
		print("CombatAI: AI data loaded (%d patterns, %d strategies)" % [player_patterns.size(), counter_strategies.size()])

func clear_learning_data():
	"""Clear all learning data"""
	player_patterns.clear()
	counter_strategies.clear()
	combat_memory.clear()
	q_table.clear()
	print("CombatAI: All learning data cleared") 
