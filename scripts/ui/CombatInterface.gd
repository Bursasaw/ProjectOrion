extends Control
class_name CombatInterface

# Advanced Combat Interface
# Displays combat information, AI reasoning, and tactical data

signal action_selected(action: CombatAction, target: CombatActor)
signal turn_ended()
signal ai_reasoning_requested()

# UI References
@onready var action_points_label: Label = $CombatLayout/ActionPointsPanel/ActionPointsLabel
@onready var turn_info_label: Label = $CombatLayout/TurnInfoPanel/TurnInfoLabel
@onready var ai_reasoning_panel: Panel = $CombatLayout/AIReasoningPanel
@onready var ai_reasoning_label: Label = $CombatLayout/AIReasoningPanel/AIReasoningLabel
@onready var emotional_state_panel: Panel = $CombatLayout/EmotionalStatePanel
@onready var emotional_state_label: Label = $CombatLayout/EmotionalStatePanel/EmotionalStateLabel
@onready var tactical_info_panel: Panel = $CombatLayout/TacticalInfoPanel
@onready var tactical_info_label: Label = $CombatLayout/TacticalInfoPanel/TacticalInfoLabel
@onready var action_buttons_container: HBoxContainer = $CombatLayout/ActionButtonsContainer
@onready var target_selection_panel: Panel = $CombatLayout/TargetSelectionPanel
@onready var target_list: VBoxContainer = $CombatLayout/TargetSelectionPanel/TargetList
@onready var weather_panel: Panel = $CombatLayout/WeatherPanel
@onready var weather_label: Label = $CombatLayout/WeatherPanel/WeatherLabel
@onready var surface_panel: Panel = $CombatLayout/SurfacePanel
@onready var surface_label: Label = $CombatLayout/SurfacePanel/SurfaceLabel

# Combat State
var current_actor: CombatActor = null
var available_actions: Array[CombatAction] = []
var available_targets: Array[CombatActor] = []
var selected_action: CombatAction = null
var selected_target: CombatActor = null

# UI Theme
var ui_theme: UITheme = null

# Animation
var animation_tween: Tween = null

func _ready():
	"""Initialize the combat interface"""
	print("CombatInterface: Initialized")
	
	# Get UI theme
	ui_theme = get_node_or_null("/root/UITheme")
	if not ui_theme:
		ui_theme = UITheme.new()
		add_child(ui_theme)
	
	# Apply theme
	apply_theme()
	
	# Connect to combat manager signals
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager:
		combat_manager.turn_started.connect(_on_turn_started)
		combat_manager.action_performed.connect(_on_action_performed)
		combat_manager.combat_ended.connect(_on_combat_ended)
	
	# Initially hide AI reasoning panel
	ai_reasoning_panel.visible = false
	target_selection_panel.visible = false

func apply_theme():
	"""Apply the current theme to all UI elements"""
	if not ui_theme:
		return
	
	# Apply panel styles
	var panels = [ai_reasoning_panel, emotional_state_panel, tactical_info_panel, 
				  target_selection_panel, weather_panel, surface_panel]
	for panel in panels:
		ui_theme.apply_theme_to_control(panel)
	
	# Apply text colors
	var labels = [action_points_label, turn_info_label, ai_reasoning_label, 
				  emotional_state_label, tactical_info_label, weather_label, surface_label]
	for label in labels:
		if label:
			label.add_theme_color_override("font_color", ui_theme.get_color("text_primary"))
			label.add_theme_font_size_override("font_size", ui_theme.get_font_size("medium"))

func _on_turn_started(actor: CombatActor):
	"""Handle turn start"""
	current_actor = actor
	update_interface()
	
	# Animate interface in
	ui_theme.animate_fade_in(self, 0.3)
	
	print("CombatInterface: Turn started for %s" % actor.character_name)

func update_interface():
	"""Update the combat interface with current state"""
	if not current_actor:
		return
	
	# Update action points
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager:
		var action_points = combat_manager.get_action_points()
		var max_action_points = combat_manager.get_max_action_points()
		action_points_label.text = "Action Points: %d/%d" % [action_points, max_action_points]
	
	# Update turn info
	turn_info_label.text = "%s's Turn" % current_actor.character_name
	
	# Update available actions
	update_action_buttons()
	
	# Update AI reasoning if it's an AI turn
	if current_actor != combat_manager.player_actor:
		show_ai_reasoning()
	else:
		hide_ai_reasoning()

