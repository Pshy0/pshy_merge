--- pshy.commands.list.game
--
-- Commands related to the current game map.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.commands")
local command_list = pshy.require("pshy.commands.list")
local help_pages = pshy.require("pshy.help.pages")



--- Module Help Page:
help_pages["pshy_commands_game"] = {back = "pshy", title = "Game", commands = {}}
help_pages["pshy"].subpages["pshy_commands_game"] = help_pages["pshy_commands_game"]



--- !time
local function ChatCommandTime(user, time)
	tfm.exec.setGameTime(time)
end
command_list["time"] = {perms = "admins", func = ChatCommandTime, desc = "change the TFM clock's time", argc_min = 1, argc_max = 1, arg_types = {"number"}}
help_pages["pshy_commands_game"].commands["time"] = command_list["time"]



--- !aiemode
local function ChatCommandAieMode(user, enabled, sensibility, player)
	if enabled == nil then
		enabled = true
	end
	tfm.exec.setAieMode(enabled, sensibility, player)
	return true, string.format("%s aie mode.", enabled and "Enabled" or "Disabled")
end
command_list["aiemode"] = {aliases = {"aie"}, perms = "admins", func = ChatCommandAieMode, desc = "enable or disable fall damage", argc_min = 0, argc_max = 3, arg_types = {"bool", "number", "player"}}
help_pages["pshy_commands_game"].commands["aiemode"] = command_list["aiemode"]



--- !gravity
local function ChatCommandGravity(user, gravity, wind)
	gravity = gravity or 9
	wind = wind or 0
	tfm.exec.setWorldGravity(wind, gravity)
end
command_list["gravity"] = {perms = "admins", func = ChatCommandGravity, desc = "change the gravity and wind", argc_min = 0, argc_max = 2, arg_types = {"number", "number"}}
help_pages["pshy_commands_game"].commands["gravity"] = command_list["gravity"]



--- !gravitywindscale
local function ChatCommandPlayergravitywindscale(user, gravity_scale, wind_scale, player)
	if gravity_scale == nil then
		gravity_scale = 1
	end
	if wind_scale == nil then
		wind_scale = 1
	end
	if player == nil then
		player = user
	end
	tfm.exec.setPlayerGravityScale(player, gravity_scale, wind_scale)
	return true
end
command_list["gravitywindscale"] = {perms = "admins", func = ChatCommandPlayergravitywindscale, desc = "set how much the player is affected by gravity and wind", argc_min = 1, argc_max = 3, arg_types = {"number", "number", "player"}}
help_pages["pshy_commands_game"].commands["gravitywindscale"] = command_list["gravitywindscale"]



--- !nightmode
local function ChatCommandPlayernightmode(user, enabled, player)
	if enabled == nil then
		enabled = true
	end
	if player == nil then
		player = user
	end
	tfm.exec.setPlayerNightMode(enabled, player)
	return true, string.format("%s night mode.", enabled and "Enabled" or "Disabled")
end
command_list["nightmode"] = {aliases = {"playernightmode", "setplayernightmode"}, perms = "admins", func = ChatCommandPlayernightmode, desc = "enable or disable night mode for a player", argc_min = 0, argc_max = 2, arg_types = {"bool", "player"}}
help_pages["pshy_commands_game"].commands["nightmode"] = command_list["nightmode"]
-- TODONOW



--- !backgroundcolor
local function ChatCommandBackgroundcolor(user, color)
	assert(type(color) == "number")
	ui.setBackgroundColor(string.format("#%06x", color))
end
command_list["backgroundcolor"] = {perms = "admins", func = ChatCommandBackgroundcolor, desc = "set background color", argc_min = 1, argc_max = 1, arg_types = {"color"}, arg_names = {"background_color"}}
help_pages["pshy_commands_game"].commands["backgroundcolor"] = command_list["backgroundcolor"]
