extends Node
class_name SurfaceManager

# Surface Manager - Handles environmental surfaces in combat
# Manages surface types, effects, and world-specific surfaces

signal surface_applied(surface_type: String, location: Vector2, description: String)
signal surface_removed(surface_type: String, location: Vector2)
signal surface_effect_triggered(surface_type: String, target, effect: String)

# Surface types and their effects
var surface_effects = {
	"fire": {
		"damage_per_turn": 3,
		"spread_chance": 0.3,
		"description": "Flames dance across the ground",
		"world_affinity": "sylithar",
		"elemental_bonus": {"fire": 1.5, "ice": 0.5},
		"spread_conditions": ["adjacent_fire", "flammable_surface"]
	},
	"water": {
		"conductivity": 2.0,
		"extinguishes_fire": true,
		"description": "Water pools reflect the light",
		"world_affinity": "aethra",
		"elemental_bonus": {"lightning": 2.0, "fire": 0.5},
		"spread_conditions": ["adjacent_water", "low_ground"]
	},
	"ice": {
		"slippery": true,
		"freeze_chance": 0.2,
		"description": "Ice crystals glint in the light",
		"world_affinity": "krynn",
		"elemental_bonus": {"ice": 1.5, "fire": 0.5},
		"spread_conditions": ["adjacent_ice", "cold_environment"]
	},
	"oil": {
		"flammable": true,
		"movement_penalty": 0.5,
		"description": "Thick oil coats the surface",
		"world_affinity": "tauron",
		"elemental_bonus": {"fire": 2.0, "lightning": 1.5},
		"spread_conditions": ["adjacent_oil", "porous_surface"]
	},
	"poison": {
		"damage_per_turn": 2,
		"spread_chance": 0.1,
		"description": "Toxic fumes rise from the ground",
		"world_affinity": "ombra",
		"elemental_bonus": {"void": 1.3, "light": 0.7},
		"spread_conditions": ["adjacent_poison", "organic_surface"]
	},
	"acid": {
		"damage_per_turn": 5,
		"corrosion": true,
		"description": "Acid bubbles and hisses",
		"world_affinity": "tauron",
		"elemental_bonus": {"tech": 1.5, "organic": 2.0},
		"spread_conditions": ["adjacent_acid", "metal_surface"]
	},
	"void": {
		"reality_distortion": true,
		"random_effects": true,
		"description": "Reality itself seems to bend",
		"world_affinity": "ombra",
		"elemental_bonus": {"void": 2.0, "light": 0.3},
		"spread_conditions": ["adjacent_void", "weak_reality"]
	},
	"light": {
		"healing_per_turn": 2,
		"purification": true,
		"description": "Sacred light emanates from the ground",
		"world_affinity": "elysion",
		"elemental_bonus": {"light": 1.5, "shadow": 0.5},
		"spread_conditions": ["adjacent_light", "holy_ground"]
	}
}

# World-specific surface types
var world_surfaces = {
	"nokturn": {
		"shadow_veil": {
			"stealth_bonus": 1.3,
			"description": "Shadows cloak your movements",
			"elemental_bonus": {"shadow": 1.4, "light": 0.6},
			"spread_conditions": ["adjacent_shadow", "dark_environment"]
		},
		"void_pool": {
			"reality_distortion": true,
			"description": "Reality itself seems to bend",
			"elemental_bonus": {"void": 1.8, "light": 0.4},
			"spread_conditions": ["adjacent_void", "weak_reality"]
		},
		"ancient_blood": {
			"magic_amplification": 1.4,
			"description": "Ancient power flows through the ground",
			"elemental_bonus": {"shadow": 1.3, "void": 1.2},
			"spread_conditions": ["adjacent_blood", "sacred_ground"]
		}
	},
	"elysion": {
		"ancient_ward": {
			"magic_amplification": 1.2,
			"description": "Ancient magic wards protect you",
			"elemental_bonus": {"light": 1.5, "shadow": 0.7},
			"spread_conditions": ["adjacent_ward", "holy_ground"]
		},
		"knowledge_field": {
			"skill_bonus": 1.3,
			"description": "Ancient knowledge flows through you",
			"elemental_bonus": {"light": 1.3, "magic": 1.4},
			"spread_conditions": ["adjacent_knowledge", "library_ground"]
		}
	},
	"sylithar": {
		"glass_shield": {
			"reflection": true,
			"description": "Crystalline structures reflect attacks",
			"elemental_bonus": {"light": 1.6, "fire": 1.3},
			"spread_conditions": ["adjacent_glass", "crystalline_ground"]
		},
		"solar_field": {
			"fire_amplification": 1.4,
			"description": "Solar energy empowers fire magic",
			"elemental_bonus": {"fire": 1.8, "light": 1.4},
			"spread_conditions": ["adjacent_solar", "sunlit_ground"]
		}
	}
}

