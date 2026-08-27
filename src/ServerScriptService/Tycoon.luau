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
	self._comboCount = 0
	self._lastSellTime = 0
	self:_setup()
	return self
end

function Tycoon:_getCash(player)
	local stats = player and player:FindFirstChild("leaderstats")
	return stats and stats:FindFirstChild("Cash")
end

function Tycoon:_fireJuice(player, kind, intensity)
	if not player then return end
	local ev = ReplicatedStorage:FindFirstChild("JuiceEvent")
	if ev then
		ev:FireClient(player, kind, intensity or 1)
	end
end

function Tycoon:_fireJuiceAll(kind, intensity)
	local ev = ReplicatedStorage:FindFirstChild("JuiceEvent")
	if ev then
		ev:FireAllClients(kind, intensity or 1)
	end
end

function Tycoon:_setPadText(text)
	local bb = self.Model.ClaimPad:FindFirstChildWhichIsA("BillboardGui")
	if bb then
		local label = bb:FindFirstChildWhichIsA("TextLabel", true)
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
	table.insert(self._connections, model.Locked.LaserGroup.BeamTop.Touched:Connect(function(hit)
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

			local prompt = btn:FindFirstChildOfClass("ProximityPrompt")
			if prompt then
				table.insert(self._connections, prompt.Triggered:Connect(function(player)
					self:_tryPurchase(btn, player)
				end))
			end
		end
	end

	for _, locked in ipairs(model.Locked:GetChildren()) do
		PlotBuilder.SetVisible(locked, false)
	end

	self:_applyBeltTier(1)
	self:_refreshButtons()

	self:_ensureWayfinder()
	self:_updateWayfinder()
end

function Tycoon:_ensureWayfinder()
	if self.Model:FindFirstChild("WayfinderOrigin") then return end
	local origin = Instance.new("Part")
	origin.Name = "WayfinderOrigin"
	origin.Size = Vector3.new(0.5, 0.5, 0.5)
	origin.Transparency = 1
	origin.Anchored = true
	origin.CanCollide = false
	origin.CFrame = self.Model.Floor.CFrame * CFrame.new(0, 12, 0)
	origin.Parent = self.Model

	local target = Instance.new("Part")
	target.Name = "WayfinderTarget"
	target.Size = Vector3.new(0.5, 0.5, 0.5)
	target.Transparency = 1
	target.Anchored = true
	target.CanCollide = false
	target.CFrame = origin.CFrame
	target.Parent = self.Model

	local a0 = Instance.new("Attachment")
	a0.Name = "A0"
	a0.Parent = origin
	local a1 = Instance.new("Attachment")
	a1.Name = "A1"
	a1.Parent = target

	local beam = Instance.new("Beam")
	beam.Name = "WayfinderBeam"
	beam.Attachment0 = a0
	beam.Attachment1 = a1
	beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 140))
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.Width0 = 0.6
	beam.Width1 = 0.2
	beam.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	beam.TextureMode = Enum.TextureMode.Wrap
	beam.TextureLength = 4
	beam.TextureSpeed = 2
	beam.Enabled = false
	beam.Parent = origin

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(0, 255, 140)
	light.Range = 12
	light.Brightness = 1.5
	light.Parent = origin
end

function Tycoon:_updateWayfinder()
	local origin = self.Model:FindFirstChild("WayfinderOrigin")
	local target = self.Model:FindFirstChild("WayfinderTarget")
	local beam = origin and origin:FindFirstChild("WayfinderBeam")
	if not origin or not target or not beam then return end

	if not self.Owner then
		beam.Enabled = false
		return
	end

	local best, bestCost = nil, math.huge
	for _, folder in ipairs({ self.Model.Buttons, self.Model.Buttons2 }) do
		for _, btn in ipairs(folder:GetChildren()) do
			local id = btn:GetAttribute("Id")
			if not self.Purchased[id] then
				local req = btn:GetAttribute("Requires")
				local gateOpen = (req == "") or self.Purchased[req]
				if gateOpen then
					local cost = btn:GetAttribute("Cost") or math.huge
					if cost < bestCost then
						bestCost = cost
						best = btn
					end
				end
			end
		end
	end

	if best then
		target.CFrame = best.CFrame
		beam.Enabled = true
	else
		beam.Enabled = false
	end
end

