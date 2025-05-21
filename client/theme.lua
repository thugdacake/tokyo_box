--[[
    Tokyo Box - Sistema de Temas
    Versão 1.0.0
]]

local Config = require 'config'

-- Temas disponíveis
local Themes = {
    dark = {
        primary = "#FF0000",
        secondary = "#00FF00",
        background = "#000000",
        text = "#FFFFFF",
        border = "#333333",
        hover = "#444444",
        shadow = "rgba(0, 0, 0, 0.5)",
        borderRadius = "4px",
        transitionSpeed = "0.3s"
    },
    light = {
        primary = "#FF0000",
        secondary = "#00FF00",
        background = "#FFFFFF",
        text = "#000000",
        border = "#CCCCCC",
        hover = "#EEEEEE",
        shadow = "rgba(0, 0, 0, 0.2)",
        borderRadius = "4px",
        transitionSpeed = "0.3s"
    }
}

-- Função para aplicar tema
local function ApplyTheme(themeName)
    if not Themes[themeName] then
        themeName = Config.DefaultTheme or "dark"
    end
    
    local theme = Themes[themeName]
    local css = string.format([[
        :root {
            --primary-color: %s;
            --secondary-color: %s;
            --background-color: %s;
            --text-color: %s;
            --border-color: %s;
            --hover-color: %s;
            --shadow-color: %s;
            --border-radius: %s;
            --transition-speed: %s;
        }
    ]], 
    theme.primary,
    theme.secondary,
    theme.background,
    theme.text,
    theme.border,
    theme.hover,
    theme.shadow,
    theme.borderRadius,
    theme.transitionSpeed)
    
    SendNUIMessage({
        type = "applyTheme",
        css = css
    })
end

-- Função para obter tema atual
local function GetCurrentTheme()
    return Config.DefaultTheme or "dark"
end

-- Função para listar temas disponíveis
local function ListThemes()
    local themes = {}
    for name, _ in pairs(Themes) do
        table.insert(themes, name)
    end
    return themes
end

-- Exportar funções
exports("ApplyTheme", ApplyTheme)
exports("GetCurrentTheme", GetCurrentTheme)
exports("ListThemes", ListThemes)

-- Aplicar tema padrão ao iniciar
Citizen.CreateThread(function()
    Wait(1000) -- Aguardar carregamento da NUI
    ApplyTheme(GetCurrentTheme())
end)

return {
    ApplyTheme = ApplyTheme,
    GetCurrentTheme = GetCurrentTheme,
    ListThemes = ListThemes,
    Themes = Themes
} 