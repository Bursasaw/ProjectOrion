# Progression Systems Guide

## Overview

Project Orion features sophisticated progression systems inspired by top-tier games like SWGOH, providing deep character customization and long-term progression goals.

## Mod System (SWGOH-Inspired)

### Overview
Advanced mod system for character customization with deep optimization possibilities.

### Implementation
- **File**: `scripts/core/ModManager.gd` (334 lines)
- **Purpose**: Character stat customization and optimization
- **Integration**: Works with gear and progression systems

### Mod Sets
```gdscript
var mod_sets = {
    "speed": {"pieces_required": 4, "bonus": "Speed +10%"},
    "health": {"pieces_required": 2, "bonus": "Health +10%"},
    "defense": {"pieces_required": 2, "bonus": "Defense +10%"},
    "attack": {"pieces_required": 4, "bonus": "Attack +10%"},
    "critical_chance": {"pieces_required": 2, "bonus": "Critical Chance +8%"},
    "critical_damage": {"pieces_required": 4, "bonus": "Critical Damage +30%"},
    "potency": {"pieces_required": 2, "bonus": "Potency +10%"},
    "tenacity": {"pieces_required": 2, "bonus": "Tenacity +10%"}
}
```

### Mod Slots
1. **Square**: Primary attack, secondary stats
2. **Arrow**: Primary speed/attack/health/defense, secondary stats
3. **Diamond**: Primary defense, secondary stats
4. **Triangle**: Primary critical chance/damage/attack/health/defense, secondary stats
5. **Circle**: Primary health, secondary stats
6. **Cross**: Primary potency/tenacity/attack/health/defense, secondary stats

### Optimization System
- **Target Stats**: Prioritize specific stats for optimization
- **Set Bonuses**: Complete sets for additional bonuses
- **Secondary Stats**: Optimize secondary stat rolls
- **Mod Levels**: Upgrade mods for better stats

### Optimization Targets
```gdscript
var optimization_targets = {
    "speed": {"priority": 10, "description": "Maximize speed for turn frequency"},
    "attack": {"priority": 8, "description": "Maximize attack for damage output"},
    "health": {"priority": 6, "description": "Maximize health for survivability"},
    "defense": {"priority": 5, "description": "Maximize defense for damage reduction"},
    "critical_chance": {"priority": 7, "description": "Maximize critical chance for damage"},
    "critical_damage": {"priority": 9, "description": "Maximize critical damage for burst"},
    "potency": {"priority": 4, "description": "Maximize potency for status effects"},
    "tenacity": {"priority": 3, "description": "Maximize tenacity for status resistance"}
}
```

## Gear System (SWGOH-Inspired)

### Overview
Comprehensive gear progression system with multiple tiers and material requirements.

### Implementation
- **File**: `scripts/core/GearManager.gd` (321 lines)
- **Purpose**: Character equipment progression
- **Integration**: Works with mod and faction systems

### Gear Tiers
1. **Basic Gear (Tier 1)**: Health +50, Attack +10, Defense +5
2. **Improved Gear (Tier 2)**: Health +100, Attack +20, Defense +10, Speed +5
3. **Advanced Gear (Tier 3)**: Health +200, Attack +40, Defense +20, Speed +10, Critical Chance +5
4. **Expert Gear (Tier 4)**: Health +400, Attack +80, Defense +40, Speed +15, Critical Chance +10, Critical Damage +20
5. **Master Gear (Tier 5)**: Health +800, Attack +160, Defense +80, Speed +25, Critical Chance +15, Critical Damage +40
6. **Legendary Gear (Tier 6)**: Health +1600, Attack +320, Defense +160, Speed +40, Critical Chance +25, Critical Damage +60

### Gear Slots
1. **Weapon**: Primary attack stat
2. **Armor**: Primary defense stat
3. **Helmet**: Primary defense stat
4. **Gloves**: Primary attack stat
5. **Boots**: Primary speed stat
6. **Accessory**: Primary critical chance stat

### Material System
- **Basic Material**: Common crafting material
- **Improved Material**: Enhanced crafting material
- **Advanced Material**: Advanced crafting material
- **Expert Material**: Expert-level crafting material
- **Master Material**: Master-level crafting material
- **Legendary Material**: Legendary crafting material

