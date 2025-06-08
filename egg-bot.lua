-- Wait for player to fully load
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Tweening service
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Store home position and camera state
local homePosition
local homeCameraCFrame
local homeCameraType

-- Function to save home position and camera state
local function saveHomeState()
    -- Wait for character to load
    while not player.Character do
        player.CharacterAdded:Wait()
    end
    
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso")
    if rootPart then
        homePosition = rootPart.Position
    else
        warn("Could not find root part to save home position")
        homePosition = Vector3.new(0, 0, 0)
    end
    
    -- Save camera state
    local camera = workspace.CurrentCamera
    homeCameraCFrame = camera.CFrame
    homeCameraType = camera.CameraType
end

-- Call this when player joins
saveHomeState()

-- Create the main UI elements
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShecklesLogger"
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0.5, -150, 0.1, 0) -- Centered horizontally, near top
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Add a title label
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Text = "jajtxs egg bot"
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

-- Add divider
local divider = Instance.new("Frame")
divider.Name = "Divider"
divider.Size = UDim2.new(1, -20, 0, 1)
divider.Position = UDim2.new(0, 10, 0, 35)
divider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
divider.BorderSizePixel = 0
divider.Parent = frame

-- Sheckles display
local shecklesLabel = Instance.new("TextLabel")
shecklesLabel.Name = "ShecklesLabel"
shecklesLabel.Text = "Sheckles: 0"
shecklesLabel.Size = UDim2.new(1, -20, 0, 30)
shecklesLabel.Position = UDim2.new(0, 10, 0, 45)
shecklesLabel.BackgroundTransparency = 1
shecklesLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
shecklesLabel.Font = Enum.Font.SourceSans
shecklesLabel.TextSize = 18
shecklesLabel.TextXAlignment = Enum.TextXAlignment.Left
shecklesLabel.Parent = frame

-- Estimated time display
local timeLabel = Instance.new("TextLabel")
timeLabel.Name = "TimeLabel"
timeLabel.Text = "Estimated Time Remaining: 0 hours"
timeLabel.Size = UDim2.new(1, -20, 0, 30)
timeLabel.Position = UDim2.new(0, 10, 0, 80)
timeLabel.BackgroundTransparency = 1
timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timeLabel.Font = Enum.Font.SourceSans
timeLabel.TextSize = 18
timeLabel.TextXAlignment = Enum.TextXAlignment.Left
timeLabel.Parent = frame

-- Add corner
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- Function to update the display
local function updateDisplay()
    while not player:FindFirstChild("leaderstats") do
        wait(1)
    end
    
    local leaderstats = player:FindFirstChild("leaderstats")
    local shecklesValue = leaderstats:FindFirstChild("Sheckles")
    
    if shecklesValue then
        shecklesLabel.Text = string.format("Sheckles: %s", tostring(shecklesValue.Value))
        local estimatedTime = shecklesValue.Value / 5000000
        timeLabel.Text = string.format("Estimated Time Remaining: %.2f seconds", estimatedTime)
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

-- Egg purchasing system
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuyPetEgg = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyPetEgg")

local function fireRemote(value)
    local args = {value}
    BuyPetEgg:FireServer(unpack(args))
    print("Fired BuyPetEgg with value:", value)
end

local function equipNextEggTool()
    -- Wait for backpack to load
    while not player:FindFirstChild("Backpack") do
        task.wait(0.1)
    end
    
    local backpack = player.Backpack
    
    -- Find first tool with "Egg" in name
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") and string.find(string.lower(item.Name), "egg") then
            -- Get character and humanoid
            local character = player.Character
            if not character then return false end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return false end
            
            -- Equip the tool
            humanoid:UnequipTools()
            task.wait(0.05)
            item.Parent = character
            return true
        end
    end
    return false
end

local function setupCameraForFarming()
    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position - Vector3.new(0, 1, 0)) -- Look straight down
end

local function resetCamera()
    local camera = workspace.CurrentCamera
    camera.CameraType = homeCameraType or Enum.CameraType.Custom
    camera.CFrame = homeCameraCFrame or CFrame.new()
end

