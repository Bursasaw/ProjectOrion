extends Control

# CraftingInterface - Comprehensive crafting UI system
# Provides intuitive interface for all crafting activities
# Version 0.13.0

signal crafting_started(recipe_id: String, station_id: String)
signal crafting_completed(recipe_id: String, result_item: String, quality: float)
signal station_selected(station_id: String)
signal material_gathered(material_id: String, location: String)

# UI References
@onready var station_list: VBoxContainer = $MainPanel/LeftPanel/StationList
@onready var recipe_list: VBoxContainer = $MainPanel/RightPanel/RecipeList
@onready var material_panel: Panel = $MainPanel/RightPanel/MaterialPanel
@onready var quality_display: Label = $MainPanel/RightPanel/QualityDisplay
@onready var craft_button: Button = $MainPanel/RightPanel/CraftButton
@onready var progress_bar: ProgressBar = $MainPanel/RightPanel/ProgressBar
@onready var status_label: Label = $MainPanel/RightPanel/StatusLabel

# Crafting system reference
var crafting_system: Node
var skill_system: Node
var inventory_manager: Node

# Current state
var selected_station: String = ""
var selected_recipe: String = ""
var available_recipes: Array[Dictionary] = []
var crafting_in_progress: bool = false

# UI elements
var station_buttons: Dictionary = {}
var recipe_buttons: Dictionary = {}
var material_labels: Dictionary = {}

func _ready():
	"""Initialize the crafting interface"""
	print("⚒️ CraftingInterface: Initializing crafting UI...")
	
	# Get system references
	crafting_system = get_node_or_null("/root/CraftingSystem")
	skill_system = get_node_or_null("/root/SkillSystem")
	
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		inventory_manager = game_manager.inventory_manager
	
	# Connect signals
	if crafting_system:
		crafting_system.recipe_crafted.connect(_on_recipe_crafted)
		crafting_system.crafting_failed.connect(_on_crafting_failed)
		crafting_system.crafting_station_unlocked.connect(_on_station_unlocked)
		crafting_system.crafting_skill_leveled_up.connect(_on_skill_leveled_up)
	
	# Initialize UI
	setup_station_list()
	setup_recipe_list()
	setup_material_panel()
	
	# Hide progress elements initially
	progress_bar.visible = false
	status_label.visible = false
	
	print("✅ CraftingInterface: Crafting UI initialized")

func setup_station_list():
	"""Set up the station selection list"""
	if not crafting_system:
		return
	
	# Clear existing buttons
	for child in station_list.get_children():
		child.queue_free()
	station_buttons.clear()
	
	# Create station buttons
	for station_id in crafting_system.unlocked_stations:
		var station_data = crafting_system.crafting_stations[station_id]
		create_station_button(station_id, station_data)

func create_station_button(station_id: String, station_data: Dictionary):
	"""Create a button for a crafting station"""
	var button = Button.new()
	button.text = station_data.name
	button.custom_minimum_size = Vector2(200, 40)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.YELLOW)
	
	# Add tooltip
	var tooltip = station_data.description + "\n"
	tooltip += "Discipline: " + station_data.discipline + "\n"
	tooltip += "Quality Bonus: +" + str(station_data.quality_bonus * 100) + "%"
	button.tooltip_text = tooltip
	
	# Connect signal
	button.pressed.connect(_on_station_selected.bind(station_id))
	
	station_list.add_child(button)
	station_buttons[station_id] = button

func setup_recipe_list():
	"""Set up the recipe selection list"""
	# Clear existing buttons
	for child in recipe_list.get_children():
		child.queue_free()
	recipe_buttons.clear()
	
	# Will be populated when station is selected
	var placeholder = Label.new()
	placeholder.text = "Select a crafting station to view recipes"
	placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	placeholder.custom_minimum_size = Vector2(300, 200)
	recipe_list.add_child(placeholder)

func setup_material_panel():
	"""Set up the material requirements panel"""
	# Clear existing labels
	for child in material_panel.get_children():
		child.queue_free()
	material_labels.clear()
	
	# Create header
	var header = Label.new()
	header.text = "Material Requirements"
	header.add_theme_font_size_override("font_size", 16)
	header.add_theme_color_override("font_color", Color.YELLOW)
	material_panel.add_child(header)

func _on_station_selected(station_id: String):
	"""Handle station selection"""
	selected_station = station_id
	
	# Update button colors
	for id in station_buttons:
		var button = station_buttons[id]
		if id == station_id:
			button.add_theme_color_override("font_color", Color.YELLOW)
		else:
			button.add_theme_color_override("font_color", Color.WHITE)
	
	# Load recipes for this station
	load_station_recipes(station_id)
	
	# Emit signal
	station_selected.emit(station_id)
	
	print("⚒️ CraftingInterface: Selected station: ", station_id)

