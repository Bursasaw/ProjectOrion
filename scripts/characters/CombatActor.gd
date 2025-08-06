extends Resource
class_name CombatActor

# Combat Actor - Represents characters in combat
# Manages stats, actions, and combat behavior

# Basic info
var character_name: String = ""
var character_class: String = ""
var level: int = 1

# Core stats
var strength: int = 10
var constitution: int = 10
var dexterity: int = 10
var intelligence: int = 10
var wisdom: int = 10
var charisma: int = 10

# Combat stats (calculated from core stats)
var health_points: int = 100
var max_health_points: int = 100
var magic_points: int = 50
var max_magic_points: int = 50
var attack: int = 15
var defense: int = 10
var magic_attack: int = 12
var magic_defense: int = 8
var speed: int = 10
var initiative: float = 0.0  # Initiative for turn order calculation

# Status effects
var buffs: Array[Dictionary] = []
var debuffs: Array[Dictionary] = []

# Positioning system
var position: String = "front"  # "front" or "back"
var formation_bonus: float = 1.0

# Enhanced status conditions
var status_conditions = {
	"burn": {"damage_per_turn": 5, "duration": 3, "type": "damage"},
	"poison": {"damage_per_turn": 3, "duration": 5, "type": "damage"},
	"paralysis": {"stun_chance": 0.25, "duration": 2, "type": "control"},
	"sleep": {"skip_turn": true, "duration": 2, "type": "control"},
	"confusion": {"self_hit_chance": 0.33, "duration": 3, "type": "control"},
	"bleeding": {"damage_per_turn": 4, "duration": 4, "type": "damage"},
	"silence": {"block_spells": true, "duration": 3, "type": "control"},
	"blind": {"accuracy_penalty": 0.5, "duration": 2, "type": "control"}
}

# Active status conditions tracking
var active_status_conditions: Dictionary = {}

# Equipment system for bonuses
var equipment: Dictionary = {}

# Abilities and actions
var abilities = []
var actions = []

# Rewards
var experience_reward: int = 50
var gold_reward: int = 25
var item_drops: Array[String] = []

# Elemental properties
var elemental_affinity: String = "neutral"
var elemental_weaknesses: Array[String] = []
var elemental_resistances: Array[String] = []

# World origin (for multiverse setting)
var world_origin: String = "terra"  # Default to Terra (Earth)
var species: String = "human"  # From GDD species list
var faction: String = "neutral"  # From GDD factions

# Player data reference (for player characters)
var player_data = null

func _init():
	"""Initialize combat actor"""
	initialize_default_stats()

func initialize_default_stats():
	"""Initialize default stats based on core attributes"""
	calculate_derived_stats()

func calculate_derived_stats():
	"""Calculate derived stats from core attributes"""
	max_health_points = constitution * 10
	max_magic_points = intelligence * 5
	health_points = max_health_points
	magic_points = max_magic_points
	
	attack = int(strength * 1.5)
	defense = int(constitution * 1.0)
	magic_attack = int(intelligence * 1.2)
	magic_defense = int(wisdom * 0.8)
	speed = int(dexterity * 1.0)

func take_damage(damage: int):
	"""Take damage and check for defeat"""
	health_points = max(0, health_points - damage)
	print("%s takes %d damage (HP: %d/%d)" % [character_name, damage, health_points, max_health_points])
	
	if is_defeated():
		print("%s is defeated!" % character_name)

func heal(amount: int):
	"""Heal the actor"""
	health_points = min(max_health_points, health_points + amount)
	print("%s heals %d HP (HP: %d/%d)" % [character_name, amount, health_points, max_health_points])

func restore_mana(amount: int):
	"""Restore magic points"""
	magic_points = min(max_magic_points, magic_points + amount)
	print("%s restores %d MP (MP: %d/%d)" % [character_name, amount, magic_points, max_magic_points])

func is_defeated() -> bool:
	"""Check if the actor is defeated"""
	return health_points <= 0

func is_alive() -> bool:
	"""Check if the actor is alive"""
	return health_points > 0

func add_buff(buff_name: String, power: int, duration: int):
	"""Add a buff to the actor"""
	buffs.append({
		"name": buff_name,
		"power": power,
		"duration": duration,
		"remaining": duration
	})
	
	# Apply buff effect immediately
	apply_buff_effect(buff_name, power)
	
	print("%s gains buff: %s" % [character_name, buff_name])

