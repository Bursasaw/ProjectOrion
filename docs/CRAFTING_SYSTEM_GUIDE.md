# Crafting System Guide
## Version 0.13.0 - Comprehensive Crafting System

### Overview

The crafting system in Project Orion is a comprehensive, multi-disciplinary crafting system inspired by Minecraft, Terraria, and Path of Exile. It integrates seamlessly with the skill system, achievement tracking, and progression systems to provide a deep and engaging crafting experience.

### Core Components

#### 1. CraftingSystem.gd
The main controller for the entire crafting system, handling:
- Recipe management and loading
- Station unlocking and management
- Skill progression and experience
- Quality calculation and modifiers
- Material gathering and consumption
- Achievement tracking integration

#### 2. CraftingInterface.gd
A comprehensive UI system that provides:
- Station selection and management
- Recipe browsing and filtering
- Material requirement display
- Quality prediction and display
- Crafting progress visualization
- Real-time status updates

#### 3. Data Files
- `data/crafting/crafting_recipes.json`: Complete recipe database
- Integrated with existing item systems for seamless operation

### Crafting Disciplines

The system features 8 distinct crafting disciplines, each with unique characteristics:

#### 1. Blacksmithing
- **Focus**: Weapons and armor crafting
- **Primary Materials**: Steel, Iron, Mithril, Adamantium
- **Stations**: Forge, Anvil, Grinder
- **Skill Tree**: Combat Mastery
- **Specialization**: Physical combat equipment

#### 2. Alchemy
- **Focus**: Potions and elixirs
- **Primary Materials**: Herbs, Crystals, Essences, Reagents
- **Stations**: Alchemy Lab, Distillery, Cauldron
- **Skill Tree**: Arcane Arts
- **Specialization**: Magical consumables

#### 3. Enchanting
- **Focus**: Magical item enhancement
- **Primary Materials**: Magic Crystals, Essences, Runes, Souls
- **Stations**: Enchanting Table, Rune Carver, Soul Forge
- **Skill Tree**: Arcane Arts
- **Specialization**: Magical item properties

#### 4. Engineering
- **Focus**: Mechanical devices and gadgets
- **Primary Materials**: Gears, Circuits, Energy Cells, Nanites
- **Stations**: Workbench, Assembler, Fabricator
- **Skill Tree**: Utility Expertise
- **Specialization**: Technological devices

#### 5. Cooking
- **Focus**: Food and consumables
- **Primary Materials**: Ingredients, Spices, Essences, Magical Herbs
- **Stations**: Kitchen, Oven, Smoker
- **Skill Tree**: Utility Expertise
- **Specialization**: Sustenance and buffs

#### 6. Jewelcrafting
- **Focus**: Jewelry and gems
- **Primary Materials**: Gems, Precious Metals, Crystals, Essences
- **Stations**: Jeweler's Bench, Gem Cutter, Polisher
- **Skill Tree**: Utility Expertise
- **Specialization**: Accessories and enhancements

#### 7. Reality Crafting
- **Focus**: Reality manipulation items
- **Primary Materials**: Reality Shards, Dimensional Essence, Void Crystals, Cosmic Dust
- **Stations**: Reality Forge, Dimensional Workshop, Void Cauldron
- **Skill Tree**: World Resonance
- **Specialization**: Reality-bending items

#### 8. Creation Crafting
- **Focus**: Items from pure imagination
- **Primary Materials**: Imagination Essence, Creation Crystals, Dream Dust, Inspiration
- **Stations**: Creation Forge, Inspiration Workshop, Dream Cauldron
- **Skill Tree**: World Resonance
- **Specialization**: Transcendent items

### Crafting Stations

#### Basic Stations (Level 1)
- **Forge**: Basic blacksmithing with +10% quality bonus
- **Alchemy Lab**: Basic alchemy with +10% quality bonus
- **Workbench**: Basic engineering with +10% quality bonus
- **Kitchen**: Basic cooking with +10% quality bonus

