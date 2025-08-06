extends Resource
class_name GameSettings

# Game Settings - Handles game configuration and user preferences
# Manages audio, graphics, controls, and other game settings

# Audio settings
@export var master_volume: float = 1.0
@export var music_volume: float = 0.8
@export var sfx_volume: float = 0.9
@export var voice_volume: float = 1.0

# Graphics settings
@export var fullscreen: bool = false
@export var vsync: bool = true
@export var max_fps: int = 60
@export var render_scale: float = 1.0

# Gameplay settings
@export var text_speed: float = 1.0
@export var auto_save_interval: int = 5  # minutes
@export var combat_speed: float = 1.0
@export var show_damage_numbers: bool = true
@export var show_health_bars: bool = true

# UI settings
@export var ui_scale: float = 1.0
@export var show_tooltips: bool = true
@export var show_minimap: bool = true
@export var show_quest_markers: bool = true

# Control settings
@export var mouse_sensitivity: float = 1.0
@export var invert_mouse_y: bool = false
@export var key_bindings: Dictionary = {}

# Accessibility settings
@export var color_blind_mode: String = "none"  # "none", "protanopia", "deuteranopia", "tritanopia"
@export var high_contrast: bool = false
@export var large_text: bool = false
@export var screen_reader: bool = false

# Debug settings
@export var debug_mode: bool = false
@export var show_fps: bool = false
@export var show_debug_info: bool = false
@export var god_mode: bool = false

# Save/Load settings
var settings_file_path: String = "user://settings.cfg"

func _init():
	load_settings()

func save_settings():
	"""Save current settings to file"""
	var config = ConfigFile.new()
	
	# Audio settings
	config.set_value("Audio", "master_volume", master_volume)
	config.set_value("Audio", "music_volume", music_volume)
	config.set_value("Audio", "sfx_volume", sfx_volume)
	config.set_value("Audio", "voice_volume", voice_volume)
	
	# Graphics settings
	config.set_value("Graphics", "fullscreen", fullscreen)
	config.set_value("Graphics", "vsync", vsync)
	config.set_value("Graphics", "max_fps", max_fps)
	config.set_value("Graphics", "render_scale", render_scale)
	
	# Gameplay settings
	config.set_value("Gameplay", "text_speed", text_speed)
	config.set_value("Gameplay", "auto_save_interval", auto_save_interval)
	config.set_value("Gameplay", "combat_speed", combat_speed)
	config.set_value("Gameplay", "show_damage_numbers", show_damage_numbers)
	config.set_value("Gameplay", "show_health_bars", show_health_bars)
	
	# UI settings
	config.set_value("UI", "ui_scale", ui_scale)
	config.set_value("UI", "show_tooltips", show_tooltips)
	config.set_value("UI", "show_minimap", show_minimap)
	config.set_value("UI", "show_quest_markers", show_quest_markers)
	
	# Control settings
	config.set_value("Controls", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("Controls", "invert_mouse_y", invert_mouse_y)
	config.set_value("Controls", "key_bindings", key_bindings)
	
	# Accessibility settings
	config.set_value("Accessibility", "color_blind_mode", color_blind_mode)
	config.set_value("Accessibility", "high_contrast", high_contrast)
	config.set_value("Accessibility", "large_text", large_text)
	config.set_value("Accessibility", "screen_reader", screen_reader)
	
	# Debug settings
	config.set_value("Debug", "debug_mode", debug_mode)
	config.set_value("Debug", "show_fps", show_fps)
	config.set_value("Debug", "show_debug_info", show_debug_info)
	config.set_value("Debug", "god_mode", god_mode)
	
	# Save to file
	var error = config.save(settings_file_path)
	if error != OK:
		print("Failed to save settings: %d" % error)
	else:
		print("Settings saved successfully")

func load_settings():
	"""Load settings from file"""
	var config = ConfigFile.new()
	var error = config.load(settings_file_path)
	
	if error != OK:
		print("No settings file found, creating with defaults")
		# Create settings file with default values on first run
		save_settings()
		return
	
	# Audio settings
	master_volume = config.get_value("Audio", "master_volume", 1.0)
	music_volume = config.get_value("Audio", "music_volume", 0.8)
	sfx_volume = config.get_value("Audio", "sfx_volume", 0.9)
	voice_volume = config.get_value("Audio", "voice_volume", 1.0)
	
	# Graphics settings
	fullscreen = config.get_value("Graphics", "fullscreen", false)
	vsync = config.get_value("Graphics", "vsync", true)
	max_fps = config.get_value("Graphics", "max_fps", 60)
	render_scale = config.get_value("Graphics", "render_scale", 1.0)
	
	# Gameplay settings
	text_speed = config.get_value("Gameplay", "text_speed", 1.0)
	auto_save_interval = config.get_value("Gameplay", "auto_save_interval", 5)
	combat_speed = config.get_value("Gameplay", "combat_speed", 1.0)
	show_damage_numbers = config.get_value("Gameplay", "show_damage_numbers", true)
	show_health_bars = config.get_value("Gameplay", "show_health_bars", true)
	
	# UI settings
	ui_scale = config.get_value("UI", "ui_scale", 1.0)
	show_tooltips = config.get_value("UI", "show_tooltips", true)
	show_minimap = config.get_value("UI", "show_minimap", true)
	show_quest_markers = config.get_value("UI", "show_quest_markers", true)
	
	# Control settings
	mouse_sensitivity = config.get_value("Controls", "mouse_sensitivity", 1.0)
	invert_mouse_y = config.get_value("Controls", "invert_mouse_y", false)
	key_bindings = config.get_value("Controls", "key_bindings", {})
	
	# Accessibility settings
	color_blind_mode = config.get_value("Accessibility", "color_blind_mode", "none")
	high_contrast = config.get_value("Accessibility", "high_contrast", false)
	large_text = config.get_value("Accessibility", "large_text", false)
	screen_reader = config.get_value("Accessibility", "screen_reader", false)
	
	# Debug settings
	debug_mode = config.get_value("Debug", "debug_mode", false)
	show_fps = config.get_value("Debug", "show_fps", false)
	show_debug_info = config.get_value("Debug", "show_debug_info", false)
	god_mode = config.get_value("Debug", "god_mode", false)
	
	print("Settings loaded successfully")

func reset_to_defaults():
	"""Reset all settings to default values"""
	master_volume = 1.0
	music_volume = 0.8
	sfx_volume = 0.9
	voice_volume = 1.0
	
	fullscreen = false
	vsync = true
	max_fps = 60
	render_scale = 1.0
	
	text_speed = 1.0
	auto_save_interval = 5
	combat_speed = 1.0
	show_damage_numbers = true
	show_health_bars = true
	
	ui_scale = 1.0
	show_tooltips = true
	show_minimap = true
	show_quest_markers = true
	
	mouse_sensitivity = 1.0
	invert_mouse_y = false
	key_bindings = {}
	
	color_blind_mode = "none"
	high_contrast = false
	large_text = false
	screen_reader = false
	
	debug_mode = false
	show_fps = false
	show_debug_info = false
	god_mode = false
	
	save_settings()
	print("Settings reset to defaults")

func apply_settings():
	"""Apply current settings to the game"""
	# Apply audio settings with safety checks
	var master_bus_idx = AudioServer.get_bus_index("Master")
	if master_bus_idx >= 0:
		AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(master_volume))
	
	var music_bus_idx = AudioServer.get_bus_index("Music")
	if music_bus_idx >= 0:
		AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(music_volume))
	
	var sfx_bus_idx = AudioServer.get_bus_index("SFX")
	if sfx_bus_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(sfx_volume))
	
	var voice_bus_idx = AudioServer.get_bus_index("Voice")
	if voice_bus_idx >= 0:
		AudioServer.set_bus_volume_db(voice_bus_idx, linear_to_db(voice_volume))
	
	# Apply graphics settings
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED)
	
	# Apply FPS limit
	Engine.max_fps = max_fps
	
	# Apply render scale
	# Note: get_viewport() not available in Resource class
	# This will need to be handled by the calling Node
	
	print("Settings applied successfully")

