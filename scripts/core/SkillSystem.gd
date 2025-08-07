extends Node

# SkillSystem - Main controller for the deep progression system
# Inspired by Jedi Survivor's data-driven skill tree system
# Version 0.13.0

signal skill_unlocked(skill_id: String, skill_data: Dictionary)
signal skill_tree_unlocked(tree_id: String, tree_data: Dictionary)
signal stance_changed(new_stances: Array[String])
signal class_evolved(class_id: String, class_data: Dictionary)
signal achievement_completed(achievement_id: String, tier: String, reward: Dictionary)
signal progress_updated(stat_type: String, new_value: float)

# Core system data
var skill_trees: Dictionary = {}
var player_skills: Dictionary = {}
var skill_effects: Dictionary = {}
var cross_tree_synergies: Array = []
var stances: Dictionary = {}
var active_stances: Array[String] = []
var stance_skills: Dictionary = {}
var cross_stance_synergies: Dictionary = {}

# Class progression
var player_classes: Array[String] = []
var class_progression_data: Dictionary = {}
var available_classes: Dictionary = {}

# Achievement system
var achievements: Dictionary = {}
var progress_trackers: Dictionary = {}
var completed_achievements: Array[String] = []

# Player progression
var player_level: int = 1
var skill_points: int = 0
var experience: int = 0
var experience_to_next_level: int = 100

# Data files
var skill_trees_file: String = "res://data/skills/skill_trees.json"
var class_progression_file: String = "res://data/skills/class_progression.json"
var achievements_file: String = "res://data/skills/achievements.json"

# Performance optimization
var skill_cache: Dictionary = {}
var effect_cache: Dictionary = {}

func _ready():
	"""Initialize the skill system"""
	print("🎯 SkillSystem: Initializing deep progression system...")
	
	# Load all data files
	load_skill_trees()
	load_class_progression()
	load_achievements()
	
	# Initialize player data
	initialize_player_progression()
	
	# Set up default stances
	setup_default_stances()
	
	print("✅ SkillSystem: Deep progression system initialized successfully")

