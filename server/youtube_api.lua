--[[
    Tokyo Box - YouTube API
    Sistema de integração com a API do YouTube
    Versão: 1.0.0
]]

-- Carregar configurações
local QBCore = exports['qb-core']:GetCoreObject()

-- API do YouTube
local YouTubeAPI = {
    isInitialized = false,
    apiKey = Config.YouTube.apiKey,
    quotaLimit = Config.YouTube.quotaLimit,
    quotaUsed = 0,
    lastReset = os.time()
}

-- Cache de vídeos
local videoCache = {}
local lastRequest = 0
local consecutiveErrors = 0
local CacheCleanupInterval = 3600 -- 1 hora em segundos
local cache = {}
local lastQuotaReset = os.time()

-- Cache de requisições
local requestCache = {}
local requestCount = {}
local lastReset = os.time()

-- Função de log
local function Log(level, message)
    if not Config.Debug.enabled and level == "debug" then
        return
    end
    
    local prefix = "[Tokyo Box YouTube]"
    if level == "debug" then
        prefix = prefix .. " [DEBUG]"
    elseif level == "info" then
        prefix = prefix .. " [INFO]"
    elseif level == "warn" then
        prefix = prefix .. " [WARN]"
    elseif level == "error" then
        prefix = prefix .. " [ERROR]"
    end
    
    print(prefix .. " " .. message)
end

-- Função de tratamento de erros
local function HandleError(error, context)
    YouTubeAPI.lastError = error
    consecutiveErrors = consecutiveErrors + 1
    
    Log("error", "Erro em " .. context .. ": " .. error)
    
    if consecutiveErrors >= Config.System.ErrorRetryCount then
        Log("error", "Muitos erros consecutivos detectados. Reiniciando recurso...")
        TriggerEvent("tokyo_box:restartResource")
    end
    
    return false
end

-- Validar estado da API
local function ValidateState()
    if not YouTubeAPI.isInitialized then
        HandleError("API não inicializada", "ValidateState")
        return false
    end
    return true
end

-- Limpar cache expirado
local function CleanExpiredCache()
    local now = GetGameTimer()
    local expiredCount = 0
    
    for videoId, data in pairs(videoCache) do
        if now - data.timestamp > Config.YouTube.CacheDuration * 1000 then
            videoCache[videoId] = nil
            expiredCount = expiredCount + 1
        end
    end
    
    if expiredCount > 0 then
        Log("info", string.format("Limpos %d itens do cache", expiredCount))
    end
end

-- Funções auxiliares
local function resetQuota()
    local currentTime = os.time()
    if currentTime - lastQuotaReset >= 86400 then -- 24 horas
        YouTubeAPI.quotaUsed = 0
        YouTubeAPI.lastReset = currentTime
    end
end

local function checkQuota()
    resetQuota()
    return YouTubeAPI.quotaUsed < YouTubeAPI.quotaLimit
end

local function updateQuota(cost)
    YouTubeAPI.quotaUsed = YouTubeAPI.quotaUsed + cost
end

local function getVideoId(url)
    if not url then return nil end
    
    -- Verificar se é um ID direto
    if string.len(url) == 11 then
        return url
    end
    
    -- Extrair ID da URL
    local patterns = {
        "youtube.com/watch%?v=([^&]+)",
        "youtu.be/([^?]+)",
        "youtube.com/embed/([^?]+)",
        "youtube.com/v/([^?]+)"
    }
    
    for _, pattern in ipairs(patterns) do
        local id = string.match(url, pattern)
        if id then return id end
    end
    
    return nil
end

local function formatDuration(duration)
    local hours = string.match(duration, "(%d+)H")
    local minutes = string.match(duration, "(%d+)M")
    local seconds = string.match(duration, "(%d+)S")
    
    hours = hours and tonumber(hours) or 0
    minutes = minutes and tonumber(minutes) or 0
    seconds = seconds and tonumber(seconds) or 0
    
    return hours * 3600 + minutes * 60 + seconds
end

