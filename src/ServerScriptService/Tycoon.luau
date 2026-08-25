local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("TycoonConfig"))
local PlotBuilder = require(script.Parent.PlotBuilder)

local Tycoon = {}
Tycoon.__index = Tycoon

function Tycoon.new(plotModel, claimHandler)
	local self = setmetatable({}, Tycoon)
	self.Model = plotModel
	self.Owner = nil
	self.Purchased = {}
	self.ActiveDroppers = {}
	self.OwnedWeapons = {}
	self.PendingCash = 0
	self.ItemMultiplier = Config.ValueMultiplierTiers[1]
	self.OnClaimRequested = claimHandler
	self._connections = {}
	self._lastShot = {}
	self:_setup()
	return self
end

function Tycoon:_getCash(player)
	local stats = player and player:FindFirstChild("leaderstats")
	return stats and stats:FindFirstChild("Cash")
end

function Tycoon:_setPadText(text)
	local bb = self.Model.ClaimPad:FindFirstChildWhichIsA("BillboardGui")
	if bb then
		local label = bb:FindFirstChildWhichIsA("TextLabel")
		if label then
			label.Text = text
		end
	end
end

function Tycoon:_setup()
	local model = self.Model

	table.insert(self._connections, model.ClaimPad.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player or self.Owner then
			return
		end
		if self.OnClaimRequested then
			self.OnClaimRequested(player, self)
		end
	end))

	table.insert(self._connections, model.Collector.Touched:Connect(function(hit)
		self:_collect(hit, model.Collector)
	end))

	table.insert(self._connections, model.Locked.StairGroup.Collector2.Touched:Connect(function(hit)
		self:_collect(hit, model.Locked.StairGroup.Collector2)
	end))

	table.insert(self._connections, model.Locked.LaserGroup.Beam.Touched:Connect(function(hit)
		self:_onLaserTouch(hit)
	end))

	table.insert(self._connections, model.CashHub.Touched:Connect(function(hit)
		self:_onHubTouch(hit)
	end))

	for _, folder in ipairs({ model.Buttons, model.Buttons2 }) do
		for _, btn in ipairs(folder:GetChildren()) do
			table.insert(self._connections, btn.Touched:Connect(function(hit)
				local player = Players:GetPlayerFromCharacter(hit.Parent)
				if player then
					self:_tryPurchase(btn, player)
				end
			end))
		end
	end

	for _, locked in ipairs(model.Locked:GetChildren()) do
		PlotBuilder.SetVisible(locked, false)
	end

	self:_applyBeltTier(1)
	self:_refreshButtons()
end

function Tycoon:_collect(hit, collectorPart)
	if hit.Name ~= "CashItem" then
		return
	end
	local value = hit:GetAttribute("Value") or 0
	hit:Destroy()
	if not self.Owner then
		return
	end
	local paid = math.floor(value * self.ItemMultiplier)
	self.PendingCash += paid
	self:_updateHub()
	self:_sellPopup(collectorPart, paid)
	local burst = collectorPart:FindFirstChild("SellBurst")
	if burst then
		burst:Emit(4)
	end
	local sound = collectorPart:FindFirstChild("SellSound")
	if sound then
		sound.PlaybackSpeed = 0.95 + math.random() * 0.2
		sound:Play()
	end
end

