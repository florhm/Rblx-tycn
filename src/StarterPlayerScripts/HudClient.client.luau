local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FactoryHud"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(1, 0)
frame.Position = UDim2.new(1, -16, 0, 16)
frame.Size = UDim2.fromOffset(210, 52)
frame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 255, 140)
stroke.Thickness = 2
stroke.Transparency = 0.4
stroke.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBlack
label.TextColor3 = Color3.fromRGB(120, 255, 160)
label.TextSize = 26
label.Text = "$0"
label.Parent = frame

local prestigeLabel = Instance.new("TextLabel")
prestigeLabel.Size = UDim2.fromOffset(220, 18)
prestigeLabel.Position = UDim2.new(1, -16, 0, 72)
prestigeLabel.AnchorPoint = Vector2.new(1, 0)
prestigeLabel.BackgroundTransparency = 1
prestigeLabel.Font = Enum.Font.GothamBold
prestigeLabel.TextColor3 = Color3.fromRGB(255, 215, 80)
prestigeLabel.TextSize = 14
prestigeLabel.TextXAlignment = Enum.TextXAlignment.Right
prestigeLabel.Text = ""
prestigeLabel.Parent = screenGui

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 230, 120)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 255, 160)),
})
gradient.Parent = label

local hint = Instance.new("TextLabel")
hint.AnchorPoint = Vector2.new(0.5, 1)
hint.Position = UDim2.new(0.5, 0, 1, -16)
hint.Size = UDim2.fromOffset(480, 26)
hint.BackgroundTransparency = 1
hint.Font = Enum.Font.GothamBold
hint.TextColor3 = Color3.fromRGB(240, 242, 250)
hint.TextStrokeTransparency = 0.4
hint.TextSize = 16
hint.Text = "💎 Claim a plot & step on green buttons to build your empire!"
hint.Parent = screenGui

local progressFrame = Instance.new("Frame")
progressFrame.AnchorPoint = Vector2.new(0.5, 0)
progressFrame.Position = UDim2.new(0.5, 0, 0, 16)
progressFrame.Size = UDim2.fromOffset(320, 28)
progressFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
progressFrame.BackgroundTransparency = 0.2
progressFrame.BorderSizePixel = 0
progressFrame.Parent = screenGui

local progressCorner = Instance.new("UICorner")
progressCorner.CornerRadius = UDim.new(0, 8)
progressCorner.Parent = progressFrame

local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(0, 220, 140)
progressBar.BorderSizePixel = 0
progressBar.Parent = progressFrame

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 8)
barCorner.Parent = progressBar

local progressLabel = Instance.new("TextLabel")
progressLabel.Size = UDim2.fromScale(1, 1)
progressLabel.BackgroundTransparency = 1
progressLabel.Font = Enum.Font.GothamBold
progressLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
progressLabel.TextSize = 13
progressLabel.Text = "Goal: Claim Plot"
progressLabel.Parent = progressFrame

local announceFrame = Instance.new("Frame")
announceFrame.AnchorPoint = Vector2.new(0.5,0)
announceFrame.Position = UDim2.new(0.5,0,0,58)
announceFrame.Size = UDim2.fromOffset(600, 36)
announceFrame.BackgroundColor3 = Color3.fromRGB(25,28,38)
announceFrame.BackgroundTransparency = 0.15
announceFrame.BorderSizePixel = 0
announceFrame.Visible = false
announceFrame.Parent = screenGui
local announceCorner = Instance.new("UICorner")
announceCorner.CornerRadius = UDim.new(0,8)
announceCorner.Parent = announceFrame
local announceStroke = Instance.new("UIStroke")
announceStroke.Color = Color3.fromRGB(255,220,80)
announceStroke.Thickness = 2
announceStroke.Transparency = 0.3
announceStroke.Parent = announceFrame
local announceLabel = Instance.new("TextLabel")
announceLabel.Size = UDim2.fromScale(1,1)
announceLabel.BackgroundTransparency = 1
announceLabel.Font = Enum.Font.GothamBlack
announceLabel.TextScaled = true
announceLabel.TextColor3 = Color3.fromRGB(255,235,120)
announceLabel.TextStrokeTransparency = 0.3
announceLabel.Text = ""
announceLabel.Parent = announceFrame

