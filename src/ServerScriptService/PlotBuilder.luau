local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Config = require(ReplicatedStorage:WaitForChild("TycoonConfig"))

local PlotBuilder = {}

local ACCENTS = {
	Color3.fromRGB(0, 255, 140),
	Color3.fromRGB(255, 90, 200),
	Color3.fromRGB(0, 200, 255),
	Color3.fromRGB(255, 150, 0),
	Color3.fromRGB(180, 255, 0),
	Color3.fromRGB(170, 90, 255),
}

local RAINBOW = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)),
	ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 220, 0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 255, 130)),
	ColorSequenceKeypoint.new(0.75, Color3.fromRGB(80, 160, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255)),
})

local L = Config.Layout
local FX = L.FloorSize.X
local FZ = L.FloorSize.Z

local function makePart(props, parent)
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props) do
		p[k] = v
	end
	p:SetAttribute("OrigT", p.Transparency)
	p:SetAttribute("OrigCC", p.CanCollide)
	if parent then
		p.Parent = parent
	end
	return p
end

local function comma(n)
	local s = tostring(n)
	while true do
		local c
		s, c = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		if c == 0 then
			break
		end
	end
	return s
end

local function makeEmitter(parent, colorSeq, size, speed, lifetime, name)
	local pe = Instance.new("ParticleEmitter")
	pe.Name = name or "Burst"
	pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	pe.Color = colorSeq
	pe.LightEmission = 1
	pe.Size = NumberSequence.new(size)
	pe.Lifetime = NumberRange.new(lifetime * 0.6, lifetime)
	pe.Speed = NumberRange.new(speed * 0.5, speed)
	pe.SpreadAngle = Vector2.new(180, 180)
	pe.Enabled = false
	pe.Parent = parent
	return pe
end

local function attachSound(part, name, pitch)
	local s = Instance.new("Sound")
	s.Name = name
	s.SoundId = "rbxasset://sounds/electronicpingshort.wav"
	s.PlaybackSpeed = pitch or 1
	s.Volume = 0.6
	s.Parent = part
	return s
end

