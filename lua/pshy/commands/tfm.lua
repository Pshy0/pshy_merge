--- pshy.commands.tfm
--
-- Various commands related to TFM.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.bases.doc")



--- Module Help Page:
pshy.help_pages["pshy_commands_tfm"] = {back = "pshy", title = "TFM", text = "Commands calling functions from the TFM api.", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_commands_tfm"] = pshy.help_pages["pshy_commands_tfm"]



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.commands_GetTargetOrError



--- !colorpicker
local function ChatCommandColorpicker(user, target)
	target = GetTarget(user, target, "!colorpicker")
	ui.showColorPicker(49, target, 0, "Get a color code:")
end
pshy.commands["colorpicker"] = {perms = "everyone", func = ChatCommandColorpicker, desc = "show the colorpicker", argc_min = 0, argc_max = 1, arg_types = {"player"}}
pshy.help_pages["pshy_commands_tfm"].commands["colorpicker"] = pshy.commands["colorpicker"]



--- !clear
local function ChatCommandClear(user)
	tfm.exec.chatMessage("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", nil)
end
pshy.commands["clear"] = {perms = "admins", func = ChatCommandClear, desc = "clear the chat for everone", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_commands_tfm"].commands["clear"] = pshy.commands["clear"]



--- !apiversion
local function ChatCommandApiversion(user)
	return true, string.format("TFM API version: %s", tostring(tfm.get.misc.apiVersion))
end
pshy.commands["apiversion"] = {perms = "everyone", func = ChatCommandApiversion, desc = "Show the API version.", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_commands_tfm"].commands["apiversion"] = pshy.commands["apiversion"]



--- !tfmversion
local function ChatCommandTfmversion(user)
	return true, string.format("TFM version: %s", tostring(tfm.get.misc.transformiceVersion))
end
pshy.commands["tfmversion"] = {perms = "everyone", func = ChatCommandTfmversion, desc = "Show the API version.", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_commands_tfm"].commands["tfmversion"] = pshy.commands["tfmversion"]



--- !playerid
local function ChatCommandPlayerid(user, player_name)
	player_name = GetTarget(user, player_name, "!playerid")
	return true, string.format("%s's player id is %d.", player_name, tfm.get.room.playerList[player_name].id)
end
pshy.commands["playerid"] = {perms = "everyone", func = ChatCommandPlayerid, desc = "Show your TFM player id.", argc_min = 0, argc_max = 1, arg_names = {"player"}}
pshy.help_pages["pshy_commands_tfm"].commands["playerid"] = pshy.commands["playerid"]



--- !playerlook
local function ChatCommandPlayerlook(user, player_name)
	player_name = player_name or user
	return true, string.format("%s's player look is '%d'.", player_name, tfm.get.room.playerList[player_name].id)
end
pshy.commands["playerlook"] = {perms = "everyone", func = ChatCommandPlayerlook, desc = "Show your TFM player look.", argc_min = 0, argc_max = 1, arg_names = {"player"}}
pshy.help_pages["pshy_commands_tfm"].commands["playerlook"] = pshy.commands["playerlook"]
