local QBCore = exports['qb-core']:GetCoreObject()

-- Configurações
local config = {
    defaultLocale = 'pt-BR',
    fallbackLocale = 'en-US',
    debug = false
}

-- Cache de traduções
local translations = {}

-- Funções auxiliares
local function loadTranslations(locale)
    if translations[locale] then return true end
    
    local success, result = pcall(function()
        return LoadResourceFile(GetCurrentResourceName(), 'locales/' .. locale .. '.lua')
    end)
    
    if not success or not result then
        if config.debug then
            print("^1[ERRO] Tokyo Box - Locale: Erro ao carregar traduções para '" .. locale .. "'^7")
        end
        return false
    end
    
    local fn, err = load(result)
    if not fn then
        if config.debug then
            print("^1[ERRO] Tokyo Box - Locale: Erro ao compilar traduções para '" .. locale .. "': " .. err .. "^7")
        end
        return false
    end
    
    local success, result = pcall(fn)
    if not success then
        if config.debug then
            print("^1[ERRO] Tokyo Box - Locale: Erro ao executar traduções para '" .. locale .. "': " .. result .. "^7")
        end
        return false
    end
    
    translations[locale] = result
    return true
end

local function getTranslation(key, locale)
    locale = locale or config.defaultLocale
    
    if not translations[locale] then
        if not loadTranslations(locale) then
            if locale ~= config.fallbackLocale then
                return getTranslation(key, config.fallbackLocale)
            end
            return key
        end
    end
    
    local keys = {}
    for k in string.gmatch(key, "([^.]+)") do
        table.insert(keys, k)
    end
    
    local value = translations[locale]
    for _, k in ipairs(keys) do
        if type(value) ~= 'table' then
            return key
        end
        value = value[k]
    end
    
    if type(value) == 'string' then
        return value
    end
    
    if locale ~= config.fallbackLocale then
        return getTranslation(key, config.fallbackLocale)
    end
    
    return key
end

local function formatTranslation(translation, ...)
    local args = {...}
    return string.gsub(translation, "{(%d+)}", function(n)
        return args[tonumber(n)] or ""
    end)
end

-- Eventos
RegisterNetEvent('tokyo_box:client:setLocale', function(locale)
    if loadTranslations(locale) then
        config.defaultLocale = locale
        TriggerEvent('tokyo_box:client:notify', 'Idioma alterado com sucesso', 'success')
    else
        TriggerEvent('tokyo_box:client:notify', 'Erro ao alterar idioma', 'error')
    end
end)

-- Comandos
RegisterCommand('tokyoboxlocale', function(source, args)
    if not args[1] then
        TriggerEvent('tokyo_box:client:notify', 'Idioma atual: ' .. config.defaultLocale, 'info')
        return
    end
    
    local locale = args[1]
    if loadTranslations(locale) then
        config.defaultLocale = locale
        TriggerEvent('tokyo_box:client:notify', 'Idioma alterado para: ' .. locale, 'success')
    else
        TriggerEvent('tokyo_box:client:notify', 'Idioma não encontrado: ' .. locale, 'error')
    end
end)

-- Exportações
exports('t', function(key, ...)
    local translation = getTranslation(key)
    if ... then
        return formatTranslation(translation, ...)
    end
    return translation
end)

exports('SetConfig', function(newConfig)
    if type(newConfig) ~= 'table' then return false end
    
    for k, v in pairs(newConfig) do
        config[k] = v
    end
    return true
end)

exports('GetLocale', function()
    return config.defaultLocale
end)

exports('GetAvailableLocales', function()
    local locales = {}
    local files = {}
    
    local success, result = pcall(function()
        return LoadResourceFile(GetCurrentResourceName(), 'locales')
    end)
    
    if success and result then
        for file in string.gmatch(result, "([^\n]+)") do
            if string.match(file, "%.lua$") then
                table.insert(files, file)
            end
        end
    end
    
    for _, file in ipairs(files) do
        local locale = string.match(file, "([^%.]+)%.lua$")
        if locale then
            table.insert(locales, locale)
        end
    end
    
    return locales
end)

-- Inicialização
CreateThread(function()
    loadTranslations(config.defaultLocale)
    if config.defaultLocale ~= config.fallbackLocale then
        loadTranslations(config.fallbackLocale)
    end
end) 