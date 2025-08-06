extends Control
class_name InventoryInterface

# Advanced Inventory Interface
# Features drag-and-drop, item details, equipment slots, and filtering

signal item_selected(item: Item)
signal item_equipped(item: Item, slot: String)
signal item_unequipped(item: Item, slot: String)
signal item_used(item: Item)
signal item_dropped(item: Item, position: Vector2)

# UI References
@onready var inventory_grid: GridContainer = $InventoryLayout/InventoryGrid
@onready var equipment_panel: Panel = $InventoryLayout/EquipmentPanel
@onready var item_details_panel: Panel = $InventoryLayout/ItemDetailsPanel
@onready var item_details_label: Label = $InventoryLayout/ItemDetailsPanel/ItemDetailsLabel
@onready var filter_buttons_container: HBoxContainer = $InventoryLayout/FilterButtonsContainer
@onready var search_box: LineEdit = $InventoryLayout/SearchBox
@onready var sort_dropdown: OptionButton = $InventoryLayout/SortDropdown
@onready var weight_label: Label = $InventoryLayout/WeightLabel
@onready var gold_label: Label = $InventoryLayout/GoldLabel

# Equipment Slots
var equipment_slots: Dictionary = {}
var equipment_buttons: Dictionary = {}

# Inventory State
var inventory_items: Array[Item] = []
var filtered_items: Array[Item] = []
var selected_item: Item = null
var dragged_item: Item = null
var drag_preview: Control = null

# UI Theme
var ui_theme: UITheme = null

# Filter and Sort
var current_filter: String = "all"
var current_sort: String = "name"
var search_text: String = ""

func _ready():
	"""Initialize the inventory interface"""
	print("InventoryInterface: Initialized")
	
	# Get UI theme
	ui_theme = get_node_or_null("/root/UITheme")
	if not ui_theme:
		ui_theme = UITheme.new()
		add_child(ui_theme)
	
	# Apply theme
	apply_theme()
	
	# Setup equipment slots
	setup_equipment_slots()
	
	# Setup filter buttons
	setup_filter_buttons()
	
	# Setup sort dropdown
	setup_sort_dropdown()
	
	# Connect signals
	search_box.text_changed.connect(_on_search_text_changed)
	sort_dropdown.item_selected.connect(_on_sort_changed)
	
	# Connect to inventory manager
	var inventory_manager = get_node_or_null("/root/InventoryManager")
	if inventory_manager:
		inventory_manager.inventory_updated.connect(_on_inventory_updated)
		inventory_manager.item_equipped.connect(_on_item_equipped)
		inventory_manager.item_unequipped.connect(_on_item_unequipped)
	
	# Initially hide details panel
	item_details_panel.visible = false

func apply_theme():
	"""Apply the current theme to all UI elements"""
	if not ui_theme:
		return
	
	# Apply panel styles
	var panels = [equipment_panel, item_details_panel]
	for panel in panels:
		ui_theme.apply_theme_to_control(panel)
	
	# Apply input styles
	ui_theme.apply_theme_to_control(search_box)
	ui_theme.apply_theme_to_control(sort_dropdown)
	
	# Apply text colors
	var labels = [item_details_label, weight_label, gold_label]
	for label in labels:
		if label:
			label.add_theme_color_override("font_color", ui_theme.get_color("text_primary"))
			label.add_theme_font_size_override("font_size", ui_theme.get_font_size("medium"))

func setup_equipment_slots():
	"""Setup equipment slot buttons"""
	var slot_configs = {
		"weapon": {"name": "Weapon", "position": Vector2(50, 50)},
		"shield": {"name": "Shield", "position": Vector2(150, 50)},
		"helmet": {"name": "Helmet", "position": Vector2(100, 100)},
		"armor": {"name": "Armor", "position": Vector2(100, 150)},
		"gloves": {"name": "Gloves", "position": Vector2(50, 200)},
		"boots": {"name": "Boots", "position": Vector2(150, 200)},
		"accessory1": {"name": "Accessory 1", "position": Vector2(50, 250)},
		"accessory2": {"name": "Accessory 2", "position": Vector2(150, 250)}
	}
	
	for slot_id in slot_configs:
		var config = slot_configs[slot_id]
		var button = Button.new()
		button.text = config["name"]
		button.custom_minimum_size = Vector2(80, 40)
		button.position = config["position"]
		
		# Apply theme
		if ui_theme:
			ui_theme.apply_theme_to_control(button)
		
		# Connect signal
		button.pressed.connect(_on_equipment_slot_pressed.bind(slot_id))
		
		# Add to equipment panel
		equipment_panel.add_child(button)
		equipment_buttons[slot_id] = button
		equipment_slots[slot_id] = null

