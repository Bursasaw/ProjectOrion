extends Node
class_name FactionSynergyManager

# Faction Synergy Manager - Handles faction synergies inspired by SWGOH
# Manages faction bonuses, faction leaders, and faction-specific abilities

signal faction_synergy_activated(faction: String, bonus_type: String, description: String)
signal faction_leader_bonus(leader: String, faction: String, bonus: Dictionary)
signal faction_ability_triggered(faction: String, ability_name: String, effect: Dictionary)

# Faction synergies inspired by SWGOH
var faction_synergies = {
	"nokturn_shadows": {
		"name": "Nokturn Shadows",
		"description": "Shadow-aligned characters from Nokturn",
		"narrative": "The shadows of Nokturn work together, their dark powers amplifying each other's abilities.",
		"bonuses": {
			"stealth_bonus": 1.3,
			"void_damage": 1.2,
			"reality_distortion": 1.1,
			"bonus_description": "Shadow characters gain enhanced stealth and void damage"
		}
	},
	"elysion_ancients": {
		"name": "Elysion Ancients",
		"description": "Ancient-aligned characters from Elysion",
		"narrative": "The ancient wisdom of Elysion flows through the team, enhancing magical abilities.",
		"bonuses": {
			"magic_attack": 1.3,
			"magic_defense": 1.2,
			"knowledge_bonus": 1.1,
			"bonus_description": "Ancient characters gain enhanced magical abilities"
		}
	},
	"sylithar_crystals": {
		"name": "Sylithar Crystals",
		"description": "Crystal-aligned characters from Sylithar",
		"narrative": "Crystalline energies resonate between team members, amplifying light and crystal abilities.",
		"bonuses": {
			"light_damage": 1.3,
			"crystal_damage": 1.2,
			"reflection_bonus": 1.1,
			"bonus_description": "Crystal characters gain enhanced light and crystal abilities"
		}
	},
	"terra_naturals": {
		"name": "Terra Naturals",
		"description": "Nature-aligned characters from Terra",
		"narrative": "The natural forces of Terra strengthen the team, enhancing healing and nature abilities.",
		"bonuses": {
			"healing": 1.3,
			"nature_damage": 1.2,
			"life_force": 1.1,
			"bonus_description": "Nature characters gain enhanced healing and nature abilities"
		}
	},
	"aethra_windwalkers": {
		"name": "Aethra Windwalkers",
		"description": "Wind-aligned characters from Aethra",
		"narrative": "The winds of Aethra carry the team, enhancing speed and air abilities.",
		"bonuses": {
			"speed": 1.3,
			"air_damage": 1.2,
			"movement": 1.1,
			"bonus_description": "Wind characters gain enhanced speed and air abilities"
		}
	},
	"ombra_voidborn": {
		"name": "Ombra Voidborn",
		"description": "Void-aligned characters from Ombra",
		"narrative": "The void essence of Ombra corrupts reality, enhancing void and corruption abilities.",
		"bonuses": {
			"void_damage": 1.3,
			"corruption": 1.2,
			"reality_break": 1.1,
			"bonus_description": "Void characters gain enhanced void and corruption abilities"
		}
	},
	"krynn_dragons": {
		"name": "Krynn Dragons",
		"description": "Dragon-aligned characters from Krynn",
		"narrative": "The dragon essence of Krynn empowers the team, enhancing elemental and dragon abilities.",
		"bonuses": {
			"elemental_damage": 1.3,
			"dragon_damage": 1.2,
			"fire_resistance": 1.1,
			"bonus_description": "Dragon characters gain enhanced elemental and dragon abilities"
		}
	},
	"tauron_technocrats": {
		"name": "Tauron Technocrats",
		"description": "Tech-aligned characters from Tauron",
		"narrative": "The advanced technology of Tauron enhances the team, improving tech and energy abilities.",
		"bonuses": {
			"tech_damage": 1.3,
			"energy_damage": 1.2,
			"efficiency": 1.1,
			"bonus_description": "Tech characters gain enhanced tech and energy abilities"
		}
	},
	"aelria_consciousness": {
		"name": "Aelria Consciousness",
		"description": "Consciousness-aligned characters from Aelria",
		"narrative": "The consciousness field of Aelria unites the team, enhancing will and reality abilities.",
		"bonuses": {
			"reality_damage": 1.3,
			"will_power": 1.2,
			"consciousness": 1.1,
			"bonus_description": "Consciousness characters gain enhanced reality and will abilities"
		}
	}
}

