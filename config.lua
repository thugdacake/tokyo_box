--[[
    Tokyo Box - Configurações
    Versão: 1.0.0
]]

Config = {
    -- Framework
    Framework = 'qb-core',
    
    -- YouTube API
    YouTube = {
        apiKey = 'SUA_CHAVE_API_AQUI', -- Substitua pela sua chave da API do YouTube
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
        enabled = false,
        level = 'info'
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
    },
    
    -- Dependências
    Dependencies = {
        'qb-core',
        'oxmysql'
    }
}

return Config
