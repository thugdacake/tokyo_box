-- Cache de requisições
local requestCache = {}
local requestCount = {}
local lastReset = os.time()

-- Função para verificar limite de requisições
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

-- Função para verificar domínio permitido
local function isAllowedDomain(url)
    for _, domain in ipairs(Config.Security.allowedDomains) do
        if string.find(url, domain) then
            return true
        end
    end
    return false
end

-- Função para buscar vídeos
local function searchVideos(query)
    if not query or query == "" then
        return { error = "Query inválida" }
    end
    
    -- Verificar cache
    local cacheKey = "search:" .. query
    if Config.Cache.enabled and requestCache[cacheKey] then
        local cache = requestCache[cacheKey]
        if os.time() - cache.time < Config.Cache.ttl then
            return cache.data
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
            TriggerClientEvent("tokyo-box:searchResults", source, { error = "Erro na API" })
            return
        end
        
        local result = json.decode(resultData)
        if not result or not result.items then
            TriggerClientEvent("tokyo-box:searchResults", source, { error = "Erro ao processar resultados" })
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
        
        -- Enviar resultados
        TriggerClientEvent("tokyo-box:searchResults", source, videos)
    end, "GET", "", { ["Content-Type"] = "application/json" })
end

-- Eventos
RegisterNetEvent("tokyo-box:search")
AddEventHandler("tokyo-box:search", function(query)
    local source = source
    
    -- Verificar limite de requisições
    if not checkRateLimit(source) then
        TriggerClientEvent("tokyo-box:searchResults", source, { error = "Limite de requisições excedido" })
        return
    end
    
    -- Buscar vídeos
    searchVideos(query)
end)

RegisterNetEvent("tokyo-box:setVolume")
AddEventHandler("tokyo-box:setVolume", function(volume)
    local source = source
    
    -- Verificar volume
    if not volume or type(volume) ~= "number" or volume < Config.Player.minVolume or volume > Config.Player.maxVolume then
        TriggerClientEvent("tokyo-box:notification", source, {
            type = "error",
            message = "Volume inválido"
        })
        return
    end
    
    -- Atualizar volume
    TriggerClientEvent("tokyo-box:volumeChanged", -1, volume)
end)

-- Comandos
RegisterCommand("tokyobox_reload", function(source, args, rawCommand)
    -- Verificar permissão
    if Config.Permissions.enabled then
        local hasPermission = false
        for _, group in ipairs(Config.Permissions.groups) do
            if IsPlayerAceAllowed(source, "command.tokyobox_reload") then
                hasPermission = true
                break
            end
        end
        
        if not hasPermission then
            TriggerClientEvent("tokyo-box:notification", source, {
                type = "error",
                message = "Sem permissão"
            })
            return
        end
    end
    
    -- Recarregar recurso
    StopResource(GetCurrentResourceName())
    Wait(1000)
    StartResource(GetCurrentResourceName())
    
    TriggerClientEvent("tokyo-box:notification", source, {
        type = "success",
        message = "Recurso recarregado"
    })
end, false) 