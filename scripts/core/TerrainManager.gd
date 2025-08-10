extends Node
class_name TerrainManager

# Terrain Manager - Handles dynamic terrain effects from different worlds
# Manages terrain effects, world-specific enhancements, and narrative integration

signal terrain_effect_applied(world: String, effect: String, description: String)
signal terrain_narrative_triggered(world: String, narrative: String)
signal terrain_state_changed(world: String, old_terrain: String, new_terrain: String)

# Dynamic terrain from different worlds
var world_terrains = {
	"nokturn": {
		"shadow_veils": true,
		"reality_distortion": 0.3,
		"stealth_bonus": 1.4,
		"description": "Shadows dance around you",
		"narrative": "Darkness envelops the battlefield, shadows twisting and writhing with unnatural life. Your movements become fluid and silent, while reality itself seems to bend and distort at the edges of your vision.",
		"combat_effects": {
			"stealth": 1.4,
			"accuracy": 0.9,
			"magic_defense": 1.2,
			"void_resistance": 1.3
		}
	},
	"elysion": {
		"ancient_wards": true,
		"magic_amplification": 1.2,
		"knowledge_fields": true,
		"description": "Ancient magic permeates the air",
		"narrative": "Ancient wards pulse with forgotten power, their runes glowing softly in the air. Knowledge flows freely here, enhancing magical abilities while ancient wisdom guides your actions.",
		"combat_effects": {
			"magic_attack": 1.3,
			"magic_defense": 1.4,
			"accuracy": 1.2,
			"healing": 1.3
		}
	},
	"sylithar": {
		"glass_reflections": true,
		"light_manipulation": 1.3,
		"crystal_resonance": true,
		"description": "Light bends through crystalline structures",
		"narrative": "Crystalline structures scatter light in mesmerizing patterns, creating illusions and amplifying magical power. The air shimmers with refracted light, making every spell more potent.",
		"combat_effects": {
			"magic_attack": 1.4,
			"accuracy": 1.3,
			"crystal_damage": 1.5,
			"light_resistance": 1.2
		}
	},
	"terra": {
		"primal_energy": true,
		"nature_affinity": 1.2,
		"life_force": true,
		"description": "The raw power of nature surrounds you",
		"narrative": "Primal energy flows through the earth, connecting you to the natural world. Life force surges through your veins, making you stronger and more resilient.",
		"combat_effects": {
			"attack": 1.2,
			"defense": 1.3,
			"healing": 1.4,
			"nature_damage": 1.3
		}
	},
	"aethra": {
		"wind_currents": true,
		"movement_bonus": 1.3,
		"air_mastery": true,
		"description": "Wind currents guide your movements",
		"narrative": "Wind currents swirl around you, carrying you effortlessly through the battlefield. The air itself seems to respond to your will, enhancing your mobility and speed.",
		"combat_effects": {
			"speed": 1.4,
			"movement": 1.3,
			"air_damage": 1.3,
			"dodge": 1.2
		}
	},
	"ombra": {
		"void_whispers": true,
		"reality_instability": 0.4,
		"void_corruption": true,
		"description": "Reality itself seems unstable",
		"narrative": "Void whispers echo through the air, reality itself bending and warping. The fabric of space-time seems thin here, allowing impossible feats but at a terrible cost.",
		"combat_effects": {
			"void_damage": 1.6,
			"reality_bending": 1.4,
			"magic_defense": 0.8,
			"void_resistance": 1.5
		}
	},
	"krynn": {
		"dragon_essence": true,
		"elemental_power": 1.4,
		"dragon_roar": true,
		"description": "The essence of dragons empowers you",
		"narrative": "Dragon essence flows through the air, ancient and powerful. The very ground seems to resonate with draconic energy, amplifying elemental abilities and filling you with primal strength.",
		"combat_effects": {
			"elemental_damage": 1.5,
			"attack": 1.3,
			"fire_resistance": 1.4,
			"dragon_damage": 1.6
		}
	},
	"tauron": {
		"technological_field": true,
		"tech_affinity": 1.3,
		"energy_amplification": true,
		"description": "Advanced technology hums around you",
		"narrative": "Advanced technology hums with barely contained energy, circuits and machinery enhancing your capabilities. The air crackles with technological power, making every action more efficient.",
		"combat_effects": {
			"tech_damage": 1.4,
			"accuracy": 1.3,
			"energy_damage": 1.3,
			"tech_resistance": 1.2
		}
	},
	"aelria": {
		"reality_bending": true,
		"will_power": 1.5,
		"consciousness_field": true,
		"description": "Your will shapes reality itself",
		"narrative": "Reality bends to your will here, the very fabric of existence responding to your thoughts. Your consciousness expands, allowing you to reshape the battlefield itself.",
		"combat_effects": {
			"reality_damage": 1.7,
			"will_power": 1.5,
			"consciousness": 1.4,
			"reality_resistance": 1.3
		}
	}
}

