extends Node
class_name CombatManager

# Combat Manager - Handles turn-based combat system
# Manages combat state, actions, and integration with other systems

signal combat_started(player_actor, enemies)
signal combat_ended(result: String)
signal turn_started(actor)
signal action_performed(action, actor, target)
# signal actor_defeated(actor: CombatActor) # Removed - not currently used

# Combat state
var combat_active: bool = false
var current_turn: int = 0
var turn_order = []
var current_actor_index: int = 0

# Enhanced combat mechanics
var action_points_system: bool = true
var max_action_points: int = 3
var current_action_points: int = 3
var initiative_bonus: float = 0.0
var turn_timeout: float = 30.0  # Seconds per turn
var turn_timer: float = 0.0

# Combatants
var player_actor = null
var enemies = []

# Team synergy system
var team_synergies = {
	"warrior": {"attack_bonus": 2, "defense_bonus": 1},
	"mage": {"magic_attack_bonus": 3, "magic_defense_bonus": 2},
	"rogue": {"speed_bonus": 2, "critical_bonus": 0.05},
	"cleric": {"healing_bonus": 1.5, "magic_defense_bonus": 1}
}

# Combat environment
var environment: Dictionary = {}
var combat_history: Array[Dictionary] = []

# Surface management system
var surface_manager: SurfaceManager = null

# Cover management system
var cover_manager: CoverManager = null

# All-out attack management system
var all_out_attack_manager: AllOutAttackManager = null

# Equipment passive effects management system
var equipment_passive_manager: EquipmentPassiveManager = null

# Momentum and combo management system
var momentum_manager: MomentumManager = null

# Emotional state management system
var emotional_state_manager: EmotionalStateManager = null

# Dynamic terrain management system
var terrain_manager: TerrainManager = null

# Time manipulation management system
var time_manager: TimeManager = null

# Quantum superposition management system
var quantum_manager: QuantumManager = null

# Multidimensional combat management system
var dimension_manager: DimensionManager = null

# Chain reaction management system
var chain_reaction_manager: ChainReactionManager = null

# Turn meter management system
var turn_meter_manager: TurnMeterManager = null

# Mod management system
var mod_manager: ModManager = null

# Gear management system
var gear_manager: GearManager = null

# Ability cooldown management system
var ability_cooldown_manager: AbilityCooldownManager = null

# Faction synergy management system
var faction_synergy_manager: FactionSynergyManager = null

# Job class management system
var job_class_manager: JobClassManager = null

# AI Systems
var combat_ai: CombatAI = null
var reinforcement_learning_ai: ReinforcementLearningAI = null
var team_coordination_ai: TeamCoordinationAI = null
var narrative_ai: NarrativeAI = null
var quantum_ai: QuantumAI = null
var performance_optimizer: PerformanceOptimizer = null

# Weather and environmental effects
var current_weather: String = "clear"
var weather_effects = {
	"clear": {"fire_damage": 1.0, "ice_damage": 1.0, "lightning_damage": 1.0, "accuracy": 1.0},
	"rain": {"fire_damage": 0.5, "ice_damage": 1.0, "lightning_damage": 1.5, "accuracy": 0.9},
	"sun": {"fire_damage": 1.5, "ice_damage": 0.7, "lightning_damage": 1.0, "accuracy": 1.0},
	"storm": {"fire_damage": 0.3, "ice_damage": 1.0, "lightning_damage": 1.3, "accuracy": 0.8},
	"fog": {"fire_damage": 1.0, "ice_damage": 1.0, "lightning_damage": 1.0, "accuracy": 0.7}
}

# Combat results
var combat_result: String = ""
var combat_victories: int = 0  # Track total victories for achievements

# Elemental effectiveness matrix (Pokemon-style)
var elemental_effectiveness = {
	"fire": {
		"fire": 0.5,      # Fire vs Fire = 0.5x (resistant)
		"ice": 2.0,       # Fire vs Ice = 2.0x (super effective)
		"lightning": 1.0, # Fire vs Lightning = 1.0x (neutral)
		"water": 0.5,     # Fire vs Water = 0.5x (not very effective)
		"earth": 1.0,     # Fire vs Earth = 1.0x (neutral)
		"wind": 1.0,      # Fire vs Wind = 1.0x (neutral)
		"shadow": 1.5,    # Fire vs Shadow = 1.5x (effective)
		"light": 1.0,     # Fire vs Light = 1.0x (neutral)
		"void": 0.5,      # Fire vs Void = 0.5x (not very effective)
		"tech": 1.5       # Fire vs Tech = 1.5x (effective)
	},
	"ice": {
		"fire": 0.5,      # Ice vs Fire = 0.5x (not very effective)
		"ice": 0.5,       # Ice vs Ice = 0.5x (resistant)
		"lightning": 1.0, # Ice vs Lightning = 1.0x (neutral)
		"water": 1.5,     # Ice vs Water = 1.5x (effective)
		"earth": 1.5,     # Ice vs Earth = 1.5x (effective)
		"wind": 1.0,      # Ice vs Wind = 1.0x (neutral)
		"shadow": 1.0,    # Ice vs Shadow = 1.0x (neutral)
		"light": 1.0,     # Ice vs Light = 1.0x (neutral)
		"void": 1.0,      # Ice vs Void = 1.0x (neutral)
		"tech": 0.5       # Ice vs Tech = 0.5x (not very effective)
	},
	"lightning": {
		"fire": 1.0,      # Lightning vs Fire = 1.0x (neutral)
		"ice": 1.0,       # Lightning vs Ice = 1.0x (neutral)
		"lightning": 0.5, # Lightning vs Lightning = 0.5x (resistant)
		"water": 2.0,     # Lightning vs Water = 2.0x (super effective)
		"earth": 0.5,     # Lightning vs Earth = 0.5x (not very effective)
		"wind": 1.5,      # Lightning vs Wind = 1.5x (effective)
		"shadow": 1.0,    # Lightning vs Shadow = 1.0x (neutral)
		"light": 1.0,     # Lightning vs Light = 1.0x (neutral)
		"void": 1.5,      # Lightning vs Void = 1.5x (effective)
		"tech": 2.0       # Lightning vs Tech = 2.0x (super effective)
	},
	"water": {
		"fire": 2.0,      # Water vs Fire = 2.0x (super effective)
		"ice": 0.5,       # Water vs Ice = 0.5x (not very effective)
		"lightning": 0.5, # Water vs Lightning = 0.5x (not very effective)
		"water": 0.5,     # Water vs Water = 0.5x (resistant)
		"earth": 1.5,     # Water vs Earth = 1.5x (effective)
		"wind": 1.0,      # Water vs Wind = 1.0x (neutral)
		"shadow": 1.0,    # Water vs Shadow = 1.0x (neutral)
		"light": 1.0,     # Water vs Light = 1.0x (neutral)
		"void": 1.0,      # Water vs Void = 1.0x (neutral)
		"tech": 0.5       # Water vs Tech = 0.5x (not very effective)
	},
	"earth": {
		"fire": 1.0,      # Earth vs Fire = 1.0x (neutral)
		"ice": 0.5,       # Earth vs Ice = 0.5x (not very effective)
		"lightning": 1.5, # Earth vs Lightning = 1.5x (effective)
		"water": 0.5,     # Earth vs Water = 0.5x (not very effective)
		"earth": 0.5,     # Earth vs Earth = 0.5x (resistant)
		"wind": 1.5,      # Earth vs Wind = 1.5x (effective)
		"shadow": 1.0,    # Earth vs Shadow = 1.0x (neutral)
		"light": 1.0,     # Earth vs Light = 1.0x (neutral)
		"void": 1.0,      # Earth vs Void = 1.0x (neutral)
		"tech": 1.5       # Earth vs Tech = 1.5x (effective)
	},
	"wind": {
		"fire": 1.0,      # Wind vs Fire = 1.0x (neutral)
		"ice": 1.0,       # Wind vs Ice = 1.0x (neutral)
		"lightning": 0.5, # Wind vs Lightning = 0.5x (not very effective)
		"water": 1.0,     # Wind vs Water = 1.0x (neutral)
		"earth": 0.5,     # Wind vs Earth = 0.5x (not very effective)
		"wind": 0.5,      # Wind vs Wind = 0.5x (resistant)
		"shadow": 1.5,    # Wind vs Shadow = 1.5x (effective)
		"light": 1.0,     # Wind vs Light = 1.0x (neutral)
		"void": 1.0,      # Wind vs Void = 1.0x (neutral)
		"tech": 1.0       # Wind vs Tech = 1.0x (neutral)
	},
	"shadow": {
		"fire": 0.5,      # Shadow vs Fire = 0.5x (not very effective)
		"ice": 1.0,       # Shadow vs Ice = 1.0x (neutral)
		"lightning": 1.0, # Shadow vs Lightning = 1.0x (neutral)
		"water": 1.0,     # Shadow vs Water = 1.0x (neutral)
		"earth": 1.0,     # Shadow vs Earth = 1.0x (neutral)
		"wind": 0.5,      # Shadow vs Wind = 0.5x (not very effective)
		"shadow": 0.5,    # Shadow vs Shadow = 0.5x (resistant)
		"light": 2.0,     # Shadow vs Light = 2.0x (super effective)
		"void": 1.5,      # Shadow vs Void = 1.5x (effective)
		"tech": 1.0       # Shadow vs Tech = 1.0x (neutral)
	},
	"light": {
		"fire": 1.0,      # Light vs Fire = 1.0x (neutral)
		"ice": 1.0,       # Light vs Ice = 1.0x (neutral)
		"lightning": 1.0, # Light vs Lightning = 1.0x (neutral)
		"water": 1.0,     # Light vs Water = 1.0x (neutral)
		"earth": 1.0,     # Light vs Earth = 1.0x (neutral)
		"wind": 1.0,      # Light vs Wind = 1.0x (neutral)
		"shadow": 2.0,    # Light vs Shadow = 2.0x (super effective)
		"light": 0.5,     # Light vs Light = 0.5x (resistant)
		"void": 2.0,      # Light vs Void = 2.0x (super effective)
		"tech": 1.0       # Light vs Tech = 1.0x (neutral)
	},
	"void": {
		"fire": 1.5,      # Void vs Fire = 1.5x (effective)
		"ice": 1.0,       # Void vs Ice = 1.0x (neutral)
		"lightning": 0.5, # Void vs Lightning = 0.5x (not very effective)
		"water": 1.0,     # Void vs Water = 1.0x (neutral)
		"earth": 1.0,     # Void vs Earth = 1.0x (neutral)
		"wind": 1.0,      # Void vs Wind = 1.0x (neutral)
		"shadow": 0.5,    # Void vs Shadow = 0.5x (not very effective)
		"light": 0.5,     # Void vs Light = 0.5x (not very effective)
		"void": 0.5,      # Void vs Void = 0.5x (resistant)
		"tech": 1.5       # Void vs Tech = 1.5x (effective)
	},
	"tech": {
		"fire": 0.5,      # Tech vs Fire = 0.5x (not very effective)
		"ice": 1.5,       # Tech vs Ice = 1.5x (effective)
		"lightning": 0.5, # Tech vs Lightning = 0.5x (not very effective)
		"water": 1.5,     # Tech vs Water = 1.5x (effective)
		"earth": 0.5,     # Tech vs Earth = 0.5x (not very effective)
		"wind": 1.0,      # Tech vs Wind = 1.0x (neutral)
		"shadow": 1.0,    # Tech vs Shadow = 1.0x (neutral)
		"light": 1.0,     # Tech vs Light = 1.0x (neutral)
		"void": 0.5,      # Tech vs Void = 0.5x (not very effective)
		"tech": 0.5       # Tech vs Tech = 0.5x (resistant)
	}
}