#### Advanced Stations (Level 3-10)
- **Anvil**: Advanced blacksmithing with +25% quality bonus
- **Enchanting Table**: Basic enchanting with +15% quality bonus
- **Jeweler's Bench**: Basic jewelcrafting with +15% quality bonus

#### Master Stations (Level 50+)
- **Reality Forge**: Advanced reality crafting with +75% quality bonus
- **Creation Forge**: Ultimate creation crafting with +100% quality bonus

### Quality System

The crafting system features a 7-tier quality system:

#### Quality Tiers
1. **Poor** (0.5x multiplier) - Red color
2. **Common** (1.0x multiplier) - White color
3. **Uncommon** (1.25x multiplier) - Green color
4. **Rare** (1.5x multiplier) - Blue color
5. **Epic** (2.0x multiplier) - Magenta color
6. **Legendary** (3.0x multiplier) - Orange color
7. **Mythic** (5.0x multiplier) - Purple color

#### Quality Calculation
Quality is calculated based on:
- **Station Bonus**: Each station provides a quality bonus
- **Skill Level**: Higher skill levels increase quality
- **Skill System Bonus**: Crafting quality skills from the skill tree
- **Random Variation**: ±10% random variation for unpredictability

### Recipe System

#### Recipe Structure
Each recipe contains:
- **Name and Description**: Clear identification
- **Discipline**: Which crafting discipline it belongs to
- **Requirements**: Material requirements and quantities
- **Skill Requirements**: Required skill levels and trees
- **Experience**: Experience gained from crafting
- **Result**: The item created
- **Quality Tiers**: Stats for each quality level

#### Progressive Complexity
Recipes progress from simple to complex:
- **Basic Recipes**: Simple materials, low skill requirements
- **Advanced Recipes**: Multiple materials, higher skill requirements
- **Master Recipes**: Rare materials, high skill requirements
- **Legendary Recipes**: Unique materials, very high skill requirements
- **Cosmic Recipes**: Transcendent materials, maximum skill requirements

### Material System

#### Material Sources
Materials can be gathered from various sources:
- **Steel**: Iron mines, blacksmith shops, scrap yards
- **Magic Crystal**: Crystal caves, magic shops, enemy drops
- **Fire Crystal**: Volcanic caves, fire realm, dragon lairs
- **Void Essence**: Void rifts, dimensional pockets, reality tears
- **Cosmic Essence**: Cosmic nexus, star forge, creation well

#### Gathering Mechanics
- **Success Chance**: Based on player level and gathering skill
- **Yield Calculation**: Base yield × skill multiplier × quality variation
- **Tool Requirements**: Different tools for different materials
- **Location Requirements**: Specific locations for rare materials

### Skill Progression

#### Experience System
- **Base Experience**: Each recipe provides base experience
- **Quality Bonus**: Higher quality items grant more experience
- **Level Requirements**: Experience needed increases with level
- **Skill Bonuses**: Higher levels provide quality bonuses

#### Level Progression
- **Level 1**: Start with basic crafting abilities
- **Level 5**: Unlock advanced recipes and stations
- **Level 10**: Master basic crafting techniques
- **Level 25**: Expert crafting with high quality
- **Level 50**: Master crafting with legendary quality
- **Level 75**: Transcendent crafting with mythic quality

### Integration Systems

#### Skill System Integration
- **Crafting Quality Skills**: Skills that improve crafting quality
- **Material Gathering Skills**: Skills that improve material gathering
- **Station Unlocking**: Skills unlock new crafting stations
- **Recipe Unlocking**: Skills unlock new recipes

#### Achievement System Integration
- **Crafting Achievements**: Track items crafted, quality achieved
- **Discipline Mastery**: Track mastery of each crafting discipline
- **Material Gathering**: Track materials gathered and sources
- **Quality Milestones**: Track high-quality and legendary crafts

