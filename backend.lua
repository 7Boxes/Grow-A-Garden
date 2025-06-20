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

-- Hardcoded shop data from decompiled scripts
local HARDCODED_SHOPS = {
    -- Gear Shop (Script_1749421957)
    GearStock = {
        ["Watering Can"] = {PurchaseID = 3260229242},
        ["Trowel"] = {PurchaseID = 3265946561},
        ["Recall Wrench"] = {PurchaseID = 3282918403},
        ["Basic Sprinkler"] = {PurchaseID = 3265889601},
        ["Advanced Sprinkler"] = {PurchaseID = 3265889751},
        ["Godly Sprinkler"] = {PurchaseID = 3265889948},
        ["Lightning Rod"] = {PurchaseID = 3265946758},
        ["Master Sprinkler"] = {PurchaseID = 3267580365},
        ["Favorite Tool"] = {PurchaseID = 3281679093},
        ["Harvest Tool"] = {PurchaseID = 3286038236},
        ["Friendship Pot"] = {PurchaseID = 3301473650}
    },
    
    -- Seed Shop (Script_1749422456) - Only items with StockChance > 0
    SeedStock = {
        ["Carrot"] = {PurchaseID = 3248692171},
        ["Strawberry"] = {PurchaseID = 3248695947},
        ["Blueberry"] = {PurchaseID = 3248690960},
        ["Orange Tulip"] = {PurchaseID = 3265927408},
        ["Tomato"] = {PurchaseID = 3248696942},
        ["Corn"] = {PurchaseID = 3248692845},
        ["Daffodil"] = {PurchaseID = 3265927978},
        ["Watermelon"] = {PurchaseID = 3248697546},
        ["Pumpkin"] = {PurchaseID = 3248695199},
        ["Apple"] = {PurchaseID = 3248716238},
        ["Bamboo"] = {PurchaseID = 3261009117},
        ["Coconut"] = {PurchaseID = 3248744789},
        ["Cactus"] = {PurchaseID = 3260940714},
        ["Dragon Fruit"] = {PurchaseID = 3253012192},
        ["Mango"] = {PurchaseID = 3259333414},
        ["Grape"] = {PurchaseID = 3261068725},
        ["Mushroom"] = {PurchaseID = 3273973729},
        ["Pepper"] = {PurchaseID = 3277675404},
        ["Cacao"] = {PurchaseID = 3282870834},
        ["Beanstalk"] = {PurchaseID = 3284390402},
        ["Ember Lily"] = {PurchaseID = 3300984139},
        ["Banana"] = {PurchaseID = 3269001250}
    },
    
    -- Event Shop (Script_1749422001)
    EventStock = {
        ["Flower Seed Pack"] = {PurchaseID = 3295395160},
        ["Lavender"] = {PurchaseID = 3301505595},
        ["Nectarshade"] = {PurchaseID = 3301505385},
        ["Nectarine"] = {PurchaseID = 3295402526},
        ["Hive Fruit"] = {PurchaseID = 3295395667},
        ["Pollen Radar"] = {PurchaseID = 3301505788},
        ["Nectar Staff"] = {PurchaseID = 3301505981},
        ["Honey Sprinkler"] = {PurchaseID = 3295397583},
        ["Bee Egg"] = {PurchaseID = 3295398638},
        ["Bee Crate"] = {PurchaseID = 3295396781},
        ["Honey Comb"] = {PurchaseID = 3295398991},
        ["Bee Chair"] = {PurchaseID = 3295397103},
        ["Honey Torch"] = {PurchaseID = 3295399979},
        ["Honey Walkway"] = {PurchaseID = 3295398026}
    },
    
    -- Cosmetic shops (from previous decompiled scripts)
    CosmeticCrate = {
        ["Sign Crate"] = {PurchaseID = 3290108854},
        ["Common Gnome Crate"] = {PurchaseID = 3290108955},
        ["Fun Crate"] = {PurchaseID = 3290109194},
        ["Farmers Gnome Crate"] = {PurchaseID = 3290109302},
        ["Classic Gnome Crate"] = {PurchaseID = 3290109380},
        ["Statue Crate"] = {PurchaseID = 3290109444}
    },
    
    CosmeticItem = {
        ["Yellow Umbrella"] = {PurchaseID = 3290145031},
        ["Orange Umbrella"] = {PurchaseID = 3290145015},
        ["Brick Stack"] = {PurchaseID = 3290145041},
        ["Compost Bin"] = {PurchaseID = 3290145025},
        ["Log"] = {PurchaseID = 3290145010},
        ["Rock Pile"] = {PurchaseID = 3290145022},
        ["Rake"] = {PurchaseID = 3290113000},
        ["Shovel"] = {PurchaseID = 3290113132},
        ["Torch"] = {PurchaseID = 3290145030},
        ["Red Pottery"] = {PurchaseID = 3290144998},
        ["White Pottery"] = {PurchaseID = 3290145014},
        ["Wood Pile"] = {PurchaseID = 3290145016},
        ["Small Circle Tile"] = {PurchaseID = 3290145040},
        ["Medium Circle Tile"] = {PurchaseID = 3290145046},
        ["Small Path Tile"] = {PurchaseID = 3290145036},
        ["Medium Path Tile"] = {PurchaseID = 3290145011},
        ["Large Path Tile"] = {PurchaseID = 3290145052},
        ["Axe Stump"] = {PurchaseID = 3290145012},
        ["Bookshelf"] = {PurchaseID = 3290145044},
        ["Brown Bench"] = {PurchaseID = 3290145003},
        ["Hay Bale"] = {PurchaseID = 3290785122},
        ["Light On Ground"] = {PurchaseID = 3290145047},
        ["Log Bench"] = {PurchaseID = 3290110287},
        ["Mini TV"] = {PurchaseID = 3290145028},
        ["Shovel Grave"] = {PurchaseID = 3290145050},
        ["Small Stone Lantern"] = {PurchaseID = 3290145009},
        ["Small Stone Pad"] = {PurchaseID = 3290145024},
        ["Large Stone Pad"] = {PurchaseID = 3290145006},
        ["Stone Lantern"] = {PurchaseID = 3290145017},
        ["Viney Beam"] = {PurchaseID = 3290145026},
        ["Water Trough"] = {PurchaseID = 3290145001},
        ["White Bench"] = {PurchaseID = 3290144996},
        ["Wood Fence"] = {PurchaseID = 3290144997},
        ["Small Wood Flooring"] = {PurchaseID = 3290145005},
        ["Medium Wood Flooring"] = {PurchaseID = 3290145051},
        ["Large Wood Flooring"] = {PurchaseID = 3290145007},
        ["Small Stone Table"] = {PurchaseID = 3290145042},
        ["Medium Stone Table"] = {PurchaseID = 3290145039},
        ["Long Stone Table"] = {PurchaseID = 3290145023},
        ["Lamp Post"] = {PurchaseID = 3290145019},
        ["Bamboo Wind Chime"] = {PurchaseID = 3290112781},
        ["Metal Wind Chime"] = {PurchaseID = 3290112884},
        ["Bird Bath"] = {PurchaseID = 3290144990},
        ["Brown Stone Pillar"] = {PurchaseID = 3290145018},
        ["Dark Stone Pillar"] = {PurchaseID = 3290145000},
        ["Grey Stone Pillar"] = {PurchaseID = 3290145035},
        ["Campfire"] = {PurchaseID = 3290145034},
        ["Clothesline"] = {PurchaseID = 3290145013},
        ["Cooking Pot"] = {PurchaseID = 3290145020},
        ["Curved Canopy"] = {PurchaseID = 3290144999},
        ["Flat Canopy"] = {PurchaseID = 3290145032},
        ["Small Wood Arbour"] = {PurchaseID = 3290145004},
        ["Square Metal Arbour"] = {PurchaseID = 3290145029},
        ["Small Wood Table"] = {PurchaseID = 3290145021},
        ["Large Wood Table"] = {PurchaseID = 3290145002},
        ["Wheelbarrow"] = {PurchaseID = 3290112654},
        ["Blue Well"] = {PurchaseID = 3290145027},
        ["Brown Well"] = {PurchaseID = 3290113294},
        ["Red Well"] = {PurchaseID = 3290115132},
        ["Green Tractor"] = {PurchaseID = 3290113504},
        ["Red Tractor"] = {PurchaseID = 3290114982},
        ["Ring Walkway"] = {PurchaseID = 3290145033},
        ["Viney Ring Walkway"] = {PurchaseID = 3290145045},
        ["Large Wood Arbour"] = {PurchaseID = 3290114021},
        ["Round Metal Arbour"] = {PurchaseID = 3290115313},
        ["Frog Fountain"] = {PurchaseID = 3290145037}
    }
}

