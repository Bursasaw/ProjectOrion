# ARMOR SETS PLAN
## Project Orion - Unique Armor Set System Implementation

### Overview
Create a comprehensive armor sets system with 20+ unique armor sets across all worlds and character classes. Each set must have distinct bonuses, synergies, and tactical value. Armor sets should reflect world themes and provide meaningful progression choices.

### File Structure
```
data/armor/
├── armor_sets.json (all armor sets)
├── world_armor.json (world-specific armor)
├── class_armor.json (class-specific armor)
├── set_bonuses.json (set bonus effects)
├── armor_stats.json (stat modifications)
├── armor_abilities.json (armor abilities)
├── armor_scaling.json (level-based scaling)
├── armor_loot.json (drop rates and locations)
├── armor_lore.json (background stories)
└── armor_synergies.json (set combinations)
```

### Armor Set Categories

#### BASIC ARMOR SETS (Level 1-10)
- **Starter sets** - Basic protection and stats
- **World-specific sets** - Reflecting world themes
- **Class-specific sets** - Tailored to character classes
- **Craftable sets** - Player-crafted armor

#### ADVANCED ARMOR SETS (Level 10-25)
- **Enhanced sets** - Improved stats and abilities
- **Specialized sets** - Focused on specific playstyles
- **Rare sets** - Harder to obtain but powerful
- **Event sets** - Limited-time availability

#### MASTER ARMOR SETS (Level 25-50)
- **Legendary sets** - Powerful and unique
- **Boss sets** - Obtained from boss encounters
- **World boss sets** - From world boss battles
- **Crafting master sets** - Advanced crafting

#### LEGENDARY ARMOR SETS (Level 50+)
- **Cosmic sets** - Reality-bending armor
- **Divine sets** - God-like protection
- **Void sets** - Dimensional armor
- **Creation sets** - Made from pure will

### World-Specific Armor Sets

#### TERRA - Nature & Life
**Theme:** Organic, living, natural protection
**Armor Sets:**
- **Ancient Bark Set** - Living wood armor with regeneration
- **Crystal Growth Set** - Crystalline armor with reflection
- **Life Force Set** - Pure life energy armor
- **Primal Beast Set** - Animal hide armor with strength
- **Root Network Set** - Connected armor with team bonuses

**Set Bonuses:**
- **2-piece:** Enhanced healing and regeneration
- **4-piece:** Nature-based ability enhancement
- **6-piece:** Primal transformation abilities
- **8-piece:** Complete nature mastery

#### NOKTRUN - Shadows & Void
**Theme:** Dark, ethereal, void-touched
**Armor Sets:**
- **Shadow Stalker Set** - Stealth-focused armor
- **Void Walker Set** - Reality-bending armor
- **Dark Mage Set** - Shadow magic enhancement
- **Nightmare Set** - Fear-inducing armor
- **Void Horror Set** - Dimensional armor

**Set Bonuses:**
- **2-piece:** Enhanced stealth and invisibility
- **4-piece:** Void manipulation abilities
- **6-piece:** Reality distortion powers
- **8-piece:** Complete void mastery

#### ELYSION - Light & Divinity
**Theme:** Holy, divine, sacred protection
**Armor Sets:**
- **Light Guardian Set** - Divine protection armor
- **Holy Warrior Set** - Sacred battle armor
- **Divine Sage Set** - Wisdom-enhancing armor
- **Celestial Set** - Angelic armor
- **Sacred Protector Set** - Pure holy armor

**Set Bonuses:**
- **2-piece:** Divine protection and damage reduction
- **4-piece:** Holy ability enhancement
- **6-piece:** Divine transformation abilities
- **8-piece:** Complete divine mastery

#### SYLITHAR - Crystals & Time
**Theme:** Crystalline, temporal, reflective
**Armor Sets:**
- **Crystal Guardian Set** - Reflective armor
- **Time Weaver Set** - Temporal manipulation armor
- **Mirror Phantom Set** - Duplicating armor
- **Fractal Set** - Geometric armor
- **Temporal Set** - Time-bending armor

