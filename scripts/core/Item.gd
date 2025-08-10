extends Resource
class_name Item

# Item - Base class for all game items
# Handles weapons, armor, consumables, and magical artifacts

enum ItemType {
	WEAPON,
	ARMOR,
	ACCESSORY,
	CONSUMABLE,
	MATERIAL,
	QUEST,
	MAGICAL_ARTIFACT
}

enum ItemRarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY,
	MYTHIC
}

# Basic item properties
@export var item_id: String = ""
@export var item_name: String = ""
@export var item_description: String = ""
@export var item_type = ItemType.MATERIAL
@export var item_rarity = ItemRarity.COMMON
@export var item_icon: Texture2D = null
@export var item_model: String = ""  # 3D model path if applicable

# Item stats
@export var weight: float = 0.0
@export var value: int = 0
@export var stackable: bool = false
@export var max_stack: int = 1
@export var current_stack: int = 1

# Equipment stats (for weapons and armor)
@export var attack_bonus: int = 0
@export var defense_bonus: int = 0
@export var magic_bonus: int = 0
@export var speed_bonus: int = 0
@export var health_bonus: int = 0
@export var magic_points_bonus: int = 0

# Special properties
@export var magical_properties: Array[String] = []
@export var enchantments: Array[String] = []
@export var requirements: Dictionary = {}

# Usage properties
@export var consumable: bool = false
@export var use_effect: String = ""
@export var cooldown: float = 0.0

# Quest properties
@export var quest_item: bool = false
@export var quest_id: String = ""

func _init():
	# Set default values
	if item_id == "":
		item_id = item_name.to_lower().replace(" ", "_")

func get_display_name() -> String:
	"""Get the display name with rarity color"""
	var rarity_colors = {
		ItemRarity.COMMON: "White",
		ItemRarity.UNCOMMON: "Green", 
		ItemRarity.RARE: "Blue",
		ItemRarity.EPIC: "Purple",
		ItemRarity.LEGENDARY: "Orange",
		ItemRarity.MYTHIC: "Red"
	}
	
	var color = rarity_colors.get(item_rarity, "White")
	return "[color=%s]%s[/color]" % [color, item_name]

func get_full_description() -> String:
	"""Get full item description with stats"""
	var desc = item_description
	
	# Add stat bonuses if any
	var bonuses = []
	if attack_bonus > 0:
		bonuses.append("Attack +%d" % attack_bonus)
	if defense_bonus > 0:
		bonuses.append("Defense +%d" % defense_bonus)
	if magic_bonus > 0:
		bonuses.append("Magic +%d" % magic_bonus)
	if speed_bonus > 0:
		bonuses.append("Speed +%d" % speed_bonus)
	if health_bonus > 0:
		bonuses.append("Health +%d" % health_bonus)
	if magic_points_bonus > 0:
		bonuses.append("Magic Points +%d" % magic_points_bonus)
	
	if bonuses.size() > 0:
		desc += "\n\nBonuses:\n" + "\n".join(bonuses)
	
	# Add magical properties
	if magical_properties.size() > 0:
		desc += "\n\nMagical Properties:\n"
		for property in magical_properties:
			desc += "• %s\n" % property
	
	# Add enchantments
	if enchantments.size() > 0:
		desc += "\n\nEnchantments:\n"
		for enchantment in enchantments:
			desc += "• %s\n" % enchantment
	
	return desc

func can_use(player_data) -> bool:
	"""Check if player can use this item"""
	# Check requirements
	for requirement in requirements:
		match requirement:
			"level":
				if player_data.level < requirements[requirement]:
					return false
			"strength":
				if player_data.strength < requirements[requirement]:
					return false
			"dexterity":
				if player_data.dexterity < requirements[requirement]:
					return false
			"intelligence":
				if player_data.intelligence < requirements[requirement]:
					return false
			"skill":
				if not player_data.has_skill(requirements[requirement]):
					return false
	
	return true

