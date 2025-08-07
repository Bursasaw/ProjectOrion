extends Node

# CraftingSystem - Comprehensive crafting system inspired by Minecraft, Terraria, and Path of Exile
# Integrates with SkillSystem, AchievementTracker, and GearManager
# Version 0.13.0

signal recipe_crafted(recipe_id: String, result_item: String, quality: float)
signal crafting_station_unlocked(station_id: String, station_data: Dictionary)
signal crafting_skill_leveled_up(skill_type: String, new_level: int, experience: int)
signal material_gathered(material_id: String, amount: int, location: String)
signal crafting_failed(recipe_id: String, reason: String)

# Core crafting data
var crafting_recipes: Dictionary = {}
var crafting_stations: Dictionary = {}
var crafting_skills: Dictionary = {}
var crafting_materials: Dictionary = {}
var crafting_history: Array = []

# Crafting stations and their capabilities
var available_stations: Dictionary = {}
var unlocked_stations: Array[String] = []

# Skill progression tracking
var skill_experience: Dictionary = {}
var skill_levels: Dictionary = {}
var skill_quality_bonuses: Dictionary = {}

# Material gathering and processing
var material_sources: Dictionary = {}
var processing_recipes: Dictionary = {}

# Quality and rarity system
var quality_multipliers: Dictionary = {
	"poor": 0.5,
	"common": 1.0,
	"uncommon": 1.25,
	"rare": 1.5,
	"epic": 2.0,
	"legendary": 3.0,
	"mythic": 5.0
}

# Crafting disciplines
var crafting_disciplines: Dictionary = {
	"blacksmithing": {
		"name": "Blacksmithing",
		"description": "Craft weapons and armor",
		"primary_materials": ["steel", "iron", "mithril", "adamantium"],
		"stations": ["forge", "anvil", "grinder"],
		"skill_tree": "combat_mastery"
	},
	"alchemy": {
		"name": "Alchemy",
		"description": "Brew potions and elixirs",
		"primary_materials": ["herbs", "crystals", "essences", "reagents"],
		"stations": ["alchemy_lab", "distillery", "cauldron"],
		"skill_tree": "arcane_arts"
	},
	"enchanting": {
		"name": "Enchanting",
		"description": "Enchant items with magical properties",
		"primary_materials": ["magic_crystals", "essences", "runes", "souls"],
		"stations": ["enchanting_table", "rune_carver", "soul_forge"],
		"skill_tree": "arcane_arts"
	},
	"engineering": {
		"name": "Engineering",
		"description": "Create mechanical devices and gadgets",
		"primary_materials": ["gears", "circuits", "energy_cells", "nanites"],
		"stations": ["workbench", "assembler", "fabricator"],
		"skill_tree": "utility_expertise"
	},
	"cooking": {
		"name": "Cooking",
		"description": "Prepare food and consumables",
		"primary_materials": ["ingredients", "spices", "essences", "magical_herbs"],
		"stations": ["kitchen", "oven", "smoker"],
		"skill_tree": "utility_expertise"
	},
	"jewelcrafting": {
		"name": "Jewelcrafting",
		"description": "Create jewelry and gems",
		"primary_materials": ["gems", "precious_metals", "crystals", "essences"],
		"stations": ["jewelers_bench", "gem_cutter", "polisher"],
		"skill_tree": "utility_expertise"
	},
	"reality_crafting": {
		"name": "Reality Crafting",
		"description": "Manipulate reality to create impossible items",
		"primary_materials": ["reality_shards", "dimensional_essence", "void_crystals", "cosmic_dust"],
		"stations": ["reality_forge", "dimensional_workshop", "void_cauldron"],
		"skill_tree": "world_resonance"
	},
	"creation_crafting": {
		"name": "Creation Crafting",
		"description": "Create items from pure imagination",
		"primary_materials": ["imagination_essence", "creation_crystals", "dream_dust", "inspiration"],
		"stations": ["creation_forge", "inspiration_workshop", "dream_cauldron"],
		"skill_tree": "world_resonance"
	}
}

func _ready():
	"""Initialize the crafting system"""
	print("⚒️ CraftingSystem: Initializing comprehensive crafting system...")
	
	# Load crafting data
	load_crafting_recipes()
	load_crafting_stations()
	load_material_sources()
	
	# Initialize crafting skills
	initialize_crafting_skills()
	
	# Set up default stations
	setup_default_stations()
	
	# Connect to other systems
	connect_to_systems()
	
	print("✅ CraftingSystem: Crafting system initialized successfully")

