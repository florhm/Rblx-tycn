# 🌋 Mining Empire Tycoon

![Roblox](https://img.shields.io/badge/Roblox-Studio-00A2FF?style=for-the-badge&logo=roblox&logoColor=white)
![Language](https://img.shields.io/badge/Luau-5.1-000080?style=for-the-badge&logo=lua&logoColor=white)
![Build Tool](https://img.shields.io/badge/Rojo-Supported-red?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

A complete, high-performance **Roblox Tycoon Prototype** featuring 6 mirrored arena plots, 10 ore & gem tier droppers, 2-floor expansion, security laser gates, PvP weapons, cash vaults, and procedural volcanic scenery.

---

## 🌟 Highlights & Features

- 🏛️ **6 Mirrored Arena Plots:** Arranged in 2 opposing rows facing a central Cobblestone plaza, each with a unique neon accent color and auto-orienting conveyor belts.
- 💎 **10-Tier Progression:**
  - **Ground Floor:** Dirt ($1), Stone ($3), Coal ($8), Iron ($20), Silver ($50), Gold ($120), Diamond ($300)
  - **Floor 2:** Ruby Rig ($750), Emerald Crusher ($2,000), Uranium Refinery ($5,000), Voidstone Extractor ($15,000)
- 🏦 **Vault & Cash Hub:** Ore revenue collects on the plot's vault pad. Touch your Cash Hub to hear an HD cash register sound (`rbxassetid://101396758527961`), trigger a golden particle burst, and claim your earnings.
- ⚡ **Security Laser Gate:** Non-owner players who cross an active laser door are instantly eliminated with kill particles and audio.
- ⚔️ **Armory & PvP Cash Drops:** Equip the **Miner's Sword** (35 DMG), **Laser Blaster** (25 DMG), or **Rail Gun** (100 DMG). Defeated players drop 10% of their cash as physical gold loot.
- 🌋 **Procedural Volcanic Landscape:** Dark basalt terrain, central plaza, street lamps, radial pathways, and 28 mountain peaks lining the horizon.

---

## 🏗️ Project Structure & Architecture

```
Rblx-tycn/
├── default.project.json           # Rojo project configuration
├── README.md                      # Project documentation
├── docs/                          # GitHub Pages showcase site
│   └── index.html
└── src/
    ├── ReplicatedStorage/
    │   └── TycoonConfig.luau       # Central economy, layout, weapon & dropper definitions
    ├── ServerScriptService/
    │   ├── Main.server.luau        # Game init, leaderstats, plot assignment, PvP drops
    │   ├── PlotBuilder.luau        # Procedural geometry for plots, floors, walls & tools
    │   ├── Tycoon.luau             # OOP Tycoon state, purchase checks, lasers & weapons
    │   └── WorldBuilder.luau       # Volcanic map, plaza, lighting & mountain horizon
    └── StarterPlayerScripts/
        └── HudClient.client.luau   # Local player HUD hint overlay
```

---

## 🚀 Getting Started with Rojo

1. Clone the repository:
   ```bash
   git clone https://github.com/florhm/Rblx-tycn.git
   ```
2. Open **Roblox Studio** with a blank place or your baseplate.
3. Serve the project using [Rojo](https://rojo.space/):
   ```bash
   rojo serve
   ```
4. Connect via the Rojo Studio plugin to sync all scripts into `ReplicatedStorage`, `ServerScriptService`, and `StarterPlayerScripts`.

---

## 🌐 GitHub Pages

Visit the live showcase landing page at:
👉 **[https://florhm.github.io/Rblx-tycn/](https://florhm.github.io/Rblx-tycn/)**

*(To enable GitHub Pages in your repo: Go to **Settings -> Pages**, select Source **Deploy from a branch**, Branch **main**, Folder **/docs**)*
