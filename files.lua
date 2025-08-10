-- Seed Shop Self-Adaptive Predictor (Executor-friendly)
-- Features: time-based patterns, prev-seed conditioning, delta-based patterns, adaptive blending, persistence & logging

local HttpService = game:GetService("HttpService")
local DataService = require(game:GetService("ReplicatedStorage").Modules.DataService)

-- === Config ===
local WebhookURL = "https://discord.com/api/webhooks/1401012390140710996/XBUD3c1lFUAqGU8xNoFh9Y5drOampi3JQJK1thWyH_1Zed4E8KA2_jqanuo02ILy3b3t"
local LOG_FILE = "SeedShopLog.txt"
local HISTORY_FILE = "SeedShopHistory.json"
local MODEL_FILE = "SeedShopModel.json"
local SEND_INTERVAL = 300 -- seconds (5 minutes)
local SMOOTHING = 1 -- Laplace smoothing for small sample counts

-- === Base odds (from your table) ===
local BASE_ODDS = {
    ["Carrot"] = 1/1,
    ["Strawberry"] = 1/1,
    ["Blueberry"] = 1/1,
    ["Orange Tulip"] = 1/3,
    ["Tomato"] = 1/1,
    ["Corn"] = 1/6,
    ["Daffodil"] = 1/7,
    ["Watermelon"] = 1/8,
    ["Pumpkin"] = 1/10,
    ["Apple"] = 1/14,
    ["Bamboo"] = 1/5,
    ["Coconut"] = 1/20,
    ["Cactus"] = 1/30,
    ["Dragon Fruit"] = 1/50,
    ["Mango"] = 1/80,
    ["Grape"] = 1/100,
    ["Mushroom"] = 1/120,
    ["Pepper"] = 1/140,
    ["Cacao"] = 1/160,
    ["Beanstalk"] = 1/210,
    ["Ember Lily"] = 1/240,
    ["Sugar Apple"] = 1/290,
    ["Burning Bud"] = 1/340,
    ["Giant Pinecone"] = 1/380,
    ["Elder Strawberry"] = 1/405
}

-- === Internal state ===
local lastSendTime = 0
local DATA_HISTORY = {}        -- recent in-memory snapshots
local MODEL = {}               -- learned counts / probabilities / meta
local STATS = {                -- runtime aggregated stats (not necessarily persisted separately)
    total_samples = 0
}

-- Ensure MODEL has required structure
local function defaultModel()
    return {
        per_seed = {},           -- per_seed[name] = {count = n, total_stock = x, hourly = {0..23}, weekday = {0..6}, prev_seed = {seedName -> count}, delta_buckets = {bucket -> count}}
        blend_weights = {        -- weights to combine signals (sum not required; treated as multipliers normalized)
            base = 1.0,
            observed = 1.0,
            hour = 1.0,
            weekday = 0.8,
            prev = 1.0,
            delta = 0.5
        },
        last_trained_at = os.time()
    }
end

-- === Persistence helpers ===
local function safeReadJSON(path)
    if isfile(path) then
        local ok, raw = pcall(readfile, path)
        if not ok then return nil end
        local ok2, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
        if ok2 then return decoded end
    end
    return nil
end

local function safeWriteJSON(path, tbl)
    local ok, encoded = pcall(function() return HttpService:JSONEncode(tbl) end)
    if not ok then return false end
    pcall(writefile, path, encoded)
    return true
end

-- Load persisted model & history
local function loadState()
    local hist = safeReadJSON(HISTORY_FILE)
    if hist and type(hist) == "table" then
        HISTORY = hist
    else
        HISTORY = {}
    end

    local mdl = safeReadJSON(MODEL_FILE)
    if mdl and type(mdl) == "table" then
        MODEL = mdl
    else
        MODEL = defaultModel()
    end
end

local function saveHistory()
    pcall(function() safeWriteJSON(HISTORY_FILE, HISTORY) end)
end

local function saveModel()
    pcall(function() MODEL.last_trained_at = os.time(); safeWriteJSON(MODEL_FILE, MODEL) end)
end

-- initialize
loadState()

-- === Utility: deepString (sorted for readability) ===
local function keysSorted(tbl)
    local t = {}
    for k in pairs(tbl) do table.insert(t, k) end
    table.sort(t)
    return t