local function attachBillboard(part, text, widthPx, heightPx, offsetY)
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(widthPx, heightPx)
	bb.StudsOffset = Vector3.new(0, offsetY, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = 120
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.4
	label.Text = text
	label.Parent = bb
	bb.Adornee = part
	bb.Parent = part
	return bb
end

local function buildDropper(id, cfg, accent, parent, base, baseY)
	local m = Instance.new("Model")
	m.Name = "Dropper_" .. id
	m:SetAttribute("DropperId", id)

	local sideX = (cfg.Side == "Left") and -5.5 or 5.5
	local h = cfg.Height
	local machine = cfg.Machine
	local bodyW = machine and 3.5 or 2

	makePart({
		Name = "Column",
		Size = Vector3.new(bodyW, h, bodyW),
		CFrame = base * CFrame.new(sideX, baseY + h / 2, cfg.DropZ),
		Color = machine and Color3.fromRGB(72, 62, 96) or Color3.fromRGB(105, 110, 118),
		Material = Enum.Material.Metal,
	}, m)

	if machine then
		makePart({
			Name = "Tank",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(2.5, 2, 2),
			CFrame = base * CFrame.new(sideX + (cfg.Side == "Left" and 2.2 or -2.2), baseY + h * 0.35, cfg.DropZ) * CFrame.Angles(0, 0, math.rad(90)),
			Color = Color3.fromRGB(130, 110, 180),
			Material = Enum.Material.Metal,
		}, m)
	end

	makePart({
		Name = "Arm",
		Size = Vector3.new(math.abs(sideX) + 1, 1, 1.5),
		CFrame = base * CFrame.new(sideX / 2, baseY + h - 0.5, cfg.DropZ),
		Color = machine and Color3.fromRGB(95, 85, 125) or Color3.fromRGB(130, 135, 145),
		Material = Enum.Material.Metal,
	}, m)

	makePart({
		Name = "Nozzle",
		Size = Vector3.new(1.6, 1, 1.6),
		CFrame = base * CFrame.new(0, baseY + h - 1, cfg.DropZ),
		Color = accent,
		Material = Enum.Material.Neon,
	}, m)

	makePart({
		Name = "SpawnPoint",
		Size = Vector3.new(0.4, 0.4, 0.4),
		CFrame = base * CFrame.new(0, baseY + h - 1.8, cfg.DropZ),
		Transparency = 1,
		CanCollide = false,
	}, m)

	m.Parent = parent
	return m
end

local function buildWalls(accent, base, parent)
	local h = L.WallHeight
	local t = 1.5
	local wallColor = Color3.fromRGB(55, 58, 66)

	local function wallModel(name)
		local wm = Instance.new("Model")
		wm.Name = "Wall_" .. name
		wm.Parent = parent
		return wm
	end

	local back = wallModel("Back")
	makePart({ Name = "Wall", Size = Vector3.new(FX, h, t), CFrame = base * CFrame.new(0, h / 2, FZ / 2), Color = wallColor, Material = Enum.Material.Metal }, back)
	makePart({ Name = "Trim", Size = Vector3.new(FX, 0.4, t + 0.2), CFrame = base * CFrame.new(0, h + 0.2, FZ / 2), Color = accent, Material = Enum.Material.Neon }, back)

	local left = wallModel("Left")
	makePart({ Name = "Wall", Size = Vector3.new(t, h, FZ), CFrame = base * CFrame.new(-FX / 2, h / 2, 0), Color = wallColor, Material = Enum.Material.Metal }, left)
	makePart({ Name = "Trim", Size = Vector3.new(t + 0.2, 0.4, FZ), CFrame = base * CFrame.new(-FX / 2, h + 0.2, 0), Color = accent, Material = Enum.Material.Neon }, left)

	local right = wallModel("Right")
	makePart({ Name = "Wall", Size = Vector3.new(t, h, FZ), CFrame = base * CFrame.new(FX / 2, h / 2, 0), Color = wallColor, Material = Enum.Material.Metal }, right)
	makePart({ Name = "Trim", Size = Vector3.new(t + 0.2, 0.4, FZ), CFrame = base * CFrame.new(FX / 2, h + 0.2, 0), Color = accent, Material = Enum.Material.Neon }, right)

	local front = wallModel("Front")
	local segW = (FX - 10) / 2
	makePart({ Name = "SegL", Size = Vector3.new(segW, h, t), CFrame = base * CFrame.new(-(5 + segW / 2), h / 2, -FZ / 2), Color = wallColor, Material = Enum.Material.Metal }, front)
	makePart({ Name = "SegR", Size = Vector3.new(segW, h, t), CFrame = base * CFrame.new(5 + segW / 2, h / 2, -FZ / 2), Color = wallColor, Material = Enum.Material.Metal }, front)
	makePart({ Name = "PostL", Size = Vector3.new(2, h, t + 0.5), CFrame = base * CFrame.new(-5, h / 2, -FZ / 2), Color = accent, Material = Enum.Material.Neon }, front)
	makePart({ Name = "PostR", Size = Vector3.new(2, h, t + 0.5), CFrame = base * CFrame.new(5, h / 2, -FZ / 2), Color = accent, Material = Enum.Material.Neon }, front)
	makePart({ Name = "Lintel", Size = Vector3.new(12, 3, t), CFrame = base * CFrame.new(0, h - 1.5, -FZ / 2), Color = wallColor, Material = Enum.Material.Metal }, front)
	makePart({ Name = "Trim", Size = Vector3.new(FX, 0.4, t + 0.2), CFrame = base * CFrame.new(0, h + 0.2, -FZ / 2), Color = accent, Material = Enum.Material.Neon }, front)
end

local function buildLaser(base, parent)
	local m = Instance.new("Model")
	m.Name = "LaserGroup"
	local beam = makePart({
		Name = "Beam",
		Size = Vector3.new(8, 0.4, 0.4),
		CFrame = base * CFrame.new(0, 2.5, -FZ / 2),
		Color = Color3.fromRGB(255, 40, 40),
		Material = Enum.Material.Neon,
		CanCollide = false,
	}, m)
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 60, 60)
	light.Range = 12
	light.Brightness = 2
	light.Parent = beam
	makeEmitter(beam, ColorSequence.new(Color3.fromRGB(255, 60, 60)), 0.6, 10, 0.5, "KillBurst")
	attachSound(beam, "KillSound", 0.5)
	makePart({ Name = "EmitL", Size = Vector3.new(0.8, 1.2, 0.8), CFrame = base * CFrame.new(-4.4, 2.5, -FZ / 2), Color = Color3.fromRGB(255, 40, 40), Material = Enum.Material.Neon }, m)
	makePart({ Name = "EmitR", Size = Vector3.new(0.8, 1.2, 0.8), CFrame = base * CFrame.new(4.4, 2.5, -FZ / 2), Color = Color3.fromRGB(255, 40, 40), Material = Enum.Material.Neon }, m)
	m.Parent = parent
end