func load_skill_trees():
	"""Load skill tree data from JSON file"""
	var file = FileAccess.open(skill_trees_file, FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		if parse_result == OK:
			var data = json.data
			skill_trees = data.skill_trees
			stances = data.stances
			cross_tree_synergies = data.cross_tree_synergies
			print("📚 SkillSystem: Loaded ", skill_trees.size(), " skill trees and ", stances.size(), " stances")
		else:
			print("❌ SkillSystem: Failed to parse skill trees JSON")
		file.close()
	else:
		print("❌ SkillSystem: Could not open skill trees file")

func load_class_progression():
	"""Load class progression data from JSON file"""
	var file = FileAccess.open(class_progression_file, FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		if parse_result == OK:
			var data = json.data
			class_progression_data = data.class_tiers
			print("📚 SkillSystem: Loaded class progression data")
		else:
			print("❌ SkillSystem: Failed to parse class progression JSON")
		file.close()
	else:
		print("❌ SkillSystem: Could not open class progression file")

func load_achievements():
	"""Load achievement data from JSON file"""
	var file = FileAccess.open(achievements_file, FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		if parse_result == OK:
			var data = json.data
			achievements = data.achievement_categories
			print("📚 SkillSystem: Loaded achievement data")
		else:
			print("❌ SkillSystem: Failed to parse achievements JSON")
		file.close()
	else:
		print("❌ SkillSystem: Could not open achievements file")

func initialize_player_progression():
	"""Initialize player progression data"""
	player_level = 1
	skill_points = 10  # Starting skill points
	experience = 0
	experience_to_next_level = 100
	
	# Initialize progress trackers
	for category in achievements:
		for achievement_id in achievements[category].achievements:
			var achievement = achievements[category].achievements[achievement_id]
			for tier in achievement.tiers:
				var tracker_key = achievement_id + "_" + tier.name.to_lower()
				progress_trackers[tracker_key] = 0.0
	
	print("👤 SkillSystem: Player progression initialized")

func setup_default_stances():
	"""Set up default stances for the player"""
	active_stances = ["combat", "arcane"]  # Default stances
	update_available_skills()
	print("⚔️ SkillSystem: Default stances set: ", active_stances)

func get_available_skill_trees() -> Array[String]:
	"""Get skill trees available to the player based on level and stances"""
	var available_trees: Array[String] = []
	
	for tree_id in skill_trees:
		var tree = skill_trees[tree_id]
		if can_unlock_skill_tree(tree):
			available_trees.append(tree_id)
	
	return available_trees

func can_unlock_skill_tree(tree_data: Dictionary) -> bool:
	"""Check if a skill tree can be unlocked"""
	# Check level requirement
	if not tree_data.has("unlock_requirements") or tree_data.unlock_requirements.size() == 0:
		return false
	if player_level < tree_data.unlock_requirements[0].split("_")[1].to_int():
		return false
	
	# Check stance requirements
	if not tree_data.has("stance_requirements"):
		return false
	var has_required_stance = false
	for stance in tree_data.stance_requirements:
		if stance in active_stances:
			has_required_stance = true
			break
	
	return has_required_stance

func get_available_skills(tree_id: String) -> Array[Dictionary]:
	"""Get available skills in a specific tree"""
	var available_skills: Array[Dictionary] = []
	if not skill_trees.has(tree_id):
		return available_skills
	var tree = skill_trees[tree_id]
	
	if not tree.has("tiers"):
		return available_skills
	for tier_name in tree.tiers:
		var tier = tree.tiers[tier_name]
		if not tier.has("unlock_level") or not tier.has("skills"):
			continue
		if player_level >= tier.unlock_level:
			for skill in tier.skills:
				if can_unlock_skill(skill):
					available_skills.append(skill)
	
	return available_skills

func can_unlock_skill(skill_data: Dictionary) -> bool:
	"""Check if a skill can be unlocked"""
	# Check if already unlocked
	if not skill_data.has("id") or skill_data.id in player_skills:
		return false
	
	# Check prerequisites
	if skill_data.has("prerequisites"):
		for prerequisite in skill_data.prerequisites:
			if not prerequisite in player_skills:
				return false
	
	# Check skill points
	if not skill_data.has("cost") or skill_points < skill_data.cost:
		return false
	
	return true

func unlock_skill(skill_id: String, tree_id: String) -> bool:
	"""Unlock a skill for the player"""
	var tree = skill_trees.get(tree_id, {})
	if tree.is_empty():
		print("❌ SkillSystem: Skill tree not found: ", tree_id)
		return false
	
	var skill_data = null
	
	# Find the skill data
	for tier_name in tree.tiers:
		var tier = tree.tiers[tier_name]
		if not tier.has("skills"):
			continue
		for skill in tier.skills:
			if not skill.has("id"):
				continue
			if skill.id == skill_id:
				skill_data = skill.duplicate()  # Create a copy
				skill_data["tree_id"] = tree_id  # Add tree_id to skill data
				break
		if skill_data:
			break
	
	if not skill_data:
		print("❌ SkillSystem: Skill not found: ", skill_id, " in tree: ", tree_id)
		return false
	
	if not can_unlock_skill(skill_data):
		print("❌ SkillSystem: Cannot unlock skill: ", skill_id)
		return false
	
	# Spend skill points
	if not skill_data.has("cost"):
		print("❌ SkillSystem: Skill has no cost: ", skill_id)
		return false
	skill_points -= skill_data.cost
	
	# Unlock the skill
	player_skills[skill_id] = skill_data
	
	# Apply skill effects
	apply_skill_effects(skill_data)
	
	# Check for synergies
	check_cross_tree_synergies()
	
	var skill_name = skill_data.get("name", skill_id)
	print("✅ SkillSystem: Unlocked skill: ", skill_name)
	skill_unlocked.emit(skill_id, skill_data)
	
	return true

func apply_skill_effects(skill_data: Dictionary):
	"""Apply the effects of an unlocked skill"""
	if not skill_data.has("effects") or not skill_data.has("id"):
		return
	for effect_name in skill_data.effects:
		var effect_value = skill_data.effects[effect_name]
		
		# Cache the effect for performance
		if not effect_cache.has(skill_data.id):
			effect_cache[skill_data.id] = {}
		
		effect_cache[skill_data.id][effect_name] = effect_value
		
		# Store the effect in skill_effects for other systems to query
		if not skill_effects.has(effect_name):
			skill_effects[effect_name] = 0.0
		skill_effects[effect_name] += effect_value
		
		# Apply the effect to the game systems
		apply_effect_to_systems(effect_name, effect_value)
		
		print("🔧 SkillSystem: Applied effect ", effect_name, " = ", effect_value, " for skill ", skill_data.id)

func apply_effect_to_systems(effect_name: String, effect_value):
	"""Apply skill effects to various game systems"""
	match effect_name:
		"weapon_damage_bonus":
			# Apply to combat system
			if get_node_or_null("/root/CombatManager"):
				get_node("/root/CombatManager").add_weapon_damage_bonus(effect_value)
		"spell_damage_bonus":
			# Apply to magic system
			if get_node_or_null("/root/CombatManager"):
				get_node("/root/CombatManager").add_spell_damage_bonus(effect_value)
		"movement_speed":
			# Apply to movement system
			if get_node_or_null("/root/GameManager"):
				get_node("/root/GameManager").add_movement_speed_bonus(effect_value)
		"crafting_quality":
			# Apply to crafting system
			if get_node_or_null("/root/GameManager"):
				get_node("/root/GameManager").add_crafting_quality_bonus(effect_value)
		_:
			# Store for other systems to query
			if not skill_effects.has(effect_name):
				skill_effects[effect_name] = 0.0
			skill_effects[effect_name] += effect_value

func switch_stance(new_stance: String) -> bool:
	"""Switch to a new stance (Jedi Survivor style)"""
	if not stances.has(new_stance):
		print("❌ SkillSystem: Invalid stance: ", new_stance)
		return false
	
	var stance_data = stances[new_stance]
	
	# Check if stance can be unlocked
	if not stance_data.has("unlock_requirements") or stance_data.unlock_requirements.size() == 0:
		print("❌ SkillSystem: Stance has no unlock requirements: ", new_stance)
		return false
	if player_level < stance_data.unlock_requirements[0].split("_")[1].to_int():
		print("❌ SkillSystem: Stance requires higher level: ", new_stance)
		return false
	
	# Remove oldest stance if at limit
	if active_stances.size() >= 2:
		active_stances.pop_back()
	
	# Add new stance
	active_stances.append(new_stance)
	
	# Update available skills
	update_available_skills()
	
	print("⚔️ SkillSystem: Switched to stance: ", new_stance)
	stance_changed.emit(active_stances)
	
	return true

func update_available_skills():
	"""Update available skills based on current stances"""
	stance_skills.clear()
	
	for stance in active_stances:
		if not stances.has(stance):
			continue
		var stance_data = stances[stance]
		var available_skills: Array[Dictionary] = []
		
		# Get skills available in this stance
		for tree_id in skill_trees:
			var tree = skill_trees[tree_id]
			if not tree.has("stance_requirements"):
				continue
			if stance in tree.stance_requirements:
				available_skills.append_array(get_available_skills(tree_id))
		
		stance_skills[stance] = available_skills

func check_cross_tree_synergies():
	"""Check for cross-tree synergies (Jedi Survivor style)"""
	for synergy_data in cross_tree_synergies:
		var requirements_met = true
		
		# Check if all requirements are met
		if synergy_data.has("requirements"):
			for tree_id in synergy_data.requirements:
				var required_points = synergy_data.requirements[tree_id]
				var current_points = get_skill_points_in_tree(tree_id)
				
				if current_points < required_points:
					requirements_met = false
					break
		
		if requirements_met:
			apply_synergy_effects(synergy_data)

func get_skill_points_in_tree(tree_id: String) -> int:
	"""Get total skill points spent in a specific tree"""
	var points = 0
	for skill_id in player_skills:
		var skill = player_skills[skill_id]
		if not skill.has("tree_id") or not skill.has("cost"):
			continue
		if skill.get("tree_id", "") == tree_id:
			points += skill.cost
	return points

func apply_synergy_effects(synergy_data: Dictionary):
	"""Apply cross-tree synergy effects"""
	if not synergy_data.has("effects") or not synergy_data.has("name"):
		return
	for effect_name in synergy_data.effects:
		var effect_value = synergy_data.effects[effect_name]
		apply_effect_to_systems(effect_name, effect_value)
	
	print("🌟 SkillSystem: Applied synergy: ", synergy_data.name)

func add_experience(amount: int):
	"""Add experience and handle level progression"""
	experience += amount
	
	while experience >= experience_to_next_level:
		level_up()
	
	# Update progress trackers
	update_progress_trackers("experience_gained", amount)

func level_up():
	"""Handle player level up"""
	experience -= experience_to_next_level
	player_level += 1
	
	# Calculate new experience requirement
	experience_to_next_level = int(experience_to_next_level * 1.2)
	
	# Grant skill points
	var skill_points_gained = 5 + (player_level / 10)  # More points at higher levels
	skill_points += skill_points_gained
	
	print("🎉 SkillSystem: Level up! Now level ", player_level, " with ", skill_points, " skill points")
	
	# Check for class evolution
	check_class_evolution()

func check_class_evolution():
	"""Check if player can evolve to a new class tier"""
	for tier_name in class_progression_data:
		var tier = class_progression_data[tier_name]
		if not tier.has("unlock_level") or not tier.has("classes"):
			continue
		if player_level >= tier.unlock_level:
			for class_id in tier.classes:
				var class_data = tier.classes[class_id]
				if can_evolve_to_class(class_data):
					evolve_to_class(class_id, class_data)

func can_evolve_to_class(class_data: Dictionary) -> bool:
	"""Check if player can evolve to a specific class"""
	# Check prerequisites
	if not class_data.has("unlock_requirements"):
		return true  # No requirements means it can be evolved
	
	for prerequisite in class_data.unlock_requirements:
		if not prerequisite in player_classes:
			# Check if it's a skill requirement
			if "_" in prerequisite:
				var parts = prerequisite.split("_")
				# Handle different prerequisite formats
				if parts.size() >= 3:
					# Format: tree_id_points (e.g., "combat_5")
					var tree_id = parts[0] + "_" + parts[1]
					var required_points = parts[2].to_int()
					if get_skill_points_in_tree(tree_id) < required_points:
						return false
				elif parts.size() == 2:
					# Format: tree_level (e.g., "level_1")
					var tree_id = parts[0]
					var level_requirement = parts[1].to_int()
					if player_level < level_requirement:
						return false
				else:
					# Invalid format
					print("⚠️ SkillSystem: Invalid prerequisite format: ", prerequisite)
					return false
			else:
				return false
	
	return true

func evolve_to_class(class_id: String, class_data: Dictionary):
	"""Evolve player to a new class"""
	player_classes.append(class_id)
	
	# Apply class bonuses
	if class_data.has("skill_bonuses"):
		for skill_tree in class_data.skill_bonuses:
			var bonus = class_data.skill_bonuses[skill_tree]
			apply_effect_to_systems(skill_tree + "_bonus", bonus)
	
	var class_name_var = class_data.get("name", class_id)
	print("🏆 SkillSystem: Evolved to class: ", class_name_var)
	class_evolved.emit(class_id, class_data)

func update_progress_trackers(stat_type: String, value: float):
	"""Update progress trackers for achievements"""
	if progress_trackers.has(stat_type):
		progress_trackers[stat_type] += value
		progress_updated.emit(stat_type, progress_trackers[stat_type])
		
		# Check achievements
		check_achievements(stat_type)

func check_achievements(stat_type: String):
	"""Check if any achievements have been completed"""
	for category in achievements:
		if not achievements[category].has("achievements"):
			continue
		for achievement_id in achievements[category].achievements:
			var achievement = achievements[category].achievements[achievement_id]
			
			if not achievement.has("tiers"):
				continue
			for tier in achievement.tiers:
				if not tier.has("name") or not tier.has("requirement") or not tier.has("requirement_value"):
					continue
				var tracker_key = achievement_id + "_" + tier.name.to_lower()
				
				if progress_trackers.has(stat_type) and tier.requirement == stat_type:
					if progress_trackers[stat_type] >= tier.requirement_value:
						complete_achievement(achievement_id, tier)

func complete_achievement(achievement_id: String, tier: Dictionary):
	"""Complete an achievement and grant rewards"""
	if not tier.has("name"):
		return
	var achievement_key = achievement_id + "_" + tier.name.to_lower()
	
	if achievement_key in completed_achievements:
		return  # Already completed
	
	completed_achievements.append(achievement_key)
	
	# Grant rewards
	if tier.has("reward"):
		if tier.reward.has("skill_points"):
			skill_points += tier.reward.skill_points
		
		if tier.reward.has("experience"):
			add_experience(tier.reward.experience)
	
	print("🏆 SkillSystem: Achievement completed: ", tier.name)
	achievement_completed.emit(achievement_id, tier.name, tier.reward)

func get_skill_effect(effect_name: String) -> float:
	"""Get the total value of a skill effect"""
	return skill_effects.get(effect_name, 0.0)

func get_player_progression_summary() -> Dictionary:
	"""Get a summary of player progression"""
	return {
		"level": player_level,
		"experience": experience,
		"experience_to_next": experience_to_next_level,
		"skill_points": skill_points,
		"unlocked_skills": player_skills.size(),
		"active_stances": active_stances,
		"classes": player_classes,
		"completed_achievements": completed_achievements.size()
	}

func save_progression_data() -> Dictionary:
	"""Save progression data for persistence"""
	return {
		"player_level": player_level,
		"experience": experience,
		"experience_to_next_level": experience_to_next_level,
		"skill_points": skill_points,
		"player_skills": player_skills,
		"active_stances": active_stances,
		"player_classes": player_classes,
		"progress_trackers": progress_trackers,
		"completed_achievements": completed_achievements,
		"skill_effects": skill_effects
	}

func load_progression_data(data: Dictionary):
	"""Load progression data from persistence"""
	player_level = data.get("player_level", 1)
	experience = data.get("experience", 0)
	experience_to_next_level = data.get("experience_to_next_level", 100)
	skill_points = data.get("skill_points", 10)
	player_skills = data.get("player_skills", {})
	active_stances = data.get("active_stances", ["combat", "arcane"])
	player_classes = data.get("player_classes", [])
	progress_trackers = data.get("progress_trackers", {})
	completed_achievements = data.get("completed_achievements", [])
	skill_effects = data.get("skill_effects", {})
	
	# Reapply all skill effects
	for skill_id in player_skills:
		apply_skill_effects(player_skills[skill_id])
	
	update_available_skills()
	print("📚 SkillSystem: Progression data loaded")
