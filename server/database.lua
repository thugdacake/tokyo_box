--[[
    Tokyo Box - Banco de Dados (Corrigido)
    Versão 1.0.3
]]

-- Configurações do banco de dados
local Config = {
    Database = {
        TablePrefix = "tokyo_box_",
        Tables = {
            Playlists = "tokyo_box_playlists",
            Tracks = "tokyo_box_tracks",
            Favorites = "tokyo_box_favorites"
        }
    },
    System = {
        DebugMode = true,
        MaxPlaylists = 100,
        MaxFavorites = 100
    },
    Playlist = {
        MaxPlaylists = 10,
        MaxTracksPerPlaylist = 100,
        AllowDuplicates = false,
        DefaultCover = "https://i.imgur.com/default_cover.jpg"
    },
    Player = {
        DefaultVolume = 0.5,
        MinVolume = 0.0,
        MaxVolume = 1.0
    }
}

-- Estado dos jogadores
local PlayerStates = {}

-- Função de log
local function Log(level, message)
    if not Config.System.DebugMode and level == "debug" then
        return
    end
    local prefix = "[Tokyo Box]"
    prefix = prefix .. " [" .. level:upper() .. "]"
    print(prefix .. " " .. message)
end

-- Função de erro
local function HandleError(err, context)
    Log("error", string.format("Erro em %s: %s", context, err))
    return false
end

-- Sanitização SQL
local function SanitizeSQLInput(input)
    if not input then return nil end
    if type(input) == "string" then
        return input:gsub("'", "''")
    elseif type(input) == "number" then
        return input
    else
        return tostring(input)
    end
end

-- Função para executar query com timeout
local function executeQuery(query, params)
    if not MySQL then
        Log("error", "MySQL não está disponível")
        return false, "MySQL não está disponível"
    end

    local retries = 0
    local result = nil
    local error = nil
    
    while retries < 3 do
        local success = pcall(function()
            result = MySQL.query.await(query, params, 5000)
        end)
        
        if success then
            return true, result
        end
        
        retries = retries + 1
        if retries < 3 then
            Wait(1000)
        end
    end
    
    return false, 'Timeout ou erro na query após 3 tentativas'
end

-- Objeto Database
local Database = {
    -- Estado
    isInitialized = false,
    isConnected = false,
    lastError = nil,
    
    -- Cache
    cache = {},
    cacheTimeout = 3600,
    
    -- Configurações
    config = Config.Database,
    
    -- Funções auxiliares
    Log = Log,
    HandleError = HandleError,
    SanitizeSQLInput = SanitizeSQLInput,
    executeQuery = executeQuery
}

