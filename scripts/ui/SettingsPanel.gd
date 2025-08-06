extends Panel

# Settings Panel - Handles game settings UI
# Manages audio, graphics, gameplay, and accessibility settings

signal settings_applied
signal settings_reset
signal settings_closed

@onready var tab_container = $SettingsContainer/TabContainer
@onready var apply_button = $SettingsContainer/ButtonContainer/ApplyButton
@onready var reset_button = $SettingsContainer/ButtonContainer/ResetButton
@onready var close_button = $SettingsContainer/ButtonContainer/CloseButton

# Audio settings
@onready var master_volume_slider = $SettingsContainer/TabContainer/Audio/MasterVolume/Slider
@onready var music_volume_slider = $SettingsContainer/TabContainer/Audio/MusicVolume/Slider
@onready var sfx_volume_slider = $SettingsContainer/TabContainer/Audio/SFXVolume/Slider

# Graphics settings
@onready var fullscreen_checkbox = $SettingsContainer/TabContainer/Graphics/Fullscreen
@onready var vsync_checkbox = $SettingsContainer/TabContainer/Graphics/VSync
@onready var max_fps_spinbox = $SettingsContainer/TabContainer/Graphics/MaxFPS/SpinBox

# Gameplay settings
@onready var text_speed_slider = $SettingsContainer/TabContainer/Gameplay/TextSpeed/Slider
@onready var show_damage_numbers_checkbox = $SettingsContainer/TabContainer/Gameplay/ShowDamageNumbers
@onready var show_health_bars_checkbox = $SettingsContainer/TabContainer/Gameplay/ShowHealthBars

# Accessibility settings
@onready var high_contrast_checkbox = $SettingsContainer/TabContainer/Accessibility/HighContrast
@onready var large_text_checkbox = $SettingsContainer/TabContainer/Accessibility/LargeText
@onready var color_blind_mode_option = $SettingsContainer/TabContainer/Accessibility/ColorBlindMode/OptionButton

var game_manager: Node
var settings

func _ready():
	# Connect button signals
	apply_button.pressed.connect(_on_apply_button_pressed)
	reset_button.pressed.connect(_on_reset_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	
	# Get references
	game_manager = get_node("/root/GameManager")
	if game_manager:
		settings = game_manager.settings
	
	# Load current settings
	load_current_settings()
	
	# Initially hide the panel
	hide()

func load_current_settings():
	"""Load current settings into the UI"""
	if not settings:
		return
	
	# Audio settings
	master_volume_slider.value = settings.master_volume
	music_volume_slider.value = settings.music_volume
	sfx_volume_slider.value = settings.sfx_volume
	
	# Graphics settings
	fullscreen_checkbox.button_pressed = settings.fullscreen
	vsync_checkbox.button_pressed = settings.vsync
	max_fps_spinbox.value = settings.max_fps
	
	# Gameplay settings
	text_speed_slider.value = settings.text_speed
	show_damage_numbers_checkbox.button_pressed = settings.show_damage_numbers
	show_health_bars_checkbox.button_pressed = settings.show_health_bars
	
	# Accessibility settings
	high_contrast_checkbox.button_pressed = settings.high_contrast
	large_text_checkbox.button_pressed = settings.large_text
	
	# Set color blind mode
	match settings.color_blind_mode:
		"none": color_blind_mode_option.selected = 0
		"protanopia": color_blind_mode_option.selected = 1
		"deuteranopia": color_blind_mode_option.selected = 2
		"tritanopia": color_blind_mode_option.selected = 3

func save_current_settings():
	"""Save current UI settings to the settings object"""
	if not settings:
		return
	
	# Audio settings
	settings.master_volume = master_volume_slider.value
	settings.music_volume = music_volume_slider.value
	settings.sfx_volume = sfx_volume_slider.value
	
	# Graphics settings
	settings.fullscreen = fullscreen_checkbox.button_pressed
	settings.vsync = vsync_checkbox.button_pressed
	settings.max_fps = int(max_fps_spinbox.value)
	
	# Gameplay settings
	settings.text_speed = text_speed_slider.value
	settings.show_damage_numbers = show_damage_numbers_checkbox.button_pressed
	settings.show_health_bars = show_health_bars_checkbox.button_pressed
	
	# Accessibility settings
	settings.high_contrast = high_contrast_checkbox.button_pressed
	settings.large_text = large_text_checkbox.button_pressed
	
	# Set color blind mode
	match color_blind_mode_option.selected:
		0: settings.color_blind_mode = "none"
		1: settings.color_blind_mode = "protanopia"
		2: settings.color_blind_mode = "deuteranopia"
		3: settings.color_blind_mode = "tritanopia"
	
	# Save settings to file
	settings.save_settings()
	
	# Apply settings
	settings.apply_settings()

func _on_apply_button_pressed():
	"""Handle apply button press"""
	save_current_settings()
	settings_applied.emit()
	print("Settings applied and saved")

func _on_reset_button_pressed():
	"""Handle reset button press"""
	if settings:
		settings.reset_to_defaults()
		load_current_settings()
		settings_reset.emit()
		print("Settings reset to defaults")

func _on_close_button_pressed():
	"""Handle close button press"""
	hide()
	settings_closed.emit()

func show_settings_panel():
	"""Show the settings panel"""
	show()
	load_current_settings()

func hide_settings_panel():
	"""Hide the settings panel"""
	hide() 