# World-specific elemental affinities (from GDD worlds)
var world_elemental_affinities = {
	"nokturn": "shadow",      # Shadow Realm
	"elysion": "light",       # Cradle of the Ancients
	"sylithar": "fire",       # Desert of Glass (solar-based)
	"terra": "earth",         # Primal Heart
	"aethra": "wind",         # Skybound Archipelago
	"ombra": "void",          # Veiled Depths
	"krynn": "fire",          # Dragon Dominion
	"tauron": "tech",         # Nexus of Flesh and Machine
	"aelria": "light"         # Realm of Manifested Will
}

func _ready():
	"""Initialize combat manager"""
	print("Combat Manager initialized")
	
	# Initialize surface manager
	surface_manager = SurfaceManager.new()
	add_child(surface_manager)
	
	# Connect surface manager signals
	surface_manager.surface_applied.connect(_on_surface_applied)
	surface_manager.surface_removed.connect(_on_surface_removed)
	surface_manager.surface_effect_triggered.connect(_on_surface_effect_triggered)
	
	# Initialize cover manager
	cover_manager = CoverManager.new()
	add_child(cover_manager)
	
	# Connect cover manager signals
	cover_manager.cover_applied.connect(_on_cover_applied)
	cover_manager.cover_removed.connect(_on_cover_removed)
	cover_manager.cover_effect_triggered.connect(_on_cover_effect_triggered)
	
	# Initialize all-out attack manager
	all_out_attack_manager = AllOutAttackManager.new()
	add_child(all_out_attack_manager)
	
	# Connect all-out attack manager signals
	all_out_attack_manager.all_out_attack_triggered.connect(_on_all_out_attack_triggered)
	all_out_attack_manager.all_out_attack_completed.connect(_on_all_out_attack_completed)
	all_out_attack_manager.all_out_attack_condition_met.connect(_on_all_out_attack_condition_met)
	
	# Initialize equipment passive manager
	equipment_passive_manager = EquipmentPassiveManager.new()
	add_child(equipment_passive_manager)
	
	# Connect equipment passive manager signals
	equipment_passive_manager.passive_effect_applied.connect(_on_passive_effect_applied)
	equipment_passive_manager.passive_effect_removed.connect(_on_passive_effect_removed)
	equipment_passive_manager.passive_effect_triggered.connect(_on_passive_effect_triggered)
	
	# Initialize momentum manager
	momentum_manager = MomentumManager.new()
	add_child(momentum_manager)
	
	# Connect momentum manager signals
	momentum_manager.momentum_gained.connect(_on_momentum_gained)
	momentum_manager.momentum_spent.connect(_on_momentum_spent)
	momentum_manager.combo_triggered.connect(_on_combo_triggered)
	momentum_manager.momentum_state_changed.connect(_on_momentum_state_changed)
	
	# Initialize emotional state manager
	emotional_state_manager = EmotionalStateManager.new()
	add_child(emotional_state_manager)
	
	# Connect emotional state manager signals
	emotional_state_manager.emotional_state_changed.connect(_on_emotional_state_changed)
	emotional_state_manager.emotional_effect_applied.connect(_on_emotional_effect_applied)
	emotional_state_manager.emotional_narrative_triggered.connect(_on_emotional_narrative_triggered)
	
	# Initialize terrain manager
	terrain_manager = TerrainManager.new()
	add_child(terrain_manager)
	
	# Connect terrain manager signals
	terrain_manager.terrain_effect_applied.connect(_on_terrain_effect_applied)
	terrain_manager.terrain_narrative_triggered.connect(_on_terrain_narrative_triggered)
	terrain_manager.terrain_state_changed.connect(_on_terrain_state_changed)
	
	# Initialize time manager
	time_manager = TimeManager.new()
	add_child(time_manager)
	
	# Connect time manager signals
	time_manager.time_manipulation_triggered.connect(_on_time_manipulation_triggered)
	time_manager.time_narrative_triggered.connect(_on_time_narrative_triggered)
	time_manager.time_state_changed.connect(_on_time_state_changed)
	
	# Initialize quantum manager
	quantum_manager = QuantumManager.new()
	add_child(quantum_manager)
	
	# Connect quantum manager signals
	quantum_manager.quantum_state_triggered.connect(_on_quantum_state_triggered)
	quantum_manager.quantum_narrative_triggered.connect(_on_quantum_narrative_triggered)
	quantum_manager.quantum_collapse_triggered.connect(_on_quantum_collapse_triggered)
	
	# Initialize dimension manager
	dimension_manager = DimensionManager.new()
	add_child(dimension_manager)
	
	# Connect dimension manager signals
	dimension_manager.dimension_shift_triggered.connect(_on_dimension_shift_triggered)
	dimension_manager.dimension_narrative_triggered.connect(_on_dimension_narrative_triggered)
	dimension_manager.dimension_merge_triggered.connect(_on_dimension_merge_triggered)
	
	# Initialize chain reaction manager
	chain_reaction_manager = ChainReactionManager.new()
	add_child(chain_reaction_manager)
	
	# Connect chain reaction manager signals
	chain_reaction_manager.chain_reaction_triggered.connect(_on_chain_reaction_triggered)
	chain_reaction_manager.chain_narrative_triggered.connect(_on_chain_narrative_triggered)
	chain_reaction_manager.chain_cascade_triggered.connect(_on_chain_cascade_triggered)

	# Initialize turn meter manager
	turn_meter_manager = TurnMeterManager.new()
	add_child(turn_meter_manager)
	
	# Connect turn meter manager signals
	turn_meter_manager.turn_meter_changed.connect(_on_turn_meter_changed)
	turn_meter_manager.turn_meter_manipulation.connect(_on_turn_meter_manipulation)
	turn_meter_manager.turn_meter_speed_boost.connect(_on_turn_meter_speed_boost)

	# Initialize mod manager
	mod_manager = ModManager.new()
	add_child(mod_manager)
	
	# Connect mod manager signals
	mod_manager.mod_equipped.connect(_on_mod_equipped)
	mod_manager.mod_optimized.connect(_on_mod_optimized)
	mod_manager.mod_set_completed.connect(_on_mod_set_completed)

	# Initialize gear manager
	gear_manager = GearManager.new()
	add_child(gear_manager)
	
	# Connect gear manager signals
	gear_manager.gear_equipped.connect(_on_gear_equipped)
	gear_manager.gear_upgraded.connect(_on_gear_upgraded)
	gear_manager.gear_material_used.connect(_on_gear_material_used)

	# Initialize ability cooldown manager
	ability_cooldown_manager = AbilityCooldownManager.new()
	add_child(ability_cooldown_manager)
	
	# Connect ability cooldown manager signals
	ability_cooldown_manager.ability_used.connect(_on_ability_used)
	ability_cooldown_manager.cooldown_reduced.connect(_on_cooldown_reduced)
	ability_cooldown_manager.cooldown_reset.connect(_on_cooldown_reset)

	# Initialize faction synergy manager
	faction_synergy_manager = FactionSynergyManager.new()
	add_child(faction_synergy_manager)
	
	# Connect faction synergy manager signals
	faction_synergy_manager.faction_synergy_activated.connect(_on_faction_synergy_activated)
	faction_synergy_manager.faction_leader_bonus.connect(_on_faction_leader_bonus)
	faction_synergy_manager.faction_ability_triggered.connect(_on_faction_ability_triggered)

	# Initialize job class manager
	job_class_manager = JobClassManager.new()
	add_child(job_class_manager)
	
	# Connect job class manager signals
	job_class_manager.job_class_changed.connect(_on_job_class_changed)
	job_class_manager.job_ability_learned.connect(_on_job_ability_learned)
	job_class_manager.job_level_up.connect(_on_job_level_up)
	
	# Load combat statistics from save if available
	load_combat_statistics()

func load_combat_statistics():
	"""Load combat statistics from save data"""
	var save_system = get_node("/root/SaveSystem")
	if save_system:
		var save_data = save_system.get_save_info(1)
		if save_data.has("valid") and save_data["valid"]:
			var game_data = save_data.get("game_data", {})
			combat_victories = game_data.get("combat_victories", 0)
			print("CombatManager: Loaded %d combat victories" % combat_victories)

func save_combat_statistics():
	"""Save combat statistics to save data"""
	var save_system = get_node("/root/SaveSystem")
	if save_system:
		var save_data = save_system.get_save_info(1)
		if save_data.has("valid") and save_data["valid"]:
			var game_data = save_data.get("game_data", {})
			game_data["combat_victories"] = combat_victories
			save_data["game_data"] = game_data
			save_system.save_game(1, "Auto Save")
			print("CombatManager: Saved combat statistics")

func start_combat(player, enemy_list):
	"""Start a new combat encounter"""
	if combat_active:
		print("Combat already active")
		return
	
	# Set up combat
	player_actor = player
	enemies = enemy_list
	combat_active = true
	current_turn = 1
	combat_history.clear()
	
	# Initialize turn order
	initialize_turn_order()
	
	# Initialize all-out attack system
	if all_out_attack_manager:
		var current_world = "elysion"  # Default world, would come from GameManager
		all_out_attack_manager.initialize_all_out_system([player], current_world)
	
	# Apply team synergies
	calculate_team_synergies()
	
	# Set random weather (optional)
	var weather_types = ["clear", "rain", "sun", "storm", "fog"]
	var random_weather = weather_types[randi() % weather_types.size()]
	set_weather(random_weather)
	
	# Emit signal
	combat_started.emit(player_actor, enemies)
	
	print("Combat started with %d enemies (Weather: %s)" % [enemies.size(), current_weather])

func initialize_turn_order():
	"""Initialize the turn order based on initiative calculation"""
	turn_order.clear()
	turn_order.append(player_actor)
	turn_order.append_array(enemies)
	
	# Calculate initiative for each actor
	for actor in turn_order:
		actor.initiative = calculate_initiative(actor)
	
	# Sort by initiative (highest first)
	turn_order.sort_custom(func(a, b): return a.initiative > b.initiative)
	
	current_actor_index = 0
	current_action_points = max_action_points
	turn_timer = 0.0
	
	print("Turn order initialized with initiative-based sorting")
	for i in range(turn_order.size()):
		var actor = turn_order[i]
		print("  %d. %s (Initiative: %.1f)" % [i + 1, actor.character_name, actor.initiative])

func calculate_initiative(actor) -> float:
	"""Calculate initiative for an actor"""
	var base_initiative = actor.speed * 10.0
	var random_bonus = randf() * 5.0  # Small random factor
	var equipment_bonus = 0.0
	
	# Add equipment bonuses if available
	if actor.has_method("get_equipment_bonus"):
		equipment_bonus = actor.get_equipment_bonus("initiative")
	
	var total_initiative = base_initiative + random_bonus + equipment_bonus + initiative_bonus
	return total_initiative

