local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Create main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SeedAutoBuyer"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Jamex Seed Script"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.Parent = TitleBar

-- User info
local UserInfo = Instance.new("Frame")
UserInfo.Name = "UserInfo"
UserInfo.Size = UDim2.new(1, -20, 0, 30)
UserInfo.Position = UDim2.new(0, 10, 0, 35)
UserInfo.BackgroundTransparency = 1
UserInfo.Parent = MainFrame

local UsernameText = Instance.new("TextLabel")
UsernameText.Name = "UsernameText"
UsernameText.Size = UDim2.new(0.5, 0, 1, 0)
UsernameText.BackgroundTransparency = 1
UsernameText.Text = "User: ..."
UsernameText.TextColor3 = Color3.fromRGB(200, 200, 200)
UsernameText.Font = Enum.Font.Gotham
UsernameText.TextSize = 12
UsernameText.TextXAlignment = Enum.TextXAlignment.Left
UsernameText.Parent = UserInfo

local ShecklesText = Instance.new("TextLabel")
ShecklesText.Name = "ShecklesText"
ShecklesText.Size = UDim2.new(0.5, 0, 1, 0)
ShecklesText.Position = UDim2.new(0.5, 0, 0, 0)
ShecklesText.BackgroundTransparency = 1
ShecklesText.Text = "¢0"
ShecklesText.TextColor3 = Color3.fromRGB(255, 215, 0)
ShecklesText.Font = Enum.Font.GothamBold
ShecklesText.TextSize = 12
ShecklesText.TextXAlignment = Enum.TextXAlignment.Right
ShecklesText.Parent = UserInfo

-- Weather info
local WeatherFrame = Instance.new("Frame")
WeatherFrame.Name = "WeatherFrame"
WeatherFrame.Size = UDim2.new(1, -20, 0, 30)
WeatherFrame.Position = UDim2.new(0, 10, 0, 70)
WeatherFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
WeatherFrame.Parent = MainFrame

local WeatherCorner = Instance.new("UICorner")
WeatherCorner.CornerRadius = UDim.new(0, 6)
WeatherCorner.Parent = WeatherFrame

local WeatherText = Instance.new("TextLabel")
WeatherText.Name = "WeatherText"
WeatherText.Size = UDim2.new(1, -10, 1, 0)
WeatherText.Position = UDim2.new(0, 5, 0, 0)
WeatherText.BackgroundTransparency = 1
WeatherText.Text = "Weather: None"
WeatherText.TextColor3 = Color3.fromRGB(200, 200, 200)
WeatherText.Font = Enum.Font.Gotham
WeatherText.TextSize = 12
WeatherText.TextXAlignment = Enum.TextXAlignment.Left
WeatherText.Parent = WeatherFrame

-- Seeds list
local SeedsScroll = Instance.new("ScrollingFrame")
SeedsScroll.Name = "SeedsScroll"
SeedsScroll.Size = UDim2.new(1, -20, 0, 250)
SeedsScroll.Position = UDim2.new(0, 10, 0, 110)
SeedsScroll.BackgroundTransparency = 1
SeedsScroll.ScrollBarThickness = 5
SeedsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
SeedsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SeedsScroll.Parent = MainFrame

local SeedsListLayout = Instance.new("UIListLayout")
SeedsListLayout.Name = "SeedsListLayout"
SeedsListLayout.Padding = UDim.new(0, 5)
SeedsListLayout.Parent = SeedsScroll

-- Control buttons
local ControlFrame = Instance.new("Frame")
ControlFrame.Name = "ControlFrame"
ControlFrame.Size = UDim2.new(1, -20, 0, 30)
ControlFrame.Position = UDim2.new(0, 10, 1, -40)
ControlFrame.BackgroundTransparency = 1
ControlFrame.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0.5, -5, 1, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.Gotham
ToggleButton.TextSize = 12
ToggleButton.Text = "Start"
ToggleButton.Parent = ControlFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleButton

local RefreshButton = Instance.new("TextButton")
RefreshButton.Name = "RefreshButton"
RefreshButton.Size = UDim2.new(0.5, -5, 1, 0)
RefreshButton.Position = UDim2.new(0.5, 5, 0, 0)
RefreshButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
RefreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshButton.Font = Enum.Font.Gotham
RefreshButton.TextSize = 12
RefreshButton.Text = "Refresh"
RefreshButton.Parent = ControlFrame

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 6)
RefreshCorner.Parent = RefreshButton

