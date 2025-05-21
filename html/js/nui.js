// Tokyo Box - NUI Configuration
const state = {
    // Estado da NUI
    isVisible: false,
    isMinimized: false,
    currentScale: 1.0,
    currentLocale: 'pt-BR',
    currentTheme: 'dark',
    translations: {},
    isAnimating: false,
    currentVolume: 50,
    isMuted: false,
    isPlaying: false,
    isShuffled: false,
    repeatMode: 'none', // none, one, all
    searchResults: [],
    playlist: [],
    currentTrack: null
};

// Cache de elementos
const elements = {};

// Constantes
const RESOURCE_NAME = 'tokyo-box';
const DEFAULT_LOCALE = 'pt-BR';
const DEFAULT_VOLUME = 50;
const DEFAULT_STATE = {
    isPlaying: false,
    volume: DEFAULT_VOLUME,
    isShuffled: false,
    repeatMode: 'none',
    currentTrack: null
};

// Sistema de traduções
const translations = {
    'pt-BR': {
        errors: {
            command_disabled: 'Comando desativado',
            no_permission: 'Sem permissão para %s',
            invalid_volume: 'Volume inválido. Use um valor entre 0 e 100',
            invalid_repeat_mode: 'Modo inválido. Use: none, one ou all',
            invalid_command: 'Uso: %s',
            player_not_found: 'Jogador não encontrado',
            invalid_url: 'URL inválida',
            api_error: 'Erro na API do YouTube',
            network_error: 'Erro de conexão',
            unknown_error: 'Erro desconhecido'
        },
        success: {
            music_playing: 'Tocando: %s',
            music_paused: 'Música pausada',
            music_resumed: 'Música retomada',
            music_stopped: 'Música parada',
            volume_set: 'Volume ajustado para %s%%',
            volume_muted: 'Volume mutado',
            volume_unmuted: 'Volume desmutado',
            repeat_mode_set: 'Modo de repetição: %s',
            shuffle_enabled: 'Embaralhamento ativado',
            shuffle_disabled: 'Embaralhamento desativado',
            playlist_cleared: 'Playlist limpa',
            track_added: 'Música adicionada: %s',
            track_removed: 'Música removida: %s'
        },
        ui: {
            title: 'Tokyo Box',
            now_playing: 'Tocando agora',
            playlist: 'Playlist',
            search: 'Pesquisar',
            settings: 'Configurações',
            volume: 'Volume',
            repeat: 'Repetir',
            shuffle: 'Embaralhar',
            no_track: 'Nenhuma música tocando',
            select_track: 'Selecione uma música'
        }
    }
};

// Função para carregar elementos da UI
function loadUIElements() {
    console.log('[Tokyo Box] Carregando elementos da UI...');
    
    // Elementos principais
    elements.phoneContainer = document.querySelector('.phone-container');
    elements.albumCover = document.getElementById('current-cover');
    elements.trackTitle = document.getElementById('track-title');
    elements.trackArtist = document.getElementById('track-artist');
    elements.playlist = document.getElementById('playlist');
    
    // Botões de controle
    elements.playBtn = document.getElementById('play-btn');
    elements.prevBtn = document.getElementById('prev-btn');
    elements.nextBtn = document.getElementById('next-btn');
    elements.shuffleBtn = document.getElementById('shuffle-btn');
    elements.repeatBtn = document.getElementById('repeat-btn');
    elements.settingsBtn = document.getElementById('settings-btn');
    
    // Controle de volume
    elements.volumeSlider = document.getElementById('volume-slider');
    
    // Verificar elementos obrigatórios
    const requiredElements = [
        'phone-container',
        'current-cover',
        'track-title',
        'track-artist',
        'playlist',
        'play-btn',
        'prev-btn',
        'next-btn',
        'shuffle-btn',
        'repeat-btn',
        'settings-btn',
        'volume-slider'
    ];
    
    const missingElements = requiredElements.filter(id => !document.getElementById(id));
    
    if (missingElements.length > 0) {
        throw new Error(`Elementos da UI não encontrados: ${missingElements.join(', ')}`);
    }
    
    console.log('[Tokyo Box] Elementos da UI carregados com sucesso');
}