# Faction leaders and their special abilities
var faction_leaders = {
	"nokturn_shadows": {
		"leader_name": "Shadow Lord",
		"leader_ability": "Shadow Mastery",
		"description": "Increases shadow damage and stealth for all shadow characters",
		"bonus": {"shadow_damage": 1.5, "stealth": 1.4}
	},
	"elysion_ancients": {
		"leader_name": "Ancient Sage",
		"leader_ability": "Ancient Wisdom",
		"description": "Increases magic attack and defense for all ancient characters",
		"bonus": {"magic_attack": 1.5, "magic_defense": 1.4}
	},
	"sylithar_crystals": {
		"leader_name": "Crystal Master",
		"leader_ability": "Crystal Resonance",
		"description": "Increases light and crystal damage for all crystal characters",
		"bonus": {"light_damage": 1.5, "crystal_damage": 1.4}
	},
	"terra_naturals": {
		"leader_name": "Nature Guardian",
		"leader_ability": "Life Force",
		"description": "Increases healing and nature damage for all nature characters",
		"bonus": {"healing": 1.5, "nature_damage": 1.4}
	},
	"aethra_windwalkers": {
		"leader_name": "Wind Master",
		"leader_ability": "Wind Surge",
		"description": "Increases speed and air damage for all wind characters",
		"bonus": {"speed": 1.5, "air_damage": 1.4}
	},
	"ombra_voidborn": {
		"leader_name": "Void Lord",
		"leader_ability": "Void Corruption",
		"description": "Increases void damage and corruption for all void characters",
		"bonus": {"void_damage": 1.5, "corruption": 1.4}
	},
	"krynn_dragons": {
		"leader_name": "Dragon King",
		"leader_ability": "Dragon Roar",
		"description": "Increases elemental and dragon damage for all dragon characters",
		"bonus": {"elemental_damage": 1.5, "dragon_damage": 1.4}
	},
	"tauron_technocrats": {
		"leader_name": "Tech Master",
		"leader_ability": "Technological Superiority",
		"description": "Increases tech and energy damage for all tech characters",
		"bonus": {"tech_damage": 1.5, "energy_damage": 1.4}
	},
	"aelria_consciousness": {
		"leader_name": "Consciousness Master",
		"leader_ability": "Reality Bending",
		"description": "Increases reality damage and will power for all consciousness characters",
		"bonus": {"reality_damage": 1.5, "will_power": 1.4}
	}
}

# Actor faction assignments
var actor_factions: Dictionary = {}
var faction_history: Array = []

