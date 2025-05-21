--[[
    Tokyo Box - Eventos do Servidor
    Versão 1.0.1
]]

local QBCore = exports['qb-core']:GetCoreObject()

-- Função de log
local function Log(level, message)
    if not Config.System.DebugMode and level == "debug" then
        return
    end
    
    local prefix = "[Tokyo Box]"
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
    Log("error", "Erro em " .. context .. ": " .. error)
    return false
end

-- Validar estado do sistema
local function ValidateState()
    if not SystemState or not SystemState.isInitialized then
        HandleError("Sistema não inicializado", "ValidateState")
        return false
    end
    return true
end

-- Verificar permissões
local function HasPermission(source, permission)
    if not source then return false end
    
    -- Verificar se QBCore está disponível
    if not QBCore then
        Log("warn", "QBCore não encontrado, concedendo permissão por padrão")
        return true
    end
    
    -- Verificar grupos administrativos
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if not xPlayer then return false end
    
    local playerGroup = xPlayer.PlayerData.permission
    if not playerGroup then return false end
    
    -- Verificar se o grupo tem permissão
    for _, group in ipairs(Config.Permissions.AdminGroups) do
        if playerGroup == group then
            return true
        end
    end
    
    -- Verificar permissão específica
    if permission == "play" then
        return Config.Permissions.UsePlayer
    elseif permission == "create_playlist" then
        return Config.Permissions.CreatePlaylists
    elseif permission == "manage_playlist" then
        return Config.Permissions.ManagePlaylists
    end
    
    return false
end

