extends Node
class_name NarrativeAI

# Narrative AI System
# Makes AI decisions based on story context and character relationships

signal narrative_decision_made(action, actor, target, reasoning)
signal story_context_updated(context_key, new_value)
signal relationship_changed(actor1, actor2, relationship_type)

# Story Context
var current_quest: Dictionary = {}
var world_state: Dictionary = {}
var character_relationships: Dictionary = {}
var faction_relationships: Dictionary = {}
var world_knowledge: Dictionary = {}

# Narrative Rules
var forbidden_actions: Array[String] = []
var required_actions: Array[String] = []
var story_priorities: Dictionary = {}

# Character Personalities
var character_personalities: Dictionary = {}
var character_goals: Dictionary = {}
var character_fears: Dictionary = {}

func _ready():
	"""Initialize the narrative AI system"""
	print("NarrativeAI: Initialized")
	initialize_narrative_systems()

func initialize_narrative_systems():
	"""Initialize all narrative systems"""
	# Initialize world knowledge
	world_knowledge = {
		"nokturn": {
			"forbidden_actions": ["light_spell", "purify"],
			"required_actions": ["shadow_embrace", "void_touch"],
			"description": "Shadow realm where light is forbidden"
		},
		"elysion": {
			"forbidden_actions": ["shadow_spell", "corrupt"],
			"required_actions": ["light_blessing", "purify"],
			"description": "Cradle of the Ancients where light prevails"
		},
		"sylithar": {
			"forbidden_actions": ["ice_spell", "freeze"],
			"required_actions": ["fire_embrace", "solar_power"],
			"description": "Desert of Glass where fire rules"
		},
		"terra": {
			"forbidden_actions": ["wind_spell", "levitate"],
			"required_actions": ["earth_strength", "ground_anchor"],
			"description": "Primal Heart where earth is sacred"
		},
		"aethra": {
			"forbidden_actions": ["earth_spell", "heavy_armor"],
			"required_actions": ["wind_dance", "sky_grace"],
			"description": "Skybound Archipelago where wind is freedom"
		},
		"ombra": {
			"forbidden_actions": ["light_spell", "hope"],
			"required_actions": ["void_embrace", "despair"],
			"description": "Veiled Depths where void consumes all"
		},
		"krynn": {
			"forbidden_actions": ["tech_spell", "mechanical"],
			"required_actions": ["dragon_essence", "primal_fire"],
			"description": "Dragon Dominion where dragons rule"
		},
		"tauron": {
			"forbidden_actions": ["nature_spell", "organic"],
			"required_actions": ["tech_enhance", "cybernetic"],
			"description": "Nexus of Flesh and Machine where technology reigns"
		},
		"aelria": {
			"forbidden_actions": ["physical_spell", "brute_force"],
			"required_actions": ["will_power", "reality_bend"],
			"description": "Realm of Manifested Will where mind shapes reality"
		}
	}
	
	# Initialize story priorities
	story_priorities = {
		"quest_objective": 10.0,
		"character_survival": 8.0,
		"faction_loyalty": 7.0,
		"personal_goal": 6.0,
		"world_harmony": 5.0,
		"self_preservation": 4.0
	}
	
	print("NarrativeAI: Narrative systems initialized")

func set_current_quest(quest: Dictionary):
	"""Set the current quest context"""
	current_quest = quest
	story_context_updated.emit("current_quest", quest)
	print("NarrativeAI: Current quest set: %s" % quest.get("name", "Unknown"))

func set_world_state(world: String, state: Dictionary):
	"""Set the current world state"""
	world_state[world] = state
	print("NarrativeAI: World state updated for %s" % world)

func set_character_relationship(actor1: String, actor2: String, relationship: Dictionary):
	"""Set relationship between two characters"""
	if not character_relationships.has(actor1):
		character_relationships[actor1] = {}
	
	character_relationships[actor1][actor2] = relationship
	relationship_changed.emit(actor1, actor2, relationship.get("type", "unknown"))
	print("NarrativeAI: Relationship set between %s and %s: %s" % [actor1, actor2, relationship.get("type", "unknown")])

func set_faction_relationship(faction1: String, faction2: String, relationship: Dictionary):
	"""Set relationship between two factions"""
	if not faction_relationships.has(faction1):
		faction_relationships[faction1] = {}
	
	faction_relationships[faction1][faction2] = relationship
	print("NarrativeAI: Faction relationship set between %s and %s: %s" % [faction1, faction2, relationship.get("type", "unknown")])

