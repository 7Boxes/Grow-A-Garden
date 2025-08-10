local HttpService = game:GetService("HttpService")
local DataService = require(game:GetService("ReplicatedStorage").Modules.DataService)

local WebhookURL = "https://discord.com/api/webhooks/1401012390140710996/XBUD3c1lFUAqGU8xNoFh9Y5drOampi3JQJK1thWyH_1Zed4E8KA2_jqanuo02ILy3b3t"
local LOG_FILE = "SeedShopLog.txt"

local DATA_HISTORY = {}
local ANALYZER = {
    last_seed = nil,
    seed_deltas = {},
    item_patterns = {}, -- Tracks item appearance patterns
    seed_to_items = {}, -- Maps seeds to items that appeared
    prediction_model = {
        active = {},    -- Items predicted to appear next
        accuracy = 0,
        algorithm = "basic_seed_modulo" -- Current algorithm being tested
    }
}

local lastSendTime = 0

-- Helper: Convert table to readable string
local function deepString(tbl, indent)
    indent = indent or 0
    local lines = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            table.insert(lines, string.rep("  ", indent) .. tostring(k) .. ":")
            local sub = deepString(v, indent + 1)
            for _, line in ipairs(sub) do
                table.insert(lines, line)
            end
        else
            table.insert(lines, string.rep("  ", indent) .. tostring(k) .. ": " .. tostring(v))
        end
    end
    return lines
end

