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
    fadeTime = 0.3
}

-- Configurações do Player
Config.Player = {
    maxDistance = 10.0,
    defaultVolume = 0.5,
    fadeTime = 0.3,
    minVolume = 0.0,
    maxVolume = 1.0
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
    spawnBox = 'tokyobox_spawnBox',
    btToggle = 'tokyobox_btToggle',
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
    tablePrefix = 'tokyo_box_'
}

-- Configurações de Cache
Config.Cache = {
    enabled = true,
    maxSize = 100,
    expireTime = 3600
}

-- Configurações de Debug
Config.Debug = {
    enabled = false,
    level = 'info'
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

-- Configurações do YouTube
Config.YouTube = {
    APIKey = "YOUR_API_KEY_HERE", -- Substitua pela sua chave de API
    QuotaLimit = 10000, -- Limite diário de quota
    CacheDuration = 3600, -- Duração do cache em segundos
    RequestInterval = 1000 -- Intervalo entre requisições em milissegundos
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
    }
}

-- Configurações de teclas
Config.Keys = {
    toggle = 'F7',
    play = 'F8',
    pause = 'F9',
    next = 'F10',
    prev = 'F11',
    volume = 'F12'
}

-- Configurações de temas
Config.Themes = {
    dark = {
        primary = "#1a1a1a",
        secondary = "#2d2d2d",
        accent = "#4a90e2",
        text = "#ffffff"
    },
    light = {
        primary = "#ffffff",
        secondary = "#f5f5f5",
        accent = "#4a90e2",
        text = "#000000"
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

return Config