func load_station_recipes(station_id: String):
	"""Load recipes available at the selected station"""
	if not crafting_system:
		return
	
	# Clear existing recipe buttons
	for child in recipe_list.get_children():
		child.queue_free()
	recipe_buttons.clear()
	
	# Get available recipes
	available_recipes = crafting_system.get_available_recipes(station_id)
	
	if available_recipes.size() == 0:
		var no_recipes = Label.new()
		no_recipes.text = "No recipes available at this station"
		no_recipes.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		no_recipes.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		no_recipes.custom_minimum_size = Vector2(300, 200)
		recipe_list.add_child(no_recipes)
		return
	
	# Create recipe buttons
	for recipe in available_recipes:
		create_recipe_button(recipe)

func create_recipe_button(recipe: Dictionary):
	"""Create a button for a crafting recipe"""
	var button = Button.new()
	button.text = recipe.name
	button.custom_minimum_size = Vector2(280, 50)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.CYAN)
	
	# Add tooltip
	var tooltip = recipe.description + "\n"
	tooltip += "Discipline: " + recipe.discipline + "\n"
	tooltip += "Experience: " + str(recipe.experience) + "\n"
	tooltip += "Requirements: "
	for material in recipe.requirements:
		tooltip += material + " x" + str(recipe.requirements[material]) + ", "
	tooltip = tooltip.trim_suffix(", ")
	button.tooltip_text = tooltip
	
	# Connect signal
	button.pressed.connect(_on_recipe_selected.bind(recipe.id))
	
	recipe_list.add_child(button)
	recipe_buttons[recipe.id] = button

func _on_recipe_selected(recipe_id: String):
	"""Handle recipe selection"""
	selected_recipe = recipe_id
	
	# Update button colors
	for id in recipe_buttons:
		var button = recipe_buttons[id]
		if id == recipe_id:
			button.add_theme_color_override("font_color", Color.CYAN)
		else:
			button.add_theme_color_override("font_color", Color.WHITE)
	
	# Update material requirements
	update_material_requirements(recipe_id)
	
	# Update quality display
	update_quality_display(recipe_id)
	
	# Update craft button
	update_craft_button(recipe_id)
	
	print("⚒️ CraftingInterface: Selected recipe: ", recipe_id)

func update_material_requirements(recipe_id: String):
	"""Update the material requirements display"""
	# Clear existing labels
	for child in material_panel.get_children():
		if child.get_name() != "Header":
			child.queue_free()
	material_labels.clear()
	
	# Find the recipe
	var recipe = null
	for r in available_recipes:
		if r.id == recipe_id:
			recipe = r
			break
	
	if not recipe:
		return
	
	# Create material requirement labels
	for material_id in recipe.requirements:
		var required_amount = recipe.requirements[material_id]
		var available_amount = get_material_count(material_id)
		
		var label = Label.new()
		label.text = material_id + ": " + str(available_amount) + "/" + str(required_amount)
		
		# Color code based on availability
		if available_amount >= required_amount:
			label.add_theme_color_override("font_color", Color.GREEN)
		else:
			label.add_theme_color_override("font_color", Color.RED)
		
		material_panel.add_child(label)
		material_labels[material_id] = label

func update_quality_display(recipe_id: String):
	"""Update the quality prediction display"""
	if not crafting_system or not skill_system:
		return
	
	# Find the recipe
	var recipe = null
	for r in available_recipes:
		if r.id == recipe_id:
			recipe = r
			break
	
	if not recipe:
		return
	
	# Calculate predicted quality
	var station = crafting_system.crafting_stations[selected_station]
	var predicted_quality = crafting_system.calculate_crafting_quality(recipe, station)
	
	# Determine quality tier
	var quality_tier = "Poor"
	var tier_color = Color.RED
	
	if predicted_quality >= 4.0:
		quality_tier = "Mythic"
		tier_color = Color.PURPLE
	elif predicted_quality >= 3.0:
		quality_tier = "Legendary"
		tier_color = Color.ORANGE
	elif predicted_quality >= 2.0:
		quality_tier = "Epic"
		tier_color = Color.MAGENTA
	elif predicted_quality >= 1.5:
		quality_tier = "Rare"
		tier_color = Color.BLUE
	elif predicted_quality >= 1.25:
		quality_tier = "Uncommon"
		tier_color = Color.GREEN
	elif predicted_quality >= 1.0:
		quality_tier = "Common"
		tier_color = Color.WHITE
	
	quality_display.text = "Predicted Quality: " + quality_tier + " (" + str(predicted_quality) + ")"
	quality_display.add_theme_color_override("font_color", tier_color)

func update_craft_button(recipe_id: String):
	"""Update the craft button state"""
	if not can_craft_recipe(recipe_id):
		craft_button.disabled = true
		craft_button.text = "Cannot Craft"
		craft_button.add_theme_color_override("font_color", Color.RED)
	else:
		craft_button.disabled = false
		craft_button.text = "Craft Item"
		craft_button.add_theme_color_override("font_color", Color.WHITE)

