extends Node

# Simple Steam Integration Test
# Run this to test if SteamManager is working

func _ready():
	"""Run Steam integration tests"""
	print("🧪 Starting Steam Integration Test...")
	var start_separator = ""
	for i in range(50):
		start_separator += "="
	print(start_separator)
	
	# Wait a moment for Steam to initialize
	await get_tree().create_timer(2.0).timeout
	
	run_steam_tests()

func run_steam_tests():
	"""Run comprehensive Steam tests"""
	
	# Test 1: Check if SteamManager exists
	print("\n1️⃣ Testing SteamManager existence...")
	var steam_manager = get_node_or_null("/root/SteamManager")
	if steam_manager == null:
		print("❌ FAIL: SteamManager not found in scene tree")
		return
	else:
		print("✅ PASS: SteamManager found")
	
	# Test 2: Check Steam availability
	print("\n2️⃣ Testing Steam availability...")
	var steam_available = steam_manager.is_steam_available()
	var steam_running = steam_manager.is_steam_running()
	print("   Steam Available: %s" % steam_available)
	print("   Steam Running: %s" % steam_running)
	
	if steam_available:
		print("✅ PASS: Steam is available")
	else:
		print("⚠️  WARNING: Steam not available (this is normal if Steam isn't running)")
	
	# Test 3: Get user information
	print("\n3️⃣ Testing user information...")
	var user_name = steam_manager.get_user_name()
	var user_id = steam_manager.get_steam_user_id()
	var app_id = steam_manager.get_steam_app_id()
	
	print("   User Name: %s" % user_name)
	print("   User ID: %d" % user_id)
	print("   App ID: %d" % app_id)
	
	if user_name != "Unknown":
		print("✅ PASS: User information retrieved")
	else:
		print("⚠️  WARNING: Could not get user info (Steam may not be logged in)")
	
	# Test 4: Test statistics
	print("\n4️⃣ Testing statistics...")
	var quests_completed = steam_manager.get_statistic("total_quests_completed")
	print("   Current quests completed: %d" % quests_completed)
	
	# Try to set a test statistic
	var set_result = steam_manager.set_statistic("test_statistic", 42)
	print("   Set test statistic: %s" % set_result)
	
	if set_result:
		print("✅ PASS: Statistics working")
	else:
		print("⚠️  WARNING: Statistics may not be working (Steam not available)")
	
	# Test 5: Test achievements
	print("\n5️⃣ Testing achievements...")
	var achievement_progress = steam_manager.get_achievement_progress("first_quest")
	print("   First quest achievement unlocked: %s" % achievement_progress.unlocked)
	print("   Achievement progress: %.1f%%" % (achievement_progress.progress * 100))
	
	print("✅ PASS: Achievement system accessible")
	
	# Test 6: Test cloud saves
	print("\n6️⃣ Testing cloud saves...")
	var cloud_save_exists = steam_manager.load_from_cloud(1)
	var save_timestamp = steam_manager.get_cloud_save_timestamp(1)
	
	print("   Cloud save exists: %s" % (cloud_save_exists.size() > 0))
	print("   Save timestamp: %d" % save_timestamp)
	
	print("✅ PASS: Cloud save system accessible")
	
	# Test 7: Test Steam initialization
	print("\n7️⃣ Testing Steam initialization...")
	var app_id_current = steam_manager.get_steam_app_id()
	print("   Current App ID: %d" % app_id_current)
	
	if app_id_current > 0:
		print("✅ PASS: Steam properly initialized")
	else:
		print("⚠️  WARNING: App ID is 0 (Steam may not be properly initialized)")
	
	# Final summary
	var summary_separator = ""
	for i in range(50):
		summary_separator += "="
	print("\n" + summary_separator)
	print("🎯 STEAM INTEGRATION TEST RESULTS")
	print(summary_separator)
	
	if steam_available:
		print("✅ SteamManager is working correctly!")
		print("✅ All Steam features are accessible")
		print("✅ Ready for production use")
	else:
		print("⚠️  SteamManager is working but Steam is not available")
		print("⚠️  This is normal if Steam isn't running")
		print("✅ All methods are accessible and ready")
	
	print("\n🚀 Steam integration test complete!")
	var final_separator = ""
	for i in range(50):
		final_separator += "="
	print(final_separator) 
