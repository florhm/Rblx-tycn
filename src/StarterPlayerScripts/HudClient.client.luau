local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FactoryHud"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(1, 0)
frame.Position = UDim2.new(1, -14, 0, 14)
frame.Size = UDim2.fromOffset(190, 46)
frame.BackgroundColor3 = Color3.fromRGB(25, 27, 33)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.TextColor3 = Color3.fromRGB(120, 235, 140)
label.TextSize = 24
label.Text = "$0"
label.Parent = frame

local hint = Instance.new("TextLabel")
hint.AnchorPoint = Vector2.new(0.5, 1)
hint.Position = UDim2.new(0.5, 0, 1, -14)
hint.Size = UDim2.fromOffset(460, 24)
hint.BackgroundTransparency = 1
hint.Font = Enum.Font.Gotham
hint.TextColor3 = Color3.fromRGB(235, 235, 240)
hint.TextStrokeTransparency = 0.5
hint.TextSize = 16
hint.Text = "Claim a plot, mine ore, buy walls, a laser gate & weapons!"
hint.Parent = screenGui

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

local function update()
	label.Text = "$" .. formatNumber(cash.Value)
end

cash.Changed:Connect(update)
update()
