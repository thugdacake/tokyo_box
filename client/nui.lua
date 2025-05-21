local QBCore = exports['qb-core']:GetCoreObject()

-- Configurações
local config = {
    debug = false,
    defaultPosition = 'bottom-right',
    defaultSize = {
        width = 360,
        height = 640
    }
}

-- Estado
local isUIOpen = false
local currentView = 'main'
local currentData = {}

-- Funções auxiliares
local function log(message)
    if config.debug then
        print("^3[DEBUG] Tokyo Box - NUI: " .. message .. "^7")
    end
end

local function sendNUIMessage(data)
    if not data then return end
    
    SendNUIMessage(data)
    log("Mensagem enviada para NUI: " .. json.encode(data))
end

local function showUI(view, data)
    if isUIOpen then return end
    
    isUIOpen = true
    currentView = view or 'main'
    currentData = data or {}
    
    SetNuiFocus(true, true)
    sendNUIMessage({
        type = 'show',
        view = currentView,
        data = currentData
    })
    
    log("UI aberta: " .. currentView)
end

local function hideUI()
    if not isUIOpen then return end
    
    isUIOpen = false
    currentView = 'main'
    currentData = {}
    
    SetNuiFocus(false, false)
    sendNUIMessage({
        type = 'hide'
    })
    
    log("UI fechada")
end

local function updateUI(data)
    if not isUIOpen then return end
    
    for k, v in pairs(data) do
        currentData[k] = v
    end
    
    sendNUIMessage({
        type = 'update',
        data = currentData
    })
    
    log("UI atualizada")
end

local function switchView(view, data)
    if not isUIOpen then return end
    
    currentView = view
    currentData = data or {}
    
    sendNUIMessage({
        type = 'switchView',
        view = currentView,
        data = currentData
    })
    
    log("View alterada: " .. currentView)
end

-- Callbacks do NUI
RegisterNUICallback('close', function(data, cb)
    hideUI()
    cb({ success = true })
end)

RegisterNUICallback('action', function(data, cb)
    if not data.action then
        cb({ success = false, error = "Ação não especificada" })
        return
    end
    
    log("Ação recebida: " .. data.action)
    
    if data.action == 'play' then
        TriggerServerEvent('tokyo_box:server:playTrack', data.track)
    elseif data.action == 'pause' then
        TriggerServerEvent('tokyo_box:server:togglePlayback', false)
    elseif data.action == 'resume' then
        TriggerServerEvent('tokyo_box:server:togglePlayback', true)
    elseif data.action == 'stop' then
        TriggerServerEvent('tokyo_box:server:stopTrack')
    elseif data.action == 'volume' then
        TriggerServerEvent('tokyo_box:server:setVolume', data.volume)
    elseif data.action == 'shuffle' then
        TriggerServerEvent('tokyo_box:server:toggleShuffle', data.enable)
    elseif data.action == 'repeat' then
        TriggerServerEvent('tokyo_box:server:toggleRepeat', data.mode)
    elseif data.action == 'search' then
        TriggerServerEvent('tokyo_box:server:searchVideos', data.query)
    elseif data.action == 'playlist' then
        if data.subAction == 'create' then
            TriggerServerEvent('tokyo_box:server:createPlaylist', data.name)
        elseif data.subAction == 'delete' then
            TriggerServerEvent('tokyo_box:server:deletePlaylist', data.id)
        elseif data.subAction == 'add' then
            TriggerServerEvent('tokyo_box:server:addTrackToPlaylist', data.id, data.track)
        elseif data.subAction == 'remove' then
            TriggerServerEvent('tokyo_box:server:removeTrackFromPlaylist', data.id, data.trackId)
        end
    end
    
    cb({ success = true })
end)

-- Eventos
RegisterNetEvent('tokyo_box:client:showUI', function(view, data)
    showUI(view, data)
end)

RegisterNetEvent('tokyo_box:client:hideUI', function()
    hideUI()
end)

RegisterNetEvent('tokyo_box:client:updateUI', function(data)
    updateUI(data)
end)

RegisterNetEvent('tokyo_box:client:switchView', function(view, data)
    switchView(view, data)
end)

-- Comandos
RegisterCommand('tokyoboxui', function(source, args)
    if not args[1] then
        TriggerEvent('tokyo_box:client:showUI')
        return
    end
    
    local action = args[1]
    if action == 'show' then
        TriggerEvent('tokyo_box:client:showUI', args[2])
    elseif action == 'hide' then
        TriggerEvent('tokyo_box:client:hideUI')
    elseif action == 'view' then
        TriggerEvent('tokyo_box:client:switchView', args[2])
    end
end)

-- Exportações
exports('ShowUI', showUI)
exports('HideUI', hideUI)
exports('UpdateUI', updateUI)
exports('SwitchView', switchView)
exports('SetConfig', function(newConfig)
    if type(newConfig) ~= 'table' then return false end
    
    for k, v in pairs(newConfig) do
        config[k] = v
    end
    return true
end)

-- Inicialização
CreateThread(function()
    while true do
        Wait(0)
        if isUIOpen then
            DisableControlAction(0, 1, true) -- LookLeftRight
            DisableControlAction(0, 2, true) -- LookUpDown
            DisableControlAction(0, 142, true) -- MeleeAttackAlternate
            DisableControlAction(0, 18, true) -- Enter
            DisableControlAction(0, 322, true) -- ESC
            DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
        end
    end
end) 