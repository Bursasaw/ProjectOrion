extends Node
class_name QuantumAI

# Quantum-Inspired AI System
# Implements quantum mechanics concepts for advanced AI decision making

# signal quantum_state_measured(state_key: String, result: String)  # Unused signal - commented out
signal superposition_created(actions: Array, probabilities: Array)
signal entanglement_formed(actors: Array, correlation_strength: float)
signal quantum_collapse_triggered(selected_action: CombatAction, reasoning: String)

# Quantum States
enum QuantumState { SUPERPOSITION, ENTANGLED, COLLAPSED, COHERENT, DECOHERENT }
enum MeasurementType { POSITION, MOMENTUM, ENERGY, SPIN, PHASE }

# Quantum Configuration
var quantum_state: QuantumState = QuantumState.SUPERPOSITION
var measurement_type: MeasurementType = MeasurementType.POSITION
var superposition_threshold: float = 0.3
var entanglement_threshold: float = 0.3  # Lowered from 0.7 for testing
var decoherence_rate: float = 0.1
var quantum_noise: float = 0.05

# Quantum Memory
var quantum_memory: Dictionary = {}
var superposition_states: Array = []
var entangled_pairs: Array = []
var quantum_history: Array = []

# Performance Optimization
var max_superposition_states: int = 10
var max_entangled_pairs: int = 5
var memory_cleanup_interval: int = 50
var quantum_calculations_per_frame: int = 100

# Quantum Statistics
var measurements_taken: int = 0
var superpositions_created: int = 0
var entanglements_formed: int = 0
var quantum_collapses: int = 0

func _init():
	"""Initialize quantum AI system immediately"""
	initialize_quantum_memory()

func _ready():
	"""Initialize quantum AI system"""
	print("QuantumAI: Initialized")

func initialize_quantum_memory():
	"""Initialize quantum memory structures"""
	quantum_memory = {
		"superposition_cache": {"default": "initialized"},
		"entanglement_cache": {"default": "initialized"},
		"measurement_cache": {"default": "initialized"},
		"quantum_states": {"default": "initialized"},
		"correlation_matrix": {"default": "initialized"},
		"initialized": true,
		"version": "1.0",
		"test_data": "quantum_memory_ready"
	}

func create_quantum_decision(actor: CombatActor, available_actions: Array, enemies: Array) -> CombatAction:
	"""Create a quantum-inspired decision"""
	print("QuantumAI: Creating quantum decision for %s" % actor.character_name)
	
	# Create superposition of possible actions
	var superposition = create_superposition(available_actions, enemies)
	
	# Apply quantum interference
	apply_quantum_interference(superposition)
	
	# Create entanglement with other actors
	create_entanglement(actor, enemies)
	
	# Measure quantum state to collapse to final decision
	var measured_action = measure_quantum_state(superposition)
	
	# Record quantum event
	record_quantum_event("decision_made", {
		"actor": actor.character_name,
		"superposition_size": superposition.size(),
		"measured_action": measured_action.name,
		"quantum_state": quantum_state
	})
	
	return measured_action

func create_superposition(actions: Array, enemies: Array) -> Array:
	"""Create a superposition of possible actions with quantum probabilities"""
	var superposition = []
	
	for action in actions:
		var quantum_probability = calculate_quantum_probability(action, enemies)
		var quantum_amplitude = sqrt(quantum_probability)
		
		var state_data = {
			"action": action,
			"probability": quantum_probability,
			"amplitude": quantum_amplitude,
			"phase": randf() * 2 * PI,
			"coherence": 1.0
		}
		
		superposition.append(state_data)
	
	# Normalize probabilities
	normalize_superposition(superposition)
	
	# Add quantum noise
	add_quantum_noise(superposition)
	
	# Re-normalize after noise to ensure probabilities sum to 1.0
	normalize_superposition(superposition)
	
	superposition_states.append(superposition)
	superpositions_created += 1
	
	# Emit signal
	var probabilities = []
	for state in superposition:
		probabilities.append(state["probability"])
	superposition_created.emit(actions, probabilities)
	
	print("QuantumAI: Created superposition with %d states" % superposition.size())
	return superposition

