fx_version 'adamant'

game 'gta5'

name 'atlantis_oxy'
author 'lilfraae'
description 'Oxy Runs script '
version 'a_0.0.1'

shared_script {
	'@es_extended/imports.lua',
	'config.lua',
}

server_scripts {
	'server/main.lua'
}

client_scripts {
	'client/main.lua'
}
