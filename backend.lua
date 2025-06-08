local module = {}

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

local ASSETS = {
    REMOTE_PATHS = {
        BuyPetEgg = {"GameEvents", "BuyPetEgg"},
        BuyGearStock = {"GameEvents", "BuyGearStock"}, 
        BuySeedStock = {"GameEvents", "BuySeedStock"},
        BuyCosmeticCrate = {"GameEvents", "BuyCosmeticCrate"},
        BuyEventShopStock = {"GameEvents", "BuyEventShopStock"},
        BuyCosmeticItem = {"GameEvents", "BuyCosmeticItem"}
    },
    SHOP_PATHS = {
        Seed = {"PlayerGui", "Seed_Shop", "Frame", "ScrollingFrame"},
        Gear = {"PlayerGui", "Gear_Shop", "Frame", "ScrollingFrame"},
        Event = {"PlayerGui", "HoneyEventShop_UI", "Frame", "ScrollingFrame"},
        CosmeticItem = {"ReplicatedStorage", "Data", "CosmeticItemShopData"},
        CosmeticCrate = {"ReplicatedStorage", "Data", "CosmeticCrateShopData"}
    }
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

function module.getShopItems(shopType)
    local success, items = pcall(function()
        log(LOG_LEVELS.DEBUG, "Fetching items for shop: "..shopType)
        
        local config = ASSETS.SHOP_PATHS[shopType]
        if not config then
            error("Invalid shop type: "..tostring(shopType))
        end

        local items = {}
        local current
        
        if shopType == "CosmeticItem" or shopType == "CosmeticCrate" then
            current = ReplicatedStorage
            for i, part in ipairs(config) do
                if not current:FindFirstChild(part) then
                    error("Missing path part: "..part.." at index "..i)
                end
                current = current:WaitForChild(part)
            end
            
            local data
            local success, err = pcall(function()
                data = require(current)
            end)
            
            if not success then
                error("Failed to require module: "..err)
            end
            
            for name, _ in pairs(data) do
                if type(name) == "string" then
                    if not items[name] then
                        items[name] = true
                        table.insert(items, name)
                    end
                else
                    log(LOG_LEVELS.WARN, "Skipping non-string key: "..tostring(name))
                end
            end
        else
            current = player
            for i, part in ipairs(config) do
                if not current:FindFirstChild(part) then
                    error("Missing path part: "..part.." at index "..i)
                end
                current = current:WaitForChild(part)
            end
            
            for _, child in ipairs(current:GetChildren()) do
                if not child.Name:find("_") and not child.Name:upper():find("UI") then
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

function module.executePurchase(remoteType, itemName)
    local success, result = pcall(function()
        log(LOG_LEVELS.DEBUG, string.format("Attempting purchase: %s (%s)", remoteType, itemName))
        
        local remotePath = ASSETS.REMOTE_PATHS[remoteType]
        if not remotePath then
            error("Invalid remote type: "..tostring(remoteType))
        end
        
        local remote = ReplicatedStorage
        for i, childName in ipairs(remotePath) do
            if not remote:FindFirstChild(childName) then
                error("Missing remote part: "..childName.." at index "..i)
            end
            remote = remote:WaitForChild(childName)
        end
        
        remote:FireServer(itemName)
        log(LOG_LEVELS.INFO, "Purchase successful: "..itemName)
        return true
    end)
    
    if not success then
        log(LOG_LEVELS.ERROR, "executePurchase failed: "..result)
        return false
    end
    
    return result
end

function module.setupAutoBuyEggs(callback)
    local autoBuyEnabled = false
    local currentValue = 1
    local connection
    
    local function fireRemote(value)
        local success = module.executePurchase("BuyPetEgg", value)
        if success and callback then
            callback("Buying Egg "..value)
        elseif not success then
            if callback then callback("Purchase failed") end
        end
    end
    
    local function start()
        if autoBuyEnabled then
            log(LOG_LEVELS.WARN, "Auto-buy already running")
            return
        end
        
        autoBuyEnabled = true
        log(LOG_LEVELS.INFO, "Starting auto-buy eggs")
        
        connection = task.spawn(function()
            while autoBuyEnabled do
                for i = 1, 3 do
                    if not autoBuyEnabled then break end
                    
                    fireRemote(currentValue)
                    currentValue = currentValue % 3 + 1
                    
                    if i < 3 then
                        task.wait(0.1)
                    end
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
        if not autoBuyEnabled then
            log(LOG_LEVELS.WARN, "Auto-buy not running")
            return
        end
        
        log(LOG_LEVELS.INFO, "Stopping auto-buy eggs")
        autoBuyEnabled = false
        if connection then
            task.cancel(connection)
        end
    end
    
    return {
        start = start,
        stop = stop
    }
end

function module.setupShecklesListener(callback)
    local function update()
        local success, err = pcall(function()
            local leaderstats = player:FindFirstChild("leaderstats")
            if not leaderstats then
                error("leaderstats not found")
            end
            
            local shecklesValue = leaderstats:FindFirstChild("Sheckles")
            if not shecklesValue then
                error("Sheckles value not found")
            end
            
            if callback then
                local formatted = tostring(shecklesValue.Value):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
                local progress = math.min(shecklesValue.Value / 5000000, 1)
                local time = string.format("%.2f hours", shecklesValue.Value / 5000000)
                callback(formatted, progress, time)
            end
        end)
        
        if not success then
            log(LOG_LEVELS.ERROR, "Sheckles update failed: "..err)
        end
    end
    
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local shecklesValue = leaderstats:FindFirstChild("Sheckles")
        if shecklesValue then
            shecklesValue:GetPropertyChangedSignal("Value"):Connect(update)
        else
            log(LOG_LEVELS.WARN, "Sheckles value not found in existing leaderstats")
        end
    else
        log(LOG_LEVELS.INFO, "Waiting for leaderstats to be added")
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
