--[[
    Tokyo Box - Traduções em Português (Brasil)
    Versão: 1.0.0
]]

-- Tabela de traduções
local Translations = {
    -- Mensagens de erro
    error = {
        invalid_input = 'Entrada inválida',
        invalid_permission = 'Sem permissão',
        invalid_volume_range = 'Volume deve estar entre %{min} e %{max}',
        invalid_mode = 'Modo inválido',
        cache_error = 'Erro ao acessar cache',
        api_error = 'Erro na API do YouTube',
        network_error = 'Erro de conexão',
        resource_error = 'Erro no recurso',
        database_error = 'Erro no banco de dados'
    },

    -- Mensagens de sucesso
    success = {
        config_reloaded = 'Configuração recarregada',
        cache_cleared = 'Cache limpo',
        playlist_saved = 'Playlist salva',
        playlist_deleted = 'Playlist deletada',
        volume_changed = 'Volume alterado para %{volume}%',
        mode_changed = 'Modo alterado para %{mode}'
    },

    -- Informações
    info = {
        no_track = 'Nenhuma música tocando',
        select_track = 'Selecione uma música',
        loading = 'Carregando...',
        searching = 'Buscando...',
        saving = 'Salvando...',
        deleting = 'Deletando...',
        updating = 'Atualizando...'
    },

    -- Comandos
    commands = {
        help = 'Ajuda do Tokyo Box',
        usage = 'Uso: /%{command} [opção]',
        options = {
            play = 'Tocar música',
            pause = 'Pausar música',
            stop = 'Parar música',
            next = 'Próxima música',
            prev = 'Música anterior',
            volume = 'Ajustar volume',
            playlist = 'Gerenciar playlist',
            search = 'Buscar música',
            help = 'Mostrar ajuda'
        }
    },

    -- UI
    ui = {
        now_playing = 'Tocando agora',
        playlist = 'Playlist',
        search = 'Buscar',
        settings = 'Configurações',
        volume = 'Volume',
        shuffle = 'Aleatório',
        repeat_mode = 'Repetir',
        add_to_playlist = 'Adicionar à playlist',
        remove_from_playlist = 'Remover da playlist',
        clear_playlist = 'Limpar playlist',
        save_playlist = 'Salvar playlist',
        load_playlist = 'Carregar playlist',
        delete_playlist = 'Deletar playlist'
    }
}

-- Sistema de tradução
Lang = {
    t = function(key, ...)
        if type(key) ~= 'string' then
            print("[Tokyo Box] Chave de tradução inválida: " .. tostring(key))
            return 'Chave inválida'
        end

        local args = {...}
        local text = Translations
        
        -- Navegar pela estrutura aninhada
        for k in string.gmatch(key, "([^.]+)") do
            if type(text) == "table" then
                text = text[k]
            else
                print("[Tokyo Box] Tradução faltando: " .. key)
                return 'Tradução não encontrada: ' .. key
            end
        end
        
        if type(text) ~= 'string' then
            print("[Tokyo Box] Tradução inválida para: " .. key)
            return 'Tradução inválida: ' .. key
        end
        
        if #args > 0 then
            return string.format(text, table.unpack(args))
        end
        
        return text
    end,
    
    has = function(key)
        if type(key) ~= 'string' then
            return false
        end

        local text = Translations
        for k in string.gmatch(key, "([^.]+)") do
            if type(text) == "table" then
                text = text[k]
            else
                return false
            end
        end
        return type(text) == 'string'
    end,
    
    getAll = function()
        return Translations
    end
}

-- Função auxiliar para tradução
function _L(key, ...)
    return Lang.t(key, ...)
end 