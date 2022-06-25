--- pshy.commands.room
--
-- Commands related to the room.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.commands")
local help_pages = pshy.require("pshy.help.pages")



--- Module Help Page:
help_pages["pshy_commands_room"] = {back = "pshy", title = "Room", commands = {}}
help_pages["pshy"].subpages["pshy_commands_room"] = help_pages["pshy_commands_room"]



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.commands_GetTargetOrError



--- !autonewgame
local function ChatCommandAutonewgame(user, autonewgame)
	if autonewgame == nil then
		autonewgame = true
	end
	tfm.exec.disableAutoNewGame(not autonewgame)
end
pshy.commands["autonewgame"] = {perms = "admins", func = ChatCommandAutonewgame, desc = "enable (or disable) TFM automatic map changes", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
help_pages["pshy_commands_room"].commands["autonewgame"] = pshy.commands["autonewgame"]



--- !autoshaman
local function ChatCommandAutoshaman(user, autoshaman)
	if autoshaman == nil then
		autoshaman = true
	end
	tfm.exec.disableAutoShaman(not autoshaman)
end
pshy.commands["autoshaman"] = {perms = "admins", func = ChatCommandAutoshaman, desc = "enable (or disable) TFM automatic shaman choice", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
help_pages["pshy_commands_room"].commands["autoshaman"] = pshy.commands["autoshaman"]



--- !autotimeleft
local function ChatCommandAutotimeleft(user, autotimeleft)
	if autotimeleft == nil then
		autotimeleft = true
	end
	tfm.exec.disableAutoTimeLeft(not autotimeleft)
end
pshy.commands["autotimeleft"] = {perms = "admins", func = ChatCommandAutotimeleft, desc = "enable (or disable) TFM automatic lowering of time", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
help_pages["pshy_commands_room"].commands["autotimeleft"] = pshy.commands["autotimeleft"]



--- !playerscore
local function ChatCommandPlayerscore(user, score, target)
	score = score or 0
	target = GetTarget(user, target, "!playerscore")
	tfm.exec.setPlayerScore(target, score, false)
end
pshy.commands["playerscore"] = {perms = "admins", func = ChatCommandPlayerscore, desc = "set the TFM score of a player in the scoreboard", argc_min = 0, argc_max = 2, arg_types = {"number", "player"}}
help_pages["pshy_commands_room"].commands["playerscore"] = pshy.commands["playerscore"]



--- !afkdeath
local function ChatCommandAfkdeath(user, afkdeath)
	if afkdeath == nil then
		afkdeath = true
	end
	tfm.exec.disableAfkDeath(not afkdeath)
end
pshy.commands["afkdeath"] = {perms = "admins", func = ChatCommandAfkdeath, desc = "enable (or disable) TFM's killing of AFK players", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
help_pages["pshy_commands_room"].commands["afkdeath"] = pshy.commands["afkdeath"]



--- !allowmort
local function ChatCommandMortcommand(user, allowmort)
	tfm.exec.disableMortCommand(not allowmort)
end
pshy.commands["allowmort"] = {perms = "admins", func = ChatCommandMortcommand, desc = "allow (or prevent) TFM's /mort command", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
help_pages["pshy_commands_room"].commands["allowmort"] = pshy.commands["allowmort"]



--- !allowwatch
local function ChatCommandWatchcommand(user, allowwatch)
	tfm.exec.disableWatchCommand(not allowwatch)
end 
pshy.commands["allowwatch"] = {perms = "admins", func = ChatCommandWatchcommand, desc = "allow (or prevent) TFM's /watch command", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
help_pages["pshy_commands_room"].commands["allowwatch"] = pshy.commands["allowwatch"]



--- !allowdebug
local function ChatCommandDebugcommand(user, allowdebug)
	tfm.exec.disableDebugCommand(not allowdebug)
end
pshy.commands["allowdebug"] = {perms = "admins", func = ChatCommandDebugcommand, desc = "allow (or prevent) TFM's /debug command", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
help_pages["pshy_commands_room"].commands["allowdebug"] = pshy.commands["allowdebug"]



--- !minimalist
local function ChatCommandMinimalist(user, debugcommand)
	tfm.exec.disableMinimalistMode(not debugcommand)
end
pshy.commands["minimalist"] = {perms = "admins", func = ChatCommandMinimalist, desc = "allow (or prevent) TFM's minimalist mode", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
help_pages["pshy_commands_room"].commands["minimalist"] = pshy.commands["minimalist"]



--- !consumables
local function ChatCommandAllowconsumables(user, consumables)
	tfm.exec.disablePshysicalConsumables(not consumables)
end
pshy.commands["consumables"] = {perms = "admins", func = ChatCommandAllowconsumables, desc = "allow (or prevent) the use of physical consumables", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
help_pages["pshy_commands_room"].commands["consumables"] = pshy.commands["consumables"]



--- !chatcommandsdisplay
local function ChatCommandChatcommandsdisplay(user, display)
	system.disableChatCommandDisplay(nil, not display)
end
pshy.commands["chatcommandsdisplay"] = {perms = "admins", func = ChatCommandChatcommandsdisplay, desc = "show (or hide) all chat commands", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
help_pages["pshy_commands_room"].commands["chatcommandsdisplay"] = pshy.commands["chatcommandsdisplay"]



--- !password <room_password>
local function ChatCommandPassword(user, pass)
	tfm.exec.setRoomPassword(pass)
	return true, "Password " .. (pass and "set" or "unset")
end
pshy.commands["password"] = {perms = "admins", func = ChatCommandPassword, desc = "set the room's password", argc_min = 0, argc_max = 1, arg_types = {"string"}}
help_pages["pshy_commands_room"].commands["password"] = pshy.commands["password"]



--- !mapflipmode
local function ChatCommandMapflipmode(user, mapflipmode)
	tfm.exec.setAutoMapFlipMode(mapflipmode)
end
pshy.commands["mapflipmode"] = {perms = "admins", func = ChatCommandMapflipmode, desc = "Set TFM to use mirrored maps (yes/no or no param for default)", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
help_pages["pshy_commands_room"].commands["mapflipmode"] = pshy.commands["mapflipmode"]



--- !shamanskills
local function ChatCommandShamanskills(user, shamanskills)
	if shamanskills == nil then
		shamanskills = true
	end
	tfm.exec.disableAllShamanSkills(not shamanskills)
end
pshy.commands["shamanskills"] = {perms = "admins", func = ChatCommandShamanskills, desc = "enable (or disable) TFM shaman's skills", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
help_pages["pshy_commands_room"].commands["shamanskills"] = pshy.commands["shamanskills"]



--- !autoscore
local function ChatCommandAutoscore(user, autoscore)
	if autoscore == nil then
		autoscore = true
	end
	tfm.exec.disableAutoScore(not autoscore)
end
pshy.commands["autoscore"] = {perms = "admins", func = ChatCommandAutoscore, desc = "enable (or disable) TFM score handling", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
help_pages["pshy_commands_room"].commands["autoscore"] = pshy.commands["autoscore"]



--- !prespawnpreview
local function ChatCommandPrespawnpreview(user, prespawnpreview)
	tfm.exec.disablePrespawnPreview(not prespawnpreview)
end
pshy.commands["prespawnpreview"] = {perms = "admins", func = ChatCommandPrespawnpreview, desc = "show (or hide) what the shaman is spawning", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
help_pages["pshy_commands_room"].commands["prespawnpreview"] = pshy.commands["prespawnpreview"]
