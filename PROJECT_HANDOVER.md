# 🌿 FERN: FARNBLUME (The Fern Flower)
### *Gothic Black Forest Survival Horror — Definitive Edition Handover*
**Author:** `soulwax`  
**Engine:** Godot Engine 4.7 Forward+ (Jolt Physics 3D)  
**Target Platform:** Windows Desktop (x86_64)  
**GitHub Repository:** [`soulwax/fern`](https://github.com/soulwax/fern)

---

## 📖 Overview & Lore

In the secluded, mist-shrouded valleys of the 19th-century Black Forest (*Schwarzwald*), an isolated carpenter plies his trade under the shadow of ancient pine trees. On Midsummer Eve (*Johannisnacht*), the legendary **Farnblume** (Fern Flower) blooms only once every hundred years.

Possessing this mystical bioluminescent blossom grants supernatural vision—revealing secrets buried beneath mortal sight. But its glow also stirs **Der Alp** (The Forest Wraith), an ancient predatory entity that hunts in the dark. 

Your objective: Keep the flower alive from **00:00 to 06:00** by harvesting mystical energy from your workshop stations, while staving off *Der Alp* with iron tools, warding salt (*Drudenfuss*), and holy candleflames.

---

## 🕹️ Controls Reference

| Input | Action | Description |
|---|---|---|
| **W, A, S, D** | Movement | Navigate the carpenter's workshop and upper catwalks. |
| **Shift** (Hold) | Sprint | Dash to escape *Der Alp* (depletes stamina bar). |
| **Space** | Jump | Leap across workshop obstacles and floorboards. |
| **Mouse** | Look | First-person camera orientation with smooth look smoothing. |
| **F** / **Right Click** | Farnblume UV Bloom | Activate flower's bioluminescence; reveals wraith hoofprints and unseen horrors. |
| **E** / **Left Click** | Interact | Work forge stations, relight snuffed candles, climb loft ladders, or repair salt thresholds. |
| **F11** | Toggle Fullscreen | Instant switch between windowed and exclusive fullscreen. |
| **Escape** | Pause Menu | Pause game, view controls, adjust graphics, and customize audio channels. |

---

## 🕯️ Core Gameplay Systems & Mechanics

### 1. The Farnblume (Fern Flower) Cycle
- **Handheld Companion:** Held continuously in the carpenter's left hand with ambient organic breathing animation and gentle blue-violet emission.
- **UV Bloom Mode (`F` or RMB):** Expands the light radius and increases luminescence intensity ($8\times$ boost), revealing invisible clues such as:
  - Cloven hoofprints left on the wooden floor by *Der Alp*.
  - Hidden runes and occult markers on the walls.
- **Wilt Dynamic:** The blossom slowly wilts over time. If the petal health drops to 0%, the flower dies and darkness consumes you.
- **Recharging the Blossom:** Completing tasks at the **GrindStoneStation** (sharpening iron tools) and **AnvilStation** (hammering iron nails) showers the workshop in spark particles and restores the flower's vital essence.

### 2. Der Alp (The Invisible Wraith AI)
- **Stalking Mode:** The wraith roams outside the windows and through workshop shadows, completely invisible to the naked eye.
- **Auditory & Visual Cues:** Wooden creaks, cloven hoofprints glowing under UV light, and gusting draft windows announce its approach.
- **Candle Snuffing:** As *Der Alp* nears a lit candle station within 3.5m, the flame sputters, blows out with grey smoke, and plunges the area into freezing dark. Players can strike a match (`[E]`) to relight it.
- **The Drudenfuss (Pentagram Salt Threshold):** The main door is protected by a consecrated salt line. If breached by the wraith, it degrades and must be replenished before the beast can enter freely.
- **Hunting Phase:** When enraged or when the player is caught in the dark without light, *Der Alp* enters full hunt, sprinting toward the player with guttural shrieks.

### 3. Loft & Catwalk Verticality
- **Ladder Stations (`LadderStation.tscn`):** Interactive ladders allow rapid ascension to the elevated storage rafters and drying beams.
- **Tactical Advantage:** Climbing the ladder freezes ground pursuit and provides high-ground sightlines over the workshop floor to plan station visits safely.

### 4. Difficulty Modes
Accessible directly from the **Main Menu**:
1. **Midsummer Eve (Standard):** Balanced wilt rate and wraith stalk/hunt speed for the authentic atmospheric horror experience.
2. **Walpurgisnacht (Nightmare):** 1.5× faster wilt rate, 1.25× wraith sprint speed, aggressive candle snuffing, and shorter station cooldowns.
3. **Stille Nacht (Story / Explorer):** 0.5× wilt rate, slower wraith speed, allowing exploratory enjoyment of the Gothic folklore atmosphere.

### 5. Death Jumpscare & Folklore Epitaph
- Upon being captured, the camera violently snaps toward the towering visage of *Der Alp*, punctuated by a bloodcurdling screech and crimson claw-strike screen flash.
- A personalized game-over sequence displays survival statistics (hours survived, stations worked, candles relit) and the German folklore epitaph:
  > *"Der Wald nimmt, was sein ist. Deine Knochen nähren die Wurzeln."*  
  > *(The forest takes what is its own. Your bones nourish the roots.)*

### 6. 19th-Century Daguerreotype Post-Processing & Spark Silhouette
- **Gothic Daguerreotype Shader (`daguerreotype_post_process.gdshader`):** Simulates 19th-century silver halide grain, claustrophobic radial vignetting, vintage curved glass chromatic aberration, and rich chiaroscuro contrast. Full toggle in Pause Menu.
- **Grindstone Spark Silhouette Detection:** Spinning the grindstone sprays sparks that coat *Der Alp*'s body in incandescent orange embers (`ember_amount`), stunning the wraith and exposing its stag silhouette in the dark while replenishing the Farnblume's bloom.

### 7. Workshop Siege & Perimeter Barricades
- **Dynamic Shutter Rattles:** *Der Alp* stalks exterior windows (`WindowBreachNorth`, `WindowBreachEast`, `WindowBreachWest`), violently rattling the timber shutters.
- **Plank Breaches & Draft Penalties:** If unaddressed, barricade planks splinter off. Each open breach increases the Farnblume's wilt rate by +20% and triggers whistling cold wind drafts.
- **UV Flaring & Hammer Repairs:** Shining the flower's UV bloom (`F`) at the window terrifies the wraith into retreating. Nailing timber planks back on (`[E]`) restores fortification and seals drafts.

### 8. Heartbeat Anxiety & Drudenfuss Consecration
- **Dual-Loop Cardiac Pulse:** Sub-bass rhythmic heartbeats on the `Ambiance` bus. As *Der Alp* stalks within 12.0m, a slow thudding heartbeat sets in; within 6.0m, it escalates to frantic panic (~140 BPM) with peripheral vignette pulsing.
- **UV-Reactive Drudenfuss Threshold:** Drawing the warded threshold plays abrasive chalk scratching audio (`chalk_scratch.wav` on `SFX` bus). Active runes glow with holy blue-violet light that intensifies under the Farnblume's UV beam. If *Der Alp* collides with the barrier, it ignites sulfur smoke particles and forces a screeching retreat.
- **Concussive Anvil Ring:** Workshop anvil strikes route through the `SFX` bus with 14m shockwave stun.

### 9. Walpurgisnacht Thunderstorm, Freezing Breath & Rafter Chains (v1.8.0)
- **Thunderstorm & Lightning Silhouettes:** Distant lightning flashes cast sharp chiaroscuro beams through the workshop windows, illuminating *Der Alp*'s terrifying branching antlered shadow against timber walls followed by rolling valley thunder.
- **Exhaled Freezing Breath Condensation:** As *Der Alp* stalks within 7.5m or cold night drafts seep through broken window breaches, ambient temperature plunges, producing rhythmic clouds of translucent condensed breath in the player's view.
- **Dynamic Rafter Chains & Foley Clinking:** Ceiling chains and hooks sway with realistic pendulum physics and metallic clinking when the entity or player passes beneath or through them.

### 10. The Zauberspiegel, Floorboard Groans & Tool Rattles (v0.0.1)
- **The Zauberspiegel (Silvered Mirror of Truth):** An antique wall-mounted shaving mirror above the washbench. While the wraith is completely invisible in the room to mortal eyes, looking into the silver mirror reflection reveals its true towering, hollow-eyed antlered phantom stalking behind you or crouching on the rafters! Press `[E]` to wipe accumulated soot from the mirror glass (`mirror_wipe.wav`) to sharpen reflection clarity.
- **Dynamic Floorboard & Rafter Groans:** Heavy 19th-century oak planks groan and crack under the invisible entity's supernatural weight with 3D spatial attenuation, differentiating elevated rafter strain (`Y > 2.8m`) from ground-floor floorboard cracks to provide vital directional and vertical awareness.
- **Workbench Tool Rattling:** Loose iron mallets, chisels, and ceramic cups vibrate and clatter on workbenches when the entity creeps within 3.8m, providing a tactile domestic warning before candles are snuffed out.

### 11. The Black Forest Standuhr, Iron Horseshoe Ward & Valley Fog Ingress (v0.0.2)
- **The Standuhr (Mechanical Clock of Dread):** Antique wooden pendulum grandfather clock ticking with mechanical escapement. When *Der Alp* stalks within 5.5m, time distorts—ticking slows down, drops in pitch, and completely freezes in dead silence within 2.5m! Strikes resonant chimes in harmony with valley cathedral bells on each hour.
- **The Warded Iron Horseshoe (Das Hufeisen am Türsturz):** Cold iron mounted above the entrance lintel. If the wraith attempts a doorway ambush, the horseshoe discharges a violent cold-iron spark burst and concussive clang (`horseshoe_strike.wav`), repelling the creature for 3.5s. Can be re-consecrated with Farnblume light (`[E]`) after triggering.
- **Valley Night Mist Ingress & Vapor Wakes (Der Talnebel):** Mountain fog drifts across the workshop floor, density swelling with open window breaches. When the invisible entity moves across the floorboards, its cloven steps part the mist, generating visible swirling vapor wakes that expose its ground path.

### 12. Consecrated Salt Lines, Turbulent Candle Drafts & Pine Shaving Soundtraps (v0.0.3)
- **Consecrated Salt Lines & Sizzling Thresholds:** A consecrated salt line laid across the entrance vestibule. When *Der Alp* attempts to cross, the salt bursts into white-hot sizzles and crackling particles (`salt_sizzle.wav`), repelling the wraith for 4.0s. Has 2 durability charges before breaking and can be replenished by re-strewn salt (`[E]`).
- **Turbulent Candle Drafts & Dynamic Flame Tilt:** Unbarricaded or broken window breaches channel atmospheric mountain drafts into the workshop. Candle flames violently tilt, stretch, and flicker according to localized wind vectors, sputtering and smoking before blowing out completely if breaches remain unsealed.
- **Pine Shaving Soundtraps:** Carpentry pine shavings scattered across high-traffic floor areas. Walking over them—or when the invisible wraith creeps across them—triggers crisp tactile wood crushing and crunching audio (`shavings_crunch.wav`), acting as an early auditory tripwire in the dark.

### 13. The Kienspan Resin Torch, Window Shutter Drop-Latches & Pine Pitch Cauldron (v0.0.4)
- **The Kienspan Resin Pitch Torch (Die Pechfackel):** A wall-mounted pine pitch torch soaked in spruce resin and linseed oil. Igniting it (`[E]`) yields 25s of fierce orange firelight, crackling combustion foley (`torch_burn.wav`), and a portable 4.2m protection aura that repels *Der Alp* when workshop candles are snuffed out.
- **Window Shutter Drop-Latch Barricades (Die Fensterläden-Riegel):** Heavy hand-forged wrought-iron drop-latches across interior timber window shutters. When the wraith claws at shutters, slam and wedge the latch (`[E]`) to absorb 2 brute-force impacts (`latch_rattle.wav`), protecting barricade planks from splintering.
- **The Pine Pitch Resin Cauldron (Der Pechkessel):** An antique cast-iron pitch pot on the hearth. Stoking the embers (`[E]`) boils hot pine rosin (`cauldron_boil.wav`) and billows aromatic consecrated spruce vapor into the ceiling rafters, denying elevated ambush perches to *Der Alp* for 45s and forcing it down to the ground floor.

### 14. The Black Forest Cuckoo Automaton, Cold-Iron Framing Chisel & Midsummer Herb Bundles (v0.0.5)
- **The Black Forest Cuckoo Automaton (Die Schwarzwald-Kuckucksuhr):** Hand-carved mechanical wall clock with pinecone weight escapement. Emits authentic dual-pipe wooden bellows cuckoo calls on every half-hour (`cuckoo_call.wav`). If *Der Alp* draws within 6.0m, the supernatural presence chatters and violently jams the escapement gears (`automaton_jam.wav`), giving an unmistakable early acoustic warning. Players can pull descending weight chains (`[E]`) to rewind the clockwork.
- **Cold-Iron Framing Chisel Defense (Das Handgeschmiedete Stemmeisen):** A heavy hand-forged socket framing chisel kept in the central workbench tool rack. When *Der Alp* lunges into critical attack range (<2.2m), the player can strike with cold iron (`[E]` / LMB) with a deafening concussive impact (`chisel_strike.wav`), repelling and staggering the wraith for 3.0s. Dulls upon impact, requiring resharpening at the GrindStone station.
- **Midsummer Eve Consecrated Herb Bundles (Die Johanniskraut-Bündel):** Bundles of dried Saint John's wort and mugwort suspended from upper ceiling rafters. Under the Farnblume's UV bloom, they glow with golden protective runes. Crushing a sprig (`[E]`, `herb_crush.wav`) envelops the player in a fragrant botanical cloud for 20s, suppressing rapid cardiac heartbeat panic audio and masking sprint footsteps from *Der Alp*.

### 15. Charcoal Hearth Bellows, Zinc Rainwater Basin & Carpenter's Drawknife Shavings (v0.0.6)
- **The Charcoal Hearth & Leather Bellows Blast (Das Kohlenbecken & Der Schmiedebalg):** The blacksmith hearth by the stone chimney (`Scenes/Workshop/HearthBellowsStation.tscn`). When *Der Alp* stalks within 5.0m, the supernatural chill quenches glowing coals into a sharp vapor hiss (`ember_hiss.wav`). Interacting with the leather bellows (`[E]`, `bellows_pump.wav`) blasts compressed air into the coals, erupting radiant light, flying sparks, and repelling the creature for 4.0s.
- **The Zinc Rainwater Basin & Droplet Resonator (Das Zink-Regenfass):** A galvanized zinc rainwater bucket catching roof runoff (`Scenes/Workshop/ZincBasinStation.tscn`). Drips with periodic metallic pings (`drip_tap.wav`). When *Der Alp* prowls across roof shingles or ceiling rafters overhead (`Y > 2.4m`), surface tension is arrested—the drip halts, followed by a violent splashing anomaly (`water_splash.wav`). Players can also collect fresh water (`[E]`) to revive the Farnblume.
- **Carpenter's Drawknife & Shaving Snares (Das Zugmesser & Der Hobelspan-Wall):** A curved two-handled drawknife at the timber shaving horse (`Scenes/Workshop/DrawknifeStation.tscn`). Holding `[E]` peels aromatic spruce shavings (`drawknife_peel.wav`). Laid across doorway or window chokepoints, the ribbon snares entangle *Der Alp*, slowing its movement by 40% for 5.0 seconds.

---

## 🔊 Sound Design & Multi-Channel Audio Architecture

All audio systems in *Fern* are routed through a dedicated multi-channel bus hierarchy (`default_bus_layout.tres`):
- **Bells Bus (Cathedral Church Bell Tolls):** Routed through an `AudioEffectReverb` with 0.70 room size and 0.45 damping, producing an authentic distant valley echo from 01:00 to 06:00.
- **Ambiance Bus:** Low-end wind draft loops howling against the clapboard walls, window breach drafts, rolling thunder rumbles, cardiac heartbeat pulses, accompanied by authentic timber stress creaks and morning dawn bird song.
- **Creature Bus:** Spatially attenuated wraith growls, floor wood crunches, and bloodcurdling jumpscare screams.
- **SFX Bus:** Distinct metallic rings for the anvil, swaying ceiling chain clinks, grinding stone friction, hammer impacts on timber barricades, shutter rattle vibrations, match strikes, candle snuff whooshes, chalk scratching on threshold, shivering cold breath puffs, cloth squeaks wiping the silvered mirror, deep oak floorboard/rafter groans, workbench tool rattles, mechanical clock escapement ticks, grandfather clock chimes, cold iron horseshoe ward clangs, consecrated salt sizzles, pine shavings crunches, torch flame crackles, iron shutter drop-latch rattles, viscous pine pitch bubbling, cuckoo calls, chisel impacts, crushed herb crunches, bellows rushes, ember hisses, zinc basin pings, water splashes, drawknife peeling, and player footsteps.
- **In-Game Mixing:** Master, SFX, and Ambiance levels are independently controllable via the in-game Pause Menu.

---

## 📦 Releases & Distribution

All standalone builds are packaged with the standalone game executable, user manual, game jam manifesto, and promotional cover art.

- **v0.0.6 (Charcoal Hearth Bellows, Zinc Rainwater Basin & Carpenter's Drawknife Shavings):** [https://github.com/soulwax/fern/releases/tag/v0.0.6](https://github.com/soulwax/fern/releases/tag/v0.0.6)
- **v0.0.5 (The Black Forest Cuckoo Automaton, Cold-Iron Framing Chisel & Midsummer Herb Bundles):** [https://github.com/soulwax/fern/releases/tag/v0.0.5](https://github.com/soulwax/fern/releases/tag/v0.0.5)
- **v0.0.4 (The Kienspan Resin Torch, Window Drop-Latches & Pine Pitch Cauldron):** [https://github.com/soulwax/fern/releases/tag/v0.0.4](https://github.com/soulwax/fern/releases/tag/v0.0.4)
- **v0.0.3 (Consecrated Salt Lines, Turbulent Candle Drafts & Pine Shaving Soundtraps):** [https://github.com/soulwax/fern/releases/tag/v0.0.3](https://github.com/soulwax/fern/releases/tag/v0.0.3)
- **v0.0.2 (The Black Forest Standuhr, Iron Horseshoe & Fog Ingress):** [https://github.com/soulwax/fern/releases/tag/v0.0.2](https://github.com/soulwax/fern/releases/tag/v0.0.2)
- **v0.0.1 (The Zauberspiegel, Floorboard Groans & Tool Rattles):** [https://github.com/soulwax/fern/releases/tag/v0.0.1](https://github.com/soulwax/fern/releases/tag/v0.0.1)
- **v1.8.0 (Walpurgisnacht Thunderstorm, Freezing Breath & Rafter Chains):** [https://github.com/soulwax/fern/releases/tag/v1.8.0](https://github.com/soulwax/fern/releases/tag/v1.8.0)
- **v1.7.0 (Heartbeat Anxiety & Drudenfuss Consecration):** [https://github.com/soulwax/fern/releases/tag/v1.7.0](https://github.com/soulwax/fern/releases/tag/v1.7.0)
- **v1.6.0 (Workshop Siege Update):** [https://github.com/soulwax/fern/releases/tag/v1.6.0](https://github.com/soulwax/fern/releases/tag/v1.6.0)
- **v1.5.0 (Daguerreotype & Spark Silhouette):** [https://github.com/soulwax/fern/releases/tag/v1.5.0](https://github.com/soulwax/fern/releases/tag/v1.5.0)
- **v1.4.0 (Audio Bus & Graphics Settings Update):** [https://github.com/soulwax/fern/releases/tag/v1.4.0](https://github.com/soulwax/fern/releases/tag/v1.4.0)
- **v1.3.0 (Definitive Jam Edition):** [https://github.com/soulwax/fern/releases/tag/v1.3.0](https://github.com/soulwax/fern/releases/tag/v1.3.0)
- **v1.2.0 (Difficulty & Cinematic Update):** [https://github.com/soulwax/fern/releases/tag/v1.2.0](https://github.com/soulwax/fern/releases/tag/v1.2.0)
- **v1.1.0 (Candles & Verticality Update):** [https://github.com/soulwax/fern/releases/tag/v1.1.0](https://github.com/soulwax/fern/releases/tag/v1.1.0)
- **v1.0.0 (Initial Release):** [https://github.com/soulwax/fern/releases/tag/v1.0.0](https://github.com/soulwax/fern/releases/tag/v1.0.0)

---

## 🛠️ Developer Verification & Test Suite

The project includes headless simulation scripts inside [scripts_scratch/](file:///c:/Users/soulwax/Workspace/Godot/fern/scripts_scratch/):
- `verify_v0_0_6_features.gd`: Validates Hearth Bellows ember chill hiss & flare repel, Zinc Basin droplet rhythm & overhead rafter splash anomaly, and Drawknife shaving peeling & movement slow debuff.
- `verify_v0_0_5_features.gd`: Validates Cuckoo Clock half-hour bellows calls, proximity escapement jamming, weight rewind, Cold-Iron Framing Chisel lunging parry/repel, grindstone resharpening, and Midsummer Herb Bundle crushing with heartbeat/scent masking.
- `verify_v1_9_features.gd`: Validates MirrorStation SubViewport reflection setup, Layer 2 wraith true-form visibility, floorboard altitude groans, and workbench tool tremble.
- `verify_v1_8_features.gd`: Validates thunderstorm lightning shadow projection, thunder delay, cold breath condensation particles, and hanging chain physics & clinking.
- `verify_v1_7_features.gd`: Validates heartbeat sub-bass cardiac pacing, Drudenfuss threshold UV luminescence, and sulfur repel bursts.
- `verify_v1_6_features.gd`: Validates window rattle, shutter shudder vibration, plank breach, hammer fortification, draft wilt multipliers, and wraith siege routines.
- `verify_v1_5_features.gd`: Validates Daguerreotype shader compilation, toggle events, GrindStone spark emission, and wraith ember ignition.
- `e2e_match_simulation.gd`: Simulates a full game cycle (00:00 to 06:00), testing hourly transitions, victory triggers, station interactions, and wraith speed scaling.
- `verify_difficulty_and_death.gd`: Tests menu button cycling, state multipliers, and HUD jumpscare components.
- `verify_features.gd`: Validates candle snuffing, match relighting, and ladder climbing mechanics.

To run tests in headless mode:
```powershell
godot --headless --script scripts_scratch/verify_v0_0_5_features.gd
godot --headless --script scripts_scratch/e2e_match_simulation.gd
```


