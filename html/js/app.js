// Estado da aplicação
const state = {
  isInitialized: false,
  isPlaying: false,
  currentTrack: null,
  volume: 50,
  range: 10,
  source: "speaker",
  bluetooth: {
    enabled: false,
    connected: false,
  },
  playback: {
    repeat: "none", // none, one, all
    shuffle: false,
  },
  playlists: [],
  favorites: [],
  searchResults: [],
  error: null,
  loading: {
    search: false,
    playlists: false,
    favorites: false,
    player: false,
  },
  uiSettings: {
    scale: 1.0,
    isExpanded: false,
  },
}

// Elementos da interface
const elements = {
  app: document.getElementById("app"),
  views: {
    search: document.getElementById("search"),
    playlists: document.getElementById("playlists"),
    favorites: document.getElementById("favorites"),
    settings: document.getElementById("settings"),
  },
  search: {
    input: document.getElementById("search-input"),
    button: document.getElementById("search-button"),
    results: document.getElementById("search-results"),
    status: document.getElementById("search-status"),
  },
  playlists: {
    list: document.getElementById("playlists-list"),
    createButton: document.getElementById("create-playlist"),
    status: document.getElementById("playlists-status"),
  },
  favorites: {
    list: document.getElementById("favorites-list"),
    status: document.getElementById("favorites-status"),
  },
  player: {
    cover: document.getElementById("track-cover"),
    title: document.getElementById("track-title"),
    artist: document.getElementById("track-artist"),
    play: document.getElementById("play"),
    prev: document.getElementById("prev"),
    next: document.getElementById("next"),
    volume: document.getElementById("volume"),
    mute: document.getElementById("mute"),
    repeat: document.getElementById("repeat"),
    shuffle: document.getElementById("shuffle"),
  },
  modals: {
    createPlaylist: document.getElementById("create-playlist-modal"),
    addToPlaylist: document.getElementById("add-to-playlist-modal"),
  },
  notifications: document.getElementById("notifications"),
  settings: {
    scaleValue: document.getElementById("scale-value"),
    scaleSlider: document.getElementById("scale-slider"),
    expandToggle: document.getElementById("expand-toggle"),
  },
}

