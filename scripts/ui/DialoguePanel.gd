extends Control
class_name DialoguePanel

# Dialogue Panel - Handles dialogue UI interactions
# Manages dialogue display, choices, and user interactions

signal dialogue_choice_made(choice_index: int)
signal dialogue_closed()

@onready var character_name_label: Label = $DialogueContainer/CharacterName
@onready var dialogue_text: RichTextLabel = $DialogueContainer/DialogueText
@onready var choices_container: VBoxContainer = $DialogueContainer/ChoicesContainer
@onready var continue_button: Button = $DialogueContainer/ContinueButton
@onready var close_button: Button = $CloseButton

var dialogue_manager: Node
var current_choices: Array = []

func _ready():
	"""Initialize dialogue panel"""
	# Connect signals
	continue_button.pressed.connect(_on_continue_pressed)
	close_button.pressed.connect(_on_close_pressed)
	
	# Connect choice buttons
	for i in range(4):
		var choice_button = choices_container.get_child(i)
		choice_button.pressed.connect(_on_choice_pressed.bind(i))
	
	# Hide initially
	visible = false

func set_dialogue_manager(manager: Node):
	"""Set the dialogue manager reference"""
	dialogue_manager = manager
	if dialogue_manager:
		dialogue_manager.dialogue_started.connect(_on_dialogue_started)
		dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
		dialogue_manager.choice_made.connect(_on_choice_made)

func _on_dialogue_started(_character_id: String):
	"""Handle dialogue start"""
	show()
	update_dialogue_display()

func _on_dialogue_ended(_character_id: String):
	"""Handle dialogue end"""
	hide()

func _on_choice_made(_choice_text: String, _next_node: String):
	"""Handle choice made"""
	update_dialogue_display()

func update_dialogue_display():
	"""Update the dialogue display with current dialogue"""
	if not dialogue_manager or not dialogue_manager.is_dialogue_active():
		return
	
	var current_dialogue = dialogue_manager.get_current_dialogue()
	if current_dialogue.is_empty():
		return
	
	# Update character name
	var character_info = dialogue_manager.get_character_info(dialogue_manager.get_current_character())
	if not character_info.is_empty():
		character_name_label.text = character_info.get("name", "Unknown")
	
	# Update dialogue text
	dialogue_text.text = current_dialogue.get("text", "")
	
	# Update choices
	current_choices = current_dialogue.get("choices", [])
	update_choice_buttons()
	
	# Show/hide continue button
	continue_button.visible = current_choices.is_empty()

func update_choice_buttons():
	"""Update the choice buttons"""
	for i in range(4):
		var choice_button = choices_container.get_child(i)
		if i < current_choices.size():
			choice_button.text = current_choices[i].get("text", "")
			choice_button.visible = true
		else:
			choice_button.visible = false

func _on_choice_pressed(choice_index: int):
	"""Handle choice button press"""
	if choice_index < current_choices.size():
		dialogue_manager.make_choice(choice_index)
		dialogue_choice_made.emit(choice_index)

func _on_continue_pressed():
	"""Handle continue button press"""
	# For dialogue without choices, just end the dialogue
	dialogue_manager.end_dialogue()

func _on_close_pressed():
	"""Handle close button press"""
	dialogue_manager.end_dialogue()
	dialogue_closed.emit()

func show_dialogue(character_id: String, node_id: String = "greeting"):
	"""Show dialogue for a character"""
	if dialogue_manager:
		dialogue_manager.start_dialogue(character_id, node_id)

func hide_dialogue():
	"""Hide the dialogue panel"""
	dialogue_manager.end_dialogue() 