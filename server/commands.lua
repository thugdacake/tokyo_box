local QBCore = exports['qb-core']:GetCoreObject()

-- Comandos
QBCore.Commands.Add('tokyobox_admin', 'Comandos administrativos do Tokyo Box', {
    { name = 'action', help = 'Ação a ser executada' },
    { name = 'target', help = 'ID do jogador (opcional)' }
}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player.PlayerData.permission == 'admin' then
        TriggerClientEvent('QBCore:Notify', src, 'Você não tem permissão para usar este comando', 'error')
        return
    end
    
    local action = args[1]
    local target = tonumber(args[2])
    
    if action == 'reload' then
        -- Recarregar configuração
        TriggerClientEvent('tokyo_box:reloadConfig', -1)
        TriggerClientEvent('QBCore:Notify', src, 'Configuração recarregada', 'success')
        
    elseif action == 'clear' then
        -- Limpar cache
        exports['tokyo_box']:ClearCache()
        TriggerClientEvent('QBCore:Notify', src, 'Cache limpo', 'success')
        
    elseif action == 'stop' then
        -- Parar reprodução
        if target then
            TriggerClientEvent('tokyo_box:stop', target)
            TriggerClientEvent('QBCore:Notify', src, 'Reprodução parada para o jogador ' .. target, 'success')
        else
            TriggerClientEvent('tokyo_box:stop', -1)
            TriggerClientEvent('QBCore:Notify', src, 'Reprodução parada para todos', 'success')
        end
        
    elseif action == 'volume' then
        -- Ajustar volume
        if not target then
            TriggerClientEvent('QBCore:Notify', src, 'ID do jogador não especificado', 'error')
            return
        end
        
        local volume = tonumber(args[3])
        if not volume or volume < 0 or volume > 100 then
            TriggerClientEvent('QBCore:Notify', src, 'Volume inválido', 'error')
            return
        end
        
        TriggerClientEvent('tokyo_box:setVolume', target, volume)
        TriggerClientEvent('QBCore:Notify', src, 'Volume ajustado para ' .. volume, 'success')
        
    elseif action == 'mute' then
        -- Mutar/desmutar
        if not target then
            TriggerClientEvent('QBCore:Notify', src, 'ID do jogador não especificado', 'error')
            return
        end
        
        local mute = args[3] == 'true'
        TriggerClientEvent('tokyo_box:mute', target, mute)
        TriggerClientEvent('QBCore:Notify', src, mute and 'Jogador mutado' or 'Jogador desmutado', 'success')
        
    else
        TriggerClientEvent('QBCore:Notify', src, 'Ação inválida', 'error')
    end
end)

-- Comandos de permissão
QBCore.Commands.Add('tokyobox_permission', 'Gerenciar permissões do Tokyo Box', {
    { name = 'action', help = 'add/remove' },
    { name = 'target', help = 'ID do jogador' },
    { name = 'permission', help = 'Nome da permissão' }
}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player.PlayerData.permission == 'admin' then
        TriggerClientEvent('QBCore:Notify', src, 'Você não tem permissão para usar este comando', 'error')
        return
    end
    
    local action = args[1]
    local target = tonumber(args[2])
    local permission = args[3]
    
    if not target or not permission then
        TriggerClientEvent('QBCore:Notify', src, 'Uso: /tokyobox_permission [add/remove] [ID] [permissão]', 'error')
        return
    end
    
    local TargetPlayer = QBCore.Functions.GetPlayer(target)
    if not TargetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Jogador não encontrado', 'error')
        return
    end
    
    if action == 'add' then
        -- Adicionar permissão
        if not Config.Permissions[permission] then
            TriggerClientEvent('QBCore:Notify', src, 'Permissão inválida', 'error')
            return
        end
        
        Config.Permissions[permission] = true
        TriggerClientEvent('QBCore:Notify', src, 'Permissão adicionada', 'success')
        
    elseif action == 'remove' then
        -- Remover permissão
        if not Config.Permissions[permission] then
            TriggerClientEvent('QBCore:Notify', src, 'Permissão inválida', 'error')
            return
        end
        
        Config.Permissions[permission] = false
        TriggerClientEvent('QBCore:Notify', src, 'Permissão removida', 'success')
        
    else
        TriggerClientEvent('QBCore:Notify', src, 'Ação inválida', 'error')
    end
end)

-- Comandos de configuração
QBCore.Commands.Add('tokyobox_config', 'Configurar Tokyo Box', {
    { name = 'option', help = 'Opção a ser configurada' },
    { name = 'value', help = 'Novo valor' }
}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player.PlayerData.permission == 'admin' then
        TriggerClientEvent('QBCore:Notify', src, 'Você não tem permissão para usar este comando', 'error')
        return
    end
    
    local option = args[1]
    local value = args[2]
    
    if not option or not value then
        TriggerClientEvent('QBCore:Notify', src, 'Uso: /tokyobox_config [opção] [valor]', 'error')
        return
    end
    
    if option == 'maxDistance' then
        -- Configurar distância máxima
        local distance = tonumber(value)
        if not distance or distance < 0 then
            TriggerClientEvent('QBCore:Notify', src, 'Distância inválida', 'error')
            return
        end
        
        Config.Player.maxDistance = distance
        TriggerClientEvent('QBCore:Notify', src, 'Distância máxima configurada', 'success')
        
    elseif option == 'defaultVolume' then
        -- Configurar volume padrão
        local volume = tonumber(value)
        if not volume or volume < 0 or volume > 100 then
            TriggerClientEvent('QBCore:Notify', src, 'Volume inválido', 'error')
            return
        end
        
        Config.Player.defaultVolume = volume
        TriggerClientEvent('QBCore:Notify', src, 'Volume padrão configurado', 'success')
        
    elseif option == 'fadeTime' then
        -- Configurar tempo de fade
        local time = tonumber(value)
        if not time or time < 0 then
            TriggerClientEvent('QBCore:Notify', src, 'Tempo inválido', 'error')
            return
        end
        
        Config.Player.fadeTime = time
        TriggerClientEvent('QBCore:Notify', src, 'Tempo de fade configurado', 'success')
        
    else
        TriggerClientEvent('QBCore:Notify', src, 'Opção inválida', 'error')
    end
end) 