func setup_filter_buttons():
	"""Setup filter buttons"""
	var filters = [
		{"name": "All", "filter": "all"},
		{"name": "Weapons", "filter": "weapon"},
		{"name": "Armor", "filter": "armor"},
		{"name": "Consumables", "filter": "consumable"},
		{"name": "Materials", "filter": "material"},
		{"name": "Quest Items", "filter": "quest"}
	]
	
	for filter_config in filters:
		var button = Button.new()
		button.text = filter_config["name"]
		button.custom_minimum_size = Vector2(100, 30)
		
		# Apply theme
		if ui_theme:
			ui_theme.apply_theme_to_control(button)
		
		# Connect signal
		button.pressed.connect(_on_filter_button_pressed.bind(filter_config["filter"]))
		
		# Add to container
		filter_buttons_container.add_child(button)

func setup_sort_dropdown():
	"""Setup sort dropdown"""
	sort_dropdown.add_item("Name", 0)
	sort_dropdown.add_item("Type", 1)
	sort_dropdown.add_item("Rarity", 2)
	sort_dropdown.add_item("Value", 3)
	sort_dropdown.add_item("Weight", 4)
	sort_dropdown.select(0)

func _on_inventory_updated():
	"""Handle inventory update"""
	refresh_inventory_display()

func refresh_inventory_display():
	"""Refresh the inventory display"""
	# Get inventory items
	var inventory_manager = get_node_or_null("/root/InventoryManager")
	if inventory_manager:
		inventory_items = inventory_manager.get_all_items()
	
	# Apply filters and sorting
	apply_filters_and_sorting()
	
	# Update grid
	update_inventory_grid()
	
	# Update weight and gold
	update_weight_and_gold()

func apply_filters_and_sorting():
	"""Apply current filters and sorting"""
	filtered_items = inventory_items.duplicate()
	
	# Apply filter
	if current_filter != "all":
		filtered_items = filtered_items.filter(func(item): return item.item_type == current_filter)
	
	# Apply search
	if search_text != "":
		filtered_items = filtered_items.filter(func(item): return search_text.to_lower() in item.name.to_lower())
	
	# Apply sorting
	match current_sort:
		"name":
			filtered_items.sort_custom(func(a, b): return a.name < b.name)
		"type":
			filtered_items.sort_custom(func(a, b): return a.item_type < b.item_type)
		"rarity":
			filtered_items.sort_custom(func(a, b): return a.rarity > b.rarity)
		"value":
			filtered_items.sort_custom(func(a, b): return a.value > b.value)
		"weight":
			filtered_items.sort_custom(func(a, b): return a.weight < b.weight)

func update_inventory_grid():
	"""Update the inventory grid display"""
	# Clear existing items
	for child in inventory_grid.get_children():
		child.queue_free()
	
	# Create item buttons
	for item in filtered_items:
		var item_button = create_item_button(item)
		inventory_grid.add_child(item_button)

func create_item_button(item: Item) -> Button:
	"""Create a button for an item"""
	var button = Button.new()
	button.text = item.name
	button.custom_minimum_size = Vector2(100, 60)
	
	# Apply theme
	if ui_theme:
		ui_theme.apply_theme_to_control(button)
	
	# Color code by rarity
	var rarity_color = get_rarity_color(item.rarity)
	button.add_theme_color_override("font_color", rarity_color)
	
	# Connect signals
	button.pressed.connect(_on_item_button_pressed.bind(item))
	button.gui_input.connect(_on_item_gui_input.bind(item, button))
	
	return button

func get_rarity_color(rarity: String) -> Color:
	"""Get color for item rarity"""
	match rarity:
		"common":
			return ui_theme.get_color("text_primary")
		"uncommon":
			return ui_theme.get_color("success")
		"rare":
			return ui_theme.get_color("accent")
		"epic":
			return ui_theme.get_color("warning")
		"legendary":
			return ui_theme.get_color("error")
		_:
			return ui_theme.get_color("text_primary")

func _on_item_button_pressed(item: Item):
	"""Handle item button press"""
	selected_item = item
	item_selected.emit(item)
	show_item_details(item)

