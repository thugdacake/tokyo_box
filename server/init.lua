--[[
    Tokyo Box - Inicialização
    Versão 1.0.3
]]

-- Carregar dependências
local success, Config = pcall(require, 'config')
if not success then
    print("^1[Tokyo Box] Erro ao carregar config.lua^0")
    return
end

local success, Database = pcall(require, 'server.database')
if not success or type(Database) ~= "table" then
    print("^1[Tokyo Box] Erro ao carregar server/database.lua^0")
    return
end

local success, YouTubeAPI = pcall(require, 'server.youtube_api')
if not success then
    print("^1[Tokyo Box] Erro ao carregar server/youtube_api.lua^0")
    return
end

local QBCore = exports['qb-core']:GetCoreObject()

-- Cache para rate limiting
local rateLimits = {}
local QUOTA_LIMIT = 10000 -- Quota diária da API
local QUOTA_RESET = 24 * 60 * 60 -- 24 horas em segundos

-- Função para verificar rate limit
local function checkRateLimit(source)
    local now = os.time()
    if not rateLimits[source] then
        rateLimits[source] = {
            count = 0,
            lastReset = now
        }
    end

    -- Reset diário
    if now - rateLimits[source].lastReset > QUOTA_RESET then
        rateLimits[source].count = 0
        rateLimits[source].lastReset = now
    end

    -- Verificar limite
    if rateLimits[source].count >= QUOTA_LIMIT then
        return false
    end

    rateLimits[source].count = rateLimits[source].count + 1
    return true
end

-- Função de log colorido
local function Log(level, message)
    local colors = {
        info = "^2", -- Verde
        warn = "^3", -- Amarelo
        error = "^1", -- Vermelho
        debug = "^5" -- Azul
    }
    
    local prefix = string.format("%s[Tokyo Box] [%s]^0", colors[level] or colors.info, level:upper())
    print(prefix .. " " .. message)
end

-- Funções auxiliares
local function log(message)
    if Config.Debug then
        print("^3[DEBUG] Tokyo Box - Init: " .. message .. "^7")
    end
end

-- Função de inicialização
local function initialize()
    -- Verificar dependências
    local requiredDeps = {
        'qb-core',
        'oxmysql'
    }
    
    local optionalDeps = {
        'ox_lib'
    }
    
    for _, dep in ipairs(requiredDeps) do
        if not GetResourceState(dep) == 'started' then
            log("Dependência obrigatória não encontrada: " .. dep)
            return false
        end
    end
    
    for _, dep in ipairs(optionalDeps) do
        if not GetResourceState(dep) == 'started' then
            log("Dependência opcional não encontrada: " .. dep)
        end
    end
    
    -- Verificar API key
    if not Config.API.key or Config.API.key == "" then
        log("API key não configurada")
        return false
    end
    
    -- Inicializar banco de dados
    exports['tokyo_box']:InitializeDatabase()
    
    -- Carregar configurações
    exports['tokyo_box']:GetSetting('config', function(config)
        if config then
            for k, v in pairs(config) do
                Config[k] = v
            end
        end
    end)
    
    log("Inicialização concluída")
    return true
end

-- Eventos
RegisterNetEvent('tokyo_box:server:getConfig', function()
    local source = source
    TriggerClientEvent('tokyo_box:client:updateConfig', source, Config)
end)

RegisterNetEvent('tokyo_box:server:saveConfig', function(newConfig)
    local source = source
    
    -- Verificar permissão
    if not Config.Permissions.admin then
        TriggerClientEvent("tokyo_box:notification", source, {
            type = "error",
            message = "Sem permissão para salvar configurações"
        })
        return
    end
    
    -- Salvar configurações
    exports['tokyo_box']:SetSetting('config', newConfig, function()
        -- Atualizar configurações
        for k, v in pairs(newConfig) do
            Config[k] = v
        end
        
        -- Notificar clientes
        TriggerClientEvent('tokyo_box:client:updateConfig', -1, Config)
        
        TriggerClientEvent("tokyo_box:notification", source, {
            type = "success",
            message = "Configurações salvas"
        })
    end)
end)

-- Inicialização
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    if not initialize() then
        log("Falha na inicialização")
        StopResource(resourceName)
    end
end)

-- Eventos do servidor
RegisterNetEvent('tokyo:server:initialize', function()
    local source = source
    if not checkRateLimit(source) then
        TriggerClientEvent('tokyo:client:notification', source, 'error', 'Limite de requisições excedido')
        return
    end

    -- Inicialização com timeout
    local success = pcall(function()
        SetTimeout(5000, function()
            if not initialize() then
                TriggerClientEvent('tokyo:client:notification', source, 'error', 'Falha ao inicializar servidor')
            end
        end)
    end)

    if not success then
        TriggerClientEvent('tokyo:client:notification', source, 'error', 'Erro interno do servidor')
    end
end)

-- Cleanup ao parar o recurso
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Limpar cache
        rateLimits = {}
        
        -- Fechar conexões
        if Database and type(Database) == "table" then
            pcall(function()
                Database.cleanup()
            end)
        end
    end
end)

-- Exportar funções
exports('checkRateLimit', checkRateLimit)
exports('getQuotaInfo', function(source)
    if not rateLimits[source] then return nil end
    return {
        count = rateLimits[source].count,
        limit = QUOTA_LIMIT,
        resetIn = QUOTA_RESET - (os.time() - rateLimits[source].lastReset)
    }
end)

-- Exportar função de log
exports("Log", Log)
exports('Initialize', initialize) 