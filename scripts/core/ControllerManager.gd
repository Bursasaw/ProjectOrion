extends Node

# Controller Manager - Handles controller input, debugging, and UI integration
# Provides comprehensive controller support with debugging tools

signal controller_connected(controller_id: int)
signal controller_disconnected(controller_id: int)
signal input_detected(action: String, strength: float, controller_id: int)

# Controller state
var controllers: Dictionary = {}
var active_controller_id: int = -1
var debug_mode: bool = true

# Input mappings for your game
var input_actions: Dictionary = {
	"move_forward": ["ui_up", "gamepad_left_stick_up"],
	"move_backward": ["ui_down", "gamepad_left_stick_down"],
	"move_left": ["ui_left", "gamepad_left_stick_left"],
	"move_right": ["ui_right", "gamepad_left_stick_right"],
	"jump": ["ui_accept", "gamepad_a"],
	"attack": ["ui_select", "gamepad_x"],
	"interact": ["ui_focus_next", "gamepad_y"],
	"menu": ["ui_cancel", "gamepad_b"],
	"inventory": ["ui_page_up", "gamepad_lb"],
	"map": ["ui_page_down", "gamepad_rb"],
	"pause": ["ui_cancel", "gamepad_start"],
	"camera_up": ["gamepad_right_stick_up"],
	"camera_down": ["gamepad_right_stick_down"],
	"camera_left": ["gamepad_right_stick_left"],
	"camera_right": ["gamepad_right_stick_right"],
	"trigger_left": ["gamepad_lt"],
	"trigger_right": ["gamepad_rt"]
}

# Controller types and their icons
var controller_types: Dictionary = {
	"xbox": "xbox_controller",
	"playstation": "ps_controller", 
	"nintendo": "switch_controller",
	"generic": "generic_controller"
}

func _ready():
	"""Initialize controller manager"""
	print("ControllerManager: Initializing...")
	setup_controller_detection()
	setup_input_mappings()

func setup_controller_detection():
	"""Set up controller connection detection"""
	# Connect to controller events
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	
	# Check for already connected controllers
	for i in range(Input.get_connected_joypads().size()):
		var controller_id = Input.get_connected_joypads()[i]
		_on_joy_connection_changed(controller_id, true)

func setup_input_mappings():
	"""Set up input mappings for the game"""
	# Add input actions to the input map
	for action in input_actions:
		for input_event in input_actions[action]:
			if not InputMap.has_action(action):
				InputMap.add_action(action)
			
			# Add the input event to the action
			var event = InputEventAction.new()
			event.action = input_event
			InputMap.action_add_event(action, event)

func _on_joy_connection_changed(device_id: int, connected: bool):
	"""Handle controller connection/disconnection"""
	if connected:
		var controller_name = Input.get_joy_name(device_id)
		var controller_guid = Input.get_joy_guid(device_id)
		
		controllers[device_id] = {
			"name": controller_name,
			"guid": controller_guid,
			"type": detect_controller_type(controller_name, controller_guid),
			"connected": true
		}
		
		if active_controller_id == -1:
			active_controller_id = device_id
		
		print("ControllerManager: Controller connected - %s (ID: %d)" % [controller_name, device_id])
		controller_connected.emit(device_id)
	else:
		if controllers.has(device_id):
			var controller_name = controllers[device_id].name
			controllers.erase(device_id)
			
			if active_controller_id == device_id:
				active_controller_id = -1
				# Switch to another controller if available
				if controllers.size() > 0:
					active_controller_id = controllers.keys()[0]
			
			print("ControllerManager: Controller disconnected - %s (ID: %d)" % [controller_name, device_id])
			controller_disconnected.emit(device_id)

func detect_controller_type(controller_name: String, controller_guid: String) -> String:
	"""Detect the type of controller based on name and GUID"""
	var name_lower = controller_name.to_lower()
	var guid_lower = controller_guid.to_lower()
	
	if "xbox" in name_lower or "xinput" in guid_lower:
		return "xbox"
	elif "playstation" in name_lower or "ps" in name_lower or "sony" in name_lower:
		return "playstation"
	elif "nintendo" in name_lower or "switch" in name_lower or "joy-con" in name_lower:
		return "nintendo"
	else:
		return "generic"

