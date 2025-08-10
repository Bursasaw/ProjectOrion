extends Node
class_name PerformanceOptimizer

# Performance Optimization System
# Optimizes AI systems for large-scale scenarios

# signal performance_optimized(optimization_type: String, improvement: float)  # Unused signal - commented out
signal memory_cleaned(cleaned_mb: float)
signal ai_systems_throttled(throttle_level: int)
signal performance_monitoring_started()

# Performance Configuration
var target_fps: int = 60
var max_ai_calculations_per_frame: int = 1000
var memory_threshold_mb: float = 512.0
var cpu_threshold_percent: float = 80.0
var optimization_enabled: bool = true

# Performance Monitoring
var current_fps: float = 60.0
var current_memory_mb: float = 0.0
var current_cpu_percent: float = 0.0
var frame_times: Array[float] = []
var memory_history: Array[float] = []
var cpu_history: Array[float] = []

# AI System Throttling
var ai_throttle_level: int = 0  # 0-5, where 0 is no throttling
var throttle_multipliers: Array[float] = [1.0, 0.8, 0.6, 0.4, 0.2, 0.1]
var ai_systems_active: Array[String] = []

# Optimization Strategies
var optimization_strategies: Dictionary = {
	"memory_cleanup": {"enabled": true, "interval": 5.0, "last_run": 0.0},
	"ai_throttling": {"enabled": true, "threshold": 0.8, "last_check": 0.0},
	"frame_skipping": {"enabled": true, "skip_threshold": 16.67, "last_skip": 0.0},
	"lod_system": {"enabled": true, "distance_threshold": 1000.0},
	"culling_system": {"enabled": true, "cull_distance": 2000.0}
}

# Statistics
var optimizations_performed: int = 0
var memory_cleaned_total: float = 0.0
var performance_improvements: Array[float] = []

func _ready():
	"""Initialize performance optimizer"""
	print("PerformanceOptimizer: Initialized")
	start_performance_monitoring()

func start_performance_monitoring():
	"""Start monitoring performance metrics"""
	performance_monitoring_started.emit()
	print("PerformanceOptimizer: Performance monitoring started")

func _process(delta):
	"""Process performance optimization"""
	if not optimization_enabled:
		return
	
	# Update performance metrics
	update_performance_metrics(delta)
	
	# Check for optimization needs
	check_optimization_needs()
	
	# Apply optimizations if needed
	apply_optimizations(delta)

func update_performance_metrics(delta):
	"""Update current performance metrics"""
	# Update FPS
	current_fps = 1.0 / delta if delta > 0 else 60.0
	frame_times.append(delta)
	if frame_times.size() > 60:
		frame_times.pop_front()
	
	# Update memory usage
	current_memory_mb = get_memory_usage_mb()
	memory_history.append(current_memory_mb)
	if memory_history.size() > 60:
		memory_history.pop_front()
	
	# Update CPU usage (estimated)
	current_cpu_percent = estimate_cpu_usage()
	cpu_history.append(current_cpu_percent)
	if cpu_history.size() > 60:
		cpu_history.pop_front()

func get_memory_usage_mb() -> float:
	"""Get current memory usage in MB"""
	# This is a simplified estimation
	var memory_usage = 0.0
	
	# Estimate based on active AI systems
	for system in ai_systems_active:
		memory_usage += 10.0  # Base memory per AI system
	
	# Add base memory usage
	memory_usage += 50.0
	
	return memory_usage

func estimate_cpu_usage() -> float:
	"""Estimate CPU usage percentage"""
	var cpu_usage = 0.0
	
	# Base CPU usage
	cpu_usage += 20.0
	
	# Add CPU usage based on AI systems
	for system in ai_systems_active:
		cpu_usage += 15.0
	
	# Add usage based on frame time
	if frame_times.size() > 0:
		var avg_frame_time = frame_times.reduce(func(a, b): return a + b) / frame_times.size()
		cpu_usage += (avg_frame_time * 1000.0) * 2.0
	
	return min(cpu_usage, 100.0)

func check_optimization_needs():
	"""Check if optimization is needed"""
	var needs_optimization = false
	
	# Check FPS
	if current_fps < target_fps * 0.8:
		needs_optimization = true
		print("PerformanceOptimizer: FPS below target (%.1f < %.1f)" % [current_fps, target_fps * 0.8])
	
	# Check memory
	if current_memory_mb > memory_threshold_mb:
		needs_optimization = true
		print("PerformanceOptimizer: Memory usage high (%.1f MB > %.1f MB)" % [current_memory_mb, memory_threshold_mb])
	
	# Check CPU
	if current_cpu_percent > cpu_threshold_percent:
		needs_optimization = true
		print("PerformanceOptimizer: CPU usage high (%.1f%% > %.1f%%)" % [current_cpu_percent, cpu_threshold_percent])
	
	if needs_optimization:
		increase_throttle_level()