function Tycoon:_sellPopup(collectorPart, amount)
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(120, 40)
	bb.StudsOffset = Vector3.new(math.random(-15, 15) / 10, 2, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = 80
	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.fromScale(1, 1)
	tl.BackgroundTransparency = 1
	tl.Font = Enum.Font.GothamBlack
	tl.TextScaled = true
	tl.TextColor3 = Color3.fromRGB(140, 255, 160)
	tl.TextStrokeTransparency = 0.3
	tl.Text = "+$" .. self:_formatNumber(amount)
	tl.Parent = bb
	bb.Adornee = collectorPart
	bb.Parent = collectorPart
	TweenService:Create(tl, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	TweenService:Create(bb, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { StudsOffset = bb.StudsOffset + Vector3.new(0, 4, 0) }):Play()
	Debris:AddItem(bb, 0.85)
end

function Tycoon:_formatNumber(n)
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

function Tycoon:_updateHub()
	local bb = self.Model.CashHub:FindFirstChildWhichIsA("BillboardGui")
	if bb then
		local label = bb:FindFirstChildWhichIsA("TextLabel")
		if label then
			label.Text = "COLLECT\n$" .. self:_formatNumber(self.PendingCash)
		end
	end
end

function Tycoon:_onHubTouch(hit)
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player or player ~= self.Owner then
		return
	end
	if self.PendingCash <= 0 then
		return
	end
	local cash = self:_getCash(player)
	if not cash then
		return
	end
	local amount = self.PendingCash
	self.PendingCash = 0
	self:_updateHub()
	cash.Value += amount
	self:_sellPopup(self.Model.CashHub, amount)
	local burst = self.Model.CashHub:FindFirstChild("CashBurst")
	if burst then
		burst:Emit(40)
	end
	local sound = self.Model.CashHub:FindFirstChild("CashSound")
	if sound then
		sound:Play()
	end
end

function Tycoon:_onLaserTouch(hit)
	if not self.Purchased["Laser"] then
		return
	end
	local character = hit.Parent
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and player == self.Owner then
		return
	end
	humanoid:SetAttribute("KillerUserId", self.Owner and self.Owner.UserId or 0)
	humanoid.Health = 0
	local beam = self.Model.Locked.LaserGroup.Beam
	local burst = beam:FindFirstChild("KillBurst")
	if burst then
		burst:Emit(25)
	end
	local sound = beam:FindFirstChild("KillSound")
	if sound then
		sound:Play()
	end
end

function Tycoon:_applyBeltTier(tier)
	local belts = { self.Model.Belt }
	local stairGroup = self.Model.Locked:FindFirstChild("StairGroup")
	if stairGroup then
		table.insert(belts, stairGroup.Belt2)
	end
	local dir = self.Model:GetAttribute("BeltDir") or Vector3.new(0, 0, 1)
	for _, belt in ipairs(belts) do
		belt.Velocity = dir * Config.Belt.SpeedTiers[tier]
		belt.Color = Config.Belt.Colors[tier]
	end
end

function Tycoon:_refreshButtons()
	for _, folder in ipairs({ self.Model.Buttons, self.Model.Buttons2 }) do
		for _, btn in ipairs(folder:GetChildren()) do
			local id = btn:GetAttribute("Id")
			local req = btn:GetAttribute("Requires")
			local gateOpen = (req == "") or self.Purchased[req] == true
			PlotBuilder.SetVisible(btn, gateOpen and not self.Purchased[id])
		end
	end
end

function Tycoon:_tryPurchase(btn, player)
	if player ~= self.Owner then
		return
	end
	local id = btn:GetAttribute("Id")
	if self.Purchased[id] then
		return
	end
	local req = btn:GetAttribute("Requires")
	if req ~= "" and not self.Purchased[req] then
		return
	end
	local cash = self:_getCash(player)
	local cost = btn:GetAttribute("Cost") or 0
	if not cash or cash.Value < cost then
		return
	end
	cash.Value -= cost
	self.Purchased[id] = true
	self:_applyPurchase(btn:GetAttribute("Kind"), btn:GetAttribute("Target"))
	self:_juice(btn)
	PlotBuilder.SetVisible(btn, false)
	self:_refreshButtons()
end

function Tycoon:_juice(btn)
	local burst = btn:FindFirstChild("BuyBurst")
	if burst then
		burst:Emit(50)
	end
	local sound = btn:FindFirstChild("BuySound")
	if sound then
		sound.PlaybackSpeed = 0.9 + math.random() * 0.4
		sound:Play()
	end
end

function Tycoon:_applyPurchase(kind, target)
	if kind == "Dropper" then
		PlotBuilder.SetVisible(self.Model.Locked["Dropper_" .. target], true)
		self:_activateDropper(target)
	elseif kind == "BeltSpeed" then
		self:_applyBeltTier(tonumber(target) or 2)
	elseif kind == "ValueTier" then
		self.ItemMultiplier = Config.ValueMultiplierTiers[tonumber(target) or 2]
		local gold = Color3.fromRGB(255, 210, 60)
		self.Model.Collector.Color = gold
		self.Model.Locked.StairGroup.Collector2.Color = gold
	elseif kind == "Wall" then
		PlotBuilder.SetVisible(self.Model.Locked["Wall_" .. target], true)
	elseif kind == "Stairs" then
		PlotBuilder.SetVisible(self.Model.Locked.StairGroup, true)
	elseif kind == "Laser" then
		PlotBuilder.SetVisible(self.Model.Locked.LaserGroup, true)
	elseif kind == "Weapon" then
		self.OwnedWeapons[target] = true
		if self.Owner then
			self:_giveWeapon(self.Owner, target)
		end
	elseif kind == "Complete" then
		if target == "2" then
			PlotBuilder.SetVisible(self.Model.Locked.CompleteSign2, true)
		else
			PlotBuilder.SetVisible(self.Model.Locked.CompleteSign1, true)
		end
	end
end

function Tycoon:_activateDropper(id)
	if self.ActiveDroppers[id] then
		return
	end
	self.ActiveDroppers[id] = true
	local cfg = Config.Droppers[id] or Config.Floor2Droppers[id]
	task.spawn(function()
		while self.ActiveDroppers[id] and self.Model.Parent do
			if self.Owner then
				self:_spawnItem(id, cfg)
			end
			task.wait(cfg.Interval)
		end
	end)
end

function Tycoon:_spawnItem(id, cfg)
	local dropperModel = self.Model.Locked:FindFirstChild("Dropper_" .. id)
	local sp = dropperModel and dropperModel:FindFirstChild("SpawnPoint", true)
	if not sp then
		return
	end
	local item = Instance.new("Part")
	item.Name = "CashItem"
	item.Size = Vector3.new(1, 1, 1)
	item.Material = cfg.ItemMaterial
	item.Color = cfg.ItemColor
	item:SetAttribute("Value", cfg.Value)
	item.CFrame = sp.CFrame * CFrame.new(math.random() * 0.4 - 0.2, 0, math.random() * 0.4 - 0.2)
	if cfg.Trail then
		local pe = Instance.new("ParticleEmitter")
		pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		pe.Color = ColorSequence.new(cfg.ItemColor)
		pe.LightEmission = 1
		pe.Size = NumberSequence.new(0.5)
		pe.Lifetime = NumberRange.new(0.4)
		pe.Rate = 15
		pe.Parent = item
	end
	if cfg.Light then
		local pl = Instance.new("PointLight")
		pl.Color = cfg.ItemColor
		pl.Range = 8
		pl.Brightness = 1.5
		pl.Parent = item
	end
	item.Parent = self.Model
	Debris:AddItem(item, 30)
end

function Tycoon:_giveWeapon(player, wid)
	local cfg = Config.Weapons[wid]
	if not cfg then
		return
	end
	local tool = PlotBuilder.BuildWeapon(wid)
	tool:SetAttribute("WeaponId", wid)
	tool.Activated:Connect(function()
		self:_fireWeapon(player, tool, wid)
	end)
	local backpack = player:FindFirstChild("Backpack")
	if backpack then
		tool.Parent = backpack
	end
end

function Tycoon:EquipWeapons(player)
	if not self.Owner or self.Owner ~= player then
		return
	end
	for wid in pairs(self.OwnedWeapons) do
		self:_giveWeapon(player, wid)
	end
end

function Tycoon:_revokeWeapons(player)
	if not player then
		return
	end
	for _, container in ipairs({ player:FindFirstChild("Backpack"), player.Character }) do
		if container then
			for _, t in ipairs(container:GetChildren()) do
				if t:IsA("Tool") and Config.Weapons[t:GetAttribute("WeaponId")] then
					t:Destroy()
				end
			end
		end
	end
end

function Tycoon:_beamVisual(a, b, color, width)
	local dist = (b - a).Magnitude
	local beam = Instance.new("Part")
	beam.Anchored = true
	beam.CanCollide = false
	beam.CanQuery = false
	beam.Material = Enum.Material.Neon
	beam.Color = color
	beam.Size = Vector3.new(width, width, dist)
	beam.CFrame = CFrame.lookAt(a, b) * CFrame.new(0, 0, -dist / 2)
	beam.Parent = workspace
	Debris:AddItem(beam, 0.08)
end

function Tycoon:_impactBurst(part)
	if not part then
		return
	end
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	pe.Color = ColorSequence.new(Color3.fromRGB(255, 120, 120))
	pe.LightEmission = 1
	pe.Size = NumberSequence.new(0.7)
	pe.Speed = NumberRange.new(6, 12)
	pe.SpreadAngle = Vector2.new(180, 180)
	pe.Lifetime = NumberRange.new(0.3, 0.5)
	pe.Enabled = false
	pe.Parent = part
	pe:Emit(15)
	Debris:AddItem(pe, 1)
end

function Tycoon:_fireWeapon(player, tool, wid)
	local cfg = Config.Weapons[wid]
	if not cfg then
		return
	end
	local now = os.clock()
	if self._lastShot[wid] and now - self._lastShot[wid] < cfg.Cooldown then
		return
	end
	self._lastShot[wid] = now

	local character = player.Character
	local handle = tool and tool:FindFirstChild("Handle")
	if not character or not handle then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local origin = root.Position
	local dir = root.CFrame.LookVector
	local hitChar = nil

	if cfg.Type == "Melee" then
		self:_beamVisual(origin + dir * 2, origin + dir * 4, Color3.new(1, 1, 1), 0.3)
		local nearest, nearestDist = nil, cfg.Range
		for _, other in ipairs(Players:GetPlayers()) do
			if other ~= player and other.Character then
				local hrp = other.Character:FindFirstChild("HumanoidRootPart")
				local hum = other.Character:FindFirstChildOfClass("Humanoid")
				if hrp and hum and hum.Health > 0 then
					local offset = hrp.Position - origin
					local dist = offset.Magnitude
					if dist <= nearestDist and offset.Unit:Dot(dir) > 0.2 then
						nearest = other
						nearestDist = dist
					end
				end
			end
		end
		if nearest then
			hitChar = nearest.Character
		end
	else
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		local exclude = { character }
		for _, item in ipairs(self.Model:GetChildren()) do
			if item.Name == "CashItem" then
				table.insert(exclude, item)
			end
		end
		params.FilterDescendantsInstances = exclude
		local result = workspace:Raycast(origin, dir * cfg.Range, params)
		local endPos = result and result.Position or (origin + dir * cfg.Range)
		self:_beamVisual(origin + dir * 2, endPos, cfg.BeamColor, cfg.BeamWidth)
		if result then
			local m = result.Instance:FindFirstAncestorOfClass("Model")
			if m then
				local otherPlayer = Players:GetPlayerFromCharacter(m)
				if otherPlayer and otherPlayer ~= player then
					hitChar = m
				end
			end
		end
	end

	if hitChar then
		local humanoid = hitChar:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			humanoid:SetAttribute("KillerUserId", player.UserId)
			humanoid:TakeDamage(cfg.Damage)
			self:_impactBurst(hitChar:FindFirstChild("HumanoidRootPart"))
		end
	end
end

function Tycoon:SetOwner(player)
	self.Owner = player
	self:_setPadText(player.DisplayName .. "'s Factory")
	PlotBuilder.SetVisible(self.Model.Locked["Dropper_Dirt"], true)
	self:_activateDropper("Dirt")
	self:_updateHub()
	self:_refreshButtons()
end

function Tycoon:Reset()
	self:_revokeWeapons(self.Owner)
	table.clear(self.OwnedWeapons)
	table.clear(self._lastShot)
	table.clear(self.ActiveDroppers)
	self.Purchased = {}
	self.ItemMultiplier = Config.ValueMultiplierTiers[1]
	self.PendingCash = 0
	self:_applyBeltTier(1)
	local green = Color3.fromRGB(90, 230, 110)
	self.Model.Collector.Color = green
	self.Model.Locked.StairGroup.Collector2.Color = green
	for _, locked in ipairs(self.Model.Locked:GetChildren()) do
		PlotBuilder.SetVisible(locked, false)
	end
	for _, item in ipairs(self.Model:GetChildren()) do
		if item.Name == "CashItem" then
			item:Destroy()
		end
	end
	self.Owner = nil
	self:_setPadText("CLAIM PLOT")
	self:_updateHub()
	self:_refreshButtons()
end

function Tycoon:Destroy()
	table.clear(self.ActiveDroppers)
	for _, c in ipairs(self._connections) do
		c:Disconnect()
	end
	table.clear(self._connections)
end

return Tycoon
