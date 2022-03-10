--- pshy_lobby.lua
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_mapdb.lua
-- @require pshy_merge.lua
pshy.merge_DisableModule("pshy_lobby.lua")		-- this is a map module (disabled by default)



--- Module Help Page:
pshy.help_pages["pshy_lobby"] = {back = "pshy", title = "Lobby", text = "Adds a lobby for players to wait before the game starts.", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_lobby"] = pshy.help_pages["pshy_lobby"]



--- Internal Use:
pshy.lobby_message = ""



--- Map began callback.
-- @private
function eventModuleEnabled()
	--tfm.exec.chatMessage("<fc>L o b b y</fc>")
	pshy.lobby_UpdateTitle()
	--tfm.exec.disableAutoNewGame(true)
	pshy.lobby_running = true
end



--- Map ended callback.
-- @private
function eventModuleDisabled()
	ui.removeTextArea(9, nil)
	pshy.lobby_running = false
end



--- Module Settings:
pshy.lobby_map_name = "lobby"					-- lobby map name



--- Default lobby map (adds to mapdb)
pshy.mapdb_maps[pshy.lobby_map_name] = {}
pshy.mapdb_maps[pshy.lobby_map_name].shamans = 0
pshy.mapdb_maps[pshy.lobby_map_name].author = "Pshy#3752"
pshy.mapdb_maps[pshy.lobby_map_name].xml = 7898520
pshy.mapdb_maps[pshy.lobby_map_name].autoskip = false
pshy.mapdb_maps[pshy.lobby_map_name].modules = {"pshy_lobby.lua"}



--- Update the lobby's title message.
-- @param player_name The player who will see the update, or nil for everybody.
-- @private
function pshy.lobby_UpdateTitle(player_name)
	--ui.setMapName("<fc>L o b b y</fc>")
	ui.addTextArea(9, "<b><p align='center'><font size='64'><n>L o b b y</n></font>\n<fc>" .. pshy.lobby_message .. "</fc></p></b>", player_name, 200, 20, 400, 0, 0x1, 0x0, 0.0, false)
end



--- TFM event eventNewPlayer.
function eventNewPlayer(player_name)
	pshy.lobby_UpdateTitle(player_name)
end



--- TFM event eventPlayerDied.
function eventPlayerDied(player_name)
	tfm.exec.respawnPlayer(player_name)
end



--- !lobby [message]
function pshy.lobby_ChatCommandLobby(user, message)
	message = message or "Setting up the room..."
	pshy.lobby_message = message
	if not pshy.lobby_running then
		tfm.exec.disableAutoShaman(true)
		tfm.exec.newGame(pshy.lobby_map_name)
	else
		pshy.lobby_UpdateTitle()
	end
	return true, "Opening the lobby..."
end
pshy.commands["lobby"] = {func = pshy.lobby_ChatCommandLobby, desc = "start or update the lobby with a message", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_lobby"].commands["lobby"] = pshy.commands["lobby"]
pshy.perms.admins["!lobby"] = true



--- Initialization:
function eventInit()
	pshy.lobby_ChatCommandLobby(nil, nil)
end
