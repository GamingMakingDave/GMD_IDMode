fx_version 'cerulean'
games { 'gta5' }

author 'GMD Scripts & Design'
description 'a all in one and FREE VoiceCycle System for SaltyChat and PMA'
version '1.0'

lua54 'yes'

shared_scripts {
	'config.lua'
}

client_scripts {
	'client/*.lua'
}

server_script {
	'server/*.lua'
  }

dependencies {
	'es_extended'
}