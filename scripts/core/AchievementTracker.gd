extends Node

# AchievementTracker - Comprehensive achievement tracking system
# Inspired by World of Warcraft's achievement system
# Version 0.13.0

signal achievement_progress_updated(achievement_id: String, progress: float, max_progress: float)
signal achievement_completed(achievement_id: String, tier: String, reward: Dictionary)
signal achievement_category_completed(category: String, completion_percentage: float)
signal reward_granted(reward_type: String, reward_value, achievement_id: String)

# Achievement system data
var achievements: Dictionary = {}
var progress_trackers: Dictionary = {}
var completed_achievements: Array[String] = []
var achievement_rewards: Dictionary = {}
var category_completion: Dictionary = {}

# Progress tracking categories
var combat_stats: Dictionary = {}
var exploration_stats: Dictionary = {}
var social_stats: Dictionary = {}
var crafting_stats: Dictionary = {}

# Achievement notifications
var notification_queue: Array[Dictionary] = []
var notification_delay: float = 2.0
var last_notification_time: float = 0.0

func _ready():
	"""Initialize the achievement tracker"""
	print("🏆 AchievementTracker: Initializing comprehensive achievement system...")
	
	# Load achievement data
	load_achievement_data()
	
	# Initialize progress trackers
	initialize_progress_trackers()
	
	# Set up achievement categories
	setup_achievement_categories()
	
	print("✅ AchievementTracker: Achievement system initialized successfully")