-- Variables
local seedButtons = {}
local selectedSeeds = {}
local running = false
local username = LocalPlayer.Name
local shortUsername = string.rep("*", #username - 5) .. (#username > 5 and string.sub(username, -5) or username)

-- Format weather name
local function formatWeatherName(name)
    local result = ""
    for i = 1, #name do
        local c = name:sub(i,i)
        if i > 1 and c:match("%u") then
            result = result .. " " .. c
        else
            result = result .. c
        end
    end
    return result
end

-- Update user info
local function updateUserInfo()
    UsernameText.Text = "User: " .. shortUsername
    
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local sheckles = leaderstats:FindFirstChild("Sheckles") or leaderstats:FindFirstChild("sheckles")
        if sheckles then
            ShecklesText.Text = "¢" .. tostring(sheckles.Value)
        end
    end
end

-- Update weather info
local function updateWeather()
    local weatherFrame = PlayerGui:WaitForChild("Bottom_UI"):WaitForChild("BottomFrame"):WaitForChild("Holder"):WaitForChild("List")
    local activeWeather = {}
    
    for _, child in ipairs(weatherFrame:GetChildren()) do
        if (child:IsA("Frame") or child:IsA("ImageButton")) and child.Visible then
            table.insert(activeWeather, formatWeatherName(child.Name))
        end
    end
    
    WeatherText.Text = #activeWeather > 0 and "Weather: " .. table.concat(activeWeather, ", ") or "Weather: None"
end

-- Get seeds from the shop
local function getSeeds()
    local seedShop = PlayerGui:WaitForChild("Seed_Shop"):WaitForChild("Frame"):WaitForChild("ScrollingFrame")
    local seeds = {}
    
    for _, child in ipairs(seedShop:GetChildren()) do
        if not string.find(child.Name, "_") and not string.find(child.Name:upper(), "UI") then
            table.insert(seeds, child.Name)
        end
    end
    
    return seeds
end

-- Create seed buttons
local function createSeedButtons()
    for _, button in ipairs(seedButtons) do
        button:Destroy()
    end
    seedButtons = {}
    
    local seeds = getSeeds()
    table.sort(seeds)
    
    for _, seedName in ipairs(seeds) do
        local seedButton = Instance.new("TextButton")
        seedButton.Name = seedName .. "Button"
        seedButton.Size = UDim2.new(1, 0, 0, 30)
        seedButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        seedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        seedButton.Font = Enum.Font.Gotham
        seedButton.TextSize = 12
        seedButton.Text = seedName
        seedButton.AutoButtonColor = false
        seedButton.Parent = SeedsScroll
        
        local seedCorner = Instance.new("UICorner")
        seedCorner.CornerRadius = UDim.new(0, 6)
        seedCorner.Parent = seedButton
        
        seedButton.MouseButton1Click:Connect(function()
            if selectedSeeds[seedName] then
                selectedSeeds[seedName] = nil
                seedButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            else
                selectedSeeds[seedName] = true
                seedButton.BackgroundColor3 = Color3.fromRGB(80, 120, 80)
            end
        end)
        
        table.insert(seedButtons, seedButton)
    end
end

-- Buy seeds
local function buySeeds()
    local buySeedEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuySeedStock")
    
    while running do
        for seedName, _ in pairs(selectedSeeds) do
            if not running then break end
            
            for i = 1, 5 do
                if not running then break end
                buySeedEvent:FireServer(seedName)
                wait(0.5)
            end
        end
        
        if not running then break end
        wait(1)
    end
end

-- Buy trowel once a minute
local function buyTrowelLoop()
    while true do
        wait(60)
        if running then
            local buyGearEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyGearStock")
            buyGearEvent:FireServer("Trowel")
        end
    end
end

-- Toggle button click
ToggleButton.MouseButton1Click:Connect(function()
    running = not running
    
    if running then
        ToggleButton.Text = "Stop"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(120, 80, 80)
        spawn(buySeeds)
    else
        ToggleButton.Text = "Start"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end
end)

-- Refresh button click
RefreshButton.MouseButton1Click:Connect(function()
    createSeedButtons()
    updateUserInfo()
    updateWeather()
end)

-- Make UI responsive
local function updateUIScale()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local scale = math.min(1, viewportSize.X / 1200, viewportSize.Y / 800)
    
    MainFrame.Size = UDim2.new(0, 300 * scale, 0, 400 * scale)
    MainFrame.Position = UDim2.new(0.5, -150 * scale, 0.5, -200 * scale)
end

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateUIScale)
updateUIScale()

-- Initialize
createSeedButtons()
updateUserInfo()
updateWeather()

-- Start trowel loop
spawn(buyTrowelLoop)

-- Update info periodically
while true do
    wait(5)
    updateUserInfo()
    updateWeather()
end