func next_turn():
	"""Advance to the next turn"""
	if not combat_active:
		return
	
	# Check if combat is over
	if check_combat_end():
		return
	
	# Get current actor
	var current_actor = turn_order[current_actor_index]
	
	# Reset action points for new turn
	if action_points_system:
		current_action_points = max_action_points
	
	# Reset turn timer
	turn_timer = 0.0
	
	# Emit signal
	turn_started.emit(current_actor)
	
	# Handle actor turn
	if current_actor == player_actor:
		# Player turn - wait for input
		print("Player's turn - Action Points: %d/%d" % [current_action_points, max_action_points])
		start_player_turn()
	else:
		# AI turn
		perform_ai_turn(current_actor)
	
	# Advance to next actor
	current_actor_index += 1
	if current_actor_index >= turn_order.size():
		# End of round
		current_actor_index = 0
		current_turn += 1
		apply_turn_effects()
		print("Round %d completed" % current_turn)

func start_player_turn():
	"""Start the player's turn with action points"""
	print("Player turn started - %s can perform %d actions" % [player_actor.character_name, current_action_points])
	# This will be handled by the UI system

func can_perform_action(action_cost: int = 1) -> bool:
	"""Check if an action can be performed with current action points"""
	if not action_points_system:
		return true
	return current_action_points >= action_cost

func spend_action_points(cost: int = 1) -> bool:
	"""Spend action points for an action"""
	if not action_points_system:
		return true
	
	if current_action_points >= cost:
		current_action_points -= cost
		print("Action points spent: %d (remaining: %d)" % [cost, current_action_points])
		return true
	else:
		print("Not enough action points: need %d, have %d" % [cost, current_action_points])
		return false

func perform_ai_turn(actor):
	"""Perform AI turn for an enemy actor using advanced AI systems"""
	print("AI turn for: ", actor.character_name)
	
	# Initialize AI systems if not already done
	initialize_ai_systems()
	
	# Get available actions
	var available_actions = actor.get_available_actions()
	if available_actions.size() == 0:
		print("AI actor %s has no available actions" % actor.character_name)
		return
	
	# Get current combat situation
	var combat_situation = get_combat_situation(actor)
	
	# Use advanced AI to select action
	var selected_action = null
	var target = null
	var reasoning = ""
	
	# Try different AI systems based on situation
	if team_coordination_ai and is_team_member(actor):
		# Use team coordination AI for allied enemies
		var coordinated_actions = team_coordination_ai.coordinate_team_actions([player_actor])
		if coordinated_actions.has(actor):
			selected_action = coordinated_actions[actor]
			target = get_best_target_for_action(selected_action, [player_actor])
			reasoning = "Team coordination decision"
	
	elif reinforcement_learning_ai and has_learning_data(actor):
		# Use reinforcement learning AI
		selected_action = reinforcement_learning_ai.select_action_with_rl(combat_situation, available_actions)
		target = get_best_target_for_action(selected_action, [player_actor])
		reasoning = "Reinforcement learning decision"
	
	elif narrative_ai and has_narrative_context(actor):
		# Use narrative AI
		selected_action = select_narrative_action(actor, available_actions, [player_actor])
		target = get_best_target_for_action(selected_action, [player_actor])
		reasoning = "Narrative-driven decision"
	
	else:
		# Use basic combat AI
		selected_action = combat_ai.make_decision(actor, [player_actor], enemies)
		target = combat_ai.get_best_target(selected_action, [player_actor]) if selected_action else null
		reasoning = "Basic AI decision"
	
	# Apply narrative modifications
	if narrative_ai and selected_action and target:
		narrative_ai.modify_action_for_narrative(selected_action, actor, target)
	
	# Apply team coordination effects
	if team_coordination_ai and selected_action and target:
		team_coordination_ai.apply_team_coordination(selected_action, actor, target)
	
	# Perform the selected action
	if selected_action and target:
		perform_action(selected_action, actor, target)
		print("AI decision: %s chose %s on %s (%s)" % [actor.character_name, selected_action.name, target.character_name, reasoning])
	else:
		print("AI could not determine action for %s" % actor.character_name)

func initialize_ai_systems():
	"""Initialize all AI systems"""
	if not combat_ai:
		combat_ai = CombatAI.new()
		add_child(combat_ai)
		print("CombatAI initialized")
	
	if not reinforcement_learning_ai:
		reinforcement_learning_ai = ReinforcementLearningAI.new()
		add_child(reinforcement_learning_ai)
		print("ReinforcementLearningAI initialized")
	
	if not team_coordination_ai:
		team_coordination_ai = TeamCoordinationAI.new()
		add_child(team_coordination_ai)
		print("TeamCoordinationAI initialized")
	
	if not narrative_ai:
		narrative_ai = NarrativeAI.new()
		add_child(narrative_ai)
		print("NarrativeAI initialized")
	
	if not quantum_ai:
		quantum_ai = QuantumAI.new()
		add_child(quantum_ai)
		print("QuantumAI initialized")
	
	if not performance_optimizer:
		performance_optimizer = PerformanceOptimizer.new()
		add_child(performance_optimizer)
		print("PerformanceOptimizer initialized")
		
		# Register AI systems with performance optimizer
		performance_optimizer.register_ai_system("CombatAI")
		performance_optimizer.register_ai_system("ReinforcementLearningAI")
		performance_optimizer.register_ai_system("TeamCoordinationAI")
		performance_optimizer.register_ai_system("NarrativeAI")
		performance_optimizer.register_ai_system("QuantumAI")

func get_combat_situation(actor) -> Dictionary:
	"""Get current combat situation for AI decision making"""
	return {
		"self_health_ratio": float(actor.health_points) / float(actor.max_health_points),
		"enemies_alive": enemies.filter(func(e): return not e.is_defeated()).size(),
		"allies_alive": enemies.filter(func(e): return not e.is_defeated()).size(),
		"weather": current_weather,
		"surface_type": surface_manager.get_surface_type() if surface_manager else "normal",
		"turn_number": current_turn,
		"action_points_remaining": current_action_points
	}

func is_team_member(actor) -> bool:
	"""Check if actor is part of a coordinated team"""
	# Check if actor has team coordination data
	return actor.has_method("get_team_id") and actor.get_team_id() != ""

func has_learning_data(_actor) -> bool:
	"""Check if actor has reinforcement learning data"""
	if not reinforcement_learning_ai:
		return false
	
	var stats = reinforcement_learning_ai.get_rl_statistics()
	return stats["episodes_completed"] > 0

func has_narrative_context(_actor) -> bool:
	"""Check if actor has narrative context"""
	if not narrative_ai:
		return false
	
	var stats = narrative_ai.get_narrative_statistics()
	return stats["character_relationships"] > 0 or stats["current_quest"] != "None"

func select_narrative_action(actor, available_actions: Array, targets: Array) -> CombatAction:
	"""Select action based on narrative context"""
	if not narrative_ai:
		return available_actions[0] if available_actions.size() > 0 else null
	
	var best_action = null
	var best_score = -INF
	
	for action in available_actions:
		var score = 1.0
		
		# Calculate narrative score for each target
		for target in targets:
			var narrative_score = narrative_ai.calculate_narrative_score(action, actor, target)
			score = max(score, narrative_score)
		
		if score > best_score:
			best_score = score
			best_action = action
	
	return best_action

func get_best_target_for_action(action, targets: Array):
	"""Get the best target for an action"""
	if targets.size() == 0:
		return null
	elif targets.size() == 1:
		return targets[0]
	
	var best_target = targets[0]
	var best_score = -INF
	
	for target in targets:
		var score = 0.0
		
		# Health-based targeting
		var health_ratio = float(target.health_points) / float(target.max_health_points)
		if health_ratio < 0.3:
			score += 50  # Prioritize weak targets
		elif health_ratio < 0.6:
			score += 30
		
		# Elemental effectiveness
		if action.element != "" and target.has_method("get_elemental_affinity"):
			var target_element = target.get_elemental_affinity()
			var effectiveness = get_elemental_effectiveness(action.element, target_element)
			score += effectiveness * 20
		
		# Threat assessment
		score += target.attack * 0.5
		score += target.magic_attack * 0.3
		
		if score > best_score:
			best_score = score
			best_target = target
	
	return best_target

func perform_action(action, actor, target):
	"""Perform a combat action"""
	if not action.can_use(actor):
		print("Action cannot be used: ", action.name)
		return
	
	# Check action points for player actions
	if actor == player_actor and action_points_system:
		var action_cost = action.get_action_cost()
		if not can_perform_action(action_cost):
			print("Not enough action points for: ", action.name)
			return
	
	# Pay cost
	if not action.pay_cost(actor):
		print("Cannot pay action cost")
		return
	
	# Spend action points for player actions
	if actor == player_actor and action_points_system:
		var action_cost = action.get_action_cost()
		spend_action_points(action_cost)
	
	# Execute action
	var combat_action_script = load("res://scripts/core/CombatAction.gd")
	match action.action_type:
		combat_action_script.ActionType.ATTACK:
			execute_attack(action, actor, target)
		combat_action_script.ActionType.SPELL:
			execute_spell(action, actor, target)
		combat_action_script.ActionType.ITEM:
			execute_item_use(action, actor, target)
		combat_action_script.ActionType.BUFF:
			execute_buff(action, actor, target)
		combat_action_script.ActionType.DEBUFF:
			execute_debuff(action, actor, target)
	
	# Update cooldown
	action.update_cooldown()
	
	# Add to history
	combat_history.append({
		"turn": current_turn,
		"actor": actor.character_name,
		"action": action.name,
		"target": target.character_name
	})
	
	# Emit signal
	action_performed.emit(action, actor, target)
	
	print("Action performed: %s by %s on %s" % [action.name, actor.character_name, target.character_name])

func execute_attack(action, actor, target):
	"""Execute an attack action with critical hit system"""
	var base_damage = action.power + actor.attack - target.defense
	base_damage = max(1, base_damage)  # Minimum 1 damage
	
	# Critical hit calculation
	var is_critical = false
	var critical_multiplier = 1.5
	var critical_chance = action.critical_chance
	
	# Add actor's critical hit bonus if available
	if actor.has_method("get_critical_chance_bonus"):
		critical_chance += actor.get_critical_chance_bonus()
	
	if randf() < critical_chance:
		is_critical = true
		base_damage = int(base_damage * critical_multiplier)
	
	# Apply positioning effects
	if target.has_method("calculate_position_damage"):
		base_damage = target.calculate_position_damage(base_damage)
	
	# Apply weather effects
	base_damage = apply_weather_effects(base_damage, action.element)
	
	# Apply elemental effectiveness (Pokemon-style)
	base_damage = apply_elemental_effectiveness(base_damage, action.element, target)
	
	# Apply surface effects to damage
	base_damage = apply_surface_effects_to_damage(base_damage, action.element, target)
	
	# Apply cover effects to damage reduction
	base_damage = apply_cover_effects_to_damage(base_damage, target)
	
	target.take_damage(base_damage)
	
	# Apply surface effects to target location
	apply_surface_effects_to_target(action, target)
	
	if is_critical:
		print("💥 CRITICAL HIT! %s attacks %s for %d damage" % [actor.character_name, target.character_name, base_damage])
	else:
		print("%s attacks %s for %d damage" % [actor.character_name, target.character_name, base_damage])