-- Eventos de Playlist
RegisterNetEvent("tokyo_box:requestPlaylists")
AddEventHandler("tokyo_box:requestPlaylists", function(data, requestId)
    local source = source
    
    if not ValidateState() then
        if requestId then
            TriggerClientEvent("tokyo_box:clientResponse", source, {
                requestId = requestId,
                success = false,
                error = "Sistema não inicializado",
                fatal = true
            })
        end
        return
    end
    
    if not HasPermission(source, "play") then
        if requestId then
            TriggerClientEvent("tokyo_box:clientResponse", source, {
                requestId = requestId,
                success = false,
                error = "Você não tem permissão para acessar playlists",
                fatal = true
            })
        else
            TriggerClientEvent("tokyo_box:showNotification", source, "Você não tem permissão para acessar playlists", "error")
        end
        return
    end
    
    -- Buscar playlists do jogador
    exports.tokyo_box:GetPlaylistsByPlayer(source, function(playlists)
        -- Enviar playlists para o cliente
        if requestId then
            TriggerClientEvent("tokyo_box:clientResponse", source, {
                requestId = requestId,
                success = true,
                data = playlists
            })
        else
            TriggerClientEvent("tokyo_box:receivePlaylists", source, playlists)
        end
        Log("debug", string.format("Enviadas %d playlists para o jogador %s", #playlists, source))
    end)
end)

RegisterNetEvent("tokyo_box:createPlaylist")
AddEventHandler("tokyo_box:createPlaylist", function(data)
    local source = source
    
    if not ValidateState() then return end
    
    if not HasPermission(source, "create_playlist") then
        TriggerClientEvent("tokyo_box:showNotification", source, "Você não tem permissão para criar playlists", "error")
        return
    end
    
    if not data or not data.name or type(data.name) ~= "string" or data.name == "" then
        HandleError("Nome da playlist inválido", "createPlaylist")
        TriggerClientEvent("tokyo_box:showNotification", source, "Nome da playlist inválido", "error")
        return
    end
    
    -- Validar nome da playlist
    if #data.name < Config.Playlist.MinNameLength or #data.name > Config.Playlist.MaxNameLength then
        TriggerClientEvent("tokyo_box:showNotification", source, "Nome da playlist deve ter entre " .. Config.Playlist.MinNameLength .. " e " .. Config.Playlist.MaxNameLength .. " caracteres", "error")
        return
    end
    
    -- Criar playlist no banco de dados
    exports.tokyo_box:CreatePlaylist({
        name = data.name,
        coverUrl = data.coverUrl,
        createdBy = source
    }, function(playlist)
        if not playlist then
            TriggerClientEvent("tokyo_box:showNotification", source, "Erro ao criar playlist", "error")
            return
        end
        
        -- Notificar cliente
        TriggerClientEvent("tokyo_box:playlistCreated", source, playlist)
        Log("debug", string.format("Playlist '%s' criada pelo jogador %s", playlist.name, source))
    end)
end)

RegisterNetEvent("tokyo_box:deletePlaylist")
AddEventHandler("tokyo_box:deletePlaylist", function(data)
    local source = source
    
    if not ValidateState() then return end
    
    if not HasPermission(source, "manage_playlist") then
        TriggerClientEvent("tokyo_box:showNotification", source, "Você não tem permissão para excluir playlists", "error")
        return
    end
    
    if not data or not data.playlistId then
        HandleError("ID da playlist inválido", "deletePlaylist")
        TriggerClientEvent("tokyo_box:showNotification", source, "ID da playlist inválido", "error")
        return
    end
    
    -- Excluir playlist
    exports.tokyo_box:DeletePlaylist(data.playlistId, source, function(success)
        if not success then
            TriggerClientEvent("tokyo_box:showNotification", source, "Erro ao excluir playlist", "error")
            return
        end
        
        -- Notificar cliente
        TriggerClientEvent("tokyo_box:playlistDeleted", source, data.playlistId)
        Log("debug", string.format("Playlist %d excluída pelo jogador %s", data.playlistId, source))
    end)
end)

RegisterNetEvent("tokyo_box:addTrackToPlaylist")
AddEventHandler("tokyo_box:addTrackToPlaylist", function(data)
    local source = source
    
    if not ValidateState() then return end
    
    if not HasPermission(source, "manage_playlist") then
        TriggerClientEvent("tokyo_box:showNotification", source, "Você não tem permissão para gerenciar playlists", "error")
        return
    end
    
    if not data or not data.playlistId or not data.videoId then
        HandleError("Dados inválidos", "addTrackToPlaylist")
        TriggerClientEvent("tokyo_box:showNotification", source, "Dados inválidos", "error")
        return
    end
    
    -- Obter detalhes do vídeo
    exports.tokyo_box:GetVideoDetails(data.videoId, function(success, videoDetails)
        if not success or not videoDetails then
            TriggerClientEvent("tokyo_box:showNotification", source, "Erro ao obter detalhes do vídeo", "error")
            return
        end
        
        -- Adicionar à playlist
        exports.tokyo_box:AddTrackToPlaylist({
            playlistId = data.playlistId,
            track = {
                videoId = videoDetails.videoId,
                title = videoDetails.title,
                thumbnailUrl = videoDetails.thumbnailUrl
            },
            addedBy = source
        }, function(track)
            if not track then
                TriggerClientEvent("tokyo_box:showNotification", source, "Erro ao adicionar música à playlist", "error")
                return
            end
            
            -- Notificar cliente
            TriggerClientEvent("tokyo_box:trackAdded", source, {
                playlistId = data.playlistId,
                track = track
            })
            Log("debug", string.format("Música '%s' adicionada à playlist %d pelo jogador %s", track.title, data.playlistId, source))
        end)
    end)
end)

RegisterNetEvent("tokyo_box:removeTrackFromPlaylist")
AddEventHandler("tokyo_box:removeTrackFromPlaylist", function(data)
    local source = source
    
    if not ValidateState() then return end
    
    if not HasPermission(source, "manage_playlist") then
        TriggerClientEvent("tokyo_box:showNotification", source, "Você não tem permissão para gerenciar playlists", "error")
        return
    end
    
    if not data or not data.playlistId or not data.trackId then
        HandleError("Dados inválidos", "removeTrackFromPlaylist")
        TriggerClientEvent("tokyo_box:showNotification", source, "Dados inválidos", "error")
        return
    end
    
    -- Remover da playlist
    exports.tokyo_box:RemoveTrackFromPlaylist(data.trackId, data.playlistId, source, function(success)
        if not success then
            TriggerClientEvent("tokyo_box:showNotification", source, "Erro ao remover música da playlist", "error")
            return
        end
        
        -- Notificar cliente
        TriggerClientEvent("tokyo_box:trackRemoved", source, {
            playlistId = data.playlistId,
            trackId = data.trackId
        })
        Log("debug", string.format("Música %d removida da playlist %d pelo jogador %s", data.trackId, data.playlistId, source))
    end)
end)

RegisterNetEvent("tokyo_box:addFavorite")
AddEventHandler("tokyo_box:addFavorite", function(data)
    local source = source
    
    if not ValidateState() then return end
    
    if not HasPermission(source, "play") then
        TriggerClientEvent("tokyo_box:showNotification", source, "Você não tem permissão para adicionar favoritos", "error")
        return
    end
    
    if not data or not data.videoId then
        HandleError("ID do vídeo inválido", "addFavorite")
        TriggerClientEvent("tokyo_box:showNotification", source, "ID do vídeo inválido", "error")
        return
    end
    
    -- Obter detalhes do vídeo
    exports.tokyo_box:GetVideoDetails(data.videoId, function(success, videoDetails)
        if not success or not videoDetails then
            TriggerClientEvent("tokyo_box:showNotification", source, "Erro ao obter detalhes do vídeo", "error")
            return
        end
        
        -- Adicionar aos favoritos
        exports.tokyo_box:AddFavorite({
            userId = source,
            track = {
                videoId = videoDetails.videoId,
                title = videoDetails.title,
                thumbnailUrl = videoDetails.thumbnailUrl
            }
        }, function(favorite)
            if not favorite then
                TriggerClientEvent("tokyo_box:showNotification", source, "Erro ao adicionar favorito", "error")
                return
            end
            
            -- Notificar cliente
            TriggerClientEvent("tokyo_box:favoriteAdded", source, favorite)
            Log("debug", string.format("Música '%s' adicionada aos favoritos pelo jogador %s", videoDetails.title, source))
        end)
    end)
end)

RegisterNetEvent("tokyo_box:removeFavorite")
AddEventHandler("tokyo_box:removeFavorite", function(data)
    local source = source
    
    if not ValidateState() then return end
    
    if not HasPermission(source, "play") then
        TriggerClientEvent("tokyo_box:showNotification", source, "Você não tem permissão para remover favoritos", "error")
        return
    end
    
    if not data or not data.favoriteId then
        HandleError("ID do favorito inválido", "removeFavorite")
        TriggerClientEvent("tokyo_box:showNotification", source, "ID do favorito inválido", "error")
        return
    end
    
    -- Remover dos favoritos
    exports.tokyo_box:RemoveFavorite(data.favoriteId, source, function(success)
        if not success then
            TriggerClientEvent("tokyo_box:showNotification", source, "Erro ao remover favorito", "error")
            return
        end
        
        -- Notificar cliente
        TriggerClientEvent("tokyo_box:favoriteRemoved", source, data.favoriteId)
        Log("debug", string.format("Favorito %d removido pelo jogador %s", data.favoriteId, source))
    end)
end)

RegisterNetEvent("tokyo_box:getFavorites")
AddEventHandler("tokyo_box:getFavorites", function()
    local source = source
    
    if not ValidateState() then return end
    
    if not HasPermission(source, "play") then
        TriggerClientEvent("tokyo_box:showNotification", source, "Você não tem permissão para acessar favoritos", "error")
        return
    end
    
    -- Buscar favoritos
    exports.tokyo_box:GetFavoritesByPlayer(source, function(favorites)
        -- Enviar favoritos para o cliente
        TriggerClientEvent("tokyo_box:receiveFavorites", source, favorites)
        Log("debug", string.format("Enviados %d favoritos para o jogador %s", #favorites, source))
    end)
end)

-- Add server-side event handlers for UI settings

-- Add this to the events.lua file
RegisterNetEvent("tokyo_box:saveUISettings")
AddEventHandler("tokyo_box:saveUISettings", function(settings)
    local source = source
    
    if not ValidateState() then return end
    
    -- Validate settings
    if not settings then return end
    
    -- Get player identifier for storage
    local identifier = source
    if QBCore then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then
            identifier = xPlayer.PlayerData.citizenid
        end
    end
    
    -- Save to database
    MySQL.query("INSERT INTO `"..Config.Database.TablePrefix.."ui_settings` (`user_id`, `scale`, `is_expanded`, `updated_at`) VALUES (?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE `scale` = ?, `is_expanded` = ?, `updated_at` = NOW()",
        {identifier, settings.scale, settings.isExpanded, settings.scale, settings.isExpanded},
        function(result)
            if not result then
                Log("error", "Failed to save UI settings for player " .. source)
                return
            end
            
            Log("debug", "UI settings saved for player " .. source)
        end
    )
end)

RegisterNetEvent("tokyo_box:getUISettings")
AddEventHandler("tokyo_box:getUISettings", function()
    local source = source
    
    if not ValidateState() then return end
    
    -- Get player identifier
    local identifier = source
    if QBCore then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then
            identifier = xPlayer.PlayerData.citizenid
        end
    end
    
    -- Get settings from database
    MySQL.query("SELECT `scale`, `is_expanded` FROM `"..Config.Database.TablePrefix.."ui_settings` WHERE `user_id` = ? LIMIT 1",
        {identifier},
        function(result)
            if not result or #result == 0 then
                -- Use default settings
                TriggerClientEvent("tokyo_box:loadUISettings", source, {
                    scale = Config.UI.DefaultScale,
                    isExpanded = Config.UI.DefaultExpanded
                })
                return
            end
            
            -- Send settings to client
            TriggerClientEvent("tokyo_box:loadUISettings", source, {
                scale = result[1].scale,
                isExpanded = result[1].is_expanded == 1
            })
            
            Log("debug", "UI settings loaded for player " .. source)
        end
    )
end)

-- Adicionar evento para sincronizar estado do player para todos os jogadores
RegisterNetEvent("tokyo_box:broadcastPlayerState")
AddEventHandler("tokyo_box:broadcastPlayerState", function(data)
    local source = source
    
    if not ValidateState() then return end
    
    if not HasPermission(source, "play") then
        TriggerClientEvent("tokyo_box:showNotification", source, "Você não tem permissão para transmitir música", "error")
        return
    end
    
    -- Validar dados
    if not data or not data.videoId then
        HandleError("Dados inválidos", "broadcastPlayerState")
        return
    end
    
    -- Obter jogadores próximos
    local range = data.range or Config.Player.DefaultRange
    local nearbyPlayers = GetNearbyPlayers(source, range)
    
    -- Transmitir estado para jogadores próximos
    for _, player in ipairs(nearbyPlayers) do
        TriggerClientEvent("tokyo_box:syncPlayerState", player.id, {
            isPlaying = data.isPlaying,
            currentTrack = data.currentTrack
        })
    end
    
    Log("debug", string.format("Estado do player transmitido para %d jogadores próximos", #nearbyPlayers))
end)

-- Adicionar evento para sincronizar playlists para todos os jogadores
RegisterNetEvent("tokyo_box:broadcastPlaylists")
AddEventHandler("tokyo_box:broadcastPlaylists", function()
    local source = source
    
    if not ValidateState() then return end
    
    -- Buscar todas as playlists
    exports.tokyo_box:GetAllPlaylists(function(playlists)
        -- Transmitir playlists para todos os jogadores
        TriggerClientEvent("tokyo_box:syncPlaylists", -1, playlists)
        Log("debug", string.format("Playlists transmitidas para todos os jogadores (%d playlists)", #playlists))
    end)
end)

-- Eventos de reprodução
RegisterNetEvent('tokyo_box:play')
AddEventHandler('tokyo_box:play', function(track)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    if not Config.Permissions.play then
        TriggerClientEvent('QBCore:Notify', src, 'Você não tem permissão para reproduzir músicas', 'error')
        return
    end

    -- Validar faixa
    if not track or not track.id then
        TriggerClientEvent('QBCore:Notify', src, 'Faixa inválida', 'error')
        return
    end

    -- Notificar todos os jogadores próximos
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local players = QBCore.Functions.GetPlayers()
    
    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(coords - targetCoords)
        
        if distance <= Config.Player.maxDistance then
            TriggerClientEvent('tokyo_box:updateTrack', playerId, track)
        end
    end
end)

RegisterNetEvent('tokyo_box:pause')
AddEventHandler('tokyo_box:pause', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    if not Config.Permissions.play then
        TriggerClientEvent('QBCore:Notify', src, 'Você não tem permissão para controlar a reprodução', 'error')
        return
    end

    -- Notificar todos os jogadores próximos
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local players = QBCore.Functions.GetPlayers()
    
    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(coords - targetCoords)
        
        if distance <= Config.Player.maxDistance then
            TriggerClientEvent('tokyo_box:pause', playerId)
        end
    end
end)

RegisterNetEvent('tokyo_box:next')
AddEventHandler('tokyo_box:next', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    if not Config.Permissions.play then
        TriggerClientEvent('QBCore:Notify', src, 'Você não tem permissão para controlar a reprodução', 'error')
        return
    end

    -- Notificar todos os jogadores próximos
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local players = QBCore.Functions.GetPlayers()
    
    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(coords - targetCoords)
        
        if distance <= Config.Player.maxDistance then
            TriggerClientEvent('tokyo_box:next', playerId)
        end
    end
end)

RegisterNetEvent('tokyo_box:prev')
AddEventHandler('tokyo_box:prev', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    if not Config.Permissions.play then
        TriggerClientEvent('QBCore:Notify', src, 'Você não tem permissão para controlar a reprodução', 'error')
        return
    end

    -- Notificar todos os jogadores próximos
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local players = QBCore.Functions.GetPlayers()
    
    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(coords - targetCoords)
        
        if distance <= Config.Player.maxDistance then
            TriggerClientEvent('tokyo_box:prev', playerId)
        end
    end
end)

-- Eventos de controle
RegisterNetEvent('tokyo_box:setVolume')
AddEventHandler('tokyo_box:setVolume', function(volume)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    if not Config.Permissions.volume then
        TriggerClientEvent('QBCore:Notify', src, 'Você não tem permissão para controlar o volume', 'error')
        return
    end

    -- Validar volume
    if type(volume) ~= 'number' or volume < 0 or volume > 100 then
        TriggerClientEvent('QBCore:Notify', src, 'Volume inválido', 'error')
        return
    end

    -- Notificar todos os jogadores próximos
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local players = QBCore.Functions.GetPlayers()
    
    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(coords - targetCoords)
        
        if distance <= Config.Player.maxDistance then
            TriggerClientEvent('tokyo_box:setVolume', playerId, volume)
        end
    end
end)

RegisterNetEvent('tokyo_box:shuffle')
AddEventHandler('tokyo_box:shuffle', function(shuffle)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    if not Config.Permissions.play then
        TriggerClientEvent('QBCore:Notify', src, 'Você não tem permissão para controlar a reprodução', 'error')
        return
    end

    -- Notificar todos os jogadores próximos
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local players = QBCore.Functions.GetPlayers()
    
    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(coords - targetCoords)
        
        if distance <= Config.Player.maxDistance then
            TriggerClientEvent('tokyo_box:shuffle', playerId, shuffle)
        end
    end
end)

RegisterNetEvent('tokyo_box:repeat')
AddEventHandler('tokyo_box:repeat', function(mode)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    if not Config.Permissions.play then
        TriggerClientEvent('QBCore:Notify', src, 'Você não tem permissão para controlar a reprodução', 'error')
        return
    end

    -- Notificar todos os jogadores próximos
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local players = QBCore.Functions.GetPlayers()
    
    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(coords - targetCoords)
        
        if distance <= Config.Player.maxDistance then
            TriggerClientEvent('tokyo_box:repeat', playerId, mode)
        end
    end
end)

RegisterNetEvent('tokyo_box:mute')
AddEventHandler('tokyo_box:mute', function(mute)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    if not Config.Permissions.volume then
        TriggerClientEvent('QBCore:Notify', src, 'Você não tem permissão para controlar o volume', 'error')
        return
    end

    -- Notificar todos os jogadores próximos
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local players = QBCore.Functions.GetPlayers()
    
    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(coords - targetCoords)
        
        if distance <= Config.Player.maxDistance then
            TriggerClientEvent('tokyo_box:mute', playerId, mute)
        end
    end
end)
