 



ui_page 'nui/index.html'

fx_version "bodacious"
game "gta5" 

client_scripts {
    "@vrp/lib/utils.lua",
    "client-side.lua",
    "**/client.lua",
    "config-side.lua"
}
 
server_scripts {
    "@vrp/lib/utils.lua",
    "server-side.lua",
    "config-side.lua"
}

files {
	'nui/*',
	'nui/imagens/*',
}
              