func execute_spell(action, actor, target):
	"""Execute a spell action"""
	var damage = action.power + actor.magic_attack - target.magic_defense
	damage = max(1, damage)
	
	target.take_damage(damage)
	print("%s casts %s on %s for %d damage" % [actor.character_name, action.name, target.character_name, damage])

func execute_item_use(action, actor, _target):
	"""Execute an item use action"""
	if actor.player_data:
		action.item.use_item(actor.player_data)
		print("%s uses %s" % [actor.character_name, action.name])

func execute_buff(_action, actor, _target):
	"""Execute a buff action"""
	# Apply buff effects to the actor based on action properties
	# For now, apply basic buff effects based on action power
	actor.attack += _action.power
	actor.defense += int(_action.power / 2.0)
	
	# Add buff to actor's buff list
	actor.add_buff(_action.name, _action.power, _action.duration)
	print("%s casts %s buff" % [actor.character_name, _action.name])

func execute_debuff(_action, _actor, target):
	"""Execute a debuff action"""
	# Apply debuff effects to the target based on action properties
	# For now, apply basic debuff effects based on action power
	target.attack = max(1, target.attack - _action.power)
	target.defense = max(1, target.defense - int(_action.power / 2.0))
	
	# Add debuff to target's debuff list
	target.add_debuff(_action.name, _action.power, _action.duration)
	print("Debuff %s cast on %s" % [_action.name, target.character_name])

func apply_turn_effects():
	"""Apply end-of-turn effects to all actors"""
	for actor in turn_order:
		actor.apply_turn_effects()
	
	# Apply status condition effects
	apply_status_condition_effects()
	
	# Apply surface effects to all actors
	apply_surface_effects_to_actors()
	
	# Apply cover effects to all actors
	apply_cover_effects_to_actors()
	
	# Apply passive effects to all actors
	apply_passive_effects_to_all_actors()
	
	# Apply emotional effects to all actors
	apply_emotional_effects_to_all_actors()
	
	# Apply terrain effects to all actors
	apply_terrain_effects_to_all_actors()
	
	# Update surface durations
	if surface_manager:
		surface_manager.update_surface_durations()
	
	# Update cover durations
	if cover_manager:
		cover_manager.update_cover_durations()

func check_combat_end() -> bool:
	"""Check if combat has ended"""
	var player_defeated = player_actor.is_defeated()
	var all_enemies_defeated = true
	
	for enemy in enemies:
		if not enemy.is_defeated():
			all_enemies_defeated = false
			break
	
	if player_defeated:
		end_combat("defeat")
		return true
	elif all_enemies_defeated:
		end_combat("victory")
		return true
	
	return false

func end_combat(result: String):
	"""End the current combat"""
	combat_active = false
	combat_result = result
	
	# Calculate rewards
	var _rewards = calculate_rewards(result)
	
	# Track combat statistics and trigger achievements
	if result == "victory":
		combat_victories += 1
		save_combat_statistics()
		trigger_combat_achievements()
	
	# Emit signal
	combat_ended.emit(result)
	
	print("Combat ended: %s" % result)

func calculate_rewards(result: String) -> Dictionary:
	"""Calculate rewards based on combat result"""
	var rewards = {
		"experience": 0,
		"gold": 0,
		"items": []
	}
	
	if result == "victory":
		# Calculate rewards based on enemies defeated
		for enemy in enemies:
			if enemy.is_defeated():
				rewards["experience"] += enemy.experience_reward
				rewards["gold"] += enemy.gold_reward
				
				# Add enemy drops
				for item_id in enemy.item_drops:
					rewards["items"].append(item_id)
	
	return rewards

func get_current_actor():
	"""Get the current actor in turn order"""
	if turn_order.size() > 0 and current_actor_index >= 0 and current_actor_index < turn_order.size():
		return turn_order[current_actor_index]
	return null

func get_combat_state() -> Dictionary:
	"""Get current combat state"""
	return {
		"active": combat_active,
		"turn": current_turn,
		"current_actor": get_current_actor(),
		"player_health": player_actor.health_points if player_actor else 0,
		"enemies_alive": enemies.filter(func(e): return not e.is_defeated()).size()
	}

func get_combat_history() -> Array[Dictionary]:
	"""Get combat history"""
	return combat_history

func is_combat_active() -> bool:
	"""Check if combat is currently active"""
	return combat_active

func _process(delta):
	"""Process combat timing and turn management"""
	if not combat_active:
		return
	
	# Update turn timer for player turns
	var current_actor = get_current_actor()
	if current_actor == player_actor and action_points_system:
		turn_timer += delta
		
		# Auto-advance turn if timeout reached
		if turn_timer >= turn_timeout:
			print("Turn timeout reached - auto-advancing")
			advance_turn()

func advance_turn():
	"""Manually advance to the next turn (for UI integration)"""
	if not combat_active:
		return
	
	# Check if player has action points remaining
	if get_current_actor() == player_actor and current_action_points > 0:
		print("Player still has %d action points remaining" % current_action_points)
		return
	
	next_turn()

func get_action_points() -> int:
	"""Get current action points"""
	return current_action_points

func get_max_action_points() -> int:
	"""Get maximum action points"""
	return max_action_points

func get_turn_time_remaining() -> float:
	"""Get remaining time in current turn"""
	return max(0.0, turn_timeout - turn_timer)

func apply_weather_effects(base_damage: int, element: String) -> int:
	"""Apply weather effects to damage"""
	if not weather_effects.has(current_weather):
		return base_damage
	
	var weather = weather_effects[current_weather]
	var multiplier = 1.0
	
	# Apply element-specific weather effects
	match element:
		"fire":
			multiplier = weather.get("fire_damage", 1.0)
		"ice":
			multiplier = weather.get("ice_damage", 1.0)
		"lightning":
			multiplier = weather.get("lightning_damage", 1.0)
		_:
			multiplier = 1.0
	
	var modified_damage = int(base_damage * multiplier)
	
	if multiplier != 1.0:
		print("🌤️ Weather effect: %s damage modified by %.1fx (%s)" % [element, multiplier, current_weather])
	
	return modified_damage

func set_weather(weather_type: String):
	"""Set the current weather"""
	if weather_effects.has(weather_type):
		current_weather = weather_type
		print("🌤️ Weather changed to: %s" % current_weather)
	else:
		print("❌ Invalid weather type: %s" % weather_type)

func get_current_weather() -> String:
	"""Get current weather"""
	return current_weather

func get_weather_effects() -> Dictionary:
	"""Get current weather effects"""
	return weather_effects.get(current_weather, {})

func apply_elemental_effectiveness(base_damage: int, attack_element: String, target) -> int:
	"""Apply Pokemon-style elemental effectiveness"""
	if attack_element == "" or not elemental_effectiveness.has(attack_element):
		return base_damage
	
	# Get target's elemental affinity
	var target_element = target.elemental_affinity
	if target_element == "" or not elemental_effectiveness[attack_element].has(target_element):
		return base_damage
	
	# Get effectiveness multiplier
	var multiplier = elemental_effectiveness[attack_element][target_element]
	var modified_damage = int(base_damage * multiplier)
	
	# Add world affinity bonus if target is from a specific world
	if target.has_method("get_world_origin"):
		var world_origin = target.get_world_origin()
		if world_elemental_affinities.has(world_origin):
			var world_element = world_elemental_affinities[world_origin]
			if world_element == target_element:
				modified_damage = int(modified_damage * 1.2)  # 20% bonus for world affinity
				print("🌍 World affinity bonus applied!")
	
	# Print effectiveness message
	var effectiveness_msg = ""
	if multiplier >= 2.0:
		effectiveness_msg = "💥 It's super effective!"
	elif multiplier >= 1.5:
		effectiveness_msg = "⚡ It's effective!"
	elif multiplier <= 0.5:
		effectiveness_msg = "🛡️ It's not very effective..."
	
	if effectiveness_msg != "":
		print("%s (%s vs %s: %.1fx)" % [effectiveness_msg, attack_element, target_element, multiplier])
	
	return modified_damage

func calculate_team_synergies():
	"""Calculate and apply team synergy bonuses"""
	var class_counts = {}
	
	# Count characters by class
	for actor in turn_order:
		var character_class = actor.character_class.to_lower()
		if character_class not in class_counts:
			class_counts[character_class] = 0
		class_counts[character_class] += 1
	
	# Apply synergy bonuses
	for actor in turn_order:
		var character_class = actor.character_class.to_lower()
		
		if team_synergies.has(character_class) and class_counts[character_class] >= 2:
			var synergy = team_synergies[character_class]
			
			# Apply bonuses
			if synergy.has("attack_bonus"):
				actor.attack += synergy["attack_bonus"]
			if synergy.has("defense_bonus"):
				actor.defense += synergy["defense_bonus"]
			if synergy.has("magic_attack_bonus"):
				actor.magic_attack += synergy["magic_attack_bonus"]
			if synergy.has("magic_defense_bonus"):
				actor.magic_defense += synergy["magic_defense_bonus"]
			if synergy.has("speed_bonus"):
				actor.speed += synergy["speed_bonus"]
			
			print("🎯 Team synergy applied: %s gets %s bonuses" % [actor.character_name, character_class])

func apply_status_condition_effects():
	"""Apply status condition effects to all actors"""
	for actor in turn_order:
		if actor.has_method("apply_status_condition_effects"):
			actor.apply_status_condition_effects() 

func trigger_combat_achievements():
	"""Trigger Steam achievements for combat victories"""
	var steam_manager = get_node("/root/SteamManager")
	if not steam_manager:
		return
	
	# Combat Master achievement - win 10 battles
	if combat_victories >= 10:
		steam_manager.unlock_achievement("combat_master")
		print("SteamManager: Combat Master achievement triggered")
	
	# Progress tracking for combat achievements
	var progress = min(combat_victories / 10.0, 1.0)
	steam_manager.set_achievement_progress("combat_master", progress)
	print("SteamManager: Combat progress updated: %d/10" % combat_victories)

# Surface Management Methods
func apply_surface_effects_to_actors():
	"""Apply surface effects to all actors in combat"""
	if not surface_manager:
		return
	
	# For now, apply surface effects to all actors
	# In a real implementation, this would use actual positioning
	for actor in turn_order:
		if actor.has_method("get_position_vector"):
			var position = actor.get_position_vector()
			surface_manager.apply_surface_effects_to_actor(actor, position)
		elif actor.has_method("get_position"):
			# Fallback: convert string position to Vector2
			var pos_string = actor.get_position()
			var position = Vector2.ZERO
			match pos_string:
				"front":
					position = Vector2(0, 0)
				"back":
					position = Vector2(0, 1)
				_:
					position = Vector2(0, 0)
			surface_manager.apply_surface_effects_to_actor(actor, position)
		else:
			# Fallback: apply effects to actor at origin
			surface_manager.apply_surface_effects_to_actor(actor, Vector2.ZERO)