// Carregar traduções
async function loadTranslations(locale = 'pt-BR') {
    try {
        const response = await fetch(`locales/${locale}.json`);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        const translations = await response.json();
        window.translations = translations;
        console.log('[Tokyo Box] Traduções carregadas com sucesso');
        return true;
    } catch (error) {
        console.error('[Tokyo Box] Erro ao carregar traduções:', error);
        // Usar traduções padrão em caso de erro
        window.translations = {
            error: {
                invalid_input: 'Entrada inválida',
                invalid_permission: 'Sem permissão',
                invalid_volume: 'Volume inválido (0-100)',
                invalid_mode: 'Modo inválido (none/one/all)',
                api_error: 'Erro na API do YouTube',
                network_error: 'Erro de rede',
                cache_error: 'Erro no cache'
            },
            success: {
                config_reloaded: 'Configuração recarregada',
                cache_cleared: 'Cache limpo',
                volume_set: 'Volume ajustado para %s',
                track_played: 'Tocando: %s',
                track_paused: 'Música pausada',
                track_resumed: 'Música retomada',
                track_stopped: 'Música parada',
                track_shuffled: 'Playlist embaralhada',
                track_repeated: 'Modo de repetição: %s',
                track_muted: 'Música mutada',
                track_unmuted: 'Música desmutada'
            },
            info: {
                command_usage: 'Uso: %s',
                command_help: 'Ajuda: %s',
                command_permissions: 'Permissões: %s',
                command_volume: 'Volume: %s',
                command_mode: 'Modo: %s',
                command_track: 'Faixa: %s',
                command_playlist: 'Playlist: %s',
                command_cache: 'Cache: %s',
                command_config: 'Config: %s'
            }
        };
        console.warn('[Tokyo Box] Usando traduções padrão');
        return false;
    }
}

// Função para traduzir texto
function translate(key, ...args) {
    const keys = key.split('.');
    let value = translations['pt-BR'];
    
    for (const k of keys) {
        if (!value[k]) {
            console.warn(`[Tokyo Box] Tradução não encontrada: ${key}`);
            return key;
        }
        value = value[k];
    }
    
    if (typeof value === 'string') {
        return args.length > 0 ? value.replace(/%s/g, () => args.shift()) : value;
    }
    
    return value;
}

