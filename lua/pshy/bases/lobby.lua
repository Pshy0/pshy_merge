--- pshy.bases.lobby
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
__MODULE__.require_direct_enabling = true
local command_list = pshy.require("pshy.commands.list")
local help_pages = pshy.require("pshy.help.pages")
local maps = pshy.require("pshy.maps.list")
local rotations = pshy.require("pshy.rotations.list")
pshy.require("pshy.moduleswitch")



--- Namespace.
local lobby = {}



--- Module Help Page:
help_pages["pshy_lobby"] = {back = "pshy", title = "Lobby", text = "Adds a lobby for players to wait before the game starts.", commands = {}}
help_pages["pshy"].subpages["pshy_lobby"] = help_pages["pshy_lobby"]



--- Internal Use:
lobby.message = ""
local dead_players = {}



--- Map began callback.
-- @private
function eventThisModuleEnabled()
	--tfm.exec.chatMessage("<fc>L o b b y</fc>")
	lobby.UpdateTitle()
	--tfm.exec.disableAutoNewGame(true)
	lobby.running = true
end



--- Map ended callback.
-- @private
function eventThisModuleDisabled()
	ui.removeTextArea(9, nil)
	lobby.running = false
	dead_players = {}
end



--- Module Settings:
lobby.map_name = "lobby"					-- lobby map name



--- Default lobby map
maps[lobby.map_name] = {}
maps[lobby.map_name].shamans = 0
maps[lobby.map_name].author = "Pshy#3752"
maps[lobby.map_name].xml = 7898520
maps[lobby.map_name].autoskip = false
maps[lobby.map_name].modules = {"pshy.bases.lobby"}



--- Update the lobby's title message.
-- @param player_name The player who will see the update, or nil for everybody.
-- @private
function lobby.UpdateTitle(player_name)
	--ui.setMapName("<fc>L o b b y</fc>")
	ui.addTextArea(9, "<b><p align='center'><font size='64'><n>L o b b y</n></font>\n<fc>" .. lobby.message .. "</fc></p></b>", player_name, 200, 20, 400, 0, 0x1, 0x0, 0.0, false)
end



--- TFM event eventNewPlayer.
function eventNewPlayer(player_name)
	lobby.UpdateTitle(player_name)
	tfm.exec.respawnPlayer(player_name)
end



--- TFM event eventPlayerDied.
function eventPlayerDied(player_name)
	dead_players[player_name] = true
end



function eventLoop()
	for player_name in pairs(dead_players) do
		tfm.exec.respawnPlayer(player_name)
	end
	dead_players = {}
end



--- !lobby [message]
function lobby.ChatCommandLobby(user, message)
	message = message or "Setting up the room..."
	lobby.message = message
	if not lobby.running then
		tfm.exec.disableAutoShaman(true)
		tfm.exec.newGame(lobby.map_name)
	else
		lobby.UpdateTitle()
	end
	return true, "Opening the lobby..."
end
command_list["lobby"] = {perms = "admins", func = lobby.ChatCommandLobby, desc = "start or update the lobby with a message", argc_min = 0, argc_max = 1, arg_types = {"string"}}
help_pages["pshy_lobby"].commands["lobby"] = command_list["lobby"]



--- Initialization:
function eventInit()
	lobby.ChatCommandLobby(nil, nil)
end



return lobby