function Tycoon:_collect(hit, collectorPart)
	if hit.Name ~= "CashItem" or hit:GetAttribute("Collecting") then
		return
	end
	hit:SetAttribute("Collecting", true)

	local value = hit:GetAttribute("Value") or 0
	local color = hit.Color

	TweenService:Create(hit, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.1, 0.1, 0.1),
		CFrame = collectorPart.CFrame * CFrame.new(0, 0.5, 0)
	}):Play()

	task.delay(0.12, function()
		if hit and hit.Parent then
			hit:Destroy()
		end
	end)

	if not self.Owner then
		return
	end

	local now = os.clock()
	if now - self._lastSellTime < 1.5 then
		self._comboCount += 1
	else
		self._comboCount = 1
	end
	self._lastSellTime = now

	local paid = math.floor(value * self.ItemMultiplier)
	self.PendingCash += paid
	self:_updateHub()
	self:_sellPopup(collectorPart, paid, color, self._comboCount)

	local burst = collectorPart:FindFirstChild("SellBurst")
	if burst then
		burst:Emit(math.clamp(self._comboCount * 2, 4, 20))
	end
	local sound = collectorPart:FindFirstChild("SellSound")
	if sound then
		sound.PlaybackSpeed = math.min(0.95 + (self._comboCount * 0.05), 1.6)
		sound:Play()
	end
	if self.Owner and (paid >= 300 or self._comboCount >= 4) then
		self:_fireJuice(self.Owner, "Shake", math.clamp(self._comboCount * 0.3 + paid/1000, 0.5, 1.5))
	end
end

function Tycoon:_sellPopup(collectorPart, amount, color, combo)
	local isCrit = (amount >= 500) or (combo and combo > 3)
	local bb = Instance.new("BillboardGui")
	bb.Size = isCrit and UDim2.fromOffset(190, 64) or UDim2.fromOffset(140, 46)
	bb.StudsOffset = Vector3.new(math.random(-18, 18) / 10, 2, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = 90

	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.fromScale(1, 1)
	tl.BackgroundTransparency = 1
	tl.Font = Enum.Font.GothamBlack
	tl.TextScaled = true
	if isCrit then
		tl.TextColor3 = (amount >= 1000) and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(255, 220, 60)
		tl.TextStrokeTransparency = 0.0
	else
		tl.TextColor3 = (amount >= 500) and Color3.fromRGB(255, 220, 60) or (color or Color3.fromRGB(140, 255, 160))
		tl.TextStrokeTransparency = 0.2
	end

	if combo and combo > 2 then
		tl.Text = "+$" .. self:_formatNumber(amount) .. " x" .. combo .. "!"
	else
		tl.Text = "+$" .. self:_formatNumber(amount)
	end
	tl.Parent = bb

	local scale = Instance.new("UIScale")
	scale.Scale = 0.5
	scale.Parent = tl
	TweenService:Create(scale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = isCrit and 1.35 or 1.15 }):Play()
	task.delay(0.35, function()
		if scale.Parent then
			TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		end
	end)

	bb.Adornee = collectorPart
	bb.Parent = collectorPart

	TweenService:Create(tl, TweenInfo.new(0.85, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	TweenService:Create(bb, TweenInfo.new(0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { StudsOffset = bb.StudsOffset + Vector3.new(0, 4.5, 0) }):Play()
	Debris:AddItem(bb, 0.9)
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
		local label = bb:FindFirstChildWhichIsA("TextLabel", true)
		if label then
			label.Text = "COLLECT\n$" .. self:_formatNumber(self.PendingCash)
		end
	end
end

function Tycoon:_spawnCoinShower(hubPart)
	for i = 1, 12 do
		local coin = Instance.new("Part")
		coin.Shape = Enum.PartType.Cylinder
		coin.Size = Vector3.new(0.2, 0.8, 0.8)
		coin.Color = Color3.fromRGB(255, 215, 60)
		coin.Material = Enum.Material.Neon
		coin.CFrame = hubPart.CFrame * CFrame.new(math.random(-2, 2), 2, math.random(-2, 2)) * CFrame.Angles(0, 0, math.rad(90))
		coin.Velocity = Vector3.new(math.random(-15, 15), math.random(20, 35), math.random(-15, 15))
		coin.Parent = workspace
		Debris:AddItem(coin, 1.5)
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
	self:_sellPopup(self.Model.CashHub, amount, Color3.fromRGB(255, 220, 80))
	self:_spawnCoinShower(self.Model.CashHub)

	local burst = self.Model.CashHub:FindFirstChild("CashBurst")
	if burst then
		burst:Emit(50)
	end
	local sound = self.Model.CashHub:FindFirstChild("CashSound")
	if sound then
		sound:Play()
	end
	self:_fireJuice(player, "Shake", math.clamp(amount/2000, 0.5, 2))
	if amount >= 5000 then
		self:_fireJuice(player, "Flash", 1)
	end
	if amount >= 2000 then
		self:_fireJuice(player, "FOV", 1)
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
		burst:Emit(30)
	end
	local sound = beam:FindFirstChild("KillSound")
	if sound then
		sound:Play()
	end
	if player then
		self:_fireJuice(player, "Shake", 2)
		self:_fireJuice(player, "Flash", 0.5)
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
	self:_updateWayfinder()
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
		self:_rejectPurchase(btn)
		return
	end

	cash.Value -= cost
	self.Purchased[id] = true
	self:_applyPurchase(btn:GetAttribute("Kind"), btn:GetAttribute("Target"))
	self:_juice(btn)
	PlotBuilder.SetVisible(btn, false)
	self:_refreshButtons()
end

function Tycoon:_rejectPurchase(btn)
	local sound = btn:FindFirstChild("BuySound")
	if sound then
		sound.PlaybackSpeed = 0.65
		sound:Play()
	end
	local bb = btn:FindFirstChildWhichIsA("BillboardGui")
	if bb then
		local frame = bb:FindFirstChildWhichIsA("Frame")
		if frame then
			local stroke = frame:FindFirstChildWhichIsA("UIStroke")
			if stroke then
				stroke.Color = Color3.fromRGB(255, 60, 60)
				task.delay(0.3, function()
					stroke.Color = Color3.fromRGB(255, 255, 255)
				end)
			end
		end
	end
end

function Tycoon:_juice(btn)
	local burst = btn:FindFirstChild("BuyBurst")
	if burst then
		burst:Emit(60)
	end
	local sound = btn:FindFirstChild("BuySound")
	if sound then
		sound.PlaybackSpeed = 1.0 + math.random() * 0.3
		sound:Play()
	end
end

function Tycoon:_bigReveal(pos, color)
	local ev = ReplicatedStorage:FindFirstChild("JuiceEvent")
	if ev then
		ev:FireAllClients("LevelUp", 1)
	end
	local Lighting = game:GetService("Lighting")
	local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
	if bloom then
		local orig = bloom.Intensity
		TweenService:Create(bloom, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Intensity = orig + 2 }):Play()
		task.delay(0.6, function()
			TweenService:Create(bloom, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Intensity = orig }):Play()
		end)
	end
	for i = 1, 8 do
		local angle = (i/8)*360
		local beam = Instance.new("Part")
		beam.Anchored = true
		beam.CanCollide = false
		beam.Material = Enum.Material.Neon
		beam.Color = color or Color3.fromRGB(255, 220, 60)
		beam.Size = Vector3.new(0.6, 18, 0.6)
		beam.CFrame = CFrame.new(pos + Vector3.new(math.cos(math.rad(angle))*2, 9, math.sin(math.rad(angle))*2))
		beam.Parent = workspace
		TweenService:Create(beam, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1, Size = Vector3.new(0.1, 18, 0.1) }):Play()
		Debris:AddItem(beam, 0.7)
		local pe = Instance.new("ParticleEmitter")
		pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		pe.Color = ColorSequence.new(color or Color3.fromRGB(255,220,60))
		pe.LightEmission = 1
		pe.Size = NumberSequence.new(1.2)
		pe.Speed = NumberRange.new(12, 18)
		pe.Lifetime = NumberRange.new(0.6, 0.9)
		pe.SpreadAngle = Vector2.new(180,180)
		pe.Enabled = false
		pe.Parent = beam
		pe:Emit(30)
	end