end

local function deepString(tbl, indent)
    indent = indent or 0
    local lines = {}
    if type(tbl) ~= "table" then
        return { tostring(tbl) }
    end
    for _, k in ipairs(keysSorted(tbl)) do
        local v = tbl[k]
        if type(v) == "table" then
            table.insert(lines, string.rep("  ", indent) .. tostring(k) .. ":")
            local sub = deepString(v, indent + 1)
            for _, l in ipairs(sub) do table.insert(lines, l) end
        else
            table.insert(lines, string.rep("  ", indent) .. tostring(k) .. ": " .. tostring(v))
        end
    end
    return lines
end

-- === Logging (append, rounded to 5-minute intervals) ===
local function appendLog(snapshot, predictions, accuracy)
    local rounded = snapshot.timestamp - (snapshot.timestamp % SEND_INTERVAL)
    local timeStr = os.date("%Y-%m-%d %H:%M:%S", rounded)

    local lines = {}
    table.insert(lines, "=== Seed Shop Data @ " .. timeStr .. " ===")
    table.insert(lines, "📦 Current Stocks:")
    for _, l in ipairs(deepString(snapshot.stocks)) do table.insert(lines, l) end

    table.insert(lines, "🔮 Predicted Next Stocks:")
    for _, l in ipairs(deepString(predictions)) do table.insert(lines, l) end

    table.insert(lines, "📊 Prediction Accuracy: " .. tostring(accuracy) .. "%")
    local delta = (MODEL.last_delta and tostring(MODEL.last_delta)) or "N/A"
    table.insert(lines, "🌱 Seed Data:")
    table.insert(lines, "  Current Seed: " .. tostring(snapshot.seed))
    table.insert(lines, "  Last Delta: " .. tostring(delta))
    if snapshot.forcedRestock then
        table.insert(lines, "⚠️ Forced Restock: " .. os.date("%Y-%m-%d %H:%M:%S", snapshot.forcedRestock))
    end
    table.insert(lines, "\n")

    local existing = (isfile(LOG_FILE) and readfile(LOG_FILE)) or ""
    writefile(LOG_FILE, existing .. table.concat(lines, "\n") .. "\n")
end

-- === Webhook sender (compatible with different executors) ===
local function sendWebhook(payload)
    local function requestWrapper(req)
        if syn and syn.request then return syn.request(req)
        elseif http and http.request then return http.request(req)
        elseif fluxus and fluxus.request then return fluxus.request(req)
        elseif http_request then return http_request(req)
        else
            -- fallback using HttpService (limited inside Roblox, but keep for safety)
            local ok, res = pcall(function()
                return HttpService:PostAsync(req.Url, req.Body or "", Enum.HttpContentType.ApplicationJson)
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
        return (res and (res.StatusCode == 204 or res.StatusCode == 200)) or false
    end)
    if not ok then warn("Webhook failed:", err) end
end

-- === Update MODEL with a new snapshot (incremental learning) ===
local function ensureSeedEntry(name)
    MODEL.per_seed[name] = MODEL.per_seed[name] or {
        count = 0,
        total_stock = 0,
        hourly = {},       -- hourly[0..23] = count occurrences
        weekday = {},      -- weekday[1..7] = count (os.date("%w") -> 0..6)
        prev_seed = {},    -- prev_seed[name] = count
        delta_buckets = {},-- delta bucket key -> count
        avg_stock = 0
    }
end

local function bucketDelta(delta)
    -- bucket ranges: 0-9,10-99,100-999,1000+
    if not delta then return "unknown" end
    local d = math.abs(delta)
    if d < 10 then return "d<10" end
    if d < 100 then return "d10-99" end
    if d < 1000 then return "d100-999" end
    return "d1000+"
end

