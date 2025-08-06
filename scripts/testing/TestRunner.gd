extends Node

# TestRunner - Simple manual test runner
# Can be called to run specific tests or all tests

# signal test_started(test_name: String)  # Unused signal
signal test_completed(test_name: String, result: bool)
signal all_tests_completed(results: Dictionary)

var test_bot: Node
var is_running: bool = false

func _ready():
	# Get reference to TestBot
	test_bot = get_node("/root/Main/TestBot")
	if test_bot:
		test_bot.test_completed.connect(_on_test_completed)
		test_bot.all_tests_completed.connect(_on_all_tests_completed)

func run_all_tests():
	"""Run all tests"""
	if is_running:
		print("⚠️  Tests already running!")
		return
	
	if not test_bot:
		print("❌ TestBot not found!")
		return
	
	print("🚀 Starting comprehensive testing...")
	is_running = true
	test_bot.start_comprehensive_testing()

func run_ui_tests():
	"""Run only UI tests"""
	if is_running:
		print("⚠️  Tests already running!")
		return
	
	if not test_bot:
		print("❌ TestBot not found!")
		return
	
	print("🧪 Running UI tests...")
	is_running = true
	test_bot.run_ui_system_tests()

func run_system_tests():
	"""Run only system tests"""
	if is_running:
		print("⚠️  Tests already running!")
		return
	
	if not test_bot:
		print("❌ TestBot not found!")
		return
	
	print("🧪 Running system tests...")
	is_running = true
	test_bot.run_game_system_tests()

func run_error_tests():
	"""Run only error handling tests"""
	if is_running:
		print("⚠️  Tests already running!")
		return
	
	if not test_bot:
		print("❌ TestBot not found!")
		return
	
	print("🧪 Running error handling tests...")
	is_running = true
	test_bot.run_error_handling_tests()

func _on_test_completed(test_name: String, result: bool, details: String):
	"""Handle individual test completion"""
	test_completed.emit(test_name, result)
	
	if result:
		print("✅ " + test_name + ": " + details)
	else:
		print("❌ " + test_name + ": " + details)

func _on_all_tests_completed(results: Dictionary):
	"""Handle all tests completion"""
	is_running = false
	all_tests_completed.emit(results)
	
	print("\n🎉 All tests completed!")
	print("📊 Results:")
	var passed = 0
	var failed = 0
	
	for test_name in results:
		if results[test_name].success:
			passed += 1
		else:
			failed += 1
	
	print("  ✅ Passed: " + str(passed))
	print("  ❌ Failed: " + str(failed))
	print("  📈 Success Rate: " + str(int((float(passed) / results.size()) * 100)) + "%")

# Console commands for manual testing
func _input(event):
	if event.is_action_pressed("ui_accept"):  # Enter key
		run_all_tests()
	elif event.is_action_pressed("ui_select"):  # Space key
		run_ui_tests()
	elif event.is_action_pressed("ui_focus_next"):  # Tab key
		run_system_tests()
	elif event.is_action_pressed("ui_focus_prev"):  # Shift+Tab key
		run_error_tests() 
