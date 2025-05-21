--[[
    Tokyo Box - Sistema de Notificações
    Sistema de notificações para o Tokyo Box
    Versão: 1.0.0
    Descrição: Sistema de notificações com cleanup de eventos
]]

local Notification = {}

local QBCore = exports['qb-core']:GetCoreObject()

-- Configurações
local config = {
    position = 'top-right',
    duration = 5000,
    animation = {
        in = 'fadeIn',
        out = 'fadeOut'
    },
    sound = true
}

-- Tipos de notificação válidos
local validTypes = {
    success = true,
    error = true,
    warning = true,
    info = true
}

-- Posições válidas
local validPositions = {
    ['top-right'] = true,
    ['top-left'] = true,
    ['bottom-right'] = true,
    ['bottom-left'] = true
}

-- Animações válidas
local validAnimations = {
    fade = true,
    slide = true,
    scale = true
}

-- Cache de eventos registrados
local registeredEvents = {}

-- Funções auxiliares
local function playSound(type)
    if not config.sound then return end
    
    local sound = {
        success = 'success',
        error = 'error',
        info = 'info'
    }
    
    if sound[type] then
        SendNUIMessage({
            type = 'playSound',
            sound = sound[type]
        })
    end
end

local function showNotification(message, type)
    if not message then return end
    
    type = type or 'info'
    local colors = {
        success = '#4CAF50',
        error = '#F44336',
        info = '#2196F3',
        warning = '#FFC107'
    }
    
    SendNUIMessage({
        type = 'showNotification',
        notification = {
            message = message,
            type = type,
            color = colors[type] or colors.info,
            position = config.position,
            duration = config.duration,
            animation = config.animation
        }
    })
    
    playSound(type)
end

-- Função principal para mostrar notificações
function Notification.Show(message, type, duration, position, icon, animation)
    -- Validações
    if not message or message == '' then
        print('^1[Tokyo Box] Erro: Mensagem vazia^7')
        return
    end
    
    if not validTypes[type] then
        print('^1[Tokyo Box] Erro: Tipo de notificação inválido^7')
        return
    end
    
    if duration and duration < 0 then
        error('Duração deve ser positiva')
    end
    
    if position and not validPositions[position] then
        error('Posição de notificação inválida')
    end
    
    if animation and not validAnimations[animation] then
        error('Animação de notificação inválida')
    end
    
    -- Configurações padrão
    duration = duration or Config.Notifications.Duration
    position = VALID_POSITIONS[position] and position or 'top-right'
    icon = icon or Config.Notifications.Types[type].Icon
    animation = VALID_ANIMATIONS[animation] and animation or 'fade'
    
    -- Enviar notificação para a NUI
    SendNUIMessage({
        type = 'notification',
        data = {
            type = type,
            message = message,
            duration = duration,
            position = position,
            icon = icon,
            animation = animation
        }
    })
    
    -- Disparar evento
    TriggerEvent('tokyo_box:notification', {
        type = type,
        message = message,
        duration = duration
    })
    
    -- Disparar evento específico do tipo
    TriggerEvent('tokyo_box:notification:' .. type, {
        message = message,
        duration = duration
    })
end

-- Funções auxiliares para cada tipo de notificação
function Notification.Success(message, duration, position, icon, animation)
    Notification.Show(message, 'success', duration, position, icon, animation)
end

function Notification.Error(message, duration, position, icon, animation)
    Notification.Show(message, 'error', duration, position, icon, animation)
end

function Notification.Warning(message, duration, position, icon, animation)
    Notification.Show(message, 'warning', duration, position, icon, animation)
end

function Notification.Info(message, duration, position, icon, animation)
    Notification.Show(message, 'info', duration, position, icon, animation)
end

-- Registrar evento com cleanup
function Notification.RegisterEvent(eventName, callback)
    if registeredEvents[eventName] then
        RemoveEventHandler(registeredEvents[eventName])
    end
    
    registeredEvents[eventName] = RegisterNetEvent(eventName, callback)
end

-- Cleanup de eventos
function Notification.Cleanup()
    for eventName, handler in pairs(registeredEvents) do
        RemoveEventHandler(handler)
        registeredEvents[eventName] = nil
    end
end

-- Evento de cleanup ao parar o recurso
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Notification.Cleanup()
    end
end)

-- Eventos
RegisterNetEvent('tokyo_box:client:notify', function(message, type)
    showNotification(message, type)
end)

-- Exportações
exports('ShowNotification', showNotification)
exports('SetConfig', function(newConfig)
    if type(newConfig) ~= 'table' then return end
    
    for k, v in pairs(newConfig) do
        config[k] = v
    end
end)

-- Inicialização
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, Config.Keys.notification) then
            showNotification('Teste de notificação', 'info')
        end
    end
end)

-- Exportar módulo
return Notification 