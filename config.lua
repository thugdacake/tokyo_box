--[[
    Tokyo Box - Configurações
    Versão 1.0.0
]]

Config = {}

-- Framework
Config.Framework = 'qb-core' -- 'qb-core' ou 'qbox'

-- API do YouTube
Config.YouTubeAPI = {
    enabled = true,
    apiKey = '', -- Sua chave da API do YouTube aqui
    maxResults = 10,
    regionCode = 'BR',
    language = 'pt-BR'
}

-- Configurações da UI
Config.UI = {
    defaultLocale = 'pt-BR',
    defaultTheme = 'dark',
    defaultScale = 1.0,
    maxResults = 10,
    updateInterval = 1000,
    fadeTime = 0.3,
    position = 'bottom-right',
    width = 360,
    height = 640,
    animation = true,
    animationDuration = 300,
    borderRadius = 36,
    shadow = '0 8px 24px rgba(0, 0, 0, 0.35)'
}

-- Configurações do Player
Config.Player = {
    maxDistance = 10.0,
    defaultVolume = 50,
    fadeTime = 0.3,
    minVolume = 0,
    maxVolume = 100,
    fadeInTime = 1000,
    fadeOutTime = 1000,
    crossfadeTime = 2000,
    defaultCover = 'img/default-cover.png'
}

-- Configurações de Permissões
Config.Permissions = {
    useCommand = true,
    playMusic = true,
    controlPlayback = true,
    adjustVolume = true,
    managePlaylist = true
}

-- Configurações de Comandos
Config.Commands = {
    main = 'tokyobox',
    spawnBox = 'tokyobox_spawn',
    btToggle = 'tokyobox_bt',
    lang = 'tokyobox_lang',
    theme = 'tokyobox_theme'
}

-- Configurações de Notificações
Config.Notifications = {
    enabled = true,
    position = 'top-right',
    duration = 3000
}

-- Configurações de Banco de Dados
Config.Database = {
    useFramework = true,
    useCustom = false,
    tablePrefix = 'tokyo_box_',
    tableName = 'tokyo_box_playlists'
}

-- Configurações de Cache
Config.Cache = {
    enabled = true,
    maxSize = 100,
    expireTime = 3600,
    expirationTime = 3600
}

-- Configurações de Debug
Config.Debug = {
    enabled = false,
    level = 'info',
    logLevel = 'info',
    file = 'tokyo-box.log',
    maxSize = 1024 * 1024 * 5, -- 5MB
    maxFiles = 5
}

-- Instruções para gerar chave da API do YouTube
Config.YouTubeAPIInstructions = [[
Para gerar uma chave da API do YouTube:

1. Acesse o Google Cloud Console: https://console.cloud.google.com/
2. Crie um novo projeto ou selecione um existente
3. Ative a YouTube Data API v3
4. Vá para "Credenciais"
5. Clique em "Criar Credenciais" > "Chave de API"
6. Copie a chave gerada e cole em Config.YouTubeAPI.apiKey
7. Restrinja a chave para uso apenas da YouTube Data API v3
8. Adicione restrições de IP se necessário

IMPORTANTE: Mantenha sua chave API segura e não a compartilhe!
]]

-- Configurações gerais
Config.Debug = false
Config.DefaultLocale = "pt-BR"
Config.DefaultTheme = "dark"
Config.DefaultScale = 1.0
Config.OpenCooldown = 500 -- ms
Config.Language = 'pt-BR'
Config.Theme = 'dark'

-- Configurações do YouTube
Config.YouTube = {
    APIKey = "YOUR_API_KEY_HERE", -- Substitua pela sua chave de API
    QuotaLimit = 10000, -- Limite diário de quota
    CacheDuration = 3600, -- Duração do cache em segundos
    RequestInterval = 1000, -- Intervalo entre requisições em milissegundos
    apiKey = 'SUA_CHAVE_AQUI',
    apiEndpoint = 'https://www.googleapis.com/youtube/v3',
    searchLimit = 10,
    maxResults = 50,
    regionCode = 'BR',
    relevanceLanguage = 'pt'
}

-- Configurações de permissões
Config.Permissions = {
    enabled = false,
    groups = {
        "admin",
        "mod"
    }
}

-- Configurações de logs
Config.Logs = {
    enabled = true,
    level = "info", -- debug, info, warn, error
    file = "tokyo-box.log"
}

-- Configurações de dependências
Config.Dependencies = {
    required = {
        "ox_lib",
        "oxmysql"
    },
    optional = {
        "qb-core",
        "es_extended"
    },
    framework = 'qb-core',
    database = 'oxmysql',
    cache = 'oxmysql'
}

-- Configurações de teclas
Config.Keys = {
    toggle = 'F7',
    play = 'F8',
    pause = 'F9',
    next = 'F10',
    prev = 'F11',
    volume = 'F12',
    open = 'F7',
    playPause = 'MEDIA_PLAY_PAUSE',
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

-- Configurações de sistema
Config.System = {
    DebugMode = true,
    MaxPlaylists = 100,
    MaxFavorites = 100,
    ErrorRetryCount = 3,
    ErrorRetryDelay = 1000
}

-- Configurações de segurança
Config.Security = {
    allowedDomains = {
        "youtube.com",
        "youtu.be",
        "i.ytimg.com"
    },
    maxRequestSize = 1024 * 1024, -- 1MB
    rateLimit = {
        window = 60, -- segundos
        max = 100    -- requisições
    }
}

-- Configurações da API
Config.API = {
    key = 'YOUR_API_KEY',
    baseUrl = 'https://www.googleapis.com/youtube/v3',
    cacheTime = 3600
}

-- Configurações gerais
Config.General = {
    debug = false,
    language = 'pt-BR',
    theme = 'dark',
    notifications = true,
    cache = true,
    database = true
}

-- Configurações de log
Config.Log = {
    enabled = true,
    level = 'info',
    file = 'tokyo-box.log',
    maxSize = 1024 * 1024 * 5, -- 5MB
    maxFiles = 5
}

return Config