func apply_optimizations(delta):
	"""Apply performance optimizations"""
	# Memory cleanup
	if optimization_strategies["memory_cleanup"]["enabled"]:
		var time_since_cleanup = Time.get_time_dict_from_system()["unix"] - optimization_strategies["memory_cleanup"]["last_run"]
		if time_since_cleanup > optimization_strategies["memory_cleanup"]["interval"]:
			perform_memory_cleanup()
			optimization_strategies["memory_cleanup"]["last_run"] = Time.get_time_dict_from_system()["unix"]
	
	# AI throttling
	if optimization_strategies["ai_throttling"]["enabled"]:
		var time_since_check = Time.get_time_dict_from_system()["unix"] - optimization_strategies["ai_throttling"]["last_check"]
		if time_since_check > 1.0:  # Check every second
			apply_ai_throttling()
			optimization_strategies["ai_throttling"]["last_check"] = Time.get_time_dict_from_system()["unix"]
	
	# Frame skipping
	if optimization_strategies["frame_skipping"]["enabled"]:
		apply_frame_skipping(delta)

func perform_memory_cleanup():
	"""Perform memory cleanup operations"""
	print("PerformanceOptimizer: Performing memory cleanup")
	
	var memory_before = current_memory_mb
	
	# Clean up AI system memory
	cleanup_ai_system_memory()
	
	# Clean up unused resources
	cleanup_unused_resources()
	
	# Force garbage collection
	force_garbage_collection()
	
	var memory_after = get_memory_usage_mb()
	var memory_freed = memory_before - memory_after
	
	memory_cleaned_total += memory_freed
	optimizations_performed += 1
	
	memory_cleaned.emit(memory_freed)
	print("PerformanceOptimizer: Memory cleanup completed (%.1f MB freed)" % memory_freed)

func cleanup_ai_system_memory():
	"""Clean up AI system memory"""
	# Check if we're in the scene tree before trying to access nodes
	if not is_inside_tree():
		print("PerformanceOptimizer: Not in scene tree, skipping AI system cleanup")
		return
	
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager:
		# Clean up AI system caches
		if combat_manager.has_method("get_combat_ai") and combat_manager.get_combat_ai():
			combat_manager.get_combat_ai().cleanup_memory()
		if combat_manager.has_method("get_reinforcement_learning_ai") and combat_manager.get_reinforcement_learning_ai():
			combat_manager.get_reinforcement_learning_ai().cleanup_memory()
		if combat_manager.has_method("get_team_coordination_ai") and combat_manager.get_team_coordination_ai():
			combat_manager.get_team_coordination_ai().cleanup_memory()
		if combat_manager.has_method("get_narrative_ai") and combat_manager.get_narrative_ai():
			combat_manager.get_narrative_ai().cleanup_memory()

func cleanup_unused_resources():
	"""Clean up unused resources"""
	# Clear unused materials (with null checks)
	var material_rid = RID()
	if material_rid != RID():
		RenderingServer.material_set_shader(material_rid, RID())
	
	# Clear unused meshes (with null checks)
	var mesh_rid = RID()
	if mesh_rid != RID():
		RenderingServer.mesh_clear(mesh_rid)

func force_garbage_collection():
	"""Force garbage collection"""
	# This is a simplified version - in a real implementation,
	# you would call the engine's garbage collection
	print("PerformanceOptimizer: Garbage collection triggered")

func apply_ai_throttling():
	"""Apply AI system throttling based on performance"""
	var throttle_multiplier = throttle_multipliers[ai_throttle_level]
	
	# Apply throttling to AI systems
	# Check if we're in the scene tree before trying to access nodes
	if not is_inside_tree():
		print("PerformanceOptimizer: Not in scene tree, skipping AI throttling")
		return
	
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager:
		if combat_manager.combat_ai:
			combat_manager.combat_ai.set_throttle_multiplier(throttle_multiplier)
		if combat_manager.reinforcement_learning_ai:
			combat_manager.reinforcement_learning_ai.set_throttle_multiplier(throttle_multiplier)
		if combat_manager.team_coordination_ai:
			combat_manager.team_coordination_ai.set_throttle_multiplier(throttle_multiplier)
		if combat_manager.narrative_ai:
			combat_manager.narrative_ai.set_throttle_multiplier(throttle_multiplier)
	
	ai_systems_throttled.emit(ai_throttle_level)
	print("PerformanceOptimizer: AI systems throttled to level %d (%.1fx)" % [ai_throttle_level, throttle_multiplier])

func apply_frame_skipping(delta):
	"""Apply frame skipping for performance"""
	var frame_time_ms = delta * 1000.0
	
	if frame_time_ms > optimization_strategies["frame_skipping"]["skip_threshold"]:
		# Skip some AI calculations
		skip_ai_calculations()
		print("PerformanceOptimizer: Frame skipping applied (%.1f ms)" % frame_time_ms)