func load_crafting_recipes():
	"""Load crafting recipes from data files"""
	var file = FileAccess.open("res://data/crafting/crafting_recipes.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		if parse_result == OK:
			var data = json.data
			if data.has("crafting_recipes"):
				crafting_recipes = data.crafting_recipes
				print("📚 CraftingSystem: Loaded ", crafting_recipes.size(), " crafting recipes")
		else:
			print("❌ CraftingSystem: Failed to parse crafting recipes JSON")
		file.close()
	else:
		print("❌ CraftingSystem: Could not open crafting recipes file")

func load_crafting_stations():
	"""Load crafting station definitions"""
	crafting_stations = {
		"forge": {
			"name": "Forge",
			"description": "Basic blacksmithing station",
			"discipline": "blacksmithing",
			"unlock_requirement": {"level": 1, "skill": "basic_crafting"},
			"quality_bonus": 0.1,
			"crafting_speed": 1.0
		},
		"anvil": {
			"name": "Anvil",
			"description": "Advanced blacksmithing station",
			"discipline": "blacksmithing",
			"unlock_requirement": {"level": 10, "skill": "advanced_crafting"},
			"quality_bonus": 0.25,
			"crafting_speed": 1.5
		},
		"alchemy_lab": {
			"name": "Alchemy Lab",
			"description": "Basic alchemy station",
			"discipline": "alchemy",
			"unlock_requirement": {"level": 1, "skill": "basic_crafting"},
			"quality_bonus": 0.1,
			"crafting_speed": 1.0
		},
		"enchanting_table": {
			"name": "Enchanting Table",
			"description": "Basic enchanting station",
			"discipline": "enchanting",
			"unlock_requirement": {"level": 5, "skill": "basic_crafting"},
			"quality_bonus": 0.15,
			"crafting_speed": 1.2
		},
		"workbench": {
			"name": "Workbench",
			"description": "Basic engineering station",
			"discipline": "engineering",
			"unlock_requirement": {"level": 1, "skill": "basic_crafting"},
			"quality_bonus": 0.1,
			"crafting_speed": 1.0
		},
		"kitchen": {
			"name": "Kitchen",
			"description": "Basic cooking station",
			"discipline": "cooking",
			"unlock_requirement": {"level": 1, "skill": "basic_crafting"},
			"quality_bonus": 0.1,
			"crafting_speed": 1.0
		},
		"jewelers_bench": {
			"name": "Jeweler's Bench",
			"description": "Basic jewelcrafting station",
			"discipline": "jewelcrafting",
			"unlock_requirement": {"level": 3, "skill": "basic_crafting"},
			"quality_bonus": 0.15,
			"crafting_speed": 1.1
		},
		"reality_forge": {
			"name": "Reality Forge",
			"description": "Advanced reality crafting station",
			"discipline": "reality_crafting",
			"unlock_requirement": {"level": 50, "skill": "reality_crafting"},
			"quality_bonus": 0.75,
			"crafting_speed": 2.0
		},
		"creation_forge": {
			"name": "Creation Forge",
			"description": "Ultimate creation crafting station",
			"discipline": "creation_crafting",
			"unlock_requirement": {"level": 75, "skill": "creation_crafting"},
			"quality_bonus": 1.0,
			"crafting_speed": 3.0
		}
	}
	
	print("📚 CraftingSystem: Loaded ", crafting_stations.size(), " crafting stations")

func load_material_sources():
	"""Load material source locations and gathering requirements"""
	material_sources = {
		"wood": {
			"sources": ["forest", "lumber_mill", "woodcutter_camp"],
			"gathering_skill": "woodcutting",
			"gathering_tool": "axe",
			"base_yield": 2,
			"quality_variation": 0.1
		},
		"steel": {
			"sources": ["iron_mine", "blacksmith_shop", "scrap_yard"],
			"gathering_skill": "mining",
			"gathering_tool": "pickaxe",
			"base_yield": 1,
			"quality_variation": 0.2
		},
		"magic_crystal": {
			"sources": ["crystal_cave", "magic_shop", "enemy_drops"],
			"gathering_skill": "mining",
			"gathering_tool": "crystal_pickaxe",
			"base_yield": 1,
			"quality_variation": 0.5
		},
		"fire_crystal": {
			"sources": ["volcanic_cave", "fire_realm", "dragon_lair"],
			"gathering_skill": "mining",
			"gathering_tool": "fire_pickaxe",
			"base_yield": 1,
			"quality_variation": 0.8
		},
		"void_essence": {
			"sources": ["void_rift", "dimensional_pocket", "reality_tear"],
			"gathering_skill": "reality_manipulation",
			"gathering_tool": "void_collector",
			"base_yield": 1,
			"quality_variation": 1.0
		},
		"cosmic_essence": {
			"sources": ["cosmic_nexus", "star_forge", "creation_well"],
			"gathering_skill": "creation_magic",
			"gathering_tool": "cosmic_collector",
			"base_yield": 1,
			"quality_variation": 1.5
		}
	}
	
	print("📚 CraftingSystem: Loaded ", material_sources.size(), " material sources")

func initialize_crafting_skills():
	"""Initialize crafting skill tracking"""
	for discipline in crafting_disciplines:
		skill_experience[discipline] = 0
		skill_levels[discipline] = 1
		skill_quality_bonuses[discipline] = 0.0
	
	print("📊 CraftingSystem: Initialized crafting skills")

func setup_default_stations():
	"""Set up default unlocked stations"""
	unlocked_stations = ["forge", "alchemy_lab", "workbench", "kitchen"]
	print("⚒️ CraftingSystem: Default stations unlocked: ", unlocked_stations)

func connect_to_systems():
	"""Connect to other game systems"""
	var skill_system_node = get_node_or_null("/root/SkillSystem")
	if skill_system_node:
		skill_system_node.skill_unlocked.connect(_on_skill_unlocked)
	
	var achievement_tracker_node = get_node_or_null("/root/AchievementTracker")
	if achievement_tracker_node:
		achievement_tracker_node.achievement_completed.connect(_on_achievement_completed)

func craft_item(recipe_id: String, station_id: String) -> Dictionary:
	"""Craft an item using a specific recipe and station"""
	var result = {
		"success": false,
		"item_id": "",
		"quality": 0.0,
		"message": ""
	}
	
	# Check if recipe exists
	if not crafting_recipes.has(recipe_id):
		result.message = "Recipe not found: " + recipe_id
		crafting_failed.emit(recipe_id, result.message)
		return result
	
	# Check if station is unlocked
	if not unlocked_stations.has(station_id):
		result.message = "Station not unlocked: " + station_id
		crafting_failed.emit(recipe_id, result.message)
		return result
	
	var recipe = crafting_recipes[recipe_id]
	var station = crafting_stations[station_id]
	
	# Check skill requirements
	if not check_skill_requirements(recipe, station):
		result.message = "Skill requirements not met"
		crafting_failed.emit(recipe_id, result.message)
		return result
	
	# Check material requirements
	if not check_material_requirements(recipe):
		result.message = "Material requirements not met"
		crafting_failed.emit(recipe_id, result.message)
		return result
	
	# Consume materials
	consume_materials(recipe.requirements)
	
	# Calculate quality
	var quality = calculate_crafting_quality(recipe, station)
	
	# Create the item
	var item_id = recipe.result
	var crafted_item = create_crafted_item(item_id, quality)
	
	# Add to inventory
	add_item_to_inventory(crafted_item)
	
	# Grant experience
	grant_crafting_experience(recipe, station, quality)
	
	# Track achievement progress
	track_crafting_achievements(recipe, quality)
	
	# Add to history
	add_crafting_history(recipe_id, item_id, quality, station_id)
	
	result.success = true
	result.item_id = item_id
	result.quality = quality
	result.message = "Successfully crafted " + recipe.name
	
	recipe_crafted.emit(recipe_id, item_id, quality)
	
	print("⚒️ CraftingSystem: Crafted ", recipe.name, " with quality ", quality)
	
	return result

func check_skill_requirements(recipe: Dictionary, station: Dictionary) -> bool:
	"""Check if player meets skill requirements for crafting"""
	var skill_system_node = get_node_or_null("/root/SkillSystem")
	if not skill_system_node:
		return false
	
	# Check skill requirements
	if recipe.has("skill_requirement"):
		for skill_tree in recipe.skill_requirement:
			var required_level = recipe.skill_requirement[skill_tree]
			var current_level = skill_system_node.player_level
			
			if current_level < required_level:
				return false
	
	# Check discipline level
	var discipline = station.discipline
	var required_discipline_level = recipe.get("discipline_level", 1)
	var current_discipline_level = skill_levels.get(discipline, 1)
	
	if current_discipline_level < required_discipline_level:
		return false
	
	return true

func check_material_requirements(recipe: Dictionary) -> bool:
	"""Check if player has required materials"""
	var inventory_manager = get_node_or_null("/root/GameManager")
	if inventory_manager and inventory_manager.inventory_manager:
		inventory_manager = inventory_manager.inventory_manager
	
	if not inventory_manager:
		return false
	
	for material_id in recipe.requirements:
		var required_amount = recipe.requirements[material_id]
		var available_amount = inventory_manager.get_item_count(material_id)
		
		if available_amount < required_amount:
			return false
	
	return true

func get_material_count(material_id: String) -> int:
	"""Get the count of a specific material in inventory"""
	var inventory_manager = get_node_or_null("/root/GameManager")
	if inventory_manager and inventory_manager.inventory_manager:
		inventory_manager = inventory_manager.inventory_manager
	
	if not inventory_manager:
		return 0
	
	return inventory_manager.get_item_count(material_id)

func consume_materials(requirements: Dictionary):
	"""Consume materials from inventory"""
	var inventory_manager = get_node_or_null("/root/GameManager")
	if inventory_manager and inventory_manager.inventory_manager:
		inventory_manager = inventory_manager.inventory_manager
	
	if not inventory_manager:
		return
	
	for material_id in requirements:
		var amount = requirements[material_id]
		inventory_manager.remove_item(material_id, amount)

func calculate_crafting_quality(_recipe: Dictionary, station: Dictionary) -> float:
	"""Calculate the quality of a crafted item"""
	var base_quality = 1.0
	
	# Station quality bonus
	base_quality += station.quality_bonus
	
	# Skill level bonus
	var discipline = station.discipline
	var skill_level = skill_levels.get(discipline, 1)
	base_quality += skill_level * 0.1
	
	# Skill system bonus
	var skill_system_node = get_node_or_null("/root/SkillSystem")
	if skill_system_node:
		var crafting_quality_bonus = skill_system_node.get_skill_effect("crafting_quality")
		base_quality += crafting_quality_bonus
	
	# Random variation
	var variation = randf_range(-0.1, 0.1)
	base_quality += variation
	
	# Clamp to reasonable range
	base_quality = clamp(base_quality, 0.1, 5.0)
	
	return base_quality

func create_crafted_item(item_id: String, quality: float) -> Dictionary:
	"""Create a crafted item with quality modifiers"""
	var item_data = {
		"id": item_id,
		"quality": quality,
		"crafted_by": "player",
		"crafting_timestamp": Time.get_unix_time_from_system()
	}
	
	# Apply quality modifiers to item stats
	# This would integrate with the item system
	
	return item_data

func add_item_to_inventory(item_data: Dictionary):
	"""Add crafted item to inventory"""
	var game_manager = get_node_or_null("/root/GameManager")
	var inventory_manager = null
	
	if game_manager and game_manager.inventory_manager:
		inventory_manager = game_manager.inventory_manager
	
	if inventory_manager:
		inventory_manager.add_item(item_data.id, 1, item_data)

func grant_crafting_experience(recipe: Dictionary, station: Dictionary, quality: float):
	"""Grant experience for crafting"""
	var discipline = station.discipline
	var base_experience = recipe.get("experience", 10)
	
	# Quality bonus
	var quality_bonus = quality * 0.5
	var total_experience = base_experience + quality_bonus
	
	# Add experience
	skill_experience[discipline] += total_experience
	
	# Check for level up
	check_skill_level_up(discipline)
	
	# Track for achievements
	var achievement_tracker_node = get_node_or_null("/root/AchievementTracker")
	if achievement_tracker_node:
		achievement_tracker_node.track_progress("crafting_experience", total_experience)

func check_skill_level_up(discipline: String):
	"""Check if crafting skill should level up"""
	var current_level = skill_levels[discipline]
	var current_experience = skill_experience[discipline]
	var experience_needed = current_level * 100
	
	if current_experience >= experience_needed:
		skill_levels[discipline] += 1
		skill_quality_bonuses[discipline] += 0.05
		
		print("🎉 CraftingSystem: ", discipline, " leveled up to ", skill_levels[discipline])
		crafting_skill_leveled_up.emit(discipline, skill_levels[discipline], current_experience)

func track_crafting_achievements(recipe: Dictionary, quality: float):
	"""Track crafting achievements"""
	var achievement_tracker_node = get_node_or_null("/root/AchievementTracker")
	if not achievement_tracker_node:
		return
	
	# Track items crafted
	achievement_tracker_node.track_progress("items_crafted", 1)
	
	# Track high quality crafts
	if quality >= 2.0:
		achievement_tracker_node.track_progress("high_quality_crafts", 1)
	
	# Track legendary crafts
	if quality >= 3.0:
		achievement_tracker_node.track_progress("legendary_crafts", 1)

func add_crafting_history(recipe_id: String, item_id: String, quality: float, station_id: String):
	"""Add crafting action to history"""
	var history_entry = {
		"timestamp": Time.get_unix_time_from_system(),
		"recipe_id": recipe_id,
		"item_id": item_id,
		"quality": quality,
		"station_id": station_id,
		"skill_levels": skill_levels.duplicate()
	}
	
	crafting_history.append(history_entry)
	
	# Keep only last 100 entries
	if crafting_history.size() > 100:
		crafting_history.pop_front()

func gather_material(material_id: String, location: String, amount: int = 1):
	"""Gather materials from a location"""
	if not material_sources.has(material_id):
		print("❌ CraftingSystem: Unknown material: ", material_id)
		return
	
	var source_data = material_sources[material_id]
	var skill_system = get_node_or_null("/root/SkillSystem")
	
	# Calculate gathering success and yield
	var skill_level = 1
	
	if skill_system:
		skill_level = skill_system.player_level
	
	var success_chance = min(0.9, 0.5 + (skill_level * 0.05))
	var gathered_amount = 0
	
	if randf() < success_chance:
		var base_yield = source_data.base_yield
		var yield_multiplier = 1.0 + (skill_level * 0.1)
		
		gathered_amount = int(base_yield * yield_multiplier * amount)
		
		# Add to inventory
		var game_manager = get_node_or_null("/root/GameManager")
		if game_manager and game_manager.inventory_manager:
			game_manager.inventory_manager.add_item(material_id, gathered_amount)
		
		# Track achievement progress
		var achievement_tracker_node = get_node_or_null("/root/AchievementTracker")
		if achievement_tracker_node:
			achievement_tracker_node.track_progress("materials_gathered", gathered_amount)
		
		material_gathered.emit(material_id, gathered_amount, location)
		
		print("⛏️ CraftingSystem: Gathered ", gathered_amount, " ", material_id, " from ", location)
	else:
		print("❌ CraftingSystem: Failed to gather ", material_id, " from ", location)

func unlock_station(station_id: String) -> bool:
	"""Unlock a new crafting station"""
	if not crafting_stations.has(station_id):
		print("❌ CraftingSystem: Unknown station: ", station_id)
		return false
	
	var station = crafting_stations[station_id]
	var skill_system_node = get_node_or_null("/root/SkillSystem")
	
	# Check unlock requirements
	var requirements = station.unlock_requirement
	if skill_system_node.player_level < requirements.level:
		print("❌ CraftingSystem: Level requirement not met for ", station_id)
		return false
	
	if requirements.has("skill"):
		var skill_id = requirements.skill
		if not skill_system_node.player_skills.has(skill_id):
			print("❌ CraftingSystem: Skill requirement not met for ", station_id)
			return false
	
	# Unlock the station
	if not unlocked_stations.has(station_id):
		unlocked_stations.append(station_id)
		crafting_station_unlocked.emit(station_id, station)
		print("🔓 CraftingSystem: Unlocked station: ", station.name)
	
	return true

func get_available_recipes(station_id: String) -> Array[Dictionary]:
	"""Get recipes available at a specific station"""
	var available_recipes: Array[Dictionary] = []
	
	if not unlocked_stations.has(station_id):
		return available_recipes
	
	var station = crafting_stations[station_id]
	var discipline = station.discipline
	
	for recipe_id in crafting_recipes:
		var recipe = crafting_recipes[recipe_id]
		
		# Check if recipe can be crafted at this station
		if recipe.get("discipline", "") == discipline:
			# Check if player meets requirements
			if check_skill_requirements(recipe, station):
				available_recipes.append(recipe)
	
	return available_recipes

func get_crafting_summary() -> Dictionary:
	"""Get a summary of crafting progress"""
	return {
		"total_crafts": crafting_history.size(),
		"skill_levels": skill_levels,
		"unlocked_stations": unlocked_stations,
		"recent_crafts": crafting_history.slice(-5) if crafting_history.size() > 5 else crafting_history
	}

func _on_skill_unlocked(skill_id: String, _skill_data: Dictionary):
	"""Handle skill unlocking for crafting"""
	# Check if this skill unlocks any stations
	for station_id in crafting_stations:
		var station = crafting_stations[station_id]
		var requirements = station.unlock_requirement
		
		if requirements.has("skill") and requirements.skill == skill_id:
			unlock_station(station_id)

func _on_achievement_completed(achievement_id: String, _tier: String, _reward: Dictionary):
	"""Handle achievement completion for crafting"""
	if achievement_id == "crafting_master":
		# Grant special crafting abilities
		print("🏆 CraftingSystem: Crafting master achievement completed!") 
