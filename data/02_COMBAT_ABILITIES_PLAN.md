# COMBAT ABILITIES PLAN
## Project Orion - Unique Ability System Implementation

### Overview
Create a comprehensive combat abilities system with 200+ unique abilities across all worlds and character classes. Each ability must have distinct effects, synergies, and tactical value. Abilities should reflect world themes and provide meaningful choices in combat.

### File Structure
```
data/abilities/
├── abilities.json (basic abilities by class)
├── world_abilities.json (world-specific abilities)
├── class_abilities.json (class-specific abilities)
├── combo_abilities.json (combo moves)
├── ultimate_abilities.json (powerful abilities)
├── ability_effects.json (status effects)
├── ability_synergies.json (ability combinations)
├── ability_scaling.json (level-based scaling)
└── ability_lore.json (background stories)
```

### Ability Categories

#### BASIC ABILITIES (Level 1-10)
- **Standard attacks** - Reliable damage dealers
- **Defensive abilities** - Protection and healing
- **Utility abilities** - Movement and positioning
- **Status abilities** - Buffs and debuffs

#### ADVANCED ABILITIES (Level 10-25)
- **Combo attacks** - Multi-hit abilities
- **Area abilities** - Affecting multiple targets
- **Specialized abilities** - Class-specific powers
- **Environmental abilities** - Using terrain and surfaces

#### MASTER ABILITIES (Level 25-50)
- **Ultimate attacks** - Powerful single-use abilities
- **Transformation abilities** - Changing character state
- **Reality manipulation** - World-specific powers
- **Team abilities** - Supporting allies

#### LEGENDARY ABILITIES (Level 50+)
- **Cosmic powers** - Reality-bending abilities
- **Divine abilities** - God-like powers
- **Void manipulation** - Dimensional abilities
- **Creation abilities** - Making something from nothing

### World-Specific Ability Themes

#### TERRA - Nature & Life
**Theme:** Growth, healing, primal forces
**Ability Types:**
- **Nature's Wrath** - Primal damage abilities
- **Life Force** - Healing and regeneration
- **Growth Magic** - Buffing and enhancement
- **Earth Power** - Terrain manipulation

**Unique Mechanics:**
- **Photosynthesis** - Healing in sunlight
- **Root Network** - Connecting with allies
- **Primal Rage** - Damage increases when wounded
- **Life Absorption** - Stealing health from enemies

#### NOKTRUN - Shadows & Void
**Theme:** Darkness, stealth, void manipulation
**Ability Types:**
- **Shadow Magic** - Stealth and deception
- **Void Powers** - Reality manipulation
- **Dark Arts** - Corruption and decay
- **Fear Magic** - Intimidation and control

**Unique Mechanics:**
- **Shadow Phase** - Temporary invisibility
- **Void Distortion** - Changing battlefield reality
- **Fear Aura** - Reducing enemy stats
- **Dark Absorption** - Absorbing enemy abilities

#### ELYSION - Light & Divinity
**Theme:** Holy power, wisdom, divine protection
**Ability Types:**
- **Holy Magic** - Divine damage and healing
- **Light Powers** - Purification and protection
- **Wisdom Magic** - Knowledge and insight
- **Divine Blessing** - Buffing and enhancement

**Unique Mechanics:**
- **Divine Protection** - Damage reduction
- **Holy Smite** - Extra damage to dark enemies
- **Light Purification** - Removing debuffs
- **Divine Favor** - Random beneficial effects

#### SYLITHAR - Crystals & Time
**Theme:** Reflection, time manipulation, crystalline power
**Ability Types:**
- **Crystal Magic** - Reflection and refraction
- **Time Powers** - Temporal manipulation
- **Mirror Magic** - Duplication and copying
- **Fractal Magic** - Infinite geometric patterns

**Unique Mechanics:**
- **Time Dilation** - Slowing enemy actions
- **Crystal Reflection** - Bouncing attacks back
- **Mirror Duplication** - Creating copies
- **Fractal Damage** - Increasing damage over time