func update_action_buttons():
	"""Update the action buttons based on available actions"""
	# Clear existing buttons
	for child in action_buttons_container.get_children():
		child.queue_free()
	
	# Get available actions
	if current_actor:
		available_actions = current_actor.get_available_actions()
	
	# Create action buttons
	for action in available_actions:
		var button = Button.new()
		button.text = action.name
		button.custom_minimum_size = Vector2(120, 40)
		
		# Apply theme
		if ui_theme:
			ui_theme.apply_theme_to_control(button)
		
		# Connect signal
		button.pressed.connect(_on_action_button_pressed.bind(action))
		
		# Add to container
		action_buttons_container.add_child(button)
		
		# Check if action can be used
		var action_cost = action.get_action_cost() if action.has_method("get_action_cost") else 1
		var combat_manager = get_node_or_null("/root/CombatManager")
		if combat_manager and not combat_manager.can_perform_action(action_cost):
			button.disabled = true
			button.modulate = Color(0.5, 0.5, 0.5)

func _on_action_button_pressed(action: CombatAction):
	"""Handle action button press"""
	selected_action = action
	
	# Show target selection if action requires a target
	if action.requires_target:
		show_target_selection()
	else:
		# Execute action immediately
		execute_action(action, null)

func show_target_selection():
	"""Show target selection panel"""
	# Clear existing targets
	for child in target_list.get_children():
		child.queue_free()
	
	# Get available targets
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager:
		if selected_action.targets_enemies():
			available_targets = combat_manager.enemies
		else:
			available_targets = [combat_manager.player_actor]
	
	# Create target buttons
	for target in available_targets:
		if target and not target.is_defeated():
			var button = Button.new()
			button.text = "%s (HP: %d/%d)" % [target.character_name, target.health_points, target.max_health_points]
			button.custom_minimum_size = Vector2(200, 40)
			
			# Apply theme
			if ui_theme:
				ui_theme.apply_theme_to_control(button)
			
			# Connect signal
			button.pressed.connect(_on_target_button_pressed.bind(target))
			
			# Add to container
			target_list.add_child(button)
	
	# Show panel with animation
	target_selection_panel.visible = true
	ui_theme.animate_slide_in(target_selection_panel, Vector2(0, -50), 0.3)

func _on_target_button_pressed(target: CombatActor):
	"""Handle target button press"""
	selected_target = target
	hide_target_selection()
	execute_action(selected_action, target)

func hide_target_selection():
	"""Hide target selection panel"""
	ui_theme.animate_fade_out(target_selection_panel, 0.2)
	await get_tree().create_timer(0.2).timeout
	target_selection_panel.visible = false

func execute_action(action: CombatAction, target: CombatActor):
	"""Execute the selected action"""
	if not action or not current_actor:
		return
	
	# Emit signal
	action_selected.emit(action, target)
	
	# Hide target selection
	target_selection_panel.visible = false
	
	# Clear selection
	selected_action = null
	selected_target = null
	
	print("CombatInterface: Action %s executed by %s on %s" % [action.name, current_actor.character_name, target.character_name if target else "self"])

func show_ai_reasoning():
	"""Show AI reasoning panel"""
	ai_reasoning_panel.visible = true
	
	# Emit signal
	ai_reasoning_requested.emit()
	
	# Get AI reasoning from combat manager
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager and combat_manager.combat_ai:
		var stats = combat_manager.combat_ai.get_ai_statistics()
		var reasoning = "AI Personality: %s\nEmotional State: %s" % [stats["personality"], stats["current_emotion"]]
		ai_reasoning_label.text = reasoning
	
	# Show emotional state
	show_emotional_state()
	
	# Show tactical info
	show_tactical_info()

func hide_ai_reasoning():
	"""Hide AI reasoning panel"""
	ai_reasoning_panel.visible = false
	emotional_state_panel.visible = false
	tactical_info_panel.visible = false