func apply_surface_to_location(surface_type: String, location: Vector2, duration: int = 3, source_world: String = ""):
	"""Apply a surface effect to a specific location"""
	if surface_manager:
		return surface_manager.apply_surface(surface_type, location, duration, source_world)
	return false

func get_surface_at_location(location: Vector2) -> Dictionary:
	"""Get surface data at a specific location"""
	if surface_manager:
		return surface_manager.get_surface_at_location(location)
	return {}

func get_surface_type_at_location(location: Vector2) -> String:
	"""Get surface type at a specific location"""
	if surface_manager:
		return surface_manager.get_surface_type_at_location(location)
	return ""

func get_elemental_bonus_for_surface(surface_type: String, element: String) -> float:
	"""Get elemental bonus for a surface type"""
	if surface_manager:
		return surface_manager.get_elemental_bonus_for_surface(surface_type, element)
	return 1.0

func get_surface_description(location: Vector2) -> String:
	"""Get rich description of surface at location"""
	if surface_manager:
		return surface_manager.get_surface_description(location)
	return ""

func get_surface_statistics() -> Dictionary:
	"""Get statistics about current surfaces"""
	if surface_manager:
		return surface_manager.get_surface_statistics()
	return {}

func clear_all_surfaces():
	"""Clear all active surfaces"""
	if surface_manager:
		surface_manager.clear_all_surfaces()

# Surface Manager Signal Handlers
func _on_surface_applied(surface_type: String, location: Vector2, description: String):
	"""Handle surface applied event"""
	print("CombatManager: Surface applied - %s at %s: %s" % [surface_type, str(location), description])
	
	# Update UI
	update_combat_ui_surface(location, surface_type)
	
	# Trigger achievements
	trigger_surface_achievement(surface_type)
	
	# Play sound effect
	play_surface_sound(surface_type)
	
	# Show visual effect
	show_surface_effect(location, surface_type)
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "surface_applied",
		"surface_type": surface_type,
		"location": location,
		"description": description
	})
	
	# Trigger narrative events
	trigger_surface_narrative(surface_type, location)

func _on_surface_removed(surface_type: String, location: Vector2):
	"""Handle surface removed event"""
	print("CombatManager: Surface removed - %s at %s" % [surface_type, str(location)])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "surface_removed",
		"surface_type": surface_type,
		"location": location
	})

func _on_surface_effect_triggered(surface_type: String, target, effect: String):
	"""Handle surface effect triggered event"""
	print("CombatManager: Surface effect - %s on %s: %s" % [surface_type, target.character_name, effect])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "surface_effect",
		"surface_type": surface_type,
		"target": target.character_name,
		"effect": effect
	})

func apply_surface_effects_to_damage(base_damage: int, element: String, target) -> int:
	"""Apply surface effects to damage calculation"""
	if not surface_manager:
		return base_damage
	
	# Get target's position as Vector2
	var target_position = Vector2.ZERO
	if target.has_method("get_position_vector"):
		target_position = target.get_position_vector()
	elif target.has_method("get_position"):
		# Fallback: convert string position to Vector2
		var pos_string = target.get_position()
		match pos_string:
			"front":
				target_position = Vector2(0, 0)
			"back":
				target_position = Vector2(0, 1)
			_:
				target_position = Vector2(0, 0)
	
	# Get surface at target location
	var surface_type = get_surface_type_at_location(target_position)
	if surface_type == "":
		return base_damage
	
	# Get elemental bonus for surface
	var elemental_bonus = get_elemental_bonus_for_surface(surface_type, element)
	if elemental_bonus != 1.0:
		base_damage = int(base_damage * elemental_bonus)
		print("🌊 Surface effect: %s damage modified by %.1fx (%s)" % [element, elemental_bonus, surface_type])
	
	return base_damage

func apply_surface_effects_to_target(action, target):
	"""Apply surface effects when attacking a target"""
	if not surface_manager:
		return
	
	# Get target's position as Vector2
	var target_position = Vector2.ZERO
	if target.has_method("get_position_vector"):
		target_position = target.get_position_vector()
	elif target.has_method("get_position"):
		# Fallback: convert string position to Vector2
		var pos_string = target.get_position()
		match pos_string:
			"front":
				target_position = Vector2(0, 0)
			"back":
				target_position = Vector2(0, 1)
			_:
				target_position = Vector2(0, 0)
	
	# Check if action creates surfaces
	if action.element == "fire":
		# Fire attacks can create fire surfaces
		if randf() < 0.3:  # 30% chance
			apply_surface_to_location("fire", target_position, 2)
	elif action.element == "ice":
		# Ice attacks can create ice surfaces
		if randf() < 0.25:  # 25% chance
			apply_surface_to_location("ice", target_position, 2)
	elif action.element == "lightning":
		# Lightning attacks can create electrified surfaces
		if randf() < 0.2:  # 20% chance
			apply_surface_to_location("electrified_water", target_position, 1)
	elif action.element == "void":
		# Void attacks can create void surfaces
		if randf() < 0.15:  # 15% chance
			apply_surface_to_location("void", target_position, 1)

func apply_cover_effects_to_damage(base_damage: int, target) -> int:
	"""Apply cover effects to damage calculation"""
	if not cover_manager:
		return base_damage
	
	# Get target's position as Vector2
	var target_position = Vector2.ZERO
	if target.has_method("get_position_vector"):
		target_position = target.get_position_vector()
	elif target.has_method("get_position"):
		# Fallback: convert string position to Vector2
		var pos_string = target.get_position()
		match pos_string:
			"front":
				target_position = Vector2(0, 0)
			"back":
				target_position = Vector2(0, 1)
			_:
				target_position = Vector2(0, 0)
	
	# Get cover at target location
	var cover_data = get_cover_at_location(target_position)
	if cover_data.has("defense") and cover_data["defense"] > 0:
		base_damage = max(1, base_damage - cover_data["defense"])
		print("🛡️ Cover effect: Damage reduced by %d (%s)" % [cover_data["defense"], cover_data.get("description", "Unknown cover")])
	
	return base_damage

# Cover system methods
func apply_cover_to_location(cover_type: String, location: Vector2, duration: int = -1, source_world: String = "") -> bool:
	"""Apply cover to a specific location"""
	if not cover_manager:
		return false
	return cover_manager.apply_cover_to_location(cover_type, location, duration, source_world)

func get_cover_at_location(location: Vector2) -> Dictionary:
	"""Get cover data at a specific location"""
	if not cover_manager:
		return {}
	return cover_manager.get_cover_at_location(location)

func apply_cover_effects_to_actors():
	"""Apply cover effects to all actors"""
	if not cover_manager:
		return
	
	# In a real implementation, this would use actual positioning
	for actor in turn_order:
		if actor.has_method("get_position_vector"):
			var position = actor.get_position_vector()
			cover_manager.apply_cover_effects_to_actor(actor, position)
		elif actor.has_method("get_position"):
			# Fallback: convert string position to Vector2
			var pos_string = actor.get_position()
			var position = Vector2.ZERO
			match pos_string:
				"front":
					position = Vector2(0, 0)
				"back":
					position = Vector2(0, 1)
				_:
					position = Vector2(0, 0)
			cover_manager.apply_cover_effects_to_actor(actor, position)
		else:
			# Default position
			cover_manager.apply_cover_effects_to_actor(actor, Vector2.ZERO)

func apply_passive_effects_to_all_actors():
	"""Apply passive effects to all actors"""
	if not equipment_passive_manager:
		return
	
	for actor in turn_order:
		equipment_passive_manager.apply_passive_effects_to_actor(actor)

func apply_emotional_effects_to_all_actors():
	"""Apply emotional effects to all actors"""
	if not emotional_state_manager:
		return
	
	for actor in turn_order:
		emotional_state_manager.apply_emotional_effects_to_actor(actor)

func apply_terrain_effects_to_all_actors():
	"""Apply terrain effects to all actors"""
	if not terrain_manager:
		return
	
	for actor in turn_order:
		terrain_manager.apply_terrain_effects_to_actor(actor)

func _on_cover_applied(cover_type: String, location: Vector2, description: String):
	"""Handle cover applied event"""
	print("CombatManager: Cover applied - %s at %s: %s" % [cover_type, str(location), description])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "cover_applied",
		"cover_type": cover_type,
		"location": location,
		"description": description
	})

func _on_cover_removed(cover_type: String, location: Vector2):
	"""Handle cover removed event"""
	print("CombatManager: Cover removed - %s at %s" % [cover_type, str(location)])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "cover_removed",
		"cover_type": cover_type,
		"location": location
	})

func _on_cover_effect_triggered(cover_type: String, target, effect: String):
	"""Handle cover effect triggered event"""
	print("CombatManager: Cover effect - %s on %s: %s" % [cover_type, target.character_name, effect])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "cover_effect",
		"cover_type": cover_type,
		"target": target.character_name,
		"effect": effect
	})

# All-out attack system methods
func initialize_all_out_attack_system(team: Array, world: String):
	"""Initialize the all-out attack system"""
	if all_out_attack_manager:
		all_out_attack_manager.initialize_all_out_system(team, world)

func check_all_out_attack_conditions() -> Array:
	"""Check which all-out attack conditions are met"""
	if not all_out_attack_manager:
		return []
	return all_out_attack_manager.check_all_out_conditions(enemies)

func trigger_all_out_attack(condition: String, base_damage: int) -> Dictionary:
	"""Trigger an all-out attack with the specified condition"""
	if not all_out_attack_manager:
		return {}
	return all_out_attack_manager.trigger_all_out_attack(condition, enemies, base_damage)

func get_available_all_out_attacks() -> Array:
	"""Get list of available all-out attack conditions"""
	if not all_out_attack_manager:
		return []
	return all_out_attack_manager.get_available_all_out_attacks(enemies)

func get_all_out_attack_info(condition: String) -> Dictionary:
	"""Get information about a specific all-out attack condition"""
	if not all_out_attack_manager:
		return {}
	return all_out_attack_manager.get_all_out_attack_info(condition)

func _on_all_out_attack_triggered(condition: String, damage_multiplier: float, description: String):
	"""Handle all-out attack triggered event"""
	print("CombatManager: All-out attack triggered - %s (%.1fx damage)" % [condition, damage_multiplier])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "all_out_attack_triggered",
		"condition": condition,
		"damage_multiplier": damage_multiplier,
		"description": description
	})

func _on_all_out_attack_completed(targets: Array, total_damage: int, narrative: String):
	"""Handle all-out attack completed event"""
	print("CombatManager: All-out attack completed - %d damage to %d targets" % [total_damage, targets.size()])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "all_out_attack_completed",
		"total_damage": total_damage,
		"targets_hit": targets.size(),
		"narrative": narrative
	})

func _on_all_out_attack_condition_met(condition: String, description: String):
	"""Handle all-out attack condition met event"""
	print("CombatManager: All-out attack condition met - %s" % condition)
	
	# Update UI
	update_combat_ui_all_out_attack(condition)
	
	# Trigger achievements
	trigger_all_out_attack_achievement(condition)
	
	# Play sound effect
	play_all_out_attack_sound(condition)
	
	# Show visual effect
	show_all_out_attack_effect(condition)
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "all_out_attack_condition_met",
		"condition": condition,
		"description": description
	})
	
	# Trigger narrative events
	trigger_all_out_attack_narrative(condition)