func is_controller_connected() -> bool:
	"""Check if any controller is connected"""
	return active_controller_id != -1

func get_active_controller() -> Dictionary:
	"""Get the currently active controller"""
	if active_controller_id != -1 and controllers.has(active_controller_id):
		return controllers[active_controller_id]
	return {}

func get_controller_type() -> String:
	"""Get the type of the active controller"""
	var controller = get_active_controller()
	if controller.has("type"):
		return controller.type
	
	# Fallback: detect from controller name
	if active_controller_id != -1:
		var controller_name = Input.get_joy_name(active_controller_id)
		print("ControllerManager: Detecting controller type for '%s'" % controller_name)
		
		# Check for specific controller types
		if "PS5" in controller_name:
			return "ps5"
		elif "PS4" in controller_name:
			return "ps4"
		elif "Xbox" in controller_name:
			return "xbox"
		elif "Nintendo" in controller_name or "Switch" in controller_name:
			return "nintendo"
		elif "PlayStation" in controller_name or "PS" in controller_name:
			return "playstation"
	
	return "generic"

func get_input_strength(action: String) -> float:
	"""Get the input strength for an action (0.0 to 1.0)"""
	if not InputMap.has_action(action):
		return 0.0
	
	return Input.get_action_strength(action)

func is_action_pressed(action: String) -> bool:
	"""Check if an action is pressed"""
	if not InputMap.has_action(action):
		return false
	
	return Input.is_action_pressed(action)

func is_action_just_pressed(action: String) -> bool:
	"""Check if an action was just pressed"""
	if not InputMap.has_action(action):
		return false
	
	return Input.is_action_just_pressed(action)

func is_action_just_released(action: String) -> bool:
	"""Check if an action was just released"""
	if not InputMap.has_action(action):
		return false
	
	return Input.is_action_just_released(action)

# ===== DEBUGGING FUNCTIONS =====

func get_controller_debug_info() -> Dictionary:
	"""Get debug information about connected controllers"""
	var debug_info = {
		"active_controller_id": active_controller_id,
		"controllers_connected": controllers.size(),
		"controllers": {}
	}
	
	for device_id in controllers:
		var controller = controllers[device_id]
		debug_info.controllers[device_id] = {
			"name": controller.name,
			"type": controller.type,
			"guid": controller.guid,
			"is_active": (device_id == active_controller_id)
		}
	
	return debug_info

func get_input_debug_info() -> Dictionary:
	"""Get debug information about current input states"""
	var debug_info = {
		"active_controller": get_active_controller(),
		"input_states": {}
	}
	
	# Check all input actions
	for action in input_actions:
		debug_info.input_states[action] = {
			"pressed": is_action_pressed(action),
			"just_pressed": is_action_just_pressed(action),
			"just_released": is_action_just_released(action),
			"strength": get_input_strength(action)
		}
	
	return debug_info

func print_controller_info():
	"""Print detailed controller information"""
	print("\n🎮 Controller Debug Information:")
	var controller_separator = ""
	for i in range(50):
		controller_separator += "="
	print(controller_separator)
	
	var debug_info = get_controller_debug_info()
	print("Active Controller ID: %d" % debug_info.active_controller_id)
	print("Controllers Connected: %d" % debug_info.controllers_connected)
	
	for device_id in debug_info.controllers:
		var controller = debug_info.controllers[device_id]
		var status = "ACTIVE" if controller.is_active else "Connected"
		print("  Controller %d: %s (%s) - %s" % [device_id, controller.name, controller.type, status])
	
	print(controller_separator)

func print_input_states():
	"""Print current input states"""
	print("\n🎮 Input States:")
	var input_separator = ""
	for i in range(50):
		input_separator += "="
	print(input_separator)
	
	var debug_info = get_input_debug_info()
	for action in debug_info.input_states:
		var state = debug_info.input_states[action]
		if state.pressed or state.just_pressed or state.just_released:
			print("  %s: Pressed=%s, JustPressed=%s, JustReleased=%s, Strength=%.2f" % [
				action, state.pressed, state.just_pressed, state.just_released, state.strength
			])
	
	print(input_separator)