-- Função para criar tabelas
function Database.CreateTables()
    if not MySQL then
        return false, "MySQL não está disponível"
    end

    local tables = {
        {
            name = Config.Database.Tables.Playlists,
            query = [[
                CREATE TABLE IF NOT EXISTS tokyo_box_playlists (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    name VARCHAR(255) NOT NULL,
                    tracks TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
                )
            ]]
        },
        {
            name = Config.Database.Tables.Tracks,
            query = [[
                CREATE TABLE IF NOT EXISTS tokyo_box_tracks (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    playlist_id INT NOT NULL,
                    video_id VARCHAR(11) NOT NULL,
                    title VARCHAR(255) NOT NULL,
                    artist VARCHAR(255) NOT NULL,
                    thumbnail VARCHAR(255) NOT NULL,
                    duration INT NOT NULL,
                    position INT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (playlist_id) REFERENCES tokyo_box_playlists(id) ON DELETE CASCADE
                )
            ]]
        },
        {
            name = Config.Database.Tables.Favorites,
            query = [[
                CREATE TABLE IF NOT EXISTS tokyo_box_favorites (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    player_id VARCHAR(50) NOT NULL,
                    video_id VARCHAR(50) NOT NULL,
                    title VARCHAR(255) NOT NULL,
                    thumbnail VARCHAR(255) NOT NULL,
                    duration INT NOT NULL,
                    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    UNIQUE KEY unique_favorite (player_id, video_id)
                )
            ]]
        },
        {
            name = "tokyo_box_settings",
            query = [[
                CREATE TABLE IF NOT EXISTS tokyo_box_settings (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    `key` VARCHAR(255) NOT NULL UNIQUE,
                    `value` TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
                )
            ]]
        },
        {
            name = "tokyo_box_history",
            query = [[
                CREATE TABLE IF NOT EXISTS tokyo_box_history (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    track_id VARCHAR(255) NOT NULL,
                    track_title VARCHAR(255) NOT NULL,
                    played_by VARCHAR(255) NOT NULL,
                    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ]]
        }
    }
    
    for _, table in ipairs(tables) do
        local success, error = executeQuery(table.query)
        if not success then
            Log("error", 'Erro ao criar tabela ' .. table.name .. ': ' .. tostring(error))
            return false, error
        end
    end
    
    Database.isInitialized = true
    return true
end

-- Função para verificar integridade
function Database.VerifyIntegrity()
    if not Database.isInitialized then
        return false, "Banco de dados não inicializado"
    end
    
    local tables = {
        Config.Database.Tables.Playlists,
        Config.Database.Tables.Tracks,
        Config.Database.Tables.Favorites
    }
    
    for _, table in ipairs(tables) do
        local success, error = executeQuery('SELECT 1 FROM ' .. table .. ' LIMIT 1')
        if not success then
            Log("error", 'Erro ao verificar tabela ' .. table .. ': ' .. tostring(error))
            return false, error
        end
    end
    
    Database.isConnected = true
    return true
end

-- Função para limpar recursos
function Database.cleanup()
    Database.cache = {}
    Database.isInitialized = false
    Database.isConnected = false
    Database.lastError = nil
end

-- Funções de playlist
function Database.GetPlaylistById(playlistId)
    if not playlistId then return nil end
    
    local success, result = executeQuery([[
        SELECT * FROM ]] .. Config.Database.Tables.Playlists .. [[
        WHERE id = ?
    ]], {playlistId})
    
    if not success or not result or #result == 0 then
        return nil
    end
    
    return result[1]
end

function Database.GetPlaylistsByPlayer(playerId)
    if not playerId then return {} end
    
    local success, result = executeQuery([[
        SELECT * FROM ]] .. Config.Database.Tables.Playlists .. [[
        WHERE owner = ? OR is_public = true
        ORDER BY updated_at DESC
    ]], {playerId})
    
    if not success then
        return {}
    end
    
    return result or {}
end

function Database.GetAllPlaylists()
    local success, result = executeQuery([[
        SELECT * FROM ]] .. Config.Database.Tables.Playlists .. [[
        ORDER BY updated_at DESC
    ]])
    
    if not success then
        return {}
    end
    
    return result or {}
end

-- Funções de configuração
function Database.GetSetting(key, cb)
    MySQL.query('SELECT `value` FROM tokyo_box_settings WHERE `key` = ?', {key}, function(results)
        if cb then
            if results[1] then
                cb(json.decode(results[1].value))
            else
                cb(nil)
            end
        end
    end)
end

function Database.SetSetting(key, value, cb)
    MySQL.insert('INSERT INTO tokyo_box_settings (`key`, `value`) VALUES (?, ?) ON DUPLICATE KEY UPDATE `value` = ?', {
        key,
        json.encode(value),
        json.encode(value)
    }, function(id)
        if cb then
            cb(id)
        end
    end)
end

-- Funções de histórico
function Database.AddToHistory(trackId, trackTitle, playedBy, cb)
    MySQL.insert('INSERT INTO tokyo_box_history (track_id, track_title, played_by) VALUES (?, ?, ?)', {
        trackId,
        trackTitle,
        playedBy
    }, function(id)
        if cb then
            cb(id)
        end
    end)
end

function Database.GetHistory(limit, cb)
    MySQL.query('SELECT * FROM tokyo_box_history ORDER BY played_at DESC LIMIT ?', {limit}, function(results)
        if cb then
            cb(results)
        end
    end)
end

-- Exportar funções
exports("GetPlaylistById", Database.GetPlaylistById)
exports("GetPlaylistsByPlayer", Database.GetPlaylistsByPlayer)
exports("GetAllPlaylists", Database.GetAllPlaylists)
exports("CreatePlaylist", Database.CreatePlaylist)
exports("DeletePlaylist", Database.DeletePlaylist)
exports("AddTrackToPlaylist", Database.AddTrackToPlaylist)
exports("RemoveTrackFromPlaylist", Database.RemoveTrackFromPlaylist)
exports("AddFavorite", Database.AddFavorite)
exports("RemoveFavorite", Database.RemoveFavorite)
exports("GetFavoritesByPlayer", Database.GetFavoritesByPlayer)
exports("GetSetting", Database.GetSetting)
exports("SetSetting", Database.SetSetting)
exports("AddToHistory", Database.AddToHistory)
exports("GetHistory", Database.GetHistory)

-- Retornar o objeto Database
return Database