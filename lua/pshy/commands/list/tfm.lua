--- pshy.commands.list.tfm
--
-- Various commands related to TFM.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local command_list = pshy.require("pshy.commands.list")
local help_pages = pshy.require("pshy.help.pages")



--- Module Help Page:
help_pages["pshy_commands_tfm"] = {back = "pshy", title = "Misc", text = "Misc TFM related commands.", commands = {}}
help_pages["pshy"].subpages["pshy_commands_tfm"] = help_pages["pshy_commands_tfm"]



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.require("pshy.commands.get_target_or_error")



--- !colorpicker
local function ChatCommandColorpicker(user, target)
	target = GetTarget(user, target, "!colorpicker")
	ui.showColorPicker(49, target, 0, "Get a color code:")
end
command_list["colorpicker"] = {perms = "everyone", func = ChatCommandColorpicker, desc = "show the colorpicker", argc_min = 0, argc_max = 1, arg_types = {"player"}}
help_pages["pshy_commands_tfm"].commands["colorpicker"] = command_list["colorpicker"]



--- !clear
local function ChatCommandClear(user)
	tfm.exec.chatMessage("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", nil)
end
command_list["clear"] = {perms = "admins", func = ChatCommandClear, desc = "clear the chat for everone", argc_min = 0, argc_max = 0}
help_pages["pshy_commands_tfm"].commands["clear"] = command_list["clear"]



--- !apiversion
local function ChatCommandApiversion(user)
	return true, string.format("TFM API version: %s", tostring(tfm.get.misc.apiVersion))
end
command_list["apiversion"] = {perms = "everyone", func = ChatCommandApiversion, desc = "Show the API version.", argc_min = 0, argc_max = 0}
help_pages["pshy_commands_tfm"].commands["apiversion"] = command_list["apiversion"]



--- !tfmversion
local function ChatCommandTfmversion(user)
	return true, string.format("TFM version: %s", tostring(tfm.get.misc.transformiceVersion))
end
command_list["tfmversion"] = {perms = "everyone", func = ChatCommandTfmversion, desc = "Show TFM's version.", argc_min = 0, argc_max = 0}
help_pages["pshy_commands_tfm"].commands["tfmversion"] = command_list["tfmversion"]



--- !playerid
local function ChatCommandPlayerid(user, player_name)
	player_name = GetTarget(user, player_name, "!playerid")
	return true, string.format("%s's player id is %d.", player_name, tfm.get.room.playerList[player_name].id)
end
command_list["playerid"] = {perms = "everyone", func = ChatCommandPlayerid, desc = "Show your TFM player id.", argc_min = 0, argc_max = 1, arg_names = {"player"}}
help_pages["pshy_commands_tfm"].commands["playerid"] = command_list["playerid"]



--- !playerlook
local function ChatCommandPlayerlook(user, player_name)
	player_name = player_name or user
	return true, string.format("%s's player look is '%s'.", player_name, tfm.get.room.playerList[player_name].look)
end
command_list["playerlook"] = {perms = "everyone", func = ChatCommandPlayerlook, desc = "Show your TFM player look.", argc_min = 0, argc_max = 1, arg_names = {"player"}}
help_pages["pshy_commands_tfm"].commands["playerlook"] = command_list["playerlook"]



--- !ping
local function ChatCommandPing(user, player_name)
	player_name = player_name or user
	return true, string.format("%s's average latency: %s.", player_name, tfm.get.room.playerList[player_name].averageLatency)
end
command_list["ping"] = {perms = "admins", func = ChatCommandPing, desc = "Show a player's latency.", argc_min = 0, argc_max = 1, arg_names = {"player"}}
help_pages["pshy_commands_tfm"].commands["ping"] = command_list["ping"]



--- !playsound
local function ChatCommandPlaysound(user, sound_name)
	tfm.exec.playSound(sound_name)
end
command_list["playsound"] = {perms = "admins", func = ChatCommandPlaysound, desc = "Play a sound in the room.", argc_min = 1, argc_max = 1}
help_pages["pshy_commands_tfm"].commands["playsound"] = command_list["playsound"]
