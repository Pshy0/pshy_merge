--- pshy.commands.list.tfm
--
-- Various commands related to TFM.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local help_pages = pshy.require("pshy.help.pages")
local room = pshy.require("pshy.room")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Misc", text = "Misc TFM related commands."}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.require("pshy.commands.get_target_or_error")



--- Map of players who have been displayed the color picker -> users asking for it
local colorpicker_callers = {}



function eventColorPicked(color_picker_id, player_name, color)
	if color_picker_id == -43 and colorpicker_callers[player_name] then
		caller = colorpicker_callers[player_name]
		if color >= 0 then
			if caller then
				tfm.exec.chatMessage(string.format("    <vi><b>/colornick %s <font color='#%x'>#%x</font></b>", player_name, color, color), caller)
				if caller == room.loader then
					print(string.format("<n2><b>[%s] chose color %x</b>", player_name, color))
				end
			end
			tfm.exec.chatMessage(string.format("<g>Chosen color: #%x.", color), player_name)
		end
		colorpicker_callers[player_name] = nil
	end
end



__MODULE__.commands = {
	["colorpicker"] = {
		perms = "everyone",
		desc = "show the colorpicker",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"player"},
		func = function(user, target)
			target = GetTarget(user, target, "!colorpicker")
			if user ~= target then
				colorpicker_callers[target] = user
			end
			ui.showColorPicker(-43, target, 0, "Get a color code:")
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
