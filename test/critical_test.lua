-- Tokyo Box - Critical Tests
-- Version: 1.0.0
-- Description: Testes para validar correções críticas

describe('Correções Críticas', function()
    -- Teste de inicialização do servidor
    it('deve inicializar o servidor corretamente', function()
        local success = pcall(function()
            TriggerEvent('tokyo:server:initialize')
        end)
        assert.is_true(success)
    end)

    -- Teste de rate limiting
    it('deve respeitar o rate limit', function()
        local source = 1
        local exceeded = false
        
        -- Simular muitas requisições
        for i = 1, 100 do
            if not exports['tokyo_box']:checkRateLimit(source) then
                exceeded = true
                break
            end
        end
        
        assert.is_true(exceeded)
    end)

    -- Teste de quota do YouTube
    it('deve respeitar a quota do YouTube', function()
        local videoId = 'dQw4w9WgXcQ'
        local success, error = YouTubeAPI.GetVideoInfo(videoId)
        
        -- Simular muitas requisições
        for i = 1, 100 do
            success, error = YouTubeAPI.GetVideoInfo(videoId)
            if not success then
                break
            end
        end
        
        assert.is_false(success)
        assert.is_not_nil(error)
    end)

    -- Teste de timeout no banco
    it('deve ter timeout em queries longas', function()
        local success, error = Database.executeQuery([[
            SELECT SLEEP(10)
        ]])
        
        assert.is_false(success)
        assert.is_not_nil(error)
        assert.is_true(string.find(error, 'Timeout'))
    end)

    -- Teste de cleanup de eventos
    it('deve limpar eventos ao parar o recurso', function()
        local eventCount = 0
        
        -- Registrar alguns eventos
        for i = 1, 5 do
            Notification.RegisterEvent('test:event:' .. i, function() end)
            eventCount = eventCount + 1
        end
        
        -- Simular parada do recurso
        TriggerEvent('onResourceStop', GetCurrentResourceName())
        
        -- Verificar se eventos foram removidos
        assert.is_equal(0, #Notification.registeredEvents)
    end)

    -- Teste de fallback da NUI
    it('deve mostrar fallback quando JS falhar', function()
        -- Simular erro no JS
        TriggerEvent('nui:error', 'Test error')
        
        -- Verificar se fallback está visível
        local fallback = GetNuiElement('fallback')
        assert.is_not_nil(fallback)
        assert.is_true(fallback.style.display ~= 'none')
    end)

    -- Teste de validação de ID do YouTube
    it('deve validar IDs do YouTube corretamente', function()
        -- IDs válidos
        assert.is_true(YouTubeAPI.ValidateId('dQw4w9WgXcQ', 'video'))
        assert.is_true(YouTubeAPI.ValidateId('PLxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', 'playlist'))
        
        -- IDs inválidos
        assert.is_false(YouTubeAPI.ValidateId('invalid', 'video'))
        assert.is_false(YouTubeAPI.ValidateId('invalid', 'playlist'))
        assert.is_false(YouTubeAPI.ValidateId('dQw4w9WgXcQ', 'invalid'))
    end)

    -- Teste de retry em queries
    it('deve tentar novamente em caso de falha', function()
        local attempts = 0
        local success = false
        
        -- Simular falha e sucesso
        local originalQuery = Database.executeQuery
        Database.executeQuery = function()
            attempts = attempts + 1
            if attempts == 3 then
                success = true
                return true
            end
            return false
        end
        
        Database.executeQuery('SELECT 1')
        
        assert.is_equal(3, attempts)
        assert.is_true(success)
        
        -- Restaurar função original
        Database.executeQuery = originalQuery
    end)
end) 