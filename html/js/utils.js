// Utility functions
const utils = {
    // Format time (seconds to MM:SS)
    formatTime(seconds) {
        try {
            if (typeof seconds !== 'number' || isNaN(seconds)) {
                return '00:00';
            }
            
            const minutes = Math.floor(seconds / 60);
            const remainingSeconds = Math.floor(seconds % 60);
            
            return `${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao formatar tempo:', error);
            return '00:00';
        }
    },

    // Format file size (bytes to human readable)
    formatFileSize(bytes) {
        try {
            if (typeof bytes !== 'number' || isNaN(bytes)) {
                return '0 B';
            }
            
            const units = ['B', 'KB', 'MB', 'GB', 'TB'];
            let size = bytes;
            let unitIndex = 0;
            
            while (size >= 1024 && unitIndex < units.length - 1) {
                size /= 1024;
                unitIndex++;
            }
            
            return `${size.toFixed(2)} ${units[unitIndex]}`;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao formatar tamanho:', error);
            return '0 B';
        }
    },

    // Debounce function
    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    },

    // Throttle function
    throttle(func, limit) {
        let inThrottle;
        return function executedFunction(...args) {
            if (!inThrottle) {
                func(...args);
                inThrottle = true;
                setTimeout(() => inThrottle = false, limit);
            }
        };
    },

    // Generate random ID
    generateId() {
        return Math.random().toString(36).substr(2, 9);
    },

    // Check if object is empty
    isEmpty(obj) {
        return Object.keys(obj).length === 0;
    },

    // Deep clone object
    deepClone(obj) {
        try {
            return JSON.parse(JSON.stringify(obj));
        } catch (error) {
            console.error('[Tokyo Box] Erro ao clonar objeto:', error);
            return {};
        }
    },

    // Validate YouTube URL
    validateYouTubeUrl(url) {
        try {
            const pattern = /^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/.+$/;
            return pattern.test(url);
        } catch (error) {
            console.error('[Tokyo Box] Erro ao validar URL:', error);
            return false;
        }
    },

    // Extract YouTube video ID
    extractYouTubeId(url) {
        try {
            const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/;
            const match = url.match(regExp);
            return (match && match[2].length === 11) ? match[2] : null;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao extrair ID:', error);
            return null;
        }
    },

    // Sanitize HTML
    sanitizeHtml(html) {
        try {
            const temp = document.createElement('div');
            temp.textContent = html;
            return temp.innerHTML;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao sanitizar HTML:', error);
            return '';
        }
    },

    // Truncate text
    truncateText(text, maxLength) {
        try {
            if (text.length <= maxLength) return text;
            return text.substr(0, maxLength) + '...';
        } catch (error) {
            console.error('[Tokyo Box] Erro ao truncar texto:', error);
            return '';
        }
    },

    // Get element by ID
    getElement(id) {
        try {
            return document.getElementById(id);
        } catch (error) {
            console.error('[Tokyo Box] Erro ao obter elemento:', error);
            return null;
        }
    },

    // Create element
    createElement(tag, attributes = {}, children = []) {
        try {
            const element = document.createElement(tag);
            
            for (const [key, value] of Object.entries(attributes)) {
                element.setAttribute(key, value);
            }
            
            if (Array.isArray(children)) {
                children.forEach(child => {
                    if (typeof child === 'string') {
                        element.appendChild(document.createTextNode(child));
                    } else {
                        element.appendChild(child);
                    }
                });
            }
            
            return element;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao criar elemento:', error);
            return null;
        }
    },

    // Add event listener
    addEventListener(element, event, handler) {
        try {
            if (element && typeof handler === 'function') {
                element.addEventListener(event, handler);
                return true;
            }
            return false;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao adicionar listener:', error);
            return false;
        }
    },

    // Remove event listener
    removeEventListener(element, event, handler) {
        try {
            if (element && typeof handler === 'function') {
                element.removeEventListener(event, handler);
                return true;
            }
            return false;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao remover listener:', error);
            return false;
        }
    }
};

// Export utils
export default utils; 