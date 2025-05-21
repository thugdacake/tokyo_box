fx_version 'cerulean'
game 'gta5'

author 'Seu Nome'
description 'Tokyo Box - Sistema de Música'
version '1.0.0'

shared_scripts {
    'config.lua',
    'locales/*.lua'
}

client_scripts {
    'client/nui.lua',
    'client/events.lua',
    'client/commands.lua'
}

server_scripts {
    'server/youtube.lua',
    'server/events.lua',
    'server/commands.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/nui.js',
    'html/js/player.js',
    'html/js/playlist.js',
    'html/js/search.js',
    'html/js/settings.js',
    'html/js/utils.js',
    'html/assets/*.png',
    'html/assets/*.svg',
    'html/assets/*.mp3'
}

dependencies {
    'qb-core'
}

lua54 'yes'
