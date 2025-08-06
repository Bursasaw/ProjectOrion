extends Node
class_name AllOutAttackManager

# All-Out Attack Manager - Handles team coordination mechanics
# Inspired by Persona series with multiverse-specific enhancements

signal all_out_attack_triggered(condition: String, damage_multiplier: float, description: String)
signal all_out_attack_completed(targets: Array, total_damage: int, narrative: String)
# This signal is used in CombatManager.gd - line 281
signal all_out_attack_condition_met(condition: String, description: String)

# All-out attack conditions and their effects
var all_out_conditions = {
	"all_enemies_weak": {
		"damage_multiplier": 2.0,
		"description": "All enemies are vulnerable!",
		"narrative": "Your enemies are completely exposed to your coordinated assault!",
		"requirement": "all_enemies_have_weakness",
		"world_bonus": {
			"nokturn": 1.3,
			"elysion": 1.2,
			"sylithar": 1.4,
			"terra": 1.1,
			"aethra": 1.3,
			"ombra": 1.5,
			"krynn": 1.2,
			"tauron": 1.1,
			"aelria": 1.4
		}
	},
	"elemental_synergy": {
		"damage_multiplier": 1.5,
		"description": "Elemental resonance amplifies the attack!",
		"narrative": "The elements harmonize perfectly, creating a devastating elemental cascade!",
		"requirement": "team_has_elemental_advantage",
		"world_bonus": {
			"sylithar": 1.6,
			"krynn": 1.4,
			"elysion": 1.3,
			"terra": 1.2,
			"aethra": 1.3,
			"ombra": 1.5,
			"nokturn": 1.2,
			"tauron": 1.1,
			"aelria": 1.4
		}
	},
	"world_alignment": {
		"damage_multiplier": 1.8,
		"description": "The multiverse itself aids your strike!",
		"narrative": "The very fabric of reality bends to your will, amplifying your coordinated assault!",
		"requirement": "team_aligned_with_world",
		"world_bonus": {
			"aelria": 2.0,
			"ombra": 1.8,
			"elysion": 1.6,
			"sylithar": 1.5,
			"krynn": 1.4,
			"nokturn": 1.3,
			"terra": 1.2,
			"aethra": 1.3,
			"tauron": 1.1
		}
	},
	"species_synergy": {
		"damage_multiplier": 1.6,
		"description": "Your species' natural abilities amplify the attack!",
		"narrative": "Your shared heritage creates a powerful resonance that devastates your enemies!",
		"requirement": "team_has_species_synergy",
		"world_bonus": {
			"krynn": 1.7,
			"elysion": 1.5,
			"sylithar": 1.4,
			"terra": 1.3,
			"aethra": 1.4,
			"ombra": 1.6,
			"nokturn": 1.3,
			"tauron": 1.2,
			"aelria": 1.5
		}
	},
	"faction_unity": {
		"damage_multiplier": 1.4,
		"description": "Your faction's ideals strengthen the attack!",
		"narrative": "United by common purpose, your faction's resolve manifests as overwhelming force!",
		"requirement": "team_has_faction_unity",
		"world_bonus": {
			"elysion": 1.6,
			"aelria": 1.5,
			"krynn": 1.4,
			"sylithar": 1.3,
			"terra": 1.2,
			"aethra": 1.3,
			"ombra": 1.4,
			"nokturn": 1.2,
			"tauron": 1.1
		}
	},
	"void_resonance": {
		"damage_multiplier": 2.2,
		"description": "The void itself responds to your presence!",
		"narrative": "Reality itself warps around your coordinated assault, creating impossible devastation!",
		"requirement": "team_has_void_affinity",
		"world_bonus": {
			"ombra": 2.5,
			"aelria": 2.2,
			"nokturn": 1.8,
			"elysion": 1.6,
			"sylithar": 1.5,
			"krynn": 1.4,
			"terra": 1.3,
			"aethra": 1.4,
			"tauron": 1.2
		}
	},
	"ancient_technology": {
		"damage_multiplier": 1.7,
		"description": "Forgotten technology amplifies your attack!",
		"narrative": "Ancient technology resonates with your coordinated assault, creating devastating results!",
		"requirement": "team_has_ancient_tech",
		"world_bonus": {
			"tauron": 1.9,
			"elysion": 1.7,
			"aelria": 1.6,
			"sylithar": 1.5,
			"krynn": 1.4,
			"terra": 1.3,
			"aethra": 1.4,
			"ombra": 1.5,
			"nokturn": 1.3
		}
	},
	"reality_bending": {
		"damage_multiplier": 2.5,
		"description": "Your will shapes reality itself!",
		"narrative": "The very laws of reality bend to your collective will, creating impossible devastation!",
		"requirement": "team_has_reality_control",
		"world_bonus": {
			"aelria": 3.0,
			"ombra": 2.5,
			"elysion": 2.0,
			"sylithar": 1.8,
			"krynn": 1.7,
			"terra": 1.5,
			"aethra": 1.6,
			"nokturn": 1.4,
			"tauron": 1.3
		}
	}
}

