-- Wait for the game to fully load
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create the main UI elements
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShecklesLogger"
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 320, 0, 180) -- Slightly larger for better spacing
frame.Position = UDim2.new(0.5, -160, 0.1, 0) -- Centered horizontally, near top
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35) -- Darker background
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Add a subtle gradient
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 35))
})
gradient.Rotation = 90
gradient.Parent = frame

-- Add a nice corner
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- Add subtle drop shadow
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.8
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundTransparency = 1
shadow.Parent = frame
shadow.ZIndex = -1

-- Add a title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

-- Add title text with better typography
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Text = "SHECKLES TRACKER"
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(220, 220, 220)
title.Font = Enum.Font.GothamMedium
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Add username display (showing only last 3 characters)
local username = player.Name
local hiddenUsername = string.rep("*", #username - 3) .. string.sub(username, -3)

local userLabel = Instance.new("TextLabel")
userLabel.Name = "UserLabel"
userLabel.Text = "USER: " .. hiddenUsername
userLabel.Size = UDim2.new(0, 120, 1, 0)
userLabel.Position = UDim2.new(1, -130, 0, 0)
userLabel.BackgroundTransparency = 1
userLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
userLabel.Font = Enum.Font.Gotham
userLabel.TextSize = 12
userLabel.TextXAlignment = Enum.TextXAlignment.Right
userLabel.Parent = titleBar

-- Add divider with gradient
local divider = Instance.new("Frame")
divider.Name = "Divider"
divider.Size = UDim2.new(1, -20, 0, 1)
divider.Position = UDim2.new(0, 10, 0, 35)
divider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
divider.BorderSizePixel = 0
divider.Parent = frame

local dividerGradient = Instance.new("UIGradient")
dividerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 100, 100)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 150, 150)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 100))
})
dividerGradient.Rotation = 0
dividerGradient.Parent = divider

-- Main content area
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -50)
contentFrame.Position = UDim2.new(0, 10, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = frame

-- Sheckles display with icon
local shecklesContainer = Instance.new("Frame")
shecklesContainer.Name = "ShecklesContainer"
shecklesContainer.Size = UDim2.new(1, 0, 0, 40)
shecklesContainer.Position = UDim2.new(0, 0, 0, 10)
shecklesContainer.BackgroundTransparency = 1
shecklesContainer.Parent = contentFrame

local shecklesIcon = Instance.new("ImageLabel")
shecklesIcon.Name = "Icon"
shecklesIcon.Size = UDim2.new(0, 24, 0, 24)
shecklesIcon.Position = UDim2.new(0, 0, 0.5, -12)
shecklesIcon.BackgroundTransparency = 1
shecklesIcon.Image = "rbxassetid://7072716622" -- Coin icon
shecklesIcon.Parent = shecklesContainer

local shecklesLabel = Instance.new("TextLabel")
shecklesLabel.Name = "ShecklesLabel"
shecklesLabel.Text = "0"
shecklesLabel.Size = UDim2.new(1, -30, 1, 0)
shecklesLabel.Position = UDim2.new(0, 30, 0, 0)
shecklesLabel.BackgroundTransparency = 1
shecklesLabel.TextColor3 = Color3.fromRGB(255, 215, 100) -- Gold color for currency
shecklesLabel.Font = Enum.Font.GothamBold
shecklesLabel.TextSize = 24
shecklesLabel.TextXAlignment = Enum.TextXAlignment.Left
shecklesLabel.Parent = shecklesContainer

-- Time display with progress bar
local timeContainer = Instance.new("Frame")
timeContainer.Name = "TimeContainer"
timeContainer.Size = UDim2.new(1, 0, 0, 60)
timeContainer.Position = UDim2.new(0, 0, 0, 60)
timeContainer.BackgroundTransparency = 1
timeContainer.Parent = contentFrame

local timeTitle = Instance.new("TextLabel")
timeTitle.Name = "TimeTitle"
timeTitle.Text = "ESTIMATED TIME REMAINING"
timeTitle.Size = UDim2.new(1, 0, 0, 20)
timeTitle.Position = UDim2.new(0, 0, 0, 0)
timeTitle.BackgroundTransparency = 1
timeTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
timeTitle.Font = Enum.Font.Gotham
timeTitle.TextSize = 12
timeTitle.TextXAlignment = Enum.TextXAlignment.Left
timeTitle.Parent = timeContainer

local timeLabel = Instance.new("TextLabel")
timeLabel.Name = "TimeLabel"
timeLabel.Text = "0 hours"
timeLabel.Size = UDim2.new(1, 0, 0, 24)
timeLabel.Position = UDim2.new(0, 0, 0, 20)
timeLabel.BackgroundTransparency = 1
timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timeLabel.Font = Enum.Font.GothamBold
timeLabel.TextSize = 20
timeLabel.TextXAlignment = Enum.TextXAlignment.Left
timeLabel.Parent = timeContainer

-- Progress bar
local progressBar = Instance.new("Frame")
progressBar.Name = "ProgressBar"
progressBar.Size = UDim2.new(1, 0, 0, 6)
progressBar.Position = UDim2.new(0, 0, 0, 50)
progressBar.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
progressBar.BorderSizePixel = 0
progressBar.Parent = timeContainer

local progressBarCorner = Instance.new("UICorner")
progressBarCorner.CornerRadius = UDim.new(1, 0)
progressBarCorner.Parent = progressBar

local progressFill = Instance.new("Frame")
progressFill.Name = "ProgressFill"
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBar

local progressFillCorner = Instance.new("UICorner")
progressFillCorner.CornerRadius = UDim.new(1, 0)
progressFillCorner.Parent = progressFill

-- Function to update the display
local function updateDisplay()
    -- Wait for leaderstats to exist
    while not player:FindFirstChild("leaderstats") do
        wait(1)
    end
    
    local leaderstats = player:FindFirstChild("leaderstats")
    local shecklesValue = leaderstats:FindFirstChild("Sheckles")
    
    if shecklesValue then
        -- Format sheckles with commas
        local formattedSheckles = tostring(shecklesValue.Value):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
        shecklesLabel.Text = formattedSheckles
        
        -- Calculate and display estimated time (sheckles / 5 million)
        local estimatedTime = shecklesValue.Value / 5000000
        timeLabel.Text = string.format("%.2f hours", estimatedTime)
        
        -- Update progress bar (cap at 100%)
        local progress = math.min(shecklesValue.Value / 5000000, 1)
        progressFill.Size = UDim2.new(progress, 0, 1, 0)
        
        -- Change progress bar color based on completion
        if progress >= 1 then
            progressFill.BackgroundColor3 = Color3.fromRGB(100, 255, 100) -- Bright green when complete
        else
            progressFill.BackgroundColor3 = Color3.fromRGB(100, 200, 100) -- Normal green
        end
    end
end

-- Set up a listener for changes
local function setupListener()
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local shecklesValue = leaderstats:FindFirstChild("Sheckles")
        if shecklesValue then
            shecklesValue:GetPropertyChangedSignal("Value"):Connect(updateDisplay)
        end
    end
end

-- Initial setup
player:WaitForChild("leaderstats", 10) -- Wait up to 10 seconds for leaderstats
setupListener()
updateDisplay()

-- Reconnect if leaderstats is added later
player.ChildAdded:Connect(function(child)
    if child.Name == "leaderstats" then
        setupListener()
        updateDisplay()
    end
end)
