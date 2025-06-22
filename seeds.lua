local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local TeleportUI = PlayerGui:WaitForChild("Teleport_UI"):WaitForChild("Frame")
local SeedShopUI = PlayerGui:WaitForChild("Seed_Shop"):WaitForChild("Frame"):WaitForChild("ScrollingFrame")
local BottomUI = PlayerGui:WaitForChild("Bottom_UI"):WaitForChild("BottomFrame"):WaitForChild("Holder"):WaitForChild("List")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JamexSeedScript"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 120)
MainFrame.Position = UDim2.new(0.5, -100, 0, 10)
MainFrame.AnchorPoint = Vector2.new(0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local UserInfo = Instance.new("Frame")
UserInfo.Name = "UserInfo"
UserInfo.Size = UDim2.new(1, -10, 0, 40)
UserInfo.Position = UDim2.new(0, 5, 0, 5)
UserInfo.BackgroundTransparency = 1
UserInfo.Parent = MainFrame

local UsernameText = Instance.new("TextLabel")
UsernameText.Name = "UsernameText"
UsernameText.Size = UDim2.new(1, 0, 0, 15)
UsernameText.BackgroundTransparency = 1
UsernameText.Text = "User: ..."
UsernameText.TextColor3 = Color3.fromRGB(200, 200, 200)
UsernameText.Font = Enum.Font.Gotham
UsernameText.TextSize = 12
UsernameText.TextXAlignment = Enum.TextXAlignment.Left
UsernameText.Parent = UserInfo

local ShecklesText = Instance.new("TextLabel")
ShecklesText.Name = "ShecklesText"
ShecklesText.Size = UDim2.new(1, 0, 0, 15)
ShecklesText.Position = UDim2.new(0, 0, 0, 15)
ShecklesText.BackgroundTransparency = 1
ShecklesText.Text = "¢0"
ShecklesText.TextColor3 = Color3.fromRGB(255, 215, 0)
ShecklesText.Font = Enum.Font.GothamBold
ShecklesText.TextSize = 12
ShecklesText.TextXAlignment = Enum.TextXAlignment.Left
ShecklesText.Parent = UserInfo

local WeatherText = Instance.new("TextLabel")
WeatherText.Name = "WeatherText"
WeatherText.Size = UDim2.new(1, 0, 0, 15)
WeatherText.Position = UDim2.new(0, 0, 0, 30)
WeatherText.BackgroundTransparency = 1
WeatherText.Text = "Weather: None"
WeatherText.TextColor3 = Color3.fromRGB(200, 200, 200)
WeatherText.Font = Enum.Font.Gotham
WeatherText.TextSize = 12
WeatherText.TextXAlignment = Enum.TextXAlignment.Left
WeatherText.Parent = UserInfo

local ControlFrame = Instance.new("Frame")
ControlFrame.Name = "ControlFrame"
ControlFrame.Size = UDim2.new(1, -10, 0, 70)
ControlFrame.Position = UDim2.new(0, 5, 0, 50)
ControlFrame.BackgroundTransparency = 1
ControlFrame.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(1, 0, 0, 20)
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
RefreshButton.Size = UDim2.new(1, 0, 0, 20)
RefreshButton.Position = UDim2.new(0, 0, 0, 25)
RefreshButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
RefreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshButton.Font = Enum.Font.Gotham
RefreshButton.TextSize = 12
RefreshButton.Text = "Refresh"
RefreshButton.Parent = ControlFrame

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 6)
RefreshCorner.Parent = RefreshButton

local DropdownToggle = Instance.new("TextButton")
DropdownToggle.Name = "DropdownToggle"
DropdownToggle.Size = UDim2.new(1, 0, 0, 20)
DropdownToggle.Position = UDim2.new(0, 0, 0, 50)
DropdownToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
DropdownToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
DropdownToggle.Font = Enum.Font.Gotham
DropdownToggle.TextSize = 12
DropdownToggle.Text = "Toggle Dropdown"
DropdownToggle.Parent = TeleportUI

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(0, 6)
DropdownCorner.Parent = DropdownToggle

local StatsToggle = Instance.new("TextButton")
StatsToggle.Name = "StatsToggle"
StatsToggle.Size = UDim2.new(0, 100, 0, 20)
StatsToggle.Position = UDim2.new(0, 10, 0, 10)
StatsToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
StatsToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsToggle.Font = Enum.Font.Gotham
StatsToggle.TextSize = 12
StatsToggle.Text = "Toggle Stats"
StatsToggle.Parent = TeleportUI

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 6)
StatsCorner.Parent = StatsToggle

local seedButtons = {}
local selectedSeeds = {}
local running = false
local username = LocalPlayer.Name
local shortUsername = string.rep("*", #username - 5) .. (#username > 5 and string.sub(username, -5) or username)

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

local function updateWeather()
    local activeWeather = {}
    for _, child in ipairs(BottomUI:GetChildren()) do
        if (child:IsA("Frame") or child:IsA("ImageButton")) and child.Visible then
            table.insert(activeWeather, formatWeatherName(child.Name))
        end
    end
    WeatherText.Text = #activeWeather > 0 and "Weather: " .. table.concat(activeWeather, ", ") or "Weather: None"
end

local function getSeeds()
    local seeds = {}
    for _, child in ipairs(SeedShopUI:GetChildren()) do
        if not string.find(child.Name, "_") and not string.find(child.Name:upper(), "UI") then
            table.insert(seeds, child.Name)
        end
    end
    return seeds
end

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
        seedButton.Parent = MainFrame
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

local function buyTrowelLoop()
    while true do
        wait(60)
        if running then
            local buyGearEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyGearStock")
            buyGearEvent:FireServer("Trowel")
        end
    end
end

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

RefreshButton.MouseButton1Click:Connect(function()
    createSeedButtons()
    updateUserInfo()
    updateWeather()
end)

DropdownToggle.MouseButton1Click:Connect(function()
    TeleportUI.Visible = not TeleportUI.Visible
end)

StatsToggle.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

createSeedButtons()
updateUserInfo()
updateWeather()
spawn(buyTrowelLoop)

while true do
    wait(5)
    updateUserInfo()
    updateWeather()
end
