--[[
    Tokyo Box - Sistema de Temas
    Versão 1.0.0
]]

local Config = require 'config'
local QBCore = exports['qb-core']:GetCoreObject()

-- Temas disponíveis
local themes = {
    default = {
        primary = '#2196F3',
        secondary = '#1976D2',
        background = '#121212',
        surface = '#1E1E1E',
        text = '#FFFFFF',
        textSecondary = '#B0B0B0',
        error = '#F44336',
        success = '#4CAF50',
        warning = '#FFC107',
        info = '#2196F3'
    },
    dark = {
        primary = '#BB86FC',
        secondary = '#3700B3',
        background = '#121212',
        surface = '#1E1E1E',
        text = '#FFFFFF',
        textSecondary = '#B0B0B0',
        error = '#CF6679',
        success = '#03DAC6',
        warning = '#FFC107',
        info = '#BB86FC'
    },
    light = {
        primary = '#6200EE',
        secondary = '#3700B3',
        background = '#FFFFFF',
        surface = '#F5F5F5',
        text = '#000000',
        textSecondary = '#757575',
        error = '#B00020',
        success = '#03DAC6',
        warning = '#FFC107',
        info = '#6200EE'
    }
}

-- Tema atual
local currentTheme = 'default'

-- Funções auxiliares
local function applyTheme(theme)
    if not themes[theme] then
        print("^1[ERRO] Tokyo Box - Theme: Tema '" .. theme .. "' não encontrado^7")
        return false
    end
    
    currentTheme = theme
    SendNUIMessage({
        type = 'updateTheme',
        theme = themes[theme]
    })
    
    return true
end

local function getTheme()
    return themes[currentTheme]
end

local function getThemeColor(color)
    local theme = getTheme()
    return theme[color] or theme.primary
end

-- Eventos
RegisterNetEvent('tokyo_box:client:setTheme', function(theme)
    if applyTheme(theme) then
        TriggerEvent('tokyo_box:client:notify', 'Tema alterado com sucesso', 'success')
    else
        TriggerEvent('tokyo_box:client:notify', 'Erro ao alterar tema', 'error')
    end
end)

-- Comandos
RegisterCommand('tokyoboxtheme', function(source, args)
    if not args[1] then
        TriggerEvent('tokyo_box:client:notify', 'Tema atual: ' .. currentTheme, 'info')
        return
    end
    
    local theme = args[1]
    if applyTheme(theme) then
        TriggerEvent('tokyo_box:client:notify', 'Tema alterado para: ' .. theme, 'success')
    else
        TriggerEvent('tokyo_box:client:notify', 'Tema não encontrado: ' .. theme, 'error')
    end
end)

-- Exportações
exports('GetTheme', getTheme)
exports('GetThemeColor', getThemeColor)
exports('SetTheme', applyTheme)
exports('AddTheme', function(name, theme)
    if type(theme) ~= 'table' then return false end
    
    themes[name] = theme
    return true
end)

-- Inicialização
CreateThread(function()
    applyTheme(currentTheme)
end)

return {
    Themes = themes,
    GetTheme = getTheme,
    GetThemeColor = getThemeColor,
    SetTheme = applyTheme,
    AddTheme = exports.AddTheme
} 