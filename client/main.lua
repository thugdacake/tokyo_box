--[[
    Tokyo Box - Client Main
    Gerenciamento principal do cliente e NUI
    Versão: 1.0.0
]]

-- Constantes
local RESOURCE_NAME = GetCurrentResourceName()
local DEFAULT_VOLUME = 50
local DEFAULT_REPEAT_MODE = 'none'
local DEFAULT_STATE = {
    isPlaying = false,
    volume = DEFAULT_VOLUME,
    isShuffled = false,
    repeatMode = DEFAULT_REPEAT_MODE,
    currentTrack = nil
}

-- Cache de variáveis
local isUIOpen = false
local isInitialized = false
local currentState = DEFAULT_STATE

-- Função para verificar se o chat está aberto
local function IsChatOpen()
    local chatExports = {
        'chat',
        'chat',
        'chat'
    }
    
    local chatMethods = {
        'IsChatOpen',
        'isOpen',
        'IsOpen'
    }
    
    for i, export in ipairs(chatExports) do
        local success, result = pcall(function()
            return exports[export][chatMethods[i]]()
        end)
        
        if success and result then
            return true
        end
    end
    
    return false
end

-- Função para verificar se o menu pode ser aberto
local function CanOpenMenu()
    if isUIOpen then return false end
    if IsPauseMenuActive() then return false end
    if IsPedInAnyVehicle(PlayerPedId(), false) then return false end
    if IsChatOpen() then return false end
    return true
end

-- Função para atualizar o estado
local function UpdateState(newState)
    if not newState then return end
    
    for k, v in pairs(newState) do
        currentState[k] = v
    end
    
    SendNUIMessage({
        type = 'updateState',
        state = currentState
    })
end

-- Função para mostrar a UI
function ShowUI()
    if not isInitialized then
        print('[Tokyo Box] Inicializando...')
        isInitialized = true
    end
    
    if isUIOpen then return end
    if not CanOpenMenu() then return end
    
    print('[Tokyo Box] Mostrando UI...')
    isUIOpen = true
    
    SendNUIMessage({
        type = 'show',
        state = currentState
    })
    
    SetNuiFocus(true, true)
end

-- Função para esconder a UI
function HideUI()
    if not isUIOpen then return end
    
    print('[Tokyo Box] Escondendo UI...')
    isUIOpen = false
    
    SendNUIMessage({
        type = 'hide'
    })
    
    SetNuiFocus(false, false)
end

-- Callbacks do NUI
RegisterNUICallback('close', function(_, cb)
    HideUI()
    cb('ok')
end)

RegisterNUICallback('playPause', function(_, cb)
    if not isUIOpen then return cb('error') end
    
    currentState.isPlaying = not currentState.isPlaying
    UpdateState({ isPlaying = currentState.isPlaying })
    
    TriggerServerEvent('tokyo-box:playPause')
    cb('ok')
end)

RegisterNUICallback('nextTrack', function(_, cb)
    if not isUIOpen then return cb('error') end
    
    TriggerServerEvent('tokyo-box:nextTrack')
    cb('ok')
end)

RegisterNUICallback('prevTrack', function(_, cb)
    if not isUIOpen then return cb('error') end
    
    TriggerServerEvent('tokyo-box:prevTrack')
    cb('ok')
end)

RegisterNUICallback('setVolume', function(data, cb)
    if not isUIOpen then return cb('error') end
    if not data.volume or type(data.volume) ~= 'number' then return cb('error') end
    
    local volume = math.max(0, math.min(100, data.volume))
    currentState.volume = volume
    UpdateState({ volume = volume })
    
    TriggerServerEvent('tokyo-box:setVolume', volume)
    cb('ok')
end)

RegisterNUICallback('toggleShuffle', function(_, cb)
    if not isUIOpen then return cb('error') end
    
    currentState.isShuffled = not currentState.isShuffled
    UpdateState({ isShuffled = currentState.isShuffled })
    
    TriggerServerEvent('tokyo-box:toggleShuffle')
    cb('ok')
end)

RegisterNUICallback('toggleRepeat', function(_, cb)
    if not isUIOpen then return cb('error') end
    
    local modes = { 'none', 'one', 'all' }
    local currentIndex = 1
    
    for i, mode in ipairs(modes) do
        if mode == currentState.repeatMode then
            currentIndex = i
            break
        end
    end
    
    currentState.repeatMode = modes[(currentIndex % #modes) + 1]
    UpdateState({ repeatMode = currentState.repeatMode })
    
    TriggerServerEvent('tokyo-box:toggleRepeat', currentState.repeatMode)
    cb('ok')
end)

-- Comandos
RegisterCommand('tokyobox', function()
    if isUIOpen then
        HideUI()
    else
        ShowUI()
    end
end, false)

RegisterCommand('tokyobox_show', function()
    ShowUI()
end, false)

RegisterCommand('tokyobox_hide', function()
    HideUI()
end, false)

-- Tecla de atalho
RegisterKeyMapping('tokyobox', 'Abrir Tokyo Box', 'keyboard', 'F7')

-- Eventos
RegisterNetEvent('tokyo-box:updateState')
AddEventHandler('tokyo-box:updateState', function(newState)
    UpdateState(newState)
end)

RegisterNetEvent('tokyo-box:searchResults')
AddEventHandler('tokyo-box:searchResults', function(results)
    if not isUIOpen then return end
    
    SendNUIMessage({
        type = 'updateResults',
        results = results
    })
end)

-- Eventos do recurso
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= RESOURCE_NAME then return end
    
    print('[Tokyo Box] Recurso iniciado')
    isInitialized = false
    isUIOpen = false
    currentState = DEFAULT_STATE
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= RESOURCE_NAME then return end
    
    if isUIOpen then
        HideUI()
    end
end)

print('^2[Tokyo Box] Cliente inicializado^7') 