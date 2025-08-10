extends Node
class_name InventoryManager

# Inventory Manager - Handles inventory and equipment
# Manages item storage, equipment, and integration with quest system

enum EquipmentSlot {
	WEAPON,
	ARMOR,
	ACCESSORY
}

signal item_added(item_id: String, quantity: int)
signal item_removed(item_id: String, quantity: int)
signal item_used(item_id: String)
signal equipment_changed(slot: EquipmentSlot, item_id: String)
signal inventory_updated()

# Inventory data
var inventory: Dictionary = {}  # item_id -> quantity
var item_objects: Dictionary = {}  # item_id -> Item resource
var equipped_weapon: String = ""
var equipped_armor: String = ""
var equipped_accessories: Array[String] = []

# Equipment bonuses
var equipment_bonuses: Dictionary = {}

# Currency
var gold: int = 0

# Item database reference
var item_database: Dictionary = {}

func _ready():
	"""Initialize inventory manager"""
	load_item_database()

func load_item_database():
	"""Load item database from JSON"""
	var file = FileAccess.open("res://data/items/items.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		if parse_result == OK:
			# Handle the "items" wrapper in the JSON structure
			if json.data.has("items"):
				item_database = json.data["items"]
			else:
				item_database = json.data
			print("Item database loaded successfully")
		else:
			print("Failed to parse item database")
		file.close()
	else:
		print("Failed to load item database file")
		create_sample_items()

func create_sample_items():
	"""Create sample items for testing"""
	item_database = {
		"health_potion": {
			"name": "Health Potion",
			"description": "Restores 50 health points",
			"type": "consumable",
			"value": 25,
			"effects": {"health": 50},
			"usable": true,
			"stackable": true
		},
		"magic_potion": {
			"name": "Magic Potion", 
			"description": "Restores 30 magic points",
			"type": "consumable",
			"value": 30,
			"effects": {"magic": 30},
			"usable": true,
			"stackable": true
		},
		"basic_sword": {
			"name": "Basic Sword",
			"description": "A simple but reliable weapon",
			"type": "weapon",
			"value": 100,
			"damage": 15,
			"equippable": true
		},
		"leather_armor": {
			"name": "Leather Armor",
			"description": "Light armor offering basic protection",
			"type": "armor",
			"value": 80,
			"defense": 10,
			"equippable": true
		},
		"shadow_crystal": {
			"name": "Shadow Crystal",
			"description": "A rare crystal that amplifies shadow magic",
			"type": "material",
			"value": 500,
			"stackable": true
		},
		"void_essence": {
			"name": "Void Essence",
			"description": "Pure energy of the space between worlds",
			"type": "material",
			"value": 1000,
			"stackable": true
		},
		"alliance_talisman": {
			"name": "Alliance Talisman",
			"description": "A talisman that helps guide you to ancient sites",
			"type": "quest_item",
			"value": 0,
			"quest_related": true
		},
		"ancient_scroll": {
			"name": "Ancient Scroll",
			"description": "Contains knowledge of the Veil's creation",
			"type": "quest_item",
			"value": 0,
			"quest_related": true
		}
	}

func add_item(item_id: String, quantity: int = 1) -> bool:
	"""Add item to inventory"""
	if not item_database.has(item_id):
		print("Item not found: ", item_id)
		return false
	
	if inventory.has(item_id):
		inventory[item_id] += quantity
	else:
		inventory[item_id] = quantity
	
	# Emit signal
	item_added.emit(item_id, quantity)
	inventory_updated.emit()
	
	print("Added %d %s to inventory" % [quantity, item_id])
	return true

func remove_item(item_id: String, quantity: int = 1) -> bool:
	"""Remove item from inventory"""
	if not inventory.has(item_id) or inventory[item_id] < quantity:
		print("Not enough %s in inventory" % item_id)
		return false
	
	inventory[item_id] -= quantity
	if inventory[item_id] <= 0:
		inventory.erase(item_id)
	
	# Emit signal
	item_removed.emit(item_id, quantity)
	inventory_updated.emit()
	
	print("Removed %d %s from inventory" % [quantity, item_id])
	return true

func use_item(item_id: String) -> bool:
	"""Use an item"""
	if not inventory.has(item_id):
		print("Item not in inventory: ", item_id)
		return false
	
	var item_data = item_database.get(item_id, {})
	if not item_data.get("usable", false):
		print("Item is not usable: ", item_id)
		return false
	
	# Apply item effects
	apply_item_effects(item_id, item_data)
	
	# Remove one from inventory
	remove_item(item_id, 1)
	
	# Emit signal
	item_used.emit(item_id)
	
	print("Used item: ", item_id)
	return true

func apply_item_effects(_item_id: String, item_data: Dictionary):
	"""Apply the effects of an item"""
	var game_manager = get_node("/root/GameManager")
	if not game_manager or not game_manager.player_data:
		return
	
	var player_data = game_manager.player_data
	var effects = item_data.get("effects", {})
	
	for effect_type in effects:
		match effect_type:
			"health":
				var heal_amount = effects[effect_type]
				player_data.health_points = min(player_data.max_health_points, player_data.health_points + heal_amount)
				print("Healed %d health points" % heal_amount)
			"magic":
				var mana_amount = effects[effect_type]
				player_data.magic_points = min(player_data.max_magic_points, player_data.magic_points + mana_amount)
				print("Restored %d magic points" % mana_amount)

func equip_item(item_id: String, slot: EquipmentSlot) -> bool:
	"""Equip an item"""
	if not inventory.has(item_id):
		print("Item not in inventory: ", item_id)
		return false
	
	var item_data = item_database.get(item_id, {})
	if not item_data.get("equippable", false):
		print("Item is not equippable: ", item_id)
		return false
	
	match slot:
		EquipmentSlot.WEAPON:
			if equipped_weapon != "":
				unequip_item(EquipmentSlot.WEAPON)
			equipped_weapon = item_id
		EquipmentSlot.ARMOR:
			if equipped_armor != "":
				unequip_item(EquipmentSlot.ARMOR)
			equipped_armor = item_id
		EquipmentSlot.ACCESSORY:
			equipped_accessories.append(item_id)
		_:
			print("Invalid equipment slot: ", slot)
			return false
	
	# Calculate equipment bonuses
	calculate_equipment_bonuses()
	
	# Emit signal
	equipment_changed.emit(slot, item_id)
	
	print("Equipped %s to %s slot" % [item_id, slot])
	return true

func unequip_item(slot: EquipmentSlot) -> bool:
	"""Unequip an item"""
	var item_id = ""
	
	match slot:
		EquipmentSlot.WEAPON:
			item_id = equipped_weapon
			equipped_weapon = ""
		EquipmentSlot.ARMOR:
			item_id = equipped_armor
			equipped_armor = ""
		EquipmentSlot.ACCESSORY:
			if equipped_accessories.size() > 0:
				item_id = equipped_accessories.pop_back()
		_:
			print("Invalid equipment slot: ", slot)
			return false
	
	if item_id != "":
		# Calculate equipment bonuses
		calculate_equipment_bonuses()
		
		# Emit signal
		equipment_changed.emit(slot, "")
		
		print("Unequipped %s from %s slot" % [item_id, slot])
		return true
	
	return false

func calculate_equipment_bonuses():
	"""Calculate bonuses from equipped items"""
	equipment_bonuses = {}
	
	# Calculate weapon bonuses
	if equipped_weapon != "":
		var weapon_data = item_database.get(equipped_weapon, {})
		if weapon_data.has("damage"):
			equipment_bonuses["attack"] = weapon_data["damage"]
	
	# Calculate armor bonuses
	if equipped_armor != "":
		var armor_data = item_database.get(equipped_armor, {})
		if armor_data.has("defense"):
			equipment_bonuses["defense"] = armor_data["defense"]
	
	# Calculate accessory bonuses
	for accessory_id in equipped_accessories:
		var _accessory_data = item_database.get(accessory_id, {})
		# Add accessory effects here
	
	return equipment_bonuses

func get_inventory_data() -> Dictionary:
	"""Get inventory data for saving"""
	return {
		"items": inventory,
		"equipment": {
			"weapon": equipped_weapon,
			"armor": equipped_armor,
			"accessories": equipped_accessories
		},
		"gold": gold
	}

func load_inventory_data(data: Dictionary):
	"""Load inventory data from save"""
	if data.has("items"):
		inventory = data["items"]
	if data.has("equipment"):
		var equipment_data = data["equipment"]
		if equipment_data.has("weapon"):
			equipped_weapon = equipment_data["weapon"]
		if equipment_data.has("armor"):
			equipped_armor = equipment_data["armor"]
		if equipment_data.has("accessories"):
			# Convert plain Array to Array[String] with type validation
			var accessories_array = equipment_data["accessories"]
			equipped_accessories.clear()
			for accessory in accessories_array:
				if accessory is String:
					equipped_accessories.append(accessory)
	if data.has("gold"):
		gold = data["gold"]
	
	# Recalculate bonuses
	calculate_equipment_bonuses()
	
	# Emit signal
	inventory_updated.emit()

func get_item_count(item_id: String) -> int:
	"""Get the count of a specific item"""
	return inventory.get(item_id, 0)

func has_item(item_id: String, quantity: int = 1) -> bool:
	"""Check if inventory has enough of an item"""
	return get_item_count(item_id) >= quantity

func get_item_info(item_id: String) -> Dictionary:
	"""Get information about an item"""
	var item_data = item_database.get(item_id, {})
	if item_data.is_empty():
		return {}
	return item_data

func get_all_items() -> Dictionary:
	"""Get all items in inventory with their counts"""
	return inventory

func get_equipment_bonuses() -> Dictionary:
	"""Get current equipment bonuses"""
	return equipment_bonuses

func get_equipped_weapon() -> String:
	"""Get currently equipped weapon"""
	return equipped_weapon

func get_equipped_armor() -> String:
	"""Get currently equipped armor"""
	return equipped_armor

func get_equipped_accessories() -> Array[String]:
	"""Get currently equipped accessories"""
	return equipped_accessories

func add_gold(amount: int):
	"""Add gold to inventory"""
	gold += amount
	inventory_updated.emit()
	print("Added %d gold" % amount)

func remove_gold(amount: int) -> bool:
	"""Remove gold from inventory"""
	if gold < amount:
		print("Not enough gold")
		return false
	
	gold -= amount
	inventory_updated.emit()
	print("Removed %d gold" % amount)
	return true

func get_gold() -> int:
	"""Get current gold amount"""
	return gold

func create_item_from_database(item_id: String):
	"""Create an Item resource from database data"""
	var item_data = item_database.get(item_id, {})
	if item_data.is_empty():
		return null
	
	var item_script = load("res://scripts/core/Item.gd")
	var item = item_script.new()
	item.item_id = item_id
	item.item_name = item_data.get("name", "")
	item.item_description = item_data.get("description", "")
	item.value = item_data.get("value", 0)
	item.stackable = item_data.get("stackable", false)
	item.max_stack = item_data.get("max_stack", 1)
	item.current_stack = 1
	
	# Set item type
	match item_data.get("type", ""):
		"weapon":
			item.item_type = item_script.ItemType.WEAPON
			item.attack_bonus = item_data.get("damage", 0)
		"armor":
			item.item_type = item_script.ItemType.ARMOR
			item.defense_bonus = item_data.get("defense", 0)
		"consumable", "artifact":
			item.item_type = item_script.ItemType.CONSUMABLE
			item.consumable = true
			# Set use_effect based on item effects
			var effects = item_data.get("effects", {})
			if effects.has("healing"):
				item.use_effect = "heal"
			elif effects.has("mana_restoration"):
				item.use_effect = "restore_mana"
			elif effects.has("attack_power"):
				item.use_effect = "strength_potion"
			elif effects.has("fire_magic"):
				item.use_effect = "strength_potion"  # Fire magic items also increase attack
			else:
				item.use_effect = item_data.get("use_effect", "")
		"material":
			item.item_type = item_script.ItemType.MATERIAL
		_:
			item.item_type = item_script.ItemType.MATERIAL
	
	return item

func get_item_object(item_id: String):
	"""Get or create an Item resource for an item ID"""
	if not item_objects.has(item_id):
		item_objects[item_id] = create_item_from_database(item_id)
	return item_objects[item_id]

func get_inventory_objects():
	"""Get all items in inventory as Item resources"""
	var items = []
	for item_id in inventory:
		var item = get_item_object(item_id)
		if item:
			item.current_stack = inventory[item_id]
			items.append(item)
	return items 
