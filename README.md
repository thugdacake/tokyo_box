# Tokyo Box - Sistema de Música para FiveM

![Tokyo Box](https://i.imgur.com/your-image.png)

## 📝 Descrição
Tokyo Box é um sistema avançado de música para servidores FiveM, permitindo que os jogadores reproduzam músicas do YouTube em tempo real. Desenvolvido com foco em performance e facilidade de uso.

## ✨ Características
- Reprodução de músicas do YouTube
- Sistema de playlists
- Controle de volume
- Interface moderna e responsiva
- Suporte a múltiplos idiomas
- Integração com QBCore
- Sistema de permissões
- Cache de músicas
- Notificações personalizáveis

## 🚀 Instalação

### Requisitos
- FiveM Server
- QBCore Framework
- oxmysql
- YouTube API Key

### Passos
1. Baixe o recurso
2. Coloque na pasta `resources`
3. Adicione ao seu `server.cfg`:
```cfg
ensure oxmysql
ensure qb-core
ensure tokyo_box
```

4. Configure a chave da API do YouTube:
```cfg
set TOKYO_BOX_YOUTUBE_API_KEY "sua_chave_aqui"
```

## ⚙️ Configuração
O arquivo `config.lua` contém todas as configurações do recurso:

```lua
Config = {
    Framework = 'qb-core',
    YouTube = {
        apiKey = 'sua_chave_aqui',
        quotaLimit = 10000
    },
    -- ... outras configurações
}
```

## 🎮 Uso
- `/music [url]` - Reproduz uma música
- `/playlist [nome]` - Gerencia playlists
- `/volume [0-100]` - Ajusta o volume

## 🔧 Comandos
| Comando | Descrição |
|---------|-----------|
| `/music` | Reproduz uma música do YouTube |
| `/playlist` | Gerencia suas playlists |
| `/volume` | Ajusta o volume da música |

## 🌐 Idiomas Suportados
- Português (Brasil)
- Inglês (EUA)

## 📦 Dependências
- qb-core
- oxmysql

## 🤝 Contribuição
Contribuições são bem-vindas! Por favor, leia o [CONTRIBUTING.md](CONTRIBUTING.md) para detalhes sobre nosso código de conduta e o processo para enviar pull requests.

## 📄 Licença
Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE.md](LICENSE.md) para detalhes.

## 👥 Autores
- **thugdacake** - *Desenvolvimento inicial*

## 🙏 Agradecimentos
- QBCore Framework
- oxmysql
- Comunidade FiveM

## 📞 Suporte
- Discord: [Link do Discord]
- Issues: [GitHub Issues]

## 🔄 Atualizações
Veja o [CHANGELOG.md](CHANGELOG.md) para informações sobre as atualizações.

## ⚠️ Problemas Conhecidos
- Nenhum problema conhecido no momento

## 🔜 Próximas Atualizações
- [ ] Sistema de rádio
- [ ] Integração com Spotify
- [ ] Mais temas de UI
- [ ] Sistema de votação para músicas
