fx_version 'cerulean'
game 'gta5'

author 'Tokyo Box'
description 'Sistema de música para FiveM'
version '1.0.0'

shared_scripts {
    'config.lua',
    'locales/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/*.css',
    'html/js/*.js',
    'html/img/*.png'
}

dependencies {
    'qb-core'
}

lua54 'yes'
