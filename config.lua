--[[
    Tokyo Box - Configurações
    Versão: 1.0.0
]]

local QBCore = exports['qb-core']:GetCoreObject()

Config = {
    -- Framework
    Framework = 'qb-core',
    
    -- YouTube API
    YouTube = {
        apiKey = GetConvar('TOKYO_BOX_YOUTUBE_API_KEY', 'AIzaSyAdzIskTxElZumF29pNBux-PYs7EOXWcDI'),
        quotaLimit = 10000,
        quotaUsed = 0,
        lastReset = os.time()
    },
    
    -- UI
    UI = {
        defaultTheme = 'dark',
        defaultVolume = 50,
        maxVolume = 100,
        minVolume = 0
    },
    
    -- Player
    Player = {
        defaultVolume = 0.5,
        minVolume = 0.0,
        maxVolume = 1.0,
        fadeInTime = 1000,
        fadeOutTime = 1000
    },
    
    -- Permissões
    Permissions = {
        useMusic = true,
        managePlaylists = true,
        skipTracks = true,
        controlVolume = true
    },
    
    -- Comandos
    Commands = {
        prefix = '/',
        music = 'music',
        playlist = 'playlist',
        volume = 'volume'
    },
    
    -- Notificações
    Notifications = {
        enabled = true,
        duration = 5000,
        position = 'top-right'
    },
    
    -- Banco de Dados
    Database = {
        enabled = true,
        tablePrefix = 'tokyo_box_',
        saveInterval = 300 -- 5 minutos
    },
    
    -- Cache
    Cache = {
        enabled = true,
        ttl = 3600, -- 1 hora
        maxSize = 1000
    },
    
    -- Debug
    Debug = {
        enabled = GetConvar('TOKYO_BOX_DEBUG', 'false') == 'true',
        level = GetConvar('TOKYO_BOX_DEBUG_LEVEL', 'info')
    },
    
    -- Teclas
    Keys = {
        toggle = 'F7',
        next = 'MEDIA_NEXT',
        prev = 'MEDIA_PREV',
        play = 'MEDIA_PLAY',
        pause = 'MEDIA_PAUSE'
    },
    
    -- Temas
    Themes = {
        dark = {
            primary = '#1a1a1a',
            secondary = '#2d2d2d',
            accent = '#4CAF50',
            text = '#ffffff'
        },
        light = {
            primary = '#ffffff',
            secondary = '#f5f5f5',
            accent = '#4CAF50',
            text = '#000000'
        }
    },
    
    -- Idiomas
    Languages = {
        default = 'pt-BR',
        available = {'pt-BR', 'en-US'}
    }
}

-- Verificações básicas
if not QBCore then
    print('^1[Tokyo Box] Erro: QBCore não está disponível^0')
    return
end

if not Config.YouTube.apiKey or Config.YouTube.apiKey == '' then
    print('^1[Tokyo Box] Erro: Chave da API do YouTube não configurada^0')
    return
end

print('^2[Tokyo Box] Configuração carregada com sucesso^0')
return Config