local function updateModelFromSnapshot(snapshot, prevSeed)
    local ts = snapshot.timestamp or os.time()
    local hour = tonumber(os.date("%H", ts))
    local wday = tonumber(os.date("%w", ts)) + 1 -- 1..7
    local deltaBucket = bucketDelta(MODEL.last_delta)

    for seedName, stockInfo in pairs(snapshot.stocks or {}) do
        -- the stockInfo may be a number or table containing Stock and MaxStock - handle both
        local qty = nil
        if type(stockInfo) == "number" then
            qty = stockInfo
        elseif type(stockInfo) == "table" then
            -- try fields 'Stock' or 'stock'
            qty = tonumber(stockInfo.Stock) or tonumber(stockInfo.stock) or tonumber(stockInfo[1]) or 0
        else
            qty = 0
        end

        ensureSeedEntry(seedName)
        local entry = MODEL.per_seed[seedName]

        entry.count = (entry.count or 0) + 1
        entry.total_stock = (entry.total_stock or 0) + (qty or 0)
        entry.avg_stock = entry.total_stock / entry.count

        entry.hourly[hour] = (entry.hourly[hour] or 0) + 1
        entry.weekday[wday] = (entry.weekday[wday] or 0) + 1
        entry.delta_buckets[deltaBucket] = (entry.delta_buckets[deltaBucket] or 0) + 1

        if prevSeed then
            entry.prev_seed[prevSeed] = (entry.prev_seed[prevSeed] or 0) + 1
        end
    end

    MODEL.total_samples = (MODEL.total_samples or 0) + 1
    saveModel()
end

-- === Helper: compute observed frequency for a seed overall or conditional ===
local function observedFreq(seedName)
    local e = MODEL.per_seed[seedName]
    if not e then return 0 end
    local totalSamples = math.max(1, MODEL.total_samples or 0)
    return (e.count + SMOOTHING) / (totalSamples + SMOOTHING * 2)
end

local function observedFreqHour(seedName, hour)
    local e = MODEL.per_seed[seedName]
    if not e then return 0 end
    local hcount = e.hourly and (e.hourly[hour] or 0) or 0
    local denom = (e.count or 0) + SMOOTHING * 2
    return (hcount + SMOOTHING) / denom
end

local function observedFreqWeekday(seedName, wday)
    local e = MODEL.per_seed[seedName]
    if not e then return 0 end
    local hcount = e.weekday and (e.weekday[wday] or 0) or 0
    local denom = (e.count or 0) + SMOOTHING * 2
    return (hcount + SMOOTHING) / denom
end

local function observedFreqPrev(seedName, prevSeed)
    local e = MODEL.per_seed[seedName]
    if not e then return 0 end
    if not prevSeed then return 0 end
    local pcount = e.prev_seed and (e.prev_seed[prevSeed] or 0) or 0
    local denom = (e.count or 0) + SMOOTHING * 2
    return (pcount + SMOOTHING) / denom
end

local function observedFreqDelta(seedName, deltaBucket)
    local e = MODEL.per_seed[seedName]
    if not e then return 0 end
    local dcount = e.delta_buckets and (e.delta_buckets[deltaBucket] or 0) or 0
    local denom = (e.count or 0) + SMOOTHING * 2
    return (dcount + SMOOTHING) / denom
end

-- === Prediction function (blends many signals) ===
local function predictNextStocks(snapshot)
    local now = os.time()
    local hour = tonumber(os.date("%H", now))
    local wday = tonumber(os.date("%w", now)) + 1
    local prevSeed = MODEL.last_seen_seed
    local deltaBucket = bucketDelta(MODEL.last_delta)

    local predictions = {}
    -- iterate over all seeds known (union of BASE_ODDS and MODEL.per_seed)
    local seedSet = {}
    for k in pairs(BASE_ODDS) do seedSet[k] = true end
    for k in pairs(MODEL.per_seed) do seedSet[k] = true end

    for seedName in pairs(seedSet) do
        local base = BASE_ODDS[seedName] or 0.001
        local obs = observedFreq(seedName)        -- overall observed frequency
        local hourObs = observedFreqHour(seedName, hour)
        local wdObs = observedFreqWeekday(seedName, wday)
        local prevObs = observedFreqPrev(seedName, prevSeed)
        local deltaObs = observedFreqDelta(seedName, deltaBucket)

        -- weighted combination (weights adapt over time)
        local bw = MODEL.blend_weights or defaultModel().blend_weights
        local weighted = (bw.base * base)
                      + (bw.observed * obs)
                      + (bw.hour * hourObs)
                      + (bw.weekday * wdObs)
                      + (bw.prev * prevObs)
                      + (bw.delta * deltaObs)

        -- normalize roughly by sum of weights for scale-agnostic probabilities
        local weightSum = (bw.base + bw.observed + bw.hour + bw.weekday + bw.prev + bw.delta)
        local prob = (weighted / math.max(0.0001, weightSum))

        -- convert probability into expected stock count:
        -- use observed avg stock if available, otherwise a heuristic:
        local avgStock = (MODEL.per_seed[seedName] and MODEL.per_seed[seedName].avg_stock) or 1
        -- expected count = round(prob * max(1, avgStock * 1.2)) -- clamp to reasonable
        local expected = math.floor((prob * math.max(1, avgStock * 1.2)) + 0.5)

        -- small chance adjustment: if prob is near 1, set expected to at least observed avg
        if prob > 0.9 then
            expected = math.max(expected, math.floor(avgStock + 0.5))
        end

        predictions[seedName] = expected
    end

    return predictions
