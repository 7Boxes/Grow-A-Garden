local ASSETS = {
    SHADOW_IMAGE = "rbxassetid://1316045217",
    COIN_ICON = "rbxassetid://7072716622",
    REMOTE_PATHS = {
        BuyPetEgg = {"GameEvents", "BuyPetEgg"},
        BuyGearStock = {"GameEvents", "BuyGearStock"},
        BuySeedStock = {"GameEvents", "BuySeedStock"},
        BuyCosmeticCrate = {"GameEvents", "BuyCosmeticCrate"},
        BuyEventShopStock = {"GameEvents", "BuyEventShopStock"},
        BuyCosmeticItem = {"GameEvents", "BuyCosmeticItem"}
    },
    SHOP_PATHS = {
        Seed = {"PlayerGui", "Seed_Shop", "Frame", "ScrollingFrame"},
        Gear = {"PlayerGui", "Gear_Shop", "Frame", "ScrollingFrame"},
        Event = {"PlayerGui", "HoneyEventShop_UI", "Frame", "ScrollingFrame"},
        CosmeticItem = {"ReplicatedStorage", "Data", "CosmeticItemShopData"},
        CosmeticCrate = {"ReplicatedStorage", "Data", "CosmeticCrateShopData"}
    }
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShecklesLogger"
screenGui.Parent = playerGui

local mainScrollingFrame = Instance.new("ScrollingFrame")
mainScrollingFrame.Name = "MainScroller"
mainScrollingFrame.Size = UDim2.new(0, 340, 0, 500)
mainScrollingFrame.Position = UDim2.new(0.5, -170, 0.5, -250)
mainScrollingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainScrollingFrame.BackgroundTransparency = 1
mainScrollingFrame.ScrollBarThickness = 6
mainScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
mainScrollingFrame.Parent = screenGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(1, -10, 0, 800)
frame.Position = UDim2.new(0.5, 0, 0, 5)
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = mainScrollingFrame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 35))
})
gradient.Rotation = 90
gradient.Parent = frame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Image = ASSETS.SHADOW_IMAGE
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.8
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundTransparency = 1
shadow.Parent = frame
shadow.ZIndex = -1

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

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -110)
contentFrame.Position = UDim2.new(0, 10, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = frame

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
shecklesIcon.Image = ASSETS.COIN_ICON
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

local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "ButtonContainer"
buttonContainer.Size = UDim2.new(1, -20, 0, 40)
buttonContainer.Position = UDim2.new(0, 10, 1, -50)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = frame

local buyEggsButton = Instance.new("TextButton")
buyEggsButton.Name = "BuyEggsButton"
buyEggsButton.Size = UDim2.new(0.5, -5, 1, 0)
buyEggsButton.Position = UDim2.new(0, 0, 0, 0)
buyEggsButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
buyEggsButton.AutoButtonColor = false
buyEggsButton.Text = "BUY ALL EGGS: OFF"
buyEggsButton.Font = Enum.Font.GothamBold
buyEggsButton.TextSize = 14
buyEggsButton.TextColor3 = Color3.fromRGB(255, 100, 100)
buyEggsButton.Parent = buttonContainer

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = buyEggsButton

local buttonIndicator = Instance.new("Frame")
buttonIndicator.Name = "Indicator"
buttonIndicator.Size = UDim2.new(1, 0, 0, 3)
buttonIndicator.Position = UDim2.new(0, 0, 1, -3)
buttonIndicator.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
buttonIndicator.BorderSizePixel = 0
buttonIndicator.Parent = buyEggsButton

local indicatorCorner = Instance.new("UICorner")
indicatorCorner.CornerRadius = UDim.new(0, 2)
indicatorCorner.Parent = buttonIndicator

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0.5, -5, 1, 0)
statusLabel.Position = UDim2.new(0.5, 5, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = buttonContainer

local function createDropdown(shopType, positionY)
    local config = {
        path = ASSETS.SHOP_PATHS[shopType],
        filter = function(name)
            return not (name:find("_") or name:upper():find("UI")
        end
    }
    
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = shopType.."Dropdown"
    dropdownFrame.Size = UDim2.new(1, -20, 0, 30)
    dropdownFrame.Position = UDim2.new(0, 10, 0, positionY)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.Parent = frame
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "Button"
    dropdownButton.Size = UDim2.new(1, 0, 0, 30)
    dropdownButton.Position = UDim2.new(0, 0, 0, 0)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    dropdownButton.Text = shopType.." ▼"
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.TextSize = 14
    dropdownButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    dropdownButton.Parent = dropdownFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = dropdownButton
    
    local optionsFrame = Instance.new("ScrollingFrame")
    optionsFrame.Name = "Options"
    optionsFrame.Size = UDim2.new(1, 0, 0, 0)
    optionsFrame.Position = UDim2.new(0, 0, 0, 35)
    optionsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    optionsFrame.BorderSizePixel = 0
    optionsFrame.ScrollBarThickness = 4
    optionsFrame.Visible = false
    optionsFrame.Parent = dropdownFrame
    
    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 6)
    optionsCorner.Parent = optionsFrame
    
    local items = {}
    if shopType == "CosmeticItem" or shopType == "CosmeticCrate" then
        local current = ReplicatedStorage
        for _, part in ipairs(config.path) do
            current = current:WaitForChild(part)
        end
        local data = require(current)
        for name, _ in pairs(data) do
            if not items[name] then
                table.insert(items, name)
                items[name] = true
            end
        end
    else
        local current = player
        for _, part in ipairs(config.path) do
            current = current:WaitForChild(part)
        end
        for _, child in ipairs(current:GetChildren()) do
            if not config.filter or config.filter(child.Name) then
                table.insert(items, child.Name)
            end
        end
    end
    
    local optionHeight = 25
    optionsFrame.CanvasSize = UDim2.new(0, 0, 0, #items * optionHeight)
    
    for i, itemName in ipairs(items) do
        local option = Instance.new("TextButton")
        option.Name = itemName
        option.Size = UDim2.new(1, -10, 0, optionHeight - 2)
        option.Position = UDim2.new(0, 5, 0, (i-1)*optionHeight)
        option.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        option.Text = itemName
        option.Font = Enum.Font.Gotham
        option.TextSize = 12
        option.TextColor3 = Color3.fromRGB(220, 220, 220)
        option.TextXAlignment = Enum.TextXAlignment.Left
        option.Parent = optionsFrame
        
        local optionCorner = Instance.new("UICorner")
        optionCorner.CornerRadius = UDim.new(0, 4)
        optionCorner.Parent = option
        
        local selectionIndicator = Instance.new("Frame")
        selectionIndicator.Name = "Selection"
        selectionIndicator.Size = UDim2.new(0, 4, 1, 0)
        selectionIndicator.Position = UDim2.new(0, 0, 0, 0)
        selectionIndicator.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        selectionIndicator.Visible = false
        selectionIndicator.Parent = option
        
        option.MouseButton1Click:Connect(function()
            selectionIndicator.Visible = not selectionIndicator.Visible
        end)
    end
    
    local isExpanded = false
    dropdownButton.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        if isExpanded then
            dropdownButton.Text = shopType.." ▲"
            optionsFrame.Size = UDim2.new(1, 0, 0, math.min(150, #items * optionHeight))
            optionsFrame.Visible = true
        else
            dropdownButton.Text = shopType.." ▼"
            optionsFrame.Size = UDim2.new(1, 0, 0, 0)
            optionsFrame.Visible = false
        end
    end)
    
    return dropdownFrame
end

local dropdowns = {
    createDropdown("Seed", 180),
    createDropdown("Gear", 220),
    createDropdown("Event", 260),
    createDropdown("CosmeticItem", 300),
    createDropdown("CosmeticCrate", 340)
}

local totalHeight = 400 + (#dropdowns * 40)
frame.Size = UDim2.new(1, -10, 0, totalHeight)
mainScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 10)

local autoBuyEnabled = false
local currentValue = 1
local numberOfRuns = 3
local delayBetweenRuns = 0.1
local cycleDelay = 10 * 60
local buyEggsConnection = nil

local function fireRemote(value)
    local remotePath = ASSETS.REMOTE_PATHS["BuyPetEgg"]
    local remote = ReplicatedStorage
    for _, childName in ipairs(remotePath) do
        remote = remote:WaitForChild(childName)
    end
    remote:FireServer(value)
    statusLabel.Text = "Status: Buying Egg "..value
    task.wait(0.1)
end

local function startAutoBuy()
    if buyEggsConnection then return end
    
    buyEggsConnection = task.spawn(function()
        while autoBuyEnabled do
            for i = 1, numberOfRuns do
                if not autoBuyEnabled then break end
                fireRemote(currentValue)
                currentValue = currentValue % 3 + 1
                if i < numberOfRuns then
                    task.wait(delayBetweenRuns)
                end
            end
            
            if autoBuyEnabled then
                statusLabel.Text = "Status: Waiting ("..math.floor(cycleDelay/60).."m)"
                local waitTime = cycleDelay
                while waitTime > 0 and autoBuyEnabled do
                    task.wait(1)
                    waitTime = waitTime - 1
                    if waitTime % 60 == 0 then
                        statusLabel.Text = "Status: Waiting ("..math.floor(waitTime/60).."m)"
                    end
                end
            end
        end
        statusLabel.Text = "Status: Idle"
    end)
end

local function stopAutoBuy()
    autoBuyEnabled = false
    if buyEggsConnection then
        task.cancel(buyEggsConnection)
        buyEggsConnection = nil
    end
end

buyEggsButton.MouseButton1Click:Connect(function()
    autoBuyEnabled = not autoBuyEnabled
    
    if autoBuyEnabled then
        buyEggsButton.Text = "BUY ALL EGGS: ON"
        buyEggsButton.TextColor3 = Color3.fromRGB(100, 255, 100)
        buttonIndicator.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        startAutoBuy()
    else
        buyEggsButton.Text = "BUY ALL EGGS: OFF"
        buyEggsButton.TextColor3 = Color3.fromRGB(255, 100, 100)
        buttonIndicator.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        stopAutoBuy()
    end
end)

local function updateDisplay()
    while not player:FindFirstChild("leaderstats") do
        task.wait(1)
    end
    
    local leaderstats = player:FindFirstChild("leaderstats")
    local shecklesValue = leaderstats:FindFirstChild("Sheckles")
    
    if shecklesValue then
        local formattedSheckles = tostring(shecklesValue.Value):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
        shecklesLabel.Text = formattedSheckles
        
        local estimatedTime = shecklesValue.Value / 5000000
        timeLabel.Text = string.format("%.2f hours", estimatedTime)
        
        local progress = math.min(shecklesValue.Value / 5000000, 1)
        progressFill.Size = UDim2.new(progress, 0, 1, 0)
        
        if progress >= 1 then
            progressFill.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        else
            progressFill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        end
    end
end

local function setupListener()
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local shecklesValue = leaderstats:FindFirstChild("Sheckles")
        if shecklesValue then
            shecklesValue:GetPropertyChangedSignal("Value"):Connect(updateDisplay)
        end
    end
end

player:WaitForChild("leaderstats", 10)
setupListener()
updateDisplay()

player.ChildAdded:Connect(function(child)
    if child.Name == "leaderstats" then
        setupListener()
        updateDisplay()
    end
end)
