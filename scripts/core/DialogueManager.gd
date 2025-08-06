extends Node
# class_name DialogueManager # Removed to avoid autoload conflict

# Dialogue Manager - Handles branching dialogue and character interactions
# Manages dialogue trees, character relationships, and conversation flow

signal dialogue_started(character_id: String)
signal dialogue_ended(character_id: String)
signal choice_made(choice_text: String, next_node: String)
signal relationship_changed(character_id: String, change: int)

# Dialogue state
var current_character: String = ""
var current_node: String = ""
var dialogue_active: bool = false
var dialogue_history: Array[Dictionary] = []

# Character relationships
var relationships: Dictionary = {}

# Dialogue data
var dialogue_data: Dictionary = {}

func _ready():
	"""Initialize dialogue manager"""
	load_dialogue_data()

func load_dialogue_data():
	"""Load dialogue data from JSON files"""
	var file = FileAccess.open("res://data/dialogue/characters.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		if parse_result == OK:
			dialogue_data = json.data
			print("Dialogue data loaded successfully")
		else:
			print("Failed to parse dialogue data")
		file.close()
	else:
		print("Failed to load dialogue data file")

func start_dialogue(character_id: String, node_id: String = "greeting"):
	"""Start a dialogue with a character"""
	if not dialogue_data.has(character_id):
		print("Character not found: ", character_id)
		return false
	
	current_character = character_id
	current_node = node_id
	dialogue_active = true
	
	# Initialize relationship if not exists
	if not relationships.has(character_id):
		relationships[character_id] = 0
	
	# Emit signal
	dialogue_started.emit(character_id)
	
	print("Started dialogue with ", character_id)
	return true

func get_current_dialogue() -> Dictionary:
	"""Get the current dialogue node"""
	if not dialogue_active or not dialogue_data.has(current_character):
		return {}
	
	var character = dialogue_data[current_character]
	if not character.has("dialogue") or not character["dialogue"].has(current_node):
		return {}
	
	return character["dialogue"][current_node]

func make_choice(choice_index: int):
	"""Make a choice in the current dialogue"""
	var current_dialogue = get_current_dialogue()
	if current_dialogue.is_empty():
		return
	
	if choice_index >= current_dialogue["choices"].size():
		print("Invalid choice index: ", choice_index)
		return
	
	var choice = current_dialogue["choices"][choice_index]
	
	# Update relationship
	if choice.has("relationship_change"):
		relationships[current_character] += choice["relationship_change"]
		relationship_changed.emit(current_character, choice["relationship_change"])
	
	# Handle quest giving
	if choice.has("quest_given"):
		var quest_manager = get_node("/root/QuestManager")
		if quest_manager:
			quest_manager.start_quest(choice["quest_given"])
			print("Quest given: ", choice["quest_given"])
	
	# Handle item giving
	if choice.has("items_given"):
		var game_manager = get_node("/root/GameManager")
		if game_manager and game_manager.inventory_manager:
			for item_id in choice["items_given"]:
				game_manager.inventory_manager.add_item(item_id, 1)
				print("Item given: ", item_id)
	
	# Handle gold giving
	if choice.has("gold_given"):
		var game_manager = get_node("/root/GameManager")
		if game_manager and game_manager.inventory_manager:
			game_manager.inventory_manager.add_gold(choice["gold_given"])
			print("Gold given: ", choice["gold_given"])
	
	# Handle shop system
	if choice.has("shop_items"):
		var game_manager = get_node("/root/GameManager")
		if game_manager and game_manager.inventory_manager:
			for item_id in choice["shop_items"]:
				game_manager.inventory_manager.add_item(item_id, 1)
				print("Shop item purchased: ", item_id)
	
	# Move to next node
	if choice.has("next_node"):
		current_node = choice["next_node"]
	else:
		end_dialogue()
	
	# Add to history
	dialogue_history.append({
		"character": current_character,
		"node": current_node,
		"choice": choice.get("text", ""),
		"timestamp": Time.get_unix_time_from_system()
	})
	
	# Emit signal
	choice_made.emit(choice.get("text", ""), choice.get("next_node", ""))
	
	print("Made choice: ", choice.get("text", ""))

func end_dialogue():
	"""End the current dialogue"""
	if dialogue_active:
		dialogue_active = false
		dialogue_ended.emit(current_character)
		print("Ended dialogue with ", current_character)

func get_current_choices() -> Array[Dictionary]:
	"""Get choices from the current dialogue node"""
	var current_dialogue = get_current_dialogue()
	if current_dialogue.is_empty():
		return []
	
	var choices: Array[Dictionary] = []
	for choice in current_dialogue.get("choices", []):
		if choice is Dictionary:
			choices.append(choice)
	
	return choices

func get_relationship(character_id: String) -> int:
	"""Get relationship value with a character"""
	return relationships.get(character_id, 0)

func set_relationship(character_id: String, value: int):
	"""Set relationship value with a character"""
	relationships[character_id] = value

func get_dialogue_history() -> Array[Dictionary]:
	"""Get dialogue history"""
	return dialogue_history

func load_dialogue_history(history_data: Array):
	"""Load dialogue history from save data"""
	dialogue_history.clear()
	for entry in history_data:
		if entry is Dictionary:
			dialogue_history.append(entry)

func is_dialogue_active() -> bool:
	"""Check if dialogue is currently active"""
	return dialogue_active

func get_current_character() -> String:
	"""Get the current character ID"""
	return current_character

func get_current_node() -> String:
	"""Get the current dialogue node ID"""
	return current_node

func get_character_info(character_id: String) -> Dictionary:
	"""Get character information from dialogue data"""
	if dialogue_data.has(character_id):
		return dialogue_data[character_id]
	return {} 