local HttpService = game:GetService("HttpService")
local DataService = require(game:GetService("ReplicatedStorage").Modules.DataService)

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
        algorithm = "seed_modulo" -- Current algorithm being used
    },
    last_prediction = nil -- Stores last prediction for validation
}

local lastSendTime = 0

-------------------------------------------------
-- Helper: Convert table to readable string
-------------------------------------------------
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

-------------------------------------------------
-- Save log to file
-------------------------------------------------
local function appendLog(snapshot, predictions, accuracy)
    -- Round down timestamp to nearest 5 minutes
    local rounded = snapshot.timestamp - (snapshot.timestamp % 300)
    local timeStr = os.date("%Y-%m-%d %H:%M:%S", rounded)

    local logLines = {}
    table.insert(logLines, "=== Seed Shop Data @ " .. timeStr .. " ===")

    -- Current stocks
    table.insert(logLines, "📦 Current Stocks:")
    for _, line in ipairs(deepString(snapshot.stocks)) do
        table.insert(logLines, line)
    end

    -- Predictions
    table.insert(logLines, "🔮 Predicted Next Stocks:")
    for _, line in ipairs(deepString(predictions)) do
        table.insert(logLines, line)
    end

    -- Accuracy
    table.insert(logLines, "📊 Prediction Accuracy: " .. tostring(accuracy) .. "%")

    -- Seed data
    local delta = ANALYZER.seed_deltas[#ANALYZER.seed_deltas]
    table.insert(logLines, "🌱 Seed Data:")
    table.insert(logLines, "  Current Seed: " .. tostring(snapshot.seed))
    table.insert(logLines, "  Last Delta: " .. (delta and tostring(delta) or "N/A"))
    table.insert(logLines, "  Algorithm: " .. ANALYZER.prediction_model.algorithm)
    table.insert(logLines, "  Known Items: " .. table.concat(ANALYZER.known_items, ", "))

    -- Forced restock
    if snapshot.forcedRestock then
        table.insert(logLines, "⚠️ Forced Restock: " .. os.date("%Y-%m-%d %H:%M:%S", snapshot.forcedRestock))
    end

    table.insert(logLines, "\n")

    -- Append to file
    writefile(LOG_FILE, (isfile(LOG_FILE) and readfile(LOG_FILE) or "") .. table.concat(logLines, "\n") .. "\n")
end

-------------------------------------------------
-- Webhook Sender
-------------------------------------------------
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

-------------------------------------------------
-- Analysis & Prediction
-------------------------------------------------
local function analyze(snapshot)
    -- Track seed deltas
    if ANALYZER.last_seed then
        table.insert(ANALYZER.seed_deltas, snapshot.seed - ANALYZER.last_seed)
    end
    ANALYZER.last_seed = snapshot.seed
    
    -- Update known items
    for item in pairs(snapshot.stocks) do
        if not table.find(ANALYZER.known_items, item) then
            table.insert(ANALYZER.known_items, item)
        end
    end
    
    -- Store seed-item mapping
    ANALYZER.seed_to_items[snapshot.seed] = {}
    for item in pairs(snapshot.stocks) do
        ANALYZER.seed_to_items[snapshot.seed][item] = true
    end
end

-- Predict which items will be in stock based on seed patterns
local function predictNextStocks(seed)
    local predictions = {}
    local next_seed = seed + 1
    
    -- Try exact seed match first
    if ANALYZER.seed_to_items[next_seed] then
        ANALYZER.prediction_model.algorithm = "exact_match"
        for item in pairs(ANALYZER.seed_to_items[next_seed]) do
            predictions[item] = 1
        end
        return predictions
    end
    
    -- Pattern-based prediction
    ANALYZER.prediction_model.algorithm = "seed_modulo"
    
    -- Try modulo patterns that have worked in the past
    local patterns = {7, 11, 13, 17, 19, 23} -- Prime numbers for modulo
    
    for _, mod_value in ipairs(patterns) do
        local residue = next_seed % mod_value
        local found_match = false
        
        -- Check if we've seen this residue before
        for s, items in pairs(ANALYZER.seed_to_items) do
            if s % mod_value == residue then
                found_match = true
                for item in pairs(items) do
                    predictions[item] = (predictions[item] or 0) + 1
                end
            end
        end
        
        if found_match then
            -- Select items that appeared in at least 50% of matches
            local final_predictions = {}
            for item, count in pairs(predictions) do
                if count >= #patterns / 2 then
                    final_predictions[item] = 1
                end
            end
            return final_predictions
        end
    end
    
    -- Fallback: Most common items
    ANALYZER.prediction_model.algorithm = "frequency_fallback"
    local common_items = {"Carrot", "Strawberry", "Blueberry", "Tomato"}
    for _, item in ipairs(common_items) do
        predictions[item] = 1
    end
    
    return predictions
end

-- Validate prediction accuracy (presence only)
local function crossValidate(actualStocks, predictedStocks)
    if type(actualStocks) ~= "table" or type(predictedStocks) ~= "table" then
        return 0
    end
    
    local correct = 0
    local total = 0
    
    -- Check true positives
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

-------------------------------------------------
-- Embed Builder
-------------------------------------------------
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

-------------------------------------------------
-- Hooked GetData (send every 5 minutes max)
-------------------------------------------------
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
        
        -- Validate previous prediction if available
        local accuracy = 0
        if ANALYZER.last_prediction then
            accuracy = crossValidate(snapshot.stocks, ANALYZER.last_prediction)
        end
        
        analyze(snapshot)
        
        -- Predict next stocks
        local predictions = predictNextStocks(snapshot.seed)
        ANALYZER.last_prediction = predictions  -- Store for next validation

        local now = os.time()
        if now - lastSendTime >= 300 then
            lastSendTime = now
            sendWebhook(createEmbed(snapshot, predictions, accuracy))
            appendLog(snapshot, predictions, accuracy)
        end
    end
    return result
end
