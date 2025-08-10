extends Node

# Simple PS5 Controller Detection Test
# This will help us debug why your PS5 controller isn't being detected

func _ready():
	print("🎮 PS5 Controller Detection Test")
	var separator = ""
	for i in range(50):
		separator += "="
	print(separator)
	
	# Wait a moment for everything to initialize
	await get_tree().create_timer(1.0).timeout
	
	run_controller_detection_tests()

func run_controller_detection_tests():
	"""Run comprehensive controller detection tests"""
	
	print("\n1️⃣ Testing Basic Input Detection...")
	print("   Connected Joypads: %s" % Input.get_connected_joypads())
	
	for device_id in Input.get_connected_joypads():
		print("   Device %d: %s" % [device_id, Input.get_joy_name(device_id)])
	
	print("\n2️⃣ Testing Controller Icons Plugin...")
	if has_node("/root/ControllerIcons"):
		print("   ✅ ControllerIcons autoload found")
		var controller_icons = get_node("/root/ControllerIcons")
		print("   Input Type: %s" % controller_icons._last_input_type)
	else:
		print("   ❌ ControllerIcons autoload not found")
	
	print("\n3️⃣ Testing Controller Detection...")
	if has_node("/root/ControllerIcons"):
		var controller_icons = get_node("/root/ControllerIcons")
		# The custom ControllerIcons script no longer has a 'Mapper' property like the old plugin
		# This part of the test needs to be adjusted or removed if the Mapper functionality is integrated directly
		# For now, we'll check if the ControllerIcons script itself is working as expected for type detection
		var detected_type = controller_icons.get_controller_type()
		print("   ControllerIcons detected type: %s" % detected_type)
		
		if Input.get_connected_joypads().size() > 0:
			var controller_name = Input.get_joy_name(Input.get_connected_joypads()[0])
			print("   Controller Name: %s" % controller_name)
			
			# Test PS5 detection
			if "PS5" in controller_name:
				print("   ✅ PS5 Controller detected!")
			else:
				print("   ⚠️  Controller detected but not recognized as PS5")
				print("   Expected: 'PS5 Controller' in name")
				print("   Actual: '%s'" % controller_name)
		else:
			print("   ❌ No controllers connected")
	
	print("\n4️⃣ Testing Input Events...")
	print("   Testing for any controller input...")
	
	# Set up input monitoring
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	
	print("\n5️⃣ Manual Controller Test...")
	print("   Please press any button on your PS5 controller...")
	print("   (This will test for 10 seconds)")
	
	# Monitor for input for 10 seconds
	var start_time = Time.get_time_dict_from_system()
	var test_duration = 10.0
	
	while Time.get_time_dict_from_system().second - start_time.second < test_duration:
		await get_tree().process_frame
		# Input events will be handled in _input()

func _input(event):
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		print("   🎮 Controller Input Detected!")
		print("   Event Type: %s" % event.get_class())
		if event is InputEventJoypadButton:
			print("   Button: %d, Pressed: %s" % [event.button_index, event.pressed])
		elif event is InputEventJoypadMotion:
			print("   Axis: %d, Value: %.2f" % [event.axis, event.axis_value])

func _on_joy_connection_changed(device_id: int, connected: bool):
	print("   🔌 Controller %d %s" % [device_id, "connected" if connected else "disconnected"])
	if connected:
		print("   Controller Name: %s" % Input.get_joy_name(device_id))

func _exit_tree():
	# Clean up
	if Input.joy_connection_changed.is_connected(_on_joy_connection_changed):
		Input.joy_connection_changed.disconnect(_on_joy_connection_changed) 