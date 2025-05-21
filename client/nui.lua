local QBCore = exports['qb-core']:GetCoreObject()
local isUIOpen = false

-- Função para mostrar a UI
function ShowUI()
    if isUIOpen then return end
    isUIOpen = true
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'show',
        state = {
            scale = Config.UI.defaultScale or 1.0,
            locale = Config.UI.defaultLocale or 'pt-BR',
            theme = Config.UI.defaultTheme or 'dark'
        }
    })
end

-- Função para esconder a UI
function HideUI()
    if not isUIOpen then return end
    isUIOpen = false
    
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'hide'
    })
end

-- Callbacks NUI
RegisterNUICallback('close', function(data, cb)
    HideUI()
    cb('ok')
end)

RegisterNUICallback('minimize', function(data, cb)
    SendNUIMessage({
        type = 'updateState',
        state = {
            isMinimized = true
        }
    })
    cb('ok')
end)

RegisterNUICallback('search', function(data, cb)
    if not data.query then
        cb({ error = 'Query inválida' })
        return
    end
    
    TriggerServerEvent('tokyo_box:search', data.query, function(results)
        cb(results)
    end)
end)

RegisterNUICallback('play', function(data, cb)
    if not data.track then
        cb({ error = 'Faixa inválida' })
        return
    end
    
    TriggerServerEvent('tokyo_box:play', data.track)
    cb('ok')
end)

RegisterNUICallback('pause', function(data, cb)
    TriggerServerEvent('tokyo_box:pause')
    cb('ok')
end)

RegisterNUICallback('next', function(data, cb)
    TriggerServerEvent('tokyo_box:next')
    cb('ok')
end)

RegisterNUICallback('prev', function(data, cb)
    TriggerServerEvent('tokyo_box:prev')
    cb('ok')
end)

RegisterNUICallback('setVolume', function(data, cb)
    if not data.volume or type(data.volume) ~= 'number' then
        cb({ error = 'Volume inválido' })
        return
    end
    
    TriggerServerEvent('tokyo_box:setVolume', data.volume)
    cb('ok')
end)

RegisterNUICallback('shuffle', function(data, cb)
    TriggerServerEvent('tokyo_box:shuffle', data.shuffle)
    cb('ok')
end)

RegisterNUICallback('repeat', function(data, cb)
    TriggerServerEvent('tokyo_box:repeat', data.mode)
    cb('ok')
end)

RegisterNUICallback('mute', function(data, cb)
    TriggerServerEvent('tokyo_box:mute', data.mute)
    cb('ok')
end)

-- Eventos do servidor
RegisterNetEvent('tokyo_box:updateTrack')
AddEventHandler('tokyo_box:updateTrack', function(track)
    if not isUIOpen then return end
    
    SendNUIMessage({
        type = 'updateTrack',
        track = track
    })
end)

RegisterNetEvent('tokyo_box:updateResults')
AddEventHandler('tokyo_box:updateResults', function(results)
    if not isUIOpen then return end
    
    SendNUIMessage({
        type = 'updateResults',
        results = results
    })
end)

-- Comandos
RegisterCommand('tokyobox', function()
    if not Config.Permissions.useCommand then
        QBCore.Functions.Notify('Comando desativado', 'error')
        return
    end
    
    ShowUI()
end)

-- Teclas
RegisterKeyMapping('tokyobox', 'Abrir Tokyo Box', 'keyboard', Config.Keys.toggle)

-- Exportações
exports('ShowUI', ShowUI)
exports('HideUI', HideUI)
exports('IsUIOpen', function() return isUIOpen end) 