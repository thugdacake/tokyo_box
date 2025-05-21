// Tokyo Box - NUI Configuration
const RESOURCE_NAME = 'tokyo_box';
const DEFAULT_VOLUME = 50;

const DEFAULT_STATE = {
    visible: false,
    volume: DEFAULT_VOLUME,
    isPlaying: false,
    currentTrack: null,
    playlist: [],
    repeatMode: 'none',
    shuffle: false
};

let state = { ...DEFAULT_STATE };
let elements = {};

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

// Carrega elementos da UI
function loadUIElements() {
    elements = {
        container: document.querySelector('.phone-container'),
        playPauseBtn: document.querySelector('.play-pause'),
        prevBtn: document.querySelector('.prev'),
        nextBtn: document.querySelector('.next'),
        shuffleBtn: document.querySelector('.shuffle'),
        repeatBtn: document.querySelector('.repeat'),
        volumeSlider: document.querySelector('.volume-slider'),
        trackTitle: document.querySelector('.track-title'),
        trackArtist: document.querySelector('.track-artist'),
        playlist: document.querySelector('.playlist')
    };

    // Verifica se todos os elementos necessários existem
    const requiredElements = Object.values(elements);
    const missingElements = requiredElements.filter(el => !el);
    
    if (missingElements.length > 0) {
        throw new Error('Elementos da UI não encontrados');
    }
}

// Função para fazer chamadas à API
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
        console.error('Erro na chamada à API:', error);
        throw error;
    }
}

// Inicializa os elementos e eventos
function initializeElements() {
    // Controles de música
    elements.playPauseBtn.addEventListener('click', async () => {
        try {
            const response = await fetchAPI('togglePlayback');
            updateUIState(response);
        } catch (error) {
            console.error('Erro ao alternar reprodução:', error);
        }
    });

    elements.prevBtn.addEventListener('click', async () => {
        try {
            const response = await fetchAPI('previousTrack');
            updateUIState(response);
        } catch (error) {
            console.error('Erro ao voltar faixa:', error);
        }
    });

    elements.nextBtn.addEventListener('click', async () => {
        try {
            const response = await fetchAPI('nextTrack');
            updateUIState(response);
        } catch (error) {
            console.error('Erro ao avançar faixa:', error);
        }
    });

    elements.shuffleBtn.addEventListener('click', async () => {
        try {
            const response = await fetchAPI('toggleShuffle');
            updateUIState(response);
        } catch (error) {
            console.error('Erro ao alternar aleatório:', error);
        }
    });

    elements.repeatBtn.addEventListener('click', async () => {
        try {
            const response = await fetchAPI('toggleRepeat');
            updateUIState(response);
        } catch (error) {
            console.error('Erro ao alternar repetição:', error);
        }
    });

    // Controle de volume
    elements.volumeSlider.addEventListener('input', async (e) => {
        const volume = parseInt(e.target.value);
        try {
            const response = await fetchAPI('setVolume', { volume });
            updateUIState(response);
        } catch (error) {
            console.error('Erro ao ajustar volume:', error);
        }
    });
}

// Atualiza o estado da UI
function updateUIState(newState) {
    state = { ...state, ...newState };

    // Atualiza visibilidade
    elements.container.classList.toggle('visible', state.visible);

    // Atualiza informações da faixa
    if (state.currentTrack) {
        elements.trackTitle.textContent = state.currentTrack.title;
        elements.trackArtist.textContent = state.currentTrack.artist;
    }

    // Atualiza controles
    elements.playPauseBtn.textContent = state.isPlaying ? '⏸' : '▶';
    elements.shuffleBtn.classList.toggle('active', state.shuffle);
    elements.repeatBtn.classList.toggle('active', state.repeatMode !== 'none');

    // Atualiza volume
    elements.volumeSlider.value = state.volume;

    // Atualiza playlist
    updatePlaylist(state.playlist);
}

// Atualiza a playlist
function updatePlaylist(playlist) {
    elements.playlist.innerHTML = '';
    
    playlist.forEach((track, index) => {
        const item = document.createElement('div');
        item.className = 'playlist-item';
        item.innerHTML = `
            <img src="${track.thumbnail}" alt="${track.title}">
            <div class="playlist-item-info">
                <div class="playlist-item-title">${track.title}</div>
                <div class="playlist-item-artist">${track.artist}</div>
            </div>
        `;
        
        item.addEventListener('click', async () => {
            try {
                const response = await fetchAPI('playTrack', { index });
                updateUIState(response);
            } catch (error) {
                console.error('Erro ao tocar faixa:', error);
            }
        });

        elements.playlist.appendChild(item);
    });
}

// Mostra a UI
function showUI() {
    state.visible = true;
    elements.container.classList.add('visible');
}

// Esconde a UI
function hideUI() {
    state.visible = false;
    elements.container.classList.remove('visible');
}

// Inicializa a aplicação
function initialize() {
    try {
        loadUIElements();
        initializeElements();
        console.log('Tokyo Box UI inicializada com sucesso');
    } catch (error) {
        console.error('Erro ao inicializar UI:', error);
    }
}

// Listener para mensagens do NUI
window.addEventListener('message', (event) => {
    const data = event.data;

    switch (data.type) {
        case 'show':
            showUI();
            break;
        case 'hide':
            hideUI();
            break;
        case 'updateState':
            updateUIState(data.state);
            break;
        case 'updateTrack':
            if (data.track) {
                state.currentTrack = data.track;
                elements.trackTitle.textContent = data.track.title;
                elements.trackArtist.textContent = data.track.artist;
            }
            break;
    }
});

// Inicializa quando o DOM estiver pronto
document.addEventListener('DOMContentLoaded', initialize); 