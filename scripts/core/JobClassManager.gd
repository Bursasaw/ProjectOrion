extends Node
class_name JobClassManager

# Job Class Manager - Handles job class system inspired by SWGOH
# Manages job classes, job progression, job abilities, and job bonuses

signal job_class_changed(actor: String, old_class: String, new_class: String)
signal job_ability_learned(actor: String, job_class: String, ability_name: String)
signal job_level_up(actor: String, job_class: String, old_level: int, new_level: int)

# Job classes inspired by Final Fantasy
var job_classes = {
	"warrior": {
		"name": "Warrior",
		"description": "A skilled fighter with high physical defense",
		"narrative": "Masters of physical combat, warriors excel at protecting allies and dealing heavy damage.",
		"base_stats": {"health": 120, "attack": 15, "defense": 12, "speed": 8},
		"growth_stats": {"health": 10, "attack": 2, "defense": 1.5, "speed": 0.5},
		"specialization": "physical_combat"
	},
	"mage": {
		"name": "Mage",
		"description": "A powerful spellcaster with high magical attack",
		"narrative": "Masters of the arcane arts, mages wield devastating magical spells.",
		"base_stats": {"health": 80, "magic_attack": 18, "magic_defense": 10, "speed": 6},
		"growth_stats": {"health": 6, "magic_attack": 2.5, "magic_defense": 1.2, "speed": 0.3},
		"specialization": "magical_combat"
	},
	"rogue": {
		"name": "Rogue",
		"description": "A stealthy fighter with high speed and critical chance",
		"narrative": "Masters of stealth and precision, rogues strike from the shadows with deadly accuracy.",
		"base_stats": {"health": 90, "attack": 12, "speed": 15, "critical_chance": 12},
		"growth_stats": {"health": 7, "attack": 1.8, "speed": 2.0, "critical_chance": 1.5},
		"specialization": "stealth_combat"
	},
	"healer": {
		"name": "Healer",
		"description": "A supportive character with powerful healing abilities",
		"narrative": "Guardians of life, healers keep their allies alive with restorative magic.",
		"base_stats": {"health": 100, "magic_attack": 14, "magic_defense": 12, "healing": 16},
		"growth_stats": {"health": 8, "magic_attack": 2.0, "magic_defense": 1.5, "healing": 2.2},
		"specialization": "support_healing"
	},
	"paladin": {
		"name": "Paladin",
		"description": "A holy warrior with balanced offense and defense",
		"narrative": "Holy warriors who combine martial prowess with divine protection.",
		"base_stats": {"health": 110, "attack": 13, "defense": 14, "magic_defense": 10},
		"growth_stats": {"health": 9, "attack": 1.9, "defense": 1.8, "magic_defense": 1.3},
		"specialization": "holy_combat"
	},
	"berserker": {
		"name": "Berserker",
		"description": "A fierce warrior with high attack but low defense",
		"narrative": "Frenzied warriors who sacrifice defense for overwhelming offense.",
		"base_stats": {"health": 130, "attack": 20, "defense": 6, "speed": 10},
		"growth_stats": {"health": 12, "attack": 2.8, "defense": 0.8, "speed": 1.2},
		"specialization": "berserker_combat"
	},
	"archer": {
		"name": "Archer",
		"description": "A ranged fighter with high accuracy and speed",
		"narrative": "Masters of the bow, archers strike from a distance with deadly precision.",
		"base_stats": {"health": 85, "attack": 14, "speed": 12, "accuracy": 15},
		"growth_stats": {"health": 7, "attack": 2.0, "speed": 1.5, "accuracy": 1.8},
		"specialization": "ranged_combat"
	},
	"summoner": {
		"name": "Summoner",
		"description": "A mystical character who summons powerful entities",
		"narrative": "Masters of summoning magic, summoners call forth powerful entities to aid them.",
		"base_stats": {"health": 95, "magic_attack": 16, "magic_defense": 11, "summoning": 18},
		"growth_stats": {"health": 8, "magic_attack": 2.3, "magic_defense": 1.4, "summoning": 2.5},
		"specialization": "summoning_magic"
	}
}