func add_debuff(debuff_name: String, power: int, duration: int):
	"""Add a debuff to the actor"""
	debuffs.append({
		"name": debuff_name,
		"power": power,
		"duration": duration,
		"remaining": duration
	})
	
	# Apply debuff effect immediately
	apply_debuff_effect(debuff_name, power)
	
	print("%s gains debuff: %s" % [character_name, debuff_name])

func remove_buff(buff_name: String):
	"""Remove a buff from the actor"""
	for i in range(buffs.size()):
		if buffs[i]["name"] == buff_name:
			buffs.remove_at(i)
			print("%s loses buff: %s" % [character_name, buff_name])
			break

func remove_debuff(debuff_name: String):
	"""Remove a debuff from the actor"""
	for i in range(debuffs.size()):
		if debuffs[i]["name"] == debuff_name:
			debuffs.remove_at(i)
			print("%s loses debuff: %s" % [character_name, debuff_name])
			break

func apply_turn_effects():
	"""Apply effects that occur at the end of each turn"""
	# Apply buff effects
	for buff in buffs:
		buff["remaining"] -= 1
		if buff["remaining"] <= 0:
			remove_buff(buff["name"])
	
	# Apply debuff effects
	for debuff in debuffs:
		debuff["remaining"] -= 1
		if debuff["remaining"] <= 0:
			remove_debuff(debuff["name"])
	
	# Apply poison damage
	for debuff in debuffs:
		if debuff["name"] == "poison":
			var poison_damage = int(max_health_points / 20.0)
			take_damage(poison_damage)

func learn_spell(spell):
	"""Learn a new spell"""
	abilities.append(spell)
	print("%s learns spell: %s" % [character_name, spell.name])

func add_action(action):
	"""Add a combat action"""
	actions.append(action)
	print("%s gains action: %s" % [character_name, action.name])

func remove_action(action_name: String):
	"""Remove a combat action"""
	for i in range(actions.size()):
		if actions[i].name == action_name:
			actions.remove_at(i)
			print("%s loses action: %s" % [character_name, action_name])
			break

func get_actions_by_type(action_type):
	"""Get all actions of a specific type"""
	var type_actions = []
	for action in actions:
		if action.action_type == action_type:
			type_actions.append(action)
	return type_actions

func get_available_actions():
	"""Get all available actions"""
	return actions

func set_player_data(data):
	"""Set the player data reference"""
	player_data = data

func set_rewards(exp_reward: int, gold: int, drops: Array[String]):
	"""Set the rewards for this combat actor"""
	experience_reward = exp_reward
	gold_reward = gold
	item_drops = drops

func add_status_effect(effect_name: String, power: int, duration: int):
	"""Add a status effect to the actor"""
	debuffs.append({
		"name": effect_name,
		"power": power,
		"duration": duration,
		"remaining": duration
	})
	print("%s gains status effect: %s" % [character_name, effect_name])

func has_status_effect(effect_name: String) -> bool:
	"""Check if the actor has a specific status effect"""
	for debuff in debuffs:
		if debuff["name"] == effect_name:
			return true
	return false

func remove_status_effect(effect_name: String):
	"""Remove a status effect from the actor"""
	remove_debuff(effect_name)

func apply_buff_effect(buff_name: String, power: int):
	"""Apply a buff effect to stats"""
	match buff_name:
		"strength":
			attack += power
		"defense":
			defense += power
		"speed":
			speed += power
		"magic":
			magic_attack += power
		_:
			pass

func apply_debuff_effect(debuff_name: String, power: int):
	"""Apply a debuff effect to stats"""
	match debuff_name:
		"weakness":
			attack = max(1, attack - power)
		"slow":
			speed = max(1, speed - power)
		"vulnerability":
			defense = max(1, defense - power)
		_:
			pass

# Sample enemy creation functions
static func create_goblin():
	"""Create a goblin enemy from Terra"""
	var goblin_script = load("res://scripts/characters/CombatActor.gd")
	var goblin = goblin_script.new()
	goblin.character_name = "Goblin"
	goblin.character_class = "Enemy"
	goblin.level = 2
	goblin.health_points = 30
	goblin.max_health_points = 30
	goblin.magic_points = 10
	goblin.max_magic_points = 10
	goblin.attack = 8
	goblin.defense = 5
	goblin.magic_attack = 6
	goblin.magic_defense = 4
	goblin.speed = 8
	
	# Set world origin and species
	goblin.set_world_origin("terra")
	goblin.set_species("goblin")
	
	# Add basic attack action
	var combat_action_script = load("res://scripts/core/CombatAction.gd")
	var attack_action = combat_action_script.new()
	attack_action.name = "Claw Attack"
	attack_action.action_type = combat_action_script.ActionType.ATTACK
	attack_action.power = 8
	attack_action.cost = 0
	attack_action.cost_type = "none"
	attack_action.element = "earth"  # Goblins use earth magic
	goblin.add_action(attack_action)
	
	return goblin

