local module = {}

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
    local config = {
        path = ASSETS.SHOP_PATHS[shopType],
        filter = function(name)
            return not (name:find("_") or name:upper():find("UI")
        end
    }
    
    local items = {}
    if shopType == "CosmeticItem" or shopType == "CosmeticCrate" then
        local current = ReplicatedStorage
        for _, part in ipairs(config.path) do
            current = current:WaitForChild(part)
        end
        local data = require(current)
        for name, _ in pairs(data) do
            if not items[name] then
                table.insert(items, name)
                items[name] = true
            end
        end
    else
        local current = player
        for _, part in ipairs(config.path) do
            current = current:WaitForChild(part)
        end
        for _, child in ipairs(current:GetChildren()) do
            if not config.filter or config.filter(child.Name) then
                table.insert(items, child.Name)
            end
        end
    end
    return items
end

function module.executePurchase(remoteType, itemName)
    local remotePath = ASSETS.REMOTE_PATHS[remoteType]
    if not remotePath then return false end
    
    local remote = ReplicatedStorage
    for _, childName in ipairs(remotePath) do
        remote = remote:WaitForChild(childName)
    end
    
    remote:FireServer(itemName)
    return true
end

function module.setupAutoBuyEggs(callback)
    local autoBuyEnabled = false
    local currentValue = 1
    local connection
    
    local function fireRemote(value)
        module.executePurchase("BuyPetEgg", value)
        if callback then callback("Buying Egg "..value) end
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
    if not leaderstats then
        player.ChildAdded:Connect(function(child)
            if child.Name == "leaderstats" then
                update()
            end
        end)
    else
        local shecklesValue = leaderstats:FindFirstChild("Sheckles")
        if shecklesValue then
            shecklesValue:GetPropertyChangedSignal("Value"):Connect(update)
        end
    end
    
    update()
    return update
end

return module