**Set Bonuses:**
- **2-piece:** Time manipulation abilities
- **4-piece:** Crystal reflection enhancement
- **6-piece:** Reality duplication powers
- **8-piece:** Complete temporal mastery

#### AETHRA - Wind & Sky
**Theme:** Aerial, free, wind-touched
**Armor Sets:**
- **Wind Spirit Set** - Air manipulation armor
- **Storm Drake Set** - Weather control armor
- **Sky Guardian Set** - Aerial combat armor
- **Cloud Walker Set** - Freedom-enhancing armor
- **Aerial Predator Set** - Flying hunter armor

**Set Bonuses:**
- **2-piece:** Enhanced movement and aerial abilities
- **4-piece:** Weather manipulation powers
- **6-piece:** Complete aerial transformation
- **8-piece:** Complete wind mastery

#### OMBRA - Mystery & Illusion
**Theme:** Deceptive, mysterious, illusionary
**Armor Sets:**
- **Illusionist Set** - Deception-focused armor
- **Mystery Guardian Set** - Secret-keeping armor
- **Veil Walker Set** - Reality-bending armor
- **Shadow Assassin Set** - Stealth combat armor
- **Mystery Set** - Unknown power armor

**Set Bonuses:**
- **2-piece:** Enhanced illusion and deception
- **4-piece:** Reality distortion abilities
- **6-piece:** Complete illusion mastery
- **8-piece:** Complete mystery mastery

#### KRYNN - Dragons & Fire
**Theme:** Powerful, fiery, draconic
**Armor Sets:**
- **Dragon Scale Set** - Dragon hide armor
- **Fire Drake Set** - Flame-resistant armor
- **Dragon Mage Set** - Dragon magic armor
- **Wyrm Set** - Young dragon armor
- **Dragon Lord Set** - Ancient dragon armor

**Set Bonuses:**
- **2-piece:** Fire resistance and dragon abilities
- **4-piece:** Dragon transformation powers
- **6-piece:** Complete dragon mastery
- **8-piece:** Ancient dragon form

#### TAURON - Technology & Fusion
**Theme:** Technological, digital, fused
**Armor Sets:**
- **Tech Golem Set** - Mechanical armor
- **Fusion Set** - Magic-tech hybrid armor
- **Digital Set** - Pure data armor
- **Machine Lord Set** - AI-enhanced armor
- **Cyber Set** - Digital warrior armor

**Set Bonuses:**
- **2-piece:** Technology enhancement abilities
- **4-piece:** Fusion magic-tech powers
- **6-piece:** Complete technological mastery
- **8-piece:** Digital transformation

#### AELRIA - Reality & Will
**Theme:** Reality-bending, willful, manifesting
**Armor Sets:**
- **Reality Weaver Set** - Reality-manipulating armor
- **Will Manifestation Set** - Pure will armor
- **Thought Phantom Set** - Mental armor
- **Creation Set** - Manifestation armor
- **Reality Guardian Set** - Reality-protecting armor

**Set Bonuses:**
- **2-piece:** Reality manipulation abilities
- **4-piece:** Will manifestation powers
- **6-piece:** Complete reality mastery
- **8-piece:** Pure creation abilities

### Class-Specific Armor Sets

#### WARRIOR ARMOR SETS
- **Battle Master Set** - Enhanced combat abilities
- **Tactical Set** - Strategic combat armor
- **Physical Set** - Strength-focused armor
- **Combat Set** - Reflex-enhancing armor
- **Guardian Set** - Protection-focused armor

#### MAGE ARMOR SETS
- **Arcane Set** - Magic-enhancing armor
- **Elemental Set** - Element manipulation armor
- **Mana Set** - Energy-focused armor
- **Spell Set** - Spell-casting armor
- **Wizard Set** - Knowledge-enhancing armor

