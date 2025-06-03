local BuyFunction = {}

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
    }
}

function BuyFunction.execute(remoteType, itemName)
    local config = REMOTE_MAPPINGS[remoteType]
    if not config then return false end
    
    local remote = game:GetService("ReplicatedStorage")
    for _, childName in ipairs(config.RemotePath) do
        remote = remote:WaitForChild(childName)
    end
    
    remote:FireServer(unpack(config.ArgsTemplate(itemName)))
    return true
end

function BuyFunction.startContinuousPurchase(config)
    local runService = game:GetService("RunService")
    local connection
    local purchaseOrder = {"GearStock", "SeedStock", "CosmeticCrate", "EventStock", "CosmeticItem"}
    
    connection = runService.Heartbeat:Connect(function()
        for _, remoteType in ipairs(purchaseOrder) do
            local items = config[remoteType] or {}
            for _, itemName in ipairs(items) do
                BuyFunction.execute(remoteType, itemName)
                task.wait(0.5) -- Wait half second between purchases
            end
        end
    end)
    
    return function() -- Return disconnect function
        if connection then
            connection:Disconnect()
        end
    end
end

return BuyFunction