end

-- === Cross-validate accuracy ===
local function crossValidate(latestStocks, predictedStocks)
    if type(latestStocks) ~= "table" then return 0 end
    local correct = 0
    local total = 0
    for seedName, actualInfo in pairs(latestStocks) do
        local actualQty = 0
        if type(actualInfo) == "number" then actualQty = actualInfo
        elseif type(actualInfo) == "table" then
            actualQty = tonumber(actualInfo.Stock) or tonumber(actualInfo.stock) or tonumber(actualInfo[1]) or 0
        end
        local predictedQty = (predictedStocks and predictedStocks[seedName]) or 0
        -- treat a presence (qty>0) prediction as correct if both present/absent match
        if (predictedQty > 0 and actualQty > 0) or (predictedQty == 0 and actualQty == 0) then
            correct = correct + 1
        end
        total = total + 1
    end
    return total > 0 and math.floor((correct / total) * 100) or 0
end

-- === Adaptive blending update:
-- After each real refresh, compare predictions with actuals and nudge blend weights.
-- If model underpredicts a seed often, increase weight on observed signals.
-- If time-based signals predict well, increase their weights.
local function adaptWeights(predictions, actualSnapshot)
    -- compute per-signal performance proxies
    local signals = { observed = 0, hour = 0, weekday = 0, prev = 0, delta = 0 }
    local counts = { observed = 0, hour = 0, weekday = 0, prev = 0, delta = 0 }

    local hour = tonumber(os.date("%H", actualSnapshot.timestamp))
    local wday = tonumber(os.date("%w", actualSnapshot.timestamp)) + 1
    local prevSeed = MODEL.last_seen_seed
    local deltaBucket = bucketDelta(MODEL.last_delta)

    for seedName, actualInfo in pairs(actualSnapshot.stocks or {}) do
        local actualQty = 0
        if type(actualInfo) == "number" then actualQty = actualInfo
        elseif type(actualInfo) == "table" then
            actualQty = tonumber(actualInfo.Stock) or tonumber(actualInfo.stock) or tonumber(actualInfo[1]) or 0
        end
        local predictedQty = predictions[seedName] or 0

        -- signal contributions (presence-based)
        local actualPresent = actualQty > 0 and 1 or 0
        local predPresent = predictedQty > 0 and 1 or 0

        -- observed overall
        local obs = observedFreq(seedName)
        signals.observed = signals.observed + ( (obs > 0.001) and (predPresent == actualPresent and 1 or 0) or 0 )
        counts.observed = counts.observed + 1

        -- hour
        local hobs = observedFreqHour(seedName, hour)
        signals.hour = signals.hour + ((hobs > 0.001) and (predPresent == actualPresent and 1 or 0) or 0)
        counts.hour = counts.hour + 1

        -- weekday
        local wdobs = observedFreqWeekday(seedName, wday)
        signals.weekday = signals.weekday + ((wdobs > 0.001) and (predPresent == actualPresent and 1 or 0) or 0)
        counts.weekday = counts.weekday + 1

        -- prev
        local pobs = observedFreqPrev(seedName, prevSeed)
        signals.prev = signals.prev + ((pobs > 0.001) and (predPresent == actualPresent and 1 or 0) or 0)
        counts.prev = counts.prev + 1

        -- delta
        local dobs = observedFreqDelta(seedName, deltaBucket)
        signals.delta = signals.delta + ((dobs > 0.001) and (predPresent == actualPresent and 1 or 0) or 0)
        counts.delta = counts.delta + 1
    end

    -- compute accuracies per-signal
    local performance = {}
    for k, v in pairs(signals) do
        local c = math.max(1, counts[k])
        performance[k] = v / c -- fraction correct by signal
    end

    -- nudge weights toward better-performing signals (small learning rate)
    local lr = 0.05
    MODEL.blend_weights = MODEL.blend_weights or defaultModel().blend_weights
    -- normalize performance to [0,1] and adjust
    for k, val in pairs(performance) do
        local current = MODEL.blend_weights[k] or 1.0
        -- if performance > 0.5, increase weight slightly; else decrease slightly
        if val > 0.5 then
            current = current * (1 + lr * (val - 0.5))
        else
            current = current * (1 - lr * (0.5 - val))
        end
        MODEL.blend_weights[k] = math.max(0.01, math.min(current, 10)) -- clamp
    end

    saveModel()
