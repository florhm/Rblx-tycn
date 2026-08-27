# Juice & Dopamine Build Checklist

> Check off in Studio Play Mode. Mirrors plan spec: `src/ReplicatedStorage/TycoonConfig.luau`, `src/ServerScriptService/PlotBuilder.luau`, `src/ServerScriptService/Tycoon.luau`, `src/StarterPlayerScripts/HudClient.client.luau`, `src/ServerScriptService/WorldBuilder.luau`, `src/ServerScriptService/Main.server.luau`.

## 1. Audio & Visual "Juice"

### Floating Text - `Tycoon.luau:115` `_sellPopup` / `HudClient:24`
- [ ] Color-coded: green `+$` sell, gold pending, yellow 1.2x for `>=$500`, red `-$` damage
- [ ] Crit scaling: extra-large `GothamBlack` 1.3x + yellow/red stroke for high-tier ores
- [ ] Tween: `Back Out` pop `0->1.2->1` + rise `+4.5 studs` + fade `0.85s` via `TweenService`
- [ ] Stack offset `math.random(-18,18)/10` to avoid overlap

### Layered SFX - `PlotBuilder.luau:71` `attachSound` / `Tycoon.luau:261` `_juice`
- [ ] Sharp high chime `electronicpingshort.wav` pitch `1.1` for currency/UI
- [ ] Bass thud `0.5` for laser kill `PlotBuilder.luau:255`
- [ ] Cash hub `rbxassetid://101396758527961` Volume 1
- [ ] Pitch-shift per combo `0.95 + combo*0.05` max 1.6 `Tycoon.luau:108`
- [ ] Rejection SFX `0.65` pitch + red `UIStroke` flash 0.3s on insufficient funds `Tycoon.luau:264`

### Camera Polish - `HudClient.client.luau` (RemoteEvent: CameraShake)
- [ ] Screenshake `0.08s` on heavy impact / `RailGun` hit + `_impactBurst` `Tycoon.luau:408`
- [ ] FOV `70->75` tween `0.2s` on sprint/dash
- [ ] Full-screen `Frame` flash white `0.12s` transparency `0->1` on level-up/complete

### Particle Bursts - `PlotBuilder.luau:56` `makeEmitter`
- [ ] Collector `SellBurst` `Emit(clamp combo*2,4,20)` `Tycoon.luau:104`
- [ ] Button `BuyBurst` rainbow 60 `Tycoon.luau:285`
- [ ] CashHub 50 burst + 12 physical coin `Cylinder` shower `Tycoon.luau:145`
- [ ] Laser `KillBurst` 30 `Tycoon.luau:172`

## 2. The First 60-Second Hook

### Instant Gratification - `TycoonConfig.luau:13` / `Tycoon.luau:505` `SetOwner`
- [ ] Dirt dropper active immediately on claim, first ore `Interval 1.8s` -> sell within 10s
- [ ] First level-up / `Stone Dropper $100` reachable <30s `TycoonConfig.luau:76`

### Zero Friction - `Main.server.luau:23` plot assignment
- [ ] No modal tutorial; `HudClient.luau:42` hint `"Claim a plot & step on green buttons..."`
- [ ] All buttons `ProximityPrompt` `MaxActivationDistance 9` `PlotBuilder.luau:360`

### Wayfinding
- [ ] Persistent beam/`Beam` or `BillboardGui` arrow to next affordable button
- [ ] Spawn `WorldBuilder.luau:152` central plaza `MINING EMPIRE` sign + path trims neon

## 3. Dopamine & Reward Pacing

### Big Reveal FX - `PlotBuilder.luau:303` `buildSign`
- [ ] Full-screen `ColorCorrection` tint + `Bloom` pulse on `Complete1/2` `WorldBuilder.luau:253`
- [ ] Ray beams + `Sound` sting for rare `Voidstone` `TycoonConfig.luau:62`

### Micro-Progression - `TycoonConfig.luau:38` droppers `SizeScale 0.9->1.5`
- [ ] Progress bar `320x28` `progressFrame` `HudClient` updates on `Cash.Changed`
- [ ] 10 tiers, intervals `1.8->0.7s` keep bar moving

### Combos & Streaks - `Tycoon.luau:17` `_comboCount`
- [ ] Window `1.5s` resets, `x3!` label `Tycoon.luau:122`, sound pitch scaling

## 4. Social & Flex Mechanics

### Visible Prestige
- [ ] Overhead `BillboardGui` title / aura `ParticleEmitter` for high tiers
- [ ] Oversized tool `PlotBuilder.luau:370` `BuildWeapon` scale for RailGun

### Server Announcements - `Main.server.luau:102` `dropCashPile`
- [ ] `Chat` banner `"PlayerX just unlocked Legendary Status! / Voidstone!"` via `TextChatService`

### Spawn Leaderboards - `WorldBuilder.luau:152` plaza
- [ ] `SurfaceGui` on plaza board: Top Cash / Daily from `leaderstats` `Main.server.luau:127`

## 5. Mobile & Performance Optimization

### Mobile-First UI - `HudClient.luau:11`
- [ ] Hitbox `>=44px` min, `UICorner 12`, `UIStroke` for thumb, test DeviceSimulator
- [ ] Aspect scaling `UDim2.fromOffset(210,52)` -> `Scale` for phones

### Client-Side FX - `Tycoon.luau:408` `_beamVisual`
- [ ] Particles/sounds fired via `RemoteEvent` on client, `Debris:AddItem` 0.08-1.5s
- [ ] No server wait for feedback

---

**Verification in Studio Play:**
- [ ] `LogService` no errors/warnings
- [ ] `workspace.Plots` 6, `workspace.Decor` ~131, `Lighting.Bloom` 1.2
- [ ] Claim -> ore spin -> sell combo -> coin shower -> buy prompt -> FOV/shake -> leaderboard updates