# Faction-specific abilities
var faction_abilities = {
	"nokturn_shadows": {
		"shadow_veil": {"description": "All shadow characters gain stealth", "effect": {"stealth": 1.3}},
		"void_corruption": {"description": "All shadow characters gain void damage", "effect": {"void_damage": 1.2}}
	},
	"elysion_ancients": {
		"ancient_ward": {"description": "All ancient characters gain magic defense", "effect": {"magic_defense": 1.3}},
		"knowledge_field": {"description": "All ancient characters gain magic attack", "effect": {"magic_attack": 1.2}}
	},
	"sylithar_crystals": {
		"crystal_barrier": {"description": "All crystal characters gain light resistance", "effect": {"light_resistance": 1.3}},
		"light_amplification": {"description": "All crystal characters gain light damage", "effect": {"light_damage": 1.2}}
	},
	"terra_naturals": {
		"life_force": {"description": "All nature characters gain healing", "effect": {"healing": 1.3}},
		"nature_affinity": {"description": "All nature characters gain nature damage", "effect": {"nature_damage": 1.2}}
	},
	"aethra_windwalkers": {
		"wind_surge": {"description": "All wind characters gain speed", "effect": {"speed": 1.3}},
		"air_mastery": {"description": "All wind characters gain air damage", "effect": {"air_damage": 1.2}}
	},
	"ombra_voidborn": {
		"void_corruption": {"description": "All void characters gain void damage", "effect": {"void_damage": 1.3}},
		"reality_break": {"description": "All void characters gain corruption", "effect": {"corruption": 1.2}}
	},
	"krynn_dragons": {
		"dragon_roar": {"description": "All dragon characters gain elemental damage", "effect": {"elemental_damage": 1.3}},
		"fire_breath": {"description": "All dragon characters gain dragon damage", "effect": {"dragon_damage": 1.2}}
	},
	"tauron_technocrats": {
		"tech_superiority": {"description": "All tech characters gain tech damage", "effect": {"tech_damage": 1.3}},
		"energy_amplification": {"description": "All tech characters gain energy damage", "effect": {"energy_damage": 1.2}}
	},
	"aelria_consciousness": {
		"reality_bending": {"description": "All consciousness characters gain reality damage", "effect": {"reality_damage": 1.3}},
		"will_amplification": {"description": "All consciousness characters gain will power", "effect": {"will_power": 1.2}}
	}
}

func _ready():
	"""Initialize faction synergy manager"""
	print("FactionSynergyManager: Initialized")

func assign_faction(actor_name: String, faction: String) -> bool:
	"""Assign a faction to an actor"""
	if not faction_synergies.has(faction):
		print("FactionSynergyManager: Unknown faction: %s" % faction)
		return false
	
	actor_factions[actor_name] = faction
	
	# Add to history
	faction_history.append({
		"turn": get_current_turn(),
		"actor": actor_name,
		"action": "assign_faction",
		"faction": faction
	})
	
	print("FactionSynergyManager: Assigned %s to faction %s" % [actor_name, faction])
	
	return true

func get_actor_faction(actor_name: String) -> String:
	"""Get the faction of an actor"""
	return actor_factions.get(actor_name, "")

func get_faction_bonuses(actor_name: String) -> Dictionary:
	"""Get faction bonuses for an actor"""
	var faction = get_actor_faction(actor_name)
	if faction == "":
		return {}
	
	var faction_data = faction_synergies.get(faction, {})
	return faction_data.get("bonuses", {})

func get_faction_leader_bonus(faction: String) -> Dictionary:
	"""Get faction leader bonus for a faction"""
	var leader_data = faction_leaders.get(faction, {})
	return leader_data.get("bonus", {})

func trigger_faction_ability(faction: String, ability_name: String) -> bool:
	"""Trigger a faction-specific ability"""
	if not faction_abilities.has(faction):
		print("FactionSynergyManager: Unknown faction: %s" % faction)
		return false
	
	var faction_ability_data = faction_abilities[faction]
	if not faction_ability_data.has(ability_name):
		print("FactionSynergyManager: Unknown ability %s for faction %s" % [ability_name, faction])
		return false
	
	var ability_data = faction_ability_data[ability_name]
	var effect = ability_data.get("effect", {})
	
	# Add to history
	faction_history.append({
		"turn": get_current_turn(),
		"faction": faction,
		"action": "trigger_faction_ability",
		"ability_name": ability_name,
		"effect": effect
	})
	
	# Check for faction leader bonus
	var leader_info = get_faction_leader_info(faction)
	if leader_info.has("leader_name"):
		var leader_bonus = get_faction_leader_bonus(faction)
		faction_leader_bonus.emit(leader_info["leader_name"], faction, leader_bonus)
	
	# Emit signal
	faction_ability_triggered.emit(faction, ability_name, effect)
	
	print("FactionSynergyManager: Triggered %s ability for faction %s" % [ability_name, faction])
	
	return true