# Active terrain effects
var active_terrain: String = ""
var terrain_duration: int = 0
var terrain_history: Array = []

# Terrain transition effects
var terrain_transitions = {
	"nokturn": ["ombra", "aelria", "elysion"],
	"elysion": ["sylithar", "aelria", "nokturn"],
	"sylithar": ["elysion", "aethra", "krynn"],
	"terra": ["aethra", "krynn", "sylithar"],
	"aethra": ["sylithar", "terra", "krynn"],
	"ombra": ["nokturn", "aelria", "krynn"],
	"krynn": ["terra", "sylithar", "aethra"],
	"tauron": ["aelria", "krynn", "elysion"],
	"aelria": ["ombra", "nokturn", "tauron"]
}

func set_terrain(world: String, duration: int = 10) -> bool:
	"""Set terrain for a specific world"""
	if not world_terrains.has(world):
		print("TerrainManager: Invalid world terrain: %s" % world)
		return false
	
	var old_terrain = active_terrain
	active_terrain = world
	terrain_duration = duration
	
	var terrain_data = world_terrains[world]
	var description = "Terrain changed to %s" % world
	
	print("TerrainManager: %s" % description)
	terrain_state_changed.emit(world, old_terrain, active_terrain)
	
	# Add to history
	terrain_history.append({
		"turn": get_current_turn(),
		"world": world,
		"old_terrain": old_terrain,
		"new_terrain": active_terrain,
		"duration": duration,
		"description": terrain_data["description"],
		"narrative": terrain_data["narrative"]
	})
	
	return true

func get_terrain_effects(world: String = "") -> Dictionary:
	"""Get terrain effects for a world"""
	var target_world = world if world != "" else active_terrain
	
	if not world_terrains.has(target_world):
		return {}
	
	return world_terrains[target_world]["combat_effects"]

