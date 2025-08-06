extends Node
class_name CoverManager

# Cover Manager - Handles cover mechanics in combat
# Manages cover types, bonuses, and narrative descriptions

signal cover_applied(cover_type: String, location: Vector2, description: String)
signal cover_removed(cover_type: String, location: Vector2)
signal cover_effect_triggered(cover_type: String, target, effect: String)

# Cover types and their effects
var cover_effects = {
	"none": {
		"defense": 0,
		"magic_defense": 0,
		"accuracy_penalty": 0.0,
		"description": "No cover available",
		"narrative": "You stand exposed in the open"
	},
	"partial": {
		"defense": 2,
		"magic_defense": 1,
		"accuracy_penalty": 0.1,
		"description": "Partial cover from nearby objects",
		"narrative": "You take cover behind scattered debris"
	},
	"full": {
		"defense": 5,
		"magic_defense": 3,
		"accuracy_penalty": 0.3,
		"description": "Full cover from solid barriers",
		"narrative": "You're well-protected behind solid cover"
	},
	"magical": {
		"defense": 3,
		"magic_defense": 5,
		"accuracy_penalty": 0.2,
		"description": "Magical barrier protection",
		"narrative": "A shimmering magical barrier surrounds you"
	},
	"void": {
		"defense": 2,
		"void_resistance": 0.5,
		"accuracy_penalty": 0.1,
		"description": "Void energy distortion",
		"narrative": "Void energy distorts reality around you"
	},
	"ancient": {
		"defense": 4,
		"magic_defense": 4,
		"accuracy_penalty": 0.15,
		"description": "Ancient ward protection",
		"narrative": "Ancient wards pulse with protective energy"
	},
	"crystal": {
		"defense": 3,
		"magic_defense": 6,
		"accuracy_penalty": 0.1,
		"description": "Crystalline barrier",
		"narrative": "Crystalline structures refract incoming attacks"
	},
	"shadow": {
		"defense": 2,
		"magic_defense": 3,
		"stealth_bonus": 0.3,
		"accuracy_penalty": 0.05,
		"description": "Shadow veil protection",
		"narrative": "Shadows cloak your movements"
	}
}

# World-specific cover enhancements
var world_cover_enhancements = {
	"nokturn": {
		"shadow_amplification": 1.5,
		"description": "Shadows are stronger in Nokturn",
		"narrative": "The eternal darkness of Nokturn amplifies shadow cover"
	},
	"elysion": {
		"ancient_ward_boost": 1.3,
		"description": "Ancient magic enhances wards",
		"narrative": "Ancient Elysion magic strengthens your protective wards"
	},
	"sylithar": {
		"crystal_resonance": 1.4,
		"description": "Crystals resonate with light",
		"narrative": "Sylithar's crystalline nature enhances light-based cover"
	},
	"terra": {
		"natural_barrier": 1.2,
		"description": "Natural barriers are stronger",
		"narrative": "Terra's natural energy fortifies your cover"
	},
	"aethra": {
		"wind_barrier": 1.3,
		"description": "Wind currents provide protection",
		"narrative": "Aethra's wind currents create protective barriers"
	},
	"ombra": {
		"void_distortion": 1.6,
		"description": "Void energy distorts reality",
		"narrative": "Ombra's void energy creates reality-bending cover"
	},
	"krynn": {
		"dragon_essence": 1.5,
		"description": "Dragon essence empowers barriers",
		"narrative": "Krynn's dragon essence empowers your protective barriers"
	},
	"tauron": {
		"tech_barrier": 1.4,
		"description": "Technology enhances barriers",
		"narrative": "Tauron's advanced technology fortifies your cover"
	},
	"aelria": {
		"reality_bending": 1.7,
		"description": "Reality itself provides protection",
		"narrative": "Aelria's reality-bending nature creates impossible cover"
	}
}

# Active cover at each location
var active_cover: Dictionary = {}

# Cover duration tracking
var cover_durations: Dictionary = {}

func apply_cover_to_location(cover_type: String, location: Vector2, duration: int = -1, source_world: String = "") -> bool:
	"""Apply cover to a specific location"""
	if not cover_effects.has(cover_type):
		print("CoverManager: Invalid cover type: %s" % cover_type)
		return false
	
	var cover_key = str(location)
	var cover_data = cover_effects[cover_type].duplicate()
	
	# Apply world-specific enhancements
	if source_world != "" and world_cover_enhancements.has(source_world):
		var world_data = world_cover_enhancements[source_world]
		for key in world_data:
			if key != "description" and key != "narrative":
				if cover_data.has(key):
					cover_data[key] *= world_data[key]
				else:
					cover_data[key] = world_data[key]
		print("CoverManager: Applied %s world enhancement to %s cover" % [source_world, cover_type])
		
		# Apply world-specific bonuses to existing stats
		if world_data.has("ancient_ward_boost") and cover_data.has("magic_defense"):
			cover_data["magic_defense"] = int(cover_data["magic_defense"] * world_data["ancient_ward_boost"])
			print("CoverManager: Enhanced magic defense with %s boost: %d" % [source_world, cover_data["magic_defense"]])
	
	active_cover[cover_key] = cover_data
	cover_durations[cover_key] = duration
	
	print("CoverManager: Applied %s cover at %s (Duration: %d)" % [cover_type, str(location), duration])
	cover_applied.emit(cover_type, location, cover_data["description"])
	
	return true

