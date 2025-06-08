local module = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Configuration file path
local CONFIG_FILE = "ShecklesConfig.json"

-- Default configuration
local DEFAULT_CONFIG = {
    autoBuyEggs = false,
    continuousPurchase = {
        GearStock = {},
        SeedStock = {},
        CosmeticCrate = {},
        EventStock = {},
        CosmeticItem = {}
    }
}

-- Current configuration
local config = DEFAULT_CONFIG

-- Remote mappings based on your exact examples
local REMOTE_MAPPINGS = {
    GearStock = {
        Path = {"GameEvents", "BuyGearStock"},
        ArgsTemplate = function(item) return {item} end
    },
    SeedStock = {
        Path = {"GameEvents", "BuySeedStock"},
        ArgsTemplate = function(item) return {item} end
    },
    CosmeticCrate = {
        Path = {"GameEvents", "BuyCosmeticCrate"},
        ArgsTemplate = function(item) return {item} end
    },
    EventStock = {
        Path = {"GameEvents", "BuyEventShopStock"},
        ArgsTemplate = function(item) return {item} end
    },
    CosmeticItem = {
        Path = {"GameEvents", "BuyCosmeticitem"}, -- Note lowercase 'i'
        ArgsTemplate = function(item) return {item} end
    },
    PetEgg = {
        Path = {"GameEvents", "BuyPetEgg"},
        ArgsTemplate = function(item) return {tonumber(item)} end
    }
}

-- Load configuration from file
local function loadConfig()
    if not isfile(CONFIG_FILE) then
        writefile(CONFIG_FILE, game:GetService("HttpService"):JSONEncode(DEFAULT_CONFIG))
        return DEFAULT_CONFIG
    end
    
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(CONFIG_FILE))
    end)
    
    if not success then
        warn("[CONFIG] Error loading config: "..tostring(result))
        return DEFAULT_CONFIG
    end
    
    -- Merge with default to ensure all keys exist
    local merged = table.clone(DEFAULT_CONFIG)
    for k, v in pairs(result) do
        if merged[k] ~= nil then
            if type(v) == "table" then
                merged[k] = v
            else
                warn("[CONFIG] Invalid config value for: "..k)
            end
        end
    end
    
    return merged
end

-- Save configuration to file
local function saveConfig()
    local success, err = pcall(function()
        writefile(CONFIG_FILE, game:GetService("HttpService"):JSONEncode(config))
    end)
    
    if not success then
        warn("[CONFIG] Failed to save config: "..tostring(err))
    end
end

-- Initialize config
config = loadConfig()

-- Core purchase execution
function module.executePurchase(remoteType, itemName)
    local config = REMOTE_MAPPINGS[remoteType]
    if not config then
        warn("[ERROR] Invalid remote type: "..tostring(remoteType))
        return false
    end

    local remote = ReplicatedStorage
    for _, childName in ipairs(config.Path) do
        remote = remote:FindFirstChild(childName)
        if not remote then
            warn("[ERROR] Missing remote part: "..childName)
            return false
        end
    end

    local args = config.ArgsTemplate(itemName)
    remote:FireServer(unpack(args))
    return true
end

-- Get shop items
function module.getShopItems(shopType)
    -- Implementation from your working version
    -- This should return a list of valid item names
    return {"Item1", "Item2"} -- Placeholder
end

-- Continuous purchase system
function module.startContinuousPurchase(callback)
    local connection
    local purchaseOrder = {"GearStock", "SeedStock", "CosmeticCrate", "EventStock", "CosmeticItem"}
    
    connection = RunService.Heartbeat:Connect(function()
        for _, remoteType in ipairs(purchaseOrder) do
            local items = config.continuousPurchase[remoteType] or {}
            for _, itemName in ipairs(items) do
                if callback then callback("Purchasing: "..itemName) end
                local success = module.executePurchase(remoteType, itemName)
                if not success and callback then
                    callback("Failed: "..itemName)
                end
                task.wait(0.5)
            end
        end
        if callback then callback("Cycle completed") end
    end)
    
    return function() -- Disconnect function
        if connection then
            connection:Disconnect()
            if callback then callback("Stopped continuous purchases") end
        end
    end
end

-- Add item to continuous purchase list
function module.addContinuousPurchaseItem(remoteType, itemName)
    if not config.continuousPurchase[remoteType] then
        config.continuousPurchase[remoteType] = {}
    end
    
    -- Prevent duplicates
    for _, name in ipairs(config.continuousPurchase[remoteType]) do
        if name == itemName then return end
    end
    
    table.insert(config.continuousPurchase[remoteType], itemName)
    saveConfig()
end

-- Remove item from continuous purchase list
function module.removeContinuousPurchaseItem(remoteType, itemName)
    if not config.continuousPurchase[remoteType] then return end
    
    for i, name in ipairs(config.continuousPurchase[remoteType]) do
        if name == itemName then
            table.remove(config.continuousPurchase[remoteType], i)
            saveConfig()
            return
        end
    end
end

-- Egg auto-buy system with config saving
function module.setupAutoBuyEggs(callback)
    local currentValue = 1
    local connection
    local running = config.autoBuyEggs  -- Start with saved state
    
    local function fireRemote(value)
        local success = module.executePurchase("PetEgg", tostring(value))
        if success and callback then
            callback("Buying Egg "..value)
        elseif not success and callback then
            callback("Purchase failed")
        end
    end
    
    local function start()
        if running then return end
        running = true
        config.autoBuyEggs = true
        saveConfig()
        
        connection = task.spawn(function()
            while running do
                for i = 1, 3 do
                    if not running then break end
                    fireRemote(currentValue)
                    currentValue = currentValue % 3 + 1
                    if i < 3 then task.wait(0.1) end
                end
                
                if running and callback then
                    callback("Waiting (10m)")
                    local waitTime = 600
                    while waitTime > 0 and running do
                        task.wait(1)
                        waitTime = waitTime - 1
                        if waitTime % 60 == 0 then
                            callback("Waiting ("..math.floor(waitTime/60).."m)")
                        end
                    end
                end
            end
            if callback then callback("Idle") end
        end)
    end
    
    local function stop()
        if not running then return end
        running = false
        config.autoBuyEggs = false
        saveConfig()
        if connection then task.cancel(connection) end
    end
    
    -- Start automatically if enabled in config
    if running then
        task.spawn(start)
    end
    
    return {
        start = start,
        stop = stop,
        isRunning = function() return running end
    }
end

-- Sheckles tracking
function module.setupShecklesListener(callback)
    local function update()
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local shecklesValue = leaderstats:FindFirstChild("Sheckles")
            if shecklesValue and callback then
                local formatted = tostring(shecklesValue.Value):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
                local progress = math.min(shecklesValue.Value / 5000000, 1)
                local time = string.format("%.2f hours", shecklesValue.Value / 5000000)
                callback(formatted, progress, time)
            end
        end
    end
    
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local shecklesValue = leaderstats:FindFirstChild("Sheckles")
        if shecklesValue then
            shecklesValue:GetPropertyChangedSignal("Value"):Connect(update)
        end
    else
        player.ChildAdded:Connect(function(child)
            if child.Name == "leaderstats" then
                update()
            end
        end)
    end
    
    update()
    return update
end

-- Get current configuration
function module.getConfig()
    return config
end

return module
