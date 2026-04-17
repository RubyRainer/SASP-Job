fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'sasp_job'
author 'SASP Custom Job by Codex'
description 'Feature-rich SASP duty job with custom framework and optional QBCore bridges.'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/utils.lua',
    'shared/framework.lua'
}

client_scripts {
    'client/main.lua',
    'client/duty.lua',
    'client/traffic.lua',
    'client/backup.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/duty.lua',
    'server/calls.lua',
    'server/armory.lua'
}

dependencies {
    'ox_lib',
    'oxmysql'
}
