// Player class
class Player {
    constructor() {
        this.currentTrack = null;
        this.isPlaying = false;
        this.volume = 0.5;
        this.isMuted = false;
        this.isShuffled = false;
        this.repeatMode = 'none'; // none, one, all
        this.playlist = [];
        this.currentIndex = -1;
    }

    // Play a track
    async play(track) {
        try {
            this.currentTrack = track;
            this.isPlaying = true;
            this.currentIndex = this.playlist.findIndex(t => t.id === track.id);
            return true;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao reproduzir faixa:', error);
            return false;
        }
    }

    // Pause playback
    async pause() {
        try {
            this.isPlaying = false;
            return true;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao pausar:', error);
            return false;
        }
    }

    // Resume playback
    async resume() {
        try {
            this.isPlaying = true;
            return true;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao retomar:', error);
            return false;
        }
    }

    // Stop playback
    async stop() {
        try {
            this.currentTrack = null;
            this.isPlaying = false;
            return true;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao parar:', error);
            return false;
        }
    }

    // Set volume
    async setVolume(volume) {
        try {
            this.volume = Math.max(0, Math.min(1, volume));
            return true;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao ajustar volume:', error);
            return false;
        }
    }

    // Toggle mute
    async toggleMute() {
        try {
            this.isMuted = !this.isMuted;
            return true;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao alternar mudo:', error);
            return false;
        }
    }

    // Toggle shuffle
    async toggleShuffle() {
        try {
            this.isShuffled = !this.isShuffled;
            if (this.isShuffled) {
                this.shufflePlaylist();
            }
            return true;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao alternar aleatório:', error);
            return false;
        }
    }

    // Set repeat mode
    async setRepeatMode(mode) {
        try {
            if (['none', 'one', 'all'].includes(mode)) {
                this.repeatMode = mode;
                return true;
            }
            return false;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao definir modo de repetição:', error);
            return false;
        }
    }

    // Add track to playlist
    async addToPlaylist(track) {
        try {
            this.playlist.push(track);
            return true;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao adicionar à playlist:', error);
            return false;
        }
    }

    // Remove track from playlist
    async removeFromPlaylist(trackId) {
        try {
            const index = this.playlist.findIndex(t => t.id === trackId);
            if (index !== -1) {
                this.playlist.splice(index, 1);
                return true;
            }
            return false;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao remover da playlist:', error);
            return false;
        }
    }

    // Clear playlist
    async clearPlaylist() {
        try {
            this.playlist = [];
            this.currentIndex = -1;
            return true;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao limpar playlist:', error);
            return false;
        }
    }

    // Shuffle playlist
    shufflePlaylist() {
        try {
            for (let i = this.playlist.length - 1; i > 0; i--) {
                const j = Math.floor(Math.random() * (i + 1));
                [this.playlist[i], this.playlist[j]] = [this.playlist[j], this.playlist[i]];
            }
        } catch (error) {
            console.error('[Tokyo Box] Erro ao embaralhar playlist:', error);
        }
    }

    // Get next track
    getNextTrack() {
        try {
            if (this.playlist.length === 0) return null;
            
            if (this.repeatMode === 'one') {
                return this.currentTrack;
            }
            
            if (this.repeatMode === 'all' && this.currentIndex === this.playlist.length - 1) {
                this.currentIndex = 0;
            } else {
                this.currentIndex++;
            }
            
            if (this.currentIndex >= this.playlist.length) {
                return null;
            }
            
            return this.playlist[this.currentIndex];
        } catch (error) {
            console.error('[Tokyo Box] Erro ao obter próxima faixa:', error);
            return null;
        }
    }

    // Get previous track
    getPreviousTrack() {
        try {
            if (this.playlist.length === 0) return null;
            
            if (this.repeatMode === 'one') {
                return this.currentTrack;
            }
            
            if (this.repeatMode === 'all' && this.currentIndex === 0) {
                this.currentIndex = this.playlist.length - 1;
            } else {
                this.currentIndex--;
            }
            
            if (this.currentIndex < 0) {
                return null;
            }
            
            return this.playlist[this.currentIndex];
        } catch (error) {
            console.error('[Tokyo Box] Erro ao obter faixa anterior:', error);
            return null;
        }
    }
}

// Export player instance
const player = new Player();
export default player; 