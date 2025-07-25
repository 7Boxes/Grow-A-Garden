local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "JMXScript - Dino DNA Lab",
   LoadingTitle = "JMXScript is loading...",
   LoadingSubtitle = "by jamex",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "JMXScript",
      FileName = "DinoLabConfig"
   },
   KeySystem = false,
})

local MainTab = Window:CreateTab("Main", "dna")

local stats = {
    petsUsed = 0,
    eggsGained = 0,
    lastPosition = nil
}

if Rayfield:LoadConfiguration() then
    local config = Rayfield.Flags
    stats.petsUsed = config.PetsUsed.CurrentValue or 0
    stats.eggsGained = config.EggsGained.CurrentValue or 0
    stats.lastPosition = config.LastPosition.CurrentValue or nil
end

local player = game:GetService("Players").LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = char:WaitForChild("HumanoidRootPart")

local function getRemote(name)
    local remote
    local attempts = 0
    repeat
        remote = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):FindFirstChild(name)
        if not remote then wait(1) end
        attempts = attempts + 1
    until remote or attempts >= 5
    return remote
end

local interactRemote = getRemote("DinoMachineService_RE")
local claimRemote = getRemote("DinoMachineService_RE")

local function getPetNames()
    local backpack = player:WaitForChild("Backpack")
    local petNames = {}
    local petDetails = {}
    
    for _, item in ipairs(backpack:GetChildren()) do
        if item.Name:find("Age") then
            local cleanName = item.Name:gsub("%[.+%]", ""):gsub("%s+$", "")
            local weight = tonumber(item.Name:match("%[([%d%.]+) KG%]")) or 0
            local age = tonumber(item.Name:match("Age (%d+)")) or 0
            
            if not petNames[cleanName] then
                petNames[cleanName] = true
                table.insert(petDetails, {
                    name = cleanName,
                    object = item,
                    weight = weight,
                    age = age
                })
            else
                for _, pet in ipairs(petDetails) do
                    if pet.name == cleanName then
                        if age < pet.age or (age == pet.age and weight < pet.weight) then
                            pet.object = item
                            pet.weight = weight
                            pet.age = age
                        end
                        break
                    end
                end
            end
        end
    end
    
    return petDetails
end

local selectedPets = {}
local grindEnabled = false

local StatsSection = MainTab:CreateSection("Statistics")
local PetsUsedLabel = MainTab:CreateLabel("Pets Used: "..stats.petsUsed)
local EggsGainedLabel = MainTab:CreateLabel("Eggs Gained: "..stats.eggsGained)

local petOptions = {}
local petList = getPetNames()
for _, pet in ipairs(petList) do
    table.insert(petOptions, pet.name)
end

local PetDropdown = MainTab:CreateDropdown({
   Name = "Select Pets",
   Options = petOptions,
   CurrentOption = {},
   MultipleOptions = true,
   Flag = "SelectedPets",
   Callback = function(Options)
        selectedPets = Options
   end,
})

local PositionSection = MainTab:CreateSection("Position")
local SetPositionButton = MainTab:CreateButton({
   Name = "Save Current Position",
   Callback = function()
        stats.lastPosition = humanoidRootPart.Position
        Rayfield.Flags.LastPosition.CurrentValue = stats.lastPosition
        Rayfield:Notify({
            Title = "Position Saved",
            Content = "Current position has been saved!",
            Duration = 3,
            Image = "map-pin",
        })
   end,
})

local TeleportButton = MainTab:CreateButton({
   Name = "Teleport to Saved Position",
   Callback = function()
        if stats.lastPosition then
            humanoidRootPart.CFrame = CFrame.new(stats.lastPosition)
            Rayfield:Notify({
                Title = "Teleported",
                Content = "Returned to saved position!",
                Duration = 3,
                Image = "map-pin",
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "No position saved!",
                Duration = 3,
                Image = "alert-circle",
            })
        end
   end,
})

local GrindToggle = MainTab:CreateToggle({
   Name = "Grind Dino Eggs",
   CurrentValue = false,
   Flag = "GrindEnabled",
   Callback = function(Value)
        grindEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Grinding Started",
                Content = "Dino egg grinding has been enabled!",
                Duration = 3,
                Image = "zap",
            })
        else
            Rayfield:Notify({
                Title = "Grinding Stopped",
                Content = "Dino egg grinding has been disabled!",
                Duration = 3,
                Image = "zap-off",
            })
        end
   end,
})

local function processPet()
    if not grindEnabled then return end
    if #selectedPets == 0 then
        Rayfield:Notify({
            Title = "No Pets Selected",
            Content = "Please select pets to use!",
            Duration = 3,
            Image = "alert-circle",
        })
        return
    end
    
    local eligiblePets = {}
    local petList = getPetNames()
    
    for _, pet in ipairs(petList) do
        for _, selected in ipairs(selectedPets) do
            if pet.name == selected then
                table.insert(eligiblePets, pet)
                break
            end
        end
    end
    
    if #eligiblePets == 0 then return end
    
    local selectedPet = eligiblePets[math.random(1, #eligiblePets)]
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    
    if humanoid then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                tool.Parent = player.Backpack
            end
        end
        
        selectedPet.object.Parent = char
        humanoid:EquipTool(selectedPet.object)
        
        wait(1)
        
        if interactRemote then
            interactRemote:FireServer("MachineInteract")
            stats.petsUsed = stats.petsUsed + 1
            PetsUsedLabel:Set("Pets Used: "..stats.petsUsed)
            Rayfield.Flags.PetsUsed.CurrentValue = stats.petsUsed
            
            Rayfield:Notify({
                Title = "DNA Lab Used",
                Content = "Used "..selectedPet.name.." at the Dino DNA Lab!",
                Duration = 3,
                Image = "dna",
            })
        end
        
        local initialEggCount = 0
        for _, item in ipairs(player.Backpack:GetChildren()) do
            if item.Name:find("Dinosaur Egg") then
                initialEggCount = tonumber(item.Name:match("x(%d+)")) or 1
                break
            end
        end
        
        spawn(function()
            wait(3600)
            
            if claimRemote then
                repeat
                    claimRemote:FireServer("ClaimReward")
                    wait(5)
                    
                    local newEggCount = 0
                    for _, item in ipairs(player.Backpack:GetChildren()) do
                        if item.Name:find("Dinosaur Egg") then
                            newEggCount = tonumber(item.Name:match("x(%d+)")) or 1
                            break
                        end
                    end
                    
                    if newEggCount > initialEggCount then
                        stats.eggsGained = stats.eggsGained + (newEggCount - initialEggCount)
                        EggsGainedLabel:Set("Eggs Gained: "..stats.eggsGained)
                        Rayfield.Flags.EggsGained.CurrentValue = stats.eggsGained
                        
                        Rayfield:Notify({
                            Title = "Success!",
                            Content = "Claimed a new Dino Egg!",
                            Duration = 3,
                            Image = "egg",
                        })
                    end
                until newEggCount > initialEggCount or not grindEnabled
            end
        end)
    end
end

spawn(function()
    while true do
        wait(60)
        local newPetOptions = {}
        local petList = getPetNames()
        for _, pet in ipairs(petList) do
            table.insert(newPetOptions, pet.name)
        end
        PetDropdown:Refresh(newPetOptions)
    end
end)

spawn(function()
    while true do
        if grindEnabled then
            processPet()
            wait(10)
        else
            wait(1)
        end
    end
end)

Rayfield:LoadConfiguration()