local function buildStairsAndFloor2(accent, base, beltDir, parent)
	local m = Instance.new("Model")
	m.Name = "StairGroup"

	for i = 1, 10 do
		local stepH = 1.4 * i
		makePart({
			Name = "Step" .. i,
			Size = Vector3.new(5.5, stepH, 2),
			CFrame = base * CFrame.new(-41.5, stepH / 2, -25 + (i - 1) * 2),
			Color = Color3.fromRGB(70, 74, 84),
			Material = Enum.Material.Slate,
		}, m)
	end

	local slabColor = Color3.fromRGB(48, 50, 58)
	makePart({ Name = "Slab1", Size = Vector3.new(FX, 2, 9), CFrame = base * CFrame.new(0, 13, -30.5), Color = slabColor, Material = Enum.Material.Slate }, m)
	makePart({ Name = "Slab2", Size = Vector3.new(FX - 7, 2, 20), CFrame = base * CFrame.new(3.5, 13, -16), Color = slabColor, Material = Enum.Material.Slate }, m)
	makePart({ Name = "Slab3", Size = Vector3.new(FX, 2, 41), CFrame = base * CFrame.new(0, 13, 14.5), Color = slabColor, Material = Enum.Material.Slate }, m)

	local railColor = Color3.fromRGB(220, 225, 235)
	makePart({ Name = "HoleRail1", Size = Vector3.new(0.4, 3, 20), CFrame = base * CFrame.new(-38, 15.5, -16), Color = railColor, Material = Enum.Material.Glass, Transparency = 0.5 }, m)
	makePart({ Name = "HoleRail2", Size = Vector3.new(7, 3, 0.4), CFrame = base * CFrame.new(-41.5, 15.5, -26), Color = railColor, Material = Enum.Material.Glass, Transparency = 0.5 }, m)
	makePart({ Name = "HoleRail3", Size = Vector3.new(7, 3, 0.4), CFrame = base * CFrame.new(-41.5, 15.5, -6), Color = railColor, Material = Enum.Material.Glass, Transparency = 0.5 }, m)

	local belt2 = makePart({ Name = "Belt2", Size = Vector3.new(4, 0.6, 30), CFrame = base * CFrame.new(0, 14.3, -2), Color = Config.Belt.Colors[1], Material = Enum.Material.DiamondPlate }, m)
	belt2.Velocity = beltDir * Config.Belt.SpeedTiers[1]

	for _, sx in ipairs({ -2.25, 2.25 }) do
		makePart({ Name = "Rail2", Size = Vector3.new(0.5, 1.4, 30), CFrame = base * CFrame.new(sx, 14.7, -2), Color = railColor, Material = Enum.Material.Glass, Transparency = 0.6 }, m)
	end

	local collector2 = makePart({ Name = "Collector2", Size = Vector3.new(6, 1, 4), CFrame = base * CFrame.new(0, 13.9, 15), Color = Color3.fromRGB(90, 230, 110), Material = Enum.Material.Neon }, m)
	attachBillboard(collector2, "SELL ORE", 120, 40, 2)
	makeEmitter(collector2, ColorSequence.new(Color3.fromRGB(120, 255, 150)), 0.6, 8, 0.5, "SellBurst")
	attachSound(collector2, "SellSound", 1.1)

	m.Parent = parent
	return m
end

local function buildSign(name, text, cf, parent)
	local m = Instance.new("Model")
	m.Name = name
	local board = makePart({
		Name = "SignBoard",
		Size = Vector3.new(26, 6, 1.5),
		CFrame = cf,
		Color = Color3.fromRGB(20, 20, 25),
		Material = Enum.Material.SmoothPlastic,
	}, m)
	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Front
	sg.Enabled = false
	sg.Parent = board
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 210, 60)
	label.Text = text
	label.Parent = sg
	m.Parent = parent
	return m
end

