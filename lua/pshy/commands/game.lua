--- pshy.commands.game
--
-- Commands related to the current game map.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.commands")



--- Module Help Page:
pshy.help_pages["pshy_commands_game"] = {back = "pshy", title = "Modules", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_commands_game"] = pshy.help_pages["pshy_commands_game"]



--- !time
local function ChatCommandTime(user, time)
	tfm.exec.setGameTime(time)
end
pshy.commands["time"] = {perms = "admins", func = ChatCommandTime, desc = "change the TFM clock's time", argc_min = 1, argc_max = 1, arg_types = {"number"}}
pshy.help_pages["pshy_commands_game"].commands["time"] = pshy.commands["time"]



--- !aiemode
local function ChatCommandAieMode(user, enabled, sensibility, player)
	if enabled == nil then
		enabled = true
	end
	tfm.exec.setAieMode(enabled, sensibility, player)
	return true, string.format("%s aie mode.", enabled and "Enabled" or "Disabled")
end
pshy.commands["aiemode"] = {aliases = {"aie"}, perms = "admins", func = ChatCommandAieMode, desc = "enable or disable fall damage", argc_min = 0, argc_max = 3, arg_types = {"bool", "number", "player"}}
pshy.help_pages["pshy_commands_game"].commands["aiemode"] = pshy.commands["aiemode"]



--- !gravity
local function ChatCommandGravity(user, gravity, wind)
	gravity = gravity or 9
	wind = wind or 0
	tfm.exec.setWorldGravity(wind, gravity)
end
pshy.commands["gravity"] = {perms = "admins", func = ChatCommandGravity, desc = "change the gravity and wind", argc_min = 0, argc_max = 2, arg_types = {"number", "number"}}
pshy.help_pages["pshy_commands_game"].commands["gravity"] = pshy.commands["gravity"]



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
pshy.commands["gravitywindscale"] = {perms = "admins", func = ChatCommandPlayergravitywindscale, desc = "set how much the player is affected by gravity and wind", argc_min = 1, argc_max = 3, arg_types = {"number", "number", "player"}}
pshy.help_pages["pshy_commands_game"].commands["gravitywindscale"] = pshy.commands["gravitywindscale"]



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
pshy.commands["nightmode"] = {aliases = {"playernightmode", "setplayernightmode"}, perms = "admins", func = ChatCommandPlayernightmode, desc = "enable or disable night mode for a player", argc_min = 0, argc_max = 2, arg_types = {"bool", "player"}}
pshy.help_pages["pshy_commands_game"].commands["nightmode"] = pshy.commands["nightmode"]
-- TODONOW



--- !backgroundcolor
local function ChatCommandBackgroundcolor(user, color)
	assert(type(color) == "number")
	ui.setBackgroundColor(string.format("#%06x", color))
end
pshy.commands["backgroundcolor"] = {perms = "admins", func = ChatCommandBackgroundcolor, desc = "set background color", argc_min = 1, argc_max = 1, arg_types = {"color"}, arg_names = {"background_color"}}
pshy.help_pages["pshy_commands_game"].commands["backgroundcolor"] = pshy.commands["backgroundcolor"]