static func create_skeleton():
	"""Create a skeleton enemy from Nokturn"""
	var skeleton_script = load("res://scripts/characters/CombatActor.gd")
	var skeleton = skeleton_script.new()
	skeleton.character_name = "Skeleton"
	skeleton.character_class = "Undead"
	skeleton.level = 3
	skeleton.health_points = 40
	skeleton.max_health_points = 40
	skeleton.magic_points = 15
	skeleton.max_magic_points = 15
	skeleton.attack = 10
	skeleton.defense = 6
	skeleton.magic_attack = 8
	skeleton.magic_defense = 5
	skeleton.speed = 7
	
	# Set world origin and species
	skeleton.set_world_origin("nokturn")
	skeleton.set_species("shadowkin")
	
	# Add basic attack action
	var combat_action_script = load("res://scripts/core/CombatAction.gd")
	var attack_action = combat_action_script.new()
	attack_action.name = "Bone Strike"
	attack_action.action_type = combat_action_script.ActionType.ATTACK
	attack_action.power = 10
	attack_action.cost = 0
	attack_action.cost_type = "none"
	attack_action.element = "shadow"  # Undead use shadow magic
	skeleton.add_action(attack_action)
	
	return skeleton

static func create_void_creature():
	"""Create a void creature enemy from Ombra"""
	var void_script = load("res://scripts/characters/CombatActor.gd")
	var void_creature = void_script.new()
	void_creature.character_name = "Void Creature"
	void_creature.character_class = "Void"
	void_creature.level = 4
	void_creature.health_points = 50
	void_creature.max_health_points = 50
	void_creature.magic_points = 20
	void_creature.max_magic_points = 20
	void_creature.attack = 12
	void_creature.defense = 8
	void_creature.magic_attack = 10
	void_creature.magic_defense = 7
	void_creature.speed = 9
	
	# Set world origin and species
	void_creature.set_world_origin("ombra")
	void_creature.set_species("shadowkin")
	
	# Add basic attack action
	var combat_action_script = load("res://scripts/core/CombatAction.gd")
	var attack_action = combat_action_script.new()
	attack_action.name = "Void Strike"
	attack_action.action_type = combat_action_script.ActionType.ATTACK
	attack_action.power = 12
	attack_action.cost = 0
	attack_action.cost_type = "none"
	attack_action.element = "void"  # Void creatures use void magic
	void_creature.add_action(attack_action)
	
	return void_creature

# Positioning system functions
func set_position(new_position: String):
	"""Set the actor's position (front/back)"""
	if new_position in ["front", "back"]:
		position = new_position
		print("%s moved to %s position" % [character_name, position])
	else:
		print("⚠️ Invalid position ignored: %s (keeping current position)" % new_position)
		# Don't change position for invalid values

func calculate_position_damage(base_damage: int) -> int:
	"""Calculate damage based on position"""
	var modified_damage = base_damage
	
	if position == "back":
		modified_damage = int(base_damage * 0.7)  # Back row takes 30% less damage
		print("🛡️ Back row protection: %s takes reduced damage" % character_name)
	
	return modified_damage

func get_position() -> String:
	"""Get current position"""
	return position

func get_position_vector() -> Vector2:
	"""Get current position as Vector2 coordinates"""
	match position:
		"front":
			return Vector2(0, 0)  # Front row position
		"back":
			return Vector2(0, 1)  # Back row position
		_:
			return Vector2(0, 0)  # Default to front

# Enhanced status condition functions
func add_status_condition(condition_name: String, duration: int = 3):
	"""Add a status condition to the actor"""
	if status_conditions.has(condition_name):
		var condition = status_conditions[condition_name].duplicate()
		condition["duration"] = duration
		condition["remaining"] = duration
		
		# Add to existing status conditions (now properly declared as class variable)
		# No need to check if it exists since it's declared as a class variable
		
		active_status_conditions[condition_name] = condition
		print("💫 %s is affected by %s for %d turns" % [character_name, condition_name, duration])
	else:
		print("❌ Unknown status condition: %s" % condition_name)

func remove_status_condition(condition_name: String):
	"""Remove a status condition"""
	if active_status_conditions.has(condition_name):
		active_status_conditions.erase(condition_name)
		print("✨ %s is no longer affected by %s" % [character_name, condition_name])