#### Inventory System Integration
- **Material Storage**: Materials stored in inventory
- **Item Creation**: Crafted items added to inventory
- **Requirement Checking**: Verify material availability
- **Consumption**: Remove materials when crafting

### UI System

#### CraftingInterface.gd Features
- **Station Selection**: Choose from available crafting stations
- **Recipe Browsing**: View recipes available at selected station
- **Material Display**: Show required materials and availability
- **Quality Prediction**: Predict quality before crafting
- **Progress Visualization**: Show crafting progress and status
- **Real-time Updates**: Update interface based on system changes

#### UI Components
- **Station List**: Left panel showing available stations
- **Recipe List**: Right panel showing available recipes
- **Material Panel**: Shows material requirements and availability
- **Quality Display**: Shows predicted quality and tier
- **Craft Button**: Initiates crafting process
- **Progress Bar**: Shows crafting progress
- **Status Label**: Shows current status and results

### Testing Framework

#### Comprehensive Test Suite
The crafting system includes 10 comprehensive tests:

1. **test_crafting_system_initialization()**: Test system startup
2. **test_crafting_recipes_loading()**: Test recipe loading
3. **test_crafting_stations()**: Test station functionality
4. **test_crafting_skills()**: Test skill progression
5. **test_crafting_quality_calculation()**: Test quality calculation
6. **test_crafting_material_requirements()**: Test material system
7. **test_crafting_experience_system()**: Test experience and leveling
8. **test_crafting_achievements()**: Test achievement integration
9. **test_crafting_disciplines()**: Test discipline system
10. **test_crafting_integration()**: Test system integration

### Usage Examples

#### Basic Crafting
```gdscript
# Get crafting system reference
var crafting_system = get_node("/root/CraftingSystem")

# Craft a basic sword
var result = crafting_system.craft_item("basic_sword", "forge")
if result.success:
    print("Crafted ", result.item_id, " with quality ", result.quality)
```

#### Material Gathering
```gdscript
# Gather materials
crafting_system.gather_material("steel", "iron_mine", 1)
```

#### Station Unlocking
```gdscript
# Unlock a new station
var unlocked = crafting_system.unlock_station("anvil")
```

#### Quality Calculation
```gdscript
# Calculate predicted quality
var recipe = crafting_system.crafting_recipes["basic_sword"]
var station = crafting_system.crafting_stations["forge"]
var quality = crafting_system.calculate_crafting_quality(recipe, station)
```

### Performance Optimization

#### Caching System
- **Recipe Caching**: Frequently accessed recipes are cached
- **Quality Caching**: Quality calculations are cached
- **Material Caching**: Material data is cached for performance
- **Station Caching**: Station data is cached for quick access

#### Lazy Loading
- **Recipe Loading**: Recipes loaded only when needed
- **Station Loading**: Stations loaded based on unlock status
- **Material Loading**: Materials loaded based on availability
- **Quality Loading**: Quality calculations performed on demand

### Future Enhancements

#### Planned Features
1. **Crafting Guilds**: Specialized crafting organizations
2. **Crafting Contests**: Competitive crafting events
3. **Crafting Markets**: Player-driven economy
4. **Crafting Quests**: Crafting-specific quest lines
5. **Crafting Reputation**: Reputation system for crafters

#### Technical Improvements
1. **Advanced UI**: More sophisticated crafting interface
2. **Crafting Animations**: Visual crafting animations
3. **Sound Integration**: Crafting sound effects
4. **Network Synchronization**: Multiplayer crafting
5. **Mod Support**: User-created recipes and disciplines

### Conclusion

The crafting system in Project Orion represents a comprehensive, deep, and engaging crafting experience that integrates seamlessly with all other game systems. With its 8 disciplines, 9 stations, 7-tier quality system, and extensive integration, it provides players with a rich and rewarding crafting experience that scales from basic crafting to transcendent creation.

The system is fully implemented, tested, and ready for integration with the game's UI and other systems. With its modular design, comprehensive testing framework, and extensive documentation, it provides a solid foundation for future enhancements and expansions. 