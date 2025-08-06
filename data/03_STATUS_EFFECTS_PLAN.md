# STATUS EFFECTS PLAN
## Project Orion - Comprehensive Status Effect System Implementation

### Overview
Create a comprehensive status effects system with 50+ unique buffs, debuffs, and environmental effects. Each effect must have distinct mechanics, visual feedback, and tactical implications. Effects should synergize with abilities, equipment, and world themes.

### File Structure
```
data/status_effects/
├── status_effects.json (all status effects)
├── buffs.json (positive status effects)
├── debuffs.json (negative status effects)
├── environmental_effects.json (terrain and weather effects)
├── elemental_effects.json (element-based effects)
├── world_effects.json (world-specific effects)
├── duration_effects.json (temporary effects)
├── permanent_effects.json (long-term effects)
├── effect_synergies.json (effect combinations)
└── effect_lore.json (background stories)
```

### Status Effect Categories

#### POSITIVE EFFECTS (Buffs)
- **Stat Enhancements** - Increasing health, damage, defense, etc.
- **Ability Enhancements** - Improving ability effectiveness
- **Environmental Benefits** - Terrain and weather advantages
- **Team Support** - Helping allies
- **Regeneration** - Healing over time

#### NEGATIVE EFFECTS (Debuffs)
- **Stat Reductions** - Decreasing health, damage, defense, etc.
- **Ability Impairments** - Reducing ability effectiveness
- **Environmental Penalties** - Terrain and weather disadvantages
- **Movement Restrictions** - Limiting movement and positioning
- **Damage Over Time** - Sustained damage

#### ENVIRONMENTAL EFFECTS
- **Terrain Effects** - Surface-based effects
- **Weather Effects** - Atmospheric conditions
- **Area Effects** - Zone-based effects
- **Time Effects** - Temporal effects
- **Reality Effects** - Reality-bending effects

### World-Specific Status Effects

#### TERRA - Nature & Life
**Theme:** Growth, healing, primal forces
**Positive Effects:**
- **Photosynthesis** - Healing in sunlight
- **Root Network** - Connecting with allies
- **Primal Strength** - Increased damage when wounded
- **Life Force** - Regeneration and healing

**Negative Effects:**
- **Root Binding** - Movement restriction
- **Life Drain** - Health loss over time
- **Nature's Wrath** - Damage from natural forces
- **Decay** - Stat reduction over time

**Environmental Effects:**
- **Fertile Ground** - Enhanced healing
- **Dense Forest** - Movement restriction
- **Crystal Growth** - Damage reflection
- **Life Energy** - Enhanced abilities

#### NOKTRUN - Shadows & Void
**Theme:** Darkness, stealth, void manipulation
**Positive Effects:**
- **Shadow Phase** - Temporary invisibility
- **Void Protection** - Damage absorption
- **Dark Empowerment** - Enhanced abilities in darkness
- **Fear Aura** - Intimidating enemies

**Negative Effects:**
- **Shadow Bind** - Movement and ability restriction
- **Void Corruption** - Stat reduction
- **Fear** - Reduced combat effectiveness
- **Darkness** - Reduced visibility and accuracy

**Environmental Effects:**
- **Shadow Realm** - Enhanced stealth abilities
- **Void Distortion** - Reality manipulation
- **Darkness** - Reduced visibility
- **Fear Field** - Intimidation effects

#### ELYSION - Light & Divinity
**Theme:** Holy power, wisdom, divine protection
**Positive Effects:**
- **Divine Protection** - Damage reduction
- **Holy Blessing** - Enhanced abilities
- **Light Purification** - Removing negative effects
- **Divine Favor** - Random beneficial effects

**Negative Effects:**
- **Divine Wrath** - Damage from holy sources
- **Light Blindness** - Reduced accuracy
- **Wisdom Drain** - Reduced intelligence
- **Holy Restriction** - Ability limitations

**Environmental Effects:**
- **Holy Ground** - Enhanced healing and protection
- **Divine Light** - Enhanced abilities
- **Sacred Space** - Purification effects
- **Celestial Energy** - Enhanced magic

