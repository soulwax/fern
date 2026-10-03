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

---

## 🔊 Sound Design & Multi-Channel Audio Architecture

All audio systems in *Fern* are routed through a dedicated multi-channel bus hierarchy (`default_bus_layout.tres`):
- **Bells Bus (Cathedral Church Bell Tolls):** Routed through an `AudioEffectReverb` with 0.70 room size and 0.45 damping, producing an authentic distant valley echo from 01:00 to 06:00.
- **Ambiance Bus:** Low-end wind draft loops howling against the clapboard walls, window breach drafts, cardiac heartbeat pulses, accompanied by authentic timber stress creaks and morning dawn bird song.
- **Creature Bus:** Spatially attenuated wraith growls, floor wood crunches, and bloodcurdling jumpscare screams.
- **SFX Bus:** Distinct metallic rings for the anvil, grinding stone friction, hammer impacts on timber barricades, shutter rattle vibrations, match strikes, candle snuff whooshes, chalk scratching on threshold, and player footsteps.
- **In-Game Mixing:** Master, SFX, and Ambiance levels are independently controllable via the in-game Pause Menu.

---

## 📦 Releases & Distribution

All standalone builds are packaged with the standalone game executable, user manual, game jam manifesto, and promotional cover art.

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
- `verify_v1_6_features.gd`: Validates window rattle, shutter shudder vibration, plank breach, hammer fortification, draft wilt multipliers, and wraith siege routines.
- `verify_v1_5_features.gd`: Validates Daguerreotype shader compilation, toggle events, GrindStone spark emission, and wraith ember ignition.
- `e2e_match_simulation.gd`: Simulates a full game cycle (00:00 to 06:00), testing hourly transitions, victory triggers, station interactions, and wraith speed scaling.
- `verify_difficulty_and_death.gd`: Tests menu button cycling, state multipliers, and HUD jumpscare components.
- `verify_features.gd`: Validates candle snuffing, match relighting, and ladder climbing mechanics.

To run tests in headless mode:
```powershell
godot --headless --script scripts_scratch/verify_v1_6_features.gd
godot --headless --script scripts_scratch/e2e_match_simulation.gd
```