func set_character_personality(character: String, personality: Dictionary):
	"""Set personality traits for a character"""
	character_personalities[character] = personality
	print("NarrativeAI: Personality set for %s" % character)

func set_character_goal(character: String, goal: Dictionary):
	"""Set personal goal for a character"""
	character_goals[character] = goal
	print("NarrativeAI: Goal set for %s: %s" % [character, goal.get("description", "Unknown")])

func set_character_fear(character: String, fear: Dictionary):
	"""Set fear for a character"""
	character_fears[character] = fear
	print("NarrativeAI: Fear set for %s: %s" % [character, fear.get("description", "Unknown")])

func is_narrative_appropriate(action: CombatAction, actor: CombatActor, target: CombatActor) -> bool:
	"""Check if an action is narratively appropriate"""
	var actor_name = actor.character_name
	var target_name = target.character_name if target else ""
	
	# Check quest context
	if current_quest.has("type") and current_quest["type"] == "rescue":
		if current_quest.has("target") and target_name == current_quest["target"]:
			return false  # Don't attack rescue target
	
	# Check character relationships
	if character_relationships.has(actor_name):
		var relationships = character_relationships[actor_name]
		if relationships.has(target_name):
			var relationship = relationships[target_name]
			if relationship.get("type") == "ally":
				return false  # Don't attack allies
			elif relationship.get("type") == "enemy":
				return true   # Encouraged to attack enemies
	
	# Check world-specific restrictions
	var current_world = get_current_world()
	if world_knowledge.has(current_world):
		var world_rules = world_knowledge[current_world]
		if world_rules.has("forbidden_actions"):
			if action.name in world_rules["forbidden_actions"]:
				return false  # Action forbidden in this world
	
	# Check character personality
	if character_personalities.has(actor_name):
		var personality = character_personalities[actor_name]
		if personality.has("forbidden_actions"):
			if action.name in personality["forbidden_actions"]:
				return false  # Action against character's personality
	
	return true

func calculate_narrative_score(action: CombatAction, actor: CombatActor, target: CombatActor) -> float:
	"""Calculate narrative appropriateness score for an action"""
	var score = 1.0
	
	# Base appropriateness
	if not is_narrative_appropriate(action, actor, target):
		score *= 0.3  # Significant penalty for inappropriate actions
	
	# Quest alignment bonus
	if current_quest.has("objectives"):
		for objective in current_quest["objectives"]:
			if objective.has("action_type") and action.action_type == objective["action_type"]:
				score *= story_priorities["quest_objective"]
	
	# Character goal alignment
	var actor_name = actor.character_name
	if character_goals.has(actor_name):
		var goal = character_goals[actor_name]
		if goal.has("preferred_actions") and action.name in goal["preferred_actions"]:
			score *= story_priorities["personal_goal"]
	
	# Faction loyalty
	if actor.has_method("get_faction") and target.has_method("get_faction"):
		var actor_faction = actor.get_faction()
		var target_faction = target.get_faction()
		
		if faction_relationships.has(actor_faction):
			var relationships = faction_relationships[actor_faction]
			if relationships.has(target_faction):
				var relationship = relationships[target_faction]
				if relationship.get("type") == "enemy":
					score *= story_priorities["faction_loyalty"]
				elif relationship.get("type") == "ally":
					score *= 0.5  # Penalty for attacking allies
	
	# World harmony
	var current_world = get_current_world()
	if world_knowledge.has(current_world):
		var world_rules = world_knowledge[current_world]
		if world_rules.has("required_actions") and action.name in world_rules["required_actions"]:
			score *= story_priorities["world_harmony"]
	
	return score

func generate_narrative_reasoning(action: CombatAction, actor: CombatActor, target: CombatActor) -> String:
	"""Generate narrative reasoning for an action"""
	var reasoning = "%s chooses %s" % [actor.character_name, action.name]
	
	# Emit narrative decision signal
	narrative_decision_made.emit(action, actor, target, reasoning)
	
	# Add quest context
	if current_quest.has("name"):
		reasoning += " in pursuit of the quest: %s" % current_quest["name"]
	
	# Add relationship context
	var actor_name = actor.character_name
	var target_name = target.character_name if target else ""
	
	if character_relationships.has(actor_name):
		var relationships = character_relationships[actor_name]
		if relationships.has(target_name):
			var relationship = relationships[target_name]
			reasoning += " despite their %s relationship" % relationship.get("type", "complicated")
	
	# Add world context
	var current_world = get_current_world()
	if world_knowledge.has(current_world):
		var world_rules = world_knowledge[current_world]
		if world_rules.has("description"):
			reasoning += " in the %s" % world_rules["description"]
	
	# Add personality context
	if character_personalities.has(actor_name):
		var personality = character_personalities[actor_name]
		if personality.has("trait"):
			reasoning += " showing their %s nature" % personality["trait"]
	
	return reasoning

