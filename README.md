<div align="center">

# 🌿 FERN: FARNBLUME
### *The Fern Flower — A Black Forest Folk Horror Survival Game*

[![Release](https://img.shields.io/github/v/release/soulwax/fern?color=blueviolet&label=Definitive%20Edition&logo=github)](https://github.com/soulwax/fern/releases/tag/v0.0.2)
[![Engine](https://img.shields.io/badge/Engine-Godot%204.7%20Forward%2B-478CBF?logo=godotengine&logoColor=white)](https://godotengine.org)
[![Physics](https://img.shields.io/badge/Physics-Jolt%20Physics%203D-ff6600)](https://github.com/godot-jolt/godot-jolt)
[![Platform](https://img.shields.io/badge/Platform-Windows%20x86__64-0078D6?logo=windows&logoColor=white)](https://github.com/soulwax/fern/releases/tag/v0.0.2)
[![Author](https://img.shields.io/badge/Author-soulwax-darkred)](https://github.com/soulwax)

<br/>

![Fern: Farnblume Cover Art](Assets/Textures/cover_art.jpg)

<br/>

**[⬇️ Download Standalone Windows Build (v0.0.2)](https://github.com/soulwax/fern/releases/download/v0.0.2/Fern-v0.0.2-windows-x86_64.zip)** • **[📖 Game Jam Presentation](GAME_JAM_SUBMISSION.md)** • **[📜 Developer Handover](PROJECT_HANDOVER.md)**

</div>

---

## 🌲 The Myth & Lore

> *"In the deepest, suffocating valleys of the 19th-century Black Forest (Schwarzwald), an isolated carpenter plies his trade under the loom of pine trees. On Midsummer Eve (Johannisnacht), the mythical Farnblume (Fern Flower) blooms once every century. To hold it is to perceive that which lies beyond mortal sight. But its sacred bioluminescence also awakens Der Alp—an ancient, invisible forest wraith hungering for the bloom."*

You are the solitary master carpenter. Through the nocturnal ordeal from **00:00 to 06:00**, you must keep the mystical blossom alive by channeling energy through your workshop forge and tools, all while eluding the predatory wraith stalking outside your doors.

---

## ✨ Core Features & Mechanics

- 🌸 **The Handheld Farnblume:** Held in your left hand with living, organic luminescence. Wilt dynamics require constant replenishment at the workshop stations.
- 🕰️ **The Black Forest Standuhr (Mechanical Clock of Dread - v0.0.2):** An antique timber pendulum grandfather clock mounted on the east workshop wall. Ticks with authentic mechanical escapement cadence. As *Der Alp* stalks within 5.5m, time distorts—ticking slows and pitches down into a deep groan; within 2.5m, the clock freezes in dead silence right before an attack. Chimes in resonance with valley church bells on the hour.
- 🧲 **The Warded Iron Horseshoe (Das Hufeisen am Türsturz - v0.0.2):** Cold iron mounted above the entrance door lintel. If the wraith attempts a doorway ambush, the horseshoe discharges a violent cold-iron spark burst and concussive clang, repelling the creature for 3.5s. Can be re-consecrated with Farnblume light (`[E]`) after triggering.
- 🌫️ **Valley Night Mist Ingress & Vapor Wakes (Der Talnebel - v0.0.2):** Mountain fog drifts across the workshop floor, density swelling with open window breaches. When the invisible entity moves across the floorboards, its cloven steps part the mist, generating visible swirling vapor wakes that expose its ground path.
- 🪞 **The Zauberspiegel (Silvered Mirror of Truth - v0.0.1):** An antique wall-mounted shaving mirror above the washbench. While the wraith is completely invisible in the room to mortal eyes, looking into the silver mirror reflection reveals its true towering, hollow-eyed antlered phantom stalking behind you or crouching on the rafters! Press `[E]` to wipe accumulated soot from the mirror glass to sharpen reflection clarity.
- 🪵 **Dynamic Floorboard & Rafter Groans (v0.0.1):** Heavy 19th-century oak planks groan and crack under the invisible entity's supernatural weight with 3D spatial attenuation, differentiating elevated rafter strain (`Y > 2.8m`) from ground-floor floorboard cracks to provide vital directional and vertical awareness.
- 🔨 **Workbench Tool Rattling (v0.0.1):** Loose iron mallets, chisels, and ceramic cups vibrate and clatter on workbenches when the entity creeps within 3.8m, providing a tactile domestic warning before candles are snuffed out.
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
| **v0.0.2** | 🌟 **Latest** | **The Black Forest Standuhr, Iron Horseshoe & Fog Ingress:** Mechanical clock with temporal dread dilation, warded iron horseshoe threshold deflection, and valley mist with displaced vapor wakes | [ZIP (306 MB)](https://github.com/soulwax/fern/releases/download/v0.0.2/Fern-v0.0.2-windows-x86_64.zip) |
| **v0.0.1** | Stable | **The Zauberspiegel, Floorboard Groans & Tool Rattles:** Silvered mirror reflection revealing true wraith form, interactive glass wiping, 3D timber floorboard/rafter creaks, and workbench tool tremble foley | [ZIP (306 MB)](https://github.com/soulwax/fern/releases/download/v0.0.1/Fern-v0.0.1-windows-x86_64.zip) |
| **v1.8.0** | Stable | **Walpurgisnacht Thunderstorm, Freezing Breath & Rafter Chains:** Lightning silhouette beams, rolling thunder audio, freezing breath condensation, and dynamic swaying rafter chains with metallic clinking | [ZIP (306 MB)](https://github.com/soulwax/fern/releases/download/v1.8.0/Fern-v1.8.0-windows-x86_64.zip) |
| **v1.7.0** | Stable | **Heartbeat Anxiety & Drudenfuss Consecration:** Proximity sub-bass cardiac pacing, Drudenfuss chalk threshold runes, UV luminescence boost, sulfur burst | [ZIP (306 MB)](https://github.com/soulwax/fern/releases/download/v1.7.0/Fern-v1.7.0-windows-x86_64.zip) |
| **v1.6.0** | Stable | **Workshop Siege Update:** Dynamic window shutter rattles, barricade breaches by Der Alp, draft-induced wilt penalty, hammer repair | [ZIP (306 MB)](https://github.com/soulwax/fern/releases/download/v1.6.0/Fern-v1.6.0-windows-x86_64.zip) |
| **v1.5.0** | Stable | **Daguerreotype & Spark Silhouette:** 19th-century silver halide film grain shader, Grindstone spark wraith ignition & outline, bloom recharge | [ZIP (275 MB)](https://github.com/soulwax/fern/releases/download/v1.5.0/Fern-v1.5.0-windows-x86_64.zip) |
| **v1.4.0** | Stable | **Audio & Graphics Settings:** Multi-channel audio bus layout with valley reverb, Forward+ TAA, VSync, in-game audio channels & F11 fullscreen | [ZIP (275 MB)](https://github.com/soulwax/fern/releases/download/v1.4.0/Fern-v1.4.0-windows-x86_64.zip) |
| **v1.3.0** | Stable | **Definitive Jam Edition:** High-res key art, complete jam presentation page, full audio foley suite | [ZIP (274 MB)](https://github.com/soulwax/fern/releases/download/v1.3.0/Fern-v1.3.0-windows-x86_64.zip) |
| **v1.2.0** | Stable | Difficulty presets (Midsummer, Walpurgisnacht, Stille Nacht), death jumpscare cinematic & epitaph | [ZIP (303 MB)](https://github.com/soulwax/fern/releases/download/v1.2.0/Fern-v1.2.0-windows-x86_64.zip) |
| **v1.1.0** | Stable | Candle snuffing & relighting, loft catwalks, ladder climbing, howling wind loop | [ZIP (303 MB)](https://github.com/soulwax/fern/releases/download/v1.1.0/Fern-v1.1.0-windows-x86_64.zip) |
| **v1.0.0** | Initial | Initial release featuring workshop arena, Farnblume UV bloom, and wraith AI | [ZIP (302 MB)](https://github.com/soulwax/fern/releases/download/v1.0.0/Fern-v1.0.0-windows-x86_64.zip) |



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