#### ROGUE ARMOR SETS
- **Stealth Set** - Invisibility-enhancing armor
- **Precision Set** - Critical hit armor
- **Shadow Set** - Shadow-walking armor
- **Assassin Set** - Deadly strike armor
- **Thief Set** - Agility-focused armor

#### HEALER ARMOR SETS
- **Divine Set** - Healing-enhancing armor
- **Protection Set** - Defensive armor
- **Purification Set** - Cleansing armor
- **Life Set** - Life-force armor
- **Sacred Set** - Holy protection armor

#### EXPLORER ARMOR SETS
- **Environmental Set** - Terrain-adapting armor
- **Movement Set** - Mobility-enhancing armor
- **Survival Set** - Adaptation armor
- **Discovery Set** - Knowledge-gathering armor
- **Adventure Set** - Exploration-focused armor

### Set Bonus Mechanics

#### STAT ENHANCEMENTS
- **Health bonuses** - Increased maximum health
- **Defense bonuses** - Damage reduction
- **Speed bonuses** - Movement and action speed
- **Accuracy bonuses** - Hit chance improvement
- **Critical bonuses** - Critical hit enhancement

#### ABILITY ENHANCEMENTS
- **Ability power** - Increased ability effectiveness
- **Ability cost** - Reduced ability costs
- **Ability cooldown** - Faster ability recharge
- **Ability range** - Extended ability range
- **Ability effects** - Enhanced ability effects

#### SPECIAL ABILITIES
- **Unique powers** - Set-specific abilities
- **Transformations** - Character state changes
- **Environmental effects** - Terrain manipulation
- **Team abilities** - Ally enhancement
- **Ultimate abilities** - Powerful set bonuses

#### SYNERGY EFFECTS
- **World synergy** - Enhanced in specific worlds
- **Class synergy** - Enhanced for specific classes
- **Ability synergy** - Enhanced with specific abilities
- **Equipment synergy** - Enhanced with specific items
- **Team synergy** - Enhanced with specific allies

### Armor Scaling System

#### LEVEL-BASED SCALING
- **Stat scaling** - Stats increase with level
- **Ability scaling** - Abilities improve with level
- **Cost scaling** - Requirements change with level
- **Effect scaling** - Effects strengthen with level

#### WORLD-BASED SCALING
- **Home world bonus** - Enhanced in native world
- **Foreign world penalty** - Reduced in other worlds
- **World synergy** - Enhanced with world-specific items
- **Cross-world combinations** - Special effects when combining worlds

#### EQUIPMENT-BASED SCALING
- **Weapon synergy** - Enhanced with specific weapons
- **Accessory synergy** - Enhanced with specific accessories
- **Mod synergy** - Enhanced with specific mods
- **Set synergy** - Enhanced with other sets

### Implementation Priority

#### PHASE 1: BASIC SETS (Week 1)
1. Create 5 basic armor sets per world (45 total)
2. Implement basic set bonuses
3. Create simple stat enhancements
4. Set up basic armor scaling

#### PHASE 2: ADVANCED SETS (Week 2)
1. Create 3 advanced sets per world (27 total)
2. Implement complex set bonuses
3. Create unique abilities and transformations
4. Set up advanced armor scaling

#### PHASE 3: LEGENDARY SETS (Week 3)
1. Create 2 legendary sets per world (18 total)
2. Implement reality-bending abilities
3. Create ultimate set bonuses
4. Set up legendary armor requirements

#### PHASE 4: CLASS SETS (Week 4)
1. Create 5 class-specific sets per class (25 total)
2. Implement class-specific bonuses
3. Create class synergies
4. Set up class-specific scaling

### Success Metrics
- [ ] 20+ unique armor sets across all worlds
- [ ] Each set has unique bonuses and abilities
- [ ] World-specific themes and synergies
- [ ] Balanced armor progression
- [ ] Interesting tactical choices
- [ ] Complex set combinations
- [ ] Dynamic armor scaling
- [ ] Comprehensive armor lore

This armor sets system will provide the equipment foundation needed for AAA-quality character progression in Project Orion. 