# Active surfaces in current combat
var active_surfaces: Dictionary = {}
var surface_locations: Array[Vector2] = []
var surface_durations: Dictionary = {}

# Surface interaction tracking
var surface_interactions: Array[Dictionary] = []
var chain_reactions: Array[String] = []

func _ready():
	"""Initialize surface manager"""
	print("SurfaceManager: Initialized")

func apply_surface(surface_type: String, location: Vector2, duration: int = 3, source_world: String = ""):
	"""Apply a surface effect to a location"""
	if not surface_effects.has(surface_type):
		print("SurfaceManager: Invalid surface type: %s" % surface_type)
		return false
	
	var surface_data = surface_effects[surface_type]
	var surface_key = "%s_%s" % [surface_type, str(location)]
	
	# Check if surface already exists at location
	if active_surfaces.has(surface_key):
		# Extend duration or enhance effect
		surface_durations[surface_key] = max(surface_durations[surface_key], duration)
		print("SurfaceManager: Extended %s surface duration at %s" % [surface_type, str(location)])
	else:
		# Create new surface
		active_surfaces[surface_key] = surface_data.duplicate()
		surface_durations[surface_key] = duration
		surface_locations.append(location)
		
		# Add world-specific modifications
		if source_world != "" and world_surfaces.has(source_world):
			var world_surface_data = world_surfaces[source_world]
			# Check if this surface type has world affinity matching the source world
			if surface_data.has("world_affinity") and surface_data["world_affinity"] == source_world:
				# Apply world-specific enhancements to elemental bonuses
				if surface_data.has("elemental_bonus") and world_surface_data.has("solar_field"):
					var solar_field_data = world_surface_data["solar_field"]
					if solar_field_data.has("elemental_bonus"):
						for element in solar_field_data["elemental_bonus"]:
							if active_surfaces[surface_key]["elemental_bonus"].has(element):
								# Enhance the elemental bonus
								active_surfaces[surface_key]["elemental_bonus"][element] *= solar_field_data["elemental_bonus"][element]
								print("SurfaceManager: Enhanced %s bonus for %s surface from %s world" % [element, surface_type, source_world])
		
		print("SurfaceManager: Applied %s surface at %s (Duration: %d)" % [surface_type, str(location), duration])
	
	# Emit signal
	surface_applied.emit(surface_type, location, surface_data.description)
	
	# Check for chain reactions
	check_chain_reactions(surface_type, location)
	
	return true

func remove_surface(location: Vector2):
	"""Remove surface at specific location"""
	var surface_key = ""
	for key in active_surfaces.keys():
		if key.ends_with(str(location)):
			surface_key = key
			break
	
	if surface_key != "":
		var surface_type = surface_key.split("_")[0]
		active_surfaces.erase(surface_key)
		surface_durations.erase(surface_key)
		surface_locations.erase(location)
		
		print("SurfaceManager: Removed %s surface at %s" % [surface_type, str(location)])
		surface_removed.emit(surface_type, location)
		return true
	
	return false