local function appendLog(snapshot, predictions, accuracy)
    local rounded = snapshot.timestamp - (snapshot.timestamp % 300)
    local timeStr = os.date("%Y-%m-%d %H:%M:%S", rounded)

    local logLines = {
        "=== Seed Shop Data @ " .. timeStr .. " ===",
        "📦 Current Stocks:",
        table.concat(deepString(snapshot.stocks), "\n"),
        "",
        "🔮 Predicted Next Stocks:",
        table.concat(deepString(predictions), "\n"),
        "📊 Prediction Accuracy: " .. tostring(accuracy) .. "%",
        "🌱 Seed Data:",
        "  Current Seed: " .. tostring(snapshot.seed),
        "  Last Delta: " .. (ANALYZER.seed_deltas[#ANALYZER.seed_deltas] and tostring(ANALYZER.seed_deltas[#ANALYZER.seed_deltas]) or "N/A"),
        "  Algorithm: " .. ANALYZER.prediction_model.algorithm,
        snapshot.forcedRestock and ("⚠️ Forced Restock: " .. os.date("%Y-%m-%d %H:%M:%S", snapshot.forcedRestock)) or "",
        ""
    }

    writefile(LOG_FILE, (isfile(LOG_FILE) and readfile(LOG_FILE) or "") .. table.concat(logLines, "\n"))
end

-- Webhook Sender (complete implementation)
local function sendWebhook(payload)
    local function requestWrapper(req)
        if syn and syn.request then
            return syn.request(req)
        elseif http and http.request then
            return http.request(req)
        elseif fluxus and fluxus.request then
            return fluxus.request(req)
        elseif http_request then
            return http_request(req)
        else
            local ok = pcall(function()
                HttpService:PostAsync(req.Url, req.Body or "", Enum.HttpContentType.ApplicationJson)
            end)
            return { StatusCode = ok and 200 or 0 }
        end
    end

    local ok, err = pcall(function()
        local res = requestWrapper({
            Url = WebhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
        return res.StatusCode == 204 or res.StatusCode == 200
    end)

    if not ok then
        warn("Webhook failed:", err)
    end
end

-- Embed Builder (complete implementation)
local function createEmbed(snapshot, predictions, accuracy)
    local currentTime = DateTime.now()
    local cstOffset = 6 * 60 * 60
    local cstTime = os.date("!%A, %B %d, %Y at %I:%M:%S %p", currentTime.UnixTimestamp - cstOffset)

    local embed = {
        title = "Seed Shop Live Analysis",
        description = string.format("Refresh detected at %s CST", cstTime),
        color = 0x00FF00,
        fields = {},
        timestamp = currentTime:ToIsoDate()
    }

    if type(snapshot.stocks) == "table" then
        local stockLines = deepString(snapshot.stocks)
        table.insert(embed.fields, {
            name = "📦 Current Stocks",
            value = table.concat(stockLines, "\n"),
            inline = false
        })
    end

    if type(predictions) == "table" then
        local predLines = deepString(predictions)
        table.insert(embed.fields, {
            name = "🔮 Predicted Next Stocks",
            value = table.concat(predLines, "\n"),
            inline = false
        })
    end

    table.insert(embed.fields, {
        name = "📊 Prediction Accuracy",
        value = string.format("%s%%", tostring(accuracy)),
        inline = false
    })

    local delta = ANALYZER.seed_deltas[#ANALYZER.seed_deltas]
    table.insert(embed.fields, {
        name = "🌱 Seed Data",
        value = string.format("Current Seed: `%s`\nLast Delta: `%s`",
            tostring(snapshot.seed),
            delta and tostring(delta) or "N/A"),
        inline = false
    })

    if snapshot.forcedRestock then
        local restockTime = DateTime.fromUnixTimestamp(snapshot.forcedRestock)
        local restockCST = os.date("!%A, %B %d, %Y at %I:%M:%S %p", restockTime.UnixTimestamp - cstOffset)
        table.insert(embed.fields, { name = "⚠️ Forced Restock", value = restockCST, inline = false })
    end

    return { embeds = { embed } }
end

-- New: Parse historical data from log file
local function loadHistoricalData()
    if not isfile(LOG_FILE) then return end
    
    local logContent = readfile(LOG_FILE)
    for seed, items in logContent:gmatch("Current Seed: (%d+).-📦 Current Stocks:%s*([%w%p%s]+)🔮") do
        local itemList = {}
        for item in items:gmatch("(%a+):") do
            itemList[item] = true
        end
        ANALYZER.seed_to_items[tonumber(seed)] = itemList
    end
end

-- New: Test different prediction algorithms
local function testAlgorithms(seed)
    local algorithms = {
        -- Basic seed modulo (tests if item index appears when seed % X matches)
        basic_seed_modulo = function()
            local predicted = {}
            local all_items = {"Carrot", "Strawberry", "Blueberry", "Orange Tulip", "Tomato", "Corn", "Daffodil", "Watermelon", "Pumpkin", "Apple", "Bamboo", "Coconut", "Cactus", "Dragon Fruit", "Mango", "Grape", "Mushroom", "Pepper", "Cacao", "Beanstalk", "Ember Lily", "Sugar Apple", "Burning Bud", "Giant Pinecone", "Elder Strawberry"}
            
            for _, item in ipairs(all_items) do
                -- Simple test: item appears if (seed % prime_number) matches pattern
                local modValue = #item * 7 -- Arbitrary multiplier
                if seed % modValue < 3 then -- Appears in ~3/modValue cases
                    predicted[item] = 1
                end
            end
            return predicted
        end,

        -- Bitwise pattern (checks specific bits in the seed)
        bitwise_pattern = function()
            local predicted = {}
            -- Check if specific bits are set for each item
            if seed & 0x1 ~= 0 then predicted.Carrot = 1 end
            if seed & 0x2 ~= 0 then predicted.Bamboo = 1 end
            -- ... add more items
            return predicted
        end,

        -- Historical pattern matching
        historical_match = function()
            local predicted = {}
            -- Look for seeds with similar last digits
            local similarSeeds = {}
            for s in pairs(ANALYZER.seed_to_items) do
                if tostring(s):sub(-3) == tostring(seed):sub(-3) then
                    similarSeeds[#similarSeeds+1] = s
                end
            end
            
            -- If we found similar seeds, use their items
            if #similarSeeds > 0 then
                local sample = ANALYZER.seed_to_items[similarSeeds[math.random(#similarSeeds)]]
                for item in pairs(sample) do
                    predicted[item] = 1
                end
            end
            return predicted
        end
    }

    -- Test each algorithm and return the best one
    local bestAlgorithm, bestAccuracy = "", 0
    for name, algo in pairs(algorithms) do
        local tempPredicted = algo()
        local accuracy = 0
        
        -- Compare with historical data if available
        if ANALYZER.seed_to_items[seed] then
            local correct = 0
            for item in pairs(tempPredicted) do
                if ANALYZER.seed_to_items[seed][item] then
                    correct = correct + 1
                end
            end
            accuracy = correct / math.max(1, table.size(tempPredicted))
        end
        
        if accuracy > bestAccuracy then
            bestAlgorithm = name
            bestAccuracy = accuracy
        end
    end

    return algorithms[bestAlgorithm or ANALYZER.prediction_model.algorithm]()
end

-- Updated analysis function
local function analyze(snapshot)
    if ANALYZER.last_seed then
        table.insert(ANALYZER.seed_deltas, snapshot.seed - ANALYZER.last_seed)
    end
    ANALYZER.last_seed = snapshot.seed

    -- Record which items appeared with this seed
    local currentItems = {}
    for item in pairs(snapshot.stocks) do
        currentItems[item] = true
        -- Update appearance frequency
        ANALYZER.item_patterns[item] = (ANALYZER.item_patterns[item] or 0) + 1
    end
    ANALYZER.seed_to_items[snapshot.seed] = currentItems
end

-- Updated prediction function
local function predictNextStocks(seed)
    -- First try exact seed matches from history
    if ANALYZER.seed_to_items[seed] then
        local exactMatch = {}
        for item in pairs(ANALYZER.seed_to_items[seed]) do
            exactMatch[item] = 1
        end
        ANALYZER.prediction_model.algorithm = "exact_historical_match"
        return exactMatch
    end

    -- Otherwise test algorithms
    return testAlgorithms(seed)
end

-- Updated validation function (only checks presence/absence)
local function crossValidate(actualStocks, predictedStocks)
    local correct = 0
    local total = 0
    
    -- Check true positives (predicted and appeared)
    for item in pairs(predictedStocks) do
        if actualStocks[item] then
            correct = correct + 1
        end
        total = total + 1
    end
    
    -- Check false negatives (appeared but not predicted)
    for item in pairs(actualStocks) do
        if not predictedStocks[item] then
            total = total + 1
        end
    end
    
    return total > 0 and math.floor((correct / total) * 100) or 0
end

-- Embed Builder (unchanged)
local function createEmbed(snapshot, predictions, accuracy) ... end

-- Load historical data on startup
loadHistoricalData()

-- Hooked GetData
local originalGetData = DataService.GetData
function DataService:GetData(...)
    local result = originalGetData(self, ...)
    if result and result.SeedStock then
        local snapshot = {
            timestamp = os.time(),
            seed = result.SeedStock.Seed,
            stocks = result.SeedStock.Stocks,
            forcedRestock = result.SeedStock.ForcedSeedEndTimestamp
        }

        table.insert(DATA_HISTORY, snapshot)
        analyze(snapshot)

        local now = os.time()
        if now - lastSendTime >= 300 then
            lastSendTime = now
            local predictions = predictNextStocks(snapshot.seed)
            local accuracy = crossValidate(snapshot.stocks, predictions)

            sendWebhook(createEmbed(snapshot, predictions, accuracy))
            appendLog(snapshot, predictions, accuracy)
        end
    end
    return result
end