local guideFrame = Instance.new("Frame")
guideFrame.AnchorPoint = Vector2.new(0.5, 1)
guideFrame.Position = UDim2.new(0.5, 0, 1, -58)
guideFrame.Size = UDim2.fromOffset(300, 38)
guideFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
guideFrame.BackgroundTransparency = 0.2
guideFrame.BorderSizePixel = 0
guideFrame.Visible = false
guideFrame.Parent = screenGui
local guideCorner = Instance.new("UICorner")
guideCorner.CornerRadius = UDim.new(0, 10)
guideCorner.Parent = guideFrame
local guideStroke = Instance.new("UIStroke")
guideStroke.Color = Color3.fromRGB(0, 255, 140)
guideStroke.Thickness = 2
guideStroke.Transparency = 0.35
guideStroke.Parent = guideFrame
local guideLabel = Instance.new("TextLabel")
guideLabel.Size = UDim2.fromScale(1,1)
guideLabel.BackgroundTransparency = 1
guideLabel.Font = Enum.Font.GothamBold
guideLabel.TextScaled = true
guideLabel.TextColor3 = Color3.fromRGB(0, 255, 140)
guideLabel.TextStrokeTransparency = 0.4
guideLabel.Text = "➤ Nearest Free Plot: --"
guideLabel.Parent = guideFrame
local guideArrow = Instance.new("TextLabel")
guideArrow.AnchorPoint = Vector2.new(0.5, 0)
guideArrow.Position = UDim2.new(0.5, 0, 0, -22)
guideArrow.Size = UDim2.fromOffset(30, 22)
guideArrow.BackgroundTransparency = 1
guideArrow.Font = Enum.Font.GothamBlack
guideArrow.TextColor3 = Color3.fromRGB(0, 255, 140)
guideArrow.TextStrokeTransparency = 0.3
guideArrow.TextSize = 22
guideArrow.Text = "▼"
guideArrow.Parent = guideFrame

local guideFolder = Instance.new("Folder")
guideFolder.Name = "LocalGuideBeam"
guideFolder.Parent = workspace

local guideFollow = Instance.new("Part")
guideFollow.Name = "Follow"
guideFollow.Transparency = 1
guideFollow.Anchored = true
guideFollow.CanCollide = false
guideFollow.CanQuery = false
guideFollow.Size = Vector3.new(1, 1, 1)
guideFollow.Parent = guideFolder
local guideFollowAtt = Instance.new("Attachment")
guideFollowAtt.Parent = guideFollow

local guideTarget = Instance.new("Part")
guideTarget.Name = "Target"
guideTarget.Transparency = 1
guideTarget.Anchored = true
guideTarget.CanCollide = false
guideTarget.CanQuery = false
guideTarget.Size = Vector3.new(1, 1, 1)
guideTarget.Parent = guideFolder
local guideTargetAtt = Instance.new("Attachment")
guideTargetAtt.Parent = guideTarget

local guideBeam = Instance.new("Beam")
guideBeam.Name = "PathBeam"
guideBeam.Attachment0 = guideFollowAtt
guideBeam.Attachment1 = guideTargetAtt
guideBeam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 140))
guideBeam.Width0 = 1.6
guideBeam.Width1 = 1.6
guideBeam.FaceCamera = false
guideBeam.LightEmission = 1
guideBeam.LightInfluence = 0
guideBeam.Transparency = NumberSequence.new(0.35)
guideBeam.Texture = "rbxasset://textures/particles/sparkles_main.dds"
guideBeam.TextureMode = Enum.TextureMode.Wrap
guideBeam.TextureLength = 8
guideBeam.TextureSpeed = 3
guideBeam.Enabled = false
guideBeam.Parent = guideFolder

local flash = Instance.new("Frame")
flash.Size = UDim2.fromScale(1, 1)
flash.BackgroundColor3 = Color3.new(1, 1, 1)
flash.BackgroundTransparency = 1
flash.BorderSizePixel = 0
flash.ZIndex = 10
flash.Parent = screenGui

local function formatNumber(n)
	local formatted = tostring(n)
	while true do
		local count
		formatted, count = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		if count == 0 then
			break
		end
	end
	return formatted
end

local function doFlash(intensity)
	flash.BackgroundTransparency = 1 - math.clamp(intensity or 0.6, 0, 1) * 0.7
	TweenService:Create(flash, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
end

local function doShake(intensity)
	local cam = workspace.CurrentCamera
	if not cam then return end
	local orig = cam.CFrame
	local mag = math.clamp(intensity or 1, 0.2, 3) * 1.2
	for i = 1, 6 do
		cam.CFrame = orig * CFrame.new(math.random(-100,100)/100 * mag, math.random(-100,100)/100 * mag, 0)
			* CFrame.Angles(math.rad(math.random(-50,50)/100 * mag), math.rad(math.random(-50,50)/100 * mag), 0)
		task.wait(0.02)
	end
	cam.CFrame = orig
end

local function doFOV(intensity)
	local cam = workspace.CurrentCamera
	if not cam then return end
	local baseFOV = cam.FieldOfView
	local target = baseFOV + math.clamp(intensity or 1, 0.5, 2) * 8
	TweenService:Create(cam, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = target }):Play()
	task.delay(0.25, function()
		TweenService:Create(cam, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = baseFOV }):Play()
	end)
