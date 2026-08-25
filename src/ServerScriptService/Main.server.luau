local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("TycoonConfig"))
local PlotBuilder = require(script.Parent.PlotBuilder)
local TycoonModule = require(script.Parent.Tycoon)
local WorldBuilder = require(script.Parent.WorldBuilder)

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
