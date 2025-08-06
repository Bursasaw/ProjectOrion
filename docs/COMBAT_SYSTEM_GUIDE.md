# Combat System Guide

## Overview

The combat system in Project Orion is a sophisticated turn-based system with multiple layers of mechanics that create deep, strategic gameplay. This guide will walk you through all the components and how they work together.

## Table of Contents

1. [Basic Combat Flow](#basic-combat-flow)
2. [Core Combat Mechanics](#core-combat-mechanics)
3. [Character Stats and Attributes](#character-stats-and-attributes)
4. [Elemental System](#elemental-system)
5. [Action System](#action-system)
6. [Environmental Systems](#environmental-systems)
7. [Advanced Combat Features](#advanced-combat-features)
8. [AI Systems](#ai-systems)
9. [Progression Systems](#progression-systems)
10. [Tips and Strategies](#tips-and-strategies)

---

## Basic Combat Flow

### Turn Structure
- **Initiative-based Turn Order**: Characters act based on their speed and initiative
- **Action Points**: Players have 3 action points per turn to spend on actions
- **Turn Timeout**: 30 seconds per turn (auto-advances if time runs out)
- **Round System**: After all characters act, a new round begins

### Combat Phases
1. **Combat Start**: Enemies are introduced, turn order is calculated
2. **Turn Execution**: Each character takes their turn
3. **End-of-Turn Effects**: Status effects, surfaces, and environmental effects are applied
4. **Victory/Defeat Check**: Combat ends when one side is defeated

---

## Core Combat Mechanics

### Damage Calculation
```
Final Damage = (Base Power + Attack - Defense) × Elemental Effectiveness × Weather Effects × Surface Effects × Cover Effects
```

### Critical Hits
- **Base Critical Chance**: 5% for most attacks
- **Critical Multiplier**: 1.5x damage
- **Equipment Bonuses**: Can increase critical chance
- **Status Effects**: Some conditions affect critical chance

### Accuracy System
- **Base Accuracy**: 95% for most actions
- **Weather Effects**: Can reduce accuracy
- **Status Effects**: Blind condition reduces accuracy by 50%

---

## Character Stats and Attributes

### Core Stats (Base Value: 10 each)
- **Strength**: Affects physical attack power
- **Constitution**: Affects health points and defense
- **Dexterity**: Affects speed and initiative
- **Intelligence**: Affects magic attack and magic points
- **Wisdom**: Affects magic defense
- **Charisma**: Affects social interactions and some abilities

### Derived Combat Stats
- **Health Points (HP)**: Constitution × 10
- **Magic Points (MP)**: Intelligence × 5
- **Attack**: Strength × 1.5
- **Defense**: Constitution × 1.0
- **Magic Attack**: Intelligence × 1.2
- **Magic Defense**: Wisdom × 0.8
- **Speed**: Dexterity × 1.0

### Positioning System
- **Front Row**: Normal damage, can use melee attacks
- **Back Row**: Takes 30% less damage, limited to ranged attacks

---

## Elemental System

### Elemental Types
The game features 10 elemental types with Pokemon-style effectiveness:

| Element | Super Effective Against | Not Very Effective Against | Resistant To |
|---------|------------------------|---------------------------|--------------|
| **Fire** | Ice, Shadow, Tech | Water, Void | Fire |
| **Ice** | Water, Earth | Fire, Tech | Ice |
| **Lightning** | Water, Wind, Void, Tech | Earth | Lightning |
| **Water** | Fire, Earth | Ice, Lightning, Tech | Water |
| **Earth** | Lightning, Wind, Tech | Ice, Water | Earth |
| **Wind** | Shadow | Lightning, Earth | Wind |
| **Shadow** | Light, Void | Fire, Wind | Shadow |
| **Light** | Shadow, Void | Light | Light |
| **Void** | Fire, Tech | Lightning, Shadow, Light | Void |
| **Tech** | Ice, Water | Fire, Lightning, Earth, Void | Tech |

### Effectiveness Multipliers
- **Super Effective**: 2.0x damage
- **Effective**: 1.5x damage
- **Neutral**: 1.0x damage
- **Not Very Effective**: 0.5x damage
- **Resistant**: 0.5x damage

### World Affinities
Each of the 9 worlds has an elemental affinity that provides bonuses:
- **Nokturn**: Shadow affinity
- **Elysion**: Light affinity
- **Sylithar**: Fire affinity
- **Terra**: Earth affinity
- **Aethra**: Wind affinity
- **Ombra**: Void affinity
- **Krynn**: Fire affinity
- **Tauron**: Tech affinity
- **Aelria**: Light affinity

---

## Action System

### Action Types
- **Attack**: Physical damage based on attack stat
- **Spell**: Magical damage based on magic attack stat
- **Heal**: Restores health points
- **Buff**: Temporarily increases stats
- **Debuff**: Temporarily decreases enemy stats
- **Item**: Uses consumable items
- **Special**: Unique abilities with special effects

### Action Properties
- **Cost**: Mana, health, or gold required
- **Range**: Self, single target, or area effect
- **Accuracy**: Chance to hit (0-100%)
- **Critical Chance**: Chance for critical hit
- **Cooldown**: Turns before reuse
- **Action Points**: How many action points the action costs

### Action Point System
- **Starting Points**: 3 per turn
- **Cost Range**: 1-3 points per action
- **Strategic Planning**: Choose between multiple weak actions or one powerful action

---

## Environmental Systems

### Surface System
Surfaces are created on the battlefield and provide various effects:

#### Surface Types
- **Fire**: Deals damage per turn, spreads to adjacent tiles, +50% fire damage
- **Water**: Conducts lightning, extinguishes fire, +100% lightning damage
- **Ice**: Slippery, can freeze enemies, +50% ice damage
- **Oil**: Flammable, movement penalty, +100% fire damage
- **Poison**: Damage over time, spreads slowly, +30% void damage
- **Acid**: High damage, corrodes equipment, +50% tech damage
- **Void**: Reality distortion, random effects, +100% void damage
- **Light**: Healing per turn, purifies, +50% light damage

#### World-Specific Surfaces
- **Shadow Veil (Nokturn)**: Stealth bonus, +40% shadow damage
- **Void Pool (Ombra)**: Reality distortion, +80% void damage
- **Ancient Blood (Nokturn)**: Magic amplification, +30% shadow damage

#### Surface Effects
- **Elemental Bonuses**: +50% damage for matching elements
- **Spreading**: Surfaces can spread to adjacent tiles
- **Duration**: Surfaces last for multiple turns
- **World Affinity**: Surfaces are stronger in their native worlds

### Cover System
- **Partial Cover**: Reduces incoming damage
- **Full Cover**: Blocks most damage
- **Magical Cover**: Protects against spells
- **Void Cover**: Protects against reality-bending attacks

### Weather System
- **Clear**: Normal conditions
- **Rain**: Reduces fire damage, increases lightning damage
- **Sun**: Increases fire damage, reduces ice damage
- **Storm**: Reduces accuracy, increases lightning damage
- **Fog**: Reduces accuracy significantly

---

## Advanced Combat Features

### All-Out Attack System
Inspired by the Persona series, this system rewards team coordination:

#### Trigger Conditions
- **All Enemies Weak**: All enemies vulnerable to same element
- **Elemental Synergy**: Team uses complementary elements
- **World Alignment**: Combat occurs in world with elemental affinity
- **Status Conditions**: All enemies affected by same status
- **Positioning**: Enemies grouped together
- **Timing**: Coordinated attacks in same turn

#### Benefits
- **Damage Multiplier**: 1.5-3.0x damage
- **Area Effect**: Hits all enemies
- **Narrative Events**: Special dialogue and effects
- **Achievement Progress**: Unlocks special achievements
- **Team Synergy**: Builds team coordination bonuses

### Momentum System
Build momentum through successful actions to unlock powerful combos:

#### Momentum Sources
- **Critical Hits**: +2 momentum
- **Elemental Effectiveness**: +1 momentum
- **Status Effects Applied**: +1 momentum
- **Team Coordination**: +1 momentum per ally

#### Combo Attacks
- **Elemental Combos**: Combine different elements
- **Status Combos**: Chain status effects
- **Position Combos**: Coordinate front/back row attacks
- **World Combos**: Use world-specific abilities

### Emotional State System
Character emotions affect combat performance:

#### Emotional States
- **Determined**: +20% defense, +10% magic attack
- **Fearful**: +30% speed, -20% attack
- **Angry**: +40% attack, -30% magic defense
- **Desperate**: +50% critical chance, -40% defense
- **Confident**: +20% accuracy, +30% critical chance
- **Calm**: +10% magic attack, +10% accuracy

#### State Transitions
- **Combat Events**: Actions trigger emotional changes
- **Narrative Events**: Story moments affect emotions
- **Team Dynamics**: Ally actions influence emotions
- **World Effects**: Different worlds affect emotional states
- **Environmental Factors**: Surfaces and weather affect emotions

### Quantum Combat System
Advanced reality-bending mechanics:

#### Quantum States
- **Superposition**: Character exists in multiple states simultaneously
- **Entanglement**: Actions affect multiple targets at once
- **Tunneling**: Attacks bypass defenses
- **Collapse**: Quantum states resolve into definite outcomes

#### Quantum Effects
- **Probability Manipulation**: Change hit/critical chances
- **Reality Distortion**: Modify elemental effectiveness
- **Temporal Effects**: Manipulate turn order
- **Dimensional Effects**: Access abilities from other worlds

### Dimensional Combat System
Combat can occur across multiple dimensions with reality-shifting effects:

#### Dimension Types
- **Primary Dimension**: Normal combat reality
- **Secondary Dimension**: Alternative reality with different rules
- **Merged Dimensions**: Combined reality with amplified effects

#### Dimensional Effects
- **Reality Changes**: Modify elemental effectiveness and damage
- **Power Amplification**: Increase damage and abilities
- **Narrative Events**: Trigger unique story moments
- **Visual Effects**: Unique visual representations for each dimension

### Chain Reaction System
Complex interaction chains that can trigger massive damage multipliers:

#### Chain Types
- **Fire Chain**: Fire attacks trigger additional fire damage
- **Ice Chain**: Ice attacks freeze multiple targets
- **Lightning Chain**: Lightning attacks chain between enemies
- **Void Chain**: Void attacks create reality distortions

#### Cascade Mechanics
- **Chain Triggers**: Specific conditions activate chains
- **Damage Multipliers**: 1.5x to 3.0x damage amplification
- **Visual Effects**: Spectacular chain reaction animations
- **Narrative Events**: Rich descriptions of chain reactions

---

## AI Systems

### Multiple AI Types
The combat system uses several AI systems for different situations:

#### Combat AI
- **Basic Decision Making**: Choose best action based on situation
- **Target Selection**: Prioritize weak or threatening enemies
- **Resource Management**: Conserve mana and health
- **Personality Types**: Aggressive, defensive, strategic, support, adaptive
- **Emotional States**: Calm, determined, fearful, angry, desperate, confident
- **Decision Weights**: Action effectiveness (30%), elemental advantage (20%), target priority (25%), team synergy (15%), survival instinct (10%)

#### Reinforcement Learning AI
- **Adaptive Behavior**: Learns from player strategies
- **Pattern Recognition**: Identifies player tactics
- **Counter-Strategies**: Develops responses to common approaches
- **Q-Learning**: Reinforcement learning algorithm
- **Episode Tracking**: Monitors learning episodes
- **Success Rate**: Tracks strategy success rates
- **Difficulty Scaling**: Adjusts difficulty based on player skill

#### Team Coordination AI
- **Group Tactics**: Coordinates multiple enemies
- **Formation Management**: Maintains optimal positioning
- **Combined Attacks**: Synchronizes enemy actions
- **Team Synergy**: Coordinates abilities between allies
- **Communication**: Simulates team communication
- **Strategy Evolution**: Develops new team strategies

#### Narrative AI
- **Story-Driven Actions**: Makes decisions based on plot
- **Character Motivation**: Considers character backstory
- **Emotional Responses**: Reacts to story events
- **Relationship Awareness**: Considers character relationships
- **World Knowledge**: Uses knowledge of the multiverse
- **Plot Integration**: Integrates with main story events

#### Quantum AI
- **Probability Calculation**: Uses quantum mechanics for decisions
- **Reality Manipulation**: Accesses quantum states
- **Dimensional Awareness**: Considers multiverse effects
- **Superposition Logic**: Makes decisions in multiple states
- **Entanglement Effects**: Considers connected actions
- **Collapse Prediction**: Anticipates quantum state resolution

---

## Progression Systems

### Equipment System
- **Weapons**: Primary source of attack power
- **Armor**: Provides defense and special bonuses
- **Accessories**: Grants unique abilities and stat bonuses
- **Mods**: Customizable enhancements for equipment

### Gear System (SWGOH-Inspired)
Advanced gear progression with multiple tiers:

#### Gear Tiers
- **Basic Gear (Tier 1)**: Health +50, Attack +10, Defense +5
- **Improved Gear (Tier 2)**: Health +100, Attack +20, Defense +10, Speed +5
- **Advanced Gear (Tier 3)**: Health +200, Attack +40, Defense +20, Speed +10, Critical Chance +5
- **Expert Gear (Tier 4)**: Health +400, Attack +80, Defense +40, Speed +15, Critical Chance +10, Critical Damage +20
- **Master Gear (Tier 5)**: Health +800, Attack +160, Defense +80, Speed +25, Critical Chance +15, Critical Damage +40
- **Legendary Gear (Tier 6)**: Health +1600, Attack +320, Defense +160, Speed +40, Critical Chance +25, Critical Damage +60

#### Gear Slots
- **Weapon**: Primary attack stat
- **Armor**: Primary defense stat
- **Helmet**: Primary defense stat
- **Gloves**: Primary attack stat
- **Boots**: Primary speed stat
- **Accessory**: Primary critical chance stat

#### Material System
- **Basic Material**: Common crafting material
- **Improved Material**: Enhanced crafting material
- **Advanced Material**: Advanced crafting material
- **Expert Material**: Expert-level crafting material
- **Master Material**: Master-level crafting material
- **Legendary Material**: Legendary crafting material

### Mod System (SWGOH-Inspired)
Advanced mod system for character customization:

#### Mod Sets
- **Speed**: 4 pieces required, Speed +10%
- **Health**: 2 pieces required, Health +10%
- **Defense**: 2 pieces required, Defense +10%
- **Attack**: 4 pieces required, Attack +10%
- **Critical Chance**: 2 pieces required, Critical Chance +8%
- **Critical Damage**: 4 pieces required, Critical Damage +30%
- **Potency**: 2 pieces required, Potency +10%
- **Tenacity**: 2 pieces required, Tenacity +10%

#### Mod Slots
- **Square**: Primary attack, secondary stats
- **Arrow**: Primary speed/attack/health/defense, secondary stats
- **Diamond**: Primary defense, secondary stats
- **Triangle**: Primary critical chance/damage/attack/health/defense, secondary stats
- **Circle**: Primary health, secondary stats
- **Cross**: Primary potency/tenacity/attack/health/defense, secondary stats

#### Optimization Targets
- **Speed**: Maximize speed for turn frequency
- **Attack**: Maximize attack for damage output
- **Health**: Maximize health for survivability
- **Defense**: Maximize defense for damage reduction
- **Critical Chance**: Maximize critical chance for damage
- **Critical Damage**: Maximize critical damage for burst
- **Potency**: Maximize potency for status effects
- **Tenacity**: Maximize tenacity for status resistance

### Job Class System
- **Class Specialization**: Different classes have unique abilities
- **Level Progression**: Gain experience and level up
- **Skill Trees**: Unlock new abilities and improvements
- **Class Changes**: Switch between different job classes

### Faction System
- **Faction Bonuses**: Members of same faction get bonuses
- **Leadership Effects**: Faction leaders provide team benefits
- **Faction Abilities**: Unique abilities for each faction
- **Alliance Mechanics**: Temporary alliances between factions

### Ability Cooldown System
- **Cooldown Management**: Track ability reuse timers
- **Cooldown Reduction**: Items and abilities can reduce cooldowns
- **Cooldown Reset**: Special conditions reset all cooldowns
- **Cooldown Optimization**: Strategic timing of ability usage

---

## Tips and Strategies

### General Combat Tips

#### Elemental Mastery
1. **Study the Matrix**: Memorize the 10x10 elemental effectiveness matrix
2. **World Awareness**: Always check which world you're in for affinity bonuses
3. **Elemental Chaining**: Use complementary elements (Fire → Ice → Water → Lightning)
4. **Resistance Planning**: Avoid using elements enemies are resistant to
5. **Super Effective Priority**: Always prioritize 2.0x damage over neutral attacks

#### Surface Strategy
1. **Surface Creation**: Use fire attacks to create fire surfaces for +50% fire damage
2. **Surface Exploitation**: Position enemies on surfaces that amplify your attacks
3. **Surface Spreading**: Chain surface creation (Fire → Oil → Lightning for massive damage)
4. **Surface Removal**: Use water to extinguish fire, light to purify poison
5. **World-Specific Surfaces**: Use Shadow Veil in Nokturn for stealth bonuses

#### Positioning and Formation
1. **Front Row**: Physical attackers and tanks with high defense
2. **Back Row**: Mages, healers, and vulnerable characters (30% damage reduction)
3. **Formation Synergy**: Coordinate front/back row for combo attacks
4. **Cover Utilization**: Use cover to protect vulnerable characters
5. **Movement Planning**: Consider how positioning affects surface and cover effects

#### Resource Management
1. **Action Point Budgeting**: Save 1 action point for defensive options
2. **Mana Conservation**: Use physical attacks when mana is low
3. **Cooldown Tracking**: Plan ability usage around cooldown cycles
4. **Momentum Investment**: Spend momentum on high-impact abilities
5. **Quantum Energy**: Reserve quantum energy for critical moments

### Advanced Strategies

#### Combo Mastery
1. **Elemental Combos**: Fire → Ice → Water → Lightning for 4x damage chain
2. **Status Combos**: Poison → Acid → Void for escalating damage over time
3. **Position Combos**: Front row attack → Back row spell for momentum building
4. **World Combos**: Use world-specific abilities in their native worlds
5. **Chain Reactions**: Trigger cascades with multiple surface interactions

#### Momentum Optimization
1. **Early Momentum**: Build momentum with safe, reliable attacks
2. **Momentum Spending**: Use momentum on abilities with 3+ action point costs
3. **Momentum Decay**: Plan around momentum decay over time
4. **Team Momentum**: Coordinate team actions to build momentum faster
5. **Momentum Combos**: Chain momentum-gaining actions for exponential growth

#### All-Out Attack Setup
1. **Elemental Weakness**: Identify enemies weak to the same element
2. **Status Coordination**: Apply the same status to all enemies
3. **Positioning Setup**: Group enemies together for area attacks
4. **Timing Coordination**: Execute team attacks in the same turn
5. **World Alignment**: Use world-specific abilities in their native worlds

#### Quantum Combat Tactics
1. **Superposition Setup**: Use quantum states to access multiple abilities simultaneously
2. **Entanglement Exploitation**: Link actions between multiple targets
3. **Tunneling Strategy**: Use quantum tunneling to bypass high-defense enemies
4. **Collapse Timing**: Time quantum collapse for maximum damage windows
5. **Probability Manipulation**: Use quantum effects to improve critical hit chances

#### Dimensional Combat
1. **Dimension Shifting**: Use dimension shifts to change elemental effectiveness
2. **Power Amplification**: Combine dimensional effects with elemental bonuses
3. **Reality Manipulation**: Use dimensional effects to modify surface interactions
4. **Narrative Integration**: Trigger dimensional events for story progression
5. **Visual Coordination**: Time dimensional effects with visual feedback

### Team Composition Strategies

#### Balanced Team (Recommended for Beginners)
- **Front Row**: Warrior (Physical Tank), Paladin (Support Tank)
- **Back Row**: Mage (Elemental Damage), Cleric (Healing/Support)
- **Elemental Coverage**: Fire, Ice, Lightning, Light
- **Synergy**: Paladin buffs team, Cleric heals, Mage provides damage

#### Elemental Specialist Team
- **Fire Team**: Fire Mage, Fire Warrior, Fire Cleric
- **World**: Sylithar or Krynn for +20% fire affinity
- **Strategy**: Create fire surfaces, chain fire attacks
- **Weakness**: Vulnerable to water enemies

#### Quantum Team
- **Composition**: Quantum Mage, Reality Shifter, Probability Manipulator
- **Strategy**: Use quantum states for probability manipulation
- **Synergy**: Quantum effects amplify each other
- **Complexity**: High skill ceiling, requires coordination

#### Momentum Team
- **Composition**: Momentum Builder, Combo Master, Finisher
- **Strategy**: Build momentum early, spend on powerful finishers
- **Synergy**: Each member contributes to momentum building
- **Timing**: Critical to coordinate momentum spending

### Equipment Optimization

#### Mod Optimization by Role
1. **Speed Mods (4-piece)**: Essential for turn frequency
   - Primary: Speed on Arrow
   - Secondary: Speed, Critical Chance, Potency
   - Target: 200+ speed for frequent turns

2. **Critical Damage Mods (4-piece)**: For damage dealers
   - Primary: Critical Damage on Triangle
   - Secondary: Critical Chance, Attack, Speed
   - Target: 200%+ critical damage

3. **Health Mods (2-piece)**: For tanks and survivability
   - Primary: Health on Circle
   - Secondary: Defense, Speed, Tenacity
   - Target: 50,000+ health

4. **Potency Mods (2-piece)**: For status effect users
   - Primary: Potency on Cross
   - Secondary: Speed, Critical Chance, Tenacity
   - Target: 100%+ potency

#### Gear Progression Strategy
1. **Tier 1-2**: Focus on basic survivability and damage
2. **Tier 3-4**: Add critical chance and damage for damage dealers
3. **Tier 5-6**: Optimize for specific roles and team synergies
4. **Material Farming**: Target specific worlds for material efficiency

#### Set Bonuses
1. **Speed Set**: Essential for all characters (turn frequency)
2. **Critical Damage Set**: For primary damage dealers
3. **Health Set**: For tanks and support characters
4. **Potency Set**: For status effect specialists
5. **Tenacity Set**: For characters vulnerable to status effects

### World-Specific Strategies

#### Nokturn (Shadow Realm)
- **Elemental Focus**: Shadow and Void abilities
- **Surface Strategy**: Use Shadow Veil for stealth bonuses
- **Team Composition**: Shadowkin characters get bonuses
- **Tactics**: Use void surfaces for reality distortion

#### Elysion (Light Realm)
- **Elemental Focus**: Light abilities
- **Surface Strategy**: Use light surfaces for healing
- **Team Composition**: Light-aligned characters excel
- **Tactics**: Purify negative status effects with light

#### Sylithar (Fire Realm)
- **Elemental Focus**: Fire abilities
- **Surface Strategy**: Create fire surfaces for damage amplification
- **Team Composition**: Fire-aligned characters get bonuses
- **Tactics**: Chain fire attacks for maximum damage

#### Terra (Earth Realm)
- **Elemental Focus**: Earth abilities
- **Surface Strategy**: Use earth for stability and defense
- **Team Composition**: Earth-aligned characters get bonuses
- **Tactics**: Focus on defensive positioning and cover

### Advanced Combat Scenarios

#### Boss Battle Strategy
1. **Phase 1**: Build momentum and apply status effects
2. **Phase 2**: Use elemental weaknesses and surface effects
3. **Phase 3**: Execute all-out attacks and quantum abilities
4. **Phase 4**: Finish with momentum-powered finishers

#### Multi-Enemy Combat
1. **Priority Targeting**: Focus on high-threat enemies first
2. **Area Control**: Use surfaces to control battlefield
3. **Team Coordination**: Coordinate attacks for maximum efficiency
4. **Resource Management**: Conserve abilities for later phases

#### Survival Scenarios
1. **Defensive Positioning**: Use back row and cover
2. **Healing Priority**: Maintain health above 50%
3. **Status Management**: Remove negative status effects quickly
4. **Escape Planning**: Keep resources for defensive abilities

---

## Combat Achievements

The system tracks various achievements:
- **Combat Master**: Win 10 battles
- **Elemental Master**: Use all elements effectively
- **Surface Master**: Create and use surfaces strategically
- **All-Out Attack Master**: Execute successful team attacks
- **Quantum Master**: Master quantum combat mechanics
- **Chain Reaction Master**: Trigger complex chain reactions
- **Dimensional Master**: Master dimensional combat mechanics
- **Emotional Master**: Master emotional state management
- **Momentum Master**: Build and use momentum effectively
- **Team Coordination Master**: Execute perfect team attacks

## Performance and Balance

### Damage Balance
- **Base Damage**: Scales with character level and equipment
- **Elemental Effectiveness**: 0.5x to 2.0x multipliers
- **Critical Hits**: 1.5x damage multiplier
- **Surface Effects**: 1.2x to 1.5x additional bonuses
- **Chain Reactions**: 1.5x to 3.0x damage amplification

### Resource Balance
- **Action Points**: 3 per turn, strategic planning required
- **Energy Systems**: 100 base, various costs for abilities
- **Cooldowns**: 1-5 turns based on power level
- **Momentum**: 0-10 points, decays over time
- **Quantum Energy**: Limited resource for reality manipulation

### Progression Balance
- **Gear Tiers**: 6 levels with exponential scaling
- **Mod Optimization**: 10 priority levels for customization
- **Job Classes**: 10 levels with ability unlocks
- **Faction Bonuses**: 2-4 member requirements
- **World Affinities**: Provide 20% bonus in native worlds

---

This combat system is designed to be both accessible to new players and deep enough to satisfy experienced gamers. The multiple interconnected systems create endless strategic possibilities while maintaining clear, understandable mechanics.

---

## Sample Battle Simulation

### Battle Setup
**Location**: Sylithar (Fire Realm) - Desert of Glass
**Weather**: Sun (+50% fire damage, -30% ice damage)
**Player Team**: Arius (Fire Mage), Luna (Ice Cleric), Thor (Lightning Warrior)
**Enemies**: 3 Fire Goblins (Fire affinity), 1 Ice Troll (Ice affinity)

### Turn 1: Initial Positioning and Setup

#### Player Turn
**Arius (Fire Mage - Front Row)**
- **Action**: Cast "Inferno Burst" (Fire spell, 2 action points)
- **Target**: Ice Troll (Fire vs Ice = 2.0x damage)
- **Surface Effect**: Creates fire surface at target location (+50% fire damage)
- **Damage**: 120 base × 2.0 elemental × 1.5 weather × 1.5 surface = **540 damage**
- **Momentum**: +2 (critical hit) +1 (elemental effectiveness) = **+3 momentum**
- **Narrative**: "The desert sun amplifies Arius's flames as they engulf the troll!"

**Luna (Ice Cleric - Back Row)**
- **Action**: Cast "Healing Light" (1 action point)
- **Target**: Thor (healing)
- **Effect**: Restores 80 HP to Thor
- **Momentum**: +1 (team coordination)

**Thor (Lightning Warrior - Front Row)**
- **Action**: "Thunder Strike" (Lightning attack, 1 action point)
- **Target**: Fire Goblin (Lightning vs Fire = 1.0x neutral)
- **Damage**: 85 base × 1.0 elemental = **85 damage**
- **Surface Interaction**: Lightning on fire surface creates electrified surface

#### Enemy Turn
**Fire Goblin 1**
- **AI Decision**: Uses "Flame Claw" on Thor
- **Damage**: 60 base × 1.5 fire affinity = **90 damage**
- **Surface Effect**: Creates additional fire surface

**Fire Goblin 2**
- **AI Decision**: Uses "Fire Breath" on Luna
- **Damage**: 70 base × 1.5 fire affinity = **105 damage** (reduced by 30% back row = **74 damage**)

### Turn 2: Surface Exploitation and Momentum Building

#### Player Turn
**Arius**
- **Action**: "Fire Chain" (3 action points, spends 2 momentum)
- **Target**: All enemies on fire surfaces
- **Damage**: 200 base × 2.0 elemental × 1.5 weather × 1.5 surface = **900 damage**
- **Chain Effect**: Triggers fire chain reaction (+50% additional damage)
- **Final Damage**: **1350 damage to all enemies**
- **Momentum**: +3 (chain reaction) +2 (area attack) = **+5 momentum**

**Luna**
- **Action**: "Ice Storm" (Ice spell, 2 action points)
- **Target**: Fire Goblins (Ice vs Fire = 0.5x, but weather penalty)
- **Damage**: 100 base × 0.5 elemental × 0.7 weather = **35 damage**
- **Surface Effect**: Creates ice surface, extinguishes some fire

**Thor**
- **Action**: "Lightning Surge" (Lightning attack, 1 action point)
- **Target**: Electrified surface area
- **Damage**: 120 base × 2.0 surface bonus = **240 damage**
- **Chain Effect**: Lightning chains between all enemies on electrified surface

### Turn 3: All-Out Attack Setup

#### Player Turn
**Arius**
- **Action**: "Burning Inferno" (Fire spell, 3 action points)
- **Target**: All enemies (all now weak to fire due to previous damage)
- **All-Out Attack Trigger**: All enemies vulnerable to fire
- **Damage**: 300 base × 2.0 elemental × 1.5 weather × 2.0 all-out attack = **1800 damage**
- **Narrative**: "The team's coordinated fire assault engulfs all enemies!"

**Luna**
- **Action**: "Purify Light" (Light spell, 2 action points)
- **Target**: Team (removes negative status effects)
- **Effect**: Heals team and removes any debuffs

**Thor**
- **Action**: "Thunder God's Wrath" (Lightning ultimate, 3 action points, spends 5 momentum)
- **Target**: All enemies
- **Damage**: 500 base × 1.5 momentum bonus = **750 damage**
- **Quantum Effect**: Triggers quantum superposition for additional damage instances

### Turn 4: Victory and Cleanup

#### Player Turn
**Arius**
- **Action**: "Ember Strike" (Fire attack, 1 action point)
- **Target**: Remaining weakened enemies
- **Damage**: 150 base × 2.0 elemental = **300 damage**

**Luna**
- **Action**: "Healing Aura" (Light spell, 2 action points)
- **Target**: Team (area healing)
- **Effect**: Restores 120 HP to all allies

**Thor**
- **Action**: "Lightning Finish" (Lightning attack, 1 action point)
- **Target**: Final enemy
- **Damage**: 200 base × 1.5 critical = **300 damage**
- **Victory**: All enemies defeated

### Battle Analysis

#### Systems Demonstrated
1. **Elemental Effectiveness**: Fire vs Ice (2.0x), Lightning vs Fire (1.0x)
2. **Surface Management**: Fire surfaces created and exploited
3. **Weather Effects**: Sun weather amplified fire damage
4. **Positioning**: Back row damage reduction for Luna
5. **Momentum System**: Built and spent momentum for powerful abilities
6. **All-Out Attack**: Triggered when all enemies became vulnerable
7. **Chain Reactions**: Fire chain and lightning chain effects
8. **Quantum Effects**: Superposition triggered for additional damage
9. **Team Coordination**: Coordinated attacks and healing
10. **World Affinity**: Fire abilities enhanced in Sylithar

#### Strategic Elements
- **Resource Management**: Conserved action points for powerful combinations
- **Surface Exploitation**: Used fire surfaces to amplify damage
- **Elemental Synergy**: Combined fire and lightning for chain effects
- **Team Support**: Balanced damage with healing and support
- **Momentum Investment**: Spent momentum on high-impact abilities
- **All-Out Attack Setup**: Created conditions for team attack bonus

This battle demonstrates how all 17 combat systems work together to create a dynamic, strategic, and narratively rich combat experience. 