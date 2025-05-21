--[[
    Tokyo Box - Traduções em Português (Brasil)
    Versão: 1.0.0
]]

-- Tabela de traduções
local Translations = {
    errors = {
        command_disabled = 'Comando desativado',
        no_permission = 'Sem permissão para %s',
        invalid_volume = 'Volume inválido. Use um valor entre 0 e 100',
        invalid_repeat_mode = 'Modo inválido. Use: none, one ou all',
        invalid_command = 'Uso: %s',
        player_not_found = 'Jogador não encontrado',
        invalid_url = 'URL inválida',
        api_error = 'Erro na API do YouTube',
        network_error = 'Erro de conexão',
        unknown_error = 'Erro desconhecido',
        invalid_input = 'Entrada inválida',
        invalid_permission = 'Sem permissão',
        invalid_volume_range = 'Volume inválido (0-100)',
        invalid_mode = 'Modo inválido (none/one/all)',
        cache_error = 'Erro no cache'
    },
    success = {
        music_playing = 'Tocando: %s',
        music_paused = 'Música pausada',
        music_resumed = 'Música retomada',
        music_stopped = 'Música parada',
        volume_set = 'Volume ajustado para %s%%',
        volume_muted = 'Volume mutado',
        volume_unmuted = 'Volume desmutado',
        repeat_mode_set = 'Modo de repetição: %s',
        shuffle_enabled = 'Embaralhamento ativado',
        shuffle_disabled = 'Embaralhamento desativado',
        playlist_cleared = 'Playlist limpa',
        track_added = 'Música adicionada: %s',
        track_removed = 'Música removida: %s',
        config_reloaded = 'Configuração recarregada',
        cache_cleared = 'Cache limpo'
    },
    info = {
        commands = {
            main = 'Abrir Tokyo Box',
            play = 'Tocar música',
            pause = 'Pausar música',
            resume = 'Retomar música',
            stop = 'Parar música',
            volume = 'Ajustar volume',
            mute = 'Mutear/Desmutear',
            shuffle = 'Embaralhar playlist',
            repeat_mode = 'Definir modo de repetição'
        },
        ui = {
            title = 'Tokyo Box',
            now_playing = 'Tocando agora',
            playlist = 'Playlist',
            search = 'Pesquisar',
            settings = 'Configurações',
            volume = 'Volume',
            repeat = 'Repetir',
            shuffle = 'Embaralhar',
            no_track = 'Nenhuma música tocando',
            select_track = 'Selecione uma música'
        },
        help = {
            command_usage = 'Uso: %s',
            command_help = 'Ajuda: %s',
            command_permissions = 'Permissões: %s',
            command_volume = 'Volume: %s',
            command_mode = 'Modo: %s',
            command_track = 'Faixa: %s',
            command_playlist = 'Playlist: %s',
            command_cache = 'Cache: %s',
            command_config = 'Config: %s'
        }
    }
}

-- Sistema de tradução
Lang = {
    t = function(key, ...)
        if not key or type(key) ~= 'string' then
            print('^1[Tokyo Box] Chave de tradução inválida^7')
            return key
        end
        
        local keys = {}
        for k in string.gmatch(key, "([^.]+)") do
            table.insert(keys, k)
        end
        
        local value = Translations
        for _, k in ipairs(keys) do
            if not value[k] then
                print('^1[Tokyo Box] Tradução não encontrada: ' .. key .. '^7')
                return key
            end
            value = value[k]
        end
        
        if type(value) == 'string' then
            local args = {...}
            if #args > 0 then
                return string.format(value, table.unpack(args))
            end
            return value
        end
        
        return value
    end,
    
    -- Função para verificar se uma tradução existe
    has = function(key)
        if not key or type(key) ~= 'string' then
            return false
        end
        
        local keys = {}
        for k in string.gmatch(key, "([^.]+)") do
            table.insert(keys, k)
        end
        
        local value = Translations
        for _, k in ipairs(keys) do
            if not value[k] then
                return false
            end
            value = value[k]
        end
        
        return true
    end,
    
    -- Função para obter todas as traduções
    getAll = function()
        return Translations
    end
}

-- Função auxiliar para tradução
function _L(key, ...)
    return Lang.t(key, ...)
end 