func get_surface_at_location(location: Vector2) -> Dictionary:
	"""Get surface data at specific location"""
	for key in active_surfaces.keys():
		if key.ends_with(str(location)):
			return active_surfaces[key]
	return {}

func get_surface_type_at_location(location: Vector2) -> String:
	"""Get surface type at specific location"""
	for key in active_surfaces.keys():
		if key.ends_with(str(location)):
			return key.split("_")[0]
	return ""

func apply_surface_effects_to_actor(actor, location: Vector2):
	"""Apply surface effects to an actor at a location"""
	var surface_data = get_surface_at_location(location)
	if surface_data.is_empty():
		return
	
	var surface_type = get_surface_type_at_location(location)
	var effects_applied = []
	
	# Apply damage per turn effects
	if surface_data.has("damage_per_turn"):
		var damage = surface_data["damage_per_turn"]
		actor.take_damage(damage)
		effects_applied.append("damage: %d" % damage)
	
	# Apply healing per turn effects
	if surface_data.has("healing_per_turn"):
		var healing = surface_data["healing_per_turn"]
		actor.health_points = min(actor.max_health_points, actor.health_points + healing)
		effects_applied.append("healing: %d" % healing)
	
	# Apply movement penalties
	if surface_data.has("movement_penalty"):
		var penalty = surface_data["movement_penalty"]
		actor.speed = int(actor.speed * penalty)
		effects_applied.append("movement_penalty: %.1f" % penalty)
	
	# Apply stealth bonuses
	if surface_data.has("stealth_bonus"):
		var bonus = surface_data["stealth_bonus"]
		# This would integrate with stealth system when implemented
		effects_applied.append("stealth_bonus: %.1f" % bonus)
	
	# Apply magic amplification
	if surface_data.has("magic_amplification"):
		var amplification = surface_data["magic_amplification"]
		actor.magic_attack = int(actor.magic_attack * amplification)
		effects_applied.append("magic_amplification: %.1f" % amplification)
	
	# Apply skill bonuses
	if surface_data.has("skill_bonus"):
		var bonus = surface_data["skill_bonus"]
		# This would integrate with skill system when implemented
		effects_applied.append("skill_bonus: %.1f" % bonus)
	
	if effects_applied.size() > 0:
		print("SurfaceManager: Applied %s effects to %s: %s" % [surface_type, actor.character_name, ", ".join(effects_applied)])
		surface_effect_triggered.emit(surface_type, actor, ", ".join(effects_applied))

func get_elemental_bonus_for_surface(surface_type: String, element: String) -> float:
	"""Get elemental bonus for a surface type"""
	if not surface_effects.has(surface_type):
		return 1.0
	
	var surface_data = surface_effects[surface_type]
	if surface_data.has("elemental_bonus") and surface_data["elemental_bonus"].has(element):
		return surface_data["elemental_bonus"][element]
	
	return 1.0

func check_chain_reactions(surface_type: String, location: Vector2):
	"""Check for chain reactions when a surface is applied"""
	var reactions = []
	
	# Fire + Oil = Explosion
	if surface_type == "fire":
		var adjacent_surfaces = get_adjacent_surfaces(location)
		for adj_location in adjacent_surfaces:
			var adj_surface = get_surface_type_at_location(adj_location)
			if adj_surface == "oil":
				reactions.append("fire_oil_explosion")
				trigger_explosion(adj_location)
	
	# Water + Lightning = Electrified Water
	elif surface_type == "lightning":
		var adjacent_surfaces = get_adjacent_surfaces(location)
		for adj_location in adjacent_surfaces:
			var adj_surface = get_surface_type_at_location(adj_location)
			if adj_surface == "water":
				reactions.append("lightning_water_electrify")
				apply_surface("electrified_water", adj_location, 2)
	
	# Ice + Fire = Steam
	elif surface_type == "fire":
		var adjacent_surfaces = get_adjacent_surfaces(location)
		for adj_location in adjacent_surfaces:
			var adj_surface = get_surface_type_at_location(adj_location)
			if adj_surface == "ice":
				reactions.append("fire_ice_steam")
				remove_surface(adj_location)
				apply_surface("steam", adj_location, 2)
	
	if reactions.size() > 0:
		print("SurfaceManager: Chain reactions triggered: %s" % ", ".join(reactions))
		chain_reactions.append_array(reactions)

