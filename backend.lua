local module = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Logging configuration
local LOG_LEVELS = {
    ERROR = 1,
    WARN = 2,
    INFO = 3,
    DEBUG = 4
}
local CURRENT_LOG_LEVEL = LOG_LEVELS.DEBUG

local function log(level, message)
    if level > CURRENT_LOG_LEVEL then return end
    local prefix = ({
        [LOG_LEVELS.ERROR] = "[ERROR] ",
        [LOG_LEVELS.WARN] = "[WARN]  ",
        [LOG_LEVELS.INFO] = "[INFO]  ",
        [LOG_LEVELS.DEBUG] = "[DEBUG] "
    })[level]
    warn(prefix .. message)
end

-- Updated remote mappings with your working configuration
local REMOTE_MAPPINGS = {
    GearStock = {
        RemotePath = {"GameEvents", "BuyGearStock"},
        ArgsTemplate = function(item) return {item} end
    },
    SeedStock = {
        RemotePath = {"GameEvents", "BuySeedStock"},
        ArgsTemplate = function(item) return {item} end
    },
    CosmeticCrate = {
        RemotePath = {"GameEvents", "BuyCosmeticCrate"},
        ArgsTemplate = function(item) return {item} end
    },
    EventStock = {
        RemotePath = {"GameEvents", "BuyEventShopStock"},
        ArgsTemplate = function(item) return {item} end
    },
    CosmeticItem = {
        RemotePath = {"GameEvents", "BuyCosmeticItem"},
        ArgsTemplate = function(item) return {item} end
    },
    PetEgg = {
        RemotePath = {"GameEvents", "BuyPetEgg"},
        ArgsTemplate = function(item) return {tonumber(item)} end
    }
}

-- Shop configuration
local SHOP_CONFIGS = {
    Seed = {
        path = {"PlayerGui", "Seed_Shop", "Frame", "ScrollingFrame"},
        remoteType = "SeedStock",
        filter = function(name) return not (name:find("_") or name:upper():find("UI")) end
    },
    Gear = {
        path = {"PlayerGui", "Gear_Shop", "Frame", "ScrollingFrame"},
        remoteType = "GearStock",
        filter = function(name) return not (name:find("_") or name:upper():find("UI")) end
    },
    Event = {
        path = {"PlayerGui", "HoneyEventShop_UI", "Frame", "ScrollingFrame"},
        remoteType = "EventStock",
        filter = function(name) return not (name:find("_") or name:upper():find("UI")) end
    },
    CosmeticItem = {
        path = {"ReplicatedStorage", "Data", "CosmeticItemShopData"},
        remoteType = "CosmeticItem",
        validator = function(data) return type(data) == "table" end
    },
    CosmeticCrate = {
        path = {"ReplicatedStorage", "Data", "CosmeticCrateShopData"},
        remoteType = "CosmeticCrate",
        validator = function(data) return type(data) == "table" end
    }
}

-- Core purchase execution
function module.executePurchase(remoteType, itemName)
    local success, result = pcall(function()
        log(LOG_LEVELS.DEBUG, string.format("Attempting purchase: %s (%s)", remoteType, itemName))
        
        local config = REMOTE_MAPPINGS[remoteType]
        if not config then
            error("Invalid remote type: "..tostring(remoteType))
        end
        
        local remote = ReplicatedStorage
        for i, childName in ipairs(config.RemotePath) do
            if not remote:FindFirstChild(childName) then
                error("Missing remote part: "..childName.." at index "..i)
            end
            remote = remote:WaitForChild(childName)
        end
        
        local args = config.ArgsTemplate(itemName)
        remote:FireServer(unpack(args))
        log(LOG_LEVELS.INFO, "Purchase successful: "..itemName)
        return true
    end)
    
    if not success then
        log(LOG_LEVELS.ERROR, "executePurchase failed: "..result)
        return false
    end
    
    return result
end

-- Get shop items with improved error handling
function module.getShopItems(shopType)
    local success, items = pcall(function()
        log(LOG_LEVELS.DEBUG, "Fetching items for shop: "..shopType)
        
        local config = SHOP_CONFIGS[shopType]
        if not config then
            error("Invalid shop type: "..tostring(shopType))
        end

        local items = {}
        local current
        
        if shopType == "CosmeticItem" or shopType == "CosmeticCrate" then
            current = ReplicatedStorage
            for i, part in ipairs(config.path) do
                if not current:FindFirstChild(part) then
                    error("Missing path part: "..part.." at index "..i)
                end
                current = current:WaitForChild(part)
            end
            
            local data = require(current)
            if config.validator and not config.validator(data) then
                error("Invalid data format in module")
            end
            
            for name, _ in pairs(data) do
                if type(name) == "string" then
                    table.insert(items, name)
                end
            end
        else
            current = player
            for i, part in ipairs(config.path) do
                if not current:FindFirstChild(part) then
                    error("Missing path part: "..part.." at index "..i)
                end
                current = current:WaitForChild(part)
            end
            
            for _, child in ipairs(current:GetChildren()) do
                if not config.filter or config.filter(child.Name) then
                    table.insert(items, child.Name)
                end
            end
        end
        
        if #items == 0 then
            log(LOG_LEVELS.WARN, "No items found for shop: "..shopType)
        end
        
        return items
    end)
    
    if not success then
        log(LOG_LEVELS.ERROR, "getShopItems failed: "..items)
        return {}
    end
    
    return items
end

-- Continuous purchase system
function module.startContinuousPurchase(config, callback)
    local connection
    local purchaseOrder = {"GearStock", "SeedStock", "CosmeticCrate", "EventStock", "CosmeticItem"}
    
    local function purchaseLoop()
        for _, remoteType in ipairs(purchaseOrder) do
            local items = config[remoteType] or {}
            for _, itemName in ipairs(items) do
                if callback then callback("Purchasing: "..itemName) end
                local success = module.executePurchase(remoteType, itemName)
                if not success then
                    log(LOG_LEVELS.WARN, "Failed to purchase: "..itemName)
                end
                task.wait(0.5)
            end
        end
        if callback then callback("Cycle completed") end
    end
    
    connection = RunService.Heartbeat:Connect(purchaseLoop)
    
    return function()
        if connection then
            connection:Disconnect()
            if callback then callback("Stopped continuous purchases") end
        end
    end
end

-- Egg auto-buy system
function module.setupAutoBuyEggs(callback)
    local autoBuyEnabled = false
    local currentValue = 1
    local connection
    
    local function fireRemote(value)
        local success = module.executePurchase("PetEgg", tostring(value))
        if success and callback then
            callback("Buying Egg "..value)
        elseif not success and callback then
            callback("Purchase failed")
        end
    end
    
    local function start()
        if autoBuyEnabled then return end
        autoBuyEnabled = true
        
        connection = task.spawn(function()
            while autoBuyEnabled do
                for i = 1, 3 do
                    if not autoBuyEnabled then break end
                    fireRemote(currentValue)
                    currentValue = currentValue % 3 + 1
                    if i < 3 then task.wait(0.1) end
                end
                
                if autoBuyEnabled and callback then
                    callback("Waiting (10m)")
                    local waitTime = 600
                    while waitTime > 0 and autoBuyEnabled do
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
        autoBuyEnabled = false
        if connection then task.cancel(connection) end
    end
    
    return {
        start = start,
        stop = stop
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

log(LOG_LEVELS.INFO, "Backend module initialized")
return module