// Função para fazer requisições à API
async function fetchAPI(endpoint, data = {}) {
    try {
        const response = await fetch(`https://${RESOURCE_NAME}/${endpoint}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        });
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        return await response.json();
    } catch (error) {
        console.error('[Tokyo Box] Erro na requisição:', error);
        throw error;
    }
}

// Função para inicializar elementos
function initializeElements() {
    console.log('[Tokyo Box] Inicializando elementos...');
    
    // Botões de controle
    elements.playBtn.addEventListener('click', () => {
        fetchAPI('playPause');
    });
    
    elements.prevBtn.addEventListener('click', () => {
        fetchAPI('prevTrack');
    });
    
    elements.nextBtn.addEventListener('click', () => {
        fetchAPI('nextTrack');
    });
    
    // Controle de volume
    let volumeTimeout;
    elements.volumeSlider.addEventListener('input', (e) => {
        const volume = parseInt(e.target.value);
        
        clearTimeout(volumeTimeout);
        volumeTimeout = setTimeout(() => {
            fetchAPI('setVolume', { volume });
        }, 100);
    });
    
    // Botões de playlist
    elements.shuffleBtn.addEventListener('click', () => {
        fetchAPI('toggleShuffle');
    });
    
    elements.repeatBtn.addEventListener('click', () => {
        fetchAPI('toggleRepeat');
    });
    
    console.log('[Tokyo Box] Elementos inicializados com sucesso');
}

// Função para atualizar o estado da UI
function updateUIState(newState) {
    if (!newState) return;
    
    // Atualizar informações da música
    if (newState.currentTrack) {
        elements.trackTitle.textContent = newState.currentTrack.title;
        elements.trackArtist.textContent = newState.currentTrack.artist;
        elements.albumCover.src = newState.currentTrack.cover || 'img/default-cover.png';
    }
    
    // Atualizar botão de play/pause
    elements.playBtn.textContent = newState.isPlaying ? '⏸' : '▶';
    
    // Atualizar controle de volume
    elements.volumeSlider.value = newState.volume || DEFAULT_VOLUME;
    
    // Atualizar botões de shuffle e repeat
    elements.shuffleBtn.style.color = newState.isShuffled ? 'var(--primary-color)' : 'var(--text-color)';
    elements.repeatBtn.textContent = newState.repeatMode === 'one' ? '🔂' : '🔁';
    elements.repeatBtn.style.color = newState.repeatMode !== 'none' ? 'var(--primary-color)' : 'var(--text-color)';
    
    // Atualizar estado
    Object.assign(state, newState);
}

// Função para mostrar a UI
function showUI() {
    if (state.isVisible) return;
    
    console.log('[Tokyo Box] Mostrando UI...');
    state.isVisible = true;
    elements.phoneContainer.style.display = 'block';
    elements.phoneContainer.classList.add('fade-in');
}

// Função para esconder a UI
function hideUI() {
    if (!state.isVisible) return;
    
    console.log('[Tokyo Box] Escondendo UI...');
    state.isVisible = false;
    elements.phoneContainer.style.display = 'none';
    elements.phoneContainer.classList.remove('fade-in');
}

// Função para atualizar o estado
function updateState(newState) {
    if (!newState) {
        console.warn('[Tokyo Box] Estado inválido recebido');
        return;
    }
    
    console.log('[Tokyo Box] Atualizando estado:', JSON.stringify(newState, null, 2));
    Object.assign(state, newState);
    
    const layout = elements['app-layout'];
    if (layout) {
        if (state.isMinimized) {
            layout.classList.add('minimized');
        } else {
            layout.classList.remove('minimized');
        }
        
        // Atualizar tema
        if (state.currentTheme) {
            document.documentElement.setAttribute('data-theme', state.currentTheme);
        }
        
        // Atualizar escala
        if (state.currentScale) {
            layout.style.transform = `scale(${state.currentScale})`;
        }
        
        console.log('[Tokyo Box] Estado atualizado com sucesso');
    } else {
        console.error('[Tokyo Box] Elemento app-layout não encontrado');
    }
}

// Função para inicializar a aplicação
async function initialize() {
    console.log('[Tokyo Box] Iniciando...');
    
    try {
        await loadTranslations();
        await loadUIElements();
        initializeElements();
        console.log('[Tokyo Box] Inicializado com sucesso');
    } catch (error) {
        console.error('[Tokyo Box] Erro na inicialização:', error);
    }
}

// Inicializar quando o DOM estiver pronto
document.addEventListener('DOMContentLoaded', initialize);

// Listener para mensagens do NUI
window.addEventListener('message', (event) => {
    try {
        const data = event.data;
        console.log('[Tokyo Box] Mensagem recebida:', JSON.stringify(data, null, 2));
        
        if (!data || typeof data !== 'object') {
            console.error('[Tokyo Box] Mensagem inválida recebida');
            return;
        }
        
        const { type, state: newState } = data;
        
        if (!type) {
            console.warn('[Tokyo Box] Tipo de mensagem não especificado');
            return;
        }
        
        switch (type) {
            case 'show':
                showUI();
                if (newState) {
                    state.currentLocale = newState.locale || DEFAULT_LOCALE;
                    state.currentTheme = newState.theme || 'dark';
                    state.currentScale = newState.scale || 1.0;
                    updateState(newState);
                }
                break;
                
            case 'hide':
                hideUI();
                break;
                
            case 'updateState':
                if (newState) updateState(newState);
                break;
                
            case 'updateResults':
                if (data.results) {
                    updateSearchResults(data.results);
                }
                break;
                
            case 'updateTrack':
                if (data.track) {
                    updateCurrentTrack(data.track);
                }
                break;
                
            default:
                console.warn('[Tokyo Box] Tipo de mensagem desconhecido:', type);
        }
    } catch (error) {
        console.error('[Tokyo Box] Erro ao processar mensagem:', error);
    }
}); 