-- Funções auxiliares
local function log(message)
    if Config.Debug then
        print("^3[DEBUG] Tokyo Box - YouTube API: " .. message .. "^7")
    end
end

local function checkRateLimit(source)
    local currentTime = os.time()
    
    -- Resetar contador a cada minuto
    if currentTime - lastReset >= Config.Security.rateLimit.window then
        requestCount = {}
        lastReset = currentTime
    end
    
    -- Incrementar contador
    requestCount[source] = (requestCount[source] or 0) + 1
    
    -- Verificar limite
    if requestCount[source] > Config.Security.rateLimit.max then
        return false
    end
    
    return true
end

local function isAllowedDomain(url)
    for _, domain in ipairs(Config.Security.allowedDomains) do
        if string.find(url, domain) then
            return true
        end
    end
    return false
end

-- Funções da API
local function searchVideos(query, cb)
    if not query or query == "" then
        if cb then
            cb({ error = "Query inválida" })
        end
        return
    end
    
    -- Verificar cache
    local cacheKey = "search:" .. query
    if Config.Cache.enabled and requestCache[cacheKey] then
        local cache = requestCache[cacheKey]
        if os.time() - cache.time < Config.Cache.ttl then
            if cb then
                cb(cache.data)
            end
            return
        end
    end
    
    -- Fazer requisição à API
    local url = string.format("%s/search?part=snippet&q=%s&type=video&maxResults=%d&key=%s",
        Config.API.baseUrl,
        query,
        Config.API.maxResults,
        Config.API.key
    )
    
    PerformHttpRequest(url, function(errorCode, resultData, resultHeaders)
        if errorCode ~= 200 then
            if cb then
                cb({ error = "Erro na API" })
            end
            return
        end
        
        local result = json.decode(resultData)
        if not result or not result.items then
            if cb then
                cb({ error = "Erro ao processar resultados" })
            end
            return
        end
        
        -- Processar resultados
        local videos = {}
        for _, item in ipairs(result.items) do
            if item.id and item.id.videoId then
                table.insert(videos, {
                    id = item.id.videoId,
                    title = item.snippet.title,
                    thumbnail = item.snippet.thumbnails.default.url,
                    duration = "0:00" -- Duração precisa de outra requisição
                })
            end
        end
        
        -- Salvar no cache
        if Config.Cache.enabled then
            requestCache[cacheKey] = {
                time = os.time(),
                data = videos
            }
            
            -- Limpar cache antigo
            local count = 0
            for k, v in pairs(requestCache) do
                count = count + 1
                if count > Config.Cache.maxSize then
                    requestCache[k] = nil
                end
            end
        end
        
        if cb then
            cb(videos)
        end
    end, "GET", "", { ["Content-Type"] = "application/json" })
end

local function getVideoDetails(videoId, cb)
    if not videoId or videoId == "" then
        if cb then
            cb({ error = "ID do vídeo inválido" })
        end
        return
    end
    
    -- Verificar cache
    local cacheKey = "video:" .. videoId
    if Config.Cache.enabled and requestCache[cacheKey] then
        local cache = requestCache[cacheKey]
        if os.time() - cache.time < Config.Cache.ttl then
            if cb then
                cb(cache.data)
            end
            return
        end
    end
    
    -- Fazer requisição à API
    local url = string.format("%s/videos?part=contentDetails,snippet&id=%s&key=%s",
        Config.API.baseUrl,
        videoId,
        Config.API.key
    )
    
    PerformHttpRequest(url, function(errorCode, resultData, resultHeaders)
        if errorCode ~= 200 then
            if cb then
                cb({ error = "Erro na API" })
            end
            return
        end
        
        local result = json.decode(resultData)
        if not result or not result.items or #result.items == 0 then
            if cb then
                cb({ error = "Erro ao processar resultados" })
            end
            return
        end
        
        -- Processar resultado
        local video = result.items[1]
        local details = {
            id = video.id,
            title = video.snippet.title,
            thumbnail = video.snippet.thumbnails.default.url,
            duration = video.contentDetails.duration
        }
        
        -- Salvar no cache
        if Config.Cache.enabled then
            requestCache[cacheKey] = {
                time = os.time(),
                data = details
            }
            
            -- Limpar cache antigo
            local count = 0
            for k, v in pairs(requestCache) do
                count = count + 1
                if count > Config.Cache.maxSize then
                    requestCache[k] = nil
                end
            end
        end
        
        if cb then
            cb(details)
        end
    end, "GET", "", { ["Content-Type"] = "application/json" })
