local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Get version text from PlayerGui
local versionText = "Unknown Version"
local success, err = pcall(function()
    versionText = game:GetService("Players").LocalPlayer.PlayerGui.Version_UI.Version.Text
end)

-- Create the window with version in title
local Window = Rayfield:CreateWindow({
    Name = "Freeze Pet Vuln - JMX - "..versionText,
    LoadingTitle = "Initializing...",
    LoadingSubtitle = "Automated Farm Processing",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FreezePetConfig",
        FileName = "Settings"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false,
})

local MainTab = Window:CreateTab("Main", "settings")
local PetTab = Window:CreateTab("Pet Controls", "paw-print")

-- Configuration
local Config = {
    SimplifyPets = false,
    FreezePets = false,
    OriginalAnimLocations = {},
    FrozenRootParts = {} -- Stores frozen root parts and their original parents
}

-- Function to enable UI elements
local function enableUIElements()
    local player = game:GetService("Players").LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    local teleportUI = playerGui:FindFirstChild("Teleport_UI")
    if not teleportUI then return false end
    
    teleportUI.Enabled = true
    
    local mainFrame = teleportUI:FindFirstChild("Frame")
    if not mainFrame then return false end
    
    mainFrame.Visible = true
    
    local petsButton = mainFrame:FindFirstChild("Pets")
    if petsButton and petsButton:IsA("ImageButton") then
        petsButton.Visible = true
    end
    
    local gearButton = mainFrame:FindFirstChild("Gear")
    if gearButton and gearButton:IsA("ImageButton") then
        gearButton.Visible = true
    end
    
    return true
end

-- Function to process farms
local function processFarms()
    local player = game:GetService("Players").LocalPlayer
    local playerName = player.Name
    local farmsMoved = 0
    
    if not workspace:FindFirstChild("Farm") then
        Rayfield:Notify({
            Title = "Error",
            Content = "No Farm folder found",
            Duration = 5,
            Image = "alert-circle"
        })
        return
    end
    
    for _, farm in ipairs(workspace.Farm:GetChildren()) do
        if farm.Name == "Farm" then
            local ownerValue
            local success = pcall(function()
                local ownerObj = farm:FindFirstChild("Important", true):FindFirstChild("Data", true):FindFirstChild("Owner", true)
                if ownerObj and ownerObj:IsA("StringValue") then
                    ownerValue = ownerObj.Value
                end
            end)
            
            if ownerValue ~= playerName then
                pcall(function()
                    farm.Parent = game:GetService("ReplicatedStorage")
                    farmsMoved += 1
                end)
            end
        end
    end
    
    enableUIElements()
    
    Rayfield:Notify({
        Title = "Processing Complete",
        Content = string.format("Hidden %d farms", farmsMoved),
        Duration = 5,
        Image = "check-circle"
    })
end

-- Function to handle pet simplification
local function togglePetSimplification(value)
    local petMover = workspace:FindFirstChild("PetsPhysical", true):FindFirstChild("PetMover", true)
    if not petMover then
        Rayfield:Notify({
            Title = "Error",
            Content = "No valid pet found. Refresh pet slot.",
            Duration = 5,
            Image = "alert-circle"
        })
        return
    end

    if value then -- Simplify Pets ON
        -- Create Anim folder if it doesn't exist
        local animFolder = petMover:FindFirstChild("Anim")
        if not animFolder then
            animFolder = Instance.new("Folder")
            animFolder.Name = "Anim"
            animFolder.Parent = petMover
        end

        -- Move all AnimationControllers to Anim folder
        Config.OriginalAnimLocations = {}
        for _, pet in ipairs(petMover:GetChildren()) do
            if pet ~= animFolder then
                local animController = pet:FindFirstChild("AnimationController")
                if animController then
                    Config.OriginalAnimLocations[animController] = animController.Parent
                    animController.Parent = animFolder
                end
            end
        end
        
        Rayfield:Notify({
            Title = "Pets Simplified",
            Content = "Disabled pet animations",
            Duration = 3,
            Image = "package"
        })
    else -- Simplify Pets OFF
        -- Move AnimationControllers back to original locations
        local animFolder = petMover:FindFirstChild("Anim")
        if animFolder then
            for animController, originalParent in pairs(Config.OriginalAnimLocations) do
                if animController and originalParent and originalParent.Parent then
                    animController.Parent = originalParent
                end
            end
            Config.OriginalAnimLocations = {}
            animFolder:Destroy()
            
            Rayfield:Notify({
                Title = "Pets Restored",
                Content = "Returned animations to pets",
                Duration = 3,
                Image = "rotate-ccw"
            })
        end
    end