# Equipment passive effects system methods
func apply_passive_effect_to_item(item_name: String, effect_type: String, world: String = "") -> bool:
	"""Apply a passive effect to an item"""
	if not equipment_passive_manager:
		return false
	return equipment_passive_manager.apply_passive_effect_to_item(item_name, effect_type, world)

func remove_passive_effect_from_item(item_name: String) -> bool:
	"""Remove passive effect from an item"""
	if not equipment_passive_manager:
		return false
	return equipment_passive_manager.remove_passive_effect_from_item(item_name)

func get_passive_effect_for_item(item_name: String) -> Dictionary:
	"""Get passive effect data for an item"""
	if not equipment_passive_manager:
		return {}
	return equipment_passive_manager.get_passive_effect_for_item(item_name)

func apply_passive_effects_to_actor(actor) -> Dictionary:
	"""Apply all passive effects from equipped items to an actor"""
	if not equipment_passive_manager:
		return {}
	return equipment_passive_manager.apply_passive_effects_to_actor(actor)

func get_passive_effect_narrative(item_name: String) -> String:
	"""Get narrative description of passive effect for an item"""
	if not equipment_passive_manager:
		return "No passive effect"
	return equipment_passive_manager.get_passive_effect_narrative(item_name)

func get_passive_effect_description(item_name: String) -> String:
	"""Get description of passive effect for an item"""
	if not equipment_passive_manager:
		return "No passive effect"
	return equipment_passive_manager.get_passive_effect_description(item_name)

func _on_passive_effect_applied(effect_type: String, item_name: String, description: String):
	"""Handle passive effect applied event"""
	print("CombatManager: Passive effect applied - %s to %s: %s" % [effect_type, item_name, description])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "passive_effect_applied",
		"effect_type": effect_type,
		"item_name": item_name,
		"description": description
	})

func _on_passive_effect_removed(effect_type: String, item_name: String):
	"""Handle passive effect removed event"""
	print("CombatManager: Passive effect removed - %s from %s" % [effect_type, item_name])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "passive_effect_removed",
		"effect_type": effect_type,
		"item_name": item_name
	})

func _on_passive_effect_triggered(effect_type: String, target, effect: String):
	"""Handle passive effect triggered event"""
	print("CombatManager: Passive effect triggered - %s on %s: %s" % [effect_type, target.character_name, effect])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "passive_effect_triggered",
		"effect_type": effect_type,
		"target": target.character_name,
		"effect": effect
	})

# Momentum system methods
func gain_momentum(amount: int, source: String, world: String = "") -> bool:
	"""Gain momentum points"""
	if not momentum_manager:
		return false
	return momentum_manager.gain_momentum(amount, source, world)

func spend_momentum(amount: int, action: String, world: String = "") -> bool:
	"""Spend momentum points"""
	if not momentum_manager:
		return false
	return momentum_manager.spend_momentum(amount, action, world)

func trigger_combo_attack(combo_type: String, world: String = "") -> Dictionary:
	"""Trigger a combo attack"""
	if not momentum_manager:
		return {"success": false, "error": "Momentum manager not available"}
	return momentum_manager.trigger_combo_attack(combo_type, world)

func get_available_combos(world: String = "") -> Array:
	"""Get available combo attacks based on current momentum"""
	if not momentum_manager:
		return []
	return momentum_manager.get_available_combos(world)

func get_momentum_narrative() -> String:
	"""Get narrative description of current momentum state"""
	if not momentum_manager:
		return "No momentum system"
	return momentum_manager.get_momentum_narrative()

func get_momentum_statistics() -> Dictionary:
	"""Get momentum system statistics"""
	if not momentum_manager:
		return {}
	return momentum_manager.get_momentum_statistics()

func _on_momentum_gained(amount: int, source: String, description: String):
	"""Handle momentum gained event"""
	print("CombatManager: Momentum gained - %s" % description)
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "momentum_gained",
		"amount": amount,
		"source": source,
		"description": description
	})

func _on_momentum_spent(amount: int, action: String, description: String):
	"""Handle momentum spent event"""
	print("CombatManager: Momentum spent - %s" % description)
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "momentum_spent",
		"amount": amount,
		"action": action,
		"description": description
	})

func _on_combo_triggered(combo_type: String, damage_multiplier: float, description: String):
	"""Handle combo triggered event"""
	print("CombatManager: Combo triggered - %s (%.1fx damage)" % [combo_type, damage_multiplier])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "combo_triggered",
		"combo_type": combo_type,
		"damage_multiplier": damage_multiplier,
		"description": description
	})

func _on_momentum_state_changed(current_momentum: int, max_momentum: int):
	"""Handle momentum state changed event"""
	print("CombatManager: Momentum state changed - %d/%d" % [current_momentum, max_momentum])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "momentum_state_changed",
		"current_momentum": current_momentum,
		"max_momentum": max_momentum
	})

# Emotional state system methods
func set_emotional_state(actor, state: String, world: String = "") -> bool:
	"""Set emotional state for an actor"""
	if not emotional_state_manager:
		return false
	return emotional_state_manager.set_emotional_state(actor, state, world)

func get_emotional_state(actor) -> String:
	"""Get current emotional state for an actor"""
	if not emotional_state_manager:
		return "neutral"
	return emotional_state_manager.get_emotional_state(actor)

func get_emotional_effects(actor) -> Dictionary:
	"""Get emotional effects for an actor"""
	if not emotional_state_manager:
		return {}
	return emotional_state_manager.get_emotional_effects(actor)

func apply_emotional_effects_to_actor(actor) -> Dictionary:
	"""Apply emotional effects to an actor"""
	if not emotional_state_manager:
		return {}
	return emotional_state_manager.apply_emotional_effects_to_actor(actor)

func get_emotional_narrative(actor) -> String:
	"""Get narrative description of actor's emotional state"""
	if not emotional_state_manager:
		return "No emotional state"
	return emotional_state_manager.get_emotional_narrative(actor)

func get_available_emotional_transitions(actor) -> Array:
	"""Get available emotional state transitions for an actor"""
	if not emotional_state_manager:
		return []
	return emotional_state_manager.get_available_transitions(actor)

func trigger_emotional_transition(actor, new_state: String, world: String = "") -> bool:
	"""Trigger an emotional state transition"""
	if not emotional_state_manager:
		return false
	return emotional_state_manager.trigger_emotional_transition(actor, new_state, world)

func get_emotional_statistics() -> Dictionary:
	"""Get emotional state system statistics"""
	if not emotional_state_manager:
		return {}
	return emotional_state_manager.get_emotional_statistics()

func _on_emotional_state_changed(actor, old_state: String, new_state: String, description: String):
	"""Handle emotional state changed event"""
	print("CombatManager: Emotional state changed - %s: %s -> %s" % [actor.character_name, old_state, new_state])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "emotional_state_changed",
		"actor": actor.character_name,
		"old_state": old_state,
		"new_state": new_state,
		"description": description
	})

func _on_emotional_effect_applied(actor, state: String, effect: String, description: String):
	"""Handle emotional effect applied event"""
	print("CombatManager: Emotional effect applied - %s: %s" % [actor.character_name, state])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "emotional_effect_applied",
		"actor": actor.character_name,
		"state": state,
		"effect": effect,
		"description": description
	})

func _on_emotional_narrative_triggered(actor, state: String, narrative: String):
	"""Handle emotional narrative triggered event"""
	print("CombatManager: Emotional narrative - %s: %s" % [actor.character_name, narrative])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "emotional_narrative_triggered",
		"actor": actor.character_name,
		"state": state,
		"narrative": narrative
	})

# Terrain system methods
func set_terrain(world: String, duration: int = 10) -> bool:
	"""Set terrain for a specific world"""
	if not terrain_manager:
		return false
	return terrain_manager.set_terrain(world, duration)

func get_terrain_effects(world: String = "") -> Dictionary:
	"""Get terrain effects for a world"""
	if not terrain_manager:
		return {}
	return terrain_manager.get_terrain_effects(world)

func apply_terrain_effects_to_actor(actor, _world: String = "") -> Dictionary:
	"""Apply terrain effects to an actor"""
	if not terrain_manager:
		return {}
	return terrain_manager.apply_terrain_effects_to_actor(actor, _world)

func get_terrain_narrative(world: String = "") -> String:
	"""Get narrative description of terrain for a world"""
	if not terrain_manager:
		return "No terrain effect"
	return terrain_manager.get_terrain_narrative(world)

func get_available_terrain_transitions(world: String = "") -> Array:
	"""Get available terrain transitions for a world"""
	if not terrain_manager:
		return []
	return terrain_manager.get_available_terrain_transitions(world)

func trigger_terrain_transition(new_world: String, duration: int = 10) -> bool:
	"""Trigger a terrain transition"""
	if not terrain_manager:
		return false
	return terrain_manager.trigger_terrain_transition(new_world, duration)

func get_terrain_statistics() -> Dictionary:
	"""Get terrain system statistics"""
	if not terrain_manager:
		return {}
	return terrain_manager.get_terrain_statistics()

func _on_terrain_effect_applied(world: String, effect: String, description: String):
	"""Handle terrain effect applied event"""
	print("CombatManager: Terrain effect applied - %s: %s" % [world, effect])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "terrain_effect_applied",
		"world": world,
		"effect": effect,
		"description": description
	})

func _on_terrain_narrative_triggered(world: String, narrative: String):
	"""Handle terrain narrative triggered event"""
	print("CombatManager: Terrain narrative - %s: %s" % [world, narrative])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "terrain_narrative_triggered",
		"world": world,
		"narrative": narrative
	})

func _on_terrain_state_changed(world: String, old_terrain: String, new_terrain: String):
	"""Handle terrain state changed event"""
	print("CombatManager: Terrain state changed - %s -> %s" % [old_terrain, new_terrain])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "terrain_state_changed",
		"world": world,
		"old_terrain": old_terrain,
		"new_terrain": new_terrain
	})

# Time manipulation system methods
func trigger_time_manipulation(mechanic: String, target = null) -> bool:
	"""Trigger a time manipulation mechanic"""
	if not time_manager:
		return false
	return time_manager.trigger_time_manipulation(mechanic, target)

func get_time_mechanic_data(mechanic: String) -> Dictionary:
	"""Get data for a specific time mechanic"""
	if not time_manager:
		return {}
	return time_manager.get_time_mechanic_data(mechanic)

func get_available_time_mechanics() -> Array:
	"""Get all available time mechanics"""
	if not time_manager:
		return []
	return time_manager.get_available_time_mechanics()

func get_time_narrative(mechanic: String) -> String:
	"""Get narrative description for a time mechanic"""
	if not time_manager:
		return ""
	return time_manager.get_time_narrative(mechanic)

func get_time_energy() -> int:
	"""Get current time energy"""
	if not time_manager:
		return 0
	return time_manager.get_time_energy()

