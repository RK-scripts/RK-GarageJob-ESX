fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'RK Scripts'
description 'ESX Job Vehicle Garage'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'config.lua',
    'client/main.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/main.lua'
}