end

local function doAnnounce(msg)
	announceLabel.Text = "⭐ " .. tostring(msg) .. " ⭐"
	announceFrame.Visible = true
	announceFrame.BackgroundTransparency = 0.15
	TweenService:Create(announceFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { BackgroundTransparency = 0.05 }):Play()
	task.delay(3.5, function()
		TweenService:Create(announceFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
		task.wait(0.5)
		announceFrame.Visible = false
	end)
	doFlash(0.4)
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local juiceEvent = ReplicatedStorage:WaitForChild("JuiceEvent")
juiceEvent.OnClientEvent:Connect(function(kind, intensity)
	if kind == "Shake" then
		task.spawn(function() doShake(intensity) end)
	elseif kind == "Flash" then
		doFlash(intensity)
	elseif kind == "FOV" then
		doFOV(intensity)
	elseif kind == "LevelUp" then
		doFlash(1)
		doFOV(1.5)
		task.spawn(function() doShake(1.2) end)
	elseif kind == "Announce" then
		doAnnounce(intensity)
	end
end)

local stats = player:WaitForChild("leaderstats")
local cash = stats:WaitForChild("Cash")
local prestige = stats:WaitForChild("Prestige")

local lastCash = cash.Value

local function update()
	local current = cash.Value
	label.Text = "$" .. formatNumber(current)
	if prestige and prestige.Value > 0 then
		prestigeLabel.Text = "Prestige Lv " .. prestige.Value .. "  (x" .. (1 + 0.25 * prestige.Value) .. " income)"
	else
		prestigeLabel.Text = ""
	end

	if current ~= lastCash then
		lastCash = current
		TweenService:Create(frame, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(225, 58) }):Play()
		task.delay(0.13, function()
			TweenService:Create(frame, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(210, 52) }):Play()
		end)
	end
end

local function updateProgress()
	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return end
	local myPlot = nil
	for _, m in ipairs(plotsFolder:GetChildren()) do
		if m:GetAttribute("OwnerUserId") == player.UserId then
			myPlot = m
			break
		end
	end
	if not myPlot then
		progressLabel.Text = "Goal: Claim a Plot"
		TweenService:Create(progressBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, 0, 1, 0) }):Play()
		return
	end
	local bestName, bestCost = nil, math.huge
	for _, folderName in ipairs({"Buttons","Buttons2","Buttons3"}) do
		local folder = myPlot:FindFirstChild(folderName)
		if folder then
			for _, btn in ipairs(folder:GetChildren()) do
				if btn:IsA("BasePart") and btn.Transparency < 1 then
					local cost = btn:GetAttribute("Cost") or math.huge
					if cost < bestCost then
						bestCost = cost
						bestName = btn:GetAttribute("Id") or btn.Name
					end
				end
			end
		end
	end
	if bestName and bestCost ~= math.huge then
		local cashVal = cash.Value
		local pct = math.clamp(cashVal / bestCost, 0, 1)
		if bestName == "Prestige" then
			progressLabel.Text = "★ PRESTIGE READY! $" .. formatNumber(bestCost) .. " (" .. math.floor(pct*100) .. "%)"
			progressBar.BackgroundColor3 = Color3.fromRGB(255, 215, 80)
		else
			progressLabel.Text = "Next: " .. bestName .. " $" .. formatNumber(bestCost) .. " (" .. math.floor(pct*100) .. "%)"
			if pct >= 1 then
				progressBar.BackgroundColor3 = Color3.fromRGB(90, 255, 140)
			else
				progressBar.BackgroundColor3 = Color3.fromRGB(0, 220, 140)
			end
		end
		TweenService:Create(progressBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(pct, 0, 1, 0) }):Play()
	else
		progressLabel.Text = "MAXED - Empire Complete!"
		TweenService:Create(progressBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 1, 0) }):Play()
		progressBar.BackgroundColor3 = Color3.fromRGB(255, 215, 60)
	end
end

local guideHighlight = nil
local lastGuidePad = nil
local guideTargetPad = nil

local function setBbEnabled(part, on)
	if not part then return end
	local bb = part:FindFirstChildWhichIsA("BillboardGui")
	if bb then bb.Enabled = on end
	local p = part:FindFirstChildOfClass("ProximityPrompt")
	if p then p.Enabled = on end
