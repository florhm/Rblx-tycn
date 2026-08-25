local Lighting = game:GetService("Lighting")

local WorldBuilder = {}

local rng = Random.new(42)

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

local function buildLamp(parent, pos)
	local m = Instance.new("Model")
	m.Name = "Lamp"
	makePart({ Name = "Pole", Size = Vector3.new(0.6, 7, 0.6), CFrame = CFrame.new(pos + Vector3.new(0, 3.5, 0)), Color = Color3.fromRGB(35, 36, 42), Material = Enum.Material.Metal }, m)
	makePart({ Name = "Base", Size = Vector3.new(1.4, 0.4, 1.4), CFrame = CFrame.new(pos + Vector3.new(0, 0.2, 0)), Color = Color3.fromRGB(35, 36, 42), Material = Enum.Material.Metal }, m)
	local bulb = makePart({ Name = "Bulb", Shape = Enum.PartType.Ball, Size = Vector3.new(1.3, 1.3, 1.3), CFrame = CFrame.new(pos + Vector3.new(0, 7.4, 0)), Color = Color3.fromRGB(255, 230, 170), Material = Enum.Material.Neon }, m)
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 225, 180)
	light.Range = 18
	light.Brightness = 1.2
	light.Parent = bulb
	m.Parent = parent
end

local function isBlocked(x, z)
	if math.abs(x) < 200 and math.abs(z) > 60 then
		return true
	end
	if math.abs(x) < 25 and math.abs(z) < 25 then
		return true
	end
	for _, cx in ipairs({ -150, 0, 150 }) do
		if math.abs(x - cx) < 10 and math.abs(z) > 12 and math.abs(z) < 75 then
			return true
		end
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
		baseplate.Color = Color3.fromRGB(38, 38, 42)
	end

	local spawnLoc = workspace:FindFirstChild("SpawnLocation")
	if spawnLoc and spawnLoc:IsA("SpawnLocation") then
		local decal = spawnLoc:FindFirstChild("Decal")
		if decal then
			decal:Destroy()
		end
		spawnLoc.CFrame = CFrame.new(0, 0.9, 0)
		spawnLoc.Material = Enum.Material.Basalt
		spawnLoc.Color = Color3.fromRGB(52, 52, 60)
	end

	makePart({ Name = "Plaza", Size = Vector3.new(24, 0.4, 24), CFrame = CFrame.new(0, 0.2, 0), Color = Color3.fromRGB(70, 70, 78), Material = Enum.Material.Cobblestone }, decor)

	for _, cx in ipairs({ -150, 0, 150 }) do
		for _, side in ipairs({ -1, 1 }) do
			makePart({ Name = "Path", Size = Vector3.new(10, 0.3, 60), CFrame = CFrame.new(cx, 0.15, side * 42), Color = Color3.fromRGB(80, 78, 86), Material = Enum.Material.Cobblestone }, decor)
		end
	end

	makePart({ Name = "SignPost", Size = Vector3.new(0.7, 8, 0.7), CFrame = CFrame.new(-4, 4, -17), Color = Color3.fromRGB(86, 62, 44), Material = Enum.Material.WoodPlanks }, decor)
	makePart({ Name = "SignPost", Size = Vector3.new(0.7, 8, 0.7), CFrame = CFrame.new(4, 4, -17), Color = Color3.fromRGB(86, 62, 44), Material = Enum.Material.WoodPlanks }, decor)
	local signBoard = makePart({ Name = "SignBoard", Size = Vector3.new(14, 4, 0.8), CFrame = CFrame.new(0, 7, -17), Color = Color3.fromRGB(110, 80, 56), Material = Enum.Material.WoodPlanks }, decor)
	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Back
	sg.Parent = signBoard
	local signLabel = Instance.new("TextLabel")
	signLabel.Size = UDim2.fromScale(1, 1)
	signLabel.BackgroundTransparency = 1
	signLabel.Font = Enum.Font.GothamBlack
	signLabel.TextScaled = true
	signLabel.TextColor3 = Color3.fromRGB(255, 220, 120)
	signLabel.TextStrokeTransparency = 0.6
	signLabel.Text = "MINING EMPIRE"
	signLabel.Parent = sg

	for _, cx in ipairs({ -150, 0, 150 }) do
		for _, z in ipairs({ -52, -30, 30, 52 }) do
			local off = (z < 0) and 7 or -7
			buildLamp(decor, Vector3.new(cx + off, 0, z))
		end
	end

	for i = 1, 14 do
		local x, z = rng:NextNumber(-220, 220), rng:NextNumber(-55, 55)
		if not isBlocked(x, z) then
			buildTree(decor, Vector3.new(x, 0, z))
		end
	end
	for i = 1, 12 do
		buildTree(decor, Vector3.new(rng:NextNumber(-300, 300), 0, rng:NextNumber(-280, -160)))
	end
	for i = 1, 12 do
		buildTree(decor, Vector3.new(rng:NextNumber(-300, 300), 0, rng:NextNumber(160, 280)))
	end
	for i = 1, 6 do
		buildTree(decor, Vector3.new(rng:NextNumber(210, 300), 0, rng:NextNumber(-160, 160)))
	end
	for i = 1, 6 do
		buildTree(decor, Vector3.new(rng:NextNumber(-300, -210), 0, rng:NextNumber(-160, 160)))
	end

	for i = 1, 20 do
		local x, z = rng:NextNumber(-280, 280), rng:NextNumber(-150, 150)
		if not isBlocked(x, z) then
			if rng:NextNumber() < 0.5 then
				buildRock(decor, Vector3.new(x, 0, z))
			else
				buildBush(decor, Vector3.new(x, 0, z))
			end
		end
	end

	for i = 1, 10 do
		local angle = (i / 10) * math.pi * 2 + rng:NextNumber(-0.15, 0.15)
		local r = rng:NextNumber(320, 480)
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

	for i = 1, 28 do
		local angle = (i / 28) * math.pi * 2 + rng:NextNumber(-0.04, 0.04)
		local r = rng:NextNumber(640, 820)
		local x, z = math.cos(angle) * r, math.sin(angle) * r
		local h = rng:NextNumber(90, 220)
		local w = rng:NextNumber(90, 170)
		local cf = CFrame.new(x, h / 2 - 4, z) * CFrame.Angles(0, -angle + math.rad(rng:NextNumber(-25, 25)), 0)
		if i % 3 == 0 then
			makeWedge({
				Name = "Mountain",
				Size = Vector3.new(w, h, w * rng:NextNumber(1, 1.4)),
				CFrame = cf,
				Color = Color3.fromRGB(30, 32, 40),
				Material = Enum.Material.Slate,
			}, decor)
		else
			makePart({
				Name = "Mountain",
				Size = Vector3.new(w, h, w * rng:NextNumber(0.7, 1)),
				CFrame = cf,
				Color = Color3.fromRGB(30, 32, 40),
				Material = Enum.Material.Slate,
			}, decor)
		end
	end

	local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmo then
		atmo.Density = 0.3
		atmo.Haze = 1.5
	end
	Lighting.ClockTime = 14.5
	Lighting.Brightness = 3

	return decor
end

return WorldBuilder