# Job abilities for each class
var job_abilities = {
	"warrior": {
		"shield_bash": {"level": 1, "description": "A powerful shield attack", "effect": {"damage": 25, "defense_bonus": 1.2}},
		"battle_cry": {"level": 3, "description": "Increases attack for the team", "effect": {"team_attack": 1.3}},
		"guardian_stance": {"level": 5, "description": "Increases defense significantly", "effect": {"defense": 1.5}},
		"weapon_mastery": {"level": 7, "description": "Increases weapon damage", "effect": {"weapon_damage": 1.4}}
	},
	"mage": {
		"fireball": {"level": 1, "description": "A basic fire spell", "effect": {"fire_damage": 30}},
		"ice_storm": {"level": 3, "description": "A powerful ice spell", "effect": {"ice_damage": 40}},
		"lightning_bolt": {"level": 5, "description": "A devastating lightning spell", "effect": {"lightning_damage": 50}},
		"arcane_explosion": {"level": 7, "description": "A massive magical explosion", "effect": {"magic_damage": 60}}
	},
	"rogue": {
		"backstab": {"level": 1, "description": "A stealthy attack from behind", "effect": {"damage": 35, "critical_chance": 1.5}},
		"shadow_step": {"level": 3, "description": "Teleport behind an enemy", "effect": {"stealth": 1.4, "damage": 1.3}},
		"poison_dagger": {"level": 5, "description": "A poisoned dagger attack", "effect": {"damage": 30, "poison": 1.2}},
		"death_blow": {"level": 7, "description": "A lethal critical strike", "effect": {"damage": 70, "critical_chance": 2.0}}
	},
	"healer": {
		"heal": {"level": 1, "description": "Basic healing spell", "effect": {"healing": 40}},
		"group_heal": {"level": 3, "description": "Heals the entire team", "effect": {"team_healing": 35}},
		"purify": {"level": 5, "description": "Removes negative status effects", "effect": {"status_removal": true}},
		"resurrection": {"level": 7, "description": "Revives a fallen ally", "effect": {"revive": true}}
	},
	"paladin": {
		"holy_strike": {"level": 1, "description": "A holy-powered attack", "effect": {"holy_damage": 30}},
		"divine_protection": {"level": 3, "description": "Protects the team with holy magic", "effect": {"team_defense": 1.3}},
		"lay_on_hands": {"level": 5, "description": "Heals and protects an ally", "effect": {"healing": 50, "defense": 1.4}},
		"divine_judgment": {"level": 7, "description": "A powerful holy judgment", "effect": {"holy_damage": 80}}
	},
	"berserker": {
		"rage": {"level": 1, "description": "Increases attack but decreases defense", "effect": {"attack": 1.5, "defense": 0.7}},
		"blood_frenzy": {"level": 3, "description": "Attacks become more powerful when wounded", "effect": {"damage_multiplier": 1.4}},
		"berserker_rage": {"level": 5, "description": "Maximum attack power", "effect": {"attack": 2.0, "defense": 0.5}},
		"death_wish": {"level": 7, "description": "Ultimate berserker ability", "effect": {"damage": 100, "self_damage": 20}}
	},
	"archer": {
		"precise_shot": {"level": 1, "description": "A highly accurate shot", "effect": {"damage": 25, "accuracy": 1.3}},
		"multi_shot": {"level": 3, "description": "Fires multiple arrows", "effect": {"damage": 20, "hits": 3}},
		"eagle_eye": {"level": 5, "description": "Increases accuracy and critical chance", "effect": {"accuracy": 1.5, "critical_chance": 1.4}},
		"rain_of_arrows": {"level": 7, "description": "A devastating arrow storm", "effect": {"damage": 60, "area_effect": true}}
	},
	"summoner": {
		"summon_fire_spirit": {"level": 1, "description": "Summons a fire spirit", "effect": {"fire_damage": 35}},
		"summon_ice_golem": {"level": 3, "description": "Summons an ice golem", "effect": {"ice_damage": 45, "defense": 1.2}},
		"summon_lightning_dragon": {"level": 5, "description": "Summons a lightning dragon", "effect": {"lightning_damage": 55}},
		"summon_ancient_one": {"level": 7, "description": "Summons an ancient entity", "effect": {"magic_damage": 80, "all_enhancements": 1.3}}
	}
}

