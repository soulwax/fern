<div align="center">

# 🌿 FERN: FARNBLUME
### *The Fern Flower — A Black Forest Folk Horror Survival Game*

[![Release](https://img.shields.io/github/v/release/soulwax/fern?color=blueviolet&label=Definitive%20Edition&logo=github)](https://github.com/soulwax/fern/releases/tag/v0.0.7)
[![Engine](https://img.shields.io/badge/Engine-Godot%204.7%20Forward%2B-478CBF?logo=godotengine&logoColor=white)](https://godotengine.org)
[![Physics](https://img.shields.io/badge/Physics-Jolt%20Physics%203D-ff6600)](https://github.com/godot-jolt/godot-jolt)
[![Platform](https://img.shields.io/badge/Platform-Windows%20x86__64-0078D6?logo=windows&logoColor=white)](https://github.com/soulwax/fern/releases/tag/v0.0.7)
[![Author](https://img.shields.io/badge/Author-soulwax-darkred)](https://github.com/soulwax)

<br/>

![Fern: Farnblume Cover Art](Assets/Textures/cover_art.jpg)

<br/>

**[⬇️ Download Standalone Windows Build — v0.0.7](https://github.com/soulwax/fern/releases/download/v0.0.7/Fern-v0.0.7-windows-x86_64.zip)** • **[📖 Game Jam Presentation](GAME_JAM_SUBMISSION.md)** • **[📜 Developer Handover](PROJECT_HANDOVER.md)**

</div>

---

## 🌲 The Myth & Lore

> *"In the deepest, suffocating valleys of the 19th-century Black Forest (Schwarzwald), an isolated carpenter plies his trade under the loom of pine trees. On Midsummer Eve (Johannisnacht), the mythical Farnblume (Fern Flower) blooms once every century. To hold it is to perceive that which lies beyond mortal sight. But its sacred bioluminescence also awakens Der Alp—an ancient, invisible forest wraith hungering for the bloom."*

You are the solitary master carpenter. Through the nocturnal ordeal from **00:00 to 06:00**, you must keep the mystical blossom alive by channeling energy through your workshop forge and tools, all while eluding the predatory wraith stalking outside your doors.

---

## ✨ Core Features & Mechanics

- 🔔 **Der Glockenstrick (Belfry Bell Rope & Rafter Shockwave):** Suspended hemp bell rope connecting to the workshop roof belfry. Pulling the rope (`[E]`, `bell_rope_pull.wav`) triggers a powerful resonant chime (`belfry_chime.wav`) that sends an acoustic shockwave through the upper rafters, stunning *Der Alp* and forcing it down out of elevated perches.
- 🪔 **Die Leinöllampe (Linseed Oil Sanctuary Lamp):** Heavy brass hanging lamp fueled by carpenter's linseed oil. Igniting the wick (`[E]`, `wick_turn.wav`) projects a focused golden illumination cone, creating a safe sanctuary that rapidly regenerates carpenter stamina and deters *Der Alp* from entering a full HUNT charge.
- 💨 **Das Wacholder-Räucherfass (Juniper Rosin Incense Censer):** Perforated copper thurible burner filled with spruce rosin, dried juniper, and thyme. Stoking the coals (`[E]`, `censer_ignite.wav`) billows fragrant consecrated smoke for 35s, suppressing creeping floor mist by 70% and revealing unseen entity footstep wakes.
- 🏗️ **Workshop Geometry Realignment & Delta Physics Stabilization:** Aligned workshop 3D geometry transform from elevation disparity down to world floor plane, with clamped safe delta, exponential decay velocity integration, and instant floor vertical velocity arrest preventing all tunneling through geometry during frame hitches.
- 🪵 **Die Totenbretter (Ancestral Memorial Ward Planks):** Inscribe and consecrate an authentic Black Forest death plank ward (`[E]`, `totenbrett_consecrate.wav`). When *Der Alp* stalks within 3.5m, the ancestral ward erupts in radiant violet runes, repelling the creature for 4.0s.
- 🌿 **Das Ebereschen-Amulett (Rowan Wood Talisman Carving):** Carve a protective amulet from sacred rowan wood at the secondary carving bench (`[E]`, `talisman_carve.wav`), bestowing a permanent +12% sprint speed boost and a 25% reduction in panic heartbeat anxiety thresholds.
- 🔔 **Das Glasglockenspiel (Acoustic Glass Rafter Carillons):** Hand-blown forest-glass bells suspended from the workshop rafters. Resonates with crystalline spatial chimes (`glass_carillon_chime.wav`) and visual swaying whenever *Der Alp* creeps through elevated rafter catwalks.
- 🍞 **Das Opferbrot (Folkloric Appeasement Offering Trencher):** Slice and place a hearty rye loaf on the central workshop trencher (`[E]`, `bread_slice_place.wav`). When *Der Alp* stalks or hunts, it catches the scent of rye and detours to feed upon the trencher for 18 seconds (`wraith_appeased_feed.wav`), suspending its hunt and pacifying its aggression.
- 🕯️ **Der Albschatten (Spectral Shadow Silhouette Projection):** Even when *Der Alp* is invisible to direct gaze, strong workshop illumination (hearth fire, resin cauldron, torches, candles) casts its towering, antlered silhouette across the timber walls and ceiling floorboards (`SHADOW_CASTING_SETTING_SHADOWS_ONLY`).
- ❄️ **Frost Ingress & Shingle Gale Chatter:** Temperatures plunge near windows when *Der Alp* lingers, visibly creeping frost patterns across the glass and frames. Rafter movement triggers violent storm wind gusts rattling roof shingles (`shingle_gale_rattle.wav`).
- 🌸 **The Handheld Farnblume:** Held in your left hand with living, organic luminescence. Wilt dynamics require constant replenishment at the workshop stations.
- 🔥 **The Charcoal Hearth & Leather Bellows Blast (Das Kohlenbecken & Der Schmiedebalg):** The blacksmith hearth by the stone chimney. When *Der Alp* stalks within 5.0m, the supernatural chill quenches glowing coals into a sharp vapor hiss (`ember_hiss.wav`). Interacting with the leather bellows (`[E]`, `bellows_pump.wav`) blasts compressed air into the coals, erupting radiant light, flying sparks, and repelling the creature for 4.0s.
- 🌧️ **The Zinc Rainwater Basin & Droplet Resonator (Das Zink-Regenfass):** A galvanized zinc rainwater bucket catching roof runoff. Drips with periodic metallic pings (`drip_tap.wav`). When *Der Alp* prowls across roof shingles or ceiling rafters overhead (`Y > 2.4m`), surface tension is arrested—the drip halts, followed by a violent splashing anomaly (`water_splash.wav`). Players can also collect fresh water (`[E]`) to revive the Farnblume.
- 🪓 **Carpenter's Drawknife & Shaving Snares (Das Zugmesser & Der Hobelspan-Wall):** A curved two-handled drawknife at the timber shaving horse. Holding `[E]` peels aromatic spruce shavings (`drawknife_peel.wav`). Laid across doorway or window chokepoints, the ribbon snares entangle *Der Alp*, slowing its movement by 40% for 5.0 seconds.
- 🕰️ **The Black Forest Cuckoo Automaton (Die Schwarzwald-Kuckucksuhr):** Hand-carved mechanical clock with carved bird door and dual-pipe bellows. Calls on half-hours (`cuckoo_call.wav`). If *Der Alp* creeps within 6.0m, the mechanism chatters and violently jams (`automaton_jam.wav`), giving an unmistakable domestic acoustic alarm. Rewind the descending pinecone weights (`[E]`) to keep time running.
- 🔨 **Cold-Iron Framing Chisel Defense (Das Handgeschmiedete Stemmeisen):** A heavy socket framing chisel kept on the workbench tool rack. When *Der Alp* lunges into critical attack range (<2.2m), strike with cold iron (`[E]` / LMB) with a concussive metallic ring (`chisel_strike.wav`), repelling and staggering the wraith for 3.0s. Dulls upon impact; carry it to the Grindstone to resharpen the cutting bevel under showers of sparks.
- 🌿 **Midsummer Eve Consecrated Herb Bundles (Die Johanniskraut-Bündel):** Bundles of dried Saint John's wort and mugwort suspended from ceiling drying beams. Under the Farnblume's UV bloom, they glow with golden protective runes. Crushing a sprig (`[E]`, `herb_crush.wav`) envelops the player in a fragrant botanical cloud for 20s, suppressing rapid cardiac panic audio and masking sprint footsteps from *Der Alp*.
- 🪵 **The Kienspan Resin Pitch Torch (Die Pechfackel):** A wall-mounted pine pitch torch soaked in spruce resin and linseed oil. Igniting it (`[E]`) yields 25s of fierce orange firelight, crackling foley (`torch_burn.wav`), and a portable 4.2m protection aura that repels *Der Alp* when workshop candles are snuffed out.
- 🔒 **Window Shutter Drop-Latch Barricades (Die Fensterläden-Riegel):** Heavy hand-forged wrought-iron drop-latches across interior timber window shutters. When the wraith claws at shutters, slam and wedge the latch (`[E]`) to absorb 2 brute-force impacts (`latch_rattle.wav`), protecting barricade planks from splintering.
- 🍲 **The Pine Pitch Resin Cauldron (Der Pechkessel):** An antique cast-iron pitch pot on the hearth. Stoking the embers (`[E]`) boils hot pine rosin (`cauldron_boil.wav`) and billows aromatic consecrated spruce vapor into the ceiling rafters, denying elevated ambush perches to *Der Alp* for 45s and forcing it down to the ground floor.
- 🧂 **Consecrated Salt Lines & Sizzling Thresholds:** A consecrated salt line laid across the entrance vestibule. If *Der Alp* attempts to cross, the salt bursts into white-hot sizzles and crackling particles (`salt_sizzle.wav`), repelling the wraith for 4.0s. Has 2 durability charges before breaking and can be replenished by re-strewn salt (`[E]`).
- 💨 **Turbulent Candle Drafts & Window Sputter:** Unbarricaded or broken window breaches channel atmospheric mountain drafts into the workshop. Candle flames violently tilt, stretch, and flicker according to localized wind vectors, sputtering and smoking before blowing out completely if breaches remain unsealed.
- 🌲 **Pine Shaving Soundtraps:** Carpentry pine shavings scattered across high-traffic floor areas. Walking over them—or when the invisible wraith creeps across them—triggers crisp tactile wood crushing and crunching audio (`shavings_crunch.wav`), acting as an early auditory tripwire in the dark.
- 🕰️ **The Black Forest Standuhr (Mechanical Clock of Dread):** An antique timber pendulum grandfather clock mounted on the east workshop wall. Ticks with authentic mechanical escapement cadence. As *Der Alp* stalks within 5.5m, time distorts—ticking slows and pitches down into a deep groan; within 2.5m, the clock freezes in dead silence right before an attack. Chimes in resonance with valley church bells on the hour.
- 🧲 **The Warded Iron Horseshoe (Das Hufeisen am Türsturz):** Cold iron mounted above the entrance door lintel. If the wraith attempts a doorway ambush, the horseshoe discharges a violent cold-iron spark burst and concussive clang, repelling the creature for 3.5s. Can be re-consecrated with Farnblume light (`[E]`) after triggering.
- 🌫️ **Valley Night Mist Ingress & Vapor Wakes (Der Talnebel):** Mountain fog drifts across the workshop floor, density swelling with open window breaches. When the invisible entity moves across the floorboards, its cloven steps part the mist, generating visible swirling vapor wakes that expose its ground path.
- 🪞 **The Zauberspiegel (Silvered Mirror of Truth):** An antique wall-mounted shaving mirror above the washbench. While the wraith is completely invisible in the room to mortal eyes, looking into the silver mirror reflection reveals its true towering, hollow-eyed antlered phantom stalking behind you or crouching on the rafters! Press `[E]` to wipe accumulated soot from the mirror glass to sharpen reflection clarity.
- 🪵 **Dynamic Floorboard & Rafter Groans:** Heavy 19th-century oak planks groan and crack under the invisible entity's supernatural weight with 3D spatial attenuation, differentiating elevated rafter strain (`Y > 2.8m`) from ground-floor floorboard cracks to provide vital directional and vertical awareness.
- 🔨 **Workbench Tool Rattling:** Loose iron mallets, chisels, and ceramic cups vibrate and clatter on workbenches when the entity creeps within 3.8m, providing a tactile domestic warning before candles are snuffed out.
- ⚡ **Black Forest Thunderstorm & Shadow Silhouettes:** Periodic distant lightning flashes cast sharp chiaroscuro beams through the workshop windows. Any wraith stalking inside is silhouetted as a towering antlered shadow against the timber walls, followed by deep rolling thunder.
- ❄️ **Exhaled Freezing Breath Condensation:** As *Der Alp* draws near (<7.5m) or cold night drafts seep through broken window breaches, ambient temperature plunges, producing rhythmic clouds of translucent condensed breath in the player's view.
- ⛓️ **Dynamic Rafter Chains & Metallic Foley:** Heavy iron chains suspended from the ceiling sway with authentic pendulum physics and metallic clinking audio when either the entity or player passes beneath or through them.
- 🔨 **Workshop Siege & Perimeter Barricades:** *Der Alp* stalks exterior workshop windows, violently rattling timber shutters with authentic 3D spatial foley. If unaddressed, barricade planks splinter off, allowing whistling cold drafts that accelerate the Farnblume's wilt rate (+20% per open breach). Rush to windows with UV bloom (`F`) to repel the wraith, and nail fresh timber planks (`[E]`) to seal the perimeter.
- 📷 **19th-Century Daguerreotype Post-Processing:** Custom full-screen film grain shader simulating authentic silver halide grain, claustrophobic radial vignetting, vintage curved glass chromatic aberration, and rich chiaroscuro contrast. Fully toggleable in the Pause Menu.
- 💥 **Grindstone Spark Silhouette Detection:** Turn the grindstone foot pedal to shower the room in fiery sparks. Any sparks striking *Der Alp* ignite glowing embers on its stag-horn body for 3 seconds, stunning the entity and outlining its terrifying silhouette in the dark.
- 🔦 **UV Bioluminescent Bloom (`F` / RMB):** Focus the flower's mystical spectrum ($8\times$ intensity boost) to uncover hidden runes and reveal **cloven hoofprints** etched onto floorboards by *Der Alp*.
- 🕯️ **Candle Stations & Alp Snuffing:** Lit candles ward off the darkness. When *Der Alp* stalks within 3.5m, the candle flutters, snuffs out with rising smoke, and plunges the sector into ice-cold black. Strike a match (`[E]`) to restore holy light.
- 🪜 **Loft Catwalks & Vertical Traversal:** Use interactive ladder stations (`LadderStation.tscn`) to scramble into the elevated storage rafters and drying beams, evading ground pursuit and scouting the workshop layout.
- ⚡ **Dynamic Workshop Stations:** Work the **GrindStoneStation** (sparks cascading from tool sharpening) and **AnvilStation** (rhythmic iron forging) to recharge the blossom's vital essence.
- 💓 **Heartbeat Anxiety & Proximity Panic:** As *Der Alp* stalks within 12.0m, an ominous sub-bass heartbeat begins to thud. Within 6.0m, it escalates to frantic cardiac panic (~140 BPM) accompanied by peripheral red vignette darkening, providing vital auditory awareness even in absolute darkness.
- ⛧ **UV-Reactive Drudenfuss Threshold:** A consecrated pentagram chalk barrier shields the entry door. Drawing the rune plays authentic abrasive chalk scratching audio (`[E]`). Active runes glow with holy blue-violet luminescence that intensifies under the Farnblume's UV bloom (`F`), and bursts into sulfur flames when repelling the wraith.
- 👹 **Visceral Death Jumpscare Cinematic:** Snap-turn camera focus onto *Der Alp*, claw-strike crimson flash, bloodcurdling audio screech, survival telemetry, and the German folkloric epitaph:
  > *"Der Wald nimmt, was sein ist. Deine Knochen nähren die Wurzeln."*
- 🎚️ **3 Difficulty Presets:**
  - **Midsummer Eve (Standard):** Authentic atmospheric balance.
  - **Walpurgisnacht (Nightmare):** 1.5× faster wilt rate, 1.25× wraith sprint speed, aggressive candle snuffing.
  - **Stille Nacht (Story / Explorer):** Relaxed wilt, slower stalk speed for atmospheric enjoyment.
- 🔊 **Rich Foley & Multi-Channel Soundscape:** Resonant hourly church bell chimes with valley acoustic reverb, Black Forest howling wind drafts, metallic anvil rings, and procedural pitch modulation.

---

## 🕹️ Controls Reference

| Input | Action | In-Game Effect |
|:---:|:---:|:---|
| <kbd>W</kbd> <kbd>A</kbd> <kbd>S</kbd> <kbd>D</kbd> | **Movement** | Navigate workshop floor and upper rafters |
| <kbd>Shift</kbd> (Hold) | **Sprint** | Sprint to escape *Der Alp* (uses stamina) |
| <kbd>Space</kbd> | **Jump** | Vault over workshop clutter and beams |
| <kbd>Mouse</kbd> | **Look** | Smooth 3D first-person camera control |
| <kbd>F</kbd> / <kbd>Right Click</kbd> | **UV Bloom** | Flare flower's light; reveal hoofprints & runes |
| <kbd>E</kbd> / <kbd>Left Click</kbd> | **Interact** | Work forge stations, relight candles, climb ladders, wipe mirror |
| <kbd>R</kbd> | **Cup Hands** | Shelter the flower blossom to conserve energy |
| <kbd>F11</kbd> | **Toggle Fullscreen** | Instant exclusive/windowed fullscreen switch |
| <kbd>Esc</kbd> | **Pause** | Access options, controls, and return to menu |

---

## 📦 Releases & Downloads

Every standalone release archive is self-contained and pre-configured for Windows x86_64, including the standalone executable, quickstart manual, promotional key art, and folklore manifesto.

| Version | Status | Highlights | Download |
|:---:|:---:|:---|:---:|
| **v0.0.7** | 🌟 **Latest** | **Der Glockenstrick & Das Räucherfass:** Suspended roof belfry bell rope rafter stun shockwave, linseed oil sanctuary lamp stamina recovery & hunt deterrence, juniper rosin incense censer mist suppression & wake detection, and workshop floor alignment & delta physics stabilization | [ZIP](https://github.com/soulwax/fern/releases/download/v0.0.7/Fern-v0.0.7-windows-x86_64.zip) |
| **v0.0.6** | 📦 Stable | **Das Kohlenbecken & Der Hobelspan-Wall:** Charcoal hearth bellows flare defense, galvanized zinc rainwater basin with acoustic overhead rafter anomaly detection and water jar refill, and carpenter's drawknife wood shaving snares (40% slow) | [ZIP](https://github.com/soulwax/fern/releases/download/v0.0.6/Fern-v0.0.6-windows-x86_64.zip) |
| **v0.0.5** | 📦 Stable | **Die Kuckucksuhr & Das Unerschütterliche Fundament:** Cuckoo automaton with escapement jamming telemetry, cold-iron socket framing chisel parry defense, ceiling herb bundles with scent masking, and 4m thick solid continuous floor collision architecture preventing all tunneling/falling | [ZIP](https://github.com/soulwax/fern/releases/download/v0.0.5/Fern-v0.0.5-windows-x86_64.zip) |
| **v0.0.4** | 📦 Stable | **Die Pechfackel:** Portable pine pitch resin torch with active wraith repulsion aura, window shutter drop-latches absorbing siege impacts, and pine pitch resin cauldron for ceiling rafter denial | [ZIP](https://github.com/soulwax/fern/releases/download/v0.0.4/Fern-v0.0.4-windows-x86_64.zip) |
| **v0.0.3** | 📦 Stable | **Die Totenbretter:** Ancestral memorial ward planks, rowan wood talisman carving bench (+12% sprint speed, 25% anxiety reduction), and acoustic glass rafter carillons | [ZIP](https://github.com/soulwax/fern/releases/download/v0.0.3/Fern-v0.0.3-windows-x86_64.zip) |
| **v0.0.2** | 📦 Stable | **Der Albschatten:** Shadow silhouette casting (`SHADOW_CASTING_SETTING_SHADOWS_ONLY`), *Das Opferbrot* bread offering station, and window frost ingress | [ZIP](https://github.com/soulwax/fern/releases/download/v0.0.2/Fern-v0.0.2-windows-x86_64.zip) |
| **v0.0.1** | 📦 Stable | **Farnblume — Initial Release:** Complete Black Forest workshop survival experience with the Farnblume UV bloom, invisible wraith AI, and the full suite of folkloric wards, sensory telemetry, and workshop stations | [ZIP](https://github.com/soulwax/fern/releases/download/v0.0.1/Fern-v0.0.1-windows-x86_64.zip) |



---

## 🛠️ Building & Running from Source

### Prerequisites
- [Godot Engine 4.7 Forward+](https://godotengine.org/download) (or official Windows 64-bit release build)
- [Godot Jolt 3D Physics Extension](https://github.com/godot-jolt/godot-jolt) (configured automatically via `addons/godot-jolt`)

### Running the Project
1. Clone this repository or open the project folder in Godot 4.7.
2. Open `project.godot` inside the Godot Editor.
3. Press <kbd>F5</kbd> (or click **Play Project**) to launch directly into `Scenes/UI/MainMenu.tscn`.

### Headless Verification Test Suite
Run the automated end-to-end match simulation from PowerShell:
```powershell
godot --headless --script scripts_scratch/e2e_match_simulation.gd
```

---

## 📜 Credits & Licensing

- **Game Design & Programming:** [`soulwax`](https://github.com/soulwax)
- **Engine:** Godot Engine 4.7 (Forward+ Renderer, Jolt Physics 3D)
- **Environment Art Assets:** Leartes Studios — Carpenter's Workshop
- **License:** All rights reserved by `soulwax`.