// Funções de utilidade
const utils = {
  // Formatar duração
  formatDuration(duration) {
    if (!duration) return "0:00"

    // Converter formato ISO 8601 para segundos
    if (typeof duration === "string" && duration.includes("PT")) {
      let seconds = 0
      const hours = duration.match(/(\d+)H/)
      const minutes = duration.match(/(\d+)M/)
      const secs = duration.match(/(\d+)S/)

      if (hours) seconds += Number.parseInt(hours[1]) * 3600
      if (minutes) seconds += Number.parseInt(minutes[1]) * 60
      if (secs) seconds += Number.parseInt(secs[1])

      duration = seconds
    }

    const minutes = Math.floor(duration / 60)
    const remainingSeconds = Math.floor(duration % 60)
    return `${minutes}:${remainingSeconds.toString().padStart(2, "0")}`
  },

  // Formatar número
  formatNumber(number) {
    if (!number) return "0"

    number = Number.parseInt(number)
    if (isNaN(number)) return "0"

    if (number >= 1000000) {
      return `${(number / 1000000).toFixed(1)}M`
    }
    if (number >= 1000) {
      return `${(number / 1000).toFixed(1)}K`
    }
    return number.toString()
  },

  // Debounce
  debounce(func, wait) {
    let timeout
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout)
        func(...args)
      }
      clearTimeout(timeout)
      timeout = setTimeout(later, wait)
    }
  },

  // Throttle
  throttle(func, limit) {
    let inThrottle
    return function executedFunction(...args) {
      if (!inThrottle) {
        func(...args)
        inThrottle = true
        setTimeout(() => (inThrottle = false), limit)
      }
    }
  },

  // Sanitizar HTML
  sanitizeHTML(text) {
    if (!text) return ""

    // Converter para string se não for
    if (typeof text !== "string") {
      text = String(text)
    }

    const map = {
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;",
      '"': "&quot;",
      "'": "&#039;",
    }

    return text.replace(/[&<>"']/g, (m) => map[m])
  },

  // Gerar ID único
  generateId() {
    return Date.now().toString(36) + Math.random().toString(36).substr(2)
  },
}

// Variável para obter o nome do recurso pai
const GetParentResourceName = () => {
  if (typeof window !== "undefined" && window.invokeNative) {
    return window.invokeNative("__cfx_getresourcename")
  } else {
    return "nui"
  }
}

// Funções de comunicação com o cliente
const client = {
  // Enviar mensagem para o cliente com retry
  async sendMessage(type, data = {}, retries = 3) {
    const resourceName = GetParentResourceName();
    const url = `https://${resourceName}/${type}`;
    
    for (let i = 0; i < retries; i++) {
      try {
        const response = await fetch(url, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(data),
        });
        
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        return true;
      } catch (error) {
        console.error(`Tentativa ${i + 1} falhou:`, error);
        
        if (i === retries - 1) {
          console.error("Todas as tentativas falharam");
          ui.showNotification("Erro de comunicação com o servidor", "error");
          return false;
        }
        
        // Esperar antes da próxima tentativa
        await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
      }
    }
  },

  // Buscar músicas com retry
  async searchVideos(query) {
    if (!query || typeof query !== "string" || query.trim() === "") {
      ui.showNotification("Digite um termo de busca válido", "error");
      return;
    }

    // Atualizar estado
    state.loading.search = true;
    ui.updateLoadingState("search", true);

    const success = await this.sendMessage("searchVideo", { query: query.trim() });
    
    if (!success) {
      state.loading.search = false;
      ui.updateLoadingState("search", false);
    }
  },

  // Reproduzir música com retry
  async playVideo(videoId) {
    if (!videoId) return;

    // Atualizar estado
    state.loading.player = true;

    const success = await this.sendMessage("playVideo", { videoId });
    
    if (!success) {
      state.loading.player = false;
    }
  },

  // Parar música
  async stopVideo() {
    await this.sendMessage("stopVideo");
  },

  // Ajustar volume
  async setVolume(volume) {
    volume = Math.max(0, Math.min(100, volume));
    await this.sendMessage("setVolume", { volume });
  },

  // Atualizar configurações da UI
  async updateUISettings(settings) {
    if (!settings) return;

    // Atualizar estado
    if (settings.scale !== undefined) {
      state.uiSettings.scale = settings.scale;
    }

    if (settings.isExpanded !== undefined) {
      state.uiSettings.isExpanded = settings.isExpanded;
    }

    await this.sendMessage("updateUISettings", settings);
  },

  // Criar playlist
  async createPlaylist(data) {
    if (!data || !data.name) {
      ui.showNotification("Nome da playlist inválido", "error");
      return;
    }

    const success = await this.sendMessage("createPlaylist", data);
    
    if (!success) {
      ui.showNotification("Erro ao criar playlist", "error");
    }
  },

  // Excluir playlist
  async deletePlaylist(playlistId) {
    if (!playlistId) return;

    const success = await this.sendMessage("deletePlaylist", { playlistId });
    
    if (!success) {
      ui.showNotification("Erro ao excluir playlist", "error");
    }
  },

  // Adicionar música à playlist
  async addTrackToPlaylist(data) {
    if (!data || !data.playlistId || !data.videoId) {
      ui.showNotification("Dados inválidos", "error");
      return;
    }

    const success = await this.sendMessage("addTrackToPlaylist", data);
    
    if (!success) {
      ui.showNotification("Erro ao adicionar música", "error");
    }
  },

  // Remover música da playlist
  async removeTrackFromPlaylist(data) {
    if (!data || !data.playlistId || !data.trackId) {
      ui.showNotification("Dados inválidos", "error");
      return;
    }

    const success = await this.sendMessage("removeTrackFromPlaylist", data);
    
    if (!success) {
      ui.showNotification("Erro ao remover música", "error");
    }
  },

  // Adicionar aos favoritos
  async addFavorite(videoId) {
    if (!videoId) return;

    const success = await this.sendMessage("addFavorite", { videoId });
    
    if (!success) {
      ui.showNotification("Erro ao adicionar aos favoritos", "error");
    }
  },

  // Remover dos favoritos
  async removeFavorite(favoriteId) {
    if (!favoriteId) return;

    const success = await this.sendMessage("removeFavorite", { favoriteId });
    
    if (!success) {
      ui.showNotification("Erro ao remover dos favoritos", "error");
    }
  },

  // Buscar favoritos
  async getFavorites() {
    state.loading.favorites = true;
    ui.updateLoadingState("favorites", true);

    const success = await this.sendMessage("getFavorites");
    
    if (!success) {
      state.loading.favorites = false;
      ui.updateLoadingState("favorites", false);
      ui.showNotification("Erro ao buscar favoritos", "error");
    }
  }
};

