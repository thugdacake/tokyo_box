// Search class
class Search {
    constructor() {
        this.results = [];
        this.isSearching = false;
        this.lastQuery = '';
        this.maxResults = 10;
    }

    // Search for tracks
    async search(query) {
        try {
            if (!query || query.trim() === '') {
                console.warn('[Tokyo Box] Query de busca inválida');
                return [];
            }

            this.isSearching = true;
            this.lastQuery = query;

            const response = await fetch(`https://${GetParentResourceName()}/search`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ query })
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const data = await response.json();
            this.results = data.results || [];
            return this.results;
        } catch (error) {
            console.error('[Tokyo Box] Erro na busca:', error);
            return [];
        } finally {
            this.isSearching = false;
        }
    }

    // Get search results
    getResults() {
        return [...this.results];
    }

    // Clear search results
    clearResults() {
        this.results = [];
        this.lastQuery = '';
    }

    // Check if searching
    isSearchingNow() {
        return this.isSearching;
    }

    // Get last query
    getLastQuery() {
        return this.lastQuery;
    }

    // Set max results
    setMaxResults(max) {
        if (typeof max === 'number' && max > 0) {
            this.maxResults = max;
            return true;
        }
        return false;
    }

    // Get max results
    getMaxResults() {
        return this.maxResults;
    }

    // Format search result
    formatResult(result) {
        try {
            return {
                id: result.id,
                title: result.title,
                artist: result.channelTitle || 'Artista desconhecido',
                thumbnail: result.thumbnail,
                duration: result.duration || '00:00',
                url: `https://www.youtube.com/watch?v=${result.id}`
            };
        } catch (error) {
            console.error('[Tokyo Box] Erro ao formatar resultado:', error);
            return null;
        }
    }

    // Format all results
    formatResults(results) {
        try {
            return results.map(result => this.formatResult(result)).filter(Boolean);
        } catch (error) {
            console.error('[Tokyo Box] Erro ao formatar resultados:', error);
            return [];
        }
    }
}

// Export search instance
const search = new Search();
export default search; 