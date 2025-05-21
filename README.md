# Tokyo Box

Um sistema avançado de música para FiveM com suporte a múltiplos frameworks e recursos modernos.

## 🚀 Recursos

- 🎵 Reprodução de música via YouTube
- 🎨 Temas personalizáveis (dark/light)
- 🌍 Suporte a múltiplos idiomas
- 💾 Sistema de playlists salvas
- 🔄 Cache inteligente
- 🔔 Sistema de notificações
- 🛡️ Suporte a múltiplos frameworks (QBCore, ESX, OX Core)
- 📱 Interface moderna e responsiva

## 📋 Requisitos

- FiveM Server
- Framework suportado (QBCore, ESX ou OX Core)
- oxmysql (opcional, para persistência de dados)

## ⚙️ Instalação

1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/tokyo-box.git
```

2. Copie a pasta `tokyo-box` para seu diretório de recursos

3. Adicione ao seu `server.cfg`:
```cfg
ensure tokyo-box
```

4. Configure sua chave da API do YouTube em `config.lua`

## 🎮 Uso

- Comando: `/tokyobox`
- Tecla padrão: `F7`

## 🔧 Configuração

Todas as configurações podem ser ajustadas no arquivo `config.lua`:

- Framework
- API do YouTube
- UI
- Player
- Permissões
- Comandos
- Notificações
- Banco de dados
- Cache
- Debug
- Teclas
- Temas
- Idiomas

## 📦 Estrutura do Projeto

```
tokyo-box/
├── client/
│   ├── main.lua
│   ├── commands.lua
│   ├── events.lua
│   ├── locale.lua
│   ├── notification.lua
│   ├── nui.lua
│   ├── theme.lua
│   └── utils.lua
├── server/
│   ├── main.lua
│   ├── commands.lua
│   ├── database.lua
│   ├── events.lua
│   ├── init.lua
│   ├── youtube_api.lua
│   └── check_dependencies.lua
├── html/
│   ├── index.html
│   ├── style.css
│   └── script.js
├── locales/
│   ├── pt-BR.lua
│   └── en-US.lua
├── config.lua
└── fxmanifest.lua
```

## 🔄 Atualizações Recentes

### v1.0.0
- Implementação inicial
- Sistema de cache
- Sistema de notificações
- Temas personalizáveis
- Playlists salvas
- Suporte a múltiplos frameworks

## 🤝 Contribuição

Contribuições são bem-vindas! Por favor, leia o [CONTRIBUTING.md](CONTRIBUTING.md) para detalhes sobre nosso código de conduta e o processo para enviar pull requests.

## 📝 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE.md](LICENSE.md) para detalhes.

## 📞 Suporte

Para suporte, abra uma issue no GitHub ou entre em contato através do Discord.
