local HttpService = game:GetService("HttpService")
local DataService = require(game:GetService("ReplicatedStorage").Modules.DataService)
local bit32 = require("bit32")

local WebhookURL = "https://discord.com/api/webhooks/1401012390140710996/XBUD3c1lFUAqGU8xNoFh9Y5drOampi3JQJK1thWyH_1Zed4E8KA2_jqanuo02ILy3b3t"
local LOG_FILE = "SeedShopLog.txt"

-- Full list of all possible seeds in the game
local ALL_SEEDS = {
    "Carrot", "Strawberry", "Blueberry", "Orange Tulip", "Tomato", 
    "Corn", "Daffodil", "Watermelon", "Pumpkin", "Apple", "Bamboo", 
    "Coconut", "Cactus", "Dragon Fruit", "Mango", "Grape", "Mushroom", 
    "Pepper", "Cacao", "Beanstalk", "Ember Lily", "Sugar Apple", 
    "Burning Bud", "Giant Pinecone", "Elder Strawberry"
}

local DATA_HISTORY = {}
local ANALYZER = {
    last_seed = nil,
    seed_deltas = {},
    item_patterns = {},
    seed_to_items = {},
    known_items = {},  -- Tracks which items we've seen before
    prediction_model = {
        active = {},
        accuracy = 0,
        algorithm = "basic_seed_modulo"
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

-- Save log to file
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
        "  Known Items: " .. table.concat(ANALYZER.known_items, ", "),
        snapshot.forcedRestock and ("⚠️ Forced Restock: " .. os.date("%Y-%m-%d %H:%M:%S", snapshot.forcedRestock)) or "",
        ""
    }

    writefile(LOG_FILE, (isfile(LOG_FILE) and readfile(LOG_FILE) or "") .. table.concat(logLines, "\n"))
end

-- Webhook Sender
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

-- Parse historical data from log file
local function loadHistoricalData()
    if not isfile(LOG_FILE) then return end
    
    local logContent = readfile(LOG_FILE)
    for seed, items in logContent:gmatch("Current Seed: (%d+).-📦 Current Stocks:%s*([%w%p%s]+)🔮") do
        local itemList = {}
        for item in items:gmatch("([%a%s]+):") do
            item = item:gsub("%s+$", "")  -- Trim trailing whitespace
            itemList[item] = true
            
            -- Add to known items if new
            if not table.find(ANALYZER.known_items, item) then
                table.insert(ANALYZER.known_items, item)
            end
        end
        ANALYZER.seed_to_items[tonumber(seed)] = itemList
    end
end

-- Test different prediction algorithms
local function testAlgorithms(seed)
    local algorithms = {
        basic_seed_modulo = function()
            local predicted = {}
            for _, item in ipairs(ALL_SEEDS) do
                -- Skip items we've never seen before
                if table.find(ANALYZER.known_items, item) then
                    local modValue = #item * 7
                    if seed % modValue < 3 then
                        predicted[item] = 1
                    end
                end
            end
            return predicted
        end,

        bitwise_pattern = function()
            local predicted = {}
            for index, item in ipairs(ALL_SEEDS) do
                -- Only predict items we've seen before
                if table.find(ANALYZER.known_items, item) then
                    local bitMask = bit32.lshift(1, (index - 1) % 24)
                    if bit32.band(seed, bitMask) ~= 0 then
                        predicted[item] = 1
                    end
                end
            end
            return predicted
        end,

        historical_match = function()
            local predicted = {}
            local seedStr = tostring(seed)
            local last3 = #seedStr >= 3 and seedStr:sub(-3) or seedStr
            
            -- Find similar seeds based on last 3 digits
            local similarSeeds = {}
            for s, items in pairs(ANALYZER.seed_to_items) do
                local sStr = tostring(s)
                if #sStr >= 3 and sStr:sub(-3) == last3 then
                    table.insert(similarSeeds, s)
                end
            end
            
            if #similarSeeds > 0 then
                local freq = {}
                for _, s in ipairs(similarSeeds) do
                    for item in pairs(ANALYZER.seed_to_items[s]) do
                        freq[item] = (freq[item] or 0) + 1
                    end
                end
                
                -- Include items that appear in >50% of similar seeds
                for item, count in pairs(freq) do
                    if count / #similarSeeds > 0.5 then
                        predicted[item] = 1
                    end
                end
            end
            return predicted
        end,

        item_cooccurrence = function()
            local predicted = {}
            -- Simple co-occurrence based on most frequent items
            for item, count in pairs(ANALYZER.item_patterns) do
                if count > #DATA_HISTORY * 0.3 then  -- Appears in >30% of history
                    predicted[item] = 1
                end
            end
            return predicted
        end
    }

    local bestAlgorithm, bestAccuracy = "", 0
    for name, algo in pairs(algorithms) do
        local tempPredicted = algo()
        local accuracy = 0
        
        if ANALYZER.seed_to_items[seed] then
            local correct = 0
            local total = 0
            
            -- Check true positives
            for item in pairs(tempPredicted) do
                if ANALYZER.seed_to_items[seed][item] then
                    correct = correct + 1
                end
                total = total + 1
            end
            
            -- Check false negatives
            for item in pairs(ANALYZER.seed_to_items[seed]) do
                if not tempPredicted[item] then
                    total = total + 1
                end
            end
            
            accuracy = total > 0 and (correct / total) or 0
        end
        
        if accuracy > bestAccuracy then
            bestAlgorithm = name
            bestAccuracy = accuracy
        end
    end

    ANALYZER.prediction_model.algorithm = bestAlgorithm ~= "" and bestAlgorithm or "basic_seed_modulo"
    return algorithms[ANALYZER.prediction_model.algorithm]()
end

-- Analysis function
local function analyze(snapshot)
    if ANALYZER.last_seed then
        table.insert(ANALYZER.seed_deltas, snapshot.seed - ANALYZER.last_seed)
    end
    ANALYZER.last_seed = snapshot.seed

    local currentItems = {}
    for item in pairs(snapshot.stocks) do
        currentItems[item] = true
        
        -- Track item appearance patterns
        ANALYZER.item_patterns[item] = (ANALYZER.item_patterns[item] or 0) + 1
        
        -- Add to known items if new
        if not table.find(ANALYZER.known_items, item) then
            table.insert(ANALYZER.known_items, item)
        end
    end
    ANALYZER.seed_to_items[snapshot.seed] = currentItems
end

-- Prediction function
local function predictNextStocks(seed)
    -- First try exact historical matches
    if ANALYZER.seed_to_items[seed] then
        local exactMatch = {}
        for item in pairs(ANALYZER.seed_to_items[seed]) do
            exactMatch[item] = 1
        end
        ANALYZER.prediction_model.algorithm = "exact_historical_match"
        return exactMatch
    end

    return testAlgorithms(seed)
end

-- Validation function
local function crossValidate(actualStocks, predictedStocks)
    local correct = 0
    local total = 0
    
    -- Check true positives
    for item in pairs(predictedStocks) do
        if actualStocks[item] then
            correct = correct + 1
        end
        total = total + 1
    end
    
    -- Check false negatives
    for item in pairs(actualStocks) do
        if not predictedStocks[item] then
            total = total + 1
        end
    end
    
    return total > 0 and math.floor((correct / total) * 100) or 0
end

-- Embed Builder
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
        value = string.format("Current Seed: `%s`\nLast Delta: `%s`\nAlgorithm: `%s`\nKnown Items: `%d/%d`",
            tostring(snapshot.seed),
            delta and tostring(delta) or "N/A",
            ANALYZER.prediction_model.algorithm,
            #ANALYZER.known_items,
            #ALL_SEEDS),
        inline = false
    })

    if snapshot.forcedRestock then
        local restockTime = DateTime.fromUnixTimestamp(snapshot.forcedRestock)
        local restockCST = os.date("!%A, %B %d, %Y at %I:%M:%S %p", restockTime.UnixTimestamp - cstOffset)
        table.insert(embed.fields, { name = "⚠️ Forced Restock", value = restockCST, inline = false })
    end

    return { embeds = { embed } }
end

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
