--- pshy.commands.tfm
--
-- Various commands related to TFM.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.commands")
pshy.require("pshy.bases.doc")
pshy.require("pshy.bases.perms")



--- Module Help Page:
pshy.help_pages["pshy_commands_tfm"] = {back = "pshy", title = "TFM function commands", text = "Basic commands calling functions from the TFM api.", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_commands_tfm"] = pshy.help_pages["pshy_commands_tfm"]



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.commands_GetTargetOrError



--- !colorpicker
local function ChatCommandColorpicker(user, target)
	target = GetTarget(user, target, "!colorpicker")
	ui.showColorPicker(49, target, 0, "Get a color code:")
end
pshy.commands["colorpicker"] = {func = ChatCommandColorpicker, desc = "show the colorpicker", argc_min = 0, argc_max = 1, arg_types = {"player"}}
pshy.help_pages["pshy_commands_tfm"].commands["colorpicker"] = pshy.commands["colorpicker"]
pshy.perms.everyone["!colorpicker"] = true
pshy.perms.admins["!colorpicker-others"] = true



--- !clear
local function ChatCommandClear(user)
	tfm.exec.chatMessage("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", nil)
end
pshy.commands["clear"] = {func = ChatCommandClear, desc = "clear the chat for everone", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_commands_tfm"].commands["clear"] = pshy.commands["clear"]
pshy.perms.admins["!clear"] = true



--- !apiversion
local function ChatCommandApiversion(user)
	return true, string.format("TFM API version: %s", tostring(tfm.get.misc.apiVersion))
end
pshy.commands["apiversion"] = {func = ChatCommandApiversion, desc = "Show the API version.", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_commands_lua"].commands["apiversion"] = pshy.commands["apiversion"]
pshy.perms.everyone["!apiversion"] = true



--- !tfmversion
local function ChatCommandTfmversion(user)
	return true, string.format("TFM version: %s", tostring(tfm.get.misc.transformiceVersion))
end
pshy.commands["tfmversion"] = {func = ChatCommandTfmversion, desc = "Show the API version.", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_commands_lua"].commands["tfmversion"] = pshy.commands["tfmversion"]
pshy.perms.everyone["!tfmversion"] = true



--- !playerid
local function ChatCommandPlayerid(user, player_name)
	player_name = GetTarget(user, player_name, "!playerid")
	return true, string.format("%s's player id is %d.", player_name, tfm.get.room.playerList[player_name].id)
end
pshy.commands["playerid"] = {func = ChatCommandPlayerid, desc = "Show your TFM player id.", argc_min = 0, argc_max = 1, arg_names = {"player"}}
pshy.help_pages["pshy_commands_lua"].commands["playerid"] = pshy.commands["playerid"]
pshy.perms.everyone["!playerid"] = true
pshy.perms.admins["!playerid-others"] = true



--- !playerlook
local function ChatCommandPlayerlook(user, player_name)
	player_name = player_name or user
	return true, string.format("%s's player look is '%d'.", player_name, tfm.get.room.playerList[player_name].id)
end
pshy.commands["playerlook"] = {func = ChatCommandPlayerlook, desc = "Show your TFM player look.", argc_min = 0, argc_max = 1, arg_names = {"player"}}
pshy.help_pages["pshy_commands_lua"].commands["playerlook"] = pshy.commands["playerlook"]
pshy.perms.everyone["!playerlook"] = true
