local QBCore = exports['qb-core']:GetCoreObject()
local isUIOpen = false
local currentTrack = nil
local playlist = {}
local volume = Config.Player.defaultVolume
local isPlaying = false
local repeatMode = 'none'
local shuffle = false

-- Eventos do NUI
RegisterNUICallback('togglePlayback', function(data, cb)
    if not currentTrack then
        QBCore.Functions.Notify(Lang:t('error.no_track'), 'error')
        cb({ success = false })
        return
    end

    isPlaying = not isPlaying
    TriggerServerEvent('tokyo_box:server:togglePlayback', isPlaying)
    cb({ success = true, isPlaying = isPlaying })
end)

RegisterNUICallback('setVolume', function(data, cb)
    if not data.volume or data.volume < Config.Player.minVolume or data.volume > Config.Player.maxVolume then
        QBCore.Functions.Notify(Lang:t('error.invalid_volume_range', { min = Config.Player.minVolume, max = Config.Player.maxVolume }), 'error')
        cb({ success = false })
        return
    end

    volume = data.volume
    TriggerServerEvent('tokyo_box:server:setVolume', volume)
    cb({ success = true, volume = volume })
end)

RegisterNUICallback('playTrack', function(data, cb)
    if not data.index or not playlist[data.index] then
        QBCore.Functions.Notify(Lang:t('error.invalid_input'), 'error')
        cb({ success = false })
        return
    end

    currentTrack = playlist[data.index]
    isPlaying = true
    TriggerServerEvent('tokyo_box:server:playTrack', currentTrack)
    cb({ success = true, track = currentTrack, isPlaying = true })
end)

RegisterNUICallback('toggleShuffle', function(data, cb)
    shuffle = not shuffle
    TriggerServerEvent('tokyo_box:server:toggleShuffle', shuffle)
    cb({ success = true, shuffle = shuffle })
end)

RegisterNUICallback('toggleRepeat', function(data, cb)
    local modes = { 'none', 'one', 'all' }
    local currentIndex = 1
    for i, mode in ipairs(modes) do
        if mode == repeatMode then
            currentIndex = i
            break
        end
    end
    
    currentIndex = currentIndex % #modes + 1
    repeatMode = modes[currentIndex]
    
    TriggerServerEvent('tokyo_box:server:toggleRepeat', repeatMode)
    cb({ success = true, repeatMode = repeatMode })
end)

-- Eventos do servidor
RegisterNetEvent('tokyo_box:client:updateState', function(newState)
    if not newState then return end
    
    if newState.currentTrack then
        currentTrack = newState.currentTrack
    end
    
    if newState.playlist then
        playlist = newState.playlist
    end
    
    if newState.volume then
        volume = newState.volume
    end
    
    if newState.isPlaying ~= nil then
        isPlaying = newState.isPlaying
    end
    
    if newState.repeatMode then
        repeatMode = newState.repeatMode
    end
    
    if newState.shuffle ~= nil then
        shuffle = newState.shuffle
    end
    
    SendNUIMessage({
        type = 'updateState',
        state = {
            currentTrack = currentTrack,
            playlist = playlist,
            volume = volume,
            isPlaying = isPlaying,
            repeatMode = repeatMode,
            shuffle = shuffle
        }
    })
end)

RegisterNetEvent('tokyo_box:client:showUI', function()
    if isUIOpen then return end
    
    isUIOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'show',
        state = {
            currentTrack = currentTrack,
            playlist = playlist,
            volume = volume,
            isPlaying = isPlaying,
            repeatMode = repeatMode,
            shuffle = shuffle
        }
    })
end)

RegisterNetEvent('tokyo_box:client:hideUI', function()
    if not isUIOpen then return end
    
    isUIOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'hide'
    })
end)

-- Comandos
RegisterCommand('tokyobox', function()
    if isUIOpen then
        TriggerEvent('tokyo_box:client:hideUI')
    else
        TriggerEvent('tokyo_box:client:showUI')
    end
end)

-- Teclas
RegisterKeyMapping('tokyobox', 'Abrir Tokyo Box', 'keyboard', Config.Keys.open)

-- Callbacks do NUI
RegisterNUICallback('close', function(data, cb)
    TriggerEvent('tokyo_box:client:hideUI')
    cb({ success = true })
end)

-- Inicialização
CreateThread(function()
    while true do
        Wait(1000)
        if isUIOpen and currentTrack then
            -- Atualizar progresso da música
            TriggerServerEvent('tokyo_box:server:getProgress')
        end
    end
end)

-- Exportar funções
exports('GetCurrentTrack', function()
    return currentTrack
end)

exports('IsPlaying', function()
    return isPlaying
end)

exports('GetVolume', function()
    return volume
end)

exports('GetPlaylist', function()
    return playlist
end) 