-- Remote mappings
local REMOTE_MAPPINGS = {
    GearStock = {
        Path = {"GameEvents", "BuyGearStock"},
        ArgsTemplate = function(item) 
            local data = HARDCODED_SHOPS.GearStock[item]
            return {data and data.PurchaseID or 0}
        end
    },
    SeedStock = {
        Path = {"GameEvents", "BuySeedStock"},
        ArgsTemplate = function(item) 
            local data = HARDCODED_SHOPS.SeedStock[item]
            return {data and data.PurchaseID or 0}
        end
    },
    CosmeticCrate = {
        Path = {"GameEvents", "BuyCosmeticCrate"},
        ArgsTemplate = function(item) 
            local data = HARDCODED_SHOPS.CosmeticCrate[item]
            return {data and data.PurchaseID or 0}
        end
    },
    EventStock = {
        Path = {"GameEvents", "BuyEventShopStock"},
        ArgsTemplate = function(item) 
            local data = HARDCODED_SHOPS.EventStock[item]
            return {data and data.PurchaseID or 0}
        end
    },
    CosmeticItem = {
        Path = {"GameEvents", "BuyCosmeticitem"},
        ArgsTemplate = function(item) 
            local data = HARDCODED_SHOPS.CosmeticItem[item]
            return {data and data.PurchaseID or 0}
        end
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
    if HARDCODED_SHOPS[shopType] then
        local items = {}
        for name in pairs(HARDCODED_SHOPS[shopType]) do
            table.insert(items, name)
        end
        table.sort(items)
        return items
    end
    return {}
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

-- Toggle auto-buy eggs
function module.toggleAutoBuyEggs()
    config.autoBuyEggs = not config.autoBuyEggs
    saveConfig()
    return config.autoBuyEggs
end

-- Clear all continuous purchases
function module.clearAllContinuousPurchases()
    for shopType, _ in pairs(config.continuousPurchase) do
        config.continuousPurchase[shopType] = {}
    end
    saveConfig()
end

return module