func add_time_energy(amount: int):
	"""Add time energy"""
	if not time_manager:
		return
	time_manager.add_time_energy(amount)

func get_time_statistics() -> Dictionary:
	"""Get time system statistics"""
	if not time_manager:
		return {}
	return time_manager.get_time_statistics()

func _on_time_manipulation_triggered(mechanic: String, cost: int, description: String):
	"""Handle time manipulation triggered event"""
	print("CombatManager: Time manipulation triggered - %s (Cost: %d)" % [mechanic, cost])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "time_manipulation_triggered",
		"mechanic": mechanic,
		"cost": cost,
		"description": description
	})

func _on_time_narrative_triggered(mechanic: String, narrative: String):
	"""Handle time narrative triggered event"""
	print("CombatManager: Time narrative - %s: %s" % [mechanic, narrative])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "time_narrative_triggered",
		"mechanic": mechanic,
		"narrative": narrative
	})

func _on_time_state_changed(old_state: String, new_state: String, duration: int):
	"""Handle time state changed event"""
	print("CombatManager: Time state changed - %s -> %s (Duration: %d)" % [old_state, new_state, duration])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "time_state_changed",
		"old_state": old_state,
		"new_state": new_state,
		"duration": duration
	})

# Quantum system methods
func trigger_quantum_state(state: String, target = null) -> bool:
	"""Trigger a quantum state"""
	if not quantum_manager:
		return false
	return quantum_manager.trigger_quantum_state(state, target)

func get_quantum_state_data(state: String) -> Dictionary:
	"""Get data for a specific quantum state"""
	if not quantum_manager:
		return {}
	return quantum_manager.get_quantum_state_data(state)

func get_available_quantum_states() -> Array:
	"""Get all available quantum states"""
	if not quantum_manager:
		return []
	return quantum_manager.get_available_quantum_states()

func get_quantum_narrative(state: String) -> String:
	"""Get narrative description for a quantum state"""
	if not quantum_manager:
		return ""
	return quantum_manager.get_quantum_narrative(state)

func get_quantum_energy() -> int:
	"""Get current quantum energy"""
	if not quantum_manager:
		return 0
	return quantum_manager.get_quantum_energy()

func add_quantum_energy(amount: int):
	"""Add quantum energy"""
	if not quantum_manager:
		return
	quantum_manager.add_quantum_energy(amount)

func get_quantum_statistics() -> Dictionary:
	"""Get quantum system statistics"""
	if not quantum_manager:
		return {}
	return quantum_manager.get_quantum_statistics()

func _on_quantum_state_triggered(state: String, probability: float, description: String):
	"""Handle quantum state triggered event"""
	print("CombatManager: Quantum state triggered - %s (Probability: %.2f)" % [state, probability])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "quantum_state_triggered",
		"state": state,
		"probability": probability,
		"description": description
	})

func _on_quantum_narrative_triggered(state: String, narrative: String):
	"""Handle quantum narrative triggered event"""
	print("CombatManager: Quantum narrative - %s: %s" % [state, narrative])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "quantum_narrative_triggered",
		"state": state,
		"narrative": narrative
	})

func _on_quantum_collapse_triggered(old_state: String, new_state: String, effects: Dictionary):
	"""Handle quantum collapse triggered event"""
	print("CombatManager: Quantum collapse - %s -> %s" % [old_state, new_state])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "quantum_collapse_triggered",
		"old_state": old_state,
		"new_state": new_state,
		"effects": effects
	})

# Dimensional system methods
func trigger_dimensional_combat(mechanic: String, target = null) -> bool:
	"""Trigger a dimensional combat mechanic"""
	if not dimension_manager:
		return false
	return dimension_manager.trigger_dimensional_combat(mechanic, target)

func get_dimensional_mechanic_data(mechanic: String) -> Dictionary:
	"""Get data for a specific dimensional mechanic"""
	if not dimension_manager:
		return {}
	return dimension_manager.get_dimensional_mechanic_data(mechanic)

func get_available_dimensional_mechanics() -> Array:
	"""Get all available dimensional mechanics"""
	if not dimension_manager:
		return []
	return dimension_manager.get_available_dimensional_mechanics()

func get_dimensional_narrative(mechanic: String) -> String:
	"""Get narrative description for a dimensional mechanic"""
	if not dimension_manager:
		return ""
	return dimension_manager.get_dimensional_narrative(mechanic)

func get_dimensional_energy() -> int:
	"""Get current dimensional energy"""
	if not dimension_manager:
		return 0
	return dimension_manager.get_dimensional_energy()

func add_dimensional_energy(amount: int):
	"""Add dimensional energy"""
	if not dimension_manager:
		return
	dimension_manager.add_dimensional_energy(amount)

func get_dimensional_statistics() -> Dictionary:
	"""Get dimensional system statistics"""
	if not dimension_manager:
		return {}
	return dimension_manager.get_dimensional_statistics()

func _on_dimension_shift_triggered(dimension: String, effects: Dictionary, description: String):
	"""Handle dimension shift triggered event"""
	print("CombatManager: Dimension shift triggered - %s" % dimension)
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "dimension_shift_triggered",
		"dimension": dimension,
		"effects": effects,
		"description": description
	})

func _on_dimension_narrative_triggered(dimension: String, narrative: String):
	"""Handle dimension narrative triggered event"""
	print("CombatManager: Dimension narrative - %s: %s" % [dimension, narrative])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "dimension_narrative_triggered",
		"dimension": dimension,
		"narrative": narrative
	})

func _on_dimension_merge_triggered(dimensions: Array, power_amplification: float):
	"""Handle dimension merge triggered event"""
	print("CombatManager: Dimension merge - %s (Power: %.1f)" % [str(dimensions), power_amplification])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "dimension_merge_triggered",
		"dimensions": dimensions,
		"power_amplification": power_amplification
	})

# Chain reaction system methods
func trigger_chain_reaction(chain_type: String, target = null) -> bool:
	"""Trigger a chain reaction"""
	if not chain_reaction_manager:
		return false
	return chain_reaction_manager.trigger_chain_reaction(chain_type, target)

func get_chain_reaction_data(chain_type: String) -> Dictionary:
	"""Get data for a specific chain reaction"""
	if not chain_reaction_manager:
		return {}
	return chain_reaction_manager.get_chain_reaction_data(chain_type)

func get_available_chain_reactions() -> Array:
	"""Get all available chain reactions"""
	if not chain_reaction_manager:
		return []
	return chain_reaction_manager.get_available_chain_reactions()

func get_chain_narrative(chain_type: String) -> String:
	"""Get narrative description for a chain reaction"""
	if not chain_reaction_manager:
		return ""
	return chain_reaction_manager.get_chain_narrative(chain_type)

func get_chain_energy() -> int:
	"""Get current chain energy"""
	if not chain_reaction_manager:
		return 0
	return chain_reaction_manager.get_chain_energy()

func add_chain_energy(amount: int):
	"""Add chain energy"""
	if not chain_reaction_manager:
		return
	chain_reaction_manager.add_chain_energy(amount)

func get_chain_statistics() -> Dictionary:
	"""Get chain reaction system statistics"""
	if not chain_reaction_manager:
		return {}
	return chain_reaction_manager.get_chain_statistics()

func _on_chain_reaction_triggered(chain_type: String, multiplier: float, description: String):
	"""Handle chain reaction triggered event"""
	print("CombatManager: Chain reaction triggered - %s (Multiplier: %.1f)" % [chain_type, multiplier])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "chain_reaction_triggered",
		"chain_type": chain_type,
		"multiplier": multiplier,
		"description": description
	})

func _on_chain_narrative_triggered(chain_type: String, narrative: String):
	"""Handle chain narrative triggered event"""
	print("CombatManager: Chain narrative - %s: %s" % [chain_type, narrative])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "chain_narrative_triggered",
		"chain_type": chain_type,
		"narrative": narrative
	})

func _on_chain_cascade_triggered(chains: Array, total_multiplier: float):
	"""Handle chain cascade triggered event"""
	print("CombatManager: Chain cascade - %s (Total Multiplier: %.1f)" % [str(chains), total_multiplier])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "chain_cascade_triggered",
		"chains": chains,
		"total_multiplier": total_multiplier
	})

# Turn Meter system methods
func initialize_actor_turn_meter(actor_name: String, base_speed: float = 100.0):
	"""Initialize turn meter for an actor"""
	if not turn_meter_manager:
		return
	turn_meter_manager.initialize_actor_turn_meter(actor_name, base_speed)

func update_turn_meter(actor_name: String, speed_modifier: float = 1.0) -> float:
	"""Update turn meter based on speed"""
	if not turn_meter_manager:
		return 0.0
	return turn_meter_manager.update_turn_meter(actor_name, speed_modifier)

func manipulate_turn_meter(actor_name: String, manipulation_type: String, amount: float) -> bool:
	"""Manipulate turn meter directly"""
	if not turn_meter_manager:
		return false
	return turn_meter_manager.manipulate_turn_meter(actor_name, manipulation_type, amount)

func get_turn_meter(actor_name: String) -> float:
	"""Get current turn meter for an actor"""
	if not turn_meter_manager:
		return 0.0
	return turn_meter_manager.get_turn_meter(actor_name)

func get_turn_order() -> Array:
	"""Get actors sorted by turn meter (highest first)"""
	if not turn_meter_manager:
		return []
	return turn_meter_manager.get_turn_order()

func _on_turn_meter_changed(actor: String, old_meter: float, new_meter: float):
	"""Handle turn meter changed event"""
	print("CombatManager: Turn meter changed - %s (%.1f -> %.1f)" % [actor, old_meter, new_meter])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "turn_meter_changed",
		"actor": actor,
		"old_meter": old_meter,
		"new_meter": new_meter
	})

func _on_turn_meter_manipulation(actor: String, manipulation_type: String, amount: float):
	"""Handle turn meter manipulation event"""
	print("CombatManager: Turn meter manipulation - %s %s by %.1f" % [actor, manipulation_type, amount])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "turn_meter_manipulation",
		"actor": actor,
		"manipulation_type": manipulation_type,
		"amount": amount
	})

func _on_turn_meter_speed_boost(actor: String, speed_bonus: float, description: String):
	"""Handle turn meter speed boost event"""
	print("CombatManager: Speed boost - %s (%.1fx): %s" % [actor, speed_bonus, description])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "turn_meter_speed_boost",
		"actor": actor,
		"speed_bonus": speed_bonus,
		"description": description
	})

# Mod system methods
func equip_mod(actor_name: String, slot_type: String, mod_data: Dictionary) -> bool:
	"""Equip a mod to an actor"""
	if not mod_manager:
		return false
	return mod_manager.equip_mod(actor_name, slot_type, mod_data)

func get_actor_mods(actor_name: String) -> Dictionary:
	"""Get all mods equipped to an actor"""
	if not mod_manager:
		return {}
	return mod_manager.get_actor_mods(actor_name)

func optimize_mods(actor_name: String, target_stat: String) -> bool:
	"""Optimize mods for a specific target stat"""
	if not mod_manager:
		return false
	return mod_manager.optimize_mods(actor_name, target_stat)