func calculate_quantum_probability(action: CombatAction, enemies: Array) -> float:
	"""Calculate quantum probability for an action"""
	var base_probability = 1.0 / enemies.size() if enemies.size() > 0 else 1.0
	
	# Apply quantum factors
	var quantum_factor = 1.0
	
	# Energy-based probability (action cost)
	var energy_factor = 1.0 - (action.get_action_cost() * 0.1)
	quantum_factor *= energy_factor
	
	# Momentum-based probability (action speed - using action_cost as proxy)
	var speed_factor = 1.0 - (action.action_cost * 0.1)  # Lower cost = faster
	var momentum_factor = 1.0 + (speed_factor * 0.05)
	quantum_factor *= momentum_factor
	
	# Spin-based probability (action type)
	var spin_factor = get_spin_factor(action)
	quantum_factor *= spin_factor
	
	# Phase-based probability (random quantum phase)
	var phase_factor = 0.8 + (randf() * 0.4)
	quantum_factor *= phase_factor
	
	return base_probability * quantum_factor

func get_spin_factor(action: CombatAction) -> float:
	"""Get quantum spin factor for action type"""
	match action.action_type:
		"attack":
			return 1.2  # Spin up
		"defend":
			return 0.8  # Spin down
		"heal":
			return 1.0  # Spin neutral
		"buff":
			return 1.1  # Spin up slightly
		"debuff":
			return 0.9  # Spin down slightly
		_:
			return 1.0

func normalize_superposition(superposition: Array):
	"""Normalize superposition probabilities"""
	var total_probability = 0.0
	
	for state in superposition:
		total_probability += state["probability"]
	
	if total_probability > 0:
		for state in superposition:
			state["probability"] /= total_probability
			state["amplitude"] = sqrt(state["probability"])

func add_quantum_noise(superposition: Array):
	"""Add quantum noise to superposition"""
	for state in superposition:
		var noise = (randf() - 0.5) * quantum_noise
		state["probability"] = max(0.0, state["probability"] + noise)
		state["coherence"] = max(0.0, state["coherence"] - quantum_noise)

func apply_quantum_interference(superposition: Array):
	"""Apply quantum interference between superposition states"""
	for i in range(superposition.size()):
		for j in range(i + 1, superposition.size()):
			var interference = calculate_interference(superposition[i], superposition[j])
			superposition[i]["probability"] += interference * 0.1
			superposition[j]["probability"] -= interference * 0.1

func calculate_interference(state1: Dictionary, state2: Dictionary) -> float:
	"""Calculate quantum interference between two states"""
	var phase_difference = state1["phase"] - state2["phase"]
	var amplitude_product = state1["amplitude"] * state2["amplitude"]
	var coherence_product = state1["coherence"] * state2["coherence"]
	
	return amplitude_product * coherence_product * cos(phase_difference)

func create_entanglement(actor: CombatActor, enemies: Array):
	"""Create quantum entanglement between actors"""
	for enemy in enemies:
		var correlation_strength = calculate_correlation(actor, enemy)
		
		if correlation_strength > entanglement_threshold:
			var entanglement = {
				"actor1": actor,
				"actor2": enemy,
				"correlation": correlation_strength,
				"entangled_actions": [],
				"creation_time": Time.get_time_dict_from_system()
			}
			
			entangled_pairs.append(entanglement)
			entanglements_formed += 1
			
			# Emit signal
			entanglement_formed.emit([actor, enemy], correlation_strength)
			
			print("QuantumAI: Created entanglement between %s and %s (strength: %.2f)" % [
				actor.character_name, enemy.character_name, correlation_strength
			])

func calculate_correlation(actor1: CombatActor, actor2: CombatActor) -> float:
	"""Calculate quantum correlation between two actors"""
	var correlation = 0.0
	
	# Health correlation
	var health_diff = abs(actor1.health_points - actor2.health_points) / max(actor1.max_health_points, actor2.max_health_points)
	correlation += (1.0 - health_diff) * 0.3
	
	# Distance correlation (if available)
	if actor1.has_method("get_position_vector") and actor2.has_method("get_position_vector"):
		var distance = actor1.get_position_vector().distance_to(actor2.get_position_vector())
		var max_distance = 1000.0  # Arbitrary max distance
		correlation += (1.0 - min(distance / max_distance, 1.0)) * 0.2
	
	# Action type correlation
	if actor1.has_method("get_last_action") and actor2.has_method("get_last_action"):
		var action1 = actor1.get_last_action()
		var action2 = actor2.get_last_action()
		if action1 and action2 and action1.action_type == action2.action_type:
			correlation += 0.3
	
	# Random quantum correlation
	correlation += randf() * 0.2
	
	return min(correlation, 1.0)

