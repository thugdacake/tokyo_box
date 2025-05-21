fx_version 'cerulean'
game 'gta5'

author 'thugdacake'
description 'Sistema de música para FiveM'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/*.lua',
    'config.lua'
}

client_scripts {
    '@qb-core/client/wrapper.lua',
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

escrow_ignore {
    'config.lua',
    'locales/*.lua'
}

provide 'tokyo_box'
