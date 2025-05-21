--[[
    Tokyo Box - Eventos do Servidor
    Versão: 1.0.0
]]

-- Carregar configuração
local Config = nil

-- Função para carregar configuração
local function LoadConfig()
    local success, result = pcall(function()
        return exports['tokyo_box']:GetConfig()
    end)
    
    if not success or not result then
        print("^1[Tokyo Box] Erro ao carregar configuração^0")
        return false
    end
    
    Config = result
    return true
end

-- Verificar configuração
if not LoadConfig() then
    print("^1[Tokyo Box] Erro: Configuração não encontrada^0")
    return
end

-- Função de log
local function log(level, message)
    if not Config.Debug.enabled and level == "debug" then
        return
    end
    local prefix = "[Tokyo Box]"
    prefix = prefix .. " [" .. level:upper() .. "]"
    print(prefix .. " " .. message)
end

-- Função de erro
local function handleError(err, context)
    log("error", string.format("Erro em %s: %s", context, err))
    return false
end

-- Eventos
RegisterNetEvent('tokyo_box:server:playMusic', function(data)
    local source = source
    
    if not data or not data.url then
        log("error", "Dados inválidos para tocar música")
        return
    end
    
    TriggerClientEvent('tokyo_box:client:playMusic', -1, {
        source = source,
        url = data.url,
        volume = data.volume or Config.Player.defaultVolume
    })
end)

RegisterNetEvent('tokyo_box:server:stopMusic', function()
    local source = source
    TriggerClientEvent('tokyo_box:client:stopMusic', -1, source)
end)

RegisterNetEvent('tokyo_box:server:updateVolume', function(volume)
    local source = source
    
    if not volume or type(volume) ~= "number" then
        log("error", "Volume inválido")
        return
    end
    
    -- Verificar limites
    volume = math.max(Config.Player.minVolume, math.min(Config.Player.maxVolume, volume))
    
    TriggerClientEvent('tokyo_box:client:updateVolume', -1, {
        source = source,
        volume = volume
    })
end)

RegisterNetEvent('tokyo_box:server:addToPlaylist', function(data)
    local source = source
    
    if not data or not data.url or not data.title then
        log("error", "Dados inválidos para adicionar à playlist")
        return
    end
    
    -- Verificar permissões
    if not Config.Permissions.playlist then
        log("error", "Jogador sem permissão para gerenciar playlists")
        return
    end
    
    -- Adicionar à playlist
    MySQL.insert('INSERT INTO tokyo_box_playlists (name, tracks) VALUES (?, ?)', {
        data.title,
        json.encode({
            {
                url = data.url,
                title = data.title,
                thumbnail = data.thumbnail,
                duration = data.duration
            }
        })
    }, function(id)
        if id then
            TriggerClientEvent('tokyo_box:client:updatePlaylist', source, {
                id = id,
                name = data.title,
                tracks = {
                    {
                        url = data.url,
                        title = data.title,
                        thumbnail = data.thumbnail,
                        duration = data.duration
                    }
                }
            })
        end
    end)
end)

RegisterNetEvent('tokyo_box:server:removeFromPlaylist', function(data)
    local source = source
    
    if not data or not data.id then
        log("error", "Dados inválidos para remover da playlist")
        return
    end
    
    -- Verificar permissões
    if not Config.Permissions.playlist then
        log("error", "Jogador sem permissão para gerenciar playlists")
        return
    end
    
    -- Remover da playlist
    MySQL.query('DELETE FROM tokyo_box_playlists WHERE id = ?', {data.id}, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('tokyo_box:client:updatePlaylist', source, {
                id = data.id,
                removed = true
            })
        end
    end)
end)

RegisterNetEvent('tokyo_box:server:getPlaylists', function()
    local source = source
    
    -- Verificar permissões
    if not Config.Permissions.playlist then
        log("error", "Jogador sem permissão para ver playlists")
        return
    end
    
    -- Buscar playlists
    MySQL.query('SELECT * FROM tokyo_box_playlists', {}, function(results)
        if results then
            TriggerClientEvent('tokyo_box:client:updatePlaylists', source, results)
        end
    end)
end)

RegisterNetEvent('tokyo_box:server:searchMusic', function(query)
    local source = source
    
    if not query or query == "" then
        log("error", "Query de busca inválida")
        return
    end
    
    -- Verificar permissões
    if not Config.Permissions.search then
        log("error", "Jogador sem permissão para buscar músicas")
        return
    end
    
    -- Buscar música
    local result = exports['tokyo_box']:SearchVideo(query)
    if result then
        TriggerClientEvent('tokyo_box:client:searchResult', source, result)
    end
end)
