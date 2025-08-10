extends Panel

# World Map Panel - Handles world map UI and travel functionality
# Shows available worlds and locations, allows travel between them

signal world_travel_requested(world_name: String, location_name: String)
signal world_map_closed

@onready var world_tabs = $MapContainer/WorldTabs
@onready var travel_button = $MapContainer/ButtonContainer/TravelButton
@onready var close_button = $MapContainer/ButtonContainer/CloseButton

var game_manager: Node
var current_world: String = "Terra"
var current_location: String = "Arcanum Sanctum"
var available_locations: Dictionary = {}

func _ready():
	# Connect button signals
	travel_button.pressed.connect(_on_travel_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	
	# Get references
	game_manager = get_node("/root/GameManager")
	
	# Initialize available locations
	initialize_available_locations()
	
	# Initially hide the panel
	hide()

func initialize_available_locations():
	"""Initialize the available locations for each world"""
	available_locations = {
		"Terra": {
			"Arcanum Sanctum": {"status": "current", "unlocked": true},
			"Crystal Spire": {"status": "available", "unlocked": true},
			"Nokturn Market": {"status": "locked", "unlocked": false},
			"Void Rift": {"status": "locked", "unlocked": false}
		},
		"Archeum": {
			"Ancient Library": {"status": "locked", "unlocked": false},
			"Mystic Tower": {"status": "locked", "unlocked": false},
			"Scholar's Guild": {"status": "locked", "unlocked": false},
			"Forbidden Archive": {"status": "locked", "unlocked": false}
		},
		"Nexus": {
			"Central Hub": {"status": "locked", "unlocked": false},
			"Trade District": {"status": "locked", "unlocked": false},
			"Residential Quarter": {"status": "locked", "unlocked": false},
			"Government Center": {"status": "locked", "unlocked": false}
		},
		"Void": {
			"Void Entrance": {"status": "locked", "unlocked": false},
			"Void Depths": {"status": "locked", "unlocked": false},
			"Void Chamber": {"status": "locked", "unlocked": false},
			"Void Core": {"status": "locked", "unlocked": false}
		}
	}

func update_current_location():
	"""Update the current location based on game state"""
	if game_manager:
		current_world = game_manager.get_current_world()
		current_location = game_manager.get_current_location()
		
		# Update status in available_locations
		for world in available_locations:
			for location in available_locations[world]:
				if world == current_world and location == current_location:
					available_locations[world][location]["status"] = "current"
				elif available_locations[world][location]["status"] == "current":
					available_locations[world][location]["status"] = "available"

func get_location_status(world_name: String, location_name: String) -> String:
	"""Get the status of a specific location"""
	if available_locations.has(world_name) and available_locations[world_name].has(location_name):
		return available_locations[world_name][location_name]["status"]
	return "locked"

func is_location_unlocked(world_name: String, location_name: String) -> bool:
	"""Check if a location is unlocked"""
	if available_locations.has(world_name) and available_locations[world_name].has(location_name):
		return available_locations[world_name][location_name]["unlocked"]
	return false

func unlock_location(world_name: String, location_name: String):
	"""Unlock a location"""
	if available_locations.has(world_name) and available_locations[world_name].has(location_name):
		available_locations[world_name][location_name]["unlocked"] = true
		available_locations[world_name][location_name]["status"] = "available"

func unlock_world(world_name: String):
	"""Unlock all locations in a world"""
	if available_locations.has(world_name):
		for location in available_locations[world_name]:
			available_locations[world_name][location]["unlocked"] = true
			if available_locations[world_name][location]["status"] != "current":
				available_locations[world_name][location]["status"] = "available"

func _on_travel_button_pressed():
	"""Handle travel button press"""
	var selected_world = world_tabs.get_tab_title(world_tabs.current_tab)
	var selected_location = get_selected_location(selected_world)
	
	if selected_location and is_location_unlocked(selected_world, selected_location):
		world_travel_requested.emit(selected_world, selected_location)
		print("Travel requested to: %s - %s" % [selected_world, selected_location])
	else:
		print("Location is locked or not available")

func get_selected_location(world_name: String) -> String:
	"""Get the currently selected location for a world"""
	# For now, return the first available location
	if available_locations.has(world_name):
		for location in available_locations[world_name]:
			if available_locations[world_name][location]["unlocked"]:
				return location
	return ""

func _on_close_button_pressed():
	"""Handle close button press"""
	hide()
	world_map_closed.emit()

func show_world_map():
	"""Show the world map panel"""
	update_current_location()
	show()

func hide_world_map():
	"""Hide the world map panel"""
	hide()

func set_current_location(world: String, location: String):
	"""Set the current location"""
	current_world = world
	current_location = location
	update_current_location() 