-- Wait for the game to fully load
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create the main UI elements
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShecklesLogger"
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 350, 0, 500) -- Increased height for all controls
frame.Position = UDim2.new(0.5, -175, 0.1, 0)
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
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

-- Add title text
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

-- Add username display
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
contentFrame.Size = UDim2.new(1, -20, 0, 120) -- For stats only
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
shecklesLabel.TextColor3 = Color3.fromRGB(255, 215, 100)
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

-- Purchase configuration section
local purchaseConfigFrame = Instance.new("Frame")
purchaseConfigFrame.Name = "PurchaseConfig"
purchaseConfigFrame.Size = UDim2.new(1, -20, 0, 320)
purchaseConfigFrame.Position = UDim2.new(0, 10, 0, 170)
purchaseConfigFrame.BackgroundTransparency = 1
purchaseConfigFrame.Parent = frame

local purchaseTitle = Instance.new("TextLabel")
purchaseTitle.Name = "PurchaseTitle"
purchaseTitle.Text = "AUTO-PURCHASE CONFIGURATION"
purchaseTitle.Size = UDim2.new(1, 0, 0, 20)
purchaseTitle.Position = UDim2.new(0, 0, 0, 0)
purchaseTitle.BackgroundTransparency = 1
purchaseTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
purchaseTitle.Font = Enum.Font.GothamMedium
purchaseTitle.TextSize = 14
purchaseTitle.TextXAlignment = Enum.TextXAlignment.Left
purchaseTitle.Parent = purchaseConfigFrame

-- Purchase control function
local function createPurchaseControl(category, yPosition, exampleText)
    local container = Instance.new("Frame")
    container.Name = category .. "Container"
    container.Size = UDim2.new(1, 0, 0, 60)
    container.Position = UDim2.new(0, 0, 0, yPosition)
    container.BackgroundTransparency = 1
    container.Parent = purchaseConfigFrame

    -- Toggle button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = category .. "Toggle"
    toggleButton.Size = UDim2.new(0, 120, 0, 25)
    toggleButton.Position = UDim2.new(0, 0, 0, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleButton.AutoButtonColor = false
    toggleButton.Text = category .. ": OFF"
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 12
    toggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    toggleButton.Parent = container

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = toggleButton

    -- Button state indicator
    local buttonIndicator = Instance.new("Frame")
    buttonIndicator.Name = "Indicator"
    buttonIndicator.Size = UDim2.new(1, 0, 0, 2)
    buttonIndicator.Position = UDim2.new(0, 0, 1, -2)
    buttonIndicator.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    buttonIndicator.BorderSizePixel = 0
    buttonIndicator.Parent = toggleButton

    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 1)
    indicatorCorner.Parent = buttonIndicator

    -- Text box label
    local textBoxLabel = Instance.new("TextLabel")
    textBoxLabel.Name = category .. "Label"
    textBoxLabel.Text = category .. " Items (comma separated):"
    textBoxLabel.Size = UDim2.new(1, 0, 0, 15)
    textBoxLabel.Position = UDim2.new(0, 0, 0, 30)
    textBoxLabel.BackgroundTransparency = 1
    textBoxLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    textBoxLabel.Font = Enum.Font.Gotham
    textBoxLabel.TextSize = 12
    textBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
    textBoxLabel.Parent = container

    -- Example text
    local exampleLabel = Instance.new("TextLabel")
    exampleLabel.Name = category .. "Example"
    exampleLabel.Text = "Example: " .. exampleText
    exampleLabel.Size = UDim2.new(1, 0, 0, 12)
    exampleLabel.Position = UDim2.new(0, 0, 0, 45)
    exampleLabel.BackgroundTransparency = 1
    exampleLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    exampleLabel.Font = Enum.Font.Gotham
    exampleLabel.TextSize = 10
    exampleLabel.TextXAlignment = Enum.TextXAlignment.Left
    exampleLabel.Parent = container

    -- Text box
    local textBox = Instance.new("TextBox")
    textBox.Name = category .. "TextBox"
    textBox.Size = UDim2.new(1, 0, 0, 20)
    textBox.Position = UDim2.new(0, 0, 0, 25)
    textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    textBox.TextColor3 = Color3.fromRGB(220, 220, 220)
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 12
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.PlaceholderText = "Enter items separated by commas"
    textBox.Text = ""
    textBox.Parent = container

    local textBoxCorner = Instance.new("UICorner")
    textBoxCorner.CornerRadius = UDim.new(0, 4)
    textBoxCorner.Parent = textBox

    local textBoxPadding = Instance.new("UIPadding")
    textBoxPadding.PaddingLeft = UDim.new(0, 5)
    textBoxPadding.Parent = textBox

    return {
        toggle = toggleButton,
        textBox = textBox,
        indicator = buttonIndicator
    }
