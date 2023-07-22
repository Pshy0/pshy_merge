--- pshy.commands.list.tfm
--
-- Various commands related to TFM.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local help_pages = pshy.require("pshy.help.pages")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Misc", text = "Misc TFM related commands."}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.require("pshy.commands.get_target_or_error")



__MODULE__.commands = {
	["colorpicker"] = {
		perms = "everyone",
		desc = "show the colorpicker",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"player"},
		func = function(user, target)
			target = GetTarget(user, target, "!colorpicker")
			ui.showColorPicker(49, target, 0, "Get a color code:")
		end
	},
	["clear"] = {
		perms = "admins",
		desc = "clear the chat for everyone",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			tfm.exec.chatMessage("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", nil)
		end
	},
	["apiversion"] = {
		perms = "everyone",
		desc = "Show the API version.",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			return true, string.format("TFM API version: %s", tostring(tfm.get.misc.apiVersion))
		end
	},
	["tfmversion"] = {
		perms = "everyone",
		desc = "Show TFM's version.",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			return true, string.format("TFM version: %s", tostring(tfm.get.misc.transformiceVersion))
		end
	},
	["playerid"] = {
		perms = "everyone",
		desc = "Show your TFM player id.",
		argc_min = 0,
		argc_max = 1,
		arg_names = {"player"},
		func = function(user, player_name)
			player_name = GetTarget(user, player_name, "!playerid")
			return true, string.format("%s's player id is %d.", player_name, tfm.get.room.playerList[player_name].id)
		end
	},
	["playerlook"] = {
		perms = "everyone",
		desc = "Show your TFM player look.",
		argc_min = 0,
		argc_max = 1,
		arg_names = {"player"},
		func = function(user, player_name)
			player_name = player_name or user
			return true, string.format("%s's player look is '%s'.", player_name, tfm.get.room.playerList[player_name].look)
		end
	},
	["ping"] = {
		perms = "admins",
		desc = "Get a player's average latency.",
		argc_min = 0,
		argc_max = 1,
		arg_names = {"player"},
		func = function(user, player_name)
			player_name = player_name or user
			return true, string.format("%s's average latency: %s.", player_name, tfm.get.room.playerList[player_name].averageLatency)
		end
	}
}