end

-- === Embed builder ===
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

    table.insert(embed.fields, {
        name = "📦 Current Stocks",
        value = table.concat(deepString(snapshot.stocks or {}), "\n"),
        inline = false
    })

    table.insert(embed.fields, {
        name = "🔮 Predicted Next Stocks",
        value = table.concat(deepString(predictions or {}), "\n"),
        inline = false
    })

    table.insert(embed.fields, {
        name = "📊 Prediction Accuracy",
        value = tostring(accuracy) .. "%",
        inline = false
    })

    local delta = MODEL.last_delta or "N/A"
    table.insert(embed.fields, {
        name = "🌱 Seed Data",
        value = string.format("Current Seed: `%s`\nLast Delta: `%s`", tostring(snapshot.seed), tostring(delta)),
        inline = false
    })

    -- optionally append blend weight summary
    local bw = MODEL.blend_weights or {}
    table.insert(embed.fields, {
        name = "⚙️ Model Blend Weights",
        value = string.format("base: %.3f, observed: %.3f, hour: %.3f, weekday: %.3f, prev: %.3f, delta: %.3f",
            bw.base or 0, bw.observed or 0, bw.hour or 0, bw.weekday or 0, bw.prev or 0, bw.delta or 0),
        inline = false
    })

    return { embeds = { embed } }
end

-- === Hook DataService:GetData - update model on each call, send webhook once per SEND_INTERVAL ===
local originalGetData = DataService.GetData
local lastSeenSeed = nil

function DataService:GetData(...)
    local result = originalGetData(self, ...)
    if not result or not result.SeedStock then
        return result
    end

    -- Build snapshot
    local snapshot = {
        timestamp = os.time(),
        seed = result.SeedStock.Seed,
        stocks = result.SeedStock.Stocks,
        forcedRestock = result.SeedStock.ForcedSeedEndTimestamp
    }

    -- Save last delta & prev seed in MODEL for use in prediction
    if MODEL.last_seed then
        MODEL.last_delta = (snapshot.seed and MODEL.last_seed) and (snapshot.seed - MODEL.last_seed) or MODEL.last_delta
    end
    MODEL.last_seen_seed = MODEL.last_seen_seed or nil -- keep previous info
    -- Insert snapshot into in-memory & persisted history
    table.insert(DATA_HISTORY, snapshot)
    HISTORY = HISTORY or {}
    table.insert(HISTORY, snapshot)
    saveHistory()

    -- Update model statistics from snapshot
    updateModelFromSnapshot(snapshot, MODEL.last_seen_seed)

    -- set new last seed
    MODEL.last_seen_seed = snapshot.seed
    MODEL.last_seed = snapshot.seed

    -- Predict & possibly send (rate-limited)
    local now = os.time()
    if now - (lastSendTime or 0) >= SEND_INTERVAL then
        lastSendTime = now
        -- generate predictions using current MODEL & snapshot context
        local predictions = predictNextStocks(snapshot)
        local accuracy = crossValidate(snapshot.stocks, predictions)
        -- adapt weights based on performance
        adaptWeights(predictions, snapshot)

        -- send embed & log & persist model
        sendWebhook(createEmbed(snapshot, predictions, accuracy))
        appendLog(snapshot, predictions, accuracy)
        saveModel()
    end

    return result
end

-- Save initial model if not present
saveModel()

-- End of script