end

-- Create controls for each category
local purchaseControls = {
    GearStock = createPurchaseControl("GearStock", 30, "Sword1, Shield2, Bow3"),
    SeedStock = createPurchaseControl("SeedStock", 100, "AppleSeed, OrangeSeed, BananaSeed"),
    CosmeticCrate = createPurchaseControl("CosmeticCrate", 170, "BasicCrate, PremiumCrate"),
    EventStock = createPurchaseControl("EventStock", 240, "HalloweenItem1, ChristmasItem2"),
    CosmeticItem = createPurchaseControl("CosmeticItem", 310, "Hat1, Shirt2, Pants3")
}

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 500)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

-- Purchase function library
local BuyFunction = {}

local REMOTE_MAPPINGS = {
    GearStock = {
        RemotePath = {"GameEvents", "BuyGearStock"},
        ArgsTemplate = function(item) return {item} end
    },
    SeedStock = {
        RemotePath = {"GameEvents", "BuySeedStock"},
        ArgsTemplate = function(item) return {item} end
    },
    CosmeticCrate = {
        RemotePath = {"GameEvents", "BuyCosmeticCrate"},
        ArgsTemplate = function(item) return {item} end
    },
    EventStock = {
        RemotePath = {"GameEvents", "BuyEventShopStock"},
        ArgsTemplate = function(item) return {item} end
    },
    CosmeticItem = {
        RemotePath = {"GameEvents", "BuyCosmeticItem"},
        ArgsTemplate = function(item) return {item} end
    }
}

function BuyFunction.execute(remoteType, itemName)
    local config = REMOTE_MAPPINGS[remoteType]
    if not config then return false end
    
    local remote = game:GetService("ReplicatedStorage")
    for _, childName in ipairs(config.RemotePath) do
        remote = remote:WaitForChild(childName)
    end
    
    remote:FireServer(unpack(config.ArgsTemplate(itemName)))
    statusLabel.Text = "Status: Buying "..remoteType.." - "..itemName
    return true
end

-- Auto-purchase system
local activeConnections = {}

local function startCategoryPurchase(category)
    if activeConnections[category] then return end
    
    local itemsText = purchaseControls[category].textBox.Text
    if itemsText == "" then
        statusLabel.Text = "Status: No items configured for "..category
        return
    end
    
    local items = {}
    for item in string.gmatch(itemsText, "([^,]+)") do
        table.insert(items, string.trim(item))
    end
    
    if #items == 0 then
        statusLabel.Text = "Status: No valid items for "..category
        return
    end
    
    local runService = game:GetService("RunService")
    local currentIndex = 1
    
    activeConnections[category] = runService.Heartbeat:Connect(function()
        BuyFunction.execute(category, items[currentIndex])
        currentIndex = currentIndex % #items + 1
        task.wait(0.5) -- Wait half second between purchases
    end)
    
    purchaseControls[category].toggle.Text = category .. ": ON"
    purchaseControls[category].toggle.TextColor3 = Color3.fromRGB(100, 255, 100)
    purchaseControls[category].indicator.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    statusLabel.Text = "Status: "..category.." auto-purchase active"
end

local function stopCategoryPurchase(category)
    if activeConnections[category] then
        activeConnections[category]:Disconnect()
        activeConnections[category] = nil
        
        purchaseControls[category].toggle.Text = category .. ": OFF"
        purchaseControls[category].toggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        purchaseControls[category].indicator.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "Status: "..category.." auto-purchase stopped"
    end
end

-- Set up toggle buttons
for category, control in pairs(purchaseControls) do
    control.toggle.MouseButton1Click:Connect(function()
        if activeConnections[category] then
            stopCategoryPurchase(category)
        else
            startCategoryPurchase(category)
        end
    end)
end

-- Function to update the display
local function updateDisplay()
    -- Wait for leaderstats to exist
    while not player:FindFirstChild("leaderstats") do
        task.wait(1)
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
            progressFill.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        else
            progressFill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
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
player:WaitForChild("leaderstats", 10)
setupListener()
updateDisplay()

-- Reconnect if leaderstats is added later
player.ChildAdded:Connect(function(child)
    if child.Name == "leaderstats" then
        setupListener()
        updateDisplay()
    end
end)
