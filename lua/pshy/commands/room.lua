--- pshy.commands.room
--
-- Commands related to the room.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.commands")



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.commands_GetTargetOrError



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



--- !password <room_password>
local function ChatCommandPassword(user, pass)
	tfm.exec.setRoomPassword(pass)
	return true, "Password " .. (pass and "set" or "unset")
end
pshy.commands["password"] = {func = ChatCommandPassword, desc = "set the room's password", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_commands_tfm"].commands["password"] = pshy.commands["password"]
pshy.perms.admins["!password"] = true



--- !mapflipmode
local function ChatCommandMapflipmode(user, mapflipmode)
	tfm.exec.setAutoMapFlipMode(mapflipmode)
end
pshy.commands["mapflipmode"] = {func = ChatCommandMapflipmode, desc = "Set TFM to use mirrored maps (yes/no or no param for default)", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm_more"].commands["mapflipmode"] = pshy.commands["mapflipmode"]
pshy.perms.admins["!mapflipmode"] = true



--- !shamanskills
local function ChatCommandShamanskills(user, shamanskills)
	if shamanskills == nil then
		shamanskills = true
	end
	tfm.exec.disableAllShamanSkills(not shamanskills)
end
pshy.commands["shamanskills"] = {func = ChatCommandShamanskills, desc = "enable (or disable) TFM shaman's skills", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm_more"].commands["shamanskills"] = pshy.commands["shamanskills"]
pshy.perms.admins["!shamanskills"] = true



--- !autoscore
local function ChatCommandAutoscore(user, autoscore)
	if autoscore == nil then
		autoscore = true
	end
	tfm.exec.disableAutoScore(not autoscore)
end
pshy.commands["autoscore"] = {func = ChatCommandAutoscore, desc = "enable (or disable) TFM score handling", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm_more"].commands["autoscore"] = pshy.commands["autoscore"]
pshy.perms.admins["!autoscore"] = true



--- !prespawnpreview
local function ChatCommandPrespawnpreview(user, prespawnpreview)
	tfm.exec.disablePrespawnPreview(not prespawnpreview)
end
pshy.commands["prespawnpreview"] = {func = ChatCommandPrespawnpreview, desc = "show (or hide) what the shaman is spawning", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm_more"].commands["prespawnpreview"] = pshy.commands["prespawnpreview"]
pshy.perms.admins["!prespawnpreview"] = true