func get_current_world() -> String:
	"""Get the current world context"""
	# This would be determined by the game state
	# For now, return a default
	return "elysion"

func modify_action_for_narrative(action: CombatAction, actor: CombatActor, target: CombatActor):
	"""Modify action based on narrative context"""
	var narrative_score = calculate_narrative_score(action, actor, target)
	
	# Apply narrative modifiers
	if narrative_score > 1.5:
		# Strong narrative alignment - boost action
		action.power = int(action.power * 1.2)
		action.critical_chance *= 1.3
		print("NarrativeAI: Action boosted due to strong narrative alignment")
	elif narrative_score < 0.5:
		# Poor narrative alignment - weaken action
		action.power = int(action.power * 0.8)
		action.accuracy *= 0.9
		print("NarrativeAI: Action weakened due to poor narrative alignment")
	
	# Apply world-specific modifiers
	var current_world = get_current_world()
	if world_knowledge.has(current_world):
		var world_rules = world_knowledge[current_world]
		if world_rules.has("required_actions") and action.name in world_rules["required_actions"]:
			action.power = int(action.power * 1.3)
			print("NarrativeAI: Action empowered by world alignment")

func should_avoid_action(action: CombatAction, actor: CombatActor, _target: CombatActor) -> bool:
	"""Determine if an action should be avoided for narrative reasons"""
	# Check for forbidden actions
	var current_world = get_current_world()
	if world_knowledge.has(current_world):
		var world_rules = world_knowledge[current_world]
		if world_rules.has("forbidden_actions") and action.name in world_rules["forbidden_actions"]:
			return true
	
	# Check character personality
	var actor_name = actor.character_name
	if character_personalities.has(actor_name):
		var personality = character_personalities[actor_name]
		if personality.has("forbidden_actions") and action.name in personality["forbidden_actions"]:
			return true
	
	# Check character fears
	if character_fears.has(actor_name):
		var fear = character_fears[actor_name]
		if fear.has("trigger_actions") and action.name in fear["trigger_actions"]:
			return true
	
	return false

func get_narrative_statistics() -> Dictionary:
	"""Get narrative AI statistics"""
	return {
		"current_quest": current_quest.get("name", "None"),
		"world_state_size": world_state.size(),
		"character_relationships": character_relationships.size(),
		"faction_relationships": faction_relationships.size(),
		"character_personalities": character_personalities.size(),
		"character_goals": character_goals.size(),
		"character_fears": character_fears.size(),
		"world_knowledge": world_knowledge.size()
	}

func clear_narrative_data():
	"""Clear all narrative data"""
	current_quest.clear()
	world_state.clear()
	character_relationships.clear()
	faction_relationships.clear()
	character_personalities.clear()
	character_goals.clear()
	character_fears.clear()
	print("NarrativeAI: All narrative data cleared")

func save_narrative_data():
	"""Save narrative data"""
	var save_data = {
		"current_quest": current_quest,
		"world_state": world_state,
		"character_relationships": character_relationships,
		"faction_relationships": faction_relationships,
		"character_personalities": character_personalities,
		"character_goals": character_goals,
		"character_fears": character_fears
	}
	
	var save_system = get_node("/root/SaveSystem")
	if save_system:
		save_system.save_narrative_data(save_data)
		print("NarrativeAI: Narrative data saved")

func load_narrative_data():
	"""Load narrative data"""
	var save_system = get_node("/root/SaveSystem")
	if save_system:
		var narrative_data = save_system.load_narrative_data()
		if narrative_data.has("current_quest"):
			current_quest = narrative_data["current_quest"]
		if narrative_data.has("world_state"):
			world_state = narrative_data["world_state"]
		if narrative_data.has("character_relationships"):
			character_relationships = narrative_data["character_relationships"]
		if narrative_data.has("faction_relationships"):
			faction_relationships = narrative_data["faction_relationships"]
		if narrative_data.has("character_personalities"):
			character_personalities = narrative_data["character_personalities"]
		if narrative_data.has("character_goals"):
			character_goals = narrative_data["character_goals"]
		if narrative_data.has("character_fears"):
			character_fears = narrative_data["character_fears"]
		
		print("NarrativeAI: Narrative data loaded") 