func get_adjacent_surfaces(location: Vector2) -> Array[Vector2]:
	"""Get adjacent surface locations"""
	var adjacent: Array[Vector2] = []
	var directions = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
	
	for direction in directions:
		var adj_location = location + direction
		if get_surface_type_at_location(adj_location) != "":
			adjacent.append(adj_location)
	
	return adjacent

func trigger_explosion(location: Vector2):
	"""Trigger an explosion at a location"""
	print("SurfaceManager: 💥 Explosion triggered at %s!" % str(location))
	
	# Remove the oil surface
	remove_surface(location)
	
	# Apply explosion damage to all actors in range
	var combat_manager = get_node_or_null("/root/CombatManager")
	if not combat_manager:
		# Try alternative paths
		combat_manager = get_node_or_null("/root/GameManager/CombatManager")
	if not combat_manager:
		combat_manager = get_node_or_null("/root/Main/CombatManager")
	
	if combat_manager and combat_manager.has_method("get_turn_order"):
		var all_actors = combat_manager.get_turn_order()
		for actor in all_actors:
			# Simple range check - in a real implementation, this would use actual positioning
			if actor.has_method("take_damage"):
				actor.take_damage(15)
				print("SurfaceManager: Explosion deals 15 damage to %s" % actor.character_name)
	else:
		print("SurfaceManager: CombatManager not found for explosion damage")

func update_surface_durations():
	"""Update surface durations and remove expired surfaces"""
	var expired_surfaces = []
	
	for surface_key in surface_durations.keys():
		surface_durations[surface_key] -= 1
		
		if surface_durations[surface_key] <= 0:
			expired_surfaces.append(surface_key)
	
	# Remove expired surfaces
	for surface_key in expired_surfaces:
		var location_str = surface_key.split("_", false, 1)[1]
		var location = Vector2.ZERO
		# Parse location string back to Vector2
		var coords = location_str.replace("(", "").replace(")", "").split(",")
		if coords.size() == 2:
			location = Vector2(int(coords[0]), int(coords[1]))
			remove_surface(location)

func get_surface_description(location: Vector2) -> String:
	"""Get rich description of surface at location"""
	var surface_type = get_surface_type_at_location(location)
	if surface_type == "":
		return ""
	
	var surface_data = get_surface_at_location(location)
	if surface_data.has("description"):
		return surface_data["description"]
	
	return "The ground is covered with %s" % surface_type

func get_all_active_surfaces() -> Dictionary:
	"""Get all active surfaces with their data"""
	return active_surfaces.duplicate()

func get_surface_count() -> int:
	"""Get total number of active surfaces"""
	return active_surfaces.size()

func clear_all_surfaces():
	"""Clear all active surfaces"""
	active_surfaces.clear()
	surface_durations.clear()
	surface_locations.clear()
	print("SurfaceManager: All surfaces cleared")

func get_surface_statistics() -> Dictionary:
	"""Get statistics about current surfaces"""
	var stats = {
		"total_surfaces": active_surfaces.size(),
		"surface_types": {},
		"chain_reactions": chain_reactions.size(),
		"interactions": surface_interactions.size()
	}
	
	# Count surface types
	for surface_key in active_surfaces.keys():
		var surface_type = surface_key.split("_")[0]
		if not stats["surface_types"].has(surface_type):
			stats["surface_types"][surface_type] = 0
		stats["surface_types"][surface_type] += 1
	
	return stats 
