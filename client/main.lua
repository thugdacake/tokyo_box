--[[
    Tokyo Box - Client Main
    Gerenciamento principal do cliente e NUI
    Versão: 1.0.0
]]

-- Framework
local framework = {
    name = Config.Framework,
    core = nil,
    initialized = false
}

-- Inicialização do Framework
local function initializeFramework()
    if framework.initialized then return end
    
    if framework.name == 'qb-core' then
        framework.core = exports['qb-core']:GetCoreObject()
    elseif framework.name == 'es_extended' then
        framework.core = exports['es_extended']:getSharedObject()
    elseif framework.name == 'ox_core' then
        framework.core = exports.ox_core:GetCoreObject()
    else
        print('^1[Tokyo Box] Framework não suportado: ' .. framework.name .. '^7')
        return false
    end
    
    framework.initialized = true
    print('^2[Tokyo Box] Framework inicializado: ' .. framework.name .. '^7')
    return true
end

-- Funções do Framework
local function getPlayerData()
    if not framework.initialized then return nil end
    
    if framework.name == 'qb-core' then
        return framework.core.Functions.GetPlayerData()
    elseif framework.name == 'es_extended' then
        return framework.core.GetPlayerData()
    elseif framework.name == 'ox_core' then
        return framework.core.GetPlayerData()
    end
    
    return nil
end

local function hasPermission(permission)
    if not framework.initialized then return false end
    
    local playerData = getPlayerData()
    if not playerData then return false end
    
    if framework.name == 'qb-core' then
        return playerData.job.grade.level >= Config.Permissions[permission]
    elseif framework.name == 'es_extended' then
        return playerData.job.grade >= Config.Permissions[permission]
    elseif framework.name == 'ox_core' then
        return playerData.job.grade >= Config.Permissions[permission]
    end
    
    return false
end

-- Configurações
local config = {
    debug = false,
    defaultVolume = 0.5,
    minVolume = 0.0,
    maxVolume = 1.0,
    defaultTheme = 'dark',
    defaultLocale = 'pt-BR'
}

-- Cache
local cache = {
    tracks = {},
    playlists = {},
    lastUpdate = 0,
    maxAge = 3600, -- 1 hora em segundos
    maxSize = 100
}

-- Sistema de Notificações
local notifications = {
    queue = {},
    maxQueue = 5,
    duration = 3000,
    position = 'top-right'
}

-- Sistema de Temas
local themes = {
    current = 'dark',
    custom = {},
    default = {
        dark = {
            primary = '#007AFF',
            background = 'rgba(20, 20, 20, 0.95)',
            text = '#FFFFFF',
            secondary = '#2D2D2D',
            accent = '#4A90E2'
        },
        light = {
            primary = '#007AFF',
            background = 'rgba(255, 255, 255, 0.95)',
            text = '#000000',
            secondary = '#F2F2F2',
            accent = '#4A90E2'
        }
    }
}

-- Sistema de Playlists
local savedPlaylists = {
    items = {},
    maxPlaylists = 10
}

-- Função para gerenciar o cache
local function manageCache(key, value)
    if not cache[key] then
        cache[key] = {}
    end
    
    -- Limpar cache antigo
    local currentTime = os.time()
    if currentTime - cache.lastUpdate > cache.maxAge then
        cache.tracks = {}
        cache.playlists = {}
        cache.lastUpdate = currentTime
    end
    
    -- Limitar tamanho do cache
    if #cache[key] >= cache.maxSize then
        table.remove(cache[key], 1)
    end
    
    -- Adicionar novo item
    table.insert(cache[key], {
        value = value,
        timestamp = currentTime
    })
end

-- Função para obter item do cache
local function getFromCache(key, id)
    if not cache[key] then return nil end
    
    for _, item in ipairs(cache[key]) do
        if item.value.id == id then
            return item.value
        end
    end
    
    return nil
end

-- Estado
local isInitialized = false
local currentTrack = nil
local playlist = {}
local volume = config.defaultVolume
local isPlaying = false
local repeatMode = 'none'
local shuffle = false

-- Funções auxiliares
local function log(message)
    if config.debug then
        print("^3[DEBUG] Tokyo Box - Client: " .. message .. "^7")
    end
end

local function initialize()
    if isInitialized then return end
    
    -- Carregar configurações
    TriggerServerEvent('tokyo_box:server:getConfig')
    
    -- Carregar tema
    exports['tokyo_box']:SetTheme(config.defaultTheme)
    
    -- Carregar idioma
    exports['tokyo_box']:SetLocale(config.defaultLocale)
    
    -- Carregar playlists
    TriggerServerEvent('tokyo_box:server:getPlaylists')
    
    isInitialized = true
    log("Cliente inicializado")
end

-- Funções auxiliares de notificação
local function showNotification(message, type)
    if not Config.Notifications.enabled then return end
    
    -- Limpar notificações antigas
    if #notifications.queue >= notifications.maxQueue then
        table.remove(notifications.queue, 1)
    end
    
    -- Adicionar nova notificação
    table.insert(notifications.queue, {
        message = message,
        type = type or 'info',
        timestamp = GetGameTimer()
    })
    
    -- Enviar para NUI
    SendNUIMessage({
        type = 'notification',
        notification = {
            message = message,
            type = type,
            position = Config.Notifications.position,
            duration = Config.Notifications.duration
        }
    })
end

