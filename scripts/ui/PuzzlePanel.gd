extends Panel

# Puzzle Panel - Handles puzzle UI and logic
# Manages various types of puzzles with different mechanics

signal puzzle_solved(puzzle_id: String, rewards: Dictionary)
signal puzzle_closed

@onready var puzzle_grid = $PuzzleContainer/PuzzleGrid
@onready var progress_label = $PuzzleContainer/ProgressLabel
@onready var hint_label = $PuzzleContainer/HintLabel
@onready var reset_button = $PuzzleContainer/ButtonContainer/ResetButton
@onready var hint_button = $PuzzleContainer/ButtonContainer/HintButton
@onready var solve_button = $PuzzleContainer/ButtonContainer/SolveButton
@onready var close_button = $PuzzleContainer/ButtonContainer/CloseButton

var current_puzzle_id: String = ""
var puzzle_data: Dictionary = {}
var selected_symbols: Array[String] = []
var correct_sequence: Array[String] = []
var puzzle_type: String = "symbol_sequence"
var hints_used: int = 0
var max_hints: int = 3

func _ready():
	# Connect button signals
	reset_button.pressed.connect(_on_reset_button_pressed)
	hint_button.pressed.connect(_on_hint_button_pressed)
	solve_button.pressed.connect(_on_solve_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	
	# Connect symbol button signals
	for i in range(1, 10):
		var symbol_button = puzzle_grid.get_child(i - 1)
		if symbol_button:
			symbol_button.pressed.connect(_on_symbol_button_pressed.bind(i))
	
	# Initially hide the panel
	hide()

func initialize_puzzle(puzzle_id: String, puzzle_info: Dictionary):
	"""Initialize a puzzle with the given data"""
	current_puzzle_id = puzzle_id
	puzzle_data = puzzle_info
	puzzle_type = puzzle_info.get("type", "symbol_sequence")
	
	# Reset puzzle state
	selected_symbols.clear()
	hints_used = 0
	
	# Set up correct sequence based on puzzle type
	match puzzle_type:
		"symbol_sequence":
			correct_sequence = puzzle_info.get("correct_sequence", ["☀", "☽", "★", "⚡", "❄", "🔥", "🌊", "🌍", "⚔"])
		"pattern_matching":
			correct_sequence = puzzle_info.get("correct_sequence", ["☀", "☽", "★"])
		"element_combination":
			correct_sequence = puzzle_info.get("correct_sequence", ["🔥", "🌊", "⚡"])
	
	# Update UI
	update_progress_display()
	update_hint_display()

func _on_symbol_button_pressed(symbol_index: int):
	"""Handle symbol button press"""
	var symbol_button = puzzle_grid.get_child(symbol_index - 1)
	if symbol_button:
		var symbol = symbol_button.text
		
		if symbol in selected_symbols:
			# Remove symbol if already selected
			selected_symbols.erase(symbol)
			symbol_button.modulate = Color.WHITE
		else:
			# Add symbol if not already selected
			selected_symbols.append(symbol)
			symbol_button.modulate = Color.YELLOW
		
		update_progress_display()
		check_puzzle_completion()

func update_progress_display():
	"""Update the progress display"""
	progress_label.text = "Progress: %d/%d symbols placed" % [selected_symbols.size(), correct_sequence.size()]

func update_hint_display():
	"""Update the hint display"""
	var hints_remaining = max_hints - hints_used
	hint_label.text = "Hints remaining: %d" % hints_remaining

func check_puzzle_completion():
	"""Check if the puzzle is completed correctly"""
	if selected_symbols.size() == correct_sequence.size():
		var is_correct = true
		for i in range(selected_symbols.size()):
			if selected_symbols[i] != correct_sequence[i]:
				is_correct = false
				break
		
		if is_correct:
			puzzle_solved.emit(current_puzzle_id, puzzle_data.get("rewards", {}))
			print("Puzzle solved successfully!")
			hide()
		else:
			print("Puzzle sequence incorrect")

func _on_reset_button_pressed():
	"""Handle reset button press"""
	selected_symbols.clear()
	
	# Reset symbol button appearances
	for i in range(puzzle_grid.get_child_count()):
		var symbol_button = puzzle_grid.get_child(i)
		if symbol_button:
			symbol_button.modulate = Color.WHITE
	
	update_progress_display()

func _on_hint_button_pressed():
	"""Handle hint button press"""
	if hints_used < max_hints:
		hints_used += 1
		update_hint_display()
		
		# Provide a hint based on puzzle type
		match puzzle_type:
			"symbol_sequence":
				var hint_index = min(hints_used - 1, correct_sequence.size() - 1)
				var hint_symbol = correct_sequence[hint_index]
				print("Hint: The %dth symbol should be %s" % [hint_index + 1, hint_symbol])
			"pattern_matching":
				print("Hint: Look for patterns in the ancient texts")
			"element_combination":
				print("Hint: Combine opposing elements")
	else:
		print("No hints remaining")

func _on_solve_button_pressed():
	"""Handle solve button press"""
	# Auto-solve the puzzle
	selected_symbols = correct_sequence.duplicate()
	
	# Update symbol button appearances
	for i in range(puzzle_grid.get_child_count()):
		var symbol_button = puzzle_grid.get_child(i)
		if symbol_button and i < selected_symbols.size():
			symbol_button.modulate = Color.GREEN
	
	update_progress_display()
	check_puzzle_completion()

func _on_close_button_pressed():
	"""Handle close button press"""
	hide()
	puzzle_closed.emit()

func show_puzzle_panel():
	"""Show the puzzle panel"""
	show()

func hide_puzzle_panel():
	"""Hide the puzzle panel"""
	hide()

func get_puzzle_difficulty() -> String:
	"""Get the difficulty of the current puzzle"""
	return puzzle_data.get("difficulty", "easy")

func get_puzzle_rewards() -> Dictionary:
	"""Get the rewards for solving the puzzle"""
	return puzzle_data.get("rewards", {}) 