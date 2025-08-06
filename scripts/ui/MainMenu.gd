extends Control
class_name MainMenu

# Simple Main Menu - Using existing scene buttons

signal new_game_started()
signal game_loaded(slot_number: int)
signal settings_opened()
# signal credits_opened()  # Unused signal - commented out
signal quit_game()

# UI References - Using existing scene buttons
@onready var title_label: Label = $VBoxContainer/Title
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var load_button: Button = $VBoxContainer/LoadButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var background_panel: ColorRect = $Background

func _ready():
	"""Initialize the main menu"""
	print("MainMenu: Initialized")
	
	# Connect button signals
	if start_button:
		start_button.pressed.connect(_on_start_button_pressed)
		print("MainMenu: Start button connected")
	if load_button:
		load_button.pressed.connect(_on_load_button_pressed)
		print("MainMenu: Load button connected")
	if settings_button:
		settings_button.pressed.connect(_on_settings_button_pressed)
		print("MainMenu: Settings button connected")
	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)
		print("MainMenu: Quit button connected")
	
	print("MainMenu: All buttons connected")

func _on_start_button_pressed():
	"""Handle start button press"""
	new_game_started.emit()
	print("MainMenu: New game started")

func _on_load_button_pressed():
	"""Handle load button press"""
	print("MainMenu: Load game pressed")
	# For now, just emit the signal
	game_loaded.emit(0)

func _on_settings_button_pressed():
	"""Handle settings button press"""
	settings_opened.emit()
	print("MainMenu: Settings opened")

func _on_quit_button_pressed():
	"""Handle quit button press"""
	quit_game.emit()
	print("MainMenu: Quit game requested")

func _notification(what):
	"""Handle application notifications"""
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game.emit() 