# Actor job assignments and levels
var actor_jobs: Dictionary = {}
var job_levels: Dictionary = {}
var job_history: Array = []

func _ready():
	"""Initialize job class manager"""
	print("JobClassManager: Initialized")

func assign_job_class(actor_name: String, job_class: String) -> bool:
	"""Assign a job class to an actor"""
	if not job_classes.has(job_class):
		print("JobClassManager: Unknown job class: %s" % job_class)
		return false
	
	var old_job = actor_jobs.get(actor_name, "")
	actor_jobs[actor_name] = job_class
	
	# Initialize job level if not set
	if not job_levels.has(actor_name):
		job_levels[actor_name] = 1
	
	# Add to history
	job_history.append({
		"turn": get_current_turn(),
		"actor": actor_name,
		"action": "assign_job_class",
		"old_job": old_job,
		"new_job": job_class
	})
	
	# Emit signal
	job_class_changed.emit(actor_name, old_job, job_class)
	
	print("JobClassManager: Assigned %s job class to %s" % [job_class, actor_name])
	
	return true

func get_actor_job(actor_name: String) -> String:
	"""Get the job class of an actor"""
	return actor_jobs.get(actor_name, "")

func get_job_level(actor_name: String) -> int:
	"""Get the job level of an actor"""
	return job_levels.get(actor_name, 1)

func level_up_job(actor_name: String) -> bool:
	"""Level up an actor's job class"""
	if not actor_jobs.has(actor_name):
		print("JobClassManager: Actor %s has no job class" % actor_name)
		return false
	
	var current_level = job_levels.get(actor_name, 1)
	var new_level = current_level + 1
	job_levels[actor_name] = new_level
	
	# Add to history
	job_history.append({
		"turn": get_current_turn(),
		"actor": actor_name,
		"action": "level_up_job",
		"job_class": actor_jobs[actor_name],
		"old_level": current_level,
		"new_level": new_level
	})
	
	# Emit signal
	job_level_up.emit(actor_name, actor_jobs[actor_name], current_level, new_level)
	
	print("JobClassManager: %s job level up %d -> %d" % [actor_name, current_level, new_level])
	
	return true

func get_job_stats(actor_name: String) -> Dictionary:
	"""Get job-based stats for an actor"""
	var job_class = get_actor_job(actor_name)
	if job_class == "":
		return {}
	
	var job_data = job_classes.get(job_class, {})
	var base_stats = job_data.get("base_stats", {})
	var growth_stats = job_data.get("growth_stats", {})
	var level = get_job_level(actor_name)
	
	var total_stats = {}
	
	# Add base stats
	for stat_name in base_stats.keys():
		total_stats[stat_name] = base_stats[stat_name]
	
	# Add growth stats based on level
	for stat_name in growth_stats.keys():
		var growth_per_level = growth_stats[stat_name]
		var total_growth = growth_per_level * (level - 1)
		total_stats[stat_name] = total_stats.get(stat_name, 0) + total_growth
	
	return total_stats