end

-- Eventos
RegisterNetEvent("tokyo_box:search")
AddEventHandler("tokyo_box:search", function(query)
    local source = source
    
    -- Verificar limite de requisições
    if not checkRateLimit(source) then
        TriggerClientEvent("tokyo_box:searchResults", source, { error = "Limite de requisições excedido" })
        return
    end
    
    -- Buscar vídeos
    searchVideos(query, function(results)
        TriggerClientEvent("tokyo_box:searchResults", source, results)
    end)
end)

RegisterNetEvent("tokyo_box:getVideoDetails")
AddEventHandler("tokyo_box:getVideoDetails", function(videoId)
    local source = source
    
    -- Verificar limite de requisições
    if not checkRateLimit(source) then
        TriggerClientEvent("tokyo_box:videoDetails", source, { error = "Limite de requisições excedido" })
        return
    end
    
    -- Buscar detalhes do vídeo
    getVideoDetails(videoId, function(details)
        TriggerClientEvent("tokyo_box:videoDetails", source, details)
    end)
end)

-- Exportações
exports('SearchVideos', searchVideos)
exports('GetVideoDetails', getVideoDetails)
exports('GetVideoId', getVideoId)
exports('GetQuotaUsed', function() return YouTubeAPI.quotaUsed end)
exports('GetQuotaLimit', function() return YouTubeAPI.quotaLimit end)
exports('GetQuotaInfo', function()
    return {
        used = YouTubeAPI.quotaUsed,
        limit = YouTubeAPI.quotaLimit,
        resetIn = YouTubeAPI.quotaLimit - YouTubeAPI.quotaUsed
    }
end)
exports('ResetQuota', function()
    YouTubeAPI.quotaUsed = 0
    YouTubeAPI.lastReset = os.time()
end)
exports('ClearCache', function()
    requestCache = {}
    requestCount = {}
    lastReset = os.time()
end)

-- Inicialização
Citizen.CreateThread(function()
    -- Verificar API key
    if not YouTubeAPI.apiKey or YouTubeAPI.apiKey == "" then
        HandleError("API key do YouTube não configurada", "Initialize")
        return
    end
    
    -- Verificar URL base
    if not Config.API.BaseURL or Config.API.BaseURL == "" then
        HandleError("URL base da API não configurada", "Initialize")
        return
    end
    
    YouTubeAPI.isInitialized = true
    Log("info", "API do YouTube inicializada")
    
    -- Registrar eventos
    RegisterNetEvent("tokyo_box:searchVideo")
    AddEventHandler("tokyo_box:searchVideo", function(query)
        local source = source
        local success, result = YouTubeAPI.SearchVideo(query)
        TriggerClientEvent("tokyo_box:searchVideoResult", source, {
            success = success,
            data = result
        })
    end)
    
    RegisterNetEvent("tokyo_box:getVideoDetails")
    AddEventHandler("tokyo_box:getVideoDetails", function(videoId)
        local source = source
        local success, result = YouTubeAPI.GetVideoDetails(videoId)
        TriggerClientEvent("tokyo_box:getVideoDetailsResult", source, {
            success = success,
            data = result
        })
    end)
end)

-- Adicionar limpeza periódica do cache
Citizen.CreateThread(function()
    while true do
        Wait(CacheCleanupInterval * 1000)
        CleanExpiredCache()
    end
end)

-- Inicialização
CreateThread(function()
    while true do
        Wait(60000) -- Verificar a cada minuto
        resetQuota()
    end
end)

return YouTubeAPI
