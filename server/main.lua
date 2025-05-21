--[[
    Tokyo Box - Servidor Principal
    Versão: 1.0.0
]]

-- Carregar configuração
Config = {}

-- Exportar configuração
exports('GetConfig', function()
    return Config
end)

-- Inicialização
CreateThread(function()
    print("^2[Tokyo Box] Inicializando...^0")
    
    -- Carregar configuração do arquivo
    local success, result = pcall(function()
        return LoadResourceFile(GetCurrentResourceName(), 'config.lua')
    end)
    
    if not success or not result then
        print("^1[Tokyo Box] Erro ao carregar config.lua^0")
        return
    end
    
    -- Executar configuração
    local fn, err = load(result)
    if not fn then
        print("^1[Tokyo Box] Erro ao compilar config.lua: " .. tostring(err) .. "^0")
        return
    end
    
    local configResult = fn()
    if type(configResult) == 'table' then
        Config = configResult
        print("^2[Tokyo Box] Configuração carregada com sucesso^0")
    else
        print("^1[Tokyo Box] Erro: config.lua não retornou uma tabela^0")
        return
    end
    
    -- Verificar dependências
    if not Config.Dependencies then
        print("^1[Tokyo Box] Erro: Dependências não configuradas^0")
        return
    end
    
    for _, dependency in ipairs(Config.Dependencies) do
        if GetResourceState(dependency) ~= 'started' then
            print("^1[Tokyo Box] Erro: Dependência " .. dependency .. " não encontrada^0")
            return
        end
    end
    
    print("^2[Tokyo Box] Inicializado com sucesso^0")
end)

local QBCore = exports['qb-core']:GetCoreObject()

-- Estado
local isInitialized = false
local players = {}

-- Funções auxiliares
local function log(message)
    if Config.Debug and Config.Debug.enabled then
        print("^3[DEBUG] Tokyo Box - Server: " .. message .. "^7")
    end
end

local function initialize()
    if isInitialized then return end
    
    -- Carregar configurações do banco de dados
    MySQL.ready(function()
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS tokyo_box_playlists (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                tracks TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )
        ]])
        
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS tokyo_box_settings (
                id INT AUTO_INCREMENT PRIMARY KEY,
                `key` VARCHAR(255) NOT NULL UNIQUE,
                `value` TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )
        ]])
    end)
    
    isInitialized = true
    log("Servidor inicializado")
end

-- Eventos
RegisterNetEvent('tokyo_box:server:getConfig', function()
    local source = source
    TriggerClientEvent('tokyo_box:client:updateConfig', source, Config)
end)

RegisterNetEvent('tokyo_box:server:getPlaylists', function()
    local source = source
    
    MySQL.query('SELECT * FROM tokyo_box_playlists', {}, function(results)
        if results then
            TriggerClientEvent('tokyo_box:client:updateState', source, {
                playlists = results
            })
        end
    end)
end)

RegisterNetEvent('tokyo_box:server:savePlaylist', function(name, tracks)
    local source = source
    
    if not name or not tracks then return end
    
    MySQL.insert('INSERT INTO tokyo_box_playlists (name, tracks) VALUES (?, ?)', {
        name,
        json.encode(tracks)
    }, function(id)
        if id then
            TriggerClientEvent('tokyo_box:client:updateState', source, {
                playlists = {
                    {
                        id = id,
                        name = name,
                        tracks = tracks
                    }
                }
            })
        end
    end)
end)

RegisterNetEvent('tokyo_box:server:deletePlaylist', function(id)
    local source = source
    
    if not id then return end
    
    MySQL.query('DELETE FROM tokyo_box_playlists WHERE id = ?', {id}, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('tokyo_box:client:updateState', source, {
                playlists = {}
            })
        end
    end)
end)

RegisterNetEvent('tokyo_box:server:updateState', function(newState)
    local source = source
    
    if not newState then return end
    
    players[source] = newState
    
    TriggerClientEvent('tokyo_box:client:updateState', -1, {
        players = players
    })
end)

-- Comandos
QBCore.Commands.Add('tokyobox', 'Abrir Tokyo Box', {}, false, function(source)
    TriggerClientEvent('tokyo_box:client:showUI', source)
end)

-- Inicialização
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    initialize()
end)

AddEventHandler('playerDropped', function()
    local source = source
    players[source] = nil
    
    TriggerClientEvent('tokyo_box:client:updateState', -1, {
        players = players
    })
end) 