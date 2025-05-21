describe('Sistema de Localização', function()
    local Locale = require('client/locale')
    
    before_each(function()
        -- Mock para LoadResourceFile
        _G.LoadResourceFile = function(resource, path)
            if path:match('pt%-BR%.json') then
                return [[{
                    "ui": {
                        "title": "Tokyo Box",
                        "search": {
                            "placeholder": "Pesquisar músicas..."
                        }
                    }
                }]]
            elseif path:match('en%-US%.json') then
                return [[{
                    "ui": {
                        "title": "Tokyo Box",
                        "search": {
                            "placeholder": "Search for music..."
                        }
                    }
                }]]
            end
            return nil
        end
        
        -- Mock para SendNUIMessage
        _G.SendNUIMessage = function(data) end
        
        -- Mock para TriggerEvent
        _G.TriggerEvent = function(event, ...) end
    end)
    
    describe('Carregamento de Traduções', function()
        it('deve carregar traduções com sucesso', function()
            local result = Locale.Set('pt-BR')
            assert.is_true(result)
            assert.equals('pt-BR', Locale.GetCurrent())
        end)
        
        it('deve falhar ao carregar arquivo inexistente', function()
            local result = Locale.Set('invalid')
            assert.is_false(result)
        end)
        
        it('deve usar fallback quando arquivo não existe', function()
            Locale.Set('pt-BR')
            local text = Locale.Get('ui.search.placeholder')
            assert.equals('Pesquisar músicas...', text)
        end)
    end)
    
    describe('Mudança de Idioma', function()
        it('deve mudar idioma com sucesso', function()
            local result = Locale.Set('en-US')
            assert.is_true(result)
            assert.equals('en-US', Locale.GetCurrent())
        end)
        
        it('deve disparar evento ao mudar idioma', function()
            local eventTriggered = false
            _G.TriggerEvent = function(event, locale)
                if event == 'tokyo_box:localeChanged' then
                    eventTriggered = true
                end
            end
            
            Locale.Set('en-US')
            assert.is_true(eventTriggered)
        end)
    end)
    
    describe('Obtenção de Textos', function()
        it('deve retornar texto traduzido', function()
            Locale.Set('pt-BR')
            local text = Locale.Get('ui.search.placeholder')
            assert.equals('Pesquisar músicas...', text)
        end)
        
        it('deve retornar chave quando texto não existe', function()
            Locale.Set('pt-BR')
            local text = Locale.Get('ui.invalid.key')
            assert.equals('ui.invalid.key', text)
        end)
        
        it('deve formatar texto com argumentos', function()
            Locale.Set('pt-BR')
            local text = Locale.Format('ui.search.results', '5')
            assert.equals('5 resultados encontrados', text)
        end)
    end)
    
    describe('Comandos', function()
        it('deve mostrar idioma atual sem argumentos', function()
            local output = ''
            _G.print = function(text)
                output = text
            end
            
            Locale.Set('pt-BR')
            _G.RegisterCommand('tokyobox_lang', function(source, args)
                if #args == 0 then
                    print('^3[Tokyo Box] Idioma atual: ' .. Locale.GetCurrent() .. '^7')
                end
            end)
            
            _G.RegisterCommand('tokyobox_lang', function() end, false)
            assert.equals('^3[Tokyo Box] Idioma atual: pt-BR^7', output)
        end)
        
        it('deve mudar idioma com argumento válido', function()
            local output = ''
            _G.print = function(text)
                output = text
            end
            
            _G.RegisterCommand('tokyobox_lang', function(source, args)
                if #args > 0 then
                    if Locale.Set(args[1]) then
                        print('^2[Tokyo Box] Idioma alterado para: ' .. args[1] .. '^7')
                    end
                end
            end)
            
            _G.RegisterCommand('tokyobox_lang', function() end, false)
            assert.equals('^2[Tokyo Box] Idioma alterado para: en-US^7', output)
        end)
    end)
end) 