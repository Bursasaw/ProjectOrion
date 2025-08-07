extends Node

# StanceManager - Jedi Survivor inspired stance system
# Handles dynamic stance switching and cross-stance synergies
# Version 0.13.0

signal stance_activated(stance_id: String, stance_data: Dictionary)
signal stance_deactivated(stance_id: String)
signal cross_stance_synergy_triggered(synergy_id: String, synergy_data: Dictionary)
signal stance_skill_updated(stance_id: String, available_skills: Array[Dictionary])

# Stance system data
var available_stances: Dictionary = {}
var active_stances: Array[String] = []
var stance_skills: Dictionary = {}
var cross_stance_synergies: Array = []
var stance_effects: Dictionary = {}

# Stance switching cooldown
var stance_switch_cooldown: float = 2.0
var last_stance_switch_time: float = 0.0

# Performance optimization
var stance_cache: Dictionary = {}
var effect_cache: Dictionary = {}

func _ready():
	"""Initialize the stance manager"""
	print("⚔️ StanceManager: Initializing Jedi Survivor-inspired stance system...")
	
	# Load stance data from skill system
	load_stance_data()
	
	# Set up default stances
	setup_default_stances()
	
	print("✅ StanceManager: Stance system initialized successfully")

func load_stance_data():
	"""Load stance data from the skill system"""
	var skill_system = get_node_or_null("/root/SkillSystem")
	if skill_system:
		available_stances = skill_system.stances
		cross_stance_synergies = skill_system.cross_tree_synergies
		print("📚 StanceManager: Loaded ", available_stances.size(), " stances")
	else:
		print("❌ StanceManager: SkillSystem not found")

func setup_default_stances():
	"""Set up default stances for the player"""
	active_stances = ["combat", "arcane"]  # Default stances
	update_stance_skills()
	print("⚔️ StanceManager: Default stances set: ", active_stances)

func switch_stance(new_stance: String) -> bool:
	"""Switch to a new stance (Jedi Survivor style)"""
	var current_time = Time.get_ticks_msec() / 1000.0  # Convert to seconds
	var time_since_last_switch = current_time - last_stance_switch_time
	
	# Check cooldown (reduced for testing)
	if time_since_last_switch < 0.5:  # Reduced to 0.5 seconds for testing
		print("⏳ StanceManager: Stance switch on cooldown")
		return false
	
	# Validate stance
	if not available_stances.has(new_stance):
		print("❌ StanceManager: Invalid stance: ", new_stance)
		return false
	
	var stance_data = available_stances[new_stance]
	
	# Check unlock requirements
	if not can_activate_stance(stance_data):
		print("❌ StanceManager: Cannot activate stance: ", new_stance)
		return false
	
	# Remove oldest stance if at limit (max 2 active stances)
	if active_stances.size() >= 2:
		var removed_stance = active_stances.pop_back()
		deactivate_stance(removed_stance)
	
	# Add new stance
	active_stances.append(new_stance)
	activate_stance(new_stance, stance_data)
	
	# Update stance skills
	update_stance_skills()
	
	# Check for cross-stance synergies
	check_cross_stance_synergies()
	
	# Update cooldown
	last_stance_switch_time = current_time
	
	print("⚔️ StanceManager: Switched to stance: ", new_stance)
	stance_activated.emit(new_stance, stance_data)
	
	return true

func can_activate_stance(stance_data: Dictionary) -> bool:
	"""Check if a stance can be activated"""
	var skill_system = get_node_or_null("/root/SkillSystem")
	if not skill_system:
		return false
	
	# Check level requirement
	for requirement in stance_data.unlock_requirements:
		if requirement.begins_with("level_"):
			var required_level = requirement.split("_")[1].to_int()
			if skill_system.player_level < required_level:
				return false
	
	return true

func activate_stance(stance_id: String, stance_data: Dictionary):
	"""Activate a stance and apply its effects"""
	stance_effects[stance_id] = stance_data.skill_tree_bonuses
	
	# Apply stance effects to skill trees
	for skill_tree in stance_data.skill_tree_bonuses:
		var bonus = stance_data.skill_tree_bonuses[skill_tree]
		apply_stance_effect(skill_tree, bonus)
	
	print("⚔️ StanceManager: Activated stance: ", stance_data.name)

func deactivate_stance(stance_id: String):
	"""Deactivate a stance and remove its effects"""
	if stance_effects.has(stance_id):
		var stance_data = available_stances[stance_id]
		
		# Remove stance effects
		for skill_tree in stance_data.skill_tree_bonuses:
			var bonus = stance_data.skill_tree_bonuses[skill_tree]
			remove_stance_effect(skill_tree, bonus)
		
		stance_effects.erase(stance_id)
	
	print("⚔️ StanceManager: Deactivated stance: ", stance_id)
	stance_deactivated.emit(stance_id)

func apply_stance_effect(skill_tree: String, bonus: float):
	"""Apply stance effect to a skill tree"""
	var skill_system = get_node_or_null("/root/SkillSystem")
	if skill_system:
		# Apply the bonus to the skill system
		skill_system.apply_effect_to_systems(skill_tree + "_stance_bonus", bonus)

