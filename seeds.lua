local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local BuyPlants = {
    "Green Apple",
    "Avocado",
    "Banana",
    "Pineapple",
    "Kiwi",
    "Bell Pepper",
    "Prickly Pear",
    "Loquat",
    "Sugar Apple",
    "Feijoa"
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JamexStats"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 150)
MainFrame.Position = UDim2.new(0.75, -100, 0.5, -75)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local StatsFrame = Instance.new("Frame")
StatsFrame.Name = "StatsFrame"
StatsFrame.Size = UDim2.new(1, -10, 1, -10)
StatsFrame.Position = UDim2.new(0, 5, 0, 5)
StatsFrame.BackgroundTransparency = 1
StatsFrame.Parent = MainFrame

local UsernameText = Instance.new("TextLabel")
UsernameText.Name = "UsernameText"
UsernameText.Size = UDim2.new(1, 0, 0, 15)
UsernameText.BackgroundTransparency = 1
UsernameText.Text = "User: ..."
UsernameText.TextColor3 = Color3.fromRGB(200, 200, 200)
UsernameText.Font = Enum.Font.Gotham
UsernameText.TextSize = 12
UsernameText.TextXAlignment = Enum.TextXAlignment.Left
UsernameText.Parent = StatsFrame

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
ShecklesText.Parent = StatsFrame

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
WeatherText.Parent = StatsFrame

local PetsText = Instance.new("TextLabel")
PetsText.Name = "PetsText"
PetsText.Size = UDim2.new(1, 0, 0, 60)
PetsText.Position = UDim2.new(0, 0, 0, 45)
PetsText.BackgroundTransparency = 1
PetsText.Text = "Pets: None"
PetsText.TextColor3 = Color3.fromRGB(200, 200, 200)
PetsText.Font = Enum.Font.Gotham
PetsText.TextSize = 12
PetsText.TextXAlignment = Enum.TextXAlignment.Left
PetsText.TextYAlignment = Enum.TextYAlignment.Top
PetsText.Parent = StatsFrame

local username = LocalPlayer.Name
local shortUsername = string.rep("*", #username - 5) .. (#username > 5 and string.sub(username, -5) or username)
local running = true

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
    local BottomUI = PlayerGui:WaitForChild("Bottom_UI"):WaitForChild("BottomFrame"):WaitForChild("Holder"):WaitForChild("List")
    local activeWeather = {}
    for _, child in ipairs(BottomUI:GetChildren()) do
        if (child:IsA("Frame") or child:IsA("ImageButton")) and child.Visible then
            table.insert(activeWeather, formatWeatherName(child.Name))
        end
    end
    WeatherText.Text = #activeWeather > 0 and "Weather: " .. table.concat(activeWeather, ", ") or "Weather: None"
end

local function updatePets()
    local ActivePetUI = PlayerGui:WaitForChild("ActivePetUI")
    if not ActivePetUI then return end
    
    local Frame = ActivePetUI:WaitForChild("Frame")
    if not Frame then return end
    
    local Main = Frame:WaitForChild("Main")
    if not Main then return end
    
    local ScrollingFrame = Main:WaitForChild("ScrollingFrame")
    if not ScrollingFrame then return end
    
    local pets = {}
    for _, child in ipairs(ScrollingFrame:GetChildren()) do
        if string.find(child.Name, "{") == 1 then
            local petType = child:FindFirstChild("PET_TYPE")
            local petName = child:FindFirstChild("PET_NAME")
            local petAge = child:FindFirstChild("PET_AGE")
            
            if petType and petName and petAge then
                table.insert(pets, petType.Text .. ": " .. petName.Text .. " (" .. petAge.Text .. ")")
            end
        end
    end
    
    PetsText.Text = #pets > 0 and "Pets:\n" .. table.concat(pets, "\n") or "Pets: None"
end

local function buySeeds()
    local buySeedEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuySeedStock")
    while running do
        for _, seedName in ipairs(BuyPlants) do
            if not running then break end
            for i = 1, 5 do
                if not running then break end
                buySeedEvent:FireServer(seedName)
                task.wait(0.5)
            end
        end
        if not running then break end
        task.wait(1)
    end
end

local function buyTrowelLoop()
    while true do
        task.wait(60)
        if running then
            local buyGearEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyGearStock")
            buyGearEvent:FireServer("Trowel")
        end
    end
end

spawn(buySeeds)
spawn(buyTrowelLoop)

while true do
    updateUserInfo()
    updateWeather()
    updatePets()
    task.wait(5)
end
