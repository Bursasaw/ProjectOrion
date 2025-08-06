extends Panel
class_name QuestPanel

# Quest Panel - Handles quest UI interactions
# Manages quest display, tracking, and user interactions
# Fixed syntax errors

# signal quest_selected(quest_id: String) # Removed - not currently used
signal quest_panel_closed()

var tab_container: TabContainer
var active_quests_list: VBoxContainer
var completed_quests_list: VBoxContainer
var available_quests_list: VBoxContainer
var close_button: Button

var quest_manager: Node
var selected_quest: String = ""

func _ready():
	"""Initialize quest panel"""
	# Get node references
	tab_container = $QuestContainer/TabContainer
	active_quests_list = $QuestContainer/TabContainer/"Active Quests"/ActiveQuestsList
	completed_quests_list = $QuestContainer/TabContainer/"Completed Quests"/CompletedQuestsList
	available_quests_list = $QuestContainer/TabContainer/"Available Quests"/AvailableQuestsList
	close_button = $QuestContainer/CloseQuestButton
	
	# Connect signals
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	
	# Hide initially
	visible = false

func set_quest_manager(manager: Node):
	"""Set the quest manager reference"""
	quest_manager = manager
	if quest_manager:
		# Disconnect existing signals first to prevent duplicates
		if quest_manager.quest_started.is_connected(_on_quest_started):
			quest_manager.quest_started.disconnect(_on_quest_started)
		if quest_manager.quest_completed.is_connected(_on_quest_completed):
			quest_manager.quest_completed.disconnect(_on_quest_completed)
		if quest_manager.quest_failed.is_connected(_on_quest_failed):
			quest_manager.quest_failed.disconnect(_on_quest_failed)
		if quest_manager.objective_updated.is_connected(_on_objective_updated):
			quest_manager.objective_updated.disconnect(_on_objective_updated)
		
		# Connect signals
		quest_manager.quest_started.connect(_on_quest_started)
		quest_manager.quest_completed.connect(_on_quest_completed)
		quest_manager.quest_failed.connect(_on_quest_failed)
		quest_manager.objective_updated.connect(_on_objective_updated)

func _on_quest_started(_quest_id: String):
	"""Handle quest started"""
	update_quest_display()

func _on_quest_completed(_quest_id: String):
	"""Handle quest completed"""
	update_quest_display()

func _on_quest_failed(_quest_id: String):
	"""Handle quest failed"""
	update_quest_display()

func _on_objective_updated(_quest_id: String, _objective_id: String, _progress: int, _total: int):
	"""Handle objective updated"""
	update_quest_display()

func update_quest_display():
	"""Update the quest display with current quest data"""
	if not quest_manager:
		return
	
	# Clear existing lists
	clear_quest_lists()
	
	# Update active quests
	update_active_quests()
	
	# Update completed quests
	update_completed_quests()
	
	# Update available quests
	update_available_quests()

func clear_quest_lists():
	"""Clear all quest lists"""
	for child in active_quests_list.get_children():
		child.queue_free()
	
	for child in completed_quests_list.get_children():
		child.queue_free()
	
	for child in available_quests_list.get_children():
		child.queue_free()

func update_active_quests():
	"""Update the active quests list"""
	if not quest_manager:
		return
	
	var active_quests = quest_manager.get_active_quests()
	
	for quest_id in active_quests:
		var quest_info = quest_manager.get_quest_info(quest_id)
		var quest_data = active_quests[quest_id]
		
		var quest_item = create_quest_item(quest_info, quest_data, true)
		active_quests_list.add_child(quest_item)

func update_completed_quests():
	"""Update the completed quests list"""
	if not quest_manager:
		return
	
	var completed_quests = quest_manager.get_completed_quests()
	
	for quest_id in completed_quests:
		var quest_info = quest_manager.get_quest_info(quest_id)
		
		var quest_item = create_quest_item(quest_info, {}, false, true)
		completed_quests_list.add_child(quest_item)

func update_available_quests():
	"""Update the available quests list"""
	if not quest_manager:
		return
	
	var available_quests = quest_manager.get_available_quests()
	
	for quest_id in available_quests:
		var quest_info = quest_manager.get_quest_info(quest_id)
		
		var quest_item = create_quest_item(quest_info, {}, false, false, true)
		available_quests_list.add_child(quest_item)

func create_quest_item(quest_info: Dictionary, quest_data: Dictionary, is_active: bool = false, is_completed: bool = false, is_available: bool = false) -> Control:
	"""Create a quest item for display"""
	var container = VBoxContainer.new()
	
	# Quest title
	var title_label = Label.new()
	title_label.text = quest_info.get("name", "Unknown Quest")
	title_label.add_theme_font_size_override("font_size", 16)
	container.add_child(title_label)
	
	# Quest description
	var desc_label = Label.new()
	desc_label.text = quest_info.get("description", "")
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	container.add_child(desc_label)
	
	# Objectives (for active quests)
	if is_active and quest_data.has("objectives"):
		var objectives_container = VBoxContainer.new()
		objectives_container.add_child(Label.new())  # Spacer
		
		for objective in quest_data["objectives"]:
			var obj_label = Label.new()
			obj_label.text = "• " + objective["description"] + " (" + str(objective["current"]) + "/" + str(objective["target"]) + ")"
			objectives_container.add_child(obj_label)
		
		container.add_child(objectives_container)
	
	# Quest type and location
	var info_label = Label.new()
	info_label.text = "Type: " + get_quest_type_name(quest_info.get("type", "")) + " | Location: " + quest_info.get("location", "Unknown")
	info_label.add_theme_color_override("font_color", Color.GRAY)
	container.add_child(info_label)
	
	# Status indicator
	var status_label = Label.new()
	if is_completed:
		status_label.text = "✓ Completed"
		status_label.add_theme_color_override("font_color", Color.GREEN)
	elif is_active:
		status_label.text = "▶ Active"
		status_label.add_theme_color_override("font_color", Color.YELLOW)
	elif is_available:
		status_label.text = "○ Available"
		status_label.add_theme_color_override("font_color", Color.WHITE)
	container.add_child(status_label)
	
	# Add some spacing
	container.add_child(HSeparator.new())
	
	return container

func get_quest_type_name(quest_type: String) -> String:
	"""Get the name of a quest type"""
	match quest_type:
		"main_story": return "Main Story"
		"side_quest": return "Side Quest"
		"collection": return "Collection"
		"exploration": return "Exploration"
		"combat": return "Combat"
		"dialogue": return "Dialogue"
		"delivery": return "Delivery"
		"puzzle": return "Puzzle"
		_: return "Unknown"

func _on_close_pressed():
	"""Handle close button press"""
	hide()
	quest_panel_closed.emit()

func show_quest_panel():
	"""Show the quest panel"""
	show()
	update_quest_display()

func hide_quest_panel():
	"""Hide the quest panel"""
	hide() 