end

local function updatePlotVisibility(plotsFolder, myPlot)
	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot == myPlot then
			setBbEnabled(plot:FindFirstChild("ClaimPad"), true)
		else
			setBbEnabled(plot:FindFirstChild("Collector"), false)
			setBbEnabled(plot:FindFirstChild("CashHub"), false)
			local b1 = plot:FindFirstChild("Buttons")
			if b1 then for _, b in ipairs(b1:GetChildren()) do setBbEnabled(b, false) end end
			local b2 = plot:FindFirstChild("Buttons2")
			if b2 then for _, b in ipairs(b2:GetChildren()) do setBbEnabled(b, false) end end
			local b3 = plot:FindFirstChild("Buttons3")
			if b3 then for _, b in ipairs(b3:GetChildren()) do setBbEnabled(b, false) end end
			setBbEnabled(plot:FindFirstChild("ClaimPad"), myPlot == nil)
		end
	end
end

local function updateGuide()
	local char = player.Character
	if not char then
		guideFrame.Visible = false
		guideBeam.Enabled = false
		return
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return end

	local myPlot = nil
	for _, m in ipairs(plotsFolder:GetChildren()) do
		if m:GetAttribute("OwnerUserId") == player.UserId then
			myPlot = m
			break
		end
	end

	updatePlotVisibility(plotsFolder, myPlot)

	if myPlot then
		guideFrame.Visible = false
		guideBeam.Enabled = false
		guideTargetPad = nil
		if guideHighlight then guideHighlight:Destroy() guideHighlight = nil end
		lastGuidePad = nil
		hint.Text = "💎 Build your empire! Buy the next upgrade above."
		return
	end

	local nearestPad, minDist, nearestName = nil, math.huge, ""
	for _, plot in ipairs(plotsFolder:GetChildren()) do
		local owner = plot:GetAttribute("OwnerUserId")
		if not owner or owner == 0 then
			local pad = plot:FindFirstChild("ClaimPad")
			if pad then
				local d = (pad.Position - hrp.Position).Magnitude
				if d < minDist then
					minDist = d
					nearestPad = pad
					nearestName = plot.Name
				end
			end
		end
	end

	if nearestPad then
		guideFrame.Visible = true
		local dist = math.floor(minDist)
		guideLabel.Text = "➤ Free Plot: " .. nearestName .. "  (" .. dist .. "m)"
		hint.Text = "→ Follow the glowing green path to claim your plot!"
		guideTargetPad = nearestPad
		guideTarget.CFrame = nearestPad.CFrame * CFrame.new(0, 2.5, 0)
		guideBeam.Enabled = true
		if lastGuidePad ~= nearestPad then
			if guideHighlight then guideHighlight:Destroy() end
			lastGuidePad = nearestPad
			local hl = Instance.new("Highlight")
			hl.Adornee = nearestPad
			hl.FillColor = Color3.fromRGB(0, 255, 140)
			hl.OutlineColor = Color3.fromRGB(255, 255, 255)
			hl.FillTransparency = 0.55
			hl.OutlineTransparency = 0
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Parent = nearestPad
			guideHighlight = hl
		end
		if not guideArrow:GetAttribute("Pulsing") then
			guideArrow:SetAttribute("Pulsing", true)
			task.spawn(function()
				while guideFrame.Visible and lastGuidePad == nearestPad do
					TweenService:Create(guideArrow, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position = UDim2.new(0.5, 0, 0, -28) }):Play()
					task.wait(0.45)
					if not guideFrame.Visible then break end
					TweenService:Create(guideArrow, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position = UDim2.new(0.5, 0, 0, -22) }):Play()
					task.wait(0.45)
				end
				guideArrow:SetAttribute("Pulsing", false)
			end)
		end
	else
		guideFrame.Visible = false
		guideBeam.Enabled = false
		guideTargetPad = nil
		if guideHighlight then guideHighlight:Destroy() guideHighlight = nil end
		guideLabel.Text = "All plots claimed!"
	end
end

task.spawn(function()
	while true do
		updateProgress()
		task.wait(0.5)
	end
end)

task.spawn(function()
	while true do
		updateGuide()
		task.wait(0.25)
	end
end)

local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
	if guideBeam.Enabled and guideTargetPad and player.Character then
		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			guideFollow.CFrame = hrp.CFrame * CFrame.new(0, 1.5, 0)
		end
	end
end)

player.CharacterAdded:Connect(function()
	task.wait(1)
	updateGuide()
end)

cash.Changed:Connect(update)
cash.Changed:Connect(updateProgress)
update()
updateProgress()
updateGuide()
