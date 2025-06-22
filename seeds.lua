local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Backpack = LocalPlayer:WaitForChild("Backpack")

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
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.75, -200, 0.5, -150)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local StatsFrame = Instance.new("Frame")
StatsFrame.Name = "StatsFrame"
StatsFrame.Size = UDim2.new(0.5, -5, 1, -10)
StatsFrame.Position = UDim2.new(0, 5, 0, 5)
StatsFrame.BackgroundTransparency = 1
StatsFrame.Parent = MainFrame

local LogsFrame = Instance.new("Frame")
LogsFrame.Name = "LogsFrame"
LogsFrame.Size = UDim2.new(0.5, -5, 1, -10)
LogsFrame.Position = UDim2.new(0.5, 0, 0, 5)
LogsFrame.BackgroundTransparency = 1
LogsFrame.Parent = MainFrame

local LogsScroll = Instance.new("ScrollingFrame")
LogsScroll.Name = "LogsScroll"
LogsScroll.Size = UDim2.new(1, 0, 1, 0)
LogsScroll.BackgroundTransparency = 1
LogsScroll.ScrollBarThickness = 5
LogsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogsScroll.Parent = LogsFrame

local LogsLayout = Instance.new("UIListLayout")
LogsLayout.Name = "LogsLayout"
LogsLayout.Padding = UDim.new(0, 5)
LogsLayout.Parent = LogsScroll

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

local SeedsText = Instance.new("TextLabel")
SeedsText.Name = "SeedsText"
SeedsText.Size = UDim2.new(1, 0, 0, 15)
SeedsText.Position = UDim2.new(0, 0, 0, 45)
SeedsText.BackgroundTransparency = 1
SeedsText.Text = "Seeds: 0"
SeedsText.TextColor3 = Color3.fromRGB(200, 200, 200)
SeedsText.Font = Enum.Font.Gotham
SeedsText.TextSize = 12
SeedsText.TextXAlignment = Enum.TextXAlignment.Left
SeedsText.Parent = StatsFrame

local PlantsText = Instance.new("TextLabel")
PlantsText.Name = "PlantsText"
PlantsText.Size = UDim2.new(1, 0, 0, 15)
PlantsText.Position = UDim2.new(0, 0, 0, 60)
PlantsText.BackgroundTransparency = 1
PlantsText.Text = "Plants: 0"
PlantsText.TextColor3 = Color3.fromRGB(200, 200, 200)
PlantsText.Font = Enum.Font.Gotham
PlantsText.TextSize = 12
PlantsText.TextXAlignment = Enum.TextXAlignment.Left
PlantsText.Parent = StatsFrame

local PetsText = Instance.new("TextLabel")
PetsText.Name = "PetsText"
PetsText.Size = UDim2.new(1, 0, 0, 60)
PetsText.Position = UDim2.new(0, 0, 0, 75)
PetsText.BackgroundTransparency = 1
PetsText.Text = "Pets: None"
PetsText.TextColor3 = Color3.fromRGB(200, 200, 200)
PetsText.Font = Enum.Font.Gotham
PetsText.TextSize = 12
PetsText.TextXAlignment = Enum.TextXAlignment.Left
PetsText.TextYAlignment = Enum.TextYAlignment.Top
PetsText.Parent = StatsFrame

local TimeText = Instance.new("TextLabel")
TimeText.Name = "TimeText"
TimeText.Size = UDim2.new(1, 0, 0, 15)
TimeText.Position = UDim2.new(0, 0, 0, 135)
TimeText.BackgroundTransparency = 1
TimeText.Text = "Time: 0s"
TimeText.TextColor3 = Color3.fromRGB(200, 200, 200)
TimeText.Font = Enum.Font.Gotham
TimeText.TextSize = 12
TimeText.TextXAlignment = Enum.TextXAlignment.Left
TimeText.Parent = StatsFrame

local SeedsBoughtText = Instance.new("TextLabel")
SeedsBoughtText.Name = "SeedsBoughtText"
SeedsBoughtText.Size = UDim2.new(1, 0, 0, 15)
SeedsBoughtText.Position = UDim2.new(0, 0, 0, 150)
SeedsBoughtText.BackgroundTransparency = 1
SeedsBoughtText.Text = "Bought: 0"
SeedsBoughtText.TextColor3 = Color3.fromRGB(200, 200, 200)
SeedsBoughtText.Font = Enum.Font.Gotham
SeedsBoughtText.TextSize = 12
SeedsBoughtText.TextXAlignment = Enum.TextXAlignment.Left
SeedsBoughtText.Parent = StatsFrame

local MoneySpentText = Instance.new("TextLabel")
MoneySpentText.Name = "MoneySpentText"
MoneySpentText.Size = UDim2.new(1, 0, 0, 15)
MoneySpentText.Position = UDim2.new(0, 0, 0, 165)
MoneySpentText.BackgroundTransparency = 1
MoneySpentText.Text = "Spent: ¢0"
MoneySpentText.TextColor3 = Color3.fromRGB(200, 200, 200)
MoneySpentText.Font = Enum.Font.Gotham
MoneySpentText.TextSize = 12
MoneySpentText.TextXAlignment = Enum.TextXAlignment.Left
MoneySpentText.Parent = StatsFrame

local username = LocalPlayer.Name
local shortUsername = string.rep("*", #username - 5) .. (#username > 5 and string.sub(username, -5) or username)
local running = true
local startTime = os.time()
local totalSeedsBought = 0
local totalMoneySpent = 0
local lastSheckles = 0

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

local function getSheckles()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local sheckles = leaderstats:FindFirstChild("Sheckles") or leaderstats:FindFirstChild("sheckles")
        if sheckles then
            return sheckles.Value
        end
    end
    return 0
end

local function addLog(message)
    local logText = Instance.new("TextLabel")
    logText.Name = "LogText"
    logText.Size = UDim2.new(1, 0, 0, 15)
    logText.BackgroundTransparency = 1
    logText.Text = message
    logText.TextColor3 = Color3.fromRGB(255, 100, 100)
    logText.Font = Enum.Font.Gotham
    logText.TextSize = 12
    logText.TextXAlignment = Enum.TextXAlignment.Left
    logText.TextYAlignment = Enum.TextYAlignment.Top
    logText.Parent = LogsScroll
    
    while #LogsScroll:GetChildren() > 50 do
        LogsScroll:GetChildren()[2]:Destroy()
    end
end

local function updateUserInfo()
    UsernameText.Text = "User: " .. shortUsername
    local currentSheckles = getSheckles()
    ShecklesText.Text = "¢" .. tostring(currentSheckles)
    lastSheckles = currentSheckles
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

local function updateInventory()
    local seedCount = 0
    local plantCount = 0
    
    for _, item in ipairs(Backpack:GetChildren()) do
        if string.find(item.Name, "Seed") then
            local quantity = string.match(item.Name, "%[(%d+)%]")
            if quantity then
                seedCount = seedCount + tonumber(quantity)
            else
                seedCount = seedCount + 1
            end
        elseif string.find(item.Name, "kg") then
            plantCount = plantCount + 1
        end
    end
    
    SeedsText.Text = "Seeds: " .. seedCount
    PlantsText.Text = "Plants: " .. plantCount
end

local function updatePets()
    local ActivePetUI = PlayerGui:FindFirstChild("ActivePetUI")
    if not ActivePetUI then return end
    
    local Frame = ActivePetUI:FindFirstChild("Frame")
    if not Frame then return end
    
    local Main = Frame:FindFirstChild("Main")
    if not Main then return end
    
    local ScrollingFrame = Main:FindFirstChild("ScrollingFrame")
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

local function updateStats()
    TimeText.Text = "Time: " .. os.time() - startTime .. "s"
    SeedsBoughtText.Text = "Bought: " .. totalSeedsBought
    MoneySpentText.Text = "Spent: ¢" .. totalMoneySpent
end

local function buyItem(itemName, isSeed)
    local buyEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild(isSeed and "BuySeedStock" or "BuyGearStock")
    local beforeSheckles = getSheckles()
    buyEvent:FireServer(itemName)
    
    task.wait(0.5)
    
    local afterSheckles = getSheckles()
    local difference = beforeSheckles - afterSheckles
    
    if difference > 0 then
        if isSeed then
            totalSeedsBought = totalSeedsBought + 5
            totalMoneySpent = totalMoneySpent + difference
        end
        addLog(itemName .. ": -¢" .. difference)
        return true
    end
    
    return false
end

local function buySeeds()
    while running do
        for _, seedName in ipairs(BuyPlants) do
            if not running then break end
            
            local success = buyItem(seedName, true)
            if not success then
                task.wait(0.1)
            else
                for i = 1, 4 do
                    if not running then break end
                    buyItem(seedName, true)
                    task.wait(0.1)
                end
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
            buyItem("Trowel", false)
        end
    end
end

spawn(buySeeds)
spawn(buyTrowelLoop)

while true do
    updateUserInfo()
    updateWeather()
    updateInventory()
    updatePets()
    updateStats()
    task.wait(5)
end
