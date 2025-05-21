# Tokyo Box

Sistema de música e vídeo para FiveM com interface moderna e recursos avançados.

## Características

- Reprodução de música e vídeos do YouTube
- Interface responsiva e moderna
- Temas personalizáveis
- Suporte a múltiplos idiomas
- Sistema de playlists
- Favoritos
- Controle de volume
- Sistema de permissões
- Cache para melhor performance
- Notificações estilizadas
- Comandos de debug

## Requisitos

- FiveM Server
- QBX Core
- oxmysql
- Chave da API do YouTube

## Instalação

1. Baixe o recurso
2. Coloque na pasta `resources`
3. Adicione `ensure tokyo-box` ao seu `server.cfg`
4. Configure sua chave da API do YouTube em `config.lua`
5. Reinicie o servidor

## Uso Rápido

### Comandos
- `/tokyobox` - Abre o menu principal
- `/tokyobox_spawnBox` - Spawna uma caixa de som
- `/tokyobox_btToggle` - Ativa/desativa modo Bluetooth
- `/tokyobox_lang [idioma]` - Muda o idioma (pt-BR, en-US)
- `/tokyobox_theme [tema]` - Muda o tema (Default, Dark, Light, Neon)

### Controles
- `E` - Interagir com a caixa de som
- `G` - Abrir/fechar interface
- `ESC` - Fechar interface
- `Mouse` - Arrastar interface
- `Scroll` - Ajustar volume

### Permissões
- `tokyo_box.play` - Reproduzir música
- `tokyo_box.create_playlist` - Criar playlists
- `tokyo_box.delete_playlist` - Deletar playlists
- `tokyo_box.admin` - Acesso administrativo

## Configuração

### API
```lua
Config.YouTubeAPIKey = 'SUA_CHAVE_API_AQUI'
Config.YouTubeCacheDuration = 3600 -- 1 hora
Config.YouTubeRequestInterval = 1 -- 1 segundo entre requisições
```

### UI
```lua
Config.UI = {
    DefaultScale = 1.0,
    MinScale = 0.5,
    MaxScale = 2.0,
    ScaleStep = 0.1,
    DefaultTheme = 'Default'
}
```

### Player
```lua
Config.Audio = {
    DefaultVolume = 0.5,
    MinVolume = 0.0,
    MaxVolume = 1.0,
    VolumeStep = 0.1,
    FadeDuration = 0.5
}
```

## Idiomas Suportados

- Português (Brasil) - `pt-BR`
- Inglês (EUA) - `en-US`

Para adicionar um novo idioma:
1. Crie um arquivo JSON em `locales/`
2. Use o formato do arquivo `pt-BR.json` como base
3. Adicione o idioma ao `Config.DefaultLocale`

## Temas Disponíveis

- Default - Tema padrão com cores vermelhas
- Dark - Tema escuro com cores azuis
- Light - Tema claro com cores azuis
- Neon - Tema escuro com cores neon

Para adicionar um novo tema:
1. Adicione o tema em `Config.Themes`
2. Use o formato dos temas existentes como base
3. Defina as cores e valores necessários

## Desenvolvimento

### Estrutura de Arquivos
```
tokyo-box/
├── client/
│   ├── locale.lua
│   ├── theme.lua
│   └── main.lua
├── server/
│   ├── database.lua
│   ├── youtube_api.lua
│   └── main.lua
├── html/
│   ├── index.html
│   ├── css/
│   │   └── style.css
│   └── js/
│       └── nui.js
├── locales/
│   ├── pt-BR.json
│   └── en-US.json
├── test/
│   ├── test_helper.lua
│   ├── locale_test.lua
│   ├── theme_test.lua
│   └── database_test.lua
├── config.lua
├── fxmanifest.lua
├── README.md
└── CHANGELOG.md
```

### Modo Debug
Para ativar o modo debug, defina `Config.Debug = true` em `config.lua`.

### Testes
Para executar os testes:
1. Ative o modo debug
2. Use o comando `/tokyobox_test`

## Suporte

- [GitHub Issues](https://github.com/seu-usuario/tokyo-box/issues)
- [Discord](https://discord.gg/seu-servidor)

## Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.
# tokyo_box
