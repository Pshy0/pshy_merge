--- pshy_commands_tfm.lua
--
-- Adds commands to call basic tfm functions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_perms.lua
--
-- @require_priority UTILS



--- Module Help Page:
pshy.help_pages["pshy_commands_tfm"] = {back = "pshy", title = "TFM basic commands", text = "", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_commands_tfm"] = pshy.help_pages["pshy_commands_tfm"]



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.commands_GetTargetOrError



--- !mapflipmode
local function ChatCommandMapflipmode(user, mapflipmode)
	tfm.exec.setAutoMapFlipMode(mapflipmode)
end
pshy.commands["mapflipmode"] = {func = ChatCommandMapflipmode, desc = "Set TFM to use mirrored maps (yes/no or no param for default)", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm"].commands["mapflipmode"] = pshy.commands["mapflipmode"]
pshy.perms.admins["!mapflipmode"] = true



--- !autonewgame
local function ChatCommandAutonewgame(user, autonewgame)
	if autonewgame == nil then
		autonewgame = true
	end
	tfm.exec.disableAutoNewGame(not autonewgame)
end
pshy.commands["autonewgame"] = {func = ChatCommandAutonewgame, desc = "enable (or disable) TFM automatic map changes", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm"].commands["autonewgame"] = pshy.commands["autonewgame"]
pshy.perms.admins["!autonewgame"] = true



--- !autoshaman
local function ChatCommandAutoshaman(user, autoshaman)
	if autoshaman == nil then
		autoshaman = true
	end
	tfm.exec.disableAutoShaman(not autoshaman)
end
pshy.commands["autoshaman"] = {func = ChatCommandAutoshaman, desc = "enable (or disable) TFM automatic shaman choice", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm"].commands["autoshaman"] = pshy.commands["autoshaman"]
pshy.perms.admins["!autoshaman"] = true



--- !shamanskills
local function ChatCommandShamanskills(user, shamanskills)
	if shamanskills == nil then
		shamanskills = true
	end
	tfm.exec.disableAllShamanSkills(not shamanskills)
end
pshy.commands["shamanskills"] = {func = ChatCommandShamanskills, desc = "enable (or disable) TFM shaman's skills", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm"].commands["shamanskills"] = pshy.commands["shamanskills"]
pshy.perms.admins["!shamanskills"] = true



--- !time
local function ChatCommandTime(user, time)
	tfm.exec.setGameTime(time)
end
pshy.commands["time"] = {func = ChatCommandTime, desc = "change the TFM clock's time", argc_min = 1, argc_max = 1, arg_types = {"number"}}
pshy.help_pages["pshy_commands_tfm"].commands["time"] = pshy.commands["time"]
pshy.perms.admins["!time"] = true



--- !autotimeleft
local function ChatCommandAutotimeleft(user, autotimeleft)
	if autotimeleft == nil then
		autotimeleft = true
	end
	tfm.exec.disableAutoTimeLeft(not autotimeleft)
end
pshy.commands["autotimeleft"] = {func = ChatCommandAutotimeleft, desc = "enable (or disable) TFM automatic lowering of time", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm"].commands["autotimeleft"] = pshy.commands["autotimeleft"]
pshy.perms.admins["!autotimeleft"] = true



--- !playerscore
local function ChatCommandPlayerscore(user, score, target)
	score = score or 0
	target = GetTarget(user, target, "!playerscore")
	tfm.exec.setPlayerScore(target, score, false)
end
pshy.commands["playerscore"] = {func = ChatCommandPlayerscore, desc = "set the TFM score of a player in the scoreboard", argc_min = 0, argc_max = 2, arg_types = {"number", "player"}}
pshy.help_pages["pshy_commands_tfm"].commands["playerscore"] = pshy.commands["playerscore"]
pshy.perms.admins["!playerscore"] = true
pshy.perms.admins["!colorpicker-others"] = true



--- !autoscore
local function ChatCommandAutoscore(user, autoscore)
	if autoscore == nil then
		autoscore = true
	end
	tfm.exec.disableAutoScore(not autoscore)
end
pshy.commands["autoscore"] = {func = ChatCommandAutoscore, desc = "enable (or disable) TFM score handling", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm"].commands["autoscore"] = pshy.commands["autoscore"]
pshy.perms.admins["!autoscore"] = true



--- !afkdeath
local function ChatCommandAfkdeath(user, afkdeath)
	if afkdeath == nil then
		afkdeath = true
	end
	tfm.exec.disableAfkDeath(not afkdeath)
end
pshy.commands["afkdeath"] = {func = ChatCommandAfkdeath, desc = "enable (or disable) TFM's killing of AFK players", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm"].commands["afkdeath"] = pshy.commands["afkdeath"]
pshy.perms.admins["!afkdeath"] = true



--- !allowmort
local function ChatCommandMortcommand(user, allowmort)
	tfm.exec.disableMortCommand(not allowmort)
end
pshy.commands["allowmort"] = {func = ChatCommandMortcommand, desc = "allow (or prevent) TFM's /mort command", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm"].commands["allowmort"] = pshy.commands["allowmort"]
pshy.perms.admins["!allowmort"] = true



--- !allowwatch
local function ChatCommandWatchcommand(user, allowwatch)
	tfm.exec.disableWatchCommand(not allowwatch)
end 
pshy.commands["allowwatch"] = {func = ChatCommandWatchcommand, desc = "allow (or prevent) TFM's /watch command", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm"].commands["allowwatch"] = pshy.commands["allowwatch"]
pshy.perms.admins["!allowwatch"] = true



--- !allowdebug
local function ChatCommandDebugcommand(user, allowdebug)
	tfm.exec.disableDebugCommand(not allowdebug)
end
pshy.commands["allowdebug"] = {func = ChatCommandDebugcommand, desc = "allow (or prevent) TFM's /debug command", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm"].commands["allowdebug"] = pshy.commands["allowdebug"]
pshy.perms.admins["!allowdebug"] = true



--- !minimalist
local function ChatCommandMinimalist(user, debugcommand)
	tfm.exec.disableMinimalistMode(not debugcommand)
end
pshy.commands["minimalist"] = {func = ChatCommandMinimalist, desc = "allow (or prevent) TFM's minimalist mode", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm"].commands["minimalist"] = pshy.commands["minimalist"]
pshy.perms.admins["!minimalist"] = true



--- !consumables
local function ChatCommandAllowconsumables(user, consumables)
	tfm.exec.disablePshysicalConsumables(not consumables)
end
pshy.commands["consumables"] = {func = ChatCommandAllowconsumables, desc = "allow (or prevent) the use of physical consumables", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm"].commands["consumables"] = pshy.commands["consumables"]
pshy.perms.admins["!consumables"] = true



--- !chatcommandsdisplay
local function ChatCommandChatcommandsdisplay(user, display)
	system.disableChatCommandDisplay(nil, not display)
end
pshy.commands["chatcommandsdisplay"] = {func = ChatCommandChatcommandsdisplay, desc = "show (or hide) all chat commands", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm"].commands["chatcommandsdisplay"] = pshy.commands["chatcommandsdisplay"]
pshy.perms.admins["!chatcommandsdisplay"] = true



--- !prespawnpreview
local function ChatCommandPrespawnpreview(user, prespawnpreview)
	tfm.exec.disablePrespawnPreview(not prespawnpreview)
end
pshy.commands["prespawnpreview"] = {func = ChatCommandPrespawnpreview, desc = "show (or hide) what the shaman is spawning", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm"].commands["prespawnpreview"] = pshy.commands["prespawnpreview"]
pshy.perms.admins["!prespawnpreview"] = true



--- !gravity
local function ChatCommandGravity(user, gravity, wind)
	gravity = gravity or 9
	wind = wind or 0
	tfm.exec.setWorldGravity(wind, gravity)
end
pshy.commands["gravity"] = {func = ChatCommandGravity, desc = "change the gravity and wind", argc_min = 0, argc_max = 2, arg_types = {"number", "number"}}
pshy.help_pages["pshy_commands_tfm"].commands["gravity"] = pshy.commands["gravity"]
pshy.perms.admins["!gravity"] = true



--- !colorpicker
local function ChatCommandColorpicker(user, target)
	target = GetTarget(user, target, "!colorpicker")
	ui.showColorPicker(49, target, 0, "Get a color code:")
end
pshy.commands["colorpicker"] = {func = ChatCommandColorpicker, desc = "show the colorpicker", argc_min = 0, argc_max = 1, arg_types = {"player"}}
pshy.help_pages["pshy_commands_tfm"].commands["colorpicker"] = pshy.commands["colorpicker"]
pshy.perms.everyone["!colorpicker"] = true
pshy.perms.admins["!colorpicker-others"] = true



--- !getxml
-- @TODO: xml may be cut in the wrong spot!
local function ChatCommandGetxml(user, force)
	if not tfm.get.room.xmlMapInfo or not tfm.get.room.xmlMapInfo.xml then
		return false, "This map does not have an xml."
	end
	local xml = tfm.get.room.xmlMapInfo.xml
	xml = string.gsub(xml, "<", "&lt;")
	xml = string.gsub(xml, ">", "&gt;")
	tfm.exec.chatMessage("<ch>=== MAP CODE (" .. tostring(#xml) .. "#) ===</ch>", user)
	while #xml > 0 do
		part = string.sub(xml, 1, 180)
		tfm.exec.chatMessage(part, user)
		xml = string.sub(xml, 180 + 1, #xml)
	end
	tfm.exec.chatMessage("<ch>=== END OF MAP CODE ===</ch>", user)
end
pshy.commands["getxml"] = {func = ChatCommandGetxml, desc = "get the current map's xml (only for @maps)", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm"].commands["getxml"] = pshy.commands["getxml"]



--- !clear
local function ChatCommandClear(user)
	tfm.exec.chatMessage("\n\n\n\n\n\n\n\n\n\n\n\n\n", nil)
end
pshy.commands["clear"] = {func = ChatCommandClear, desc = "clear the chat for everone", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_commands_tfm"].commands["clear"] = pshy.commands["clear"]
pshy.perms.admins["!clear"] = true



--- !backgroundcolor
local function ChatCommandBackgroundcolor(user, color)
	assert(type(color) == "number")
	ui.setBackgroundColor(string.format("#%06x", color))
end
pshy.commands["backgroundcolor"] = {func = ChatCommandBackgroundcolor, desc = "set background color", argc_min = 1, argc_max = 1, arg_types = {"color"}, arg_names = {"background_color"}}
pshy.help_pages["pshy_commands_tfm"].commands["backgroundcolor"] = pshy.commands["backgroundcolor"]
pshy.perms.admins["!backgroundcolor"] = true



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



--- !gravityscale
local function ChatCommandPlayergravityscale(user, scale, player)
	if scale == nil then
		scale = 1
	end
	if player == nil then
		player = user
	end
	tfm.exec.setPlayerGravityScale(player, scale)
	return true
end
pshy.commands["gravityscale"] = {func = ChatCommandPlayergravityscale, desc = "set how much the player is affected by gravity", argc_min = 1, argc_max = 2, arg_types = {"number", "player"}}
pshy.help_pages["pshy_commands_tfm"].commands["gravityscale"] = pshy.commands["gravityscale"]
pshy.commands_aliases["playergravityscale"] = "gravityscale"
pshy.perms.admins["!gravityscale"] = true



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



--- !password <room_password>
local function ChatCommandPassword(user, pass)
	tfm.exec.setRoomPassword(pass)
	return true, "Password " .. (pass and "set" or "unset")
end
pshy.commands["password"] = {func = ChatCommandPassword, desc = "set the room's password", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_commands_tfm"].commands["password"] = pshy.commands["password"]
pshy.perms.admins["!password"] = true