func get_audio_settings() -> Dictionary:
	"""Get all audio settings as a dictionary"""
	return {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"voice_volume": voice_volume
	}

func get_graphics_settings() -> Dictionary:
	"""Get all graphics settings as a dictionary"""
	return {
		"fullscreen": fullscreen,
		"vsync": vsync,
		"max_fps": max_fps,
		"render_scale": render_scale
	}

func get_gameplay_settings() -> Dictionary:
	"""Get all gameplay settings as a dictionary"""
	return {
		"text_speed": text_speed,
		"auto_save_interval": auto_save_interval,
		"combat_speed": combat_speed,
		"show_damage_numbers": show_damage_numbers,
		"show_health_bars": show_health_bars
	}

func get_ui_settings() -> Dictionary:
	"""Get all UI settings as a dictionary"""
	return {
		"ui_scale": ui_scale,
		"show_tooltips": show_tooltips,
		"show_minimap": show_minimap,
		"show_quest_markers": show_quest_markers
	}

func get_control_settings() -> Dictionary:
	"""Get all control settings as a dictionary"""
	return {
		"mouse_sensitivity": mouse_sensitivity,
		"invert_mouse_y": invert_mouse_y,
		"key_bindings": key_bindings
	}

func get_accessibility_settings() -> Dictionary:
	"""Get all accessibility settings as a dictionary"""
	return {
		"color_blind_mode": color_blind_mode,
		"high_contrast": high_contrast,
		"large_text": large_text,
		"screen_reader": screen_reader
	}

func get_debug_settings() -> Dictionary:
	"""Get all debug settings as a dictionary"""
	return {
		"debug_mode": debug_mode,
		"show_fps": show_fps,
		"show_debug_info": show_debug_info,
		"god_mode": god_mode
	}

func set_key_binding(action_name: String, key_code: int):
	"""Set a key binding for a specific action"""
	key_bindings[action_name] = key_code
	save_settings()

func get_key_binding(action_name: String) -> int:
	"""Get the key code for a specific action"""
	return key_bindings.get(action_name, 0)

func is_key_bound(key_code: int) -> bool:
	"""Check if a key is bound to any action"""
	return key_bindings.values().has(key_code) 