func apply_status_condition_effects():
	"""Apply status condition effects at turn start"""
	if active_status_conditions.is_empty():
		return
	
	var conditions_to_remove = []
	
	for condition_name in active_status_conditions:
		var condition = active_status_conditions[condition_name]
		
		# Apply damage-over-time effects
		if condition.has("damage_per_turn"):
			var damage = condition["damage_per_turn"]
			take_damage(damage)
			print("💀 %s takes %d damage from %s" % [character_name, damage, condition_name])
		
		# Apply control effects
		if condition.has("stun_chance") and randf() < condition["stun_chance"]:
			print("⚡ %s is stunned by %s!" % [character_name, condition_name])
			# Skip turn logic would be handled by combat manager
		
		# Decrease duration
		condition["remaining"] -= 1
		
		# Remove expired conditions
		if condition["remaining"] <= 0:
			conditions_to_remove.append(condition_name)
	
	# Remove expired conditions
	for condition_name in conditions_to_remove:
		remove_status_condition(condition_name)

func has_status_condition(condition_name: String) -> bool:
	"""Check if actor has a specific status condition"""
	return active_status_conditions.has(condition_name)

func get_equipment_bonus(bonus_type: String) -> float:
	"""Get equipment bonus for a specific stat type"""
	var bonus = 0.0
	
	# Check equipment for bonuses
	for item_name in equipment:
		var item = equipment[item_name]
		if item.has("bonuses") and item["bonuses"].has(bonus_type):
			bonus += item["bonuses"][bonus_type]
	
	return bonus

func equip_item(item_name: String, item_data: Dictionary):
	"""Equip an item and apply its bonuses"""
	equipment[item_name] = item_data
	print("🔧 %s equips %s" % [character_name, item_name])

func unequip_item(item_name: String):
	"""Unequip an item and remove its bonuses"""
	if equipment.has(item_name):
		equipment.erase(item_name)
		print("🔧 %s unequips %s" % [character_name, item_name])

func get_equipment() -> Dictionary:
	"""Get all equipped items"""
	return equipment

func get_critical_chance_bonus() -> float:
	"""Get critical hit chance bonus from equipment/status"""
	var bonus = 0.0
	
	# Add equipment bonuses
	bonus += get_equipment_bonus("critical_chance")
	
	# Add status condition effects
	if has_status_condition("blind"):
		bonus -= 0.1  # Blind reduces critical chance
	
	return bonus

func get_world_origin() -> String:
	"""Get the actor's world of origin"""
	return world_origin

func set_world_origin(world: String):
	"""Set the actor's world of origin and update elemental affinity"""
	world_origin = world
	
	# Update elemental affinity based on world
	var world_affinities = {
		"nokturn": "shadow",
		"elysion": "light", 
		"sylithar": "fire",
		"terra": "earth",
		"aethra": "wind",
		"ombra": "void",
		"krynn": "fire",
		"tauron": "tech",
		"aelria": "light"
	}
	
	if world_affinities.has(world):
		elemental_affinity = world_affinities[world]
		print("%s is from %s - elemental affinity: %s" % [character_name, world, elemental_affinity])

func get_species() -> String:
	"""Get the actor's species"""
	return species

func set_species(new_species: String):
	"""Set the actor's species and apply species bonuses"""
	species = new_species
	
	# Apply species-specific bonuses (from GDD)
	var species_bonuses = {
		"sylph": {"speed": 2, "magic_attack": 1},
		"dwarf": {"defense": 2, "strength": 1},
		"goblin": {"speed": 1, "magic_attack": 1},
		"merfolk": {"speed": 2, "magic_defense": 1},
		"naga": {"strength": 1, "magic_attack": 1},
		"orc": {"strength": 2, "defense": 1},
		"fae": {"magic_attack": 2, "speed": 1},
		"titan": {"strength": 3, "defense": 2},
		"shadowkin": {"magic_attack": 1, "speed": 1}
	}
	
	if species_bonuses.has(species):
		var bonuses = species_bonuses[species]
		for stat in bonuses:
			# Apply the bonus directly to the stat property
			match stat:
				"speed":
					speed += bonuses[stat]
				"magic_attack":
					magic_attack += bonuses[stat]
				"defense":
					defense += bonuses[stat]
				"strength":
					strength += bonuses[stat]
				"magic_defense":
					magic_defense += bonuses[stat]
		print("%s is a %s - species bonuses applied" % [character_name, species]) 
