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

local stats = player:WaitForChild("leaderstats")
local cash = stats:WaitForChild("Cash")

local lastCash = cash.Value

local function update()
	local current = cash.Value
	label.Text = "$" .. formatNumber(current)

	if current ~= lastCash then
		lastCash = current
		TweenService:Create(frame, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(225, 58) }):Play()
		task.delay(0.13, function()
			TweenService:Create(frame, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(210, 52) }):Play()
		end)
	end
end

cash.Changed:Connect(update)
update()
