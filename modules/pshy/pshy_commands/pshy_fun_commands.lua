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
pshy.help_pages["pshy_fun_commands"] = {back = "pshy", title = "Fun Commands", text = "Adds fun commands everyone can use.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_fun_commands"] = pshy.help_pages["pshy_fun_commands"]



--- Internal use:
pshy.fun_commands_link_wishes = {}	-- map of player names requiring a link to another one
pshy.fun_commands_flyers = {}		-- flying players
pshy.fun_commands_speedies = {}	-- speedy players

--pshy.FindPlayerNameOrError(partial_name)


--- Get the target of the command, throwing on permission issue
-- @private
function pshy.fun_commands_GetTarget(user, target, perm_prefix)
	assert(type(perm_prefix) == "string")
	if not target then
		return user
	end
	target = pshy.FindPlayerNameOrError(target)
	if target == user then
		return user
	elseif not pshy.HavePerm(user, perm_prefix .. "-others") then
		error("you cant use this command on other players :c")
		return
	elseif not tfm.get.room.playerList[target] then
		error("the target player is not in the room")
		return
	end
	return target
end




--- !shaman
function pshy.ChatCommandShaman(user, target)
	target = pshy.fun_commands_GetTarget(user, target, "!shaman")
	tfm.exec.setShaman(target, not tfm.get.room.playerList[target].isShaman)