#### SYLITHAR - Crystals & Time
**Theme:** Reflection, time manipulation, crystalline power
**Positive Effects:**
- **Time Acceleration** - Faster actions
- **Crystal Armor** - Damage reflection
- **Mirror Image** - Creating copies
- **Fractal Enhancement** - Increasing power over time

**Negative Effects:**
- **Time Dilation** - Slower actions
- **Crystal Binding** - Movement restriction
- **Mirror Trap** - Confusion effects
- **Fractal Decay** - Decreasing power over time

**Environmental Effects:**
- **Crystal Field** - Damage reflection
- **Time Distortion** - Temporal effects
- **Mirror Realm** - Duplication effects
- **Fractal Space** - Geometric effects

#### AETHRA - Wind & Sky
**Theme:** Freedom, movement, aerial combat
**Positive Effects:**
- **Wind Empowerment** - Enhanced movement
- **Aerial Superiority** - Bonus damage from above
- **Storm Strength** - Enhanced abilities in storms
- **Freedom** - Breaking restrictions

**Negative Effects:**
- **Wind Restriction** - Movement limitation
- **Grounded** - Reduced aerial abilities
- **Storm Weakness** - Reduced abilities in storms
- **Wind Bind** - Movement restriction

**Environmental Effects:**
- **Wind Currents** - Enhanced movement
- **Storm Field** - Hazardous weather
- **Aerial Zone** - Enhanced aerial abilities
- **Freedom Field** - Breaking restrictions

#### OMBRA - Mystery & Illusion
**Theme:** Deception, illusion, the unknown
**Positive Effects:**
- **Illusion Mastery** - Enhanced deception
- **Stealth Enhancement** - Improved invisibility
- **Mystery Empowerment** - Enhanced unpredictable abilities
- **Reality Distortion** - Changing perceptions

**Negative Effects:**
- **Illusion Confusion** - Reduced accuracy
- **Stealth Detection** - Reduced stealth abilities
- **Mystery Fear** - Reduced effectiveness
- **Reality Bind** - Movement restriction

**Environmental Effects:**
- **Illusion Field** - Deception effects
- **Mystery Zone** - Unpredictable effects
- **Stealth Realm** - Enhanced stealth
- **Reality Distortion** - Perception changes

#### KRYNN - Dragons & Fire
**Theme:** Power, fire, dragon magic
**Positive Effects:**
- **Dragon Strength** - Enhanced damage
- **Fire Absorption** - Healing from fire
- **Scale Armor** - Damage reduction
- **Dragon Fear** - Intimidating enemies

**Negative Effects:**
- **Dragon Weakness** - Reduced effectiveness
- **Fire Vulnerability** - Extra damage from fire
- **Scale Damage** - Reduced defense
- **Dragon Fear** - Reduced effectiveness

**Environmental Effects:**
- **Dragon Territory** - Enhanced dragon abilities
- **Fire Field** - Hazardous fire effects
- **Scale Zone** - Enhanced defense
- **Dragon Energy** - Enhanced abilities

#### TAURON - Technology & Fusion
**Theme:** Technology, fusion, digital power
**Positive Effects:**
- **Tech Enhancement** - Enhanced technological abilities
- **Fusion Power** - Combined magic and tech
- **Digital Protection** - Damage reduction
- **Machine Learning** - Adaptive abilities

**Negative Effects:**
- **Tech Vulnerability** - Reduced technological abilities
- **Fusion Instability** - Unpredictable effects
- **Digital Corruption** - System damage
- **Machine Malfunction** - Ability failures

**Environmental Effects:**
- **Tech Field** - Enhanced technology
- **Fusion Zone** - Combined effects
- **Digital Realm** - Digital effects
- **Machine Energy** - Enhanced abilities

#### AELRIA - Reality & Will
**Theme:** Reality manipulation, pure will, manifestation
**Positive Effects:**
- **Reality Mastery** - Enhanced reality manipulation
- **Will Empowerment** - Enhanced determination
- **Thought Projection** - Mental abilities
- **Creation Power** - Making from nothing