local function buildButtons(folder, defs, cols, rows, yBase, accent, base)
	for _, def in ipairs(defs) do
		local col = (def.Slot - 1) % #cols
		local row = math.floor((def.Slot - 1) / #cols)
		local btn = makePart({
			Name = "Button_" .. def.Id,
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(0.4, 5, 5),
			CFrame = base * CFrame.new(cols[col + 1], yBase, rows[row + 1]) * CFrame.Angles(0, 0, math.rad(90)),
			Color = accent,
			Material = Enum.Material.Neon,
		}, folder)
		btn:SetAttribute("Id", def.Id)
		btn:SetAttribute("Cost", def.Cost)
		btn:SetAttribute("Kind", def.Kind)
		btn:SetAttribute("Target", def.Target or "")
		btn:SetAttribute("Requires", def.Requires or "")
		attachBillboard(btn, def.Name .. "\n$" .. comma(def.Cost), 190, 70, 3)
		makeEmitter(btn, RAINBOW, 0.8, 14, 0.9, "BuyBurst")
		attachSound(btn, "BuySound", 1.1)
		local light = Instance.new("PointLight")
		light.Color = accent
		light.Range = 8
		light.Brightness = 1
		light.Parent = btn
	end
end

function PlotBuilder.BuildWeapon(wid)
	local cfg = Config.Weapons[wid]
	local tool = Instance.new("Tool")
	tool.Name = cfg.DisplayName
	tool.RequiresHandle = true
	tool.CanBeDropped = false

	local handle = makePart({ Name = "Handle", Size = Vector3.new(0.5, 1, 0.5), Color = Color3.fromRGB(40, 42, 48), Material = Enum.Material.Metal })
	handle.Anchored = false
	handle.Massless = true
	handle.Parent = tool

	local extras = {}
	if cfg.Type == "Melee" then
		local blade = makePart({ Name = "Blade", Size = Vector3.new(0.25, 3.4, 1), Color = cfg.BladeColor, Material = Enum.Material.Metal })
		blade.CFrame = handle.CFrame * CFrame.new(0, 2.2, 0)
		local edge = makePart({ Name = "Edge", Size = Vector3.new(0.3, 3.4, 0.3), Color = Color3.fromRGB(0, 255, 140), Material = Enum.Material.Neon })
		edge.CFrame = handle.CFrame * CFrame.new(0, 2.2, 0.55)
		extras = { blade, edge }
	else
		local barrelLen = (wid == "RailGun") and 3 or 2.2
		local barrel = makePart({ Name = "Barrel", Size = Vector3.new(0.6, 0.6, barrelLen), Color = Color3.fromRGB(55, 58, 66), Material = Enum.Material.Metal })
		barrel.CFrame = handle.CFrame * CFrame.new(0, 0.5, -(barrelLen / 2 + 0.3))
		local tip = makePart({ Name = "Tip", Size = Vector3.new(0.7, 0.7, 0.3), Color = cfg.BeamColor, Material = Enum.Material.Neon })
		tip.CFrame = handle.CFrame * CFrame.new(0, 0.5, -(barrelLen + 0.45))
		extras = { barrel, tip }
	end

	for _, part in ipairs(extras) do
		part.Anchored = false
		part.Massless = true
		part.Parent = tool
		local w = Instance.new("WeldConstraint")
		w.Part0 = handle
		w.Part1 = part
		w.Parent = handle
	end

	return tool
end

function PlotBuilder.SetVisible(root, visible)
	local function apply(inst)
		if inst:IsA("BasePart") then
			inst.Transparency = visible and inst:GetAttribute("OrigT") or 1
			inst.CanCollide = visible and inst:GetAttribute("OrigCC") or false
		elseif inst:IsA("BillboardGui") or inst:IsA("SurfaceGui") then
			inst.Enabled = visible
		end
	end
	apply(root)
	for _, d in ipairs(root:GetDescendants()) do
		apply(d)
	end
end

function PlotBuilder.Build(index, origin, yaw)
	local model = Instance.new("Model")
	model.Name = "Plot" .. index
	model:SetAttribute("PlotIndex", index)

	local accent = ACCENTS[((index - 1) % #ACCENTS) + 1]
	local base = CFrame.new(origin) * CFrame.Angles(0, math.rad(yaw or 0), 0)

	makePart({ Name = "Floor", Size = L.FloorSize, CFrame = base * CFrame.new(0, -1, 0), Color = Color3.fromRGB(45, 47, 53), Material = Enum.Material.Slate }, model)

	for _, trim in ipairs({
		{ Vector3.new(FX, 0.4, 1), Vector3.new(0, 0.2, FZ / 2 - 0.5) },
		{ Vector3.new(FX, 0.4, 1), Vector3.new(0, 0.2, -FZ / 2 + 0.5) },
		{ Vector3.new(1, 0.4, FZ), Vector3.new(FX / 2 - 0.5, 0.2, 0) },
		{ Vector3.new(1, 0.4, FZ), Vector3.new(-FX / 2 + 0.5, 0.2, 0) },
	}) do
		makePart({ Name = "Trim", Size = trim[1], CFrame = base * CFrame.new(trim[2]), Color = accent, Material = Enum.Material.Neon }, model)
	end

	makePart({ Name = "Porch", Size = Vector3.new(26, 2, 6), CFrame = base * CFrame.new(0, -1, -FZ / 2 - 3), Color = Color3.fromRGB(45, 47, 53), Material = Enum.Material.Slate }, model)

	local claimPad = makePart({ Name = "ClaimPad", Size = Vector3.new(12, 0.4, 4), CFrame = base * CFrame.new(-6.5, 0.2, -FZ / 2 - 3), Color = accent, Material = Enum.Material.Neon }, model)
	attachBillboard(claimPad, "CLAIM PLOT", 220, 50, 4)
	TweenService:Create(claimPad, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Transparency = 0.35 }):Play()

	local hub = makePart({
		Name = "CashHub",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.5, 6, 6),
		CFrame = base * CFrame.new(6.5, 0.25, -FZ / 2 - 3) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(255, 200, 50),
		Material = Enum.Material.Neon,
	}, model)
	attachBillboard(hub, "COLLECT\n$0", 160, 70, 5)
	makeEmitter(hub, ColorSequence.new(Color3.fromRGB(255, 220, 80)), 0.8, 12, 0.9, "CashBurst")
	local cashSound = Instance.new("Sound")
	cashSound.Name = "CashSound"
	cashSound.SoundId = "rbxassetid://101396758527961"
	cashSound.Volume = 1
	cashSound.Parent = hub
	local hubLight = Instance.new("PointLight")
	hubLight.Color = Color3.fromRGB(255, 210, 80)
	hubLight.Range = 10
	hubLight.Brightness = 1.2
	hubLight.Parent = hub
	makePart({ Name = "Vault", Size = Vector3.new(4, 3.5, 3), CFrame = base * CFrame.new(6.5, 1.75, -FZ / 2 - 4.75), Color = Color3.fromRGB(40, 42, 50), Material = Enum.Material.Metal }, model)

	local beltDir = base:VectorToWorldSpace(Vector3.new(0, 0, 1))
	model:SetAttribute("BeltDir", beltDir)

	local belt = makePart({ Name = "Belt", Size = Vector3.new(4, 0.6, L.BeltLength), CFrame = base * CFrame.new(0, 1.3, L.BeltCenterZ), Color = Config.Belt.Colors[1], Material = Enum.Material.DiamondPlate }, model)
	belt.Velocity = beltDir * Config.Belt.SpeedTiers[1]

	for _, sx in ipairs({ -2.25, 2.25 }) do
		makePart({ Name = "Rail", Size = Vector3.new(0.5, 1.4, L.BeltLength), CFrame = base * CFrame.new(sx, 1.7, L.BeltCenterZ), Color = Color3.fromRGB(220, 225, 235), Material = Enum.Material.Glass, Transparency = 0.6 }, model)
	end

	local collector = makePart({ Name = "Collector", Size = Vector3.new(6, 1, 4), CFrame = base * CFrame.new(0, 0.5, L.BeltCenterZ + L.BeltLength / 2 + 2), Color = Color3.fromRGB(90, 230, 110), Material = Enum.Material.Neon }, model)
	attachBillboard(collector, "SELL ORE", 120, 40, 2)
	makeEmitter(collector, ColorSequence.new(Color3.fromRGB(120, 255, 150)), 0.6, 8, 0.5, "SellBurst")
	attachSound(collector, "SellSound", 1.1)

	local locked = Instance.new("Folder")
	locked.Name = "Locked"
	locked.Parent = model

	buildWalls(accent, base, locked)
	buildStairsAndFloor2(accent, base, beltDir, locked)
	buildLaser(base, locked)

	for id, cfg in pairs(Config.Droppers) do
		buildDropper(id, cfg, accent, locked, base, 0)
	end
	for id, cfg in pairs(Config.Floor2Droppers) do
		buildDropper(id, cfg, accent, locked, base, 14)
	end

	buildSign("CompleteSign1", "TYCOON COMPLETE!", base * CFrame.new(0, 10, FZ / 2 - 1.75), locked)
	buildSign("CompleteSign2", "EMPIRE COMPLETE!", base * CFrame.new(0, 20, FZ / 2 - 1.75), locked)

	local buttons = Instance.new("Folder")
	buttons.Name = "Buttons"
	buttons.Parent = model
	local buttons2 = Instance.new("Folder")
	buttons2.Name = "Buttons2"
	buttons2.Parent = model

	local groundDefs, floor2Defs = {}, {}
	for _, def in ipairs(Config.Buttons) do
		if def.Floor2 then
			table.insert(floor2Defs, def)
		else
			table.insert(groundDefs, def)
		end
	end
	buildButtons(buttons, groundDefs, L.GroundButtonCols, L.GroundButtonRows, 0.35, accent, base)
	buildButtons(buttons2, floor2Defs, L.Floor2ButtonCols, L.Floor2ButtonRows, 14.35, accent, base)

	return model
end

return PlotBuilder
