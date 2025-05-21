--[[
    Tokyo Box - Testes de Notificações
    Testes unitários para o sistema de notificações
    Versão: 1.0.0
]]

describe('Sistema de Notificações', function()
    -- Mock das funções necessárias
    local SendNUIMessage
    local TriggerEvent
    
    setup(function()
        SendNUIMessage = spy.new(function() end)
        TriggerEvent = spy.new(function() end)
        
        _G.SendNUIMessage = SendNUIMessage
        _G.TriggerEvent = TriggerEvent
    end)
    
    teardown(function()
        _G.SendNUIMessage = nil
        _G.TriggerEvent = nil
    end)
    
    -- Testes de notificações básicas
    describe('Notificações Básicas', function()
        it('deve enviar notificação de sucesso', function()
            Notification.Success('Operação concluída com sucesso')
            
            assert.spy(SendNUIMessage).was.called_with({
                type = 'notification',
                data = {
                    type = 'success',
                    message = 'Operação concluída com sucesso',
                    duration = Config.Notifications.Duration
                }
            })
        end)
        
        it('deve enviar notificação de erro', function()
            Notification.Error('Ocorreu um erro')
            
            assert.spy(SendNUIMessage).was.called_with({
                type = 'notification',
                data = {
                    type = 'error',
                    message = 'Ocorreu um erro',
                    duration = Config.Notifications.Duration
                }
            })
        end)
        
        it('deve enviar notificação de aviso', function()
            Notification.Warning('Atenção')
            
            assert.spy(SendNUIMessage).was.called_with({
                type = 'notification',
                data = {
                    type = 'warning',
                    message = 'Atenção',
                    duration = Config.Notifications.Duration
                }
            })
        end)
        
        it('deve enviar notificação de informação', function()
            Notification.Info('Informação importante')
            
            assert.spy(SendNUIMessage).was.called_with({
                type = 'notification',
                data = {
                    type = 'info',
                    message = 'Informação importante',
                    duration = Config.Notifications.Duration
                }
            })
        end)
    end)
    
    -- Testes de notificações personalizadas
    describe('Notificações Personalizadas', function()
        it('deve enviar notificação com duração personalizada', function()
            local customDuration = 5000
            Notification.Show('Mensagem', 'info', customDuration)
            
            assert.spy(SendNUIMessage).was.called_with({
                type = 'notification',
                data = {
                    type = 'info',
                    message = 'Mensagem',
                    duration = customDuration
                }
            })
        end)
        
        it('deve usar duração padrão quando não especificada', function()
            Notification.Show('Mensagem', 'info')
            
            assert.spy(SendNUIMessage).was.called_with({
                type = 'notification',
                data = {
                    type = 'info',
                    message = 'Mensagem',
                    duration = Config.Notifications.Duration
                }
            })
        end)
        
        it('deve validar tipo de notificação', function()
            assert.has_error(function()
                Notification.Show('Mensagem', 'tipo_invalido')
            end, 'Tipo de notificação inválido')
        end)
        
        it('deve validar mensagem vazia', function()
            assert.has_error(function()
                Notification.Show('', 'info')
            end, 'Mensagem não pode estar vazia')
        end)
        
        it('deve validar duração negativa', function()
            assert.has_error(function()
                Notification.Show('Mensagem', 'info', -1000)
            end, 'Duração deve ser positiva')
        end)
    end)
    
    -- Testes de notificações com formatação
    describe('Notificações com Formatação', function()
        it('deve formatar mensagem com argumentos', function()
            Notification.Success('Operação %s concluída', 'teste')
            
            assert.spy(SendNUIMessage).was.called_with({
                type = 'notification',
                data = {
                    type = 'success',
                    message = 'Operação teste concluída',
                    duration = Config.Notifications.Duration
                }
            })
        end)
        
        it('deve formatar mensagem com múltiplos argumentos', function()
            Notification.Info('Usuário %s (%s) conectado', 'teste', '123')
            
            assert.spy(SendNUIMessage).was.called_with({
                type = 'notification',
                data = {
                    type = 'info',
                    message = 'Usuário teste (123) conectado',
                    duration = Config.Notifications.Duration
                }
            })
        end)
        
        it('deve lidar com argumentos faltantes', function()
            Notification.Warning('Aviso: %s')
            
            assert.spy(SendNUIMessage).was.called_with({
                type = 'notification',
                data = {
                    type = 'warning',
                    message = 'Aviso: %s',
                    duration = Config.Notifications.Duration
                }
            })
        end)
    end)
    
    -- Testes de notificações com eventos
    describe('Notificações com Eventos', function()
        it('deve disparar evento ao mostrar notificação', function()
            Notification.Show('Mensagem', 'info')
            
            assert.spy(TriggerEvent).was.called_with('tokyo_box:notification', {
                type = 'info',
                message = 'Mensagem',
                duration = Config.Notifications.Duration
            })
        end)
        
        it('deve disparar evento específico para cada tipo', function()
            Notification.Success('Sucesso')
            assert.spy(TriggerEvent).was.called_with('tokyo_box:notification:success', {
                message = 'Sucesso',
                duration = Config.Notifications.Duration
            })
            
            Notification.Error('Erro')
            assert.spy(TriggerEvent).was.called_with('tokyo_box:notification:error', {
                message = 'Erro',
                duration = Config.Notifications.Duration
            })
            
            Notification.Warning('Aviso')
            assert.spy(TriggerEvent).was.called_with('tokyo_box:notification:warning', {
                message = 'Aviso',
                duration = Config.Notifications.Duration
            })
            
            Notification.Info('Info')
            assert.spy(TriggerEvent).was.called_with('tokyo_box:notification:info', {
                message = 'Info',
                duration = Config.Notifications.Duration
            })
        end)
    end)
    
    -- Testes de notificações com posicionamento
    describe('Notificações com Posicionamento', function()
        it('deve usar posição padrão quando não especificada', function()
            Notification.Show('Mensagem', 'info')
            
            assert.spy(SendNUIMessage).was.called_with({
                type = 'notification',
                data = {
                    type = 'info',
                    message = 'Mensagem',
                    duration = Config.Notifications.Duration,
                    position = Config.Notifications.Position
                }
            })
        end)
        
        it('deve aceitar posição personalizada', function()
            Notification.Show('Mensagem', 'info', nil, 'top-left')
            
            assert.spy(SendNUIMessage).was.called_with({
                type = 'notification',
                data = {
                    type = 'info',
                    message = 'Mensagem',
                    duration = Config.Notifications.Duration,
                    position = 'top-left'
                }
            })
        end)
        
        it('deve validar posição inválida', function()
            assert.has_error(function()
                Notification.Show('Mensagem', 'info', nil, 'posicao_invalida')
            end, 'Posição de notificação inválida')
        end)
    end)
    
    -- Testes de notificações com ícones
    describe('Notificações com Ícones', function()
        it('deve incluir ícone padrão para cada tipo', function()
            Notification.Success('Sucesso')
            
            assert.spy(SendNUIMessage).was.called_with({
                type = 'notification',
                data = {
                    type = 'success',
                    message = 'Sucesso',
                    duration = Config.Notifications.Duration,
                    icon = Config.Notifications.Types.Success.Icon
                }
            })
        end)
        
        it('deve aceitar ícone personalizado', function()
            Notification.Show('Mensagem', 'info', nil, nil, 'custom-icon')
            
            assert.spy(SendNUIMessage).was.called_with({
                type = 'notification',
                data = {
                    type = 'info',
                    message = 'Mensagem',
                    duration = Config.Notifications.Duration,
                    position = Config.Notifications.Position,
                    icon = 'custom-icon'
                }
            })
        end)
    end)
    
    -- Testes de notificações com animações
    describe('Notificações com Animações', function()
        it('deve incluir animação padrão', function()
            Notification.Show('Mensagem', 'info')
            
            assert.spy(SendNUIMessage).was.called_with({
                type = 'notification',
                data = {
                    type = 'info',
                    message = 'Mensagem',
                    duration = Config.Notifications.Duration,
                    position = Config.Notifications.Position,
                    icon = Config.Notifications.Types.Info.Icon,
                    animation = 'fade'
                }
            })
        end)
        
        it('deve aceitar animação personalizada', function()
            Notification.Show('Mensagem', 'info', nil, nil, nil, 'slide')
            
            assert.spy(SendNUIMessage).was.called_with({
                type = 'notification',
                data = {
                    type = 'info',
                    message = 'Mensagem',
                    duration = Config.Notifications.Duration,
                    position = Config.Notifications.Position,
                    icon = Config.Notifications.Types.Info.Icon,
                    animation = 'slide'
                }
            })
        end)
        
        it('deve validar animação inválida', function()
            assert.has_error(function()
                Notification.Show('Mensagem', 'info', nil, nil, nil, 'animacao_invalida')
            end, 'Animação de notificação inválida')
        end)
    end)
end) 