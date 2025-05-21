--[[
    Tokyo Box - Testes de Configuração
    Testes unitários para o sistema de configuração
    Versão: 1.0.0
]]

describe('Sistema de Configuração', function()
    -- Testes de obtenção de configuração
    describe('Obtenção de Configuração', function()
        it('deve retornar valor padrão para chave inexistente', function()
            assert.equals('valor_padrao', Config.Get('chave.inexistente', 'valor_padrao'))
        end)

        it('deve retornar valor padrão para chave nula', function()
            assert.equals('valor_padrao', Config.Get(nil, 'valor_padrao'))
        end)

        it('deve obter valor de configuração aninhada', function()
            assert.equals(Config.API.YouTubeKey, Config.Get('API.YouTubeKey'))
        end)

        it('deve obter valor de configuração simples', function()
            assert.equals(Config.Debug, Config.Get('Debug'))
        end)
    end)

    -- Testes de validação de configuração
    describe('Validação de Configuração', function()
        it('deve validar configurações corretas', function()
            local errors = Config.Validate()
            assert.equals(0, #errors)
        end)

        it('deve detectar API key ausente', function()
            local originalKey = Config.API.YouTubeKey
            Config.API.YouTubeKey = ""
            
            local errors = Config.Validate()
            assert.equals(1, #errors)
            assert.equals("API key do YouTube não configurada", errors[1])
            
            Config.API.YouTubeKey = originalKey
        end)

        it('deve detectar URL base ausente', function()
            local originalUrl = Config.API.BaseUrl
            Config.API.BaseUrl = ""
            
            local errors = Config.Validate()
            assert.equals(1, #errors)
            assert.equals("URL base da API não configurada", errors[1])
            
            Config.API.BaseUrl = originalUrl
        end)

        it('deve detectar volume padrão inválido', function()
            local originalVolume = Config.Player.DefaultVolume
            Config.Player.DefaultVolume = Config.Player.MaxVolume + 1
            
            local errors = Config.Validate()
            assert.equals(1, #errors)
            assert.equals(string.format("Volume padrão deve estar entre %d e %d", Config.Player.MinVolume, Config.Player.MaxVolume), errors[1])
            
            Config.Player.DefaultVolume = originalVolume
        end)

        it('deve detectar alcance padrão inválido', function()
            local originalRange = Config.Player.DefaultRange
            Config.Player.DefaultRange = Config.Player.MaxRange + 1
            
            local errors = Config.Validate()
            assert.equals(1, #errors)
            assert.equals(string.format("Alcance padrão deve estar entre %.1f e %.1f metros", Config.Player.MinRange, Config.Player.MaxRange), errors[1])
            
            Config.Player.DefaultRange = originalRange
        end)

        it('deve detectar escala padrão inválida', function()
            local originalScale = Config.UI.DefaultScale
            Config.UI.DefaultScale = Config.UI.MaxScale + 1
            
            local errors = Config.Validate()
            assert.equals(1, #errors)
            assert.equals(string.format("Escala padrão deve estar entre %.1f e %.1f", Config.UI.MinScale, Config.UI.MaxScale), errors[1])
            
            Config.UI.DefaultScale = originalScale
        end)

        it('deve detectar limite de músicas inválido', function()
            local originalMaxTracks = Config.Playlist.MaxTracks
            Config.Playlist.MaxTracks = 0
            
            local errors = Config.Validate()
            assert.equals(1, #errors)
            assert.equals("Limite de músicas inválido", errors[1])
            
            Config.Playlist.MaxTracks = originalMaxTracks
        end)

        it('deve detectar limites de nome inválidos', function()
            local originalMinLength = Config.Playlist.MinNameLength
            local originalMaxLength = Config.Playlist.MaxNameLength
            
            Config.Playlist.MinNameLength = 0
            Config.Playlist.MaxNameLength = 0
            
            local errors = Config.Validate()
            assert.equals(1, #errors)
            assert.equals("Limites de nome inválidos", errors[1])
            
            Config.Playlist.MinNameLength = originalMinLength
            Config.Playlist.MaxNameLength = originalMaxLength
        end)

        it('deve detectar limite de erros consecutivos inválido', function()
            local originalMaxErrors = Config.System.MaxConsecutiveErrors
            Config.System.MaxConsecutiveErrors = 0
            
            local errors = Config.Validate()
            assert.equals(1, #errors)
            assert.equals("Limite de erros consecutivos inválido", errors[1])
            
            Config.System.MaxConsecutiveErrors = originalMaxErrors
        end)

        it('deve detectar tempo de reset de erros inválido', function()
            local originalResetTime = Config.System.ErrorResetTime
            Config.System.ErrorResetTime = 0
            
            local errors = Config.Validate()
            assert.equals(1, #errors)
            assert.equals("Tempo de reset de erros inválido", errors[1])
            
            Config.System.ErrorResetTime = originalResetTime
        end)

        it('deve detectar timeout de conexão muito baixo', function()
            local originalTimeout = Config.Database.ConnectionTimeout
            Config.Database.ConnectionTimeout = 500
            
            local errors = Config.Validate()
            assert.equals(1, #errors)
            assert.equals("Timeout de conexão muito baixo", errors[1])
            
            Config.Database.ConnectionTimeout = originalTimeout
        end)

        it('deve detectar timeout de queries muito baixo', function()
            local originalTimeout = Config.Database.QueryTimeout
            Config.Database.QueryTimeout = 500
            
            local errors = Config.Validate()
            assert.equals(1, #errors)
            assert.equals("Timeout de queries muito baixo", errors[1])
            
            Config.Database.QueryTimeout = originalTimeout
        end)

        it('deve detectar número máximo de conexões inválido', function()
            local originalMaxConnections = Config.Database.MaxConnections
            Config.Database.MaxConnections = 0
            
            local errors = Config.Validate()
            assert.equals(1, #errors)
            assert.equals("Número máximo de conexões inválido", errors[1])
            
            Config.Database.MaxConnections = originalMaxConnections
        end)
    end)

    -- Testes de temas
    describe('Temas', function()
        it('deve ter tema padrão definido', function()
            assert.not_nil(Config.DefaultTheme)
            assert.not_nil(Config.Themes[Config.DefaultTheme])
        end)

        it('deve ter todos os temas necessários', function()
            local requiredThemes = {'Default', 'Dark', 'Light', 'Neon'}
            for _, theme in ipairs(requiredThemes) do
                assert.not_nil(Config.Themes[theme], string.format("Tema %s não encontrado", theme))
            end
        end)

        it('deve ter todas as propriedades necessárias em cada tema', function()
            local requiredProperties = {'primary', 'secondary', 'text', 'background', 'border-radius', 'transition-speed'}
            
            for themeName, theme in pairs(Config.Themes) do
                for _, prop in ipairs(requiredProperties) do
                    assert.not_nil(theme[prop], string.format("Propriedade %s não encontrada no tema %s", prop, themeName))
                end
            end
        end)

        it('deve ter cores válidas em cada tema', function()
            local function isValidColor(color)
                return string.match(color, '^#[0-9A-Fa-f]{6}$') ~= nil
            end
            
            for themeName, theme in pairs(Config.Themes) do
                assert.is_true(isValidColor(theme.primary), string.format("Cor primária inválida no tema %s", themeName))
                assert.is_true(isValidColor(theme.secondary), string.format("Cor secundária inválida no tema %s", themeName))
                assert.is_true(isValidColor(theme.text), string.format("Cor de texto inválida no tema %s", themeName))
                assert.is_true(isValidColor(theme.background), string.format("Cor de fundo inválida no tema %s", themeName))
            end
        end)

        it('deve ter valores numéricos válidos em cada tema', function()
            for themeName, theme in pairs(Config.Themes) do
                assert.is_true(tonumber(string.match(theme['border-radius'], '(%d+)px')) > 0, 
                    string.format("Border radius inválido no tema %s", themeName))
                assert.is_true(tonumber(string.match(theme['transition-speed'], '(%d+%.?%d*)s')) > 0, 
                    string.format("Velocidade de transição inválida no tema %s", themeName))
            end
        end)
    end)

    -- Testes de notificações
    describe('Notificações', function()
        it('deve ter configurações válidas de notificação', function()
            assert.is_true(Config.Notifications.Duration > 0)
            assert.not_nil(Config.Notifications.Position)
            assert.not_nil(Config.Notifications.Types)
        end)

        it('deve ter todos os tipos de notificação necessários', function()
            local requiredTypes = {'Info', 'Success', 'Warning', 'Error'}
            for _, type in ipairs(requiredTypes) do
                assert.not_nil(Config.Notifications.Types[type], string.format("Tipo de notificação %s não encontrado", type))
            end
        end)

        it('deve ter propriedades válidas em cada tipo de notificação', function()
            for typeName, type in pairs(Config.Notifications.Types) do
                assert.not_nil(type.Background, string.format("Background não encontrado no tipo %s", typeName))
                assert.not_nil(type.Icon, string.format("Ícone não encontrado no tipo %s", typeName))
            end
        end)
    end)

    -- Testes de áudio
    describe('Áudio', function()
        it('deve ter configurações válidas de áudio', function()
            assert.is_true(Config.Audio.DefaultVolume >= Config.Audio.MinVolume)
            assert.is_true(Config.Audio.DefaultVolume <= Config.Audio.MaxVolume)
            assert.is_true(Config.Audio.VolumeStep > 0)
            assert.is_true(Config.Audio.FadeDuration > 0)
        end)

        it('deve ter configurações válidas de Bluetooth', function()
            assert.not_nil(Config.Audio.Bluetooth)
            assert.is_true(Config.Audio.Bluetooth.MaxConnections > 0)
            assert.is_true(Config.Audio.Bluetooth.ReconnectDelay > 0)
        end)

        it('deve ter configurações válidas de reprodução', function()
            assert.not_nil(Config.Audio.Playback)
            assert.is_true(Config.Audio.Playback.BufferSize > 0)
            assert.is_true(Config.Audio.Playback.MaxRetries > 0)
        end)
    end)

    -- Testes de cache
    describe('Cache', function()
        it('deve ter configurações válidas de cache', function()
            assert.not_nil(Config.Cache)
            assert.is_true(Config.Cache.Duration > 0)
            assert.is_true(Config.Cache.MaxSize > 0)
        end)
    end)

    -- Testes de debug
    describe('Debug', function()
        it('deve ter comandos de debug válidos', function()
            assert.not_nil(Config.DebugCommands)
            for cmdName, cmd in pairs(Config.DebugCommands) do
                assert.not_nil(cmd, string.format("Comando de debug %s não encontrado", cmdName))
            end
        end)
    end)
end) 