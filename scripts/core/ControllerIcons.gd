extends Node

signal input_type_changed(input_type)

enum InputType {
	KEYBOARD_MOUSE,
	CONTROLLER
}

# var _cached_icons := {}  # Removed unused variable
var _last_input_type: InputType = InputType.KEYBOARD_MOUSE

func _ready():
	# Connect to controller events
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	
	# Set initial input type
	if Input.get_connected_joypads().size() > 0:
		_set_last_input_type(InputType.CONTROLLER)
	else:
		_set_last_input_type(InputType.KEYBOARD_MOUSE)

func _set_last_input_type(input_type: InputType):
	_last_input_type = input_type
	input_type_changed.emit(input_type)

func _on_joy_connection_changed(_device_id: int, connected: bool):
	if connected:
		_set_last_input_type(InputType.CONTROLLER)
	else:
		# Check if any controllers are still connected
		if Input.get_connected_joypads().size() == 0:
			_set_last_input_type(InputType.KEYBOARD_MOUSE)

func _input(event: InputEvent):
	var input_type = _last_input_type
	
	match event.get_class():
		"InputEventKey", "InputEventMouseButton":
			input_type = InputType.KEYBOARD_MOUSE
		"InputEventJoypadButton":
			input_type = InputType.CONTROLLER
		"InputEventJoypadMotion":
			if abs(event.axis_value) > 0.1:  # Deadzone
				input_type = InputType.CONTROLLER
	
	if input_type != _last_input_type:
		_set_last_input_type(input_type)

# ===== CONTROLLER DETECTION =====

func get_controller_type() -> String:
	"""Get the type of the active controller"""
	var connected_joypads = Input.get_connected_joypads()
	if connected_joypads.size() == 0:
		return "generic"
	
	var controller_name = Input.get_joy_name(connected_joypads[0])
	print("ControllerIcons: Detecting controller type for '%s'" % controller_name)
	
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
	else:
		return "generic"

# ===== ICON PATH GENERATION =====

func get_controller_icon_path(controller_type: String = "") -> String:
	"""Get the path to the controller icon for UI"""
	if controller_type.is_empty():
		controller_type = get_controller_type()
	
	# NOTE: ControllerIcons_old directory was removed, using fallback
	return "res://assets/ui/controller_disconnected.png"

func get_button_icon_path(_button_name: String, controller_type: String = "") -> String:
	"""Get the path to a specific button icon"""
	if controller_type.is_empty():
		controller_type = get_controller_type()
	
	# NOTE: ControllerIcons_old directory was removed, using fallback
	return "res://assets/ui/controller_disconnected.png"

# ===== PS5 SPECIFIC MAPPING =====

func get_ps5_button_path(button_name: String) -> String:
	"""Get the PS5-specific button path"""
	match button_name:
		"a": return "cross"
		"b": return "circle"
		"x": return "square"
		"y": return "triangle"
		"lb": return "l1"
		"rb": return "r1"
		"lt": return "l2"
		"rt": return "r2"
		"select": return "share"
		"start": return "options"
		"home": return "assistant"
		_: return button_name

# ===== UTILITY FUNCTIONS =====

func is_controller_connected() -> bool:
	"""Check if any controller is connected"""
	return Input.get_connected_joypads().size() > 0

func get_controller_count() -> int:
	"""Get the number of connected controllers"""
	return Input.get_connected_joypads().size()

func get_controller_names() -> Array[String]:
	"""Get names of all connected controllers"""
	var names: Array[String] = []
	for device_id in Input.get_connected_joypads():
		names.append(Input.get_joy_name(device_id))
	return names

func get_input_type() -> InputType:
	"""Get the current input type"""
	return _last_input_type 