end

function Tycoon:_announce(msg, color)
	local ev = ReplicatedStorage:FindFirstChild("JuiceEvent")
	if ev then
		ev:FireAllClients("Announce", msg)
	end
	print("[ANNOUNCE] " .. msg)
end

function Tycoon:_givePrestige(player, tierName, color)
	if not player or not player.Character then return end
	local head = player.Character:FindFirstChild("Head")
	if not head then return end
	if head:FindFirstChild("PrestigeTag") then head.PrestigeTag:Destroy() end
	if head:FindFirstChild("PrestigeAura") then head.PrestigeAura:Destroy() end
	local bb = Instance.new("BillboardGui")
	bb.Name = "PrestigeTag"
	bb.Size = UDim2.fromOffset(180, 32)
	bb.StudsOffset = Vector3.new(0, 3.5, 0)
	bb.AlwaysOnTop = true
	bb.Parent = head
	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.fromScale(1,1)
	tl.BackgroundTransparency = 1
	tl.Font = Enum.Font.GothamBlack
	tl.TextScaled = true
	tl.TextColor3 = color or Color3.fromRGB(255,220,60)
	tl.TextStrokeTransparency = 0.2
	tl.Text = tierName
	tl.Parent = bb
	local aura = Instance.new("ParticleEmitter")
	aura.Name = "PrestigeAura"
	aura.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	aura.Color = ColorSequence.new(color or Color3.fromRGB(255,220,60))
	aura.LightEmission = 1
	aura.Size = NumberSequence.new(1.2)
	aura.Rate = 8
	aura.Lifetime = NumberRange.new(0.8, 1.2)
	aura.Speed = NumberRange.new(2, 4)
	aura.Parent = head
	local light = Instance.new("PointLight")
	light.Color = color or Color3.fromRGB(255,220,60)
	light.Range = 12
	light.Brightness = 2
	light.Parent = head
