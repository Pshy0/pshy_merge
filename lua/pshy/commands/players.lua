--- pshy.commands.players
--
-- Adds fun commands everyone can use.
-- Expected to be used in chill rooms, such as villages.
--
-- Disable cheat commands with `pshy.commands_fun_DisableCheatCommands()`.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.bases.doc")
local help_pages = pshy.require("pshy.help.pages")
local utils_tfm = pshy.require("pshy.utils.tfm")



--- Module Help Page:
help_pages["pshy_commands_players"] = {back = "pshy", title = "Mice", commands = {}}
help_pages["pshy"].subpages["pshy_commands_players"] = help_pages["pshy_commands_players"]



--- Internal use:
local link_wishes = {}			-- map of player names requiring a link to another one
local players_balloon_id = {}



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.commands_GetTargetOrError



--- !shaman
local function ChatCommandShaman(user, value, target)
	target = GetTarget(user, target, "!shaman")
	if value == nil then
		value = not tfm.get.room.playerList[target].isShaman
	end
	tfm.exec.setShaman(target, value)
	return true, string.format("%s %s", target, value and "is now a shaman." or "is no longer a shaman.")
end
pshy.commands["shaman"] = {perms = "cheats", func = ChatCommandShaman, desc = "switch you to a shaman", argc_min = 0, argc_max = 2, arg_types = {"bool", "player"}, arg_names = {"on/off"}}
help_pages["pshy_commands_players"].commands["shaman"] = pshy.commands["shaman"]



--- !shamanmode
local function ChatCommandShamanmode(user, mode, target)
	target = GetTarget(user, target, "!shamanmode")
	if mode ~= 0 and mode ~= 1 and mode ~= 2 then
		return false, "Mode must be 0 (normal), 1 (hard) or 2 (divine)."		
	end
	tfm.exec.setShaman(target, value)
	return true, string.format("Set %s's shaman mode to %d.", target, mode)
end
pshy.commands["shamanmode"] = {perms = "cheats", func = ChatCommandShamanmode, desc = "choose your shaman mode (0/1/2)", argc_min = 0, argc_max = 2, arg_types = {"number", "player"}}
help_pages["pshy_commands_players"].commands["shamanmode"] = pshy.commands["shamanmode"]



--- !vampire
local function ChatCommandVampire(user, value, target)
	target = GetTarget(user, target, "!vampire")
	if value == nil then
		value = not tfm.get.room.playerList[target].isVampire
	end
	tfm.exec.setVampirePlayer(target, value)
	return true, string.format("%s %s", target, value and "is now a vampire." or "is no longer a vampire.")
end
pshy.commands["vampire"] = {perms = "cheats", func = ChatCommandVampire, desc = "switch you to a vampire", argc_min = 0, argc_max = 2, arg_types = {"bool", "player"}, arg_names = {"on/off"}}
help_pages["pshy_commands_players"].commands["vampire"] = pshy.commands["vampire"]



--- !cheese
local function ChatCommandCheese(user, value, target)
	target = GetTarget(user, target, "!cheese")
	if value == nil then
		value = not tfm.get.room.playerList[target].hasCheese
	end
	if value then
		tfm.exec.giveCheese(target)
	else
		tfm.exec.removeCheese(target)
	end
	return true, string.format("%s %s", target, value and "now have the cheese." or "do no longer have the cheese.")
end
pshy.commands["cheese"] = {perms = "cheats", func = ChatCommandCheese, desc = "toggle your cheese", argc_min = 0, argc_max = 2, arg_types = {"bool", "player"}, arg_names = {"yes/no"}}
help_pages["pshy_commands_players"].commands["cheese"] = pshy.commands["cheese"]



--- !win
local function ChatCommandWin(user, target)
	target = GetTarget(user, target, "!win")
	tfm.exec.giveCheese(target)
	tfm.exec.playerVictory(target)
	return true, string.format("%s won.", target)
end
pshy.commands["win"] = {aliases = {"victory"}, perms = "cheats", func = ChatCommandWin, desc = "play the win animation", argc_min = 0, argc_max = 1, arg_types = {"player"}}
help_pages["pshy_commands_players"].commands["win"] = pshy.commands["win"]



--- !kill
local function ChatCommandKill(user, target)
	target = GetTarget(user, target, "!kill")
	tfm.exec.killPlayer(target)
	return true, string.format("%s killed.", target)
