--[[
    Tokyo Box - Configurações
    Versão 1.0.0
]]

Config = {}

-- Framework
Config.Framework = 'qb-core'

-- API do YouTube
Config.YouTube = {
    apiKey = '', -- Configure sua chave aqui
    apiEndpoint = 'https://www.googleapis.com/youtube/v3',
    searchLimit = 10,
    maxResults = 50,
    regionCode = 'BR',
    relevanceLanguage = 'pt',
    quotaLimit = 10000,
    cacheDuration = 3600
}

-- Configurações da UI
Config.UI = {
    position = 'bottom-right',
    width = 360,
    height = 640,
    scale = 1.0,
    animation = true,
    animationDuration = 300,
    borderRadius = 36,
    shadow = '0 8px 24px rgba(0, 0, 0, 0.35)'
}

-- Configurações do Player
Config.Player = {
    defaultVolume = 50,
    minVolume = 0,
    maxVolume = 100,
    fadeInTime = 1000,
    fadeOutTime = 1000,
    crossfadeTime = 2000,
    defaultCover = 'img/default-cover.png'
}

-- Configurações de permissões
Config.Permissions = {
    useCommand = true,
    playMusic = true,
    controlPlayback = true,
    adjustVolume = true,
    managePlaylist = true
}

-- Configurações de comandos
Config.Commands = {
    main = 'tokyobox',
    spawnBox = 'tokyobox_spawn',
    btToggle = 'tokyobox_bt',
    lang = 'tokyobox_lang',
    theme = 'tokyobox_theme'
}

-- Configurações de notificações
Config.Notifications = {
    enabled = true,
    position = 'top-right',
    duration = 3000
}

-- Configurações do banco de dados
Config.Database = {
    useFramework = true,
    tableName = 'tokyo_box_playlists'
}

-- Configurações de cache
Config.Cache = {
    enabled = true,
    maxSize = 100,
    expirationTime = 3600
}

-- Configurações de debug
Config.Debug = {
    enabled = false,
    level = 'info',
    file = 'tokyo-box.log',
    maxSize = 1024 * 1024 * 5, -- 5MB
    maxFiles = 5
}

-- Configurações de teclas
Config.Keys = {
    open = 'F7',
    playPause = 'MEDIA_PLAY_PAUSE',
    next = 'MEDIA_NEXT',
    previous = 'MEDIA_PREVIOUS',
    volumeUp = 'MEDIA_VOLUME_UP',
    volumeDown = 'MEDIA_VOLUME_DOWN',
    mute = 'MEDIA_MUTE'
}

-- Configurações de temas
Config.Themes = {
    dark = {
        primary = '#007AFF',
        background = 'rgba(20, 20, 20, 0.95)',
        text = '#FFFFFF',
        secondary = '#2D2D2D',
        accent = '#4A90E2'
    },
    light = {
        primary = '#007AFF',
        background = 'rgba(255, 255, 255, 0.95)',
        text = '#000000',
        secondary = '#F2F2F2',
        accent = '#4A90E2'
    }
}

-- Configurações de idiomas
Config.Languages = {
    ['pt-BR'] = {
        name = 'Português (Brasil)',
        code = 'pt-BR'
    },
    ['en-US'] = {
        name = 'English (US)',
        code = 'en-US'
    }
}

-- Configurações de dependências
Config.Dependencies = {
    required = {
        'qb-core',
        'oxmysql'
    },
    optional = {
        'ox_lib'
    }
}

return Config
