local QBCore = exports['qb-core']:GetCoreObject()

-- Comandos
QBCore.Commands.Add('tokyobox_reload', 'Recarregar Tokyo Box', {}, false, function(source)
    -- Verificar permissão
    if not Config.Permissions.admin then
        TriggerClientEvent("tokyo_box:notification", source, {
            type = "error",
            message = "Sem permissão para recarregar"
        })
        return
    end
    
    -- Recarregar recurso
    StopResource(GetCurrentResourceName())
    Wait(1000)
    StartResource(GetCurrentResourceName())
    
    TriggerClientEvent("tokyo_box:notification", source, {
        type = "success",
        message = "Recurso recarregado"
    })
end)

QBCore.Commands.Add('tokyobox_clear', 'Limpar cache do Tokyo Box', {}, false, function(source)
    -- Verificar permissão
    if not Config.Permissions.admin then
        TriggerClientEvent("tokyo_box:notification", source, {
            type = "error",
            message = "Sem permissão para limpar cache"
        })
        return
    end
    
    -- Limpar cache
    requestCache = {}
    requestCount = {}
    lastReset = os.time()
    
    TriggerClientEvent("tokyo_box:notification", source, {
        type = "success",
        message = "Cache limpo"
    })
end)

QBCore.Commands.Add('tokyobox_play', 'Tocar música no Tokyo Box', {
    {name = "id", help = "ID do vídeo"}
}, false, function(source, args)
    -- Verificar permissão
    if not Config.Permissions.play then
        TriggerClientEvent("tokyo_box:notification", source, {
            type = "error",
            message = "Sem permissão para tocar música"
        })
        return
    end
    
    -- Verificar argumentos
    if not args[1] then
        TriggerClientEvent("tokyo_box:notification", source, {
            type = "error",
            message = "ID do vídeo não informado"
        })
        return
    end
    
    -- Tocar música
    TriggerClientEvent("tokyo_box:playTrack", -1, {
        id = args[1]
    })
end)

QBCore.Commands.Add('tokyobox_stop', 'Parar música no Tokyo Box', {}, false, function(source)
    -- Verificar permissão
    if not Config.Permissions.stop then
        TriggerClientEvent("tokyo_box:notification", source, {
            type = "error",
            message = "Sem permissão para parar música"
        })
        return
    end
    
    -- Parar música
    TriggerClientEvent("tokyo_box:stopTrack", -1)
end)

QBCore.Commands.Add('tokyobox_volume', 'Ajustar volume do Tokyo Box', {
    {name = "volume", help = "Volume (0-100)"}
}, false, function(source, args)
    -- Verificar permissão
    if not Config.Permissions.volume then
        TriggerClientEvent("tokyo_box:notification", source, {
            type = "error",
            message = "Sem permissão para ajustar volume"
        })
        return
    end
    
    -- Verificar argumentos
    if not args[1] then
        TriggerClientEvent("tokyo_box:notification", source, {
            type = "error",
            message = "Volume não informado"
        })
        return
    end
    
    -- Converter volume
    local volume = tonumber(args[1])
    if not volume or volume < 0 or volume > 100 then
        TriggerClientEvent("tokyo_box:notification", source, {
            type = "error",
            message = "Volume inválido"
        })
        return
    end
    
    -- Ajustar volume
    TriggerClientEvent("tokyo_box:volumeChanged", -1, volume / 100)
end)

QBCore.Commands.Add('tokyobox_playlist', 'Gerenciar playlists do Tokyo Box', {
    {name = "action", help = "Ação (create, delete, list)"},
    {name = "name", help = "Nome da playlist"}
}, false, function(source, args)
    -- Verificar permissão
    if not Config.Permissions.playlist then
        TriggerClientEvent("tokyo_box:notification", source, {
            type = "error",
            message = "Sem permissão para gerenciar playlists"
        })
        return
    end
    
    -- Verificar argumentos
    if not args[1] then
        TriggerClientEvent("tokyo_box:notification", source, {
            type = "error",
            message = "Ação não informada"
        })
        return
    end
    
    -- Processar ação
    if args[1] == "list" then
        -- Listar playlists
        MySQL.query('SELECT * FROM tokyo_box_playlists', {}, function(results)
            if results then
                local message = "Playlists:\n"
                for _, playlist in ipairs(results) do
                    message = message .. "- " .. playlist.name .. "\n"
                end
                
                TriggerClientEvent("tokyo_box:notification", source, {
                    type = "info",
                    message = message
                })
            end
        end)
    elseif args[1] == "create" then
        -- Verificar nome
        if not args[2] then
            TriggerClientEvent("tokyo_box:notification", source, {
                type = "error",
                message = "Nome da playlist não informado"
            })
            return
        end
        
        -- Criar playlist
        MySQL.insert('INSERT INTO tokyo_box_playlists (name, tracks) VALUES (?, ?)', {
            args[2],
            json.encode({})
        }, function(id)
            if id then
                TriggerClientEvent("tokyo_box:notification", source, {
                    type = "success",
                    message = "Playlist criada"
                })
            end
        end)
    elseif args[1] == "delete" then
        -- Verificar nome
        if not args[2] then
            TriggerClientEvent("tokyo_box:notification", source, {
                type = "error",
                message = "Nome da playlist não informado"
            })
            return
        end
        
        -- Deletar playlist
        MySQL.query('DELETE FROM tokyo_box_playlists WHERE name = ?', {args[2]}, function(affectedRows)
            if affectedRows > 0 then
                TriggerClientEvent("tokyo_box:notification", source, {
                    type = "success",
                    message = "Playlist deletada"
                })
            else
                TriggerClientEvent("tokyo_box:notification", source, {
                    type = "error",
                    message = "Playlist não encontrada"
                })
            end
        end)
    else
        TriggerClientEvent("tokyo_box:notification", source, {
            type = "error",
            message = "Ação inválida"
        })
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