func skip_ai_calculations():
	"""Skip some AI calculations to improve performance"""
	# Check if we're in the scene tree before trying to access nodes
	if not is_inside_tree():
		print("PerformanceOptimizer: Not in scene tree, skipping AI calculations")
		return
	
	var combat_manager = get_node_or_null("/root/CombatManager")
	if combat_manager:
		# Reduce AI calculation frequency
		combat_manager.set_ai_calculation_frequency(0.5)

func increase_throttle_level():
	"""Increase AI throttling level"""
	if ai_throttle_level < throttle_multipliers.size() - 1:
		ai_throttle_level += 1
		print("PerformanceOptimizer: Throttle level increased to %d" % ai_throttle_level)

func decrease_throttle_level():
	"""Decrease AI throttling level"""
	if ai_throttle_level > 0:
		ai_throttle_level -= 1
		print("PerformanceOptimizer: Throttle level decreased to %d" % ai_throttle_level)

func register_ai_system(system_name: String):
	"""Register an AI system for monitoring"""
	if not ai_systems_active.has(system_name):
		ai_systems_active.append(system_name)
		print("PerformanceOptimizer: Registered AI system: %s" % system_name)

func unregister_ai_system(system_name: String):
	"""Unregister an AI system from monitoring"""
	if ai_systems_active.has(system_name):
		ai_systems_active.erase(system_name)
		print("PerformanceOptimizer: Unregistered AI system: %s" % system_name)

func get_performance_statistics() -> Dictionary:
	"""Get current performance statistics"""
	var avg_fps = 0.0
	if frame_times.size() > 0:
		avg_fps = 1.0 / (frame_times.reduce(func(a, b): return a + b) / frame_times.size())
	
	var avg_memory = 0.0
	if memory_history.size() > 0:
		avg_memory = memory_history.reduce(func(a, b): return a + b) / memory_history.size()
	
	var avg_cpu = 0.0
	if cpu_history.size() > 0:
		avg_cpu = cpu_history.reduce(func(a, b): return a + b) / cpu_history.size()
	
	return {
		"current_fps": current_fps,
		"average_fps": avg_fps,
		"current_memory_mb": current_memory_mb,
		"average_memory_mb": avg_memory,
		"current_cpu_percent": current_cpu_percent,
		"average_cpu_percent": avg_cpu,
		"ai_throttle_level": ai_throttle_level,
		"optimizations_performed": optimizations_performed,
		"memory_cleaned_total": memory_cleaned_total,
		"ai_systems_active": ai_systems_active.size()
	}

func set_optimization_enabled(enabled: bool):
	"""Enable or disable performance optimization"""
	optimization_enabled = enabled
	print("PerformanceOptimizer: Optimization %s" % ("enabled" if enabled else "disabled"))

func set_target_fps(fps: int):
	"""Set target FPS for optimization"""
	target_fps = fps
	print("PerformanceOptimizer: Target FPS set to %d" % fps)

func set_memory_threshold(threshold_mb: float):
	"""Set memory threshold for optimization"""
	memory_threshold_mb = threshold_mb
	print("PerformanceOptimizer: Memory threshold set to %.1f MB" % threshold_mb)

func set_cpu_threshold(threshold_percent: float):
	"""Set CPU threshold for optimization"""
	cpu_threshold_percent = threshold_percent
	print("PerformanceOptimizer: CPU threshold set to %.1f%%" % threshold_percent)

func save_performance_data():
	"""Save performance optimization data"""
	var save_data = {
		"optimization_enabled": optimization_enabled,
		"target_fps": target_fps,
		"memory_threshold_mb": memory_threshold_mb,
		"cpu_threshold_percent": cpu_threshold_percent,
		"ai_throttle_level": ai_throttle_level,
		"optimizations_performed": optimizations_performed,
		"memory_cleaned_total": memory_cleaned_total,
		"ai_systems_active": ai_systems_active
	}
	
	return save_data

func load_performance_data(data: Dictionary):
	"""Load performance optimization data"""
	if data.has("optimization_enabled"):
		optimization_enabled = data["optimization_enabled"]
	if data.has("target_fps"):
		target_fps = data["target_fps"]
	if data.has("memory_threshold_mb"):
		memory_threshold_mb = data["memory_threshold_mb"]
	if data.has("cpu_threshold_percent"):
		cpu_threshold_percent = data["cpu_threshold_percent"]
	if data.has("ai_throttle_level"):
		ai_throttle_level = data["ai_throttle_level"]
	if data.has("optimizations_performed"):
		optimizations_performed = data["optimizations_performed"]
	if data.has("memory_cleaned_total"):
		memory_cleaned_total = data["memory_cleaned_total"]
	if data.has("ai_systems_active"):
		ai_systems_active = data["ai_systems_active"]
	
	print("PerformanceOptimizer: Loaded performance data") 