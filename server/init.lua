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

-- Validar dependências
local function ValidateDependencies()
    local dependencies = {
        {name = "qbx_core", required = true},
        {name = "oxmysql", required = true}
    }
    
    local missing = {}
    
    for _, dep in ipairs(dependencies) do
        local state = GetResourceState(dep.name)
        if not state:find("start") then
            table.insert(missing, dep.name)
            if dep.required then
                Log("error", string.format("Dependência obrigatória não encontrada: %s", dep.name))
            else
                Log("warn", string.format("Dependência opcional não encontrada: %s", dep.name))
            end
        end
    end
    
    return #missing == 0
end

-- Inicialização segura
local function initializeServer()
    Log("info", "Iniciando Tokyo Box...")
    
    -- Validar dependências
    if not ValidateDependencies() then
        Log("error", "Falha na inicialização: dependências ausentes")
        return false
    end
    
    -- Verificar se o MySQL está disponível
    if not MySQL then
        Log("error", "MySQL não está disponível")
        return false
    end
    
    -- Inicializar banco de dados
    Log("info", "Inicializando banco de dados...")
    local success, error = pcall(function()
        return Database.CreateTables()
    end)
    
    if not success or not error then
        Log("error", "Falha ao criar tabelas do banco de dados: " .. tostring(error))
        return false
    end
    
    -- Verificar integridade
    Log("info", "Verificando integridade do banco de dados...")
    success, error = pcall(function()
        return Database.VerifyIntegrity()
    end)
    
    if not success or not error then
        Log("error", "Falha na verificação de integridade: " .. tostring(error))
        return false
    end
    
    -- Inicializar API do YouTube
    Log("info", "Inicializando API do YouTube...")
    if not YouTubeAPI or not YouTubeAPI.isInitialized then
        Log("error", "Falha ao inicializar API do YouTube")
        return false
    end
    
    -- Registrar comandos de debug
    RegisterCommand("tokyobox_spawnBox", function(source, args, raw)
        if source == 0 then
            Log("warn", "Comando executado pelo console")
            return
        end
        TriggerClientEvent("tokyo_box:spawnSpeaker", source)
    end, true)
    
    RegisterCommand("tokyobox_btToggle", function(source, args, raw)
        if source == 0 then
            Log("warn", "Comando executado pelo console")
            return
        end
        TriggerClientEvent("tokyo_box:btToggle", source)
    end, true)
    
    Log("info", "Tokyo Box inicializado com sucesso!")
    return true
end

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
            if not initializeServer() then
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