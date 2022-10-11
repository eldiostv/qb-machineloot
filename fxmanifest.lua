

fx_version 'cerulean'
game 'gta5'
description 'qb-machineloot by eldios'
version "1.0.0"
author "SpyX"

dependencies { 'qb-target' }

version "1.0.0"

client_scripts {
  'client/client.lua',
  'qb-target',
  'config.lua',
}

server_scripts {
  'config.lua',
  'server/server.lua',
}