# ===== UI INTEGRATION =====

func get_controller_icon_path(controller_type: String = "") -> String:
	"""Get the path to the controller icon for UI"""
	if has_node("/root/ControllerIcons"):
		var controller_icons = get_node("/root/ControllerIcons")
		return controller_icons.get_controller_icon_path(controller_type)
	
	# Fallback if ControllerIcons not available
	if controller_type.is_empty():
		controller_type = get_controller_type()
	
	# NOTE: ControllerIcons_old directory was removed, using fallback
	return "res://assets/ui/controller_disconnected.png"

func get_button_icon_path(button_name: String, controller_type: String = "") -> String:
	"""Get the path to a specific button icon"""
	if has_node("/root/ControllerIcons"):
		var controller_icons = get_node("/root/ControllerIcons")
		return controller_icons.get_button_icon_path(button_name, controller_type)
	
	# Fallback if ControllerIcons not available
	if controller_type.is_empty():
		controller_type = get_controller_type()
	
	# NOTE: ControllerIcons_old directory was removed, using fallback
	return "res://assets/ui/controller_disconnected.png"

# ===== UTILITY FUNCTIONS =====

func switch_active_controller(controller_id: int):
	"""Switch to a different active controller"""
	if controllers.has(controller_id):
		active_controller_id = controller_id
		print("ControllerManager: Switched to controller %d" % controller_id)

func get_controller_count() -> int:
	"""Get the number of connected controllers"""
	return controllers.size()

func get_controller_names() -> Array[String]:
	"""Get names of all connected controllers"""
	var names: Array[String] = []
	for controller in controllers.values():
		names.append(controller.name)
	return names

func _process(_delta):
	"""Process controller input and emit signals"""
	if debug_mode and is_controller_connected():
		# Emit signals for debugging
		for action in input_actions:
			var strength = get_input_strength(action)
			if strength > 0.0:
				input_detected.emit(action, strength, active_controller_id)

# ===== RUMBLE FUNCTIONALITY =====

func start_rumble(weak_magnitude: float, strong_magnitude: float, duration_ms: int) -> bool:
	"""Start controller rumble with specified parameters"""
	if not is_controller_connected():
		print("ControllerManager: No controller connected for rumble")
		return false
	
	# Clamp magnitudes to valid range (0.0 to 1.0)
	weak_magnitude = clamp(weak_magnitude, 0.0, 1.0)
	strong_magnitude = clamp(strong_magnitude, 0.0, 1.0)
	
	# Start rumble using Godot's Input system
	Input.start_joy_vibration(active_controller_id, weak_magnitude, strong_magnitude, duration_ms / 1000.0)
	
	print("ControllerManager: Rumble started - Weak: %.2f, Strong: %.2f, Duration: %dms" % [
		weak_magnitude, strong_magnitude, duration_ms
	])
	
	return true

func stop_rumble() -> bool:
	"""Stop controller rumble"""
	if not is_controller_connected():
		return false
	
	Input.stop_joy_vibration(active_controller_id)
	
	print("ControllerManager: Rumble stopped")
	
	return true

func is_rumble_supported() -> bool:
	"""Check if the current controller supports rumble"""
	if not is_controller_connected():
		return false
	
	# Try a very short rumble to test support
	var test_result = start_rumble(0.1, 0.1, 50)  # 50ms at 10% strength
	if test_result:
		stop_rumble()  # Stop the test rumble
		return true
	
	return false

func get_rumble_info() -> Dictionary:
	"""Get information about rumble support and capabilities"""
	var info = {
		"supported": false,
		"controller_connected": false,
		"controller_type": "",
		"test_result": false
	}
	
	if is_controller_connected():
		info.controller_connected = true
		info.controller_type = get_controller_type()
		info.supported = is_rumble_supported()
		info.test_result = start_rumble(0.1, 0.1, 50)  # Quick test
		if info.test_result:
			stop_rumble()  # Clean up test
	
	return info 