func get_job_abilities(actor_name: String) -> Array:
	"""Get available abilities for an actor's job class"""
	var job_class = get_actor_job(actor_name)
	if job_class == "":
		return []
	
	var level = get_job_level(actor_name)
	var job_ability_data = job_abilities.get(job_class, {})
	var available_abilities = []
	
	for ability_name in job_ability_data.keys():
		var ability_data = job_ability_data[ability_name]
		var required_level = ability_data.get("level", 1)
		
		if level >= required_level:
			available_abilities.append({
				"name": ability_name,
				"description": ability_data["description"],
				"effect": ability_data["effect"],
				"level_required": required_level
			})
	
	return available_abilities

func learn_job_ability(actor_name: String, ability_name: String) -> bool:
	"""Learn a job ability (placeholder for future implementation)"""
	var job_class = get_actor_job(actor_name)
	if job_class == "":
		print("JobClassManager: Actor %s has no job class" % actor_name)
		return false
	
	var job_ability_data = job_abilities.get(job_class, {})
	if not job_ability_data.has(ability_name):
		print("JobClassManager: Unknown ability %s for job %s" % [ability_name, job_class])
		return false
	
	# Add to history
	job_history.append({
		"turn": get_current_turn(),
		"actor": actor_name,
		"action": "learn_job_ability",
		"job_class": job_class,
		"ability_name": ability_name
	})
	
	# Emit signal
	job_ability_learned.emit(actor_name, job_class, ability_name)
	
	print("JobClassManager: %s learned %s ability" % [actor_name, ability_name])
	
	return true

func get_job_info(job_class: String) -> Dictionary:
	"""Get information about a specific job class"""
	return job_classes.get(job_class, {})

func get_available_job_classes() -> Array:
	"""Get all available job classes"""
	var available = []
	
	for job_class in job_classes.keys():
		var job_data = job_classes[job_class]
		available.append({
			"job_class": job_class,
			"name": job_data["name"],
			"description": job_data["description"],
			"narrative": job_data["narrative"],
			"base_stats": job_data["base_stats"],
			"growth_stats": job_data["growth_stats"],
			"specialization": job_data["specialization"]
		})
	
	return available

func get_job_ability_info(job_class: String, ability_name: String) -> Dictionary:
	"""Get information about a specific job ability"""
	var job_ability_data = job_abilities.get(job_class, {})
	return job_ability_data.get(ability_name, {})

func get_current_turn() -> int:
	"""Get current turn number (placeholder)"""
	# In a real implementation, this would get the current turn from CombatManager
	return 1

func clear_actor_job(actor_name: String):
	"""Clear job assignment for an actor"""
	if actor_jobs.has(actor_name):
		actor_jobs.erase(actor_name)
	if job_levels.has(actor_name):
		job_levels.erase(actor_name)
	print("JobClassManager: Cleared job for %s" % actor_name)

func get_job_statistics(actor_name: String) -> Dictionary:
	"""Get job statistics for an actor"""
	var job_class = get_actor_job(actor_name)
	if job_class == "":
		return {}
	
	var level = get_job_level(actor_name)
	var abilities = get_job_abilities(actor_name)
	var stats = get_job_stats(actor_name)
	
	return {
		"job_class": job_class,
		"job_name": job_classes[job_class]["name"],
		"job_description": job_classes[job_class]["description"],
		"level": level,
		"abilities_available": abilities.size(),
		"stats": stats,
		"specialization": job_classes[job_class]["specialization"]
	}

func get_job_system_statistics() -> Dictionary:
	"""Get overall job system statistics"""
	var total_actors = actor_jobs.size()
	var job_counts = {}
	var total_levels = 0
	
	for actor_name in actor_jobs.keys():
		var job_class = actor_jobs[actor_name]
		job_counts[job_class] = job_counts.get(job_class, 0) + 1
		total_levels += job_levels.get(actor_name, 1)
	
	return {
		"actors_with_jobs": total_actors,
		"job_distribution": job_counts,
		"total_job_classes": job_classes.size(),
		"total_abilities": job_abilities.size(),
		"average_job_level": float(total_levels) / total_actors if total_actors > 0 else 0.0,
		"total_history": job_history.size()
	} 