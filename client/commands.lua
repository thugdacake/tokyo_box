local QBCore = exports['qb-core']:GetCoreObject()

-- Funções auxiliares
local function hasPermission(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    local group = Player.PlayerData.permission
    return Config.Permissions[group] or false
end

local function notify(source, message, type)
    TriggerEvent('tokyo_box:client:notify', message, type)
end

-- Comandos
QBCore.Commands.Add('tokyobox', Lang:t('commands.tokyobox.description'), {
    { name = 'action', help = Lang:t('commands.tokyobox.help') }
}, function(source, args)
    if not hasPermission(source) then
        notify(source, Lang:t('error.invalid_permission'), 'error')
        return
    end
    
    local action = args[1]
    if not action then
        TriggerEvent('tokyo_box:client:showUI')
        return
    end
    
    if action == 'play' then
        local url = args[2]
        if not url then
            notify(source, Lang:t('error.invalid_input'), 'error')
            return
        end
        
        TriggerServerEvent('tokyo_box:server:playTrack', {
            url = url
        })
    elseif action == 'stop' then
        TriggerServerEvent('tokyo_box:server:stopTrack')
    elseif action == 'pause' then
        TriggerServerEvent('tokyo_box:server:togglePlayback', false)
    elseif action == 'resume' then
        TriggerServerEvent('tokyo_box:server:togglePlayback', true)
    elseif action == 'volume' then
        local vol = tonumber(args[2])
        if not vol then
            notify(source, Lang:t('error.invalid_input'), 'error')
            return
        end
        
        TriggerServerEvent('tokyo_box:server:setVolume', vol)
    elseif action == 'shuffle' then
        TriggerServerEvent('tokyo_box:server:toggleShuffle', true)
    elseif action == 'unshuffle' then
        TriggerServerEvent('tokyo_box:server:toggleShuffle', false)
    elseif action == 'repeat' then
        local mode = args[2]
        if not mode or (mode ~= 'none' and mode ~= 'one' and mode ~= 'all') then
            notify(source, Lang:t('error.invalid_input'), 'error')
            return
        end
        
        TriggerServerEvent('tokyo_box:server:toggleRepeat', mode)
    elseif action == 'playlist' then
        local subAction = args[2]
        if not subAction then
            TriggerEvent('tokyo_box:client:showPlaylist')
            return
        end
        
        if subAction == 'create' then
            local name = args[3]
            if not name then
                notify(source, Lang:t('error.invalid_input'), 'error')
                return
            end
            
            TriggerServerEvent('tokyo_box:server:createPlaylist', name)
        elseif subAction == 'delete' then
            local id = tonumber(args[3])
            if not id then
                notify(source, Lang:t('error.invalid_input'), 'error')
                return
            end
            
            TriggerServerEvent('tokyo_box:server:deletePlaylist', id)
        elseif subAction == 'add' then
            local id = tonumber(args[3])
            local url = args[4]
            if not id or not url then
                notify(source, Lang:t('error.invalid_input'), 'error')
                return
            end
            
            TriggerServerEvent('tokyo_box:server:addTrackToPlaylist', id, url)
        elseif subAction == 'remove' then
            local id = tonumber(args[3])
            local trackId = tonumber(args[4])
            if not id or not trackId then
                notify(source, Lang:t('error.invalid_input'), 'error')
                return
            end
            
            TriggerServerEvent('tokyo_box:server:removeTrackFromPlaylist', id, trackId)
        end
    elseif action == 'search' then
        local query = table.concat(args, ' ', 2)
        if not query then
            notify(source, Lang:t('error.invalid_input'), 'error')
            return
        end
        
        TriggerServerEvent('tokyo_box:server:searchVideos', query)
    elseif action == 'help' then
        notify(source, Lang:t('commands.help'), 'info')
    end
end)

-- Teclas
RegisterKeyMapping('tokyobox', 'Abrir Tokyo Box', 'keyboard', Config.Keys.open)

-- Exportações
exports('HasPermission', hasPermission)
exports('Notify', notify) 