local function clickCenterScreen()
    local success, err = pcall(function()
        -- Get the viewport size
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local center = Vector2.new(viewportSize.X/2, viewportSize.Y/2)
        
        -- Create mouse down event
        local inputDown = Instance.new("InputObject")
        inputDown.UserInputType = Enum.UserInputType.MouseButton1
        inputDown.UserInputState = Enum.UserInputState.Begin
        inputDown.Position = center
        
        -- Create mouse up event
        local inputUp = Instance.new("InputObject")
        inputUp.UserInputType = Enum.UserInputType.MouseButton1
        inputUp.UserInputState = Enum.UserInputState.End
        inputUp.Position = center
        
        -- Get UserInputService
        local uis = game:GetService("UserInputService")
        
        -- Send the events
        uis:ProcessInput(inputDown)
        task.wait(0.1) -- Short delay between down and up
        uis:ProcessInput(inputUp)
    end)
    
    if not success then
        warn("Failed to click:", err)
    end
end

local function tweenToPosition(position)
    local character = player.Character
    if not character then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
    if not rootPart then return false end
    
    -- Create tween info
    local tweenInfo = TweenInfo.new(
        1, -- Time
        Enum.EasingStyle.Quad, -- Easing style
        Enum.EasingDirection.Out, -- Easing direction
        0, -- Repeat count
        false, -- Reverses
        0 -- Delay
    )
    
    -- Create and play tween
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = CFrame.new(position)})
    tween:Play()
    
    -- Wait for tween to complete
    tween.Completed:Wait()
    return true
end

local function generateFarmPositions()
    -- Find the target folder
    local folder = workspace:FindFirstChild("Farm")
                  and workspace.Farm:FindFirstChild("Farm")
                  and workspace.Farm.Farm:FindFirstChild("Important")
                  and workspace.Farm.Farm.Important:FindFirstChild("Plant_Locations")
    
    if not folder then
        warn("Farm folder not found")
        return {}
    end
    
    -- Find all valid parts
    local parts = {}
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("BasePart") then
            table.insert(parts, child)
        end
    end
    
    if #parts == 0 then
        warn("No farm parts found")
        return {}
    end
    
    -- Generate positions above each part
    local positions = {}
    for _, part in ipairs(parts) do
        table.insert(positions, part.Position + Vector3.new(0, 5, 0)) -- 5 units above
    end
    
    return positions
end

-- Main loop
local currentValue = 1
local numberOfRuns = 3
local delayBetweenRuns = 0.1
local cycleDelay = 10 * 60 -- 10 minutes

while true do
    -- Buy eggs first
    print("Starting egg purchase cycle...")
    for i = 1, numberOfRuns do
        fireRemote(currentValue)
        currentValue = currentValue % 3 + 1
        if i < numberOfRuns then
            wait(delayBetweenRuns)
        end
    end
    print("Egg purchases complete")
    
    -- Setup for farming
    print("Setting up camera for farming...")
    setupCameraForFarming()
    
    -- Get farm positions
    print("Generating farm positions...")
    local farmPositions = generateFarmPositions()
    
    if #farmPositions > 0 then
        print("Beginning farming at "..#farmPositions.." locations")
        
        -- Farm at each position
        for i, position in ipairs(farmPositions) do
            print(string.format("Moving to position %d/%d", i, #farmPositions))
            
            -- Tween to position
            local tweenSuccess = tweenToPosition(position)
            if not tweenSuccess then
                warn("Failed to tween to position")
                continue
            end
            
            -- Stabilize
            task.wait(0.5)
            
            -- Click center
            print("Clicking center screen...")
            clickCenterScreen()
            
            -- Equip next tool
            print("Equipping next egg tool...")
            local equipSuccess = equipNextEggTool()
            print(equipSuccess and "Tool equipped" or "No tool found")
            
            -- Wait before next position
            if i < #farmPositions then
                task.wait(1)
            end
        end
    else
        warn("No valid farm positions found")
    end
    
    -- Return home and reset camera
    print("Returning home...")
    tweenToPosition(homePosition)
    resetCamera()
    
    -- Wait for next cycle
    print(string.format("Waiting %.1f minutes for next cycle...", cycleDelay/60))
    wait(cycleDelay)
end
