--[[
    Tokyo Box - Utilitários do Cliente
    Versão 1.0.1
]]

local QBCore = exports['qb-core']:GetCoreObject()

-- Funções auxiliares
local function formatTime(seconds)
    if not seconds then return "00:00" end
    
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    
    if hours > 0 then
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    else
        return string.format("%02d:%02d", minutes, secs)
    end
end

local function formatFileSize(bytes)
    if not bytes then return "0 B" end
    
    local units = {"B", "KB", "MB", "GB", "TB"}
    local size = bytes
    local unit = 1
    
    while size >= 1024 and unit < #units do
        size = size / 1024
        unit = unit + 1
    end
    
    return string.format("%.1f %s", size, units[unit])
end

local function sanitizeString(str)
    if not str then return "" end
    
    return string.gsub(str, "[<>\"']", "")
end

local function validateURL(url)
    if not url then return false end
    
    local patterns = {
        "^https?://[%w-_%.%?%.:/%+=&]+$",
        "^[%w-_%.%?%.:/%+=&]+$"
    }
    
    for _, pattern in ipairs(patterns) do
        if string.match(url, pattern) then
            return true
        end
    end
    
    return false
end

local function deepCopy(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for k, v in pairs(original) do
            copy[k] = deepCopy(v)
        end
    else
        copy = original
    end
    return copy
end

local function tableLength(t)
    if type(t) ~= 'table' then return 0 end
    
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

local function tableContains(t, value)
    if type(t) ~= 'table' then return false end
    
    for _, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

local function tableRemoveValue(t, value)
    if type(t) ~= 'table' then return end
    
    for k, v in pairs(t) do
        if v == value then
            table.remove(t, k)
            return
        end
    end
end

local function tableShuffle(t)
    if type(t) ~= 'table' then return end
    
    local n = #t
    while n > 1 do
        local k = math.random(n)
        t[n], t[k] = t[k], t[n]
        n = n - 1
    end
    return t
end

local function debounce(func, wait)
    local timeout
    
    return function(...)
        local args = {...}
        if timeout then
            ClearTimeout(timeout)
        end
        
        timeout = SetTimeout(wait, function()
            func(unpack(args))
        end)
    end
end

local function throttle(func, limit)
    local lastRun = 0
    
    return function(...)
        local now = GetGameTimer()
        if now - lastRun >= limit then
            lastRun = now
            return func(...)
        end
    end
end

-- Função para formatar duração
function FormatDuration(duration)
    if not duration then return "0:00" end
    
    -- Converter formato ISO 8601 para segundos
    if type(duration) == "string" and duration:find("PT") then
        local seconds = 0
        local hours = duration:match("(%d+)H")
        local minutes = duration:match("(%d+)M")
        local secs = duration:match("(%d+)S")
        
        if hours then seconds = seconds + tonumber(hours) * 3600 end
        if minutes then seconds = seconds + tonumber(minutes) * 60 end
        if secs then seconds = seconds + tonumber(secs) end
        
        duration = seconds
    end
    
    local minutes = math.floor(duration / 60)
    local remainingSeconds = math.floor(duration % 60)
    
    return string.format("%d:%02d", minutes, remainingSeconds)
end

-- Função para formatar número
function FormatNumber(number)
    if not number then return "0" end
    
    number = tonumber(number)
    if not number then return "0" end
    
    if number >= 1000000 then
        return string.format("%.1fM", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.1fK", number / 1000)
    else
        return tostring(number)
    end
end

-- Função para validar URL
function IsValidURL(url)
    if not url or type(url) ~= "string" then return false end
    
    return url:match("^https?://[%w-_%.%?%.:/%+=&]+$") ~= nil
end

-- Função para validar ID de vídeo do YouTube
function IsValidYouTubeID(id)
    if not id or type(id) ~= "string" then return false end
    
    return id:match("^[%w_-]+$") ~= nil and #id == 11
end

-- Função para extrair ID de vídeo do YouTube de uma URL
function ExtractYouTubeID(url)
    if not url or type(url) ~= "string" then return nil end
    
    local id = url:match("v=([%w_-]+)")
    if not id then
        id = url:match("youtu%.be/([%w_-]+)")
    end
    
    return id
end

-- Função para verificar se o jogador está em um veículo
function IsPlayerInVehicle()
    local ped = PlayerPedId()
    return IsPedInAnyVehicle(ped, false)
end

-- Função para verificar se o jogador está próximo de outro jogador
function IsPlayerNearby(targetId, maxDistance)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local targetPed = GetPlayerPed(targetId)
    if not DoesEntityExist(targetPed) then return false end
    
    local targetCoords = GetEntityCoords(targetPed)
    local distance = #(playerCoords - targetCoords)
    
    return distance <= maxDistance
end

-- Função para obter jogadores próximos
function GetNearbyPlayers(maxDistance)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local players = GetActivePlayers()
    local nearbyPlayers = {}
    
    for _, playerId in ipairs(players) do
        if playerId ~= PlayerId() then
            local targetPed = GetPlayerPed(playerId)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)
            
            if distance <= maxDistance then
                table.insert(nearbyPlayers, {
                    id = playerId,
                    distance = distance
                })
            end
        end
    end
    
    return nearbyPlayers
end

-- Função para calcular volume baseado na distância
function CalculateDistanceVolume(baseVolume, distance, maxDistance)
    if distance >= maxDistance then return 0 end
    
    local volumeFactor = 1 - (distance / maxDistance)
    return math.floor(baseVolume * volumeFactor)
end

-- Função para verificar se o jogador tem permissão
function HasPermission(permission)
    -- Esta função deve ser implementada de acordo com o sistema de permissões do servidor
    -- Por padrão, retorna true para testes
    return true
end

-- Exportar funções
exports("FormatDuration", FormatDuration)
exports("FormatNumber", FormatNumber)
exports("IsValidURL", IsValidURL)
exports("IsValidYouTubeID", IsValidYouTubeID)
exports("ExtractYouTubeID", ExtractYouTubeID)
exports("IsPlayerInVehicle", IsPlayerInVehicle)
exports("IsPlayerNearby", IsPlayerNearby)
exports("GetNearbyPlayers", GetNearbyPlayers)
exports("CalculateDistanceVolume", CalculateDistanceVolume)
exports("HasPermission", HasPermission)
exports('FormatTime', formatTime)
exports('FormatFileSize', formatFileSize)
exports('SanitizeString', sanitizeString)
exports('ValidateURL', validateURL)
exports('DeepCopy', deepCopy)
exports('TableLength', tableLength)
exports('TableContains', tableContains)
exports('TableRemoveValue', tableRemoveValue)
exports('TableShuffle', tableShuffle)
exports('Debounce', debounce)
exports('Throttle', throttle)

-- Inicialização
CreateThread(function()
    math.randomseed(GetGameTimer())
end)