func apply_terrain_effects_to_actor(actor, _world: String = "") -> Dictionary:
	"""Apply terrain effects to an actor"""
	var effects_applied = {}
	var terrain_data = world_terrains.get(active_terrain, {})
	
	if terrain_data.size() == 0:
		return effects_applied
	
	var combat_effects = terrain_data.get("combat_effects", {})
	
	# Apply stealth bonus
	if combat_effects.has("stealth"):
		if actor.has_method("add_stealth_bonus"):
			actor.add_stealth_bonus(combat_effects["stealth"])
		effects_applied["stealth"] = combat_effects["stealth"]
		print("TerrainManager: Applied %.1fx stealth bonus from %s terrain" % [combat_effects["stealth"], active_terrain])
	
	# Apply accuracy bonus/penalty
	if combat_effects.has("accuracy"):
		if actor.has_method("add_accuracy_bonus"):
			actor.add_accuracy_bonus(combat_effects["accuracy"])
		effects_applied["accuracy"] = combat_effects["accuracy"]
		print("TerrainManager: Applied %.1fx accuracy bonus from %s terrain" % [combat_effects["accuracy"], active_terrain])
	
	# Apply magic defense bonus
	if combat_effects.has("magic_defense"):
		if actor.has_method("add_magic_defense_bonus"):
			actor.add_magic_defense_bonus(combat_effects["magic_defense"])
		effects_applied["magic_defense"] = combat_effects["magic_defense"]
		print("TerrainManager: Applied %.1fx magic defense bonus from %s terrain" % [combat_effects["magic_defense"], active_terrain])
	
	# Apply void resistance bonus
	if combat_effects.has("void_resistance"):
		if actor.has_method("add_void_resistance_bonus"):
			actor.add_void_resistance_bonus(combat_effects["void_resistance"])
		effects_applied["void_resistance"] = combat_effects["void_resistance"]
		print("TerrainManager: Applied %.1fx void resistance bonus from %s terrain" % [combat_effects["void_resistance"], active_terrain])
	
	# Apply magic attack bonus
	if combat_effects.has("magic_attack"):
		if actor.has_method("add_magic_attack_bonus"):
			actor.add_magic_attack_bonus(combat_effects["magic_attack"])
		effects_applied["magic_attack"] = combat_effects["magic_attack"]
		print("TerrainManager: Applied %.1fx magic attack bonus from %s terrain" % [combat_effects["magic_attack"], active_terrain])
	
	# Apply healing bonus
	if combat_effects.has("healing"):
		if actor.has_method("add_healing_bonus"):
			actor.add_healing_bonus(combat_effects["healing"])
		effects_applied["healing"] = combat_effects["healing"]
		print("TerrainManager: Applied %.1fx healing bonus from %s terrain" % [combat_effects["healing"], active_terrain])
	
	# Apply crystal damage bonus
	if combat_effects.has("crystal_damage"):
		if actor.has_method("add_crystal_damage_bonus"):
			actor.add_crystal_damage_bonus(combat_effects["crystal_damage"])
		effects_applied["crystal_damage"] = combat_effects["crystal_damage"]
		print("TerrainManager: Applied %.1fx crystal damage bonus from %s terrain" % [combat_effects["crystal_damage"], active_terrain])
	
	# Apply light resistance bonus
	if combat_effects.has("light_resistance"):
		if actor.has_method("add_light_resistance_bonus"):
			actor.add_light_resistance_bonus(combat_effects["light_resistance"])
		effects_applied["light_resistance"] = combat_effects["light_resistance"]
		print("TerrainManager: Applied %.1fx light resistance bonus from %s terrain" % [combat_effects["light_resistance"], active_terrain])
	
	# Apply attack bonus
	if combat_effects.has("attack"):
		if actor.has_method("add_attack_bonus"):
			actor.add_attack_bonus(combat_effects["attack"])
		effects_applied["attack"] = combat_effects["attack"]
		print("TerrainManager: Applied %.1fx attack bonus from %s terrain" % [combat_effects["attack"], active_terrain])
	
	# Apply defense bonus
	if combat_effects.has("defense"):
		if actor.has_method("add_defense_bonus"):
			actor.add_defense_bonus(combat_effects["defense"])
		effects_applied["defense"] = combat_effects["defense"]
		print("TerrainManager: Applied %.1fx defense bonus from %s terrain" % [combat_effects["defense"], active_terrain])
	
	# Apply nature damage bonus
	if combat_effects.has("nature_damage"):
		if actor.has_method("add_nature_damage_bonus"):
			actor.add_nature_damage_bonus(combat_effects["nature_damage"])
		effects_applied["nature_damage"] = combat_effects["nature_damage"]
		print("TerrainManager: Applied %.1fx nature damage bonus from %s terrain" % [combat_effects["nature_damage"], active_terrain])
	
	# Apply speed bonus
	if combat_effects.has("speed"):
		if actor.has_method("add_speed_bonus"):
			actor.add_speed_bonus(combat_effects["speed"])
		effects_applied["speed"] = combat_effects["speed"]
		print("TerrainManager: Applied %.1fx speed bonus from %s terrain" % [combat_effects["speed"], active_terrain])
	
	# Apply movement bonus
	if combat_effects.has("movement"):
		if actor.has_method("add_movement_bonus"):
			actor.add_movement_bonus(combat_effects["movement"])
		effects_applied["movement"] = combat_effects["movement"]
		print("TerrainManager: Applied %.1fx movement bonus from %s terrain" % [combat_effects["movement"], active_terrain])
	
	# Apply air damage bonus
	if combat_effects.has("air_damage"):
		if actor.has_method("add_air_damage_bonus"):
			actor.add_air_damage_bonus(combat_effects["air_damage"])
		effects_applied["air_damage"] = combat_effects["air_damage"]
		print("TerrainManager: Applied %.1fx air damage bonus from %s terrain" % [combat_effects["air_damage"], active_terrain])
	
	# Apply dodge bonus
	if combat_effects.has("dodge"):
		if actor.has_method("add_dodge_bonus"):
			actor.add_dodge_bonus(combat_effects["dodge"])
		effects_applied["dodge"] = combat_effects["dodge"]
		print("TerrainManager: Applied %.1fx dodge bonus from %s terrain" % [combat_effects["dodge"], active_terrain])
	
	# Apply void damage bonus
	if combat_effects.has("void_damage"):
		if actor.has_method("add_void_damage_bonus"):
			actor.add_void_damage_bonus(combat_effects["void_damage"])
		effects_applied["void_damage"] = combat_effects["void_damage"]
		print("TerrainManager: Applied %.1fx void damage bonus from %s terrain" % [combat_effects["void_damage"], active_terrain])
	
	# Apply reality bending bonus
	if combat_effects.has("reality_bending"):
		if actor.has_method("add_reality_bending_bonus"):
			actor.add_reality_bending_bonus(combat_effects["reality_bending"])
		effects_applied["reality_bending"] = combat_effects["reality_bending"]
		print("TerrainManager: Applied %.1fx reality bending bonus from %s terrain" % [combat_effects["reality_bending"], active_terrain])
	
	# Apply elemental damage bonus
	if combat_effects.has("elemental_damage"):
		if actor.has_method("add_elemental_damage_bonus"):
			actor.add_elemental_damage_bonus(combat_effects["elemental_damage"])
		effects_applied["elemental_damage"] = combat_effects["elemental_damage"]
		print("TerrainManager: Applied %.1fx elemental damage bonus from %s terrain" % [combat_effects["elemental_damage"], active_terrain])
	
	# Apply fire resistance bonus
	if combat_effects.has("fire_resistance"):
		if actor.has_method("add_fire_resistance_bonus"):
			actor.add_fire_resistance_bonus(combat_effects["fire_resistance"])
		effects_applied["fire_resistance"] = combat_effects["fire_resistance"]
		print("TerrainManager: Applied %.1fx fire resistance bonus from %s terrain" % [combat_effects["fire_resistance"], active_terrain])
	
	# Apply dragon damage bonus
	if combat_effects.has("dragon_damage"):
		if actor.has_method("add_dragon_damage_bonus"):
			actor.add_dragon_damage_bonus(combat_effects["dragon_damage"])
		effects_applied["dragon_damage"] = combat_effects["dragon_damage"]
		print("TerrainManager: Applied %.1fx dragon damage bonus from %s terrain" % [combat_effects["dragon_damage"], active_terrain])
	
	# Apply tech damage bonus
	if combat_effects.has("tech_damage"):
		if actor.has_method("add_tech_damage_bonus"):
			actor.add_tech_damage_bonus(combat_effects["tech_damage"])
		effects_applied["tech_damage"] = combat_effects["tech_damage"]
		print("TerrainManager: Applied %.1fx tech damage bonus from %s terrain" % [combat_effects["tech_damage"], active_terrain])
	
	# Apply energy damage bonus
	if combat_effects.has("energy_damage"):
		if actor.has_method("add_energy_damage_bonus"):
			actor.add_energy_damage_bonus(combat_effects["energy_damage"])
		effects_applied["energy_damage"] = combat_effects["energy_damage"]
		print("TerrainManager: Applied %.1fx energy damage bonus from %s terrain" % [combat_effects["energy_damage"], active_terrain])
	
	# Apply tech resistance bonus
	if combat_effects.has("tech_resistance"):
		if actor.has_method("add_tech_resistance_bonus"):
			actor.add_tech_resistance_bonus(combat_effects["tech_resistance"])
		effects_applied["tech_resistance"] = combat_effects["tech_resistance"]
		print("TerrainManager: Applied %.1fx tech resistance bonus from %s terrain" % [combat_effects["tech_resistance"], active_terrain])
	
	# Apply reality damage bonus
	if combat_effects.has("reality_damage"):
		if actor.has_method("add_reality_damage_bonus"):
			actor.add_reality_damage_bonus(combat_effects["reality_damage"])
		effects_applied["reality_damage"] = combat_effects["reality_damage"]
		print("TerrainManager: Applied %.1fx reality damage bonus from %s terrain" % [combat_effects["reality_damage"], active_terrain])
	
	# Apply will power bonus
	if combat_effects.has("will_power"):
		if actor.has_method("add_will_power_bonus"):
			actor.add_will_power_bonus(combat_effects["will_power"])
		effects_applied["will_power"] = combat_effects["will_power"]
		print("TerrainManager: Applied %.1fx will power bonus from %s terrain" % [combat_effects["will_power"], active_terrain])
	
	# Apply consciousness bonus
	if combat_effects.has("consciousness"):
		if actor.has_method("add_consciousness_bonus"):
			actor.add_consciousness_bonus(combat_effects["consciousness"])
		effects_applied["consciousness"] = combat_effects["consciousness"]
		print("TerrainManager: Applied %.1fx consciousness bonus from %s terrain" % [combat_effects["consciousness"], active_terrain])
	
	# Apply reality resistance bonus
	if combat_effects.has("reality_resistance"):
		if actor.has_method("add_reality_resistance_bonus"):
			actor.add_reality_resistance_bonus(combat_effects["reality_resistance"])
		effects_applied["reality_resistance"] = combat_effects["reality_resistance"]
		print("TerrainManager: Applied %.1fx reality resistance bonus from %s terrain" % [combat_effects["reality_resistance"], active_terrain])
	
	# Emit effect applied signal
	if effects_applied.size() > 0:
		terrain_effect_applied.emit(active_terrain, str(effects_applied), terrain_data.get("description", ""))
	
	return effects_applied