// Validar entrada
function validateInput(input, type) {
  if (!input) return false

  switch (type) {
    case "search":
      return typeof input === "string" && input.trim().length >= 2 && input.trim().length <= 100
    case "playlistName":
      return typeof input === "string" && input.trim().length >= 3 && input.trim().length <= 50
    case "url":
      try {
        new URL(input)
        return true
      } catch (e) {
        return false
      }
    case "videoId":
      return typeof input === "string" && /^[a-zA-Z0-9_-]{11}$/.test(input)
    case "playlistId":
      return typeof input === "number" || (typeof input === "string" && /^\d+$/.test(input))
    case "scale":
      return typeof input === "number" && input >= 0.7 && input <= 1.3
    default:
      return false
  }
}

// Aplicar validação antes de enviar para o servidor
client.searchVideos = function (query) {
  if (!validateInput(query, "search")) {
    ui.showNotification("Digite um termo de busca válido (2-100 caracteres)", "error")
    return
  }

  // Atualizar estado
  state.loading.search = true
  ui.updateLoadingState("search", true)

  this.sendMessage("searchVideo", { query: query.trim() })
}

client.updateUISettings = function (settings) {
  if (settings.scale !== undefined && !validateInput(settings.scale, "scale")) {
    ui.showNotification("Escala inválida (0.7-1.3)", "error")
    return
  }

  // Atualizar estado
  if (settings.scale !== undefined) {
    state.uiSettings.scale = settings.scale
  }

  if (settings.isExpanded !== undefined) {
    state.uiSettings.isExpanded = settings.isExpanded
  }

  // Enviar para o cliente
  this.sendMessage("updateUISettings", settings)

  // Atualizar interface
  ui.applyUISettings()
}

// Funções de interface
const ui = {
  // Mostrar notificação
  showNotification(message, level = "info") {
    if (!message) return

    const id = utils.generateId()
    const html = `
            <div class="notification ${level}" id="notification-${id}">
                <div class="notification-message">${utils.sanitizeHTML(message)}</div>
                <button class="notification-close" aria-label="Fechar notificação">
                    <img src="img/close.svg" alt="">
                </button>
            </div>
        `

    elements.notifications.insertAdjacentHTML("beforeend", html)

    // Adicionar evento de fechar
    const notification = document.getElementById(`notification-${id}`)
    const closeButton = notification.querySelector(".notification-close")

    closeButton.addEventListener("click", () => {
      notification.remove()
    })

    // Auto-remover após 5 segundos
    setTimeout(() => {
      if (notification && notification.parentNode) {
        notification.remove()
      }
    }, 5000)
  },

  // Atualizar estado de carregamento
  updateLoadingState(section, isLoading) {
    if (!elements[section] || !elements[section].status) return

    elements[section].status.style.display = isLoading ? "flex" : "none"

    if (section === "search" && elements.search.results) {
      elements.search.results.style.display = isLoading ? "none" : "grid"
    }
  },

  // Aplicar configurações da UI
  applyUISettings() {
    // Aplicar escala
    document.documentElement.style.setProperty("--ui-scale", state.uiSettings.scale)

    // Aplicar modo expandido
    const app = document.getElementById("app")
    if (app) {
      if (state.uiSettings.isExpanded) {
        app.classList.add("expanded")
      } else {
        app.classList.remove("expanded")
      }
    }

    // Atualizar controles de configuração
    if (elements.settings.scaleValue) {
      elements.settings.scaleValue.textContent = `${Math.round(state.uiSettings.scale * 100)}%`
    }

    if (elements.settings.scaleSlider) {
      elements.settings.scaleSlider.value = state.uiSettings.scale
    }

    if (elements.settings.expandToggle) {
      elements.settings.expandToggle.checked = state.uiSettings.isExpanded
    }
  },

  // Renderizar resultados da busca
  renderSearchResults(results) {
    if (!results || !Array.isArray(results)) {
      elements.search.results.innerHTML = '<div class="no-results">Nenhum resultado encontrado</div>'
      return
    }

    if (results.length === 0) {
      elements.search.results.innerHTML = '<div class="no-results">Nenhum resultado encontrado</div>'
      return
    }

    elements.search.results.innerHTML = results
      .map(
        (track) => `
            <div class="track-card" data-video-id="${utils.sanitizeHTML(track.videoId)}">
                <img src="${utils.sanitizeHTML(track.thumbnailUrl)}" alt="${utils.sanitizeHTML(track.title)}">
                <div class="track-info">
                    <h3>${utils.sanitizeHTML(track.title)}</h3>
                    <p>${utils.sanitizeHTML(track.channelTitle)}</p>
                </div>
                <div class="track-actions">
                    <button class="btn-icon" data-action="play" aria-label="Reproduzir">
                        <img src="img/play.svg" alt="">
                    </button>
                    <button class="btn-icon" data-action="add" aria-label="Adicionar à playlist">
                        <img src="img/add.svg" alt="">
                    </button>
                    <button class="btn-icon" data-action="favorite" aria-label="Adicionar aos favoritos">
                        <img src="img/favorite.svg" alt="">
                    </button>
                </div>
            </div>
        `,
      )
      .join("")
  },
}