### Upgrade System
- **Material Requirements**: Each tier requires specific materials
- **Upgrade Costs**: Exponential material costs
- **Visual Changes**: Gear appearance changes with tiers
- **Stat Improvements**: Exponential stat improvements

## Job Class System

### Overview
Character job class progression with unique abilities and stat improvements.

### Implementation
- **File**: `scripts/core/JobClassManager.gd` (359 lines)
- **Purpose**: Character job progression and ability unlocks
- **Integration**: Works with faction and gear systems

### Job Classes
1. **Warrior**: Physical combat specialist
2. **Mage**: Magical combat specialist
3. **Rogue**: Stealth and critical specialist
4. **Cleric**: Healing and support specialist
5. **Paladin**: Balanced warrior/cleric hybrid
6. **Wizard**: Advanced magical specialist
7. **Assassin**: Stealth and critical specialist
8. **Bard**: Support and buff specialist
9. **Druid**: Nature and transformation specialist
10. **Monk**: Unarmed combat specialist

### Job Progression
- **Level 1-5**: Basic job abilities
- **Level 6-10**: Advanced job abilities
- **Level 11-15**: Master job abilities
- **Level 16-20**: Legendary job abilities

### Job Abilities
Each job class has unique abilities:
- **Warrior**: Heavy Strike, Shield Bash, Berserker Rage
- **Mage**: Fireball, Ice Storm, Lightning Bolt
- **Rogue**: Backstab, Stealth, Poison Dart
- **Cleric**: Heal, Bless, Purify
- **Paladin**: Holy Strike, Divine Shield, Lay on Hands

### Job Bonuses
Each job provides stat bonuses:
- **Warrior**: +20% attack, +10% defense
- **Mage**: +20% magic attack, +10% magic defense
- **Rogue**: +15% speed, +15% critical chance
- **Cleric**: +20% healing, +10% magic defense
- **Paladin**: +10% attack, +10% defense, +10% healing

## Faction System

### Overview
Faction-based bonuses and abilities that enhance team coordination.

### Implementation
- **File**: `scripts/core/FactionSynergyManager.gd` (417 lines)
- **Purpose**: Faction bonuses and team coordination
- **Integration**: Works with job classes and team coordination

### Factions
1. **Guardians**: Defensive and protective faction
2. **Vanguard**: Offensive and aggressive faction
3. **Mystics**: Magical and mystical faction
4. **Rogues**: Stealth and critical faction
5. **Supporters**: Healing and support faction

### Faction Bonuses
Each faction provides unique bonuses:
- **Guardians**: +15% defense, +10% health
- **Vanguard**: +15% attack, +10% critical chance
- **Mystics**: +15% magic attack, +10% magic defense
- **Rogues**: +15% speed, +10% critical chance
- **Supporters**: +15% healing, +10% magic defense

### Faction Leaders
Each faction has a leader with special abilities:
- **Guardian Leader**: Shield Wall (team defense bonus)
- **Vanguard Leader**: Battle Cry (team attack bonus)
- **Mystic Leader**: Arcane Burst (team magic bonus)
- **Rogue Leader**: Shadow Strike (team critical bonus)
- **Supporter Leader**: Healing Wave (team healing bonus)

### Faction Abilities
Special abilities available to faction members:
- **Guardian**: Defensive Stance, Protective Aura
- **Vanguard**: Offensive Stance, Battle Fury
- **Mystic**: Arcane Focus, Mystic Shield
- **Rogue**: Stealth Mode, Critical Strike
- **Supporter**: Healing Focus, Support Aura

## Turn Meter System (SWGOH-Inspired)

### Overview
Speed-based turn meter system that determines action frequency.

### Implementation
- **File**: `scripts/core/TurnMeterManager.gd` (308 lines)
- **Purpose**: Turn frequency and speed management
- **Integration**: Works with AI and team coordination systems

### Turn Meter Mechanics
- **Speed-Based**: Turn meter fills based on character speed
- **Meter Manipulation**: Direct manipulation of turn meters
- **Speed Boosts**: Temporary and permanent speed increases
- **Turn Meter Effects**: Various effects on turn meter

### Speed System
- **Base Speed**: Character's base speed stat
- **Speed Modifiers**: Equipment and ability bonuses
- **Speed Boosts**: Temporary speed increases
- **Speed Penalties**: Temporary speed decreases

