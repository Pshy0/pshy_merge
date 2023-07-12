--- pshy.commands.list.game
--
-- Commands related to the current game map.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.commands")
local help_pages = pshy.require("pshy.help.pages")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Game", text = "Commands affecting the current game/map."}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



__MODULE__.commands = {
	["time"] = {
		perms = "admins",
		desc = "change the TFM clock's time",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"number"},
		func = function(user, time)
			tfm.exec.setGameTime(time)
		end
	},
	["aiemode"] = {
		aliases = {"aie"},
		perms = "admins",
		desc = "enable or disable fall damage",
		argc_min = 0,
		argc_max = 3,
		arg_types = {"bool", "number", "player"},
		func = function(user, enabled, sensibility, player)
			if enabled == nil then
				enabled = true
			end
			tfm.exec.setAieMode(enabled, sensibility, player)
			return true, string.format("%s aie mode.", enabled and "Enabled" or "Disabled")
		end
	},
	["gravity"] = {
		perms = "admins",
		desc = "change the gravity and wind",
		argc_min = 0,
		argc_max = 2,
		arg_types = {"number", "number"},
		func = function(user, gravity, wind)
			gravity = gravity or 9
			wind = wind or 0
			tfm.exec.setWorldGravity(wind, gravity)
		end
	},
	["gravitywindscale"] = {
		perms = "admins",
		desc = "set how much the player is affected by gravity and wind",
		argc_min = 1,
		argc_max = 3,
		arg_types = {"number", "number", "player"},
		func = function(user, gravity_scale, wind_scale, player)
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
	},
	["nightmode"] = {
		aliases = {"playernightmode", "setplayernightmode"},
		perms = "admins",
		desc = "enable or disable night mode for a player",
		argc_min = 0,
		argc_max = 2,
		arg_types = {"bool", "player"},
		func = function(user, enabled, player)
			if enabled == nil then
				enabled = true
			end
			if player == nil then
				player = user
			end
			tfm.exec.setPlayerNightMode(enabled, player)
			return true, string.format("%s night mode.", enabled and "Enabled" or "Disabled")
		end
	},
	["backgroundcolor"] = {
		perms = "admins",
		desc = "set background color",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"color"},
		arg_names = {"background_color"},
		func = function(user, color)
			assert(type(color) == "number")
			ui.setBackgroundColor(string.format("#%06x", color))
		end
	}
}