func _on_item_gui_input(item: Item, button: Button, event: InputEvent):
	"""Handle item GUI input for drag and drop"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start drag
				start_drag(item, button)
			else:
				# End drag
				end_drag()

func start_drag(item: Item, _button: Button):
	"""Start dragging an item"""
	dragged_item = item
	
	# Create drag preview
	drag_preview = Button.new()
	drag_preview.text = item.name
	drag_preview.custom_minimum_size = Vector2(100, 60)
	drag_preview.modulate.a = 0.8
	
	# Apply theme
	if ui_theme:
		ui_theme.apply_theme_to_control(drag_preview)
	
	# Add to scene
	add_child(drag_preview)
	
	# Set initial position
	drag_preview.position = get_global_mouse_position() - drag_preview.size / 2

func end_drag():
	"""End dragging an item"""
	if not dragged_item or not drag_preview:
		return
	
	# Check if dropped on equipment slot
	var mouse_pos = get_global_mouse_position()
	for slot_id in equipment_buttons:
		var button = equipment_buttons[slot_id]
		if button.get_global_rect().has_point(mouse_pos):
			equip_item(dragged_item, slot_id)
			break
	
	# Remove drag preview
	if drag_preview:
		drag_preview.queue_free()
		drag_preview = null
	
	dragged_item = null

func _input(_event):
	"""Handle input for drag and drop"""
	if dragged_item and drag_preview:
		drag_preview.position = get_global_mouse_position() - drag_preview.size / 2

func equip_item(item: Item, slot_id: String):
	"""Equip an item to a slot"""
	if not item.can_equip_to_slot(slot_id):
		print("InventoryInterface: Cannot equip %s to slot %s" % [item.name, slot_id])
		return
	
	var inventory_manager = get_node_or_null("/root/InventoryManager")
	if inventory_manager:
		inventory_manager.equip_item(item, slot_id)
		item_equipped.emit(item, slot_id)
		print("InventoryInterface: Equipped %s to %s" % [item.name, slot_id])

func _on_equipment_slot_pressed(slot_id: String):
	"""Handle equipment slot press"""
	var equipped_item = equipment_slots[slot_id]
	if equipped_item:
		unequip_item(equipped_item, slot_id)
		show_item_details(equipped_item)

func unequip_item(item: Item, slot_id: String):
	"""Unequip an item from a slot"""
	var inventory_manager = get_node_or_null("/root/InventoryManager")
	if inventory_manager:
		inventory_manager.unequip_item(item, slot_id)
		item_unequipped.emit(item, slot_id)
		print("InventoryInterface: Unequipped %s from %s" % [item.name, slot_id])

func show_item_details(item: Item):
	"""Show detailed information about an item"""
	item_details_panel.visible = true
	
	var details = []
	details.append("Name: %s" % item.name)
	details.append("Type: %s" % str(item.item_type).capitalize())
	details.append("Rarity: %s" % str(item.rarity).capitalize())
	details.append("Value: %d gold" % item.value)
	details.append("Weight: %.1f" % item.weight)
	
	if item.description:
		details.append("")
		details.append("Description:")
		details.append(item.description)
	
	if item.stats.size() > 0:
		details.append("")
		details.append("Stats:")
		for stat in item.stats:
			details.append("  %s: %d" % [stat, item.stats[stat]])
	
	if item.effects.size() > 0:
		details.append("")
		details.append("Effects:")
		for effect in item.effects:
			details.append("  %s" % effect)
	
	item_details_label.text = "\n".join(details)

func _on_filter_button_pressed(filter_name: String):
	"""Handle filter button press"""
	current_filter = filter_name
	apply_filters_and_sorting()
	update_inventory_grid()

func _on_search_text_changed(new_text: String):
	"""Handle search text change"""
	search_text = new_text
	apply_filters_and_sorting()
	update_inventory_grid()

func _on_sort_changed(index: int):
	"""Handle sort dropdown change"""
	var sort_options = ["name", "type", "rarity", "value", "weight"]
	if index < sort_options.size():
		current_sort = sort_options[index]
		apply_filters_and_sorting()
		update_inventory_grid()

func update_weight_and_gold():
	"""Update weight and gold display"""
	var inventory_manager = get_node_or_null("/root/InventoryManager")
	if inventory_manager:
		var weight = inventory_manager.get_total_weight()
		var max_weight = inventory_manager.get_max_weight()
		weight_label.text = "Weight: %.1f/%.1f" % [weight, max_weight]
		
		var gold = inventory_manager.get_gold()
		gold_label.text = "Gold: %d" % gold

func _on_item_equipped(item: Item, slot_id: String):
	"""Handle item equipped event"""
	equipment_slots[slot_id] = item
	var button = equipment_buttons[slot_id]
	if button:
		button.text = item.name
		button.add_theme_color_override("font_color", get_rarity_color(item.rarity))

func _on_item_unequipped(_item: Item, slot_id: String):
	"""Handle item unequipped event"""
	equipment_slots[slot_id] = null
	var button = equipment_buttons[slot_id]
	if button:
		button.text = button.name
		button.remove_theme_color_override("font_color")

func use_item(item: Item):
	"""Use a consumable item"""
	if item.item_type == "consumable":
		var inventory_manager = get_node_or_null("/root/InventoryManager")
		if inventory_manager:
			inventory_manager.use_item(item)
			item_used.emit(item)
			print("InventoryInterface: Used %s" % item.name)
	else:
		print("InventoryInterface: Cannot use non-consumable item %s" % item.name)

func drop_item(item: Item):
	"""Drop an item from inventory"""
	var inventory_manager = get_node_or_null("/root/InventoryManager")
	if inventory_manager:
		inventory_manager.remove_item(item)
		item_dropped.emit(item, Vector2.ZERO)
		print("InventoryInterface: Dropped %s" % item.name) 