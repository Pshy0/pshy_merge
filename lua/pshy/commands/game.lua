--- pshy.commands.game
--
-- Commands related to the current game map.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.commands")



--- !time
local function ChatCommandTime(user, time)
	tfm.exec.setGameTime(time)
end
pshy.commands["time"] = {func = ChatCommandTime, desc = "change the TFM clock's time", argc_min = 1, argc_max = 1, arg_types = {"number"}}
pshy.help_pages["pshy_commands_tfm"].commands["time"] = pshy.commands["time"]
pshy.perms.admins["!time"] = true



--- !aiemode
local function ChatCommandAieMode(user, enabled, sensibility, player)
	if enabled == nil then
		enabled = true
	end
	tfm.exec.setAieMode(enabled, sensibility, player)
	return true, string.format("%s aie mode.", enabled and "Enabled" or "Disabled")
end
pshy.commands["aiemode"] = {func = ChatCommandAieMode, desc = "enable or disable fall damage", argc_min = 0, argc_max = 3, arg_types = {"bool", "number", "player"}}
pshy.help_pages["pshy_commands_tfm"].commands["aiemode"] = pshy.commands["aiemode"]
pshy.commands_aliases["aie"] = "aiemode"
pshy.perms.admins["!aiemode"] = true



--- !gravity
local function ChatCommandGravity(user, gravity, wind)
	gravity = gravity or 9
	wind = wind or 0
	tfm.exec.setWorldGravity(wind, gravity)
end
pshy.commands["gravity"] = {func = ChatCommandGravity, desc = "change the gravity and wind", argc_min = 0, argc_max = 2, arg_types = {"number", "number"}}
pshy.help_pages["pshy_commands_tfm"].commands["gravity"] = pshy.commands["gravity"]
pshy.perms.admins["!gravity"] = true



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
pshy.commands["gravitywindscale"] = {func = ChatCommandPlayergravitywindscale, desc = "set how much the player is affected by gravity and wind", argc_min = 1, argc_max = 3, arg_types = {"number", "number", "player"}}
pshy.help_pages["pshy_commands_tfm"].commands["gravitywindscale"] = pshy.commands["gravitywindscale"]
pshy.perms.admins["!gravitywindscale"] = true



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
pshy.commands["nightmode"] = {func = ChatCommandPlayernightmode, desc = "enable or disable night mode for a player", argc_min = 0, argc_max = 2, arg_types = {"bool", "player"}}
pshy.help_pages["pshy_commands_tfm"].commands["nightmode"] = pshy.commands["nightmode"]
pshy.commands_aliases["playernightmode"] = "nightmode"
pshy.commands_aliases["setplayernightmode"] = "nightmode"
pshy.perms.admins["!nightmode"] = true



--- !backgroundcolor
local function ChatCommandBackgroundcolor(user, color)
	assert(type(color) == "number")
	ui.setBackgroundColor(string.format("#%06x", color))
end
pshy.commands["backgroundcolor"] = {func = ChatCommandBackgroundcolor, desc = "set background color", argc_min = 1, argc_max = 1, arg_types = {"color"}, arg_names = {"background_color"}}
pshy.help_pages["pshy_commands_tfm_more"].commands["backgroundcolor"] = pshy.commands["backgroundcolor"]
pshy.perms.admins["!backgroundcolor"] = true