### Turn Meter Manipulation
- **Gain Meter**: Increase turn meter directly
- **Reduce Meter**: Decrease enemy turn meter
- **Drain Meter**: Significant turn meter reduction
- **Freeze Meter**: Stop turn meter from filling

## Ability Cooldown System

### Overview
Comprehensive ability cooldown management with reduction mechanics.

### Implementation
- **File**: `scripts/core/AbilityCooldownManager.gd` (329 lines)
- **Purpose**: Ability usage and cooldown management
- **Integration**: Works with AI and combat systems

### Cooldown Mechanics
- **Ability Usage**: Track when abilities are used
- **Cooldown Reduction**: Various ways to reduce cooldowns
- **Cooldown Reset**: Complete cooldown reset
- **Cooldown Tracking**: Monitor all ability cooldowns

### Reduction Types
1. **Equipment Reduction**: Gear that reduces cooldowns
2. **Ability Reduction**: Abilities that reduce other cooldowns
3. **Passive Reduction**: Passive effects that reduce cooldowns
4. **Temporary Reduction**: Temporary cooldown reductions

### Cooldown Categories
- **Short Cooldowns**: 1-2 turns
- **Medium Cooldowns**: 3-4 turns
- **Long Cooldowns**: 5+ turns
- **Ultimate Cooldowns**: 8+ turns

## Progression Integration

### System Interactions
All progression systems work together:
- **Mod + Gear**: Mods enhance gear bonuses
- **Job + Faction**: Job abilities work with faction bonuses
- **Gear + Turn Meter**: Gear affects speed and turn frequency
- **Ability + Cooldown**: Abilities can reduce cooldowns

### Progression Scaling
Systems scale with character progression:
- **Early Game**: Basic gear and mods
- **Mid Game**: Advanced gear and optimized mods
- **Late Game**: Master gear and perfect mods
- **End Game**: Legendary gear and ultimate mods

### Resource Management
Careful resource management required:
- **Materials**: Limited crafting materials
- **Mod Energy**: Limited mod optimization energy
- **Gear Materials**: Limited gear upgrade materials
- **Ability Points**: Limited ability learning points

## Balance Guidelines

### Power Scaling
Progression systems scale appropriately:
- **Linear Scaling**: Basic stat improvements
- **Exponential Scaling**: Advanced bonuses
- **Multiplicative Scaling**: Combined system bonuses
- **Capped Scaling**: Maximum power limits

### Resource Balance
Resources are balanced for long-term progression:
- **Material Distribution**: Fair material availability
- **Energy Costs**: Reasonable energy requirements
- **Time Investment**: Appropriate time requirements
- **Skill Requirements**: Meaningful skill requirements

### Counter-Play
All progression systems have counter-play:
- **Defensive Options**: Ways to counter offensive progression
- **Status Effects**: Status effects that bypass progression
- **Environmental Factors**: Environmental effects that affect progression
- **Team Coordination**: Team strategies that counter individual progression

## Testing and Validation

### TestBot Integration
The TestBot system tests all progression systems:
- **Mod Tests**: Test mod equipping and optimization
- **Gear Tests**: Test gear equipping and upgrading
- **Job Tests**: Test job progression and abilities
- **Faction Tests**: Test faction bonuses and abilities

### Validation Metrics
- **Progression Speed**: How quickly characters progress
- **Power Balance**: Balance between different progression paths
- **Resource Efficiency**: Efficiency of resource usage
- **Player Satisfaction**: Player satisfaction with progression

## Future Enhancements

### Planned Features
1. **Advanced Mods**: More sophisticated mod system
2. **Legendary Gear**: Additional gear tiers
3. **Job Specializations**: Advanced job specializations
4. **Faction Alliances**: Faction alliance system

### Expansion Opportunities
1. **World-Specific Progression**: Unique progression per world
2. **Character-Specific Progression**: Individual character progression
3. **Story-Driven Progression**: Narrative-driven progression
4. **Dynamic Progression**: Adaptive progression systems

## Conclusion

The progression systems in Project Orion provide deep, engaging character development with multiple paths for advancement. The modular design allows for easy expansion while maintaining balance and player satisfaction. 