func measure_quantum_state(superposition: Array) -> CombatAction:
	"""Measure quantum state to collapse superposition"""
	measurements_taken += 1
	
	# Apply measurement uncertainty
	var measurement_uncertainty = randf() * 0.2 - 0.1
	
	# Select action based on quantum probabilities
	var random_value = randf() + measurement_uncertainty
	var cumulative_probability = 0.0
	
	for state in superposition:
		cumulative_probability += state["probability"]
		if random_value <= cumulative_probability:
			# Quantum collapse
			quantum_state = QuantumState.COLLAPSED
			quantum_collapses += 1
			
			# Emit signal
			quantum_collapse_triggered.emit(state["action"], "Quantum measurement: %.2f probability" % state["probability"])
			
			print("QuantumAI: Measured action %s with probability %.2f" % [state["action"].name, state["probability"]])
			return state["action"]
	
	# Fallback to highest probability action
	var best_state = superposition[0]
	for state in superposition:
		if state["probability"] > best_state["probability"]:
			best_state = state
	
	quantum_collapse_triggered.emit(best_state["action"], "Quantum fallback: highest probability")
	return best_state["action"]

func apply_quantum_effects(action: CombatAction, _actor: CombatActor, _target: CombatActor):
	"""Apply quantum effects to an action"""
	# Quantum tunneling (bypass defenses)
	var tunneling_probability = 0.1
	if randf() < tunneling_probability:
		action.quantum_tunneling = true
		print("QuantumAI: Quantum tunneling activated for %s" % action.name)
	
	# Quantum superposition damage (multiple damage instances)
	var superposition_damage = 0.05
	if randf() < superposition_damage:
		action.quantum_superposition = true
		print("QuantumAI: Quantum superposition damage for %s" % action.name)
	
	# Quantum entanglement (affects multiple targets)
	var entanglement_probability = 0.08
	if randf() < entanglement_probability:
		action.quantum_entanglement = true
		print("QuantumAI: Quantum entanglement for %s" % action.name)

func update_quantum_state():
	"""Update quantum state over time"""
	# Apply decoherence
	for state in superposition_states:
		for state_item in state:
			state_item["coherence"] = max(0.0, state_item["coherence"] - decoherence_rate * get_process_delta_time())
	
	# Clean up old quantum states
	cleanup_quantum_memory()
	
	# Update quantum statistics
	update_quantum_statistics()

func cleanup_quantum_memory():
	"""Clean up old quantum memory to optimize performance"""
	# Remove old superposition states
	if superposition_states.size() > max_superposition_states:
		superposition_states = superposition_states.slice(-max_superposition_states)
	
	# Remove old entangled pairs
	if entangled_pairs.size() > max_entangled_pairs:
		entangled_pairs = entangled_pairs.slice(-max_entangled_pairs)
	
	# Clean up quantum history periodically
	if quantum_history.size() > 100:
		quantum_history = quantum_history.slice(-50)

func update_quantum_statistics():
	"""Update quantum statistics"""
	var stats = {
		"measurements_taken": measurements_taken,
		"superpositions_created": superpositions_created,
		"entanglements_formed": entanglements_formed,
		"quantum_collapses": quantum_collapses,
		"current_superposition_states": superposition_states.size(),
		"current_entangled_pairs": entangled_pairs.size(),
		"quantum_state": quantum_state,
		"measurement_type": measurement_type
	}
	
	quantum_memory["statistics"] = stats

func get_quantum_statistics() -> Dictionary:
	"""Get current quantum statistics"""
	update_quantum_statistics()
	return quantum_memory.get("statistics", {})

func record_quantum_event(event_type: String, data: Dictionary):
	"""Record a quantum event for analysis"""
	var event = {
		"type": event_type,
		"data": data,
		"timestamp": Time.get_time_dict_from_system(),
		"quantum_state": quantum_state
	}
	
	quantum_history.append(event)

func save_quantum_data():
	"""Save quantum AI data"""
	var save_data = {
		"quantum_memory": quantum_memory,
		"superposition_states": superposition_states,
		"entangled_pairs": entangled_pairs,
		"quantum_history": quantum_history,
		"statistics": get_quantum_statistics()
	}
	
	return save_data

func load_quantum_data(data: Dictionary):
	"""Load quantum AI data"""
	if data.has("quantum_memory"):
		quantum_memory = data["quantum_memory"]
	if data.has("superposition_states"):
		superposition_states = data["superposition_states"]
	if data.has("entangled_pairs"):
		entangled_pairs = data["entangled_pairs"]
	if data.has("quantum_history"):
		quantum_history = data["quantum_history"]
	
	print("QuantumAI: Loaded quantum data")

func _process(_delta):
	"""Process quantum AI updates"""
	update_quantum_state() 
