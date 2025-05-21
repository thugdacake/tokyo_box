--[[
    Tokyo Box - Verificação de Dependências
    Versão: 1.0.0
]]

local QBCore = exports['qb-core']:GetCoreObject()

-- Funções auxiliares
local function log(message)
    if Config.Debug then
        print("^3[DEBUG] Tokyo Box - Dependencies: " .. message .. "^7")
    end
end

-- Função para verificar estado do recurso
local function checkResource(resourceName)
    local state = GetResourceState(resourceName)
    if state == 'started' then
        return true
    elseif state == 'stopped' then
        log("Recurso parado: " .. resourceName)
        return false
    elseif state == 'starting' then
        log("Recurso iniciando: " .. resourceName)
        return false
    elseif state == 'stopping' then
        log("Recurso parando: " .. resourceName)
        return false
    else
        log("Recurso não encontrado: " .. resourceName)
        return false
    end
end

-- Função para verificar dependências
local function checkDependencies()
    -- Dependências obrigatórias
    local requiredDeps = {
        'qb-core',
        'oxmysql'
    }
    
    -- Dependências opcionais
    local optionalDeps = {
        'ox_lib'
    }
    
    -- Verificar dependências obrigatórias
    local missingRequired = {}
    for _, dep in ipairs(requiredDeps) do
        if not checkResource(dep) then
            table.insert(missingRequired, dep)
        end
    end
    
    if #missingRequired > 0 then
        log("Dependências obrigatórias ausentes: " .. table.concat(missingRequired, ", "))
        return false
    end
    
    -- Verificar dependências opcionais
    local missingOptional = {}
    for _, dep in ipairs(optionalDeps) do
        if not checkResource(dep) then
            table.insert(missingOptional, dep)
        end
    end
    
    if #missingOptional > 0 then
        log("Dependências opcionais ausentes: " .. table.concat(missingOptional, ", "))
    end
    
    -- Verificar API key
    if not Config.API.key or Config.API.key == "" then
        log("API key não configurada")
        return false
    end
    
    -- Verificar conexão com banco de dados
    MySQL.ready(function()
        MySQL.query('SELECT 1', {}, function(result)
            if not result then
                log("Falha na conexão com banco de dados")
                return false
            end
        end)
    end)
    
    return true
end

-- Eventos
RegisterNetEvent('tokyo_box:server:checkDependencies', function()
    local source = source
    
    if checkDependencies() then
        TriggerClientEvent("tokyo_box:notification", source, {
            type = "success",
            message = "Todas as dependências estão instaladas"
        })
    else
        TriggerClientEvent("tokyo_box:notification", source, {
            type = "error",
            message = "Algumas dependências estão ausentes"
        })
    end
end)

-- Exportações
exports('CheckDependencies', checkDependencies)

return {
    CheckDependencies = checkDependencies
} 