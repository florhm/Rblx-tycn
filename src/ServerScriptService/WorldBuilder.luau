local Lighting = game:GetService("Lighting")

local WorldBuilder = {}

local rng = Random.new(42)

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("TycoonConfig"))

local function makePart(props, parent)
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props) do
		p[k] = v
	end
	if parent then
		p.Parent = parent
	end
	return p
end

local function makeWedge(props, parent)
	local p = Instance.new("WedgePart")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props) do
		p[k] = v
	end
	if parent then
		p.Parent = parent
	end
	return p
end

local function buildTree(parent, pos)
	local m = Instance.new("Model")
	m.Name = "Tree"
	local tall = rng:NextNumber() < 0.4
	local h = tall and rng:NextNumber(11, 15) or rng:NextNumber(7, 10)
	local trunkH = h * 0.45
	makePart({
		Name = "Trunk",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(trunkH, 1.2, 1.2),
		CFrame = CFrame.new(pos + Vector3.new(0, trunkH / 2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(86, 62, 44),
		Material = Enum.Material.WoodPlanks,
	}, m)
	local green = Color3.fromRGB(rng:NextInteger(50, 90), rng:NextInteger(140, 190), rng:NextInteger(60, 100))
	local crown = h * 0.55
	makePart({
		Name = "Leaves",
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(crown, crown, crown),
		CFrame = CFrame.new(pos + Vector3.new(0, trunkH + crown * 0.35, 0)),
		Color = green,
		Material = Enum.Material.LeafyGrass,
	}, m)
	for i = 1, 2 do
		local d = crown * rng:NextNumber(0.5, 0.7)
		makePart({
			Name = "Leaves",
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(d, d, d),
			CFrame = CFrame.new(pos + Vector3.new(rng:NextNumber(-crown, crown) * 0.4, trunkH + crown * rng:NextNumber(0.2, 0.6), rng:NextNumber(-crown, crown) * 0.4)),
			Color = green,
			Material = Enum.Material.LeafyGrass,
		}, m)
	end
	m.Parent = parent
end

local function buildRock(parent, pos)
	local s = rng:NextNumber(2, 4.5)
	makePart({
		Name = "Rock",
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(s, s * 0.8, s),
		CFrame = CFrame.new(pos + Vector3.new(0, s * 0.22, 0)) * CFrame.Angles(rng:NextNumber(0, 3), rng:NextNumber(0, 3), rng:NextNumber(0, 3)),
		Color = Color3.fromRGB(rng:NextInteger(115, 145), rng:NextInteger(115, 145), rng:NextInteger(118, 148)),
		Material = Enum.Material.Slate,
	}, parent)
end

local function buildBush(parent, pos)
	local s = rng:NextNumber(1.6, 2.8)
	makePart({
		Name = "Bush",
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(s, s * 0.7, s),
		CFrame = CFrame.new(pos + Vector3.new(0, s * 0.25, 0)),
		Color = Color3.fromRGB(rng:NextInteger(60, 95), rng:NextInteger(130, 170), rng:NextInteger(65, 95)),
		Material = Enum.Material.Grass,
	}, parent)
end

local function buildCrystalCluster(parent, pos, color)
	local m = Instance.new("Model")
	m.Name = "CrystalCluster"
	for i = 1, 3 do
		local h = rng:NextNumber(2.5, 4.5)
		local w = rng:NextNumber(0.8, 1.4)
		local crystal = makePart({
			Name = "Crystal",
			Size = Vector3.new(w, h, w),
			CFrame = CFrame.new(pos + Vector3.new(rng:NextNumber(-0.8, 0.8), h / 2, rng:NextNumber(-0.8, 0.8)))
				* CFrame.Angles(math.rad(rng:NextNumber(-15, 15)), math.rad(rng:NextNumber(0, 360)), math.rad(rng:NextNumber(-15, 15))),
			Color = color or Color3.fromRGB(0, 230, 255),
			Material = Enum.Material.Neon,
		}, m)
		local light = Instance.new("PointLight")
		light.Color = color or Color3.fromRGB(0, 230, 255)
		light.Range = 8
		light.Brightness = 1.2
		light.Parent = crystal
	end
	m.Parent = parent
end

local function buildLamp(parent, pos)
	local m = Instance.new("Model")
	m.Name = "Lamp"
	makePart({ Name = "Pole", Size = Vector3.new(0.6, 7, 0.6), CFrame = CFrame.new(pos + Vector3.new(0, 3.5, 0)), Color = Color3.fromRGB(35, 36, 42), Material = Enum.Material.Metal }, m)
	makePart({ Name = "Base", Size = Vector3.new(1.4, 0.4, 1.4), CFrame = CFrame.new(pos + Vector3.new(0, 0.2, 0)), Color = Color3.fromRGB(35, 36, 42), Material = Enum.Material.Metal }, m)
	local bulb = makePart({ Name = "Bulb", Shape = Enum.PartType.Ball, Size = Vector3.new(1.4, 1.4, 1.4), CFrame = CFrame.new(pos + Vector3.new(0, 7.4, 0)), Color = Color3.fromRGB(255, 220, 140), Material = Enum.Material.Neon }, m)
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 215, 150)
	light.Range = 22
	light.Brightness = 1.5
	light.Parent = bulb
	m.Parent = parent
end

local function computeBranches()
	local branches = {}
	for _, layout in ipairs(Config.PlotLayout) do
		local yaw = layout.Yaw or 0
		local base = Vector3.new(layout.X, 0, layout.Z)
		local off = CFrame.new(-6.5, 0, -Config.Layout.FloorSize.Z / 2 - 3)
		local world = base + (CFrame.Angles(0, math.rad(yaw), 0) * off).Position
		local north = world.Z > 0
		table.insert(branches, {
			x = world.X,
			z = world.Z,
			zmin = north and 39 or (-math.abs(world.Z) - 6),
			zmax = north and (math.abs(world.Z) + 6) or -39,
		})
	end
	return branches
end

local Branches = computeBranches()

local function isBlocked(x, z)
	if math.abs(x) < 30 and math.abs(z) < 30 then return true end
	if math.abs(z) > 35 and math.abs(z) < 49 then return true end
	if math.abs(x) < 7 and math.abs(z) < 49 then return true end
	for _, cx in ipairs({ -150, 0, 150 }) do
		if math.abs(x - cx) < 13 and math.abs(z) > 60 then return true end
	end
	for _, b in ipairs(Branches) do
		if math.abs(x - b.x) < 7 and z > b.zmin and z < b.zmax then return true end
	end
	return false
end

function WorldBuilder.Build()
	local decor = Instance.new("Folder")
	decor.Name = "Decor"
	decor.Parent = workspace

	local baseplate = workspace:FindFirstChild("Baseplate")
	if baseplate and baseplate:IsA("BasePart") then
		local tex = baseplate:FindFirstChild("Texture")
		if tex then
			tex:Destroy()
		end
		baseplate.Material = Enum.Material.Basalt
		baseplate.Color = Color3.fromRGB(34, 35, 40)
	end

	local spawnLoc = workspace:FindFirstChild("SpawnLocation")
	if spawnLoc and spawnLoc:IsA("SpawnLocation") then
		local decal = spawnLoc:FindFirstChild("Decal")
		if decal then
			decal:Destroy()
		end
		spawnLoc.CFrame = CFrame.new(0, 0.9, 0)
		spawnLoc.Material = Enum.Material.Basalt
		spawnLoc.Color = Color3.fromRGB(48, 50, 58)
	end
	makePart({ Name = "Plaza", Size = Vector3.new(30, 0.4, 30), CFrame = CFrame.new(0, 0.2, 0), Color = Color3.fromRGB(72, 74, 84), Material = Enum.Material.Cobblestone }, decor)
	makePart({ Name = "PlazaRing", Size = Vector3.new(32, 0.35, 32), CFrame = CFrame.new(0, 0.18, 0), Color = Color3.fromRGB(0, 255, 140), Material = Enum.Material.Neon }, decor)

	local roadCol = Color3.fromRGB(82, 80, 90)
	local trimCol = Color3.fromRGB(0, 220, 255)
	local function road(x1, z1, x2, z2, w)
		local minX, maxX = math.min(x1, x2), math.max(x1, x2)
		local minZ, maxZ = math.min(z1, z2), math.max(z1, z2)
		local lenX = maxX - minX
		local lenZ = maxZ - minZ
		local cy = 0.15
		if lenX < 0.1 then
			local c = CFrame.new((x1 + x2) / 2, cy, (z1 + z2) / 2)
			makePart({ Name = "Path", Size = Vector3.new(w, 0.3, lenZ + w), CFrame = c, Color = roadCol, Material = Enum.Material.Cobblestone }, decor)
			makePart({ Name = "Trim", Size = Vector3.new(0.4, 0.35, lenZ + w), CFrame = c + Vector3.new(-w / 2 - 0.2, 0, 0), Color = trimCol, Material = Enum.Material.Neon }, decor)
			makePart({ Name = "Trim", Size = Vector3.new(0.4, 0.35, lenZ + w), CFrame = c + Vector3.new(w / 2 + 0.2, 0, 0), Color = trimCol, Material = Enum.Material.Neon }, decor)
		else
			local c = CFrame.new((x1 + x2) / 2, cy, (z1 + z2) / 2)
			makePart({ Name = "Path", Size = Vector3.new(lenX + w, 0.3, w), CFrame = c, Color = roadCol, Material = Enum.Material.Cobblestone }, decor)
			makePart({ Name = "Trim", Size = Vector3.new(lenX + w, 0.35, 0.4), CFrame = c + Vector3.new(0, 0, -w / 2 - 0.2), Color = trimCol, Material = Enum.Material.Neon }, decor)
			makePart({ Name = "Trim", Size = Vector3.new(lenX + w, 0.35, 0.4), CFrame = c + Vector3.new(0, 0, w / 2 + 0.2), Color = trimCol, Material = Enum.Material.Neon }, decor)
		end
	end

	road(0, 14, 0, 42, 10)
	road(0, -14, 0, -42, 10)
	road(-210, 42, 210, 42, 10)
	road(-210, -42, 210, -42, 10)
	for _, b in ipairs(Branches) do
		local padZ = b.z
		local startZ = (padZ > 0) and 42 or -42
		local endZ = padZ
		road(b.x, startZ, b.x, endZ, 10)
	end

	local signBoard = makePart({ Name = "SignBoard", Size = Vector3.new(16, 4.5, 0.8), CFrame = CFrame.new(0, 7.5, -17), Color = Color3.fromRGB(30, 32, 40), Material = Enum.Material.Metal }, decor)
	makePart({ Name = "SignBoardBorder", Size = Vector3.new(16.4, 4.9, 0.6), CFrame = CFrame.new(0, 7.5, -17), Color = Color3.fromRGB(0, 255, 140), Material = Enum.Material.Neon }, decor)
	makePart({ Name = "SignPostL", Size = Vector3.new(0.8, 8, 0.8), CFrame = CFrame.new(-6, 4, -17), Color = Color3.fromRGB(50, 52, 60), Material = Enum.Material.Metal }, decor)
	makePart({ Name = "SignPostR", Size = Vector3.new(0.8, 8, 0.8), CFrame = CFrame.new(6, 4, -17), Color = Color3.fromRGB(50, 52, 60), Material = Enum.Material.Metal }, decor)

	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Back
	sg.Parent = signBoard
	local signLabel = Instance.new("TextLabel")
	signLabel.Size = UDim2.fromScale(1, 1)
	signLabel.BackgroundTransparency = 1
	signLabel.Font = Enum.Font.GothamBlack
	signLabel.TextScaled = true
	signLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
	signLabel.TextStrokeTransparency = 0.3
	signLabel.Text = "MINING EMPIRE"
	signLabel.Parent = sg

	for _, z in ipairs({ 50, -50 }) do
		for _, x in ipairs({ -180, -120, -60, 0, 60, 120, 180 }) do
			if not isBlocked(x, z) then
				buildLamp(decor, Vector3.new(x, 0, z))
			end
		end
	end
	buildLamp(decor, Vector3.new(-14, 0, 14))
	buildLamp(decor, Vector3.new(14, 0, 14))
	buildLamp(decor, Vector3.new(-14, 0, -14))
	buildLamp(decor, Vector3.new(14, 0, -14))

	for i, color in ipairs({ Color3.fromRGB(0, 230, 255), Color3.fromRGB(255, 90, 200), Color3.fromRGB(0, 255, 140), Color3.fromRGB(255, 180, 40) }) do
		local angle = (i / 4) * math.pi * 2
		buildCrystalCluster(decor, Vector3.new(math.cos(angle) * 16, 0.2, math.sin(angle) * 16), color)
	end

	local function scatter(count, xr, zr)
		local placed, tries = 0, 0
		while placed < count and tries < count * 6 do
			tries = tries + 1
			local x = rng:NextNumber(xr[1], xr[2])
			local z = rng:NextNumber(zr[1], zr[2])
			if isBlocked(x, z) then continue end
			local r = rng:NextNumber()
			if r < 0.5 then
				buildTree(decor, Vector3.new(x, 0, z))
			elseif r < 0.78 then
				buildBush(decor, Vector3.new(x, 0, z))
			else
				buildRock(decor, Vector3.new(x, 0, z))
			end
			placed = placed + 1
		end
	end
	scatter(40, { -270, 270 }, { -150, 150 })
	scatter(20, { -270, -70 }, { -30, 30 })
	scatter(20, { 70, 270 }, { -30, 30 })

	for i = 1, 24 do
		buildTree(decor, Vector3.new(rng:NextNumber(-320, 320), 0, rng:NextNumber(-300, -170)))
	end
	for i = 1, 24 do
		buildTree(decor, Vector3.new(rng:NextNumber(-320, 320), 0, rng:NextNumber(170, 300)))
	end

	for i = 1, 10 do
		local angle = (i / 10) * math.pi * 2 + rng:NextNumber(-0.15, 0.15)
		local r = rng:NextNumber(330, 470)
		local x, z = math.cos(angle) * r, math.sin(angle) * r
		local h = rng:NextNumber(40, 100)
		makePart({
			Name = "Mesa",
			Size = Vector3.new(rng:NextNumber(120, 220), h, rng:NextNumber(100, 180)),
			CFrame = CFrame.new(x, h / 2 - 3, z) * CFrame.Angles(0, -angle + math.rad(rng:NextNumber(-30, 30)), 0),
			Color = Color3.fromRGB(44, 46, 54),
			Material = Enum.Material.Slate,
		}, decor)
	end

	for i = 1, 30 do
		local angle = (i / 30) * math.pi * 2 + rng:NextNumber(-0.04, 0.04)
		local r = rng:NextNumber(660, 860)
		local x, z = math.cos(angle) * r, math.sin(angle) * r
		local h = rng:NextNumber(90, 230)
		local w = rng:NextNumber(90, 175)
		local snow = rng:NextNumber() < 0.35
		local baseCol = snow and Color3.fromRGB(60, 64, 74) or Color3.fromRGB(30, 32, 40)
		local cf = CFrame.new(x, h / 2 - 4, z) * CFrame.Angles(0, -angle + math.rad(rng:NextNumber(-25, 25)), 0)
		if i % 3 == 0 then
			makeWedge({
				Name = "Mountain",
				Size = Vector3.new(w, h, w * rng:NextNumber(1, 1.4)),
				CFrame = cf,
				Color = baseCol,
				Material = Enum.Material.Slate,
			}, decor)
		else
			makePart({
				Name = "Mountain",
				Size = Vector3.new(w, h, w * rng:NextNumber(0.7, 1)),
				CFrame = cf,
				Color = baseCol,
				Material = Enum.Material.Slate,
			}, decor)
		end
		if snow then
			makePart({
				Name = "SnowCap",
				Shape = Enum.PartType.Ball,
				Size = Vector3.new(w * 0.5, w * 0.4, w * 0.5),
				CFrame = cf + Vector3.new(0, h * 0.42, 0),
				Color = Color3.fromRGB(235, 240, 250),
				Material = Enum.Material.Snow,
			}, decor)
		end
	end

	local bloom = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect")
	bloom.Intensity = 1.2
	bloom.Size = 24
	bloom.Threshold = 0.8
	bloom.Parent = Lighting

	local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect")
	cc.Brightness = 0.02
	cc.Contrast = 0.1
	cc.Saturation = 0.2
	cc.TintColor = Color3.fromRGB(255, 248, 240)
	cc.Parent = Lighting

	local sunRays = Lighting:FindFirstChildOfClass("SunRaysEffect") or Instance.new("SunRaysEffect")
	sunRays.Intensity = 0.15
	sunRays.Spread = 0.8
	sunRays.Parent = Lighting

	local atmo = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
	atmo.Density = 0.25
	atmo.Haze = 1.2
	atmo.Color = Color3.fromRGB(180, 190, 210)
	atmo.Decay = Color3.fromRGB(90, 100, 120)
	atmo.Parent = Lighting

	Lighting.ClockTime = 14.5
	Lighting.Brightness = 2.8

	return decor
end

return WorldBuilder
