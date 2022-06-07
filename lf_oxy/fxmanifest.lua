fx_version 'cerulean'
game 'gta5'

name 'lf_oxy'
author 'lilfraae'
description 'Clean black money by delivering packages'
version '1.0.0'

shared_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config.lua',
}

server_scripts {
	'server/main.lua'
}

client_scripts {
	'client/main.lua'
}

dependency 'es_extended'