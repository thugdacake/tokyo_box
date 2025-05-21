local Locale = {}
local currentLocale = Config.DefaultLocale
local translations = {}

-- Função para carregar traduções
local function loadTranslations(locale)
    local file = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. locale .. '.json')
    if not file then
        print('^1[Tokyo Box] Arquivo de tradução não encontrado: ' .. locale .. '^7')
        return false
    end
    
    local success, result = pcall(json.decode, file)
    if not success then
        print('^1[Tokyo Box] Erro ao decodificar arquivo de tradução: ' .. locale .. '^7')
        return false
    end
    
    translations = result
    return true
end

-- Função para obter texto traduzido
function Locale.Get(key)
    local keys = {}
    for k in key:gmatch('[^%.]+') do
        table.insert(keys, k)
    end
    
    local value = translations
    for _, k in ipairs(keys) do
        if not value[k] then
            return key
        end
        value = value[k]
    end
    
    return value
end

-- Função para formatar texto com argumentos
function Locale.Format(key, ...)
    local text = Locale.Get(key)
    local args = {...}
    
    return text:gsub('%%s', function()
        return table.remove(args, 1) or '%s'
    end)
end

-- Função para mudar idioma
function Locale.Set(locale)
    if not loadTranslations(locale) then
        return false
    end
    
    currentLocale = locale
    
    -- Enviar idioma para NUI
    SendNUIMessage({
        type = 'setLocale',
        locale = locale,
        translations = translations
    })
    
    -- Disparar evento de mudança de idioma
    TriggerEvent('tokyo_box:localeChanged', locale)
    
    return true
end

-- Função para obter idioma atual
function Locale.GetCurrent()
    return currentLocale
end

-- Comando para mudar idioma
RegisterCommand('tokyobox_lang', function(source, args)
    if #args == 0 then
        print('^3[Tokyo Box] Idioma atual: ' .. currentLocale .. '^7')
        return
    end
    
    local locale = args[1]
    if Locale.Set(locale) then
        print('^2[Tokyo Box] Idioma alterado para: ' .. locale .. '^7')
    else
        print('^1[Tokyo Box] Idioma inválido. Use: pt-BR, en-US^7')
    end
end)

-- Inicializar idioma padrão
Citizen.CreateThread(function()
    Locale.Set(Config.DefaultLocale)
end)

-- Exportar funções
exports('GetLocale', Locale.GetCurrent)
exports('SetLocale', Locale.Set)
exports('GetText', Locale.Get)
exports('FormatText', Locale.Format)

-- Eventos
RegisterNetEvent('tokyo_box:setLanguage')
AddEventHandler('tokyo_box:setLanguage', function(lang)
    Locale.Set(lang)
end) 