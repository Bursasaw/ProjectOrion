extends Resource
class_name CombatAction

# Combat Action - Represents different types of combat actions
# Handles attacks, spells, abilities, and their properties

enum ActionType {
	ATTACK,
	SPELL,
	HEAL,
	BUFF,
	DEBUFF,
	ITEM,
	SPECIAL
}

# Basic action properties
@export var action_id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var action_type: ActionType = ActionType.ATTACK
@export var icon: Texture2D = null

# Action requirements
@export var cost: int = 0
@export var cost_type: String = "mana"  # "mana", "health", "none"
@export var requires_target: bool = true
@export var is_offensive: bool = true
@export var action_range: int = 1  # 0 = self, 1 = single target, 2+ = area

# Action effects
@export var power: int = 10
@export var element: String = "physical"  # "physical", "fire", "ice", "lightning", "healing", etc.
@export var accuracy: float = 0.95
@export var critical_chance: float = 0.05

# Status effects
@export var buff_type: String = ""
@export var debuff_type: String = ""
@export var duration: int = 3

# Special properties
@export var item = null
@export var cooldown: int = 0
@export var current_cooldown: int = 0

# Action point system
@export var action_cost: int = 1  # How many action points this action costs

# Quantum effects (for QuantumAI system)
@export var quantum_tunneling: bool = false  # Bypass defenses
@export var quantum_superposition: bool = false  # Multiple damage instances
@export var quantum_entanglement: bool = false  # Affects multiple targets

# Learning requirements
@export var level_requirement: int = 1
@export var skill_requirement: String = ""

func _init():
	# Set default values
	if action_id == "":
		action_id = name.to_lower().replace(" ", "_")

func can_use(actor) -> bool:
	"""Check if this action can be used by the given actor"""
	# Check if actor has enough resources
	if cost_type == "mana" and actor.magic_points < cost:
		return false
	elif cost_type == "health" and actor.health_points <= cost:
		return false
	elif cost_type == "gold" and actor.gold < cost:
		return false
	
	# Check cooldown
	if is_on_cooldown():
		return false
	
	return true

func use_action(actor):
	"""Use the action and apply cooldown"""
	if not can_use(actor):
		return false
	
	# Pay cost
	pay_cost(actor)
	
	# Apply cooldown
	if cooldown > 0:
		current_cooldown = cooldown
	
	return true

func pay_cost(actor) -> bool:
	"""Pay the cost for using this action"""
	if cost_type == "mana":
		if actor.magic_points >= cost:
			actor.magic_points -= cost
			return true
	elif cost_type == "health":
		if actor.health_points > cost:
			actor.health_points -= cost
			return true
	elif cost_type == "gold":
		if actor.gold >= cost:
			actor.gold -= cost
			return true
	elif cost_type == "none":
		return true
	
	return false

func update_cooldown():
	"""Update the cooldown for this action"""
	if current_cooldown > 0:
		current_cooldown -= 1

func reset_cooldown():
	"""Reset the cooldown to full"""
	current_cooldown = cooldown

func is_on_cooldown() -> bool:
	"""Check if action is on cooldown"""
	return current_cooldown > 0

func get_cooldown_percentage() -> float:
	"""Get cooldown as a percentage"""
	if cooldown <= 0:
		return 0.0
	return float(current_cooldown) / float(cooldown)

func get_display_name() -> String:
	"""Get the display name with element color"""
	var element_colors = {
		"physical": "White",
		"fire": "Red",
		"ice": "Cyan",
		"lightning": "Yellow",
		"healing": "Green",
		"dark": "Purple",
		"light": "White"
	}
	
	var color = element_colors.get(element, "White")
	return "[color=%s]%s[/color]" % [color, name]

func get_full_description() -> String:
	"""Get full action description with details"""
	var desc = description
	
	# Add power information
	desc += "\n\nPower: %d" % power
	
	# Add cost information
	if cost > 0:
		desc += "\nCost: %d %s" % [cost, cost_type]
	
	# Add action point cost
	if action_cost > 1:
		desc += "\nAction Points: %d" % action_cost
	
	# Add accuracy information
	if accuracy < 1.0:
		desc += "\nAccuracy: %d%%" % int(accuracy * 100)
	
	# Add critical chance
	if critical_chance > 0:
		desc += "\nCritical: %d%%" % int(critical_chance * 100)
	
	# Add range information
	if action_range > 1:
		desc += "\nRange: Area"
	elif action_range == 1:
		desc += "\nRange: Single Target"
	else:
		desc += "\nRange: Self"
	
	# Add cooldown information
	if cooldown > 0:
		desc += "\nCooldown: %d turns" % cooldown
	
	# Add status effect information
	if buff_type != "":
		desc += "\nEffect: %s (+%d for %d turns)" % [buff_type, power, duration]
	elif debuff_type != "":
		desc += "\nEffect: %s (-%d for %d turns)" % [debuff_type, power, duration]
	
	return desc

func get_action_type_name() -> String:
	"""Get action type name as string"""
	var type_names = {
		ActionType.ATTACK: "Attack",
		ActionType.SPELL: "Spell",
		ActionType.HEAL: "Heal",
		ActionType.BUFF: "Buff",
		ActionType.DEBUFF: "Debuff",
		ActionType.ITEM: "Item",
		ActionType.SPECIAL: "Special"
	}
	return type_names.get(action_type, "Unknown")

func get_action_cost() -> int:
	"""Get the action point cost for this action"""
	return action_cost

func get_element_name() -> String:
	"""Get element name as string"""
	var element_names = {
		"physical": "Physical",
		"fire": "Fire",
		"ice": "Ice",
		"lightning": "Lightning",
		"healing": "Healing",
		"dark": "Dark",
		"light": "Light"
	}
	return element_names.get(element, "Unknown")

func is_healing_action() -> bool:
	"""Check if this is a healing action"""
	return action_type == ActionType.HEAL or element == "healing"

func is_damaging_action() -> bool:
	"""Check if this is a damaging action"""
	return is_offensive and not is_healing_action()

func is_support_action() -> bool:
	"""Check if this is a support action"""
	return action_type == ActionType.BUFF or action_type == ActionType.HEAL

func is_debuff_action() -> bool:
	"""Check if this is a debuff action"""
	return action_type == ActionType.DEBUFF

func is_area_action() -> bool:
	"""Check if this is an area action"""
	return action_range > 1

func is_self_action() -> bool:
	"""Check if this is a self-targeting action"""
	return action_range == 0

func requires_target_actor() -> bool:
	"""Check if this action requires a target actor"""
	return requires_target and not is_self_action()

func get_effectiveness_multiplier(target) -> float:
	"""Get effectiveness multiplier against target based on elements"""
	var effectiveness = 1.0
	
	# Check for elemental weaknesses/resistances
	if element != "" and target.has_method("get_element"):
		var target_element = target.get_element()
		
		# Fire vs Ice
		if element == "fire" and target_element == "ice":
			effectiveness = 1.5
		elif element == "ice" and target_element == "fire":
			effectiveness = 0.5
		
		# Lightning vs Water
		elif element == "lightning" and target_element == "water":
			effectiveness = 1.5
		elif element == "water" and target_element == "lightning":
			effectiveness = 0.5
		
		# Earth vs Lightning
		elif element == "earth" and target_element == "lightning":
			effectiveness = 1.5
		elif element == "lightning" and target_element == "earth":
			effectiveness = 0.5
	
	return effectiveness 
