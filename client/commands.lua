local QBCore = exports['qb-core']:GetCoreObject()

-- Comando para abrir a UI
RegisterCommand('tokyobox', function()
    if not Config.Permissions.useCommand then
        QBCore.Functions.Notify('Comando desativado', 'error')
        return
    end
    
    TriggerEvent('tokyo_box:showUI')
end, false)

-- Comando para tocar música
RegisterCommand('tokyobox_play', function(source, args)
    if not Config.Permissions.playMusic then
        QBCore.Functions.Notify('Sem permissão para tocar música', 'error')
        return
    end
    
    if not args[1] then
        QBCore.Functions.Notify('Uso: /tokyobox_play [url/id]', 'error')
        return
    end
    
    TriggerServerEvent('tokyo_box:play', args[1])
end, false)

-- Comando para pausar
RegisterCommand('tokyobox_pause', function()
    if not Config.Permissions.controlPlayback then
        QBCore.Functions.Notify('Sem permissão para controlar reprodução', 'error')
        return
    end
    
    TriggerServerEvent('tokyo_box:pause')
end, false)

-- Comando para retomar
RegisterCommand('tokyobox_resume', function()
    if not Config.Permissions.controlPlayback then
        QBCore.Functions.Notify('Sem permissão para controlar reprodução', 'error')
        return
    end
    
    TriggerServerEvent('tokyo_box:resume')
end, false)

-- Comando para parar
RegisterCommand('tokyobox_stop', function()
    if not Config.Permissions.controlPlayback then
        QBCore.Functions.Notify('Sem permissão para controlar reprodução', 'error')
        return
    end
    
    TriggerServerEvent('tokyo_box:stop')
end, false)

-- Comando para ajustar volume
RegisterCommand('tokyobox_volume', function(source, args)
    if not Config.Permissions.adjustVolume then
        QBCore.Functions.Notify('Sem permissão para ajustar volume', 'error')
        return
    end
    
    if not args[1] then
        QBCore.Functions.Notify('Uso: /tokyobox_volume [0-100]', 'error')
        return
    end
    
    local volume = tonumber(args[1])
    if not volume or volume < 0 or volume > 100 then
        QBCore.Functions.Notify('Volume inválido. Use um valor entre 0 e 100', 'error')
        return
    end
    
    TriggerServerEvent('tokyo_box:setVolume', volume / 100)
end, false)

-- Comando para mutar
RegisterCommand('tokyobox_mute', function()
    if not Config.Permissions.adjustVolume then
        QBCore.Functions.Notify('Sem permissão para ajustar volume', 'error')
        return
    end
    
    TriggerServerEvent('tokyo_box:mute')
end, false)

-- Comando para embaralhar
RegisterCommand('tokyobox_shuffle', function()
    if not Config.Permissions.managePlaylist then
        QBCore.Functions.Notify('Sem permissão para gerenciar playlist', 'error')
        return
    end
    
    TriggerServerEvent('tokyo_box:shuffle')
end, false)

-- Comando para repetir
RegisterCommand('tokyobox_repeat_mode', function(source, args)
    if not Config.Permissions.managePlaylist then
        QBCore.Functions.Notify('Sem permissão para gerenciar playlist', 'error')
        return
    end
    
    if not args[1] then
        QBCore.Functions.Notify('Uso: /tokyobox_repeat_mode [none/one/all]', 'error')
        return
    end
    
    local mode = args[1]:lower()
    if mode ~= 'none' and mode ~= 'one' and mode ~= 'all' then
        QBCore.Functions.Notify('Modo inválido. Use: none, one ou all', 'error')
        return
    end
    
    TriggerServerEvent('tokyo_box:repeat', mode)
end, false)

-- Mapeamento de teclas
RegisterKeyMapping('tokyobox', 'Abrir Tokyo Box', 'keyboard', Config.Keys.toggle)
RegisterKeyMapping('tokyobox_play', 'Tocar música', 'keyboard', Config.Keys.play)
RegisterKeyMapping('tokyobox_pause', 'Pausar música', 'keyboard', Config.Keys.pause)
RegisterKeyMapping('tokyobox_next', 'Próxima música', 'keyboard', Config.Keys.next)
RegisterKeyMapping('tokyobox_prev', 'Música anterior', 'keyboard', Config.Keys.prev)
RegisterKeyMapping('tokyobox_volume', 'Ajustar volume', 'keyboard', Config.Keys.volume) 