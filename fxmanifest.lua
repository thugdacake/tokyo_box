fx_version 'cerulean'
game 'gta5'

author 'Tokyo Box'
description 'Sistema de música para FiveM'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/*.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
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
    'qb-core',
    'oxmysql'
}

lua54 'yes'