func use_item(player_data) -> bool:
	"""Use the item and apply its effects"""
	if not can_use(player_data):
		return false
	
	if consumable:
		# Apply use effect
		apply_use_effect(player_data)
		
		# Reduce stack
		if stackable:
			current_stack -= 1
			if current_stack <= 0:
				return true  # Item should be removed
		
		return true
	
	return false

func apply_use_effect(player_data):
	"""Apply the item's use effect to the player"""
	match use_effect:
		"heal":
			var heal_amount = min(50, player_data.constitution * 10)
			player_data.health_points = min(player_data.health_points + heal_amount, player_data.max_health_points)
		"restore_mana":
			var mana_amount = min(30, player_data.intelligence * 5)
			player_data.magic_points = min(player_data.magic_points + mana_amount, player_data.max_magic_points)
		"strength_potion":
			player_data.strength += 2
			player_data.calculate_derived_stats()
		"intelligence_potion":
			player_data.intelligence += 2
			player_data.calculate_derived_stats()
		"experience_potion":
			player_data.gain_experience(100)
		_:
			print("Unknown use effect: %s" % use_effect)

func get_equipment_bonuses() -> Dictionary:
	"""Get all equipment bonuses as a dictionary"""
	return {
		"attack": attack_bonus,
		"defense": defense_bonus,
		"magic": magic_bonus,
		"speed": speed_bonus,
		"health": health_bonus,
		"magic_points": magic_points_bonus
	}

func is_equipment() -> bool:
	"""Check if item is equipment"""
	return item_type == ItemType.WEAPON or item_type == ItemType.ARMOR or item_type == ItemType.ACCESSORY

func is_weapon() -> bool:
	"""Check if item is a weapon"""
	return item_type == ItemType.WEAPON

func is_armor() -> bool:
	"""Check if item is armor"""
	return item_type == ItemType.ARMOR

func is_accessory() -> bool:
	"""Check if item is an accessory"""
	return item_type == ItemType.ACCESSORY

func is_consumable() -> bool:
	"""Check if item is consumable"""
	return consumable

func is_stackable() -> bool:
	"""Check if item can be stacked"""
	return stackable

func can_stack_with(other_item) -> bool:
	"""Check if this item can stack with another item"""
	return stackable and item_id == other_item.item_id and current_stack < max_stack

func add_to_stack(amount: int) -> int:
	"""Add items to stack, returns leftover amount"""
	if not stackable:
		return amount
	
	var space_left = max_stack - current_stack
	var to_add = min(amount, space_left)
	current_stack += to_add
	return amount - to_add

func remove_from_stack(amount: int) -> bool:
	"""Remove items from stack, returns true if stack is empty"""
	if not stackable:
		return false
	
	current_stack = max(0, current_stack - amount)
	return current_stack <= 0

func get_stack_size() -> int:
	"""Get current stack size"""
	return current_stack

func get_max_stack() -> int:
	"""Get maximum stack size"""
	return max_stack

func get_value() -> int:
	"""Get item value"""
	return value

func get_weight() -> float:
	"""Get item weight"""
	return weight

func get_rarity_name() -> String:
	"""Get rarity name as string"""
	var rarity_names = {
		ItemRarity.COMMON: "Common",
		ItemRarity.UNCOMMON: "Uncommon",
		ItemRarity.RARE: "Rare",
		ItemRarity.EPIC: "Epic",
		ItemRarity.LEGENDARY: "Legendary",
		ItemRarity.MYTHIC: "Mythic"
	}
	return rarity_names.get(item_rarity, "Unknown")

func get_type_name() -> String:
	"""Get item type name as string"""
	var type_names = {
		ItemType.WEAPON: "Weapon",
		ItemType.ARMOR: "Armor",
		ItemType.ACCESSORY: "Accessory",
		ItemType.CONSUMABLE: "Consumable",
		ItemType.MATERIAL: "Material",
		ItemType.QUEST: "Quest Item",
		ItemType.MAGICAL_ARTIFACT: "Magical Artifact"
	}
	return type_names.get(item_type, "Unknown") 