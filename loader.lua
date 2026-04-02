-- loader.lua
local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/CaveUser/MxF/main/GameList.lua"))()

local URL = Games[game.GameId]

if URL then
    loadstring(game:HttpGet(URL))()
else
    warn("Jeu non supporté")
end