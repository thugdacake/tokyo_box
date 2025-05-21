local QBCore = exports['qb-core']:GetCoreObject()
local cache = {}

-- Função para limpar o cache
local function clearCache()
    cache = {}
end

-- Função para buscar no YouTube
local function searchYouTube(query)
    if not Config.YouTube.enabled then
        return { error = 'API do YouTube desativada' }
    end

    if not Config.YouTube.apiKey or Config.YouTube.apiKey == '' then
        return { error = 'Chave da API do YouTube não configurada' }
    end

    -- Verificar cache
    if Config.Cache.enabled then
        local cached = cache[query]
        if cached and (os.time() - cached.timestamp) < Config.Cache.ttl then
            return cached.results
        end
    end

    -- Fazer requisição à API
    PerformHttpRequest(string.format(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&q=%s&maxResults=%d&type=video&key=%s&regionCode=%s&relevanceLanguage=%s',
        query,
        Config.YouTube.maxResults,
        Config.YouTube.apiKey,
        Config.YouTube.regionCode,
        Config.YouTube.language
    ), function(err, text, headers)
        if err ~= 200 then
            print('^1[ERRO] Falha na requisição à API do YouTube: ' .. tostring(err))
            return
        end

        local data = json.decode(text)
        if not data or not data.items then
            print('^1[ERRO] Resposta inválida da API do YouTube')
            return
        end

        -- Processar resultados
        local results = {}
        for _, item in ipairs(data.items) do
            table.insert(results, {
                id = item.id.videoId,
                title = item.snippet.title,
                description = item.snippet.description,
                thumbnail = item.snippet.thumbnails.high.url,
                channelTitle = item.snippet.channelTitle,
                publishedAt = item.snippet.publishedAt
            })
        end

        -- Salvar no cache
        if Config.Cache.enabled then
            cache[query] = {
                results = results,
                timestamp = os.time()
            }

            -- Limpar cache se exceder o tamanho máximo
            local count = 0
            for _ in pairs(cache) do
                count = count + 1
            end
            if count > Config.Cache.maxSize then
                clearCache()
            end
        end

        return results
    end, 'GET', '', { ['Content-Type'] = 'application/json' })
end

-- Eventos
RegisterNetEvent('tokyo_box:search')
AddEventHandler('tokyo_box:search', function(query, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    if not Config.Permissions.search then
        TriggerClientEvent('QBCore:Notify', src, 'Você não tem permissão para pesquisar', 'error')
        return
    end

    local results = searchYouTube(query)
    if results.error then
        TriggerClientEvent('QBCore:Notify', src, results.error, 'error')
        return
    end

    if cb then
        cb(results)
    else
        TriggerClientEvent('tokyo_box:updateResults', src, results)
    end
end)

-- Comandos
QBCore.Commands.Add('clearcache', 'Limpar cache do YouTube (Admin)', {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player.PlayerData.permission == 'admin' then
        TriggerClientEvent('QBCore:Notify', src, 'Você não tem permissão para usar este comando', 'error')
        return
    end

    clearCache()
    TriggerClientEvent('QBCore:Notify', src, 'Cache limpo com sucesso', 'success')
end)

-- Exportações
exports('SearchYouTube', searchYouTube)
exports('ClearCache', clearCache) 