// Add proper scroll handling to the app.js file

// Add this function to handle mouse wheel events
function handleMouseWheel() {
  // Get all scrollable containers
  const scrollableContainers = [
    document.querySelector("#search.tab-view"),
    document.querySelector("#playlists.tab-view"),
    document.querySelector("#favorites.tab-view"),
    document.querySelector("#settings.tab-view"),
  ]

  // Add wheel event listeners to each container
  scrollableContainers.forEach((container) => {
    if (!container) return

    container.addEventListener("wheel", function (e) {
      // Prevent the default scroll behavior
      e.stopPropagation()

      // Scroll the container
      this.scrollTop += e.deltaY
    })
  })
}

// Adicionar feedback visual para ações do usuário
function addVisualFeedback() {
  // Adicionar feedback para botões
  const buttons = document.querySelectorAll("button")
  buttons.forEach((button) => {
    button.addEventListener("click", function () {
      this.classList.add("button-clicked")
      setTimeout(() => {
        this.classList.remove("button-clicked")
      }, 200)
    })
  })

  // Adicionar indicadores de carregamento
  const addLoadingIndicator = (element, isLoading) => {
    if (isLoading) {
      const loadingSpinner = document.createElement("div")
      loadingSpinner.className = "spinner"
      element.appendChild(loadingSpinner)
      element.classList.add("is-loading")
    } else {
      const spinner = element.querySelector(".spinner")
      if (spinner) {
        spinner.remove()
      }
      element.classList.remove("is-loading")
    }
  }

  // Expor função para uso global
  window.showLoading = (elementId, isLoading) => {
    const element = document.getElementById(elementId)
    if (element) {
      addLoadingIndicator(element, isLoading)
    }
  }
}

// Verificar e corrigir eventos de botões
function verifyButtonEvents() {
  // Verificar botões de navegação
  const tabButtons = document.querySelectorAll(".tab-button")
  tabButtons.forEach((button) => {
    const tab = button.dataset.tab
    if (!tab) {
      console.error("Botão de tab sem identificador:", button)
      return
    }

    // Verificar se o tab existe
    const tabView = document.getElementById(tab)
    if (!tabView) {
      console.error(`Tab não encontrado: ${tab}`)
      return
    }

    // Garantir que o evento de clique está funcionando
    button.addEventListener("click", function () {
      // Remover classe active de todos os tabs e botões
      document.querySelectorAll(".tab-view").forEach((view) => view.classList.remove("active"))
      document.querySelectorAll(".tab-button").forEach((btn) => btn.classList.remove("active"))

      // Adicionar classe active ao tab e botão selecionados
      tabView.classList.add("active")
      this.classList.add("active")
    })
  })

  // Verificar botões de controle do player
  const playButton = document.getElementById("play")
  if (playButton) {
    playButton.addEventListener("click", () => {
      if (state.isPlaying) {
        client.stopVideo()
      } else if (state.currentTrack) {
        client.playVideo(state.currentTrack.videoId)
      }
    })
  }

  // Verificar botão de busca
  const searchButton = document.getElementById("search-button")
  const searchInput = document.getElementById("search-input")
  if (searchButton && searchInput) {
    searchButton.addEventListener("click", () => {
      const query = searchInput.value
      client.searchVideos(query)
    })

    searchInput.addEventListener("keypress", function (e) {
      if (e.key === "Enter") {
        const query = this.value
        client.searchVideos(query)
      }
    })
  }
}