func get_faction_synergy_bonus(team_factions: Array) -> Dictionary:
	"""Calculate faction synergy bonus for a team"""
	var synergy_bonuses = {}
	var faction_counts = {}
	
	# Count faction members
	for faction in team_factions:
		faction_counts[faction] = faction_counts.get(faction, 0) + 1
	
	# Calculate bonuses for each faction
	for faction in faction_counts.keys():
		var count = faction_counts[faction]
		var faction_data = faction_synergies.get(faction, {})
		var bonuses = faction_data.get("bonuses", {})
		
		# Apply bonus based on number of faction members
		for bonus_type in bonuses.keys():
			if bonus_type != "bonus_description":
				var base_bonus = bonuses[bonus_type]
				var total_bonus = base_bonus * count
				synergy_bonuses[bonus_type] = synergy_bonuses.get(bonus_type, 1.0) + (total_bonus - 1.0)
	
	# Add to history
	faction_history.append({
		"turn": get_current_turn(),
		"action": "calculate_synergy",
		"team_factions": team_factions,
		"faction_counts": faction_counts,
		"synergy_bonuses": synergy_bonuses
	})
	
	# Emit signal
	faction_synergy_activated.emit("team", "synergy", "Faction synergy bonuses calculated")
	
	return synergy_bonuses

func get_faction_info(faction: String) -> Dictionary:
	"""Get information about a specific faction"""
	return faction_synergies.get(faction, {})

func get_faction_leader_info(faction: String) -> Dictionary:
	"""Get information about a faction leader"""
	return faction_leaders.get(faction, {})

func get_available_factions() -> Array:
	"""Get all available factions"""
	var available = []
	
	for faction in faction_synergies.keys():
		var faction_data = faction_synergies[faction]
		available.append({
			"faction": faction,
			"name": faction_data["name"],
			"description": faction_data["description"],
			"narrative": faction_data["narrative"],
			"bonuses": faction_data["bonuses"]
		})
	
	return available

func get_faction_abilities(faction: String) -> Array:
	"""Get all abilities for a specific faction"""
	if not faction_abilities.has(faction):
		return []
	
	var abilities = []
	for ability_name in faction_abilities[faction].keys():
		var ability_data = faction_abilities[faction][ability_name]
		abilities.append({
			"name": ability_name,
			"description": ability_data["description"],
			"effect": ability_data["effect"]
		})
	
	return abilities

func get_current_turn() -> int:
	"""Get current turn number (placeholder)"""
	# In a real implementation, this would get the current turn from CombatManager
	return 1

func clear_actor_faction(actor_name: String):
	"""Clear faction assignment for an actor"""
	if actor_factions.has(actor_name):
		actor_factions.erase(actor_name)
		print("FactionSynergyManager: Cleared faction for %s" % actor_name)

func get_faction_statistics(actor_name: String) -> Dictionary:
	"""Get faction statistics for an actor"""
	var faction = get_actor_faction(actor_name)
	if faction == "":
		return {}
	
	var faction_data = faction_synergies.get(faction, {})
	var leader_data = faction_leaders.get(faction, {})
	var abilities = get_faction_abilities(faction)
	
	return {
		"faction": faction,
		"faction_name": faction_data.get("name", ""),
		"faction_description": faction_data.get("description", ""),
		"faction_bonuses": faction_data.get("bonuses", {}),
		"leader_name": leader_data.get("leader_name", ""),
		"leader_ability": leader_data.get("leader_ability", ""),
		"leader_bonus": leader_data.get("bonus", {}),
		"faction_abilities": abilities.size()
	}

func get_faction_system_statistics() -> Dictionary:
	"""Get overall faction system statistics"""
	var total_actors = actor_factions.size()
	var faction_counts = {}
	
	for actor_name in actor_factions.keys():
		var faction = actor_factions[actor_name]
		faction_counts[faction] = faction_counts.get(faction, 0) + 1
	
	return {
		"actors_with_factions": total_actors,
		"faction_distribution": faction_counts,
		"total_factions": faction_synergies.size(),
		"total_leaders": faction_leaders.size(),
		"total_history": faction_history.size()
	} 