**Negative Effects:**
- **Reality Bind** - Movement restriction
- **Will Drain** - Reduced determination
- **Thought Confusion** - Mental impairment
- **Creation Block** - Ability restriction

**Environmental Effects:**
- **Reality Field** - Reality manipulation
- **Will Zone** - Enhanced determination
- **Thought Realm** - Mental effects
- **Creation Space** - Manifestation effects

### Effect Mechanics

#### DURATION TYPES
- **Instant** - Immediate effect
- **Temporary** - Short-term effect
- **Persistent** - Long-term effect
- **Permanent** - Lasting effect
- **Conditional** - Effect based on conditions

#### STACKING TYPES
- **Non-stacking** - Only one instance
- **Stacking** - Multiple instances
- **Intensifying** - Increasing effect with stacks
- **Diminishing** - Decreasing effect with stacks
- **Capping** - Maximum effect limit

#### REMOVAL TYPES
- **Natural** - Wears off over time
- **Manual** - Can be removed by abilities
- **Conditional** - Removed by specific conditions
- **Permanent** - Cannot be removed
- **Transferable** - Can be transferred to others

### Effect Synergies

#### ELEMENTAL COMBINATIONS
- **Fire + Ice** - Steam effects
- **Lightning + Water** - Electrified water
- **Earth + Wind** - Sandstorm effects
- **Light + Shadow** - Balance effects

#### WORLD COMBINATIONS
- **Terra + Elysion** - Nature and light
- **Nokturn + Krynn** - Shadow and fire
- **Sylithar + Aethra** - Time and wind
- **Tauron + Aelria** - Technology and reality

#### CLASS COMBINATIONS
- **Warrior + Mage** - Physical and magical effects
- **Rogue + Healer** - Stealth and healing effects
- **Explorer + Warrior** - Environmental and combat effects
- **Mage + Healer** - Magical and restorative effects

### Effect Scaling

#### LEVEL-BASED SCALING
- **Effect strength** - Increases with level
- **Effect duration** - Changes with level
- **Effect cost** - Changes with level
- **Effect resistance** - Changes with level

#### EQUIPMENT-BASED SCALING
- **Weapon scaling** - Effects scale with weapon power
- **Armor scaling** - Effects scale with armor
- **Accessory scaling** - Effects scale with accessories
- **Set bonus scaling** - Effects enhanced by set bonuses

#### WORLD-BASED SCALING
- **Home world bonus** - Effects stronger in their world
- **Foreign world penalty** - Effects weaker in other worlds
- **World synergy** - Effects work better with world-specific items
- **Cross-world combinations** - Special effects when combining worlds

### Implementation Priority

#### PHASE 1: BASIC EFFECTS (Week 1)
1. Create 20 basic buffs and debuffs
2. Implement simple stat modifications
3. Create basic duration and stacking mechanics
4. Set up basic effect scaling

#### PHASE 2: WORLD EFFECTS (Week 2)
1. Create 10 world-specific effects per world (90 total)
2. Implement unique world mechanics
3. Create environmental interaction effects
4. Set up world-specific scaling

#### PHASE 3: ADVANCED EFFECTS (Week 3)
1. Create 5 advanced effects per world (45 total)
2. Implement complex effect mechanics
3. Create effect combinations and synergies
4. Set up advanced effect scaling

#### PHASE 4: LEGENDARY EFFECTS (Week 4)
1. Create 3 legendary effects per world (27 total)
2. Implement reality-bending effects
3. Create ultimate effects
4. Set up legendary effect requirements

### Success Metrics
- [ ] 50+ unique status effects across all worlds
- [ ] Each effect has unique mechanics and visuals
- [ ] World-specific themes and synergies
- [ ] Balanced effect progression
- [ ] Interesting tactical choices
- [ ] Complex effect combinations
- [ ] Dynamic effect scaling
- [ ] Comprehensive effect lore

This status effects system will provide the tactical depth and variety needed for AAA-quality combat encounters in Project Orion. 