func get_terrain_narrative(world: String = "") -> String:
	"""Get narrative description of terrain for a world"""
	var target_world = world if world != "" else active_terrain
	
	if not world_terrains.has(target_world):
		return "No terrain effect"
	
	var terrain_data = world_terrains[target_world]
	var narrative = terrain_data.get("narrative", "")
	
	if narrative != "":
		terrain_narrative_triggered.emit(target_world, narrative)
	
	return narrative

func get_available_terrain_transitions(world: String = "") -> Array:
	"""Get available terrain transitions for a world"""
	var target_world = world if world != "" else active_terrain
	var available = []
	
	if terrain_transitions.has(target_world):
		for transition_world in terrain_transitions[target_world]:
			var terrain_data = world_terrains[transition_world]
			available.append({
				"world": transition_world,
				"description": terrain_data["description"],
				"narrative": terrain_data["narrative"]
			})
	
	return available

func trigger_terrain_transition(new_world: String, duration: int = 10) -> bool:
	"""Trigger a terrain transition"""
	var available_transitions = get_available_terrain_transitions()
	
	for transition in available_transitions:
		if transition["world"] == new_world:
			return set_terrain(new_world, duration)
	
	print("TerrainManager: Invalid transition to %s from current terrain" % new_world)
	return false

func get_current_turn() -> int:
	"""Get current turn number (placeholder)"""
	# In a real implementation, this would get the current turn from CombatManager
	return 1

func clear_terrain():
	"""Clear current terrain"""
	var old_terrain = active_terrain
	active_terrain = ""
	terrain_duration = 0
	print("TerrainManager: Terrain cleared")
	terrain_state_changed.emit("", old_terrain, "")

func get_terrain_statistics() -> Dictionary:
	"""Get terrain system statistics"""
	return {
		"active_terrain": active_terrain,
		"terrain_duration": terrain_duration,
		"total_terrains": world_terrains.size(),
		"history_entries": terrain_history.size(),
		"available_transitions": terrain_transitions.size()
	} 