#### AETHRA - Wind & Sky
**Theme:** Freedom, movement, aerial combat
**Ability Types:**
- **Wind Magic** - Movement and positioning
- **Storm Powers** - Weather manipulation
- **Aerial Combat** - Flying and air superiority
- **Freedom Magic** - Breaking restrictions

**Unique Mechanics:**
- **Wind Manipulation** - Pushing enemies around
- **Storm Generation** - Creating hazardous weather
- **Aerial Superiority** - Bonus damage from above
- **Cloud Concealment** - Hiding in clouds

#### OMBRA - Mystery & Illusion
**Theme:** Deception, illusion, the unknown
**Ability Types:**
- **Illusion Magic** - Deception and confusion
- **Mystery Powers** - Unknown and unpredictable
- **Stealth Magic** - Invisibility and surprise
- **Reality Distortion** - Changing perceptions

**Unique Mechanics:**
- **Illusion Creation** - Creating fake enemies
- **Reality Distortion** - Changing battlefield appearance
- **Stealth Mechanics** - Invisible attacks
- **Mystery Aura** - Confusing enemy abilities

#### KRYNN - Dragons & Fire
**Theme:** Power, fire, dragon magic
**Ability Types:**
- **Dragon Magic** - Fire and power abilities
- **Scale Powers** - Protection and enhancement
- **Fire Magic** - Burning and destruction
- **Dragon Fear** - Intimidation and control

**Unique Mechanics:**
- **Dragon Breath** - Powerful fire attacks
- **Scale Armor** - Damage reduction
- **Dragon Fear** - Intimidation effects
- **Fire Absorption** - Healing from fire damage

#### TAURON - Technology & Fusion
**Theme:** Technology, fusion, digital power
**Ability Types:**
- **Tech Magic** - Technological abilities
- **Fusion Powers** - Combining magic and tech
- **Digital Magic** - Data manipulation
- **Machine Learning** - Adaptive abilities

**Unique Mechanics:**
- **Technology Hacking** - Disabling enemy equipment
- **Fusion Abilities** - Combining different elements
- **Digital Corruption** - Damaging enemy systems
- **Machine Learning** - Adapting to enemy tactics

#### AELRIA - Reality & Will
**Theme:** Reality manipulation, pure will, manifestation
**Ability Types:**
- **Reality Magic** - Shaping the world
- **Will Powers** - Pure determination
- **Thought Magic** - Mental manipulation
- **Creation Magic** - Making from nothing

**Unique Mechanics:**
- **Reality Warping** - Changing the battlefield
- **Thought Projection** - Mental attacks
- **Will Manifestation** - Creating objects from nothing
- **Mind Control** - Taking control of enemies

### Class-Specific Abilities

#### WARRIOR CLASSES
- **Weapon Mastery** - Enhanced weapon abilities
- **Battle Tactics** - Strategic combat abilities
- **Physical Prowess** - Strength-based abilities
- **Combat Instincts** - Reflex-based abilities

#### MAGE CLASSES
- **Arcane Mastery** - Powerful spell abilities
- **Elemental Control** - Element manipulation
- **Mana Manipulation** - Energy management
- **Spell Crafting** - Creating new spells

#### ROGUE CLASSES
- **Stealth Mastery** - Invisibility and surprise
- **Precision Strikes** - Critical hit abilities
- **Shadow Walking** - Movement through shadows
- **Assassination** - Deadly single-target abilities

#### HEALER CLASSES
- **Divine Healing** - Powerful restoration
- **Protection Magic** - Defensive abilities
- **Purification** - Removing negative effects
- **Life Force** - Manipulating health and energy

#### EXPLORER CLASSES
- **Environmental Mastery** - Using terrain
- **Movement Abilities** - Enhanced mobility
- **Survival Skills** - Adaptation abilities
- **Discovery Magic** - Finding hidden things

### Ability Mechanics