end

-- Function to handle pet freezing
local function togglePetFreezing(value)
    local petMover = workspace:FindFirstChild("PetsPhysical", true):FindFirstChild("PetMover", true)
    if not petMover then
        Rayfield:Notify({
            Title = "Error",
            Content = "No resource found. Refresh pet slot.",
            Duration = 5,
            Image = "alert-circle"
        })
        return
    end

    if value then -- Freeze Pets ON
        -- Find all pets with both AnimationController and RootPart
        local validPets = {}
        for _, pet in ipairs(petMover:GetChildren()) do
            if pet:FindFirstChild("AnimationController") and pet:FindFirstChild("RootPart") then
                table.insert(validPets, pet)
            end
        end

        if #validPets > 0 then
            -- Clear any previously frozen pets
            Config.FrozenRootParts = {}
            
            -- Freeze a random pet
            local randomPet = validPets[math.random(1, #validPets)]
            local rootPart = randomPet:FindFirstChild("RootPart")
            if rootPart then
                Config.FrozenRootParts[randomPet] = rootPart:Clone()
                rootPart:Destroy()
                
                Rayfield:Notify({
                    Title = "Pet(s) Frozen",
                    Content = "Vuln triggered on "..randomPet.Name,
                    Duration = 3,
                    Image = "snowflake"
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Must disable animations after freezing.",
                Duration = 5,
                Image = "alert-circle"
            })
        end
    else -- Freeze Pets OFF
        -- Restore all frozen root parts
        for pet, rootPartClone in pairs(Config.FrozenRootParts) do
            if pet and pet.Parent and not pet:FindFirstChild("RootPart") then
                rootPartClone.Parent = pet
            end
        end
        Config.FrozenRootParts = {}
        
        Rayfield:Notify({
            Title = "Cannot unfreeze pets",
            Content = "Refresh pet slot.",
            Duration = 3,
            Image = "sun"
        })
    end
end

-- Main Tab
MainTab:CreateButton({
    Name = "Process Farms",
    Callback = processFarms,
})

MainTab:CreateParagraph({
    Title = "Freeze Pet Vuln",
    Content = "Automatically enabled two QOL scripts (Teleport_UI unlock + Hide all other farms)\nPlease freeze pets before disabling animations."
})

-- Pet Controls Tab
PetTab:CreateToggle({
    Name = "Simplify Pets",
    CurrentValue = Config.SimplifyPets,
    Flag = "SimplifyPetsToggle",
    Callback = function(value)
        Config.SimplifyPets = value
        togglePetSimplification(value)
    end,
})

PetTab:CreateToggle({
    Name = "Freeze Pets",
    CurrentValue = Config.FreezePets,
    Flag = "FreezePetsToggle",
    Callback = function(value)
        Config.FreezePets = value
        togglePetFreezing(value)
    end,
})

PetTab:CreateParagraph({
    Title = "Pet Controls",
    Content = "Simplify Pets: Remove pet animations (not necessary)\nFreeze Pets: Freezes any and all pets."
})

-- Run automatically on script start
processFarms()

-- Load configuration (must be last)
Rayfield:LoadConfiguration()