func _on_mod_equipped(actor: String, mod_type: String, mod_level: int):
	"""Handle mod equipped event"""
	print("CombatManager: Mod equipped - %s %s (Level %d)" % [actor, mod_type, mod_level])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "mod_equipped",
		"actor": actor,
		"mod_type": mod_type,
		"mod_level": mod_level
	})

func _on_mod_optimized(actor: String, optimization_type: String, improvement: float):
	"""Handle mod optimized event"""
	print("CombatManager: Mod optimized - %s %s (%.1f)" % [actor, optimization_type, improvement])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "mod_optimized",
		"actor": actor,
		"optimization_type": optimization_type,
		"improvement": improvement
	})

func _on_mod_set_completed(actor: String, set_type: String, bonus_activated: bool):
	"""Handle mod set completed event"""
	print("CombatManager: Mod set completed - %s %s (%s)" % [actor, set_type, "Active" if bonus_activated else "Inactive"])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "mod_set_completed",
		"actor": actor,
		"set_type": set_type,
		"bonus_activated": bonus_activated
	})

# Gear system methods
func equip_gear(actor_name: String, gear_slot: String, gear_tier: int) -> bool:
	"""Equip gear to an actor"""
	if not gear_manager:
		return false
	return gear_manager.equip_gear(actor_name, gear_slot, gear_tier)

func upgrade_gear(actor_name: String, gear_slot: String) -> bool:
	"""Upgrade gear in a specific slot"""
	if not gear_manager:
		return false
	return gear_manager.upgrade_gear(actor_name, gear_slot)

func get_gear_stats(actor_name: String) -> Dictionary:
	"""Get total gear stats for an actor"""
	if not gear_manager:
		return {}
	return gear_manager.get_gear_stats(actor_name)

func _on_gear_equipped(actor: String, gear_tier: int, gear_slot: String):
	"""Handle gear equipped event"""
	print("CombatManager: Gear equipped - %s tier %d in %s slot" % [actor, gear_tier, gear_slot])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "gear_equipped",
		"actor": actor,
		"gear_tier": gear_tier,
		"gear_slot": gear_slot
	})

func _on_gear_upgraded(actor: String, old_tier: int, new_tier: int):
	"""Handle gear upgraded event"""
	print("CombatManager: Gear upgraded - %s (Tier %d -> %d)" % [actor, old_tier, new_tier])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "gear_upgraded",
		"actor": actor,
		"old_tier": old_tier,
		"new_tier": new_tier
	})

func _on_gear_material_used(material_type: String, amount: int, remaining: int):
	"""Handle gear material used event"""
	print("CombatManager: Gear material used - %d %s (Remaining: %d)" % [amount, material_type, remaining])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "gear_material_used",
		"material_type": material_type,
		"amount": amount,
		"remaining": remaining
	})

# Ability Cooldown system methods
func use_ability(actor_name: String, ability_name: String) -> bool:
	"""Use an ability and set its cooldown"""
	if not ability_cooldown_manager:
		return false
	return ability_cooldown_manager.use_ability(actor_name, ability_name)

func reduce_cooldown(actor_name: String, ability_name: String, reduction_type: String) -> bool:
	"""Reduce cooldown for an ability"""
	if not ability_cooldown_manager:
		return false
	return ability_cooldown_manager.reduce_cooldown(actor_name, ability_name, reduction_type)

func get_ability_cooldown(actor_name: String, ability_name: String) -> int:
	"""Get current cooldown for an ability"""
	if not ability_cooldown_manager:
		return 0
	return ability_cooldown_manager.get_ability_cooldown(actor_name, ability_name)

func _on_ability_used(actor: String, ability_name: String, cooldown_turns: int):
	"""Handle ability used event"""
	print("CombatManager: Ability used - %s %s (Cooldown: %d turns)" % [actor, ability_name, cooldown_turns])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "ability_used",
		"actor": actor,
		"ability_name": ability_name,
		"cooldown_turns": cooldown_turns
	})

func _on_cooldown_reduced(actor: String, ability_name: String, reduction: int):
	"""Handle cooldown reduced event"""
	print("CombatManager: Cooldown reduced - %s %s by %d turns" % [actor, ability_name, reduction])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "cooldown_reduced",
		"actor": actor,
		"ability_name": ability_name,
		"reduction": reduction
	})

func _on_cooldown_reset(actor: String, ability_name: String):
	"""Handle cooldown reset event"""
	print("CombatManager: Cooldown reset - %s %s" % [actor, ability_name])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "cooldown_reset",
		"actor": actor,
		"ability_name": ability_name
	})

# Faction Synergy system methods
func assign_faction(actor_name: String, faction: String) -> bool:
	"""Assign a faction to an actor"""
	if not faction_synergy_manager:
		return false
	return faction_synergy_manager.assign_faction(actor_name, faction)

func get_faction_bonuses(actor_name: String) -> Dictionary:
	"""Get faction bonuses for an actor"""
	if not faction_synergy_manager:
		return {}
	return faction_synergy_manager.get_faction_bonuses(actor_name)

func trigger_faction_ability(faction: String, ability_name: String) -> bool:
	"""Trigger a faction-specific ability"""
	if not faction_synergy_manager:
		return false
	return faction_synergy_manager.trigger_faction_ability(faction, ability_name)

func _on_faction_synergy_activated(faction: String, bonus_type: String, description: String):
	"""Handle faction synergy activated event"""
	print("CombatManager: Faction synergy - %s %s: %s" % [faction, bonus_type, description])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "faction_synergy_activated",
		"faction": faction,
		"bonus_type": bonus_type,
		"description": description
	})

func _on_faction_leader_bonus(leader: String, faction: String, bonus: Dictionary):
	"""Handle faction leader bonus event"""
	print("CombatManager: Faction leader bonus - %s %s: %s" % [leader, faction, str(bonus)])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "faction_leader_bonus",
		"leader": leader,
		"faction": faction,
		"bonus": bonus
	})

func _on_faction_ability_triggered(faction: String, ability_name: String, effect: Dictionary):
	"""Handle faction ability triggered event"""
	print("CombatManager: Faction ability - %s %s: %s" % [faction, ability_name, str(effect)])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "faction_ability_triggered",
		"faction": faction,
		"ability_name": ability_name,
		"effect": effect
	})

# Job Class system methods
func assign_job_class(actor_name: String, job_class: String) -> bool:
	"""Assign a job class to an actor"""
	if not job_class_manager:
		return false
	return job_class_manager.assign_job_class(actor_name, job_class)

func level_up_job(actor_name: String) -> bool:
	"""Level up an actor's job class"""
	if not job_class_manager:
		return false
	return job_class_manager.level_up_job(actor_name)

func get_job_stats(actor_name: String) -> Dictionary:
	"""Get job-based stats for an actor"""
	if not job_class_manager:
		return {}
	return job_class_manager.get_job_stats(actor_name)

func _on_job_class_changed(actor: String, old_job: String, new_job: String):
	"""Handle job class changed event"""
	print("CombatManager: Job class changed - %s (%s -> %s)" % [actor, old_job, new_job])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "job_class_changed",
		"actor": actor,
		"old_job": old_job,
		"new_job": new_job
	})

func _on_job_ability_learned(actor: String, job: String, ability_name: String):
	"""Handle job ability learned event"""
	print("CombatManager: Job ability learned - %s %s: %s" % [actor, job, ability_name])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "job_ability_learned",
		"actor": actor,
		"job": job,
		"ability_name": ability_name
	})

func _on_job_level_up(actor: String, job: String, old_level: int, new_level: int):
	"""Handle job level up event"""
	print("CombatManager: Job level up - %s %s (Level %d -> %d)" % [actor, job, old_level, new_level])
	
	# Add to combat history
	combat_history.append({
		"turn": current_turn,
		"type": "job_level_up",
		"actor": actor,
		"job": job,
		"old_level": old_level,
		"new_level": new_level
	})

func get_elemental_effectiveness(attack_element: String, defense_element: String) -> float:
	"""Get elemental effectiveness multiplier between attack and defense elements"""
	if elemental_effectiveness.has(attack_element):
		var effectiveness = elemental_effectiveness[attack_element]
		return effectiveness.get(defense_element, 1.0)
	return 1.0

# UI Update Methods
func update_combat_ui_surface(location: Vector2, surface_type: String):
	"""Update UI for surface effects"""
	var ui_manager = get_node_or_null("/root/GameManager")
	if ui_manager and ui_manager.has_method("update_surface_ui"):
		ui_manager.update_surface_ui(location, surface_type)

func update_combat_ui_all_out_attack(condition: String):
	"""Update UI for all-out attack conditions"""
	var ui_manager = get_node_or_null("/root/GameManager")
	if ui_manager and ui_manager.has_method("update_all_out_attack_ui"):
		ui_manager.update_all_out_attack_ui(condition)

# Achievement Trigger Methods
func trigger_surface_achievement(surface_type: String):
	"""Trigger achievements for surface effects"""
	var steam_manager = get_node_or_null("/root/SteamManager")
	if steam_manager:
		match surface_type:
			"fire":
				steam_manager.unlock_achievement("fire_master")
			"ice":
				steam_manager.unlock_achievement("ice_master")
			"lightning":
				steam_manager.unlock_achievement("lightning_master")

func trigger_all_out_attack_achievement(_condition: String):
	"""Trigger achievements for all-out attacks"""
	var steam_manager = get_node_or_null("/root/SteamManager")
	if steam_manager:
		steam_manager.unlock_achievement("all_out_attack_master")

# Sound Effect Methods
func play_surface_sound(surface_type: String):
	"""Play sound effects for surface creation"""
	var audio_manager = get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method("play_surface_sound"):
		audio_manager.play_surface_sound(surface_type)

func play_all_out_attack_sound(condition: String):
	"""Play sound effects for all-out attacks"""
	var audio_manager = get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method("play_all_out_attack_sound"):
		audio_manager.play_all_out_attack_sound(condition)

# Visual Effect Methods
func show_surface_effect(location: Vector2, surface_type: String):
	"""Show visual effects for surface creation"""
	var effect_manager = get_node_or_null("/root/EffectManager")
	if effect_manager and effect_manager.has_method("show_surface_effect"):
		effect_manager.show_surface_effect(location, surface_type)

func show_all_out_attack_effect(condition: String):
	"""Show visual effects for all-out attacks"""
	var effect_manager = get_node_or_null("/root/EffectManager")
	if effect_manager and effect_manager.has_method("show_all_out_attack_effect"):
		effect_manager.show_all_out_attack_effect(condition)

# Narrative Trigger Methods
func trigger_surface_narrative(surface_type: String, location: Vector2):
	"""Trigger narrative events for surface creation"""
	var narrative_manager = get_node_or_null("/root/NarrativeManager")
	if narrative_manager and narrative_manager.has_method("trigger_surface_narrative"):
		narrative_manager.trigger_surface_narrative(surface_type, location)

func trigger_all_out_attack_narrative(condition: String):
	"""Trigger narrative events for all-out attacks"""
	var narrative_manager = get_node_or_null("/root/NarrativeManager")
	if narrative_manager and narrative_manager.has_method("trigger_all_out_attack_narrative"):
		narrative_manager.trigger_all_out_attack_narrative(condition)