// Inicializar aplicação
function initApp() {
  // Add the mouse wheel handler
  handleMouseWheel()

  // Ouvinte de mensagens do cliente
  window.addEventListener("message", (event) => {
    const data = event.data

    if (!data || !data.type) return

    switch (data.type) {
      case "openUI":
        // Mostrar interface
        elements.app.classList.remove("hidden")

        // Atualizar estado e configurações
        if (data.settings) {
          state.volume = data.settings.volume || state.volume
          state.range = data.settings.range || state.range
          state.source = data.settings.source || state.source
          state.bluetooth.enabled = data.settings.bluetoothEnabled || state.bluetooth.enabled
          state.uiSettings.scale = data.settings.uiScale || state.uiSettings.scale
          state.uiSettings.isExpanded =
            data.settings.isExpanded !== undefined ? data.settings.isExpanded : state.uiSettings.isExpanded
        }

        if (data.state) {
          state.isPlaying = data.state.isPlaying || false
          state.currentTrack = data.state.currentTrack || null
          state.playlists = data.state.playlists || []
          state.favorites = data.state.favorites || []
        }

        // Aplicar configurações
        ui.applyUISettings()

        // Atualizar elementos
        if (elements.player.volume) {
          elements.player.volume.value = state.volume
        }

        break

      case "closeUI":
        elements.app.classList.add("hidden")
        break

      case "notification":
        ui.showNotification(data.message, data.level)
        break

      case "updateSettings":
        if (data.settings) {
          state.volume = data.settings.volume || state.volume
          state.range = data.settings.range || state.range
          state.source = data.settings.source || state.source
          state.bluetooth.enabled = data.settings.bluetoothEnabled || state.bluetooth.enabled
          state.uiSettings.scale = data.settings.uiScale || state.uiSettings.scale
          state.uiSettings.isExpanded =
            data.settings.isExpanded !== undefined ? data.settings.isExpanded : state.uiSettings.isExpanded
        }

        // Aplicar configurações
        ui.applyUISettings()

        // Atualizar elementos
        if (elements.player.volume) {
          elements.player.volume.value = state.volume
        }

        break

      case "searchStatus":
        state.loading.search = data.status === "loading"
        ui.updateLoadingState("search", state.loading.search)

        if (data.status === "error") {
          ui.showNotification(data.error || "Erro na busca", "error")
        }
        break

      case "updateSearchResults":
        state.searchResults = data.results || []
        state.loading.search = false
        ui.updateLoadingState("search", false)
        ui.renderSearchResults(state.searchResults)
        break

      case "playStatus":
        state.loading.player = data.status === "loading"

        if (data.status === "error") {
          ui.showNotification(data.error || "Erro ao reproduzir", "error")
        }
        break

      case "updatePlayer":
        state.isPlaying = data.isPlaying || false
        state.currentTrack = data.track || null
        state.loading.player = false

        // Atualizar elementos do player
        if (elements.player.title) {
          elements.player.title.textContent = state.currentTrack ? state.currentTrack.title : "Nenhuma música tocando"
        }

        if (elements.player.artist) {
          elements.player.artist.textContent = state.currentTrack
            ? state.currentTrack.channelTitle
            : "Selecione uma música para começar"
        }

        if (elements.player.cover) {
          elements.player.cover.src = state.currentTrack ? state.currentTrack.thumbnailUrl : "img/default_cover.svg"
        }

        if (elements.player.play) {
          elements.player.play.innerHTML = state.isPlaying
            ? '<img src="img/pause.svg" alt="">'
            : '<img src="img/play.svg" alt="">'
        }

        break

      case "playlists":
        state.playlists = data.playlists || []
        state.loading.playlists = false
        ui.updateLoadingState("playlists", false)

        // Renderizar playlists
        if (elements.playlists.list) {
          elements.playlists.list.innerHTML = state.playlists
            .map(
              (playlist) => `
                <div class="playlist-item" data-playlist-id="${playlist.id}">
                    <img src="${playlist.cover_url || "img/default_playlist.svg"}" alt="${utils.sanitizeHTML(playlist.name)}">
                    <div class="playlist-info">
                        <h3>${utils.sanitizeHTML(playlist.name)}</h3>
                        <p>${playlist.tracks ? playlist.tracks.length : 0} músicas</p>
                    </div>
                </div>
            `,
            )
            .join("")
        }
        break

      case "playlistCreated":
        state.playlists.push(data.playlist)
        ui.showNotification("Playlist criada com sucesso", "success")
        break

      case "trackAdded":
        // Atualizar playlist no estado
        for (let i = 0; i < state.playlists.length; i++) {
          if (state.playlists[i].id === data.playlistId) {
            if (!state.playlists[i].tracks) {
              state.playlists[i].tracks = []
            }
            state.playlists[i].tracks.push(data.track)
            break
          }
        }
        ui.showNotification("Música adicionada à playlist", "success")
        break

      case "receiveFavorites":
        state.favorites = data.favorites || []
        state.loading.favorites = false
        ui.updateLoadingState("favorites", false)

        // Renderizar favoritos
        if (elements.favorites.list) {
          elements.favorites.list.innerHTML = state.favorites
            .map(
              (favorite) => `
                <div class="track-item" data-favorite-id="${favorite.id}">
                    <img src="${favorite.thumbnail_url || "img/default_cover.svg"}" alt="${utils.sanitizeHTML(favorite.title)}">
                    <div class="track-info">
                        <h3>${utils.sanitizeHTML(favorite.title)}</h3>
                    </div>
                    <div class="track-actions">
                        <button class="btn-icon" data-action="play" data-video-id="${favorite.video_id}" aria-label="Reproduzir">
                            <img src="img/play.svg" alt="">
                        </button>
                        <button class="btn-icon" data-action="remove-favorite" data-favorite-id="${favorite.id}" aria-label="Remover dos favoritos">
                            <img src="img/trash.svg" alt="">
                        </button>
                    </div>
                </div>
            `,
            )
            .join("")
        }
        break
    }
  })

  // Botão de fechar
  document.getElementById("close")?.addEventListener("click", () => {
    client.sendMessage("closeUI")
  })

  // Botão de minimizar/maximizar
  document.getElementById("minimize")?.addEventListener("click", () => {
    state.uiSettings.isExpanded = !state.uiSettings.isExpanded
    client.updateUISettings({ isExpanded: state.uiSettings.isExpanded })
  })

  // Controle de volume
  elements.player.volume?.addEventListener(
    "input",
    utils.throttle(function () {
      const volume = Number.parseInt(this.value)
      client.setVolume(volume)
    }, 300),
  )

  // Botão de play/pause
  elements.player.play?.addEventListener("click", () => {
    if (state.isPlaying) {
      client.stopVideo()
    } else if (state.currentTrack) {
      client.playVideo(state.currentTrack.videoId)
    }
  })

  // Botões de busca
  elements.search.button?.addEventListener("click", () => {
    const query = elements.search.input.value
    client.searchVideos(query)
  })

  elements.search.input?.addEventListener("keypress", function (e) {
    if (e.key === "Enter") {
      const query = this.value
      client.searchVideos(query)
    }
  })

  // Configurações de UI
  elements.settings.scaleSlider?.addEventListener(
    "input",
    utils.throttle(function () {
      const scale = Number.parseFloat(this.value)
      client.updateUISettings({ scale })

      if (elements.settings.scaleValue) {
        elements.settings.scaleValue.textContent = `${Math.round(scale * 100)}%`
      }
    }, 100),
  )

  elements.settings.expandToggle?.addEventListener("change", function () {
    const isExpanded = this.checked
    client.updateUISettings({ isExpanded })
  })

  // Eventos de clique para resultados de busca
  elements.search.results?.addEventListener("click", (e) => {
    const trackCard = e.target.closest(".track-card")
    if (!trackCard) return

    const videoId = trackCard.dataset.videoId
    if (!videoId) return

    const actionBtn = e.target.closest("[data-action]")
    if (!actionBtn) return

    const action = actionBtn.dataset.action

    switch (action) {
      case "play":
        client.playVideo(videoId)
        break
      case "add":
        // Abrir modal de adicionar à playlist
        if (elements.modals.addToPlaylist) {
          openAddToPlaylistModal(videoId)
        }
        break
      case "favorite":
        client.addFavorite(videoId)
        break
    }
  })

  // Inicializar estado
  state.isInitialized = true

  // Adicionar feedback visual
  addVisualFeedback()

  // Verificar e corrigir caminhos de imagens
  updateImagePaths()

  // Melhorar tratamento de erros na interface
  window.addEventListener("error", (e) => {
    console.error("Erro na interface:", e.error)
    ui.showNotification("Ocorreu um erro na interface. Verifique o console para mais detalhes.", "error")
  })

  // Solicitar favoritos
  setTimeout(() => {
    client.getFavorites()
  }, 1000)

  // Verificar e corrigir eventos de botões
  verifyButtonEvents()
}

