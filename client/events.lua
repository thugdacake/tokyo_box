local QBCore = exports['qb-core']:GetCoreObject()
local currentTrack = nil
local isPlaying = false
local volume = Config.Player.defaultVolume
local isMuted = false
local isShuffled = false
local repeatMode = 'none' -- none, one, all

-- Função para reproduzir áudio
local function playAudio(track)
    if not track or not track.id then return end
    
    currentTrack = track
    isPlaying = true
    
    -- Criar objeto de áudio
    local audio = {
        id = track.id,
        title = track.title,
        artist = track.channelTitle,
        thumbnail = track.thumbnail,
        duration = 0, -- Será atualizado quando o áudio começar
        position = 0
    }
    
    -- Enviar para a UI
    SendNUIMessage({
        type = 'updateTrack',
        track = audio
    })
    
    -- Reproduzir áudio
    TriggerServerEvent('tokyo_box:playAudio', track.id, volume)
end

-- Função para pausar áudio
local function pauseAudio()
    if not isPlaying then return end
    
    isPlaying = false
    TriggerServerEvent('tokyo_box:pauseAudio')
end

-- Função para retomar áudio
local function resumeAudio()
    if isPlaying then return end
    
    isPlaying = true
    TriggerServerEvent('tokyo_box:resumeAudio')
end

-- Função para parar áudio
local function stopAudio()
    if not currentTrack then return end
    
    currentTrack = nil
    isPlaying = false
    TriggerServerEvent('tokyo_box:stopAudio')
end

-- Função para ajustar volume
local function setVolume(newVolume)
    if type(newVolume) ~= 'number' or newVolume < 0 or newVolume > 100 then return end
    
    volume = newVolume
    if not isMuted then
        TriggerServerEvent('tokyo_box:setVolume', volume)
    end
end

-- Função para mutar/desmutar
local function toggleMute()
    isMuted = not isMuted
    if isMuted then
        TriggerServerEvent('tokyo_box:setVolume', 0)
    else
        TriggerServerEvent('tokyo_box:setVolume', volume)
    end
end

-- Função para embaralhar
local function toggleShuffle()
    isShuffled = not isShuffled
    TriggerServerEvent('tokyo_box:shuffle', isShuffled)
end

-- Função para repetir
local function setRepeatMode(mode)
    if mode ~= 'none' and mode ~= 'one' and mode ~= 'all' then return end
    
    repeatMode = mode
    TriggerServerEvent('tokyo_box:repeat', mode)
end

-- Eventos do servidor
RegisterNetEvent('tokyo_box:updateTrack')
AddEventHandler('tokyo_box:updateTrack', function(track)
    playAudio(track)
end)

RegisterNetEvent('tokyo_box:pause')
AddEventHandler('tokyo_box:pause', function()
    pauseAudio()
end)

RegisterNetEvent('tokyo_box:resume')
AddEventHandler('tokyo_box:resume', function()
    resumeAudio()
end)

RegisterNetEvent('tokyo_box:stop')
AddEventHandler('tokyo_box:stop', function()
    stopAudio()
end)

RegisterNetEvent('tokyo_box:setVolume')
AddEventHandler('tokyo_box:setVolume', function(newVolume)
    setVolume(newVolume)
end)

RegisterNetEvent('tokyo_box:shuffle')
AddEventHandler('tokyo_box:shuffle', function(shuffle)
    isShuffled = shuffle
end)

RegisterNetEvent('tokyo_box:repeat')
AddEventHandler('tokyo_box:repeat', function(mode)
    repeatMode = mode
end)

RegisterNetEvent('tokyo_box:mute')
AddEventHandler('tokyo_box:mute', function(mute)
    isMuted = mute
    if mute then
        TriggerServerEvent('tokyo_box:setVolume', 0)
    else
        TriggerServerEvent('tokyo_box:setVolume', volume)
    end
end)

-- Exportações
exports('GetCurrentTrack', function() return currentTrack end)
exports('IsPlaying', function() return isPlaying end)
exports('GetVolume', function() return volume end)
exports('IsMuted', function() return isMuted end)
exports('IsShuffled', function() return isShuffled end)
exports('GetRepeatMode', function() return repeatMode end)

exports('PlayTrack', playAudio)
exports('PauseTrack', pauseAudio)
exports('ResumeTrack', resumeAudio)
exports('StopTrack', stopAudio)
exports('SetVolume', setVolume)
exports('ToggleMute', toggleMute)
exports('ToggleShuffle', toggleShuffle)
exports('SetRepeatMode', setRepeatMode) 