func can_craft_recipe(recipe_id: String) -> bool:
	"""Check if the recipe can be crafted"""
	if not crafting_system or not inventory_manager:
		return false
	
	# Find the recipe
	var recipe = null
	for r in available_recipes:
		if r.id == recipe_id:
			recipe = r
			break
	
	if not recipe:
		return false
	
	# Check material requirements
	for material_id in recipe.requirements:
		var required_amount = recipe.requirements[material_id]
		var available_amount = get_material_count(material_id)
		
		if available_amount < required_amount:
			return false
	
	return true

func get_material_count(material_id: String) -> int:
	"""Get the count of a material in inventory"""
	if not inventory_manager:
		return 0
	
	return inventory_manager.get_item_count(material_id)

func _on_craft_button_pressed():
	"""Handle craft button press"""
	if not selected_recipe or not selected_station:
		return
	
	if not can_craft_recipe(selected_recipe):
		return
	
	# Start crafting
	start_crafting(selected_recipe, selected_station)

func start_crafting(recipe_id: String, station_id: String):
	"""Start the crafting process"""
	if not crafting_system:
		return
	
	# Disable UI during crafting
	crafting_in_progress = true
	craft_button.disabled = true
	craft_button.text = "Crafting..."
	
	# Show progress
	progress_bar.visible = true
	status_label.visible = true
	status_label.text = "Crafting " + selected_recipe + "..."
	
	# Simulate crafting time
	var crafting_time = 2.0  # 2 seconds
	var elapsed_time = 0.0
	
	# Start crafting timer
	var timer = get_tree().create_timer(crafting_time)
	timer.timeout.connect(_on_crafting_complete)
	
	# Update progress bar
	var progress_timer = get_tree().create_timer(0.1)
	progress_timer.timeout.connect(_update_progress_bar)
	
	# Emit signal
	crafting_started.emit(recipe_id, station_id)
	
	print("⚒️ CraftingInterface: Started crafting ", recipe_id)

func _update_progress_bar():
	"""Update the crafting progress bar"""
	if not crafting_in_progress:
		return
	
	progress_bar.value += 5
	if progress_bar.value >= 100:
		return
	
	# Continue updating
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(_update_progress_bar)

func _on_crafting_complete():
	"""Handle crafting completion"""
	if not crafting_system:
		return
	
	# Perform the actual crafting
	var result = crafting_system.craft_item(selected_recipe, selected_station)
	
	# Reset UI
	crafting_in_progress = false
	craft_button.disabled = false
	craft_button.text = "Craft Item"
	progress_bar.visible = false
	status_label.visible = false
	
	# Update material requirements
	update_material_requirements(selected_recipe)
	
	# Show result
	if result.success:
		status_label.text = "Successfully crafted " + result.item_id + " (Quality: " + str(result.quality) + ")"
		status_label.add_theme_color_override("font_color", Color.GREEN)
		status_label.visible = true
		
		# Hide after 3 seconds
		var timer = get_tree().create_timer(3.0)
		timer.timeout.connect(func(): status_label.visible = false)
	else:
		status_label.text = "Crafting failed: " + result.message
		status_label.add_theme_color_override("font_color", Color.RED)
		status_label.visible = true
		
		# Hide after 3 seconds
		var timer = get_tree().create_timer(3.0)
		timer.timeout.connect(func(): status_label.visible = false)

func _on_recipe_crafted(recipe_id: String, result_item: String, quality: float):
	"""Handle recipe crafting completion"""
	crafting_completed.emit(recipe_id, result_item, quality)
	
	# Update UI if this was our recipe
	if recipe_id == selected_recipe:
		update_material_requirements(recipe_id)
		update_quality_display(recipe_id)
		update_craft_button(recipe_id)

func _on_crafting_failed(recipe_id: String, reason: String):
	"""Handle crafting failure"""
	print("❌ CraftingInterface: Crafting failed for ", recipe_id, ": ", reason)
	
	# Show error message
	status_label.text = "Crafting failed: " + reason
	status_label.add_theme_color_override("font_color", Color.RED)
	status_label.visible = true
	
	# Hide after 3 seconds
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(func(): status_label.visible = false)

func _on_station_unlocked(station_id: String, station_data: Dictionary):
	"""Handle new station unlocking"""
	print("🔓 CraftingInterface: New station unlocked: ", station_data.name)
	
	# Add new station button
	create_station_button(station_id, station_data)

func _on_skill_leveled_up(skill_type: String, new_level: int, experience: int):
	"""Handle crafting skill level up"""
	print("🎉 CraftingInterface: ", skill_type, " leveled up to ", new_level)
	
	# Refresh recipe list if we have a station selected
	if selected_station:
		load_station_recipes(selected_station)

func refresh_interface():
	"""Refresh the entire interface"""
	setup_station_list()
	if selected_station:
		load_station_recipes(selected_station)
		update_material_requirements(selected_recipe)
		update_quality_display(selected_recipe)
		update_craft_button(selected_recipe)

func get_crafting_summary() -> Dictionary:
	"""Get a summary of current crafting state"""
	return {
		"selected_station": selected_station,
		"selected_recipe": selected_recipe,
		"available_recipes": available_recipes.size(),
		"can_craft": can_craft_recipe(selected_recipe) if selected_recipe else false
	} 