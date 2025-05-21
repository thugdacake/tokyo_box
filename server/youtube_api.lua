--[[
    Tokyo Box - YouTube API
    Sistema de integração com a API do YouTube
    Versão: 1.0.0
]]

local Config = require 'config'

-- API do YouTube
local YouTubeAPI = {
    isInitialized = false,
    apiKey = Config.YouTube.APIKey,
    quotaLimit = Config.YouTube.QuotaLimit,
    quotaUsed = 0,
    lastReset = os.time()
}

-- Cache de vídeos
local videoCache = {}
local lastRequest = 0
local consecutiveErrors = 0
local CacheCleanupInterval = 3600 -- 1 hora em segundos

-- Função de log
local function Log(level, message)
    if not Config.System.DebugMode and level == "debug" then
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

-- Função para verificar quota
local function checkQuota()
    local now = os.time()
    
    -- Reset diário
    if now - YouTubeAPI.lastReset > 24 * 60 * 60 then
        YouTubeAPI.quotaUsed = 0
        YouTubeAPI.lastReset = now
    end
    
    -- Verificar limite
    if YouTubeAPI.quotaUsed >= YouTubeAPI.quotaLimit then
        return false
    end
    
    return true
end

-- Função para fazer requisição à API
local function MakeRequest(endpoint, params)
    if not YouTubeAPI.apiKey or YouTubeAPI.apiKey == "" then
        Log("error", "API key do YouTube não configurada")
        return nil
    end

    -- Verificar intervalo entre requisições
    local now = os.time()
    if now - lastRequest < Config.YouTube.RequestInterval / 1000 then
        Wait(Config.YouTube.RequestInterval)
    end
    lastRequest = now

    -- Adicionar API key aos parâmetros
    params.key = YouTubeAPI.apiKey

    -- Construir URL
    local url = Config.API.BaseURL .. endpoint
    local queryString = ""
    for k, v in pairs(params) do
        queryString = queryString .. k .. "=" .. v .. "&"
    end
    url = url .. "?" .. queryString:sub(1, -2)

    -- Fazer requisição
    local response = nil
    local attempts = 0
    while attempts < Config.System.ErrorRetryCount do
        response = PerformHttpRequest(url, function(err, text, headers)
            if err then
                if not HandleError(err, "MakeRequest") then
                    return nil
                end
                attempts = attempts + 1
                Wait(Config.System.ErrorRetryDelay)
            else
                consecutiveErrors = 0
                return text
            end
        end)
        if response then break end
    end

    return response
end

-- Função para buscar vídeo
function YouTubeAPI.SearchVideo(query)
    if not query or query == "" then
        return false, {error = "Query inválida"}
    end
    
    -- Verificar quota
    if not checkQuota() then
        return false, {error = "Limite de quota excedido"}
    end
    
    -- Verificar cache
    if videoCache[query] and GetGameTimer() - videoCache[query].timestamp < Config.YouTube.CacheDuration * 1000 then
        YouTubeAPI.quotaUsed = YouTubeAPI.quotaUsed + 100
        return true, videoCache[query].data
    end
    
    -- Fazer requisição
    local response = MakeRequest(Config.API.Endpoints.Search, {
        part = "snippet",
        q = query,
        type = "video",
        maxResults = 10
    })

    if not response then return false, {error = "Erro ao buscar vídeo"} end

    -- Processar resposta
    local data = json.decode(response)
    if not data or not data.items or #data.items == 0 then
        return false, {error = "Nenhum vídeo encontrado"}
    end

    -- Salvar em cache
    videoCache[query] = {
        data = data.items[1],
        timestamp = GetGameTimer()
    }

    YouTubeAPI.quotaUsed = YouTubeAPI.quotaUsed + 100
    return true, data.items[1]
end

-- Função para obter detalhes do vídeo
function YouTubeAPI.GetVideoDetails(videoId)
    if not videoId or videoId == "" then
        return false, {error = "ID do vídeo inválido"}
    end
    
    -- Verificar quota
    if not checkQuota() then
        return false, {error = "Limite de quota excedido"}
    end
    
    -- Verificar cache
    if videoCache[videoId] and GetGameTimer() - videoCache[videoId].timestamp < Config.YouTube.CacheDuration * 1000 then
        YouTubeAPI.quotaUsed = YouTubeAPI.quotaUsed + 1
        return true, videoCache[videoId].data
    end
    
    -- Fazer requisição
    local response = MakeRequest(Config.API.Endpoints.Video, {
        part = "snippet,contentDetails",
        id = videoId
    })

    if not response then return false, {error = "Erro ao buscar detalhes do vídeo"} end

    -- Processar resposta
    local data = json.decode(response)
    if not data or not data.items or #data.items == 0 then
        return false, {error = "Nenhum vídeo encontrado"}
    end

    -- Salvar em cache
    videoCache[videoId] = {
        data = data.items[1],
        timestamp = GetGameTimer()
    }

    YouTubeAPI.quotaUsed = YouTubeAPI.quotaUsed + 1
    return true, data.items[1]
end

-- Função para validar ID do YouTube
function YouTubeAPI.ValidateId(id, type)
    if not id or id == '' then
        return false, 'ID inválido'
    end
    
    if type == 'video' then
        return id:match('^[%w_-]{11}$') ~= nil
    elseif type == 'playlist' then
        return id:match('^[%w_-]{34}$') ~= nil
    end
    
    return false, 'Tipo inválido'
end

-- Função para obter informações da quota
function YouTubeAPI.GetQuotaInfo()
    return {
        used = YouTubeAPI.quotaUsed,
        limit = YouTubeAPI.quotaLimit,
        resetIn = YouTubeAPI.quotaLimit - YouTubeAPI.quotaUsed
    }
end

-- Função para resetar quota
function YouTubeAPI.ResetQuota()
    YouTubeAPI.quotaUsed = 0
    YouTubeAPI.lastReset = os.time()
end

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

-- Exportar funções
exports("SearchVideo", YouTubeAPI.SearchVideo)
exports("GetVideoDetails", YouTubeAPI.GetVideoDetails)

-- Adicionar limpeza periódica do cache
Citizen.CreateThread(function()
    while true do
        Wait(CacheCleanupInterval * 1000)
        CleanExpiredCache()
    end
end)

return YouTubeAPI
