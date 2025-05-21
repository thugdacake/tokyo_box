// Playlist class
class Playlist {
    constructor() {
        this.tracks = [];
        this.currentIndex = -1;
        this.isShuffled = false;
        this.repeatMode = 'none'; // none, one, all
    }

    // Add track to playlist
    addTrack(track) {
        try {
            this.tracks.push(track);
            return true;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao adicionar faixa:', error);
            return false;
        }
    }

    // Remove track from playlist
    removeTrack(trackId) {
        try {
            const index = this.tracks.findIndex(t => t.id === trackId);
            if (index !== -1) {
                this.tracks.splice(index, 1);
                if (this.currentIndex >= this.tracks.length) {
                    this.currentIndex = this.tracks.length - 1;
                }
                return true;
            }
            return false;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao remover faixa:', error);
            return false;
        }
    }

    // Clear playlist
    clear() {
        try {
            this.tracks = [];
            this.currentIndex = -1;
            return true;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao limpar playlist:', error);
            return false;
        }
    }

    // Get current track
    getCurrentTrack() {
        try {
            if (this.currentIndex === -1 || this.tracks.length === 0) {
                return null;
            }
            return this.tracks[this.currentIndex];
        } catch (error) {
            console.error('[Tokyo Box] Erro ao obter faixa atual:', error);
            return null;
        }
    }

    // Get next track
    getNextTrack() {
        try {
            if (this.tracks.length === 0) return null;
            
            if (this.repeatMode === 'one') {
                return this.getCurrentTrack();
            }
            
            if (this.repeatMode === 'all' && this.currentIndex === this.tracks.length - 1) {
                this.currentIndex = 0;
            } else {
                this.currentIndex++;
            }
            
            if (this.currentIndex >= this.tracks.length) {
                return null;
            }
            
            return this.tracks[this.currentIndex];
        } catch (error) {
            console.error('[Tokyo Box] Erro ao obter próxima faixa:', error);
            return null;
        }
    }

    // Get previous track
    getPreviousTrack() {
        try {
            if (this.tracks.length === 0) return null;
            
            if (this.repeatMode === 'one') {
                return this.getCurrentTrack();
            }
            
            if (this.repeatMode === 'all' && this.currentIndex === 0) {
                this.currentIndex = this.tracks.length - 1;
            } else {
                this.currentIndex--;
            }
            
            if (this.currentIndex < 0) {
                return null;
            }
            
            return this.tracks[this.currentIndex];
        } catch (error) {
            console.error('[Tokyo Box] Erro ao obter faixa anterior:', error);
            return null;
        }
    }

    // Set current track
    setCurrentTrack(trackId) {
        try {
            const index = this.tracks.findIndex(t => t.id === trackId);
            if (index !== -1) {
                this.currentIndex = index;
                return true;
            }
            return false;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao definir faixa atual:', error);
            return false;
        }
    }

    // Toggle shuffle
    toggleShuffle() {
        try {
            this.isShuffled = !this.isShuffled;
            if (this.isShuffled) {
                this.shuffle();
            }
            return true;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao alternar aleatório:', error);
            return false;
        }
    }

    // Shuffle playlist
    shuffle() {
        try {
            for (let i = this.tracks.length - 1; i > 0; i--) {
                const j = Math.floor(Math.random() * (i + 1));
                [this.tracks[i], this.tracks[j]] = [this.tracks[j], this.tracks[i]];
            }
            return true;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao embaralhar playlist:', error);
            return false;
        }
    }

    // Set repeat mode
    setRepeatMode(mode) {
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

    // Get playlist length
    getLength() {
        return this.tracks.length;
    }

    // Check if playlist is empty
    isEmpty() {
        return this.tracks.length === 0;
    }

    // Get all tracks
    getAllTracks() {
        return [...this.tracks];
    }
}

// Export playlist instance
const playlist = new Playlist();
export default playlist; 