func remove_stance_effect(skill_tree: String, bonus: float):
	"""Remove stance effect from a skill tree"""
	var skill_system = get_node_or_null("/root/SkillSystem")
	if skill_system:
		# Remove the bonus from the skill system
		skill_system.apply_effect_to_systems(skill_tree + "_stance_bonus", -bonus)

func update_stance_skills():
	"""Update available skills based on current stances"""
	stance_skills.clear()
	
	for stance_id in active_stances:
		var stance_data = available_stances[stance_id]
		var available_skills: Array[Dictionary] = []
		
		# Get skills available in this stance
		var skill_system = get_node_or_null("/root/SkillSystem")
		if skill_system:
			for tree_id in skill_system.skill_trees:
				var tree = skill_system.skill_trees[tree_id]
				if stance_id in tree.stance_requirements:
					available_skills.append_array(skill_system.get_available_skills(tree_id))
		
		stance_skills[stance_id] = available_skills
		stance_skill_updated.emit(stance_id, available_skills)

func check_cross_stance_synergies():
	"""Check for cross-stance synergies (Jedi Survivor style)"""
	for synergy_data in cross_stance_synergies:
		if not synergy_data.has("stance_requirements"):
			continue
		
		var requirements_met = true
		
		# Check if all required stances are active
		for stance_requirement in synergy_data.stance_requirements:
			if not stance_requirement in active_stances:
				requirements_met = false
				break
		
		if requirements_met:
			apply_cross_stance_synergy(synergy_data)

func apply_cross_stance_synergy(synergy_data: Dictionary):
	"""Apply cross-stance synergy effects"""
	var skill_system = get_node_or_null("/root/SkillSystem")
	if skill_system:
		for effect_name in synergy_data.effects:
			var effect_value = synergy_data.effects[effect_name]
			skill_system.apply_effect_to_systems(effect_name, effect_value)
	
	print("🌟 StanceManager: Applied cross-stance synergy: ", synergy_data.name)
	cross_stance_synergy_triggered.emit(synergy_data.id, synergy_data)

func get_active_stances() -> Array[String]:
	"""Get currently active stances"""
	return active_stances

func get_stance_data(stance_id: String) -> Dictionary:
	"""Get data for a specific stance"""
	return available_stances.get(stance_id, {})

func get_stance_skills(stance_id: String) -> Array[Dictionary]:
	"""Get available skills for a specific stance"""
	return stance_skills.get(stance_id, [])

func get_stance_effect(stance_id: String, skill_tree: String) -> float:
	"""Get the effect bonus for a stance on a skill tree"""
	if stance_effects.has(stance_id):
		return stance_effects[stance_id].get(skill_tree, 0.0)
	return 0.0

func can_switch_stance() -> bool:
	"""Check if stance switching is available (not on cooldown)"""
	var current_time = Time.get_ticks_msec() / 1000.0
	var time_since_last_switch = current_time - last_stance_switch_time
	return time_since_last_switch >= stance_switch_cooldown

func get_stance_switch_cooldown_remaining() -> float:
	"""Get remaining cooldown time for stance switching"""
	var current_time = Time.get_ticks_msec() / 1000.0
	var time_since_last_switch = current_time - last_stance_switch_time
	var remaining = stance_switch_cooldown - time_since_last_switch
	return max(0.0, remaining)

func get_available_stances() -> Array[String]:
	"""Get all stances available to the player"""
	var available: Array[String] = []
	
	for stance_id in available_stances:
		var stance_data = available_stances[stance_id]
		if can_activate_stance(stance_data):
			available.append(stance_id)
	
	return available

func get_stance_summary() -> Dictionary:
	"""Get a summary of current stance status"""
	return {
		"active_stances": active_stances,
		"available_stances": get_available_stances(),
		"stance_effects": stance_effects,
		"can_switch": can_switch_stance(),
		"cooldown_remaining": get_stance_switch_cooldown_remaining()
	}

func save_stance_data() -> Dictionary:
	"""Save stance data for persistence"""
	return {
		"active_stances": active_stances,
		"stance_effects": stance_effects,
		"last_stance_switch_time": last_stance_switch_time
	}

func load_stance_data_from_save(data: Dictionary):
	"""Load stance data from persistence"""
	active_stances = data.get("active_stances", ["combat", "arcane"])
	stance_effects = data.get("stance_effects", {})
	last_stance_switch_time = data.get("last_stance_switch_time", 0.0)
	
	# Reapply stance effects
	for stance_id in active_stances:
		if available_stances.has(stance_id):
			var stance_data = available_stances[stance_id]
			activate_stance(stance_id, stance_data)
	
	update_stance_skills()
	print("📚 StanceManager: Stance data loaded from save")

func reset_stances():
	"""Reset to default stances"""
	for stance_id in active_stances:
		deactivate_stance(stance_id)
	
	active_stances.clear()
	setup_default_stances()
	print("🔄 StanceManager: Stances reset to default") 
