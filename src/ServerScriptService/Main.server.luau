local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("TycoonConfig"))
local PlotBuilder = require(script.Parent.PlotBuilder)
local TycoonModule = require(script.Parent.Tycoon)
local WorldBuilder = require(script.Parent.WorldBuilder)

local juiceEvent = ReplicatedStorage:FindFirstChild("JuiceEvent")
if not juiceEvent then
	juiceEvent = Instance.new("RemoteEvent")
	juiceEvent.Name = "JuiceEvent"
	juiceEvent.Parent = ReplicatedStorage
end

local plotsFolder = Instance.new("Folder")
plotsFolder.Name = "Plots"
plotsFolder.Parent = workspace

local groundY = 0
local baseplate = workspace:FindFirstChild("Baseplate")
if baseplate and baseplate:IsA("BasePart") then
	groundY = baseplate.Position.Y + baseplate.Size.Y / 2
end

local ownerByPlayer = {}
local tycoons = {}

for i, layout in ipairs(Config.PlotLayout) do
	local origin = Vector3.new(layout.X, groundY + 1.05, layout.Z)
	local model = PlotBuilder.Build(i, origin, layout.Yaw or 0)
	model.Parent = plotsFolder
	tycoons[i] = TycoonModule.new(model, function(player, tycoon)
		if ownerByPlayer[player] or tycoon.Owner then
			return
		end
		ownerByPlayer[player] = tycoon
		tycoon:SetOwner(player)
	end)
end

WorldBuilder.Build()
shared.Tycoons = tycoons

local leaderboardPart = Instance.new("Part")
leaderboardPart.Name = "SpawnLeaderboard"
leaderboardPart.Size = Vector3.new(14, 8, 1)
leaderboardPart.Anchored = true
leaderboardPart.Color = Color3.fromRGB(20, 22, 30)
leaderboardPart.Material = Enum.Material.Metal
leaderboardPart.CFrame = CFrame.new(22, 4, 0) * CFrame.Angles(0, math.rad(-90), 0)
leaderboardPart.Parent = workspace
local lbGui = Instance.new("SurfaceGui")
lbGui.Face = Enum.NormalId.Front
lbGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
lbGui.PixelsPerStud = 32
lbGui.Parent = leaderboardPart
local lbFrame = Instance.new("Frame")
lbFrame.Size = UDim2.fromScale(1,1)
lbFrame.BackgroundTransparency = 1
lbFrame.Parent = lbGui
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,48)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255,220,80)
title.Text = "TOP TYCOONS"
title.Parent = lbFrame
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0,4)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = lbFrame
title.LayoutOrder = 0
local lbLabels = {}
for i=1,5 do
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1,0,0,32)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBold
	lbl.TextScaled = true
	lbl.TextColor3 = Color3.fromRGB(220,230,255)
	lbl.TextStrokeTransparency = 0.6
	lbl.Text = i..". ---"
	lbl.LayoutOrder = i
	lbl.Parent = lbFrame
	lbLabels[i]=lbl
end
task.spawn(function()
	while true do
		local entries = {}
		for _, pl in ipairs(Players:GetPlayers()) do
			local c = pl:FindFirstChild("leaderstats") and pl.leaderstats:FindFirstChild("Cash")
			if c then table.insert(entries, {pl.DisplayName, c.Value}) end
		end
		table.sort(entries, function(a,b) return a[2] > b[2] end)
		for i=1,5 do
			if entries[i] then
				lbLabels[i].Text = i..". "..entries[i][1]..": $"..tostring(entries[i][2])
			else
				lbLabels[i].Text = i..". ---"
			end
		end
		task.wait(1.5)
	end
end)

local function dropCashPile(victim, killer)
	local cash = victim:FindFirstChild("leaderstats") and victim.leaderstats.Cash
	if not cash or cash.Value <= 0 then
		return
	end
	local amount = math.floor(cash.Value * 0.10)
	if amount <= 0 then
		return
	end
	cash.Value -= amount

	local root = victim.Character and victim.Character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local pile = Instance.new("Part")
	pile.Shape = Enum.PartType.Cylinder
	pile.Size = Vector3.new(0.8, 2.4, 2.4)
	pile.CFrame = CFrame.new(root.Position + Vector3.new(0, 1, 0)) * CFrame.Angles(0, 0, math.rad(90))
	pile.Anchored = true
	pile.Material = Enum.Material.Neon
	pile.Color = Color3.fromRGB(255, 210, 60)
	pile:SetAttribute("OwnerUserId", killer.UserId)
	pile:SetAttribute("Amount", amount)

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(140, 40)
	bb.StudsOffset = Vector3.new(0, 2.5, 0)
	bb.AlwaysOnTop = true
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 230, 120)
	label.TextStrokeTransparency = 0.3
	label.Text = "+$" .. tostring(amount)
	label.Parent = bb
	bb.Adornee = pile
	bb.Parent = pile

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 210, 60)
	light.Range = 10
	light.Brightness = 1.5
	light.Parent = pile

	pile.Touched:Connect(function(hit)
		local p = Players:GetPlayerFromCharacter(hit.Parent)
		if p and p.UserId == pile:GetAttribute("OwnerUserId") then
			local c = p:FindFirstChild("leaderstats") and p.leaderstats.Cash
			if c then
				c.Value += pile:GetAttribute("Amount")
				pile:Destroy()
			end
		end
	end)

	pile.Parent = workspace
	Debris:AddItem(pile, 30)
end

shared._dropCashPile = dropCashPile

local function onCharacterAdded(player, char)
	local humanoid = char:WaitForChild("Humanoid", 10)
	if not humanoid then
		return
	end
	humanoid.Died:Connect(function()
		local killerId = humanoid:GetAttribute("KillerUserId")
		humanoid:SetAttribute("KillerUserId", nil)
		if killerId and killerId > 0 then
			local killer = Players:GetPlayerByUserId(killerId)
			if killer and killer ~= player then
				dropCashPile(player, killer)
			end
		end
	end)
	local tycoon = ownerByPlayer[player]
	if tycoon then
		task.spawn(function()
			tycoon:EquipWeapons(player)
		end)
	end
end

local function onPlayerAdded(player)
	if not player:FindFirstChild("leaderstats") then
		local stats = Instance.new("Folder")
		stats.Name = "leaderstats"
		local cash = Instance.new("IntValue")
		cash.Name = "Cash"
		cash.Value = Config.StartingCash
		cash.Parent = stats
		local prestige = Instance.new("IntValue")
		prestige.Name = "Prestige"
		prestige.Value = 0
		prestige.Parent = stats
		stats.Parent = player
	end
	player.CharacterAdded:Connect(function(char)
		onCharacterAdded(player, char)
	end)
	if player.Character then
		onCharacterAdded(player, player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

Players.PlayerRemoving:Connect(function(player)
	local tycoon = ownerByPlayer[player]
	if tycoon then
		tycoon:Reset()
		ownerByPlayer[player] = nil
	end
end)