func load_achievement_data():
	"""Load achievement data from JSON file"""
	var file = FileAccess.open("res://data/skills/achievements.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		if parse_result == OK:
			var data = json.data
			achievements = data.achievement_categories
			achievement_rewards = data.achievement_rewards
			print("📚 AchievementTracker: Loaded achievement data")
		else:
			print("❌ AchievementTracker: Failed to parse achievements JSON")
		file.close()
	else:
		print("❌ AchievementTracker: Could not open achievements file")

func initialize_progress_trackers():
	"""Initialize progress trackers for all achievements"""
	for category in achievements:
		for achievement_id in achievements[category].achievements:
			var achievement = achievements[category].achievements[achievement_id]
			
			for tier in achievement.tiers:
				var tracker_key = achievement_id + "_" + tier.name.to_lower()
				progress_trackers[tracker_key] = 0.0
				
				# Initialize category completion tracking
				if not category_completion.has(category):
					category_completion[category] = {
						"total_achievements": 0,
						"completed_achievements": 0
					}
				category_completion[category].total_achievements += 1
	
	print("📊 AchievementTracker: Progress trackers initialized")

func setup_achievement_categories():
	"""Set up achievement category tracking"""
	combat_stats = {
		"weapons_mastered": 0,
		"max_combo_hits": 0,
		"bosses_defeated": 0,
		"damage_dealt": 0,
		"enemies_defeated": 0
	}
	
	exploration_stats = {
		"locations_discovered": 0,
		"treasures_found": 0,
		"secret_paths_completed": 0,
		"areas_explored": 0,
		"world_events_participated": 0
	}
	
	social_stats = {
		"conflicts_resolved_peacefully": 0,
		"followers_recruited": 0,
		"factions_max_reputation": 0,
		"relationships_built": 0,
		"influence_exerted": 0
	}
	
	crafting_stats = {
		"items_crafted": 0,
		"high_quality_crafts": 0,
		"legendary_crafts": 0,
		"legendary_items_crafted": 0,
		"unique_combinations_created": 0,
		"crafting_disciplines_mastered": 0,
		"materials_gathered": 0,
		"techniques_learned": 0
	}
	
	print("📋 AchievementTracker: Achievement categories set up")

func track_progress(stat_type: String, progress: float):
	"""Track progress for a specific statistic"""
	# Update the appropriate stat category
	if combat_stats.has(stat_type):
		combat_stats[stat_type] += progress
	elif exploration_stats.has(stat_type):
		exploration_stats[stat_type] += progress
	elif social_stats.has(stat_type):
		social_stats[stat_type] += progress
	elif crafting_stats.has(stat_type):
		crafting_stats[stat_type] += progress
	
	# Check achievements that depend on this stat
	check_achievements_for_stat(stat_type)
	
	# Emit progress update signal
	achievement_progress_updated.emit(stat_type, progress)

func check_achievements_for_stat(stat_type: String):
	"""Check if any achievements have been completed for a specific stat"""
	for category in achievements:
		for achievement_id in achievements[category].achievements:
			var achievement = achievements[category].achievements[achievement_id]
			
			for tier in achievement.tiers:
				if tier.requirement == stat_type:
					check_achievement_completion(achievement_id, tier, stat_type)

func check_achievement_completion(achievement_id: String, tier: Dictionary, stat_type: String):
	"""Check if an achievement tier has been completed"""
	var tracker_key = achievement_id + "_" + tier.name.to_lower()
	
	# Get current progress
	var current_progress = 0.0
	if combat_stats.has(stat_type):
		current_progress = combat_stats[stat_type]
	elif exploration_stats.has(stat_type):
		current_progress = exploration_stats[stat_type]
	elif social_stats.has(stat_type):
		current_progress = social_stats[stat_type]
	elif crafting_stats.has(stat_type):
		current_progress = crafting_stats[stat_type]
	
	# Check if achievement is completed
	if current_progress >= tier.requirement_value:
		complete_achievement(achievement_id, tier, tracker_key)
	else:
		# Update progress for UI
		achievement_progress_updated.emit(achievement_id, current_progress, tier.requirement_value)

func complete_achievement(achievement_id: String, tier: Dictionary, tracker_key: String):
	"""Complete an achievement and grant rewards"""
	if tracker_key in completed_achievements:
		return  # Already completed
	
	completed_achievements.append(tracker_key)
	
	# Update category completion
	var category = get_achievement_category(achievement_id)
	if category and category_completion.has(category):
		category_completion[category].completed_achievements += 1
	
	# Grant rewards
	grant_achievement_rewards(achievement_id, tier)
	
	# Add to notification queue
	add_achievement_notification(achievement_id, tier)
	
	print("🏆 AchievementTracker: Achievement completed: ", tier.name)
	achievement_completed.emit(achievement_id, tier.name, tier.reward)

func get_achievement_category(achievement_id: String) -> String:
	"""Get the category for a specific achievement"""
	for category in achievements:
		if achievements[category].achievements.has(achievement_id):
			return category
	return ""

func grant_achievement_rewards(achievement_id: String, tier: Dictionary):
	"""Grant rewards for completing an achievement"""
	var skill_system = get_node_or_null("/root/SkillSystem")
	
	if tier.reward.has("skill_points"):
		var skill_points = tier.reward.skill_points
		if skill_system:
			skill_system.skill_points += skill_points
		reward_granted.emit("skill_points", skill_points, achievement_id)
	
	if tier.reward.has("experience"):
		var experience = tier.reward.experience
		if skill_system:
			skill_system.add_experience(experience)
		reward_granted.emit("experience", experience, achievement_id)
	
	if tier.reward.has("title"):
		var title = tier.reward.title
		reward_granted.emit("title", title, achievement_id)
	
	if tier.reward.has("unique_ability"):
		var ability = tier.reward.unique_ability
		reward_granted.emit("unique_ability", ability, achievement_id)

func add_achievement_notification(achievement_id: String, tier: Dictionary):
	"""Add achievement completion to notification queue"""
	var achievement_notification = {
		"achievement_id": achievement_id,
		"tier_name": tier.name,
		"description": tier.description,
		"rewards": tier.reward
	}
	
	notification_queue.append(achievement_notification)

func process_notifications():
	"""Process achievement notifications with timing"""
	var current_time = Time.get_time_dict_from_system()
	
	if notification_queue.size() > 0 and current_time.second - last_notification_time >= notification_delay:
		var achievement_notification = notification_queue.pop_front()
		show_achievement_notification(achievement_notification)
		last_notification_time = current_time.second

func show_achievement_notification(achievement_notification: Dictionary):
	"""Show an achievement completion notification"""
	print("🎉 ACHIEVEMENT UNLOCKED: ", achievement_notification.tier_name)
	print("   Description: ", achievement_notification.description)
	
	# Here you would integrate with the UI system to show notifications
	# For now, we'll just print to console

func get_achievement_progress(achievement_id: String) -> Dictionary:
	"""Get progress for a specific achievement"""
	var progress_data = {}
	
	for category in achievements:
		if achievements[category].achievements.has(achievement_id):
			var achievement = achievements[category].achievements[achievement_id]
			
			for tier in achievement.tiers:
				var tracker_key = achievement_id + "_" + tier.name.to_lower()
				var stat_type = tier.requirement
				
				var current_progress = 0.0
				if combat_stats.has(stat_type):
					current_progress = combat_stats[stat_type]
				elif exploration_stats.has(stat_type):
					current_progress = exploration_stats[stat_type]
				elif social_stats.has(stat_type):
					current_progress = social_stats[stat_type]
				elif crafting_stats.has(stat_type):
					current_progress = crafting_stats[stat_type]
				
				progress_data[tier.name] = {
					"current": current_progress,
					"required": tier.requirement_value,
					"completed": tracker_key in completed_achievements
				}
	
	return progress_data

func get_category_progress(category: String) -> Dictionary:
	"""Get progress for an entire achievement category"""
	if not achievements.has(category):
		return {}
	
	var category_data = achievements[category]
	var progress = {
		"name": category_data.name,
		"description": category_data.description,
		"achievements": {},
		"completion_percentage": 0.0
	}
	
	var total_achievements = 0
	var completed_achievements_count = 0
	
	for achievement_id in category_data.achievements:
		var achievement = category_data.achievements[achievement_id]
		progress.achievements[achievement_id] = {
			"name": achievement.name,
			"description": achievement.description,
			"tiers": get_achievement_progress(achievement_id)
		}
		
		total_achievements += achievement.tiers.size()
		for tier in achievement.tiers:
			var tracker_key = achievement_id + "_" + tier.name.to_lower()
			if tracker_key in completed_achievements:
				completed_achievements_count += 1
	
	if total_achievements > 0:
		progress.completion_percentage = (completed_achievements_count / total_achievements) * 100.0
	
	return progress

func get_achievement_summary() -> Dictionary:
	"""Get a summary of all achievement progress"""
	var summary = {
		"total_achievements": 0,
		"completed_achievements": completed_achievements.size(),
		"categories": {},
		"recent_completions": []
	}
	
	for category in achievements:
		summary.categories[category] = get_category_progress(category)
		summary.total_achievements += achievements[category].achievements.size()
	
	return summary

func get_stat_summary() -> Dictionary:
	"""Get a summary of all tracked statistics"""
	return {
		"combat": combat_stats,
		"exploration": exploration_stats,
		"social": social_stats,
		"crafting": crafting_stats
	}

func save_achievement_data() -> Dictionary:
	"""Save achievement data for persistence"""
	return {
		"progress_trackers": progress_trackers,
		"completed_achievements": completed_achievements,
		"combat_stats": combat_stats,
		"exploration_stats": exploration_stats,
		"social_stats": social_stats,
		"crafting_stats": crafting_stats,
		"category_completion": category_completion
	}

func load_achievement_data_from_save(data: Dictionary):
	"""Load achievement data from persistence"""
	progress_trackers = data.get("progress_trackers", {})
	completed_achievements = data.get("completed_achievements", [])
	combat_stats = data.get("combat_stats", {})
	exploration_stats = data.get("exploration_stats", {})
	social_stats = data.get("social_stats", {})
	crafting_stats = data.get("crafting_stats", {})
	category_completion = data.get("category_completion", {})
	
	print("📚 AchievementTracker: Achievement data loaded from save")

func reset_achievements():
	"""Reset all achievement progress (for testing)"""
	progress_trackers.clear()
	completed_achievements.clear()
	combat_stats.clear()
	exploration_stats.clear()
	social_stats.clear()
	crafting_stats.clear()
	category_completion.clear()
	
	initialize_progress_trackers()
	setup_achievement_categories()
	
	print("🔄 AchievementTracker: All achievements reset")

func _process(_delta):
	"""Process achievement notifications"""
	process_notifications() 
