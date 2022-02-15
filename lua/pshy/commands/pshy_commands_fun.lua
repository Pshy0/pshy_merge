--- pshy_commands_fun.lua
--
-- Adds fun commands everyone can use.
-- Expected to be used in chill rooms, such as villages.
--
-- Disable cheat commands with `pshy.commands_fun_DisableCheatCommands()`.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_perms.lua
--
-- @require_priority UTILS



--- Module Help Page:
pshy.help_pages["pshy_commands_fun"] = {back = "pshy", title = "Fun Commands", text = "Adds fun commands everyone can use.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_commands_fun"] = pshy.help_pages["pshy_commands_fun"]



--- Internal use:
local fun_link_wishes = {}	-- map of player names requiring a link to another one
local players_balloon_id = {}



--- Get the target of the command, throwing on permission issue.
-- @private
function pshy.commands_fun_GetTarget(user, target, perm_prefix)
	assert(type(perm_prefix) == "string")
	if not target then
		return user
	end
	if target == user then
		return user
	elseif not pshy.HavePerm(user, perm_prefix .. "-others") then
		error("you cant use this command on other players :c")
		return
	end
	return target
end



--- !shaman
local function ChatCommandShaman(user, value, target)
	target = pshy.commands_fun_GetTarget(user, target, "!shaman")
	if value == nil then
		value = not tfm.get.room.playerList[target].isShaman
	end
	tfm.exec.setShaman(target, value)
	return true, string.format("%s %s", target, value and "is now a shaman." or "is no longer a shaman.")
end
pshy.commands["shaman"] = {func = ChatCommandShaman, desc = "switch you to a shaman", argc_min = 0, argc_max = 2, arg_types = {"bool", "player"}}
pshy.help_pages["pshy_commands_fun"].commands["shaman"] = pshy.commands["shaman"]
pshy.perms.admins["!shaman"] = true
pshy.perms.admins["!shaman-others"] = true
pshy.commands_aliases["sham"] = "shaman"



--- !shamanmode
local function ChatCommandShamanmode(user, mode, target)
	target = pshy.commands_fun_GetTarget(user, target, "!shamanmode")
	if mode ~= 0 and mode ~= 1 and mode ~= 2 then
		return false, "Mode must be 0 (normal), 1 (hard) or 2 (divine)."		
	end
	tfm.exec.setShaman(target, value)
	return true, string.format("Set %s's shaman mode to %d.", target, mode)
end
pshy.commands["shamanmode"] = {func = ChatCommandShamanmode, desc = "choose your shaman mode (0/1/2)", argc_min = 0, argc_max = 2, arg_types = {"number", "player"}}
pshy.help_pages["pshy_commands_fun"].commands["shamanmode"] = pshy.commands["shamanmode"]
pshy.perms.admins["!shamanmode"] = true
pshy.perms.admins["!shamanmode-others"] = true



--- !vampire
local function ChatCommandVampire(user, value, target)
	target = pshy.commands_fun_GetTarget(user, target, "!vampire")
	if value == nil then
		value = not tfm.get.room.playerList[target].isVampire
	end
	tfm.exec.setVampirePlayer(target, value)
	return true, string.format("%s %s", target, value and "is now a vampire." or "is no longer a vampire.")
end
pshy.commands["vampire"] = {func = ChatCommandVampire, desc = "switch you to a vampire", argc_min = 0, argc_max = 2, arg_types = {"bool", "player"}}
pshy.help_pages["pshy_commands_fun"].commands["vampire"] = pshy.commands["vampire"]
pshy.perms.admins["!vampire"] = true
pshy.perms.admins["!vampire-others"] = true



--- !cheese
local function ChatCommandCheese(user, value, target)
	target = pshy.commands_fun_GetTarget(user, target, "!cheese")
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
pshy.commands["cheese"] = {func = ChatCommandCheese, desc = "toggle your cheese", argc_min = 0, argc_max = 2, arg_types = {"bool", "player"}}
pshy.help_pages["pshy_commands_fun"].commands["cheese"] = pshy.commands["cheese"]
pshy.perms.cheats["!cheese"] = true
pshy.perms.admins["!cheese-others"] = true



--- !win
local function ChatCommandWin(user, target)
	target = pshy.commands_fun_GetTarget(user, target, "!win")
	tfm.exec.giveCheese(target)
	tfm.exec.playerVictory(target)
	return true, string.format("%s won.", target)
end
pshy.commands["win"] = {func = ChatCommandWin, desc = "play the win animation", argc_min = 0, argc_max = 1, arg_types = {"player"}}
pshy.help_pages["pshy_commands_fun"].commands["win"] = pshy.commands["win"]
pshy.perms.cheats["!win"] = true
pshy.perms.admins["!win-others"] = true



--- !kill
local function ChatCommandKill(user, target)
	target = pshy.commands_fun_GetTarget(user, target, "!kill")
	tfm.exec.killPlayer(target)
	return true, string.format("%s killed.", target)
