// Settings class
class Settings {
    constructor() {
        this.settings = {
            theme: 'dark',
            locale: 'pt-BR',
            scale: 1.0,
            volume: 0.5,
            notifications: true,
            autoplay: false,
            shuffle: false,
            repeat: 'none'
        };
    }

    // Load settings from localStorage
    loadSettings() {
        try {
            const savedSettings = localStorage.getItem('tokyo_box_settings');
            if (savedSettings) {
                this.settings = { ...this.settings, ...JSON.parse(savedSettings) };
            }
            return true;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao carregar configurações:', error);
            return false;
        }
    }

    // Save settings to localStorage
    saveSettings() {
        try {
            localStorage.setItem('tokyo_box_settings', JSON.stringify(this.settings));
            return true;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao salvar configurações:', error);
            return false;
        }
    }

    // Get setting value
    getSetting(key) {
        return this.settings[key];
    }

    // Set setting value
    setSetting(key, value) {
        try {
            if (key in this.settings) {
                this.settings[key] = value;
                this.saveSettings();
                return true;
            }
            return false;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao definir configuração:', error);
            return false;
        }
    }

    // Get all settings
    getAllSettings() {
        return { ...this.settings };
    }

    // Reset settings to default
    resetSettings() {
        try {
            this.settings = {
                theme: 'dark',
                locale: 'pt-BR',
                scale: 1.0,
                volume: 0.5,
                notifications: true,
                autoplay: false,
                shuffle: false,
                repeat: 'none'
            };
            this.saveSettings();
            return true;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao resetar configurações:', error);
            return false;
        }
    }

    // Apply settings to UI
    applySettings() {
        try {
            // Apply theme
            document.documentElement.setAttribute('data-theme', this.settings.theme);

            // Apply scale
            const appLayout = document.getElementById('app-layout');
            if (appLayout) {
                appLayout.style.transform = `scale(${this.settings.scale})`;
            }

            // Apply locale
            if (window.translate) {
                window.translate.setLocale(this.settings.locale);
            }

            return true;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao aplicar configurações:', error);
            return false;
        }
    }

    // Get available themes
    getAvailableThemes() {
        return ['dark', 'light'];
    }

    // Get available locales
    getAvailableLocales() {
        return ['pt-BR', 'en-US'];
    }

    // Get available repeat modes
    getAvailableRepeatModes() {
        return ['none', 'one', 'all'];
    }

    // Check if setting exists
    hasSetting(key) {
        return key in this.settings;
    }

    // Remove setting
    removeSetting(key) {
        try {
            if (key in this.settings) {
                delete this.settings[key];
                this.saveSettings();
                return true;
            }
            return false;
        } catch (error) {
            console.error('[Tokyo Box] Erro ao remover configuração:', error);
            return false;
        }
    }
}

// Export settings instance
const settings = new Settings();
export default settings; 