func remove_cover_from_location(location: Vector2) -> bool:
	"""Remove cover from a specific location"""
	var cover_key = str(location)
	
	if not active_cover.has(cover_key):
		return false
	
	var cover_type = "unknown"
	for type in cover_effects:
		if cover_effects[type] == active_cover[cover_key]:
			cover_type = type
			break
	
	active_cover.erase(cover_key)
	cover_durations.erase(cover_key)
	
	print("CoverManager: Removed cover from %s" % str(location))
	cover_removed.emit(cover_type, location)
	
	return true

func get_cover_at_location(location: Vector2) -> Dictionary:
	"""Get cover data at a specific location"""
	var cover_key = str(location)
	
	if active_cover.has(cover_key):
		return active_cover[cover_key]
	
	return cover_effects["none"]

func apply_cover_effects_to_actor(actor, location: Vector2) -> Dictionary:
	"""Apply cover effects to an actor at a specific location"""
	var cover_data = get_cover_at_location(location)
	var effects_applied = {}
	
	if cover_data.has("defense") and cover_data["defense"] > 0:
		actor.defense += cover_data["defense"]
		effects_applied["defense"] = cover_data["defense"]
		print("CoverManager: Applied %d defense bonus to %s" % [cover_data["defense"], actor.character_name])
	
	if cover_data.has("magic_defense") and cover_data["magic_defense"] > 0:
		if actor.has_method("add_magic_defense"):
			actor.add_magic_defense(cover_data["magic_defense"])
		effects_applied["magic_defense"] = cover_data["magic_defense"]
		print("CoverManager: Applied %d magic defense bonus to %s" % [cover_data["magic_defense"], actor.character_name])
	
	if cover_data.has("void_resistance"):
		effects_applied["void_resistance"] = cover_data["void_resistance"]
		print("CoverManager: Applied void resistance to %s" % actor.character_name)
	
	if cover_data.has("stealth_bonus"):
		effects_applied["stealth_bonus"] = cover_data["stealth_bonus"]
		print("CoverManager: Applied stealth bonus to %s" % actor.character_name)
	
	# Emit effect triggered signal
	if effects_applied.size() > 0:
		cover_effect_triggered.emit("cover", actor, str(effects_applied))
	
	return effects_applied

func calculate_cover_accuracy_penalty(location: Vector2) -> float:
	"""Calculate accuracy penalty for cover at location"""
	var cover_data = get_cover_at_location(location)
	
	if cover_data.has("accuracy_penalty"):
		return cover_data["accuracy_penalty"]
	
	return 0.0

func get_cover_narrative(location: Vector2) -> String:
	"""Get narrative description of cover at location"""
	var cover_data = get_cover_at_location(location)
	
	if cover_data.has("narrative"):
		return cover_data["narrative"]
	
	return "No cover available"

func update_cover_durations():
	"""Update cover durations and remove expired cover"""
	var locations_to_remove = []
	
	for location_key in cover_durations:
		if cover_durations[location_key] > 0:
			cover_durations[location_key] -= 1
			if cover_durations[location_key] <= 0:
				locations_to_remove.append(location_key)
	
	for location_key in locations_to_remove:
		var location = Vector2.ZERO
		# Convert string back to Vector2 (proper parsing)
		var coords = location_key.replace("(", "").replace(")", "").split(",")
		if coords.size() == 2:
			location = Vector2(float(coords[0]), float(coords[1]))
		
		remove_cover_from_location(location)
		print("CoverManager: Cover expired at %s" % str(location))

func get_all_active_cover() -> Dictionary:
	"""Get all active cover locations and their data"""
	return active_cover.duplicate()

func clear_all_cover():
	"""Clear all active cover"""
	active_cover.clear()
	cover_durations.clear()
	print("CoverManager: Cleared all cover")

func get_cover_statistics() -> Dictionary:
	"""Get cover system statistics"""
	return {
		"active_cover_count": active_cover.size(),
		"cover_types": active_cover.keys(),
		"total_locations": active_cover.size()
	} 