end
pshy.chat_commands["shaman"] = {func = pshy.ChatCommandShaman, desc = "switch you to a shaman", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["shaman"] = pshy.chat_commands["shaman"]
pshy.perms.everyone["!shaman"] = false



--- !vampire
function pshy.ChatCommandVampire(user, target)
	target = pshy.fun_commands_GetTarget(user, target, "!vampire")
	tfm.exec.setVampirePlayer(target, not tfm.get.room.playerList[target].isVampire)
end
pshy.chat_commands["vampire"] = {func = pshy.ChatCommandVampire, desc = "switch you to a vampire", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["vampire"] = pshy.chat_commands["vampire"]
pshy.perms.everyone["!vampire"] = false



--- !cheese
function pshy.ChatCommandCheese(user, target)
	target = pshy.fun_commands_GetTarget(user, target, "!cheese")
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
	target = pshy.fun_commands_GetTarget(user, target, "!freeze")
	tfm.exec.freezePlayer(target, true)
end
pshy.chat_commands["freeze"] = {func = pshy.ChatCommandFreeze, desc = "freeze yourself", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["freeze"] = pshy.chat_commands["freeze"]
pshy.perms.everyone["!freeze"] = true



--- !kill
function pshy.ChatCommandKill(user, target)
	target = pshy.fun_commands_GetTarget(user, target, "!kill")
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
	target = pshy.fun_commands_GetTarget(user, target, "!win")
	tfm.exec.playerVictory(target)
end
pshy.chat_commands["win"] = {func = pshy.ChatCommandWin, desc = "play the win animation", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["win"] = pshy.chat_commands["win"]
pshy.perms.everyone["!win"] = true



--- !colorpicker
function pshy.ChatCommandColorpicker(user, target)
	target = pshy.fun_commands_GetTarget(user, target, "!colorpicker")
	ui.showColorPicker(49, target, 0, "Get a color code:")
end 
pshy.chat_commands["colorpicker"] = {func = pshy.ChatCommandColorpicker, desc = "show the colorpicker", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["colorpicker"] = pshy.chat_commands["colorpicker"]
pshy.perms.everyone["!colorpicker"] = true



--- !fly
function pshy.ChatCommandFly(user, target)
	target = pshy.fun_commands_GetTarget(user, target, "!fly")
	if not pshy.fun_commands_flyers[target] then
		pshy.fun_commands_flyers[target] = true
		tfm.exec.bindKeyboard(target, 1, true, true)
		tfm.exec.bindKeyboard(target, 1, false, true)
		tfm.exec.chatMessage("[FunCommands] Jump to swing your wings!", target)
	else
		pshy.fun_commands_flyers[target] = nil
		tfm.exec.chatMessage("[FunCommands] Your feet are happy again.", target)
	end
end 
pshy.chat_commands["fly"] = {func = pshy.ChatCommandFly, desc = "yeah", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["fly"] = pshy.chat_commands["fly"]
pshy.perms.everyone["!fly"] = true



--- !speed
function pshy.ChatCommandSpeed(user, target)
	target = pshy.fun_commands_GetTarget(user, target, "!speed")
	if not pshy.fun_commands_speedies[target] then
		pshy.fun_commands_speedies[target] = true
		tfm.exec.bindKeyboard(target, 0, true, true)
		tfm.exec.bindKeyboard(target, 2, true, true)
		tfm.exec.chatMessage("[FunCommands] You now feel like sonic!", target)
	else
		pshy.fun_commands_speedies[target] = nil
		tfm.exec.chatMessage("[FunCommands] You are back to turtle speed.", target)
	end
end 
pshy.chat_commands["speed"] = {func = pshy.ChatCommandSpeed, desc = "makes you accel faster", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["speed"] = pshy.chat_commands["speed"]
pshy.perms.everyone["!speed"] = true



--- !action
function pshy.ChatCommandAction(user, action)
	tfm.exec.chatMessage("<v>" .. user .. "</v> <n>" .. action .. "</n>")
end 
pshy.chat_commands["action"] = {func = pshy.ChatCommandAction, desc = "send a rp-like/action message", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["action"] = pshy.chat_commands["action"]
pshy.perms.everyone["!action"] = false



--- !balloon
function pshy.ChatCommandBalloon(user, target)
	target = pshy.fun_commands_GetTarget(user, target, "!balloon")
	tfm.exec.attachBalloon(target, true, math.random(1, 4), true)
end 
pshy.chat_commands["balloon"] = {func = pshy.ChatCommandBalloon, desc = "attach a balloon to yourself", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["balloon"] = pshy.chat_commands["balloon"]
pshy.perms.everyone["!balloon"] = false



--- !size <n>
function pshy.ChatCommandSize(user, size, target)
	assert(size >= 0.2, "minimum size is 0.2")
	assert(size <= 5, "maximum size is 5")
	target = pshy.fun_commands_GetTarget(user, target, "!size")
	tfm.exec.changePlayerSize(target, size)
end 
pshy.chat_commands["size"] = {func = pshy.ChatCommandSize, desc = "change your size", argc_min = 1, argc_max = 2, arg_types = {"number", "string"}}
pshy.help_pages["pshy_fun_commands"].commands["size"] = pshy.chat_commands["size"]
pshy.perms.everyone["!size"] = true



--- !namecolor
function pshy.ChatCommandNamecolor(user, color, target)
	target = pshy.fun_commands_GetTarget(user, target, "!namecolor")
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
	target = pshy.fun_commands_GetTarget(user, target, "!link")
	if wish == "off" then
		tfm.exec.linkMice(target, target, false)
		return
	else
		wish = pshy.FindPlayerNameOrError(wish)
		pshy.fun_commands_link_wishes[target] = wish
	end
	if wish == target then
		tfm.exec.linkMice(target, wish, false)
	elseif pshy.fun_commands_link_wishes[wish] == target or user ~= target then
		tfm.exec.linkMice(target, wish, true)
	end
end 
pshy.chat_commands["link"] = {func = pshy.ChatCommandLink, desc = "attach yourself to another player ('off' to stop)", argc_min = 1, argc_max = 2, arg_types = {"string", "string"}}
pshy.help_pages["pshy_fun_commands"].commands["link"] = pshy.chat_commands["link"]
pshy.perms.everyone["!link"] = true



--- !tpp (teleport to player)
function pshy.ChatCommandTeleport(user, destination, target)
	target = pshy.fun_commands_GetTarget(user, target, "!tpp")
	destination = pshy.FindPlayerNameOrError(destination)
	tfm.exec.movePlayer(target, tfm.get.room.list[destination].x, tfm.get.room.list[destination].y, false, 0, 0, true)
end
pshy.chat_commands["tpp"] = {func = pshy.ChatCommandLink, desc = "teleport to a player", argc_min = 1, argc_max = 2, arg_types = {"string", "string", "string"}, arg_names = {"destination", "target"}}
pshy.help_pages["pshy_fun_commands"].commands["tpp"] = pshy.chat_commands["tpp"]
pshy.perms.everyone["!tpp"] = true



--- !tpl (teleport to location)
function pshy.ChatCommandTeleport(user, x, y, target)
	tfm.exec.movePlayer(target, x, y, false, 0, 0, true)
end
pshy.chat_commands["tpl"] = {func = pshy.ChatCommandLink, desc = "teleport to location", argc_min = 2, argc_max = 3, arg_types = {"number", "number", "string"}}
pshy.help_pages["pshy_fun_commands"].commands["tpl"] = pshy.chat_commands["tpl"]
pshy.perms.everyone["!tpl"] = true



--- Disable commands that may give an advantage.
function pshy.fun_commands_DisableCheatCommands()
	pshy.perms.everyone["!balloon"] = false
	pshy.perms.everyone["!cheese"] = false
	pshy.perms.everyone["!fly"] = false
	pshy.perms.everyone["!gravity"] = false
	pshy.perms.everyone["!kill"] = false
	pshy.perms.everyone["!link"] = false
	pshy.perms.everyone["!tpp"] = false
	pshy.perms.everyone["!tpl"] = false
	pshy.perms.everyone["!shaman"] = false
	pshy.perms.everyone["!size"] = false
	pshy.perms.everyone["!speed"] = false
	pshy.perms.everyone["!vampire"] = false
	pshy.perms.everyone["!win"] = false
end



--- TFM event eventkeyboard
function eventKeyboard(player_name, key_code, down, x, y)
	if key_code == 1 and down and pshy.fun_commands_flyers[player_name] then
		tfm.exec.movePlayer(player_name, 0, 0, true, 0, -55, false)
	elseif key_code == 0 and down and pshy.fun_commands_speedies[player_name] then
		tfm.exec.movePlayer(player_name, 0, 0, true, -50, 0, true)
	elseif key_code == 2 and down and pshy.fun_commands_speedies[player_name] then
		tfm.exec.movePlayer(player_name, 0, 0, true, 50, 0, true)
	end
end



--- Initialization:
