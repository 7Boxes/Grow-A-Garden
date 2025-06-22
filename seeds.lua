local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Backpack = LocalPlayer:WaitForChild("Backpack")
local UserInputService = game:GetService("UserInputService")

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
ScreenGui.Name = "JamexProfessionalUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, -20, 1, -20)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 8)
TopBarCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "JAMEX FARMING SUITE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 100, 1, 0)
MinimizeButton.Position = UDim2.new(1, -100, 0, 0)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.Gotham
MinimizeButton.TextSize = 12
MinimizeButton.Text = "Minimize"
MinimizeButton.Parent = TopBar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeButton

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -50)
ContentFrame.Position = UDim2.new(0, 10, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local StatsFrame = Instance.new("Frame")
StatsFrame.Name = "StatsFrame"
StatsFrame.Size = UDim2.new(0.3, -10, 1, 0)
StatsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
StatsFrame.Parent = ContentFrame

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 8)
StatsCorner.Parent = StatsFrame

local StatsScroll = Instance.new("ScrollingFrame")
StatsScroll.Name = "StatsScroll"
StatsScroll.Size = UDim2.new(1, 0, 1, 0)
StatsScroll.BackgroundTransparency = 1
StatsScroll.ScrollBarThickness = 5
StatsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
StatsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
StatsScroll.Parent = StatsFrame

local StatsLayout = Instance.new("UIListLayout")
StatsLayout.Name = "StatsLayout"
StatsLayout.Padding = UDim.new(0, 10)
StatsLayout.Parent = StatsScroll

local LogsFrame = Instance.new("Frame")
LogsFrame.Name = "LogsFrame"
LogsFrame.Size = UDim2.new(0.7, -10, 0.5, -5)
LogsFrame.Position = UDim2.new(0.3, 10, 0, 0)
LogsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LogsFrame.Parent = ContentFrame

local LogsCorner = Instance.new("UICorner")
LogsCorner.CornerRadius = UDim.new(0, 8)
LogsCorner.Parent = LogsFrame

local LogsTitle = Instance.new("TextLabel")
LogsTitle.Name = "LogsTitle"
LogsTitle.Size = UDim2.new(1, 0, 0, 30)
LogsTitle.BackgroundTransparency = 1
LogsTitle.Text = "PURCHASE LOGS"
LogsTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
LogsTitle.Font = Enum.Font.GothamBold
LogsTitle.TextSize = 14
LogsTitle.Parent = LogsFrame

local LogsScroll = Instance.new("ScrollingFrame")
LogsScroll.Name = "LogsScroll"
LogsScroll.Size = UDim2.new(1, -10, 1, -40)
LogsScroll.Position = UDim2.new(0, 5, 0, 35)
LogsScroll.BackgroundTransparency = 1
LogsScroll.ScrollBarThickness = 5
LogsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogsScroll.Parent = LogsFrame

local LogsLayout = Instance.new("UIListLayout")
LogsLayout.Name = "LogsLayout"
LogsLayout.Padding = UDim.new(0, 5)
LogsLayout.Parent = LogsScroll

local PetsFrame = Instance.new("Frame")
PetsFrame.Name = "PetsFrame"
PetsFrame.Size = UDim2.new(0.7, -10, 0.5, -5)
PetsFrame.Position = UDim2.new(0.3, 10, 0.5, 5)
PetsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
PetsFrame.Parent = ContentFrame

local PetsCorner = Instance.new("UICorner")
PetsCorner.CornerRadius = UDim.new(0, 8)
PetsCorner.Parent = PetsFrame

local PetsTitle = Instance.new("TextLabel")
PetsTitle.Name = "PetsTitle"
PetsTitle.Size = UDim2.new(1, 0, 0, 30)
PetsTitle.BackgroundTransparency = 1
PetsTitle.Text = "PET STATUS"
PetsTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
PetsTitle.Font = Enum.Font.GothamBold
PetsTitle.TextSize = 14
PetsTitle.Parent = PetsFrame

local PetsScroll = Instance.new("ScrollingFrame")
PetsScroll.Name = "PetsScroll"
PetsScroll.Size = UDim2.new(1, -10, 1, -40)
PetsScroll.Position = UDim2.new(0, 5, 0, 35)
PetsScroll.BackgroundTransparency = 1
PetsScroll.ScrollBarThickness = 5
PetsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
PetsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PetsScroll.Parent = PetsFrame

local PetsLayout = Instance.new("UIListLayout")
PetsLayout.Name = "PetsLayout"
PetsLayout.Padding = UDim.new(0, 5)
PetsLayout.Parent = PetsScroll

local function createStatLabel(name)
    local frame = Instance.new("Frame")
    frame.Name = name .. "Frame"
    frame.Size = UDim2.new(1, 0, 0, 20)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Name = name .. "Label"
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name .. ":"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local value = Instance.new("TextLabel")
    value.Name = name .. "Value"
    value.Size = UDim2.new(0.5, 0, 1, 0)
    value.Position = UDim2.new(0.5, 0, 0, 0)
    value.BackgroundTransparency = 1
    value.Text = "0"
    value.TextColor3 = Color3.fromRGB(255, 255, 255)
    value.Font = Enum.Font.GothamBold
    value.TextSize = 12
    value.TextXAlignment = Enum.TextXAlignment.Right
    value.Parent = frame
    
    frame.Parent = StatsScroll
    return value
end

local UsernameValue = createStatLabel("User")
local ShecklesValue = createStatLabel("Sheckles")
local WeatherValue = createStatLabel("Weather")
local SeedsValue = createStatLabel("Seeds")
local PlantsValue = createStatLabel("Plants")
local TimeValue = createStatLabel("Runtime")
local BoughtValue = createStatLabel("Bought")
local SpentValue = createStatLabel("Spent")

local username = LocalPlayer.Name
local shortUsername = string.rep("*", #username - 5) .. (#username > 5 and string.sub(username, -5) or username)
local running = true
local minimized = false
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
    logText.Size = UDim2.new(1, 0, 0, 20)
    logText.BackgroundTransparency = 1
    logText.Text = "> " .. message
    logText.TextColor3 = Color3.fromRGB(255, 120, 120)
    logText.Font = Enum.Font.Gotham
    logText.TextSize = 12
    logText.TextXAlignment = Enum.TextXAlignment.Left
    logText.TextYAlignment = Enum.TextYAlignment.Top
    logText.Parent = LogsScroll
    
    while #LogsScroll:GetChildren() > 50 do
        LogsScroll:GetChildren()[2]:Destroy()
    end
end

local function addPet(petInfo)
    local petText = Instance.new("TextLabel")
    petText.Name = "PetText"
    petText.Size = UDim2.new(1, 0, 0, 20)
    petText.BackgroundTransparency = 1
    petText.Text = petInfo
    petText.TextColor3 = Color3.fromRGB(200, 200, 255)
    petText.Font = Enum.Font.Gotham
    petText.TextSize = 12
    petText.TextXAlignment = Enum.TextXAlignment.Left
    petText.TextYAlignment = Enum.TextYAlignment.Top
    petText.Parent = PetsScroll
end

local function updateUserInfo()
    UsernameValue.Text = shortUsername
    local currentSheckles = getSheckles()
    ShecklesValue.Text = "¢" .. tostring(currentSheckles)
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
    WeatherValue.Text = #activeWeather > 0 and table.concat(activeWeather, ", ") or "None"
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
    
    SeedsValue.Text = seedCount
    PlantsValue.Text = plantCount
end

local function updatePets()
    for _, child in ipairs(PetsScroll:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    local ActivePetUI = PlayerGui:FindFirstChild("ActivePetUI")
    if not ActivePetUI then
        addPet("No pets active")
        return
    end
    
    local Frame = ActivePetUI:FindFirstChild("Frame")
    if not Frame then
        addPet("No pets active")
        return
    end
    
    local Main = Frame:FindFirstChild("Main")
    if not Main then
        addPet("No pets active")
        return
    end
    
    local ScrollingFrame = Main:FindFirstChild("ScrollingFrame")
    if not ScrollingFrame then
        addPet("No pets active")
        return
    end
    
    local pets = {}
    for _, child in ipairs(ScrollingFrame:GetChildren()) do
        if string.find(child.Name, "{") == 1 then
            local petType = child:FindFirstChild("PET_TYPE")
            local petName = child:FindFirstChild("PET_NAME")
            local petAge = child:FindFirstChild("PET_AGE")
            
            if petType and petName and petAge then
                addPet(petType.Text .. ": " .. petName.Text .. " (" .. petAge.Text .. ")")
            end
        end
    end
    
    if #PetsScroll:GetChildren() == 1 then
        addPet("No pets active")
    end
end

local function updateStats()
    TimeValue.Text = os.time() - startTime .. "s"
    BoughtValue.Text = totalSeedsBought
    SpentValue.Text = "¢" .. totalMoneySpent
end

local function toggleUI()
    minimized = not minimized
    if minimized then
        MainFrame.Visible = false
        MinimizeButton.Text = "Maximize"
    else
        MainFrame.Visible = true
        MinimizeButton.Text = "Minimize"
    end
end

MinimizeButton.MouseButton1Click:Connect(toggleUI)

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

local function handleResize()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local padding = math.min(20, viewportSize.X * 0.02, viewportSize.Y * 0.02)
    MainFrame.Size = UDim2.new(1, -padding * 2, 1, -padding * 2)
end

handleResize()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(handleResize)

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