end

function Tycoon:_applyPurchase(kind, target)
	if kind == "Dropper" then
		PlotBuilder.SetVisible(self.Model.Locked["Dropper_" .. target], true)
		self:_activateDropper(target)
		if target == "Voidstone" then
			local m = self.Model.Locked:FindFirstChild("Dropper_"..target)
			local pos = m and m:GetBoundingBox()
			self:_bigReveal(pos and (pos.Position) or self.Model.Floor.Position + Vector3.new(0,10,0), Color3.fromRGB(190,80,255))
			if self.Owner then
				self:_announce(self.Owner.DisplayName .. " unlocked Voidstone Extractor! [MYTHIC]", Color3.fromRGB(190,80,255))
			end
		end
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
			local sign = self.Model.Locked:FindFirstChild("CompleteSign2")
			local pos = sign and sign:GetBoundingBox()
			self:_bigReveal(pos and pos.Position or self.Model.Floor.Position + Vector3.new(0,20,0), Color3.fromRGB(255,60,90))
			if self.Owner then
				self:_announce(self.Owner.DisplayName .. " just unlocked EMPIRE COMPLETE! [LEGENDARY]", Color3.fromRGB(255,60,90))
				self:_givePrestige(self.Owner, "EMPIRE LEGEND", Color3.fromRGB(255,60,90))
			end
		else
			PlotBuilder.SetVisible(self.Model.Locked.CompleteSign1, true)
			local sign = self.Model.Locked:FindFirstChild("CompleteSign1")
			local pos = sign and sign:GetBoundingBox()
			self:_bigReveal(pos and pos.Position or self.Model.Floor.Position + Vector3.new(0,10,0), Color3.fromRGB(255,220,60))
			if self.Owner then
				self:_announce(self.Owner.DisplayName .. " just completed TYCOON! [EPIC]", Color3.fromRGB(255,220,60))
				self:_givePrestige(self.Owner, "TYCOON MASTER", Color3.fromRGB(255,220,60))
			end
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
	local nozzle = dropperModel and dropperModel:FindFirstChild("Nozzle", true)
	if not sp then
		return
	end

	if nozzle then
		local origSize = Vector3.new(1.8, 1.2, 1.8)
		TweenService:Create(nozzle, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(2.2, 0.7, 2.2) }):Play()
		task.delay(0.09, function()
			if nozzle and nozzle.Parent then
				TweenService:Create(nozzle, TweenInfo.new(0.12, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), { Size = origSize }):Play()
			end
		end)
	end

	local scale = cfg.SizeScale or 1.0
	local item = Instance.new("Part")
	item.Name = "CashItem"
	item.Size = Vector3.new(scale, scale, scale)
	item.Material = cfg.ItemMaterial
	item.Color = cfg.ItemColor
	item:SetAttribute("Value", cfg.Value)
	item.CFrame = sp.CFrame * CFrame.new(math.random() * 0.4 - 0.2, 0, math.random() * 0.4 - 0.2) * CFrame.Angles(math.rad(45), math.rad(45), 0)

	local spin = Instance.new("BodyAngularVelocity")
	spin.AngularVelocity = Vector3.new(math.random(-3, 3), math.random(2, 6), math.random(-3, 3))
	spin.MaxTorque = Vector3.new(100, 100, 100)
	spin.Parent = item

	if cfg.Trail then
		local pe = Instance.new("ParticleEmitter")
		pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		pe.Color = ColorSequence.new(cfg.ItemColor)
		pe.LightEmission = 1
		pe.Size = NumberSequence.new(0.5)
		pe.Lifetime = NumberRange.new(0.4)
		pe.Rate = 18
		pe.Parent = item
	end

	if cfg.Light then
		local pl = Instance.new("PointLight")
		pl.Color = cfg.ItemColor
		pl.Range = 9
		pl.Brightness = 1.6
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
			local victimPlayer = Players:GetPlayerFromCharacter(hitChar)
			if victimPlayer then
				self:_fireJuice(victimPlayer, "Shake", cfg.Damage >= 100 and 2 or 1)
				self:_fireJuice(victimPlayer, "Flash", 0.3)
			end
			self:_fireJuice(player, "Shake", 0.6)
		end
	else
		self:_fireJuice(player, "Shake", 0.2)
	end
end

function Tycoon:SetOwner(player)
	self.Owner = player
	self.Model:SetAttribute("OwnerUserId", player.UserId)
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
	self._comboCount = 0
	self._lastSellTime = 0
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
	self.Model:SetAttribute("OwnerUserId", 0)
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