#### DAMAGE TYPES
- **Physical** - Standard weapon damage
- **Magical** - Spell-based damage
- **Elemental** - Fire, ice, lightning, etc.
- **Void** - Reality-bending damage
- **Divine** - Holy damage
- **Shadow** - Dark damage
- **Tech** - Technological damage
- **Reality** - Reality-manipulating damage

#### EFFECT TYPES
- **Direct Damage** - Immediate health loss
- **Damage Over Time** - Sustained damage
- **Healing** - Restoring health
- **Buffs** - Positive status effects
- **Debuffs** - Negative status effects
- **Movement** - Changing position
- **Transformation** - Changing character state
- **Environmental** - Affecting the battlefield

#### TARGET TYPES
- **Self** - Affecting the caster
- **Single Target** - One enemy or ally
- **Multiple Targets** - Several enemies or allies
- **Area of Effect** - All in a radius
- **Line** - All in a straight line
- **Cone** - All in a cone shape
- **Environment** - Affecting the battlefield

### Ability Synergies

#### ELEMENTAL COMBINATIONS
- **Fire + Ice** - Steam effects
- **Lightning + Water** - Electrified water
- **Earth + Wind** - Sandstorm effects
- **Light + Shadow** - Balance effects

#### CLASS COMBINATIONS
- **Warrior + Mage** - Spell sword abilities
- **Rogue + Healer** - Stealth healing
- **Explorer + Warrior** - Environmental combat
- **Mage + Healer** - Arcane healing

#### WORLD COMBINATIONS
- **Terra + Elysion** - Nature and light
- **Nokturn + Krynn** - Shadow and fire
- **Sylithar + Aethra** - Time and wind
- **Tauron + Aelria** - Technology and reality

### Ability Scaling

#### LEVEL-BASED SCALING
- **Damage scaling** - Increases with level
- **Effect scaling** - Stronger effects at higher levels
- **Cost scaling** - Higher costs for more powerful abilities
- **Cooldown scaling** - Shorter cooldowns at higher levels

#### EQUIPMENT-BASED SCALING
- **Weapon scaling** - Abilities scale with weapon power
- **Armor scaling** - Defensive abilities scale with armor
- **Accessory scaling** - Abilities scale with accessories
- **Set bonus scaling** - Abilities enhanced by set bonuses

#### WORLD-BASED SCALING
- **Home world bonus** - Abilities stronger in their world
- **Foreign world penalty** - Abilities weaker in other worlds
- **World synergy** - Abilities work better with world-specific items
- **Cross-world combinations** - Special effects when combining worlds

### Implementation Priority

#### PHASE 1: BASIC ABILITIES (Week 1)
1. Create 20 basic abilities per class (100 total)
2. Implement basic damage and healing abilities
3. Create simple buff and debuff abilities
4. Set up basic ability scaling

#### PHASE 2: WORLD ABILITIES (Week 2)
1. Create 10 world-specific abilities per world (90 total)
2. Implement unique world mechanics
3. Create environmental interaction abilities
4. Set up world-specific scaling

#### PHASE 3: ADVANCED ABILITIES (Week 3)
1. Create 5 advanced abilities per class (25 total)
2. Implement combo and area abilities
3. Create transformation abilities
4. Set up advanced ability synergies

#### PHASE 4: LEGENDARY ABILITIES (Week 4)
1. Create 3 legendary abilities per world (27 total)
2. Implement reality-bending abilities
3. Create ultimate abilities
4. Set up legendary ability requirements

### Success Metrics
- [ ] 200+ unique abilities across all classes and worlds
- [ ] Each ability has unique effects and mechanics
- [ ] World-specific themes and synergies
- [ ] Balanced ability progression
- [ ] Interesting tactical choices
- [ ] Complex ability combinations
- [ ] Dynamic ability scaling
- [ ] Comprehensive ability lore

This ability system will provide the tactical depth and variety needed for AAA-quality combat encounters in Project Orion. 