func show_emotional_state():
	"""Show AI emotional state"""
	emotional_state_panel.visible = true
	
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager and combat_manager.combat_ai:
		var stats = combat_manager.combat_ai.get_ai_statistics()
		var emotion = stats["current_emotion"]
		emotional_state_label.text = "Emotional State: %s" % emotion
		
		# Color code the emotional state
		if ui_theme:
			var emotion_color = ui_theme.get_ai_emotion_color(emotion)
			emotional_state_label.add_theme_color_override("font_color", emotion_color)

func show_tactical_info():
	"""Show tactical information"""
	tactical_info_panel.visible = true
	
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager:
		var info = []
		
		# Weather effects
		var weather = combat_manager.get_current_weather()
		if weather != "clear":
			info.append("Weather: %s" % weather)
		
		# Surface effects
		if combat_manager.surface_manager:
			var surface_type = combat_manager.surface_manager.get_surface_type()
			if surface_type != "normal":
				info.append("Surface: %s" % surface_type)
		
		# Team synergies
		if combat_manager.team_coordination_ai:
			var team_stats = combat_manager.team_coordination_ai.get_coordination_statistics()
			info.append("Team Strategy: %s" % team_stats["current_strategy"])
		
		if info.size() > 0:
			tactical_info_label.text = "\n".join(info)
		else:
			tactical_info_label.text = "No special conditions"

func _on_action_performed(action: CombatAction, actor: CombatActor, target: CombatActor):
	"""Handle action performed"""
	# Update interface
	update_interface()
	
	# Show action result
	show_action_result(action, actor, target)

func show_action_result(action: CombatAction, actor: CombatActor, target: CombatActor):
	"""Show the result of an action"""
	var result_text = "%s used %s" % [actor.character_name, action.name]
	if target:
		result_text += " on %s" % target.character_name
	
	# Create temporary result label
	var result_label = Label.new()
	result_label.text = result_text
	result_label.add_theme_color_override("font_color", ui_theme.get_color("accent"))
	result_label.add_theme_font_size_override("font_size", ui_theme.get_font_size("large"))
	result_label.position = Vector2(400, 200)
	add_child(result_label)
	
	# Animate and remove
	ui_theme.animate_fade_in(result_label, 0.2)
	await get_tree().create_timer(2.0).timeout
	ui_theme.animate_fade_out(result_label, 0.2)
	await get_tree().create_timer(0.2).timeout
	result_label.queue_free()

func _on_combat_ended(result: String):
	"""Handle combat end"""
	# Show combat result
	var result_text = "Combat %s!" % result.capitalize()
	var result_color = ui_theme.get_color("success") if result == "victory" else ui_theme.get_color("error")
	
	# Create result label
	var result_label = Label.new()
	result_label.text = result_text
	result_label.add_theme_color_override("font_color", result_color)
	result_label.add_theme_font_size_override("font_size", ui_theme.get_font_size("title"))
	result_label.position = Vector2(300, 150)
	add_child(result_label)
	
	# Animate and remove
	ui_theme.animate_fade_in(result_label, 0.5)
	await get_tree().create_timer(3.0).timeout
	ui_theme.animate_fade_out(result_label, 0.5)
	await get_tree().create_timer(0.5).timeout
	result_label.queue_free()
	
	# Hide interface
	ui_theme.animate_fade_out(self, 0.3)
	await get_tree().create_timer(0.3).timeout
	visible = false

func end_turn():
	"""End the current turn"""
	turn_ended.emit()
	
	# Hide interface
	ui_theme.animate_fade_out(self, 0.2)
	await get_tree().create_timer(0.2).timeout
	visible = false

func update_weather_display():
	"""Update weather display"""
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager:
		var weather = combat_manager.get_current_weather()
		weather_label.text = "Weather: %s" % weather.capitalize()
		
		# Show weather effects
		var weather_effects = combat_manager.get_weather_effects()
		if weather_effects.size() > 0:
			var effects_text = []
			for effect in weather_effects:
				effects_text.append("%s: %.1fx" % [effect, weather_effects[effect]])
			weather_label.text += "\nEffects: " + ", ".join(effects_text)

func update_surface_display():
	"""Update surface display"""
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager and combat_manager.surface_manager:
		var surface_type = combat_manager.surface_manager.get_surface_type()
		surface_label.text = "Surface: %s" % surface_type.capitalize() 