# Current all-out attack state
var current_all_out_condition: String = ""
var all_out_attack_active: bool = false
var all_out_damage_multiplier: float = 1.0
var all_out_narrative: String = ""

# Team coordination tracking
var team_members: Array = []
var current_world: String = ""
var team_species: Array = []
var team_factions: Array = []

func initialize_all_out_system(team: Array, world: String):
	"""Initialize the all-out attack system with team and world data"""
	team_members = team
	current_world = world
	
	# Extract team information
	team_species.clear()
	team_factions.clear()
	
	for member in team:
		if member.has_method("get_species"):
			team_species.append(member.get_species())
		if member.has_method("get_faction"):
			team_factions.append(member.get_faction())
	
	print("AllOutAttackManager: Initialized with %d team members in %s world" % [team.size(), world])

func check_all_out_conditions(enemies: Array) -> Array:
	"""Check which all-out attack conditions are met"""
	var met_conditions = []
	
	for condition_name in all_out_conditions:
		var condition = all_out_conditions[condition_name]
		var requirement = condition["requirement"]
		
		if check_requirement(requirement, enemies):
			met_conditions.append(condition_name)
			print("AllOutAttackManager: Condition '%s' met!" % condition_name)
	
	return met_conditions

func check_requirement(requirement: String, enemies: Array) -> bool:
	"""Check if a specific requirement is met"""
	match requirement:
		"all_enemies_have_weakness":
			return check_all_enemies_weak(enemies)
		"team_has_elemental_advantage":
			return check_elemental_advantage(enemies)
		"team_aligned_with_world":
			return check_world_alignment()
		"team_has_species_synergy":
			return check_species_synergy()
		"team_has_faction_unity":
			return check_faction_unity()
		"team_has_void_affinity":
			return check_void_affinity()
		"team_has_ancient_tech":
			return check_ancient_technology()
		"team_has_reality_control":
			return check_reality_control()
		_:
			return false

func check_all_enemies_weak(enemies: Array) -> bool:
	"""Check if all enemies have elemental weaknesses"""
	for enemy in enemies:
		if not enemy.has_method("get_elemental_weaknesses"):
			return false
		var weaknesses = enemy.get_elemental_weaknesses()
		if weaknesses.size() == 0:
			return false
	return true

func check_elemental_advantage(enemies: Array) -> bool:
	"""Check if team has elemental advantage over enemies"""
	var team_elements = []
	for member in team_members:
		if member.has_method("get_primary_element"):
			team_elements.append(member.get_primary_element())
	
	for enemy in enemies:
		if enemy.has_method("get_elemental_weaknesses"):
			var enemy_weaknesses = enemy.get_elemental_weaknesses()
			var has_advantage = false
			for element in team_elements:
				if enemy_weaknesses.has(element):
					has_advantage = true
					break
			if not has_advantage:
				return false
	return true

func check_world_alignment() -> bool:
	"""Check if team is aligned with current world"""
	if current_world == "":
		return false
	
	# Check if team members are from the current world
	for member in team_members:
		if member.has_method("get_home_world"):
			var home_world = member.get_home_world()
			if home_world == current_world:
				return true
	return false

func check_species_synergy() -> bool:
	"""Check if team has species synergy"""
	if team_species.size() < 2:
		return false
	
	# Check if all team members are the same species
	var first_species = team_species[0]
	for species in team_species:
		if species != first_species:
			return false
	return true