end
pshy.commands["kill"] = {perms = "cheats", func = ChatCommandKill, desc = "kill yourself", argc_min = 0, argc_max = 1, arg_types = {"player"}}
help_pages["pshy_commands_players"].commands["kill"] = pshy.commands["kill"]



--- !respawn
local function ChatCommandRespawn(user, target)
	target = GetTarget(user, target, "!respawn")
	tfm.exec.respawnPlayer(target)
	return true, string.format("%s respawned.", target)
end
pshy.commands["respawn"] = {perms = "cheats", func = ChatCommandRespawn, desc = "resurect yourself", argc_min = 0, argc_max = 1, arg_types = {"player"}}
help_pages["pshy_commands_players"].commands["respawn"] = pshy.commands["respawn"]



--- !freeze
local function ChatCommandFreeze(user, value, target)
	target = GetTarget(user, target, "!freeze")
	tfm.exec.freezePlayer(target, value)
	return true, string.format("%s %d", target, value and "frozen." or "no longer frozen.")
end
pshy.commands["freeze"] = {perms = "cheats", func = ChatCommandFreeze, desc = "freeze yourself", argc_min = 1, argc_max = 2, arg_types = {"bool", "player"}, arg_names = {"yes/no"}}
help_pages["pshy_commands_players"].commands["freeze"] = pshy.commands["freeze"]



--- !size <n>
local function ChatCommandSize(user, size, target)
	if size < 0.2 then
		return false, "The minimum size is `0.2`."
	end
	if size > 5 then
		return false, "The maximum size is `5`."
	end
	assert(size >= 0.2, "minimum size is 0.2")
	assert(size <= 5, "maximum size is 5")
	target = GetTarget(user, target, "!size")
	tfm.exec.changePlayerSize(target, size)
	return true, string.format("%s'size changed to %f.", target, size)
end 
pshy.commands["size"] = {perms = "cheats", func = ChatCommandSize, desc = "change your size", argc_min = 1, argc_max = 2, arg_types = {"number", "player"}}
help_pages["pshy_commands_players"].commands["size"] = pshy.commands["size"]



--- !namecolor
local function ChatCommandNamecolor(user, color, target)
	target = GetTarget(user, target, "!namecolor")
	tfm.exec.setNameColor(target, color)
	return true, string.format("%s'name color is now <font color='#%06x'>#%06x</font>.", target, color, color)
end 
pshy.commands["namecolor"] = {perms = "cheats", func = ChatCommandNamecolor, desc = "change your name's color", argc_min = 1, argc_max = 2, arg_types = {"color", "player"}}
help_pages["pshy_commands_players"].commands["namecolor"] = pshy.commands["namecolor"]



--- !balloon
local function ChatCommandBalloon(user, target)
	target = GetTarget(user, target, "!balloon")
	if players_balloon_id[target] then
		tfm.exec.removeObject(players_balloon_id[target])
		players_balloon_id[target] = nil
	end
	players_balloon_id[target] = tfm.exec.attachBalloon(target, true, math.random(1, 4), true)
	return true, string.format("Attached a balloon to %s.", target)
end 
pshy.commands["balloon"] = {perms = "cheats", func = ChatCommandBalloon, desc = "attach a balloon to yourself", argc_min = 0, argc_max = 1, arg_types = {"player"}}
help_pages["pshy_commands_players"].commands["balloon"] = pshy.commands["balloon"]



--- !link
local function ChatCommandLink(user, wish, target)
	target = GetTarget(user, target, "!link")
	if wish == nil then
		tfm.exec.linkMice(target, target, false)
	else
		wish = utils_tfm.FindPlayerNameOrError(wish)
		link_wishes[target] = wish
	end
	if wish == target then
		tfm.exec.linkMice(target, wish, false)
		return true, "Unlinked."
	elseif link_wishes[wish] == target or user ~= target then
		tfm.exec.linkMice(target, wish, true)
		return true, "Linked."
	end
end 
pshy.commands["link"] = {perms = "cheats", func = ChatCommandLink, desc = "attach yourself to another player (yourself to stop)", argc_min = 1, argc_max = 2, arg_types = {"player", "player"}}
help_pages["pshy_commands_players"].commands["link"] = pshy.commands["link"]