// Função para abrir modal de adicionar à playlist
function openAddToPlaylistModal(videoId) {
  const modal = elements.modals.addToPlaylist
  if (!modal) return

  // Renderizar playlists
  const playlistsSelect = modal.querySelector("#playlists-select")
  if (playlistsSelect) {
    playlistsSelect.innerHTML = state.playlists
      .map(
        (playlist) => `
          <div class="playlist-item" data-playlist-id="${playlist.id}" data-video-id="${videoId}">
              <img src="${playlist.cover_url || "img/default_playlist.svg"}" alt="${utils.sanitizeHTML(playlist.name)}">
              <div class="playlist-info">
                  <h3>${utils.sanitizeHTML(playlist.name)}</h3>
                  <p>${playlist.tracks ? playlist.tracks.length : 0} músicas</p>
              </div>
          </div>
      `,
      )
      .join("")

    // Adicionar evento de clique
    playlistsSelect.querySelectorAll(".playlist-item").forEach((item) => {
      item.addEventListener("click", function () {
        const playlistId = this.dataset.playlistId
        const videoId = this.dataset.videoId

        if (playlistId && videoId) {
          client.addTrackToPlaylist({
            playlistId: Number.parseInt(playlistId),
            videoId,
          })

          // Fechar modal
          modal.classList.remove("active")
        }
      })
    })
  }

  // Botão de cancelar
  modal.querySelectorAll("[data-action='cancel']").forEach((btn) => {
    btn.addEventListener("click", () => {
      modal.classList.remove("active")
    })
  })

  // Abrir modal
  modal.classList.add("active")
}

// Corrigir referências de imagens
function updateImagePaths() {
  // Verificar se as imagens existem e usar fallbacks se necessário
  const checkImage = (url, fallback) => {
    return new Promise((resolve) => {
      const img = new Image()
      img.onload = () => resolve(url)
      img.onerror = () => resolve(fallback)
      img.src = url
    })
  }

  // Verificar e corrigir caminhos de imagens
  const imageElements = document.querySelectorAll("img")
  imageElements.forEach(async (img) => {
    const src = img.getAttribute("src")
    if (src && src.startsWith("img/")) {
      const fallback = src.includes("default_cover")
        ? "img/default_cover.svg"
        : src.includes("default_playlist")
          ? "img/default_playlist.svg"
          : "img/logo.svg"

      const validSrc = await checkImage(src, fallback)
      if (validSrc !== src) {
        console.warn(`Imagem não encontrada: ${src}, usando fallback: ${validSrc}`)
        img.setAttribute("src", validSrc)
      }
    }
  })
}

// Adicionar à inicialização
document.addEventListener("DOMContentLoaded", () => {
  initApp()
})
