extends Node
class_name WorldManager

# World Manager - Handles world transitions and location management
# Manages the nine worlds, their connections, and world-specific data

signal world_changed(world_name: String)
signal location_changed(location_name: String)
signal world_discovered(world_name: String)

# World data
var worlds: Dictionary = {}
var current_world: String = "Terra"
var current_location: String = "Arcanum Sanctum"

# World connections (The Veil)
var world_connections: Dictionary = {}

# Player progress
var discovered_worlds: Array[String] = []
var visited_locations: Array[String] = []

# World-specific data
var world_effects: Dictionary = {}
var weather_conditions: Dictionary = {}

func _ready():
	load_world_data()

func load_world_data():
	"""Load world data from external JSON file"""
	var file = FileAccess.open("res://data/worlds/worlds.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var data = json.data
			worlds = data.get("worlds", {})
			world_connections = data.get("connections", {})
			print("World data loaded successfully from JSON")
		else:
			print("Failed to parse world data JSON")
			# Fallback to hardcoded data if JSON fails
			initialize_fallback_worlds()
	else:
		print("Failed to load world data file")
		# Fallback to hardcoded data if file doesn't exist
		initialize_fallback_worlds()

func initialize_fallback_worlds():
	"""Initialize fallback world data if JSON loading fails"""
	print("Using fallback world data")
	worlds = {
		"Terra": {
			"name": "Terra",
			"description": "The Primal Heart - A world of ancient forests and mystical energies",
			"theme": "nature",
			"difficulty": 1,
			"magic_level": "high",
			"locations": ["Arcanum Sanctum", "Ancient Grove", "Crystal Caverns", "Mystic Springs"],
			"enemies": ["Forest Sprite", "Crystal Guardian", "Ancient Treant"],
			"items": ["Nature Essence", "Crystal Shard", "Healing Herb"],
			"weather": "temperate",
			"effects": ["enhanced_magic", "nature_affinity"]
		}
	}
	world_connections = {
		"Terra": []
	}

func change_world(world_name: String) -> bool:
	"""Change to a different world"""
	if not worlds.has(world_name):
		print("World not found: %s" % world_name)
		return false
	
	# Check if player can access this world
	if not can_access_world(world_name):
		print("Cannot access world: %s" % world_name)
		return false
	
	current_world = world_name
	
	# Set default location for new world
	current_location = worlds[world_name]["locations"][0]
	
	# Mark world as discovered
	if not discovered_worlds.has(world_name):
		discovered_worlds.append(world_name)
		world_discovered.emit(world_name)
	
	# Emit signals
	world_changed.emit(world_name)
	location_changed.emit(current_location)
	
	print("Changed to world: %s" % world_name)
	return true

func can_access_world(world_name: String) -> bool:
	"""Check if player can access a world"""
	# Terra is always accessible
	if world_name == "Terra":
		return true
	
	# Check if world is discovered
	if discovered_worlds.has(world_name):
		return true
	
	# Check if connected to current world
	if world_connections.has(current_world):
		return world_connections[current_world].has(world_name)
	
	return false

func change_location(location_name: String) -> bool:
	"""Change to a different location in the current world"""
	if not worlds.has(current_world):
		return false
	
	var world_data = worlds[current_world]
	var display_name = get_location_display_name(location_name)
	
	if not world_data["locations"].has(display_name):
		print("Location not found: %s in world %s" % [location_name, current_world])
		return false
	
	current_location = display_name
	
	# Mark location as visited
	if not visited_locations.has(display_name):
		visited_locations.append(display_name)
	
	# Emit signal
	location_changed.emit(display_name)
	
	print("Changed to location: %s" % display_name)
	return true

func get_location_display_name(location_id: String) -> String:
	"""Convert location ID to display name"""
	# Load location data to get the mapping
	var file = FileAccess.open("res://data/worlds/locations.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		if parse_result == OK:
			var location_data = json.data.get("locations", {})
			if location_data.has(location_id):
				return location_data[location_id].get("name", location_id)
		file.close()
	
	# If no mapping found, return the original ID
	return location_id

func get_current_world() -> String:
	"""Get the current world name"""
	return current_world

func get_current_location() -> String:
	"""Get the current location name"""
	return current_location

func get_world_data(world_name: String) -> Dictionary:
	"""Get data for a specific world"""
	return worlds.get(world_name, {})

func get_current_world_data() -> Dictionary:
	"""Get data for the current world"""
	return get_world_data(current_world)

func get_accessible_worlds() -> Array[String]:
	"""Get list of worlds the player can currently access"""
	var accessible = ["Terra"]  # Always accessible
	
	for world_name in discovered_worlds:
		if not accessible.has(world_name):
			accessible.append(world_name)
	
	# Add connected worlds
	if world_connections.has(current_world):
		for connected_world in world_connections[current_world]:
			if not accessible.has(connected_world):
				accessible.append(connected_world)
	
	return accessible

func get_world_locations(world_name: String) -> Array[String]:
	"""Get all locations in a specific world"""
	var world_data = get_world_data(world_name)
	return world_data.get("locations", [])

func get_current_world_locations() -> Array[String]:
	"""Get all locations in the current world"""
	return get_world_locations(current_world)

func get_world_enemies(world_name: String) -> Array[String]:
	"""Get enemies found in a specific world"""
	var world_data = get_world_data(world_name)
	return world_data.get("enemies", [])

func get_world_items(world_name: String) -> Array[String]:
	"""Get items found in a specific world"""
	var world_data = get_world_data(world_name)
	return world_data.get("items", [])

func get_world_effects(world_name: String) -> Array[String]:
	"""Get effects active in a specific world"""
	var world_data = get_world_data(world_name)
	return world_data.get("effects", [])

func get_current_world_effects() -> Array[String]:
	"""Get effects active in the current world"""
	return get_world_effects(current_world)

func get_world_difficulty(world_name: String) -> int:
	"""Get the difficulty level of a world"""
	var world_data = get_world_data(world_name)
	return world_data.get("difficulty", 1)

func get_world_magic_level(world_name: String) -> String:
	"""Get the magic level of a world"""
	var world_data = get_world_data(world_name)
	return world_data.get("magic_level", "normal")

func get_connected_worlds(world_name: String) -> Array[String]:
	"""Get worlds connected to a specific world"""
	var connections = world_connections.get(world_name, [])
	# Ensure we return a properly typed Array[String]
	var typed_connections: Array[String] = []
	for connection in connections:
		if connection is String:
			typed_connections.append(connection)
	return typed_connections

func get_current_connected_worlds() -> Array[String]:
	"""Get worlds connected to the current world"""
	return get_connected_worlds(current_world)

func has_visited_location(location_name: String) -> bool:
	"""Check if player has visited a specific location"""
	return visited_locations.has(location_name)

func has_discovered_world(world_name: String) -> bool:
	"""Check if player has discovered a specific world"""
	return discovered_worlds.has(world_name)

func get_discovered_worlds() -> Array[String]:
	"""Get all discovered worlds"""
	return discovered_worlds.duplicate()

func get_visited_locations() -> Array[String]:
	"""Get all visited locations"""
	return visited_locations.duplicate()

func set_discovered_worlds(worlds_array: Array):
	"""Set discovered worlds from save data"""
	discovered_worlds.clear()
	for world in worlds_array:
		if world is String:
			discovered_worlds.append(world)

func set_visited_locations(locations_array: Array):
	"""Set visited locations from save data"""
	visited_locations.clear()
	for location in locations_array:
		if location is String:
			visited_locations.append(location)

func get_world_progress() -> Dictionary:
	"""Get progress information for all worlds"""
	var progress = {}
	
	for world_name in worlds:
		var world_data = worlds[world_name]
		var locations = world_data["locations"]
		var visited_count = 0
		
		for location in locations:
			if has_visited_location(location):
				visited_count += 1
		
		progress[world_name] = {
			"discovered": has_discovered_world(world_name),
			"locations_total": locations.size(),
			"locations_visited": visited_count,
			"completion_percentage": float(visited_count) / float(locations.size()) * 100.0
		}
	
	return progress 
