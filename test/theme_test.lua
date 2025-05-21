describe('Sistema de Temas', function()
    local Theme = require('client/theme')

    before_each(function()
        -- Mock para SendNUIMessage
        _G.SendNUIMessage = function(data) end
        
        -- Mock para TriggerEvent
        _G.TriggerEvent = function(event, ...) end
        
        -- Mock para Config
        _G.Config = {
            DefaultTheme = 'Default',
            Themes = {
                Default = {
                    primary = '#FF0000',
                    secondary = '#FF3333',
                    text = '#FFFFFF',
                    background = '#1A1A1A',
                    ['border-radius'] = '8px',
                    ['transition-speed'] = '0.3s'
                },
                Dark = {
                    primary = '#0066CC',
                    secondary = '#3399FF',
                    text = '#FFFFFF',
                    background = '#0A0A0A',
                    ['border-radius'] = '8px',
                    ['transition-speed'] = '0.3s'
                }
            }
        }
    end)

    describe('Aplicação de Temas', function()
        it('deve aplicar tema com sucesso', function()
            local result = Theme.Apply('Default')
            assert.is_true(result)
            assert.equals('Default', Theme.GetCurrent())
        end)
        
        it('deve falhar ao aplicar tema inexistente', function()
            local result = Theme.Apply('Invalid')
            assert.is_false(result)
        end)
        
        it('deve disparar evento ao mudar tema', function()
            local eventTriggered = false
            _G.TriggerEvent = function(event, theme)
                if event == 'tokyo_box:themeChanged' then
                    eventTriggered = true
                end
            end
            
            Theme.Apply('Default')
            assert.is_true(eventTriggered)
        end)
    end)

    describe('Obtenção de Temas', function()
        it('deve retornar tema atual', function()
            Theme.Apply('Default')
            assert.equals('Default', Theme.GetCurrent())
        end)
        
        it('deve listar temas disponíveis', function()
            local themes = Theme.List()
            assert.is_table(themes)
            assert.is_true(#themes > 0)
        end)
    end)

    describe('Comandos', function()
        it('deve mostrar tema atual sem argumentos', function()
            local output = ''
            _G.print = function(text)
                output = text
            end
            
            Theme.Apply('Default')
            _G.RegisterCommand('tokyobox_theme', function(source, args)
                if #args == 0 then
                    print('^3[Tokyo Box] Tema atual: ' .. Theme.GetCurrent() .. '^7')
                end
            end)
            
            _G.RegisterCommand('tokyobox_theme', function() end, false)
            assert.equals('^3[Tokyo Box] Tema atual: Default^7', output)
        end)
        
        it('deve mudar tema com argumento válido', function()
            local output = ''
            _G.print = function(text)
                output = text
            end
            
            _G.RegisterCommand('tokyobox_theme', function(source, args)
                if #args > 0 then
                    if Theme.Apply(args[1]) then
                        print('^2[Tokyo Box] Tema alterado para: ' .. args[1] .. '^7')
                    end
                end
            end)
            
            _G.RegisterCommand('tokyobox_theme', function() end, false)
            assert.equals('^2[Tokyo Box] Tema alterado para: Dark^7', output)
        end)
    end)

    describe('Inicialização', function()
        it('deve aplicar tema padrão ao iniciar', function()
            Theme.Apply(Config.DefaultTheme)
            assert.equals(Config.DefaultTheme, Theme.GetCurrent())
        end)
    end)

    describe('Validação de Temas', function()
        it('deve validar formato de cores hexadecimais', function()
            local validColors = {
                '#FF0000',
                '#00FF00',
                '#0000FF',
                '#FFFFFF'
            }
            
            local invalidColors = {
                'FF0000',
                '#FF00',
                '#FF000',
                'invalid'
            }
            
            for _, color in ipairs(validColors) do
                assert.is_true(Theme.isValidHexColor(color))
            end
            
            for _, color in ipairs(invalidColors) do
                assert.is_false(Theme.isValidHexColor(color))
            end
        end)
        
        it('deve validar valores numéricos', function()
            local validNumbers = {
                0,
                1,
                10,
                100
            }
            
            local invalidNumbers = {
                -1,
                'invalid',
                nil,
                {}
            }
            
            for _, num in ipairs(validNumbers) do
                assert.is_true(Theme.isValidNumber(num))
            end
            
            for _, num in ipairs(invalidNumbers) do
                assert.is_false(Theme.isValidNumber(num))
            end
        end)
    end)
end) 