func check_faction_unity() -> bool:
	"""Check if team has faction unity"""
	if team_factions.size() < 2:
		return false
	
	# Check if all team members are from the same faction
	var first_faction = team_factions[0]
	for faction in team_factions:
		if faction != first_faction:
			return false
	return true

func check_void_affinity() -> bool:
	"""Check if team has void affinity"""
	for member in team_members:
		if member.has_method("has_void_affinity"):
			if member.has_void_affinity():
				return true
	return false

func check_ancient_technology() -> bool:
	"""Check if team has ancient technology"""
	for member in team_members:
		if member.has_method("has_ancient_tech"):
			if member.has_ancient_tech():
				return true
	return false

func check_reality_control() -> bool:
	"""Check if team has reality control abilities"""
	for member in team_members:
		if member.has_method("has_reality_control"):
			if member.has_reality_control():
				return true
	return false

func trigger_all_out_attack(condition: String, targets: Array, base_damage: int) -> Dictionary:
	"""Trigger an all-out attack with the specified condition"""
	if not all_out_conditions.has(condition):
		print("AllOutAttackManager: Invalid condition: %s" % condition)
		return {}
	
	var condition_data = all_out_conditions[condition]
	var damage_multiplier = condition_data["damage_multiplier"]
	var description = condition_data["description"]
	var narrative = condition_data["narrative"]
	
	# Apply world bonus if available
	if condition_data.has("world_bonus") and condition_data["world_bonus"].has(current_world):
		var world_bonus = condition_data["world_bonus"][current_world]
		damage_multiplier *= world_bonus
		print("AllOutAttackManager: Applied %s world bonus: %.1fx" % [current_world, world_bonus])
	
	# Calculate final damage
	var final_damage = int(base_damage * damage_multiplier)
	
	# Apply damage to all targets
	var total_damage = 0
	for target in targets:
		if target.has_method("take_damage"):
			target.take_damage(final_damage)
			total_damage += final_damage
			print("AllOutAttackManager: All-out attack deals %d damage to %s" % [final_damage, target.character_name])
	
	# Set current state
	current_all_out_condition = condition
	all_out_attack_active = true
	all_out_damage_multiplier = damage_multiplier
	all_out_narrative = narrative
	
	# Emit signals
	all_out_attack_triggered.emit(condition, damage_multiplier, description)
	all_out_attack_completed.emit(targets, total_damage, narrative)
	
	print("AllOutAttackManager: All-out attack triggered! %s (%.1fx damage)" % [description, damage_multiplier])
	
	return {
		"condition": condition,
		"damage_multiplier": damage_multiplier,
		"description": description,
		"narrative": narrative,
		"total_damage": total_damage,
		"targets_hit": targets.size()
	}

func get_available_all_out_attacks(enemies: Array) -> Array:
	"""Get list of available all-out attack conditions"""
	return check_all_out_conditions(enemies)

func get_all_out_attack_info(condition: String) -> Dictionary:
	"""Get information about a specific all-out attack condition"""
	if not all_out_conditions.has(condition):
		return {}
	
	var condition_data = all_out_conditions[condition].duplicate()
	
	# Add world bonus information
	if condition_data.has("world_bonus") and condition_data["world_bonus"].has(current_world):
		var world_bonus = condition_data["world_bonus"][current_world]
		condition_data["effective_multiplier"] = condition_data["damage_multiplier"] * world_bonus
		condition_data["world_bonus_applied"] = world_bonus
	else:
		condition_data["effective_multiplier"] = condition_data["damage_multiplier"]
		condition_data["world_bonus_applied"] = 1.0
	
	return condition_data

func reset_all_out_attack():
	"""Reset the all-out attack state"""
	current_all_out_condition = ""
	all_out_attack_active = false
	all_out_damage_multiplier = 1.0
	all_out_narrative = ""
	print("AllOutAttackManager: All-out attack state reset")

func get_all_out_attack_statistics() -> Dictionary:
	"""Get all-out attack system statistics"""
	return {
		"current_condition": current_all_out_condition,
		"attack_active": all_out_attack_active,
		"damage_multiplier": all_out_damage_multiplier,
		"team_size": team_members.size(),
		"current_world": current_world,
		"available_conditions": all_out_conditions.size()
	} 