-- Funções auxiliares de notificação
local function notifySuccess(message)
    showNotification(message, 'success')
end

local function notifyError(message)
    showNotification(message, 'error')
end

local function notifyInfo(message)
    showNotification(message, 'info')
end

local function notifyWarning(message)
    showNotification(message, 'warning')
end

-- Eventos
RegisterNetEvent('tokyo_box:client:updateConfig', function(newConfig)
    if type(newConfig) ~= 'table' then 
        notifyError('Configuração inválida')
        return 
    end
    
    for k, v in pairs(newConfig) do
        config[k] = v
    end
    
    manageCache('config', newConfig)
    notifySuccess('Configurações atualizadas com sucesso')
    log("Configurações atualizadas")
end)

RegisterNetEvent('tokyo_box:client:updateState', function(newState)
    if not newState then 
        notifyError('Estado inválido')
        return 
    end
    
    if newState.currentTrack then
        currentTrack = newState.currentTrack
        manageCache('tracks', currentTrack)
        notifyInfo('Nova música carregada')
    end
    
    if newState.playlist then
        playlist = newState.playlist
        manageCache('playlists', playlist)
        notifyInfo('Playlist atualizada')
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
    
    TriggerEvent('tokyo_box:client:updateUI', {
        currentTrack = currentTrack,
        playlist = playlist,
        volume = volume,
        isPlaying = isPlaying,
        repeatMode = repeatMode,
        shuffle = shuffle
    })
    
    log("Estado atualizado")
end)

RegisterNetEvent('tokyo_box:client:updateProgress', function(progress)
    if not currentTrack then return end
    
    TriggerEvent('tokyo_box:client:updateUI', {
        progress = progress
    })
    
    log("Progresso atualizado: " .. progress)
end)

-- Comandos
RegisterCommand('tokyobox', function()
    if not isInitialized then
        initialize()
    end
    
    TriggerEvent('tokyo_box:client:showUI')
end)

-- Teclas
RegisterKeyMapping('tokyobox', 'Abrir Tokyo Box', 'keyboard', Config.Keys.open)

-- Exportações
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

exports('SetConfig', function(newConfig)
    if type(newConfig) ~= 'table' then return false end
    
    for k, v in pairs(newConfig) do
        config[k] = v
    end
    return true
end)

-- Inicialização
CreateThread(function()
    while not initializeFramework() do
        Wait(100)
    end
    
    initialize()
end)

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

-- Eventos
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

local function setTheme(themeName, customTheme)
    if customTheme then
        themes.custom[themeName] = customTheme
    end
    
    if not themes.custom[themeName] and not themes.default[themeName] then
        notifyError('Tema não encontrado')
        return false
    end
    
    themes.current = themeName
    local theme = themes.custom[themeName] or themes.default[themeName]
    
    SendNUIMessage({
        type = 'updateTheme',
        theme = theme
    })
    
    notifySuccess('Tema alterado para: ' .. themeName)
    return true
end

local function getTheme(themeName)
    return themes.custom[themeName] or themes.default[themeName]
end

local function getCurrentTheme()
    return themes.current
end

-- Exportações de tema
exports('SetTheme', setTheme)
exports('GetTheme', getTheme)
exports('GetCurrentTheme', getCurrentTheme)

-- Evento para atualizar tema
RegisterNetEvent('tokyo_box:client:updateTheme', function(themeName, customTheme)
    setTheme(themeName, customTheme)
end)

local function savePlaylist(name, tracks)
    if not name or not tracks then
        notifyError('Nome da playlist ou faixas inválidas')
        return false
    end
    
    if #savedPlaylists.items >= savedPlaylists.maxPlaylists then
        notifyWarning('Número máximo de playlists atingido')
        return false
    end
    
    savedPlaylists.items[name] = {
        tracks = tracks,
        createdAt = os.time(),
        updatedAt = os.time()
    }
    
    -- Salvar no servidor
    TriggerServerEvent('tokyo_box:server:savePlaylist', name, tracks)
    
    notifySuccess('Playlist salva com sucesso: ' .. name)
    return true
end

local function loadPlaylist(name)
    if not savedPlaylists.items[name] then
        notifyError('Playlist não encontrada: ' .. name)
        return false
    end
    
    playlist = savedPlaylists.items[name].tracks
    TriggerEvent('tokyo_box:client:updateUI', {
        playlist = playlist
    })
    
    notifySuccess('Playlist carregada: ' .. name)
    return true
end

local function deletePlaylist(name)
    if not savedPlaylists.items[name] then
        notifyError('Playlist não encontrada: ' .. name)
        return false
    end
    
    savedPlaylists.items[name] = nil
    TriggerServerEvent('tokyo_box:server:deletePlaylist', name)
    
    notifySuccess('Playlist removida: ' .. name)
    return true
end

local function getSavedPlaylists()
    return savedPlaylists.items
end

-- Exportações de playlist
exports('SavePlaylist', savePlaylist)
exports('LoadPlaylist', loadPlaylist)
exports('DeletePlaylist', deletePlaylist)
exports('GetSavedPlaylists', getSavedPlaylists)

-- Eventos de playlist
RegisterNetEvent('tokyo_box:client:updatePlaylists', function(playlists)
    if type(playlists) ~= 'table' then
        notifyError('Dados de playlist inválidos')
        return
    end
    
    savedPlaylists.items = playlists
    notifyInfo('Playlists atualizadas')
end) 