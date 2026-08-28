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

local function attachSound(part, name, soundId, pitch)
	local s = Instance.new("Sound")
	s.Name = name
	s.SoundId = soundId or "rbxasset://sounds/electronicpingshort.wav"
	s.PlaybackSpeed = pitch or 1
	s.Volume = 0.6
	s.Parent = part
	return s
end

local function attachBillboard(part, text, widthPx, heightPx, offsetY, bgColor)
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(widthPx, heightPx)
	bb.StudsOffset = Vector3.new(0, offsetY, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = 120

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = bgColor or Color3.fromRGB(18, 20, 26)
	frame.BackgroundTransparency = 0.25
	frame.BorderSizePixel = 0
	frame.Parent = bb

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = 0.6
	stroke.Thickness = 2
	stroke.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.5
	label.Text = text
	label.Parent = frame

	bb.Adornee = part
	bb.Parent = part
	return bb
end

local DROPPER_STYLE = {
	Dirt = "Rock", Stone = "Rock", Coal = "Void", Iron = "Metal", Silver = "Metal",
	Gold = "Metal", Diamond = "Crystal", Ruby = "Crystal", Emerald = "Crystal",
	Uranium = "Void", Voidstone = "Void", Neutronium = "Void", Singularity = "Void",
	Galaxy = "Void", Quasar = "Void",
}

local function buildDropper(id, cfg, accent, parent, base, baseY, posX, posZ, yaw)
	local m = Instance.new("Model")
	m.Name = "Dropper_" .. id
	m:SetAttribute("DropperId", id)

	local h = cfg.Height
	local style = DROPPER_STYLE[id] or "Rock"
	local itemCol = cfg.ItemColor
	local root = base * CFrame.new(posX, baseY + h / 2, posZ) * CFrame.Angles(0, yaw or 0, 0)

	local function part(props)
		return makePart(props, m)
	end

	if style == "Crystal" then
		part({ Name = "Body", Shape = Enum.PartType.Cylinder, Size = Vector3.new(2.6, h, 2.6), CFrame = root * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(38, 44, 56), Material = Enum.Material.Slate })
		part({ Name = "Crystal", Shape = Enum.PartType.Ball, Size = Vector3.new(2.4, h * 0.7, 2.4), CFrame = root * CFrame.new(0, h * 0.12, 0), Color = itemCol, Material = Enum.Material.Neon })
		for a = 0, 3 do
			part({ Name = "Facet", Size = Vector3.new(0.35, h * 0.6, 1.8), CFrame = root * CFrame.Angles(0, math.rad(a * 90), 0) * CFrame.new(0, h * 0.12, 1.0), Color = itemCol, Material = Enum.Material.Neon, Transparency = 0.35 })
		end
	elseif style == "Metal" then
		part({ Name = "Body", Size = Vector3.new(3.0, h, 3.0), CFrame = root, Color = Color3.fromRGB(66, 70, 80), Material = Enum.Material.Metal })
		part({ Name = "Top", Size = Vector3.new(2.8, 0.9, 2.8), CFrame = root * CFrame.new(0, h / 2, 0), Color = itemCol, Material = Enum.Material.Neon })
		for a = 0, 3 do
			part({ Name = "Pipe", Shape = Enum.PartType.Cylinder, Size = Vector3.new(h * 0.5, 0.5, 0.5), CFrame = root * CFrame.Angles(0, math.rad(a * 90), math.rad(90)) * CFrame.new(0, 0, 1.8), Color = itemCol, Material = Enum.Material.Neon })
		end
	elseif style == "Void" then
		part({ Name = "Body", Size = Vector3.new(2.8, h, 2.8), CFrame = root, Color = Color3.fromRGB(26, 20, 38), Material = Enum.Material.Metal })
		part({ Name = "Core", Shape = Enum.PartType.Ball, Size = Vector3.new(1.9, 1.9, 1.9), CFrame = root * CFrame.new(0, h * 0.18, 0), Color = itemCol, Material = Enum.Material.Neon })
		for a = 0, 3 do
			part({ Name = "Vein", Size = Vector3.new(0.3, h * 0.7, 0.3), CFrame = root * CFrame.Angles(0, math.rad(a * 90 + 45), 0) * CFrame.new(0, 0, 1.4), Color = itemCol, Material = Enum.Material.Neon })
		end
	else
		part({ Name = "Body", Shape = Enum.PartType.Ball, Size = Vector3.new(3.2, h, 3.2), CFrame = root, Color = Color3.fromRGB(90, 92, 98), Material = Enum.Material.Slate })
		part({ Name = "Crack", Size = Vector3.new(0.6, h * 0.5, 0.6), CFrame = root * CFrame.new(0, h * 0.2, 1.4), Color = itemCol, Material = Enum.Material.Neon })
	end

	part({ Name = "Arm", Size = Vector3.new(math.abs(posX) + 1, 1.0, 1.2), CFrame = base * CFrame.new(posX / 2, baseY + h - 0.5, posZ), Color = Color3.fromRGB(80, 84, 94), Material = Enum.Material.Metal })

	local nozzle = part({ Name = "Nozzle", Size = Vector3.new(1.8, 1.2, 1.8), CFrame = base * CFrame.new(0, baseY + h - 1.1, posZ), Color = itemCol, Material = Enum.Material.Neon })
	local nozzleLight = Instance.new("PointLight")
	nozzleLight.Color = itemCol
	nozzleLight.Range = 10
	nozzleLight.Brightness = 1.5
	nozzleLight.Parent = nozzle

	part({ Name = "SpawnPoint", Size = Vector3.new(0.4, 0.4, 0.4), CFrame = base * CFrame.new(0, baseY + h - 1.8, posZ), Transparency = 1, CanCollide = false })

	m.Parent = parent
	return m
end

local function buildWalls(accent, base, parent)
	local h = L.WallHeight
	local t = 1.5
	local wallColor = Color3.fromRGB(48, 50, 58)

	local function wallModel(name)
		local wm = Instance.new("Model")
		wm.Name = "Wall_" .. name
		wm.Parent = parent
		return wm
	end

	local back = wallModel("Back")
	makePart({ Name = "Wall", Size = Vector3.new(FX, h, t), CFrame = base * CFrame.new(0, h / 2, FZ / 2), Color = wallColor, Material = Enum.Material.Slate }, back)
	makePart({ Name = "Trim", Size = Vector3.new(FX, 0.5, t + 0.2), CFrame = base * CFrame.new(0, h + 0.2, FZ / 2), Color = accent, Material = Enum.Material.Metal }, back)
	for _, sx in ipairs({ -FX / 2, FX / 2 }) do
		local tower = makePart({ Name = "Tower", Size = Vector3.new(2.5, h + 4, 2.5), CFrame = base * CFrame.new(sx, (h + 4) / 2, FZ / 2), Color = Color3.fromRGB(40, 42, 50), Material = Enum.Material.Slate }, back)
		makePart({ Name = "Crystal", Shape = Enum.PartType.Ball, Size = Vector3.new(2.2, 2.2, 2.2), CFrame = base * CFrame.new(sx, h + 4, FZ / 2), Color = accent, Material = Enum.Material.Neon }, back)
		local gl = Instance.new("PointLight")
		gl.Color = accent
		gl.Range = 14
		gl.Brightness = 1.5
		gl.Parent = tower
	end

	local left = wallModel("Left")
	makePart({ Name = "Wall", Size = Vector3.new(t, h, FZ), CFrame = base * CFrame.new(-FX / 2, h / 2, 0), Color = wallColor, Material = Enum.Material.Slate }, left)
	makePart({ Name = "Trim", Size = Vector3.new(t + 0.2, 0.5, FZ), CFrame = base * CFrame.new(-FX / 2, h + 0.2, 0), Color = accent, Material = Enum.Material.Metal }, left)

	local right = wallModel("Right")
	makePart({ Name = "Wall", Size = Vector3.new(t, h, FZ), CFrame = base * CFrame.new(FX / 2, h / 2, 0), Color = wallColor, Material = Enum.Material.Slate }, right)
	makePart({ Name = "Trim", Size = Vector3.new(t + 0.2, 0.5, FZ), CFrame = base * CFrame.new(FX / 2, h + 0.2, 0), Color = accent, Material = Enum.Material.Metal }, right)

	local front = wallModel("Front")
	local segW = (FX - 10) / 2
	makePart({ Name = "SegL", Size = Vector3.new(segW, h, t), CFrame = base * CFrame.new(-(5 + segW / 2), h / 2, -FZ / 2), Color = wallColor, Material = Enum.Material.Slate }, front)
	makePart({ Name = "SegR", Size = Vector3.new(segW, h, t), CFrame = base * CFrame.new(5 + segW / 2, h / 2, -FZ / 2), Color = wallColor, Material = Enum.Material.Slate }, front)
	makePart({ Name = "PostL", Size = Vector3.new(2, h, t + 0.5), CFrame = base * CFrame.new(-5, h / 2, -FZ / 2), Color = Color3.fromRGB(40, 42, 50), Material = Enum.Material.Slate }, front)
	makePart({ Name = "PostR", Size = Vector3.new(2, h, t + 0.5), CFrame = base * CFrame.new(5, h / 2, -FZ / 2), Color = Color3.fromRGB(40, 42, 50), Material = Enum.Material.Slate }, front)
	makePart({ Name = "Lintel", Size = Vector3.new(12, 3, t), CFrame = base * CFrame.new(0, h - 1.5, -FZ / 2), Color = wallColor, Material = Enum.Material.Slate }, front)
	makePart({ Name = "Trim", Size = Vector3.new(FX, 0.5, t + 0.2), CFrame = base * CFrame.new(0, h + 0.2, -FZ / 2), Color = accent, Material = Enum.Material.Metal }, front)
end

local function buildDecor(model, accent, base)
	local d = Instance.new("Model")
	d.Name = "ThemeDecor"
	d:SetAttribute("Decor", true)
	d.Parent = model

	local cols = { accent, Color3.fromRGB(120, 200, 255), Color3.fromRGB(200, 140, 255), Color3.fromRGB(255, 200, 90) }
	local corners = { { -FX / 2 + 7, -FZ / 2 + 7 }, { FX / 2 - 7, -FZ / 2 + 7 }, { -FX / 2 + 7, FZ / 2 - 7 }, { FX / 2 - 7, FZ / 2 - 7 } }
	for i, c in ipairs(corners) do
		local col = cols[(i % #cols) + 1]
		for k = 1, 3 do
			local ang = (k / 3) * math.pi * 2 + i
			local r = 2.6
			local x = c[1] + math.cos(ang) * r
			local z = c[2] + math.sin(ang) * r
			makePart({ Name = "Crystal", Shape = Enum.PartType.Ball, Size = Vector3.new(1.3, 3 + k, 1.3), CFrame = base * CFrame.new(x, 1.5 + (3 + k) / 2, z), Color = col, Material = Enum.Material.Neon, CanCollide = false }, d)
		end
	end

	makePart({ Name = "Obelisk", Size = Vector3.new(2, 6, 2), CFrame = base * CFrame.new(0, 3, 27), Color = Color3.fromRGB(40, 42, 50), Material = Enum.Material.Slate }, d)
	local orb = makePart({ Name = "Core", Shape = Enum.PartType.Ball, Size = Vector3.new(3, 3, 3), CFrame = base * CFrame.new(0, 7, 27), Color = accent, Material = Enum.Material.Neon, CanCollide = false }, d)
	local gl = Instance.new("PointLight")
	gl.Color = accent
	gl.Range = 22
	gl.Brightness = 2
	gl.Parent = orb
	makeEmitter(orb, ColorSequence.new(accent), 0.8, 12, 0.6, "DecorBurst")
	return d
end

local function buildLaser(base, parent)
	local m = Instance.new("Model")
	m.Name = "LaserGroup"

	local beamCenter = makePart({
		Name = "Beam",
		Size = Vector3.new(8, 0.4, 0.4),
		CFrame = base * CFrame.new(0, 2.5, -FZ / 2),
		Color = Color3.fromRGB(255, 40, 40),
		Material = Enum.Material.Neon,
		CanCollide = false,
	}, m)

	local beamTop = makePart({
		Name = "BeamTop",
		Size = Vector3.new(8, 0.4, 0.4),
		CFrame = base * CFrame.new(0, 5.0, -FZ / 2),
		Color = Color3.fromRGB(255, 40, 40),
		Material = Enum.Material.Neon,
		CanCollide = false,
	}, m)

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 60, 60)
	light.Range = 14
	light.Brightness = 2.5
	light.Parent = beamCenter

	makeEmitter(beamCenter, ColorSequence.new(Color3.fromRGB(255, 60, 60)), 0.6, 12, 0.5, "KillBurst")
	attachSound(beamCenter, "KillSound", "rbxasset://sounds/electronicpingshort.wav", 0.5)

	makePart({ Name = "EmitL", Size = Vector3.new(0.8, 6.0, 0.8), CFrame = base * CFrame.new(-4.4, 3.5, -FZ / 2), Color = Color3.fromRGB(255, 40, 40), Material = Enum.Material.Neon }, m)
	makePart({ Name = "EmitR", Size = Vector3.new(0.8, 6.0, 0.8), CFrame = base * CFrame.new(4.4, 3.5, -FZ / 2), Color = Color3.fromRGB(255, 40, 40), Material = Enum.Material.Neon }, m)
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
	attachBillboard(collector2, "SELL ORE", 90, 28, 1.8, Color3.fromRGB(20, 40, 25))
	makeEmitter(collector2, ColorSequence.new(Color3.fromRGB(120, 255, 150)), 0.6, 10, 0.5, "SellBurst")
	attachSound(collector2, "SellSound", "rbxasset://sounds/electronicpingshort.wav", 1.1)

	m.Parent = parent
	return m
end

local function buildSign(name, text, cf, parent)
	local m = Instance.new("Model")
	m.Name = name
	local board = makePart({
		Name = "SignBoard",
		Size = Vector3.new(28, 6.5, 1.5),
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

local function buildStairsAndFloor3(accent, base, beltDir, parent)
	local m = Instance.new("Model")
	m.Name = "StairGroup2"

	for i = 1, 10 do
		local stepH = 1.2 * i
		makePart({
			Name = "Step" .. i,
			Size = Vector3.new(5.5, stepH, 2),
			CFrame = base * CFrame.new(41.5, stepH / 2, -25 + (i - 1) * 2),
			Color = Color3.fromRGB(70, 74, 84),
			Material = Enum.Material.Slate,
		}, m)
	end

	local slabColor = Color3.fromRGB(48, 50, 58)
	makePart({ Name = "Slab1", Size = Vector3.new(FX, 2, 9), CFrame = base * CFrame.new(0, 25, -30.5), Color = slabColor, Material = Enum.Material.Slate }, m)
	makePart({ Name = "Slab2", Size = Vector3.new(FX - 7, 2, 20), CFrame = base * CFrame.new(3.5, 25, -16), Color = slabColor, Material = Enum.Material.Slate }, m)
	makePart({ Name = "Slab3", Size = Vector3.new(FX, 2, 41), CFrame = base * CFrame.new(0, 25, 14.5), Color = slabColor, Material = Enum.Material.Slate }, m)

	local railColor = Color3.fromRGB(220, 225, 235)
	makePart({ Name = "HoleRail1", Size = Vector3.new(0.4, 3, 20), CFrame = base * CFrame.new(38, 27.5, -16), Color = railColor, Material = Enum.Material.Glass, Transparency = 0.5 }, m)
	makePart({ Name = "HoleRail2", Size = Vector3.new(7, 3, 0.4), CFrame = base * CFrame.new(41.5, 27.5, -26), Color = railColor, Material = Enum.Material.Glass, Transparency = 0.5 }, m)
	makePart({ Name = "HoleRail3", Size = Vector3.new(7, 3, 0.4), CFrame = base * CFrame.new(41.5, 27.5, -6), Color = railColor, Material = Enum.Material.Glass, Transparency = 0.5 }, m)

	local belt3 = makePart({ Name = "Belt3", Size = Vector3.new(4, 0.6, 30), CFrame = base * CFrame.new(0, 26.3, -2), Color = Config.Belt.Colors[1], Material = Enum.Material.DiamondPlate }, m)
	belt3.Velocity = beltDir * Config.Belt.SpeedTiers[1]

	for _, sx in ipairs({ -2.25, 2.25 }) do
		makePart({ Name = "Rail3", Size = Vector3.new(0.5, 1.4, 30), CFrame = base * CFrame.new(sx, 26.7, -2), Color = railColor, Material = Enum.Material.Glass, Transparency = 0.6 }, m)
	end

	local collector3 = makePart({ Name = "Collector3", Size = Vector3.new(6, 1, 4), CFrame = base * CFrame.new(0, 25.9, 15), Color = Color3.fromRGB(90, 230, 110), Material = Enum.Material.Neon }, m)
	attachBillboard(collector3, "SELL ORE", 90, 28, 1.8, Color3.fromRGB(20, 40, 25))
	makeEmitter(collector3, ColorSequence.new(Color3.fromRGB(120, 255, 150)), 0.6, 10, 0.5, "SellBurst")
	attachSound(collector3, "SellSound", "rbxasset://sounds/electronicpingshort.wav", 1.1)

	m.Parent = parent
	return m
end

local function buildMonument(model)
	local m = Instance.new("Model")
	m.Name = "Monument"
	local base = model.Floor.CFrame * CFrame.new(0, 1, 0)
	local mb = base * CFrame.new(0, 0, -Config.Layout.FloorSize.Z / 2 - 9)
	makePart({ Name = "Pedestal", Size = Vector3.new(7, 2, 7), CFrame = mb * CFrame.new(0, 1, 0), Color = Color3.fromRGB(40, 42, 50), Material = Enum.Material.Metal }, m)
	makePart({ Name = "Spire", Size = Vector3.new(2, 10, 2), CFrame = mb * CFrame.new(0, 6, 0), Color = Color3.fromRGB(180, 90, 255), Material = Enum.Material.Neon }, m)
	local orb = makePart({ Name = "Orb", Shape = Enum.PartType.Ball, Size = Vector3.new(4, 4, 4), CFrame = mb * CFrame.new(0, 12, 0), Color = Color3.fromRGB(255, 220, 120), Material = Enum.Material.Neon }, m)
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 210, 90)
	light.Range = 30
	light.Brightness = 3
	light.Parent = orb
	makeEmitter(orb, ColorSequence.new(Color3.fromRGB(255, 220, 120)), 1.2, 20, 0.6, "MonBurst")
	m.Parent = model
	PlotBuilder.SetVisible(m, false)
	return m
end

function PlotBuilder.ScaleMonument(model, level)
	local m = model:FindFirstChild("Monument")
	if not m then
		return
	end
	PlotBuilder.SetVisible(m, true)
	local base = model.Floor.CFrame * CFrame.new(0, 1, 0)
	local mb = base * CFrame.new(0, 0, -Config.Layout.FloorSize.Z / 2 - 9)
	local scale = 1 + 0.6 * (level - 1)
	local spire = m:FindFirstChild("Spire")
	if spire then
		spire.Size = Vector3.new(2 * scale, 10 * scale, 2 * scale)
		spire.CFrame = mb * CFrame.new(0, 1 + 5 * scale, 0)
	end
	local orb = m:FindFirstChild("Orb")
	if orb then
		orb.Size = Vector3.new(4 * scale, 4 * scale, 4 * scale)
		orb.CFrame = mb * CFrame.new(0, 2 + 10 * scale, 0)
	end
end

function PlotBuilder.ApplyDecor(model, id)
	if model:FindFirstChild("Decor_" .. id) then
		return
	end
	local d = Instance.new("Model")
	d.Name = "Decor_" .. id
	d:SetAttribute("Decor", true)
	local base = model.Floor.CFrame * CFrame.new(0, 1, 0)

	if id == "Garden" then
		local flowerCols = { Color3.fromRGB(255, 90, 140), Color3.fromRGB(255, 200, 60), Color3.fromRGB(120, 180, 255), Color3.fromRGB(200, 120, 255) }
		for i = 1, 10 do
			local ang = (i / 10) * math.pi * 2
			local r = 40
			local x = math.cos(ang) * r
			local z = math.sin(ang) * (Config.Layout.FloorSize.Z / 2 - 4)
			local stem = makePart({ Name = "Stem", Shape = Enum.PartType.Cylinder, Size = Vector3.new(3, 0.4, 0.4), CFrame = base * CFrame.new(x, 1.5, z) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(60, 140, 60), Material = Enum.Material.Grass }, d)
			local col = flowerCols[(i % #flowerCols) + 1]
			makePart({ Name = "Bloom", Shape = Enum.PartType.Ball, Size = Vector3.new(2, 2, 2), CFrame = base * CFrame.new(x, 3.2, z), Color = col, Material = Enum.Material.Neon }, d)
		end
	elseif id == "Statue" then
		local pos = base * CFrame.new(0, 0, Config.Layout.FloorSize.Z / 2 - 10)
		makePart({ Name = "Pedestal", Size = Vector3.new(5, 3, 5), CFrame = pos * CFrame.new(0, 1.5, 0), Color = Color3.fromRGB(60, 60, 70), Material = Enum.Material.Metal }, d)
		makePart({ Name = "Figure", Size = Vector3.new(3, 8, 3), CFrame = pos * CFrame.new(0, 7, 0), Color = Color3.fromRGB(255, 200, 60), Material = Enum.Material.Metal }, d)
		local orb = makePart({ Name = "Crown", Shape = Enum.PartType.Ball, Size = Vector3.new(2.4, 2.4, 2.4), CFrame = pos * CFrame.new(0, 12, 0), Color = Color3.fromRGB(255, 230, 120), Material = Enum.Material.Neon }, d)
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(255, 220, 100)
		light.Range = 22
		light.Brightness = 2
		light.Parent = orb
	end

	d.Parent = model
end

local function buildButtons(folder, defs, cols, rows, yBase, accent, base)
	for _, def in ipairs(defs) do
		local col = (def.Slot - 1) % #cols
		local row = math.floor((def.Slot - 1) / #cols)

		local btnPos = base * CFrame.new(cols[col + 1], yBase, rows[row + 1])
		local btn = makePart({
			Name = "Button_" .. def.Id,
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(0.4, 5, 5),
			CFrame = btnPos * CFrame.Angles(0, 0, math.rad(90)),
			Color = accent,
			Material = Enum.Material.Neon,
		}, folder)

		btn:SetAttribute("Id", def.Id)
		btn:SetAttribute("Cost", def.Cost)
		btn:SetAttribute("Kind", def.Kind)
		btn:SetAttribute("Target", def.Target or "")
		btn:SetAttribute("Requires", def.Requires or "")

		attachBillboard(btn, def.Name .. "\n$" .. comma(def.Cost), 130, 44, 2.4, Color3.fromRGB(22, 26, 36))
		makeEmitter(btn, RAINBOW, 0.9, 16, 0.9, "BuyBurst")
		attachSound(btn, "BuySound", "rbxassetid://101396758527961", 1.0)

		local light = Instance.new("PointLight")
		light.Color = accent
		light.Range = 9
		light.Brightness = 1.2
		light.Parent = btn

		local prompt = Instance.new("ProximityPrompt")
		prompt.ObjectText = def.Name
		prompt.ActionText = "Buy ($" .. comma(def.Cost) .. ")"
		prompt.HoldDuration = 0
		prompt.MaxActivationDistance = 14
		prompt.RequiresLineOfSight = false
		prompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
		prompt.ClickablePrompt = true
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
		prompt.Parent = btn
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
		elseif inst:IsA("ProximityPrompt") then
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
		makePart({ Name = "Trim", Size = trim[1], CFrame = base * CFrame.new(trim[2]), Color = accent, Material = Enum.Material.SmoothPlastic }, model)
	end

	makePart({ Name = "Porch", Size = Vector3.new(26, 2, 6), CFrame = base * CFrame.new(0, -1, -FZ / 2 - 3), Color = Color3.fromRGB(45, 47, 53), Material = Enum.Material.Slate }, model)

	local claimPad = makePart({ Name = "ClaimPad", Size = Vector3.new(12, 0.4, 4), CFrame = base * CFrame.new(-6.5, 0.2, -FZ / 2 - 3), Color = accent, Material = Enum.Material.Neon }, model)
	attachBillboard(claimPad, "CLAIM PLOT", 140, 34, 3, Color3.fromRGB(15, 30, 22))
	claimPad:SetAttribute("IsClaimPad", true)
	TweenService:Create(claimPad, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Transparency = 0.35 }):Play()

	local hub = makePart({
		Name = "CashHub",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.5, 6, 6),
		CFrame = base * CFrame.new(6.5, 0.25, -FZ / 2 - 3) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(255, 200, 50),
		Material = Enum.Material.Neon,
	}, model)
	attachBillboard(hub, "DEPOSIT ORE", 120, 44, 3.5, Color3.fromRGB(40, 32, 10))
	makeEmitter(hub, ColorSequence.new(Color3.fromRGB(255, 220, 80)), 0.9, 14, 0.9, "CashBurst")

	local cashSound = Instance.new("Sound")
	cashSound.Name = "CashSound"
	cashSound.SoundId = "rbxassetid://101396758527961"
	cashSound.Volume = 1
	cashSound.Parent = hub

	local hubLight = Instance.new("PointLight")
	hubLight.Color = Color3.fromRGB(255, 210, 80)
	hubLight.Range = 12
	hubLight.Brightness = 1.5
	hubLight.Parent = hub

	makePart({ Name = "Vault", Size = Vector3.new(4, 3.5, 3), CFrame = base * CFrame.new(6.5, 1.75, -FZ / 2 - 4.75), Color = Color3.fromRGB(40, 42, 50), Material = Enum.Material.Metal }, model)

	makePart({ Name = "CashPost", Size = Vector3.new(0.45, 1.3, 0.45), CFrame = base * CFrame.new(6.5, 3.7, -FZ / 2 - 3), Color = Color3.fromRGB(60, 64, 74), Material = Enum.Material.Metal }, model)
	local screen = makePart({
		Name = "CashScreen",
		Size = Vector3.new(3.8, 3.0, 0.25),
		CFrame = base * CFrame.new(6.5, 4.6, -FZ / 2 - 3),
		Color = Color3.fromRGB(12, 16, 22),
		Material = Enum.Material.SmoothPlastic,
	}, model)
	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Back
	sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	sg.PixelsPerStud = 55
	sg.Parent = screen
	local bg = Instance.new("Frame")
	bg.Size = UDim2.fromScale(1, 1)
	bg.BackgroundColor3 = Color3.fromRGB(8, 12, 18)
	bg.BorderSizePixel = 0
	bg.Parent = sg
	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(0.04, 0)
	bgCorner.Parent = bg
	local bgStroke = Instance.new("UIStroke")
	bgStroke.Color = Color3.fromRGB(255, 200, 70)
	bgStroke.Thickness = 0.05
	bgStroke.Parent = bg
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, 0, 0.2, 0)
	header.Position = UDim2.new(0, 0, 0.06, 0)
	header.BackgroundTransparency = 1
	header.Font = Enum.Font.GothamBold
	header.TextScaled = true
	header.TextColor3 = Color3.fromRGB(255, 200, 80)
	header.Text = "CASH VAULT"
	header.Parent = sg
	local amount = Instance.new("TextLabel")
	amount.Name = "CashText"
	amount.Size = UDim2.new(1, 0, 0.5, 0)
	amount.Position = UDim2.new(0, 0, 0.27, 0)
	amount.BackgroundTransparency = 1
	amount.Font = Enum.Font.GothamBlack
	amount.TextScaled = true
	amount.TextColor3 = Color3.fromRGB(120, 255, 165)
	amount.Text = "$0"
	amount.Parent = sg
	local status = Instance.new("TextLabel")
	status.Name = "CashStatus"
	status.Size = UDim2.new(1, 0, 0.2, 0)
	status.Position = UDim2.new(0, 0, 0.78, 0)
	status.BackgroundTransparency = 1
	status.Font = Enum.Font.Gotham
	status.TextScaled = true
	status.TextColor3 = Color3.fromRGB(160, 180, 200)
	status.Text = "AWAITING DEPOSITS"
	status.Parent = sg

	local beltDir = base:VectorToWorldSpace(Vector3.new(0, 0, 1))
	model:SetAttribute("BeltDir", beltDir)

	local belt = makePart({ Name = "Belt", Size = Vector3.new(4, 0.6, L.BeltLength), CFrame = base * CFrame.new(0, 1.3, L.BeltCenterZ), Color = Config.Belt.Colors[1], Material = Enum.Material.DiamondPlate }, model)
	belt.Velocity = beltDir * Config.Belt.SpeedTiers[1]

	for _, sx in ipairs({ -2.25, 2.25 }) do
		makePart({ Name = "Rail", Size = Vector3.new(0.5, 1.4, L.BeltLength), CFrame = base * CFrame.new(sx, 1.7, L.BeltCenterZ), Color = Color3.fromRGB(220, 225, 235), Material = Enum.Material.Glass, Transparency = 0.6 }, model)
		makePart({ Name = "RailTrim", Size = Vector3.new(0.2, 0.3, L.BeltLength), CFrame = base * CFrame.new(sx, 2.4, L.BeltCenterZ), Color = accent, Material = Enum.Material.Neon }, model)
	end

	local collector = makePart({ Name = "Collector", Size = Vector3.new(6, 1, 4), CFrame = base * CFrame.new(0, 0.5, L.BeltCenterZ + L.BeltLength / 2 + 2), Color = Color3.fromRGB(90, 230, 110), Material = Enum.Material.Neon }, model)
	attachBillboard(collector, "SELL ORE", 90, 28, 1.8, Color3.fromRGB(20, 40, 25))
	makeEmitter(collector, ColorSequence.new(Color3.fromRGB(120, 255, 150)), 0.6, 10, 0.5, "SellBurst")
	attachSound(collector, "SellSound", "rbxasset://sounds/electronicpingshort.wav", 1.1)

	local locked = Instance.new("Folder")
	locked.Name = "Locked"
	locked.Parent = model

	buildWalls(accent, base, locked)
	buildStairsAndFloor2(accent, base, beltDir, locked)
	buildStairsAndFloor3(accent, base, beltDir, locked)
	buildLaser(base, locked)

	local function placeDroppers(tbl, baseY)
		local list = {}
		for id, cfg in pairs(tbl) do
			table.insert(list, { id = id, cfg = cfg })
		end
		table.sort(list, function(a, b) return (a.cfg.DropZ or 0) < (b.cfg.DropZ or 0) end)
		local n = #list
		for i, d in ipairs(list) do
			local sign = (d.cfg.Side == "Left") and -1 or 1
			local tt = (i - 1) / math.max(1, n - 1)
			local x = sign * (4 + 4 * math.sin(tt * math.pi))
			local yaw = math.rad(sign * 28)
			buildDropper(d.id, d.cfg, accent, locked, base, baseY, x, d.cfg.DropZ, yaw)
		end
	end
	placeDroppers(Config.Droppers, 0)
	placeDroppers(Config.Floor2Droppers, 14)
	if Config.Floor3Droppers then
		placeDroppers(Config.Floor3Droppers, 24)
	end

	buildSign("CompleteSign1", "TYCOON COMPLETE!", base * CFrame.new(0, 10, FZ / 2 - 1.75), locked)
	buildSign("CompleteSign2", "EMPIRE COMPLETE!", base * CFrame.new(0, 20, FZ / 2 - 1.75), locked)
	buildSign("CompleteSign3", "GALAXY DOMINATED!", base * CFrame.new(0, 30, FZ / 2 - 1.75), locked)

	local buttons = Instance.new("Folder")
	buttons.Name = "Buttons"
	buttons.Parent = model
	local buttons2 = Instance.new("Folder")
	buttons2.Name = "Buttons2"
	buttons2.Parent = model
	local buttons3 = Instance.new("Folder")
	buttons3.Name = "Buttons3"
	buttons3.Parent = model

	local groundDefs, floor2Defs, floor3Defs = {}, {}, {}
	for _, def in ipairs(Config.Buttons) do
		if def.Floor3 then
			table.insert(floor3Defs, def)
		elseif def.Floor2 then
			table.insert(floor2Defs, def)
		else
			table.insert(groundDefs, def)
		end
	end
	buildButtons(buttons, groundDefs, L.GroundButtonCols, L.GroundButtonRows, 0.35, accent, base)
	buildButtons(buttons2, floor2Defs, L.Floor2ButtonCols, L.Floor2ButtonRows, 14.35, accent, base)
	buildButtons(buttons3, floor3Defs, L.Floor3ButtonCols, L.Floor3ButtonRows, 24.35, accent, base)

	buildMonument(model)
	buildDecor(model, accent, base)

	return model
end

return PlotBuilder