end
pshy.commands["kill"] = {func = ChatCommandKill, desc = "kill yourself", argc_min = 0, argc_max = 1, arg_types = {"player"}}
pshy.help_pages["pshy_commands_fun"].commands["kill"] = pshy.commands["kill"]
pshy.perms.cheats["!kill"] = true
pshy.perms.admins["!kill-others"] = true



--- !respawn
local function ChatCommandRespawn(user, target)
	target = pshy.commands_fun_GetTarget(user, target, "!respawn")
	tfm.exec.respawnPlayer(target)
	return true, string.format("%s respawned.", target)
end
pshy.commands["respawn"] = {func = ChatCommandRespawn, desc = "resurect yourself", argc_min = 0, argc_max = 1, arg_types = {"player"}}
pshy.help_pages["pshy_commands_fun"].commands["respawn"] = pshy.commands["respawn"]
pshy.commands_aliases["resurect"] = "respawn"
pshy.perms.cheats["!respawn"] = true
pshy.perms.admins["!respawn-others"] = true



--- !freeze
local function ChatCommandFreeze(user, value, target)
	target = pshy.commands_fun_GetTarget(user, target, "!freeze")
	tfm.exec.freezePlayer(target, value)
	return true, string.format("%s %d", target, value and "frozen." or "no longer frozen.")
end
pshy.commands["freeze"] = {func = ChatCommandFreeze, desc = "freeze yourself", argc_min = 1, argc_max = 2, arg_types = {"bool", "player"}}
pshy.help_pages["pshy_commands_fun"].commands["freeze"] = pshy.commands["freeze"]
pshy.perms.cheats["!freeze"] = true
pshy.perms.admins["!freeze-others"] = true



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
	target = pshy.commands_fun_GetTarget(user, target, "!size")
	tfm.exec.changePlayerSize(target, size)
	return true, string.format("%s'size changed to %f.", target, size)
end 
pshy.commands["size"] = {func = ChatCommandSize, desc = "change your size", argc_min = 1, argc_max = 2, arg_types = {"number", "player"}}
pshy.help_pages["pshy_commands_fun"].commands["size"] = pshy.commands["size"]
pshy.perms.cheats["!size"] = true
pshy.perms.admins["!size-others"] = true



--- !namecolor
local function ChatCommandNamecolor(user, color, target)
	target = pshy.commands_fun_GetTarget(user, target, "!namecolor")
	tfm.exec.setNameColor(target, color)
	return true, string.format("%s'name color is now <font color='#%06x'>#%06x</font>.", target, color, color)
end 
pshy.commands["namecolor"] = {func = ChatCommandNamecolor, desc = "change your name's color", argc_min = 1, argc_max = 2, arg_types = {nil, "player"}}
pshy.help_pages["pshy_commands_fun"].commands["namecolor"] = pshy.commands["namecolor"]
pshy.perms.cheats["!namecolor"] = true
pshy.perms.admins["!namecolor-others"] = true



--- !action
local function ChatCommandAction(user, action)
	tfm.exec.chatMessage("<v>" .. user .. "</v> <n>" .. action .. "</n>")
	return true
end 
pshy.commands["action"] = {func = ChatCommandAction, desc = "send a rp-like/action message", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_commands_fun"].commands["action"] = pshy.commands["action"]



--- !say
local function ChatCommandSay(user, message)
	tfm.exec.chatMessage("<v>[" .. user .. "]</v> <n>" .. message .. "</n>")
	return true
end 
pshy.commands["say"] = {func = ChatCommandSay, desc = "say something", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_commands_fun"].commands["say"] = pshy.commands["say"]
pshy.perms.everyone["!say"] = true



--- !balloon
local function ChatCommandBalloon(user, target)
	target = pshy.commands_fun_GetTarget(user, target, "!balloon")
	if players_balloon_id[target] then
		tfm.exec.removeObject(players_balloon_id[target])
		players_balloon_id[target] = nil
	end
	players_balloon_id[target] = tfm.exec.attachBalloon(target, true, math.random(1, 4), true)
	return true, string.format("Attached a balloon to %s.", target)
end 
pshy.commands["balloon"] = {func = ChatCommandBalloon, desc = "attach a balloon to yourself", argc_min = 0, argc_max = 1, arg_types = {"player"}}
pshy.help_pages["pshy_commands_fun"].commands["balloon"] = pshy.commands["balloon"]
pshy.perms.cheats["!balloon"] = true
pshy.perms.admins["!balloon-others"] = true



--- !link
local function ChatCommandLink(user, wish, target)
	target = pshy.commands_fun_GetTarget(user, target, "!link")
	if wish == nil then
		tfm.exec.linkMice(target, target, false)
	else
		wish = pshy.FindPlayerNameOrError(wish)
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
pshy.commands["link"] = {func = ChatCommandLink, desc = "attach yourself to another player (yourself to stop)", argc_min = 0, argc_max = 2, arg_types = {"player", "player"}}
pshy.help_pages["pshy_commands_fun"].commands["link"] = pshy.commands["link"]
pshy.perms.cheats["!link"] = true
pshy.perms.admins["!link-others"] = true
