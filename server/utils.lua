--[[
    Tokyo Box - Utilitários do Servidor
    Versão 1.0.1
]]

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

-- Função para sanitizar entrada
function SanitizeInput(input)
    if not input then return nil end
    
    if type(input) == "string" then
        -- Remover caracteres potencialmente perigosos
        return input:gsub("[<>\"'&]", "")
    elseif type(input) == "number" then
        return input
    else
        return tostring(input)
    end
end

-- Função para verificar se o jogador tem permissão
function HasPermission(source, permission)
    if not source then return false end
    
    -- Verificar se QBCore está disponível
    if not QBCore then
        print("[Tokyo Box] QBCore não encontrado, concedendo permissão por padrão")
        return true
    end
    
    -- Verificar grupos administrativos
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if not xPlayer then return false end
    
    local playerGroup = xPlayer.PlayerData.permission
    if not playerGroup then return false end
    
    -- Verificar se o grupo tem permissão
    for _, group in ipairs(Config.Permissions.AdminGroups) do
        if playerGroup == group then
            return true
        end
    end
    
    -- Verificar permissão específica
    if permission == "play" then
        return Config.Permissions.UsePlayer
    elseif permission == "create_playlist" then
        return Config.Permissions.CreatePlaylists
    elseif permission == "manage_playlist" then
        return Config.Permissions.ManagePlaylists
    end
    
    return false
end

-- Função para obter jogadores próximos
function GetNearbyPlayers(source, range)
    local nearbyPlayers = {}
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    
    for _, playerId in ipairs(GetPlayers()) do
        playerId = tonumber(playerId)
        if playerId ~= source then
            local targetPed = GetPlayerPed(playerId)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)
            
            if distance <= range then
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

-- Função para gerar ID único
function GenerateUniqueID()
    local timestamp = os.time()
    local random = math.random(1000, 9999)
    return timestamp .. random
end

-- Exportar funções
exports("FormatDuration", FormatDuration)
exports("FormatNumber", FormatNumber)
exports("IsValidURL", IsValidURL)
exports("IsValidYouTubeID", IsValidYouTubeID)
exports("ExtractYouTubeID", ExtractYouTubeID)
exports("SanitizeInput", SanitizeInput)
exports("HasPermission", HasPermission)
exports("GetNearbyPlayers", GetNearbyPlayers)
exports("CalculateDistanceVolume", CalculateDistanceVolume)
exports("GenerateUniqueID", GenerateUniqueID)
