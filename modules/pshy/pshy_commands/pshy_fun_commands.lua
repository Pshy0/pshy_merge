--- pshy_fun_commands.lua
--
-- Adds fun commands everyone can use.
-- Expected to be used in chill rooms, such as villages.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_perms.lua



--- Module Help Page:
pshy.help_pages["pshy_fun_commands"] = {back = "pshy", text = "Adds fun commands everyone can use.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_fun_commands"] = pshy.help_pages["pshy_fun_commands"]



--- Internal use:
pshy.fun_commands_link_wishes = {}	-- map of player names requiring a link to another one



--- !shaman
function pshy.ChatCommandShaman(user, target)
	if not target then
		target = user
	elseif not pshy.HavePerm(user, "!shaman others") then
		error("You are not allowed to use this command on others :c")
		return
	elseif not tfm.get.room.playerList[target] then
		error("This player is not in the room.")
		return
	end
	tfm.exec.setShaman(target, not tfm.get.room.playerList[target].isShaman)
end
pshy.chat_commands["shaman"] = {func = pshy.ChatCommandShaman, desc = "switch you to a shaman", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["shaman"] = pshy.chat_commands["shaman"]
pshy.perms.everyone["!shaman"] = false



--- !vampire
function pshy.ChatCommandVampire(user, target)
	if not target then
		target = user
	elseif not pshy.HavePerm(user, "!vampire others") then
		error("You are not allowed to use this command on others :c")
		return
	elseif not tfm.get.room.playerList[target] then
		error("This player is not in the room.")
		return
	end
	tfm.exec.setVampirePlayer(target, not tfm.get.room.playerList[target].isVampire)
end
pshy.chat_commands["vampire"] = {func = pshy.ChatCommandVampire, desc = "switch you to a vampire", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["vampire"] = pshy.chat_commands["vampire"]
pshy.perms.everyone["!vampire"] = true



--- !cheese
function pshy.ChatCommandCheese(user, target)
	if not target then
		target = user
	elseif not pshy.HavePerm(user, "!cheese others") then
		error("You are not allowed to use this command on others :c")
		return
	elseif not tfm.get.room.playerList[target] then
		error("This player is not in the room.")
		return
	end
	if not tfm.get.room.playerList[target].hasCheese then
		tfm.exec.giveCheese(target)
	else
		tfm.exec.removeCheese(target)
	end
end
pshy.chat_commands["cheese"] = {func = pshy.ChatCommandCheese, desc = "toggle your cheese", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["cheese"] = pshy.chat_commands["cheese"]
pshy.perms.everyone["!cheese"] = true



--- !freeze
function pshy.ChatCommandFreeze(user, target)
	if not target then
		target = user
	elseif not pshy.HavePerm(user, "!freeze others") then
		error("You are not allowed to use this command on others :c")
		return
	elseif not tfm.get.room.playerList[target] then
		error("This player is not in the room.")
		return
	end
	tfm.exec.freezePlayer(target, true)
end
pshy.chat_commands["freeze"] = {func = pshy.ChatCommandFreeze, desc = "freeze yourself", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["freeze"] = pshy.chat_commands["freeze"]
pshy.perms.everyone["!freeze"] = true



--- !kill
function pshy.ChatCommandKill(user, target)
	if not target then
		target = user
	elseif not pshy.HavePerm(user, "!kill others") then
		error("You are not allowed to use this command on others :c")
		return
	elseif not tfm.get.room.playerList[target] then
		error("This player is not in the room.")
		return
	end
	if not tfm.get.room.playerList[target].isDead then
		tfm.exec.killPlayer(target)
	else
		tfm.exec.respawnPlayer(target)
	end
end
pshy.chat_commands["kill"] = {func = pshy.ChatCommandKill, desc = "kill or resurect yourself", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["kill"] = pshy.chat_commands["kill"]
pshy.perms.everyone["!kill"] = true



--- !win
function pshy.ChatCommandWin(user, target)
	if not target then
		target = user
	elseif not pshy.HavePerm(user, "!win others") then
		error("You are not allowed to use this command on others :c")
		return
	elseif not tfm.get.room.playerList[target] then
		error("This player is not in the room.")
		return
	end
	tfm.exec.playerVictory(target)
end
pshy.chat_commands["win"] = {func = pshy.ChatCommandWin, desc = "play the win animation", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["win"] = pshy.chat_commands["win"]
pshy.perms.everyone["!win"] = true



--- !colorpicker
function pshy.ChatCommandColorpicker(user)
	if not target then
		target = user
	elseif not pshy.HavePerm(user, "!colorpicker others") then
		error("You are not allowed to use this command on others :c")
		return
	elseif not tfm.get.room.playerList[target] then
		error("This player is not in the room.")
		return
	end
	ui.showColorPicker(49, target, 0, nil)
end 
pshy.chat_commands["colorpicker"] = {func = pshy.ChatCommandColorpicker, desc = "show the colorpicker", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["colorpicker"] = pshy.chat_commands["colorpicker"]
pshy.perms.everyone["!colorpicker"] = true



--- !action
function pshy.ChatCommandAction(user, action)
	tfm.exec.chatmessage("*" .. user .. " " .. action .. "*")
end 
pshy.chat_commands["action"] = {func = pshy.ChatCommandAction, desc = "send a rp-like/action message", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["action"] = pshy.chat_commands["action"]
pshy.perms.everyone["!action"] = true



--- !balloon
function pshy.ChatCommandBalloon(user, target)
	if not target then
		target = user
	elseif not pshy.HavePerm(user, "!balloon others") then
		error("You are not allowed to use this command on others :c")
		return
	elseif not tfm.get.room.playerList[target] then
		error("This player is not in the room.")
		return
	end
	tfm.exec.attachBalloon(target, true, math.random(1, 4), true)
end 
pshy.chat_commands["balloon"] = {func = pshy.ChatCommandBalloon, desc = "attach a balloon to yourself", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["balloon"] = pshy.chat_commands["balloon"]
pshy.perms.everyone["!balloon"] = false



--- !size <n>
function pshy.ChatCommandSize(user, size, target)
	if not target then
		target = user
	elseif not pshy.HavePerm(user, "!size others") then
		error("You are not allowed to use this command on others :c")
		return
	elseif not tfm.get.room.playerList[target] then
		error("This player is not in the room.")
		return
	end
	tfm.exec.changePlayerSize(target, size)
end 
pshy.chat_commands["size"] = {func = pshy.ChatCommandSize, desc = "change your size", argc_min = 1, argc_max = 2, arg_types = {"number", "string"}}
pshy.help_pages["pshy_fun_commands"].commands["size"] = pshy.chat_commands["size"]
pshy.perms.everyone["!size"] = true



--- !namecolor
function pshy.ChatCommandNamecolor(user, color, target)
	if not target then
		target = user
	elseif not pshy.HavePerm(user, "!size others") then
		error("You are not allowed to use this command on others :c")
		return
	elseif not tfm.get.room.playerList[target] then
		error("This player is not in the room.")
		return
	end
	tfm.exec.setNameColor(target, color)
end 
pshy.chat_commands["namecolor"] = {func = pshy.ChatCommandNamecolor, desc = "change your name's color", argc_min = 1, argc_max = 2, arg_types = {nil, "string"}}
pshy.help_pages["pshy_fun_commands"].commands["namecolor"] = pshy.chat_commands["namecolor"]
pshy.perms.everyone["!namecolor"] = true



--- !gravity
function pshy.ChatCommandGravity(user, value)
	tfm.exec.setWorldGravity(0, value)
end 
pshy.chat_commands["gravity"] = {func = pshy.ChatCommandGravity, desc = "change the gravity", argc_min = 1, argc_max = 1, arg_types = {"number"}}
pshy.help_pages["pshy_fun_commands"].commands["gravity"] = pshy.chat_commands["gravity"]



--- !link
function pshy.ChatCommandLink(user, wish, target)
	if not target then
		target = user
		pshy.fun_commands_link_wishes[user] = wish
	elseif not pshy.HavePerm(user, "!link others") then
		error("You are not allowed to use this command on others :c")
		return
	elseif not tfm.get.room.playerList[target] then
		error("This player is not in the room.")
		return
	end
	if not wish then
		-- delete link
		tfm.exec.linkMice(target, target, true)
	end
	if pshy.fun_commands_link_wishes[wish] == target or user ~= target then 
		tfm.exec.linkMice(target, wish, true)
	end
end 
pshy.chat_commands["link"] = {func = pshy.ChatCommandLink, desc = "attach yourself to another player (if they want too)", argc_min = 1, argc_max = 2, arg_types = {"string", "string"}}
pshy.help_pages["pshy_fun_commands"].commands["link"] = pshy.chat_commands["link"]
pshy.perms.everyone["!link"] = true



--- Initialization:
tfm.exec.disableAllShamanSkills(true)	-- avoid skills induced lags
tfm.exec.disableAutoNewGame(true)	-- you probably dont want this script with AutonewGame
tfm.exec.disableAutoShaman(disable)	-- you probably dont want this script with AutonewShaman
tfm.exec.disableAutoTimeLeft(true)
