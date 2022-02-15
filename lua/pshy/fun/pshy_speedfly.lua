--- pshy_speedfly.lua
--
-- Fly, speed boost, and teleport features.
--
-- @author DC:Pshy#7998 TFM:Pshy#3752
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_help.lua
--
-- @require_priority UTILS


--- Module Help Page:
pshy.help_pages["pshy_speedfly"] = {back = "pshy", title = "Speed / Fly / Teleport", text = "Fly and speed boost.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_speedfly"] = pshy.help_pages["pshy_speedfly"]



--- Settings:
pshy.speedfly_reset_on_new_game = true



--- Internal Use:
local flyers = {}		-- flying players
local speedies = {}		-- speedy players (value is the speed)



--- Give speed to a player.
function pshy.speedfly_Speed(player_name, speed)
	if speed == nil then
		speed = 20
	end
	if speed <= 1 or speed == false or speed == speedies[player_name]then
		speedies[player_name] = nil
		tfm.exec.chatMessage("<i><ch2>You are back to turtle speed.</ch2></i>", player_name)
	else
		speedies[player_name] = speed
		tfm.exec.bindKeyboard(player_name, 0, true, true)
		tfm.exec.bindKeyboard(player_name, 2, true, true)
		tfm.exec.chatMessage("<i><ch>You feel like sonic!</ch></i>", player_name)
	end
end



--- Give fly to a player.
function pshy.speedfly_Fly(player_name, value)
	if value == nil then
		value = 50
	end
	if value then
		flyers[player_name] = true
		tfm.exec.bindKeyboard(player_name, 1, true, true)
		tfm.exec.bindKeyboard(player_name, 1, false, true)
		tfm.exec.chatMessage("<i><ch>Jump to flap your wings!</ch></i>", player_name)
	else
		flyers[player_name] = nil
		tfm.exec.chatMessage("<i><ch2>Your feet are happy again.</ch2></i>", player_name)
	end
end



--- Get the target of the command, throwing on permission issue.
-- @private
function pshy.speedfly_GetTarget(user, target, perm_prefix)
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



function eventKeyboard(player_name, key_code, down)
	if down then
		if key_code == 1 and flyers[player_name] then
			tfm.exec.movePlayer(player_name, 0, 0, true, 0, -55, false)
		elseif key_code == 0 and speedies[player_name] then
			tfm.exec.movePlayer(player_name, 0, 0, true, -(speedies[player_name]), 0, true)
		elseif key_code == 2 and speedies[player_name] then
			tfm.exec.movePlayer(player_name, 0, 0, true, speedies[player_name], 0, true)
		end
	end
end



function eventNewGame()
	if pshy.speedfly_reset_on_new_game then
		flyers = {}
		speedies = {}
	end
end



--- !speed
local function ChatCommandSpeed(user, speed, target)
	target = pshy.speedfly_GetTarget(user, target, "!speed")
	speed = speed or (speedies[target] and 0 or 50)
	assert(speed >= 0, "the minimum speed boost is 0")
	assert(speed <= 200, "the maximum speed boost is 200")
	pshy.speedfly_Speed(target, speed)
	return true
end 
pshy.commands["speed"] = {func = ChatCommandSpeed, desc = "toggle fast acceleration mode", argc_min = 0, argc_max = 2, arg_types = {"number", "player"}, arg_names = {"speed", "target_player"}}
pshy.help_pages["pshy_speedfly"].commands["speed"] = pshy.commands["speed"]
pshy.perms.cheats["!speed"] = true
pshy.perms.admins["!speed-others"] = true
pshy.ChatCommandSpeed = ChatCommandSpeed -- @TODO: remove (Required now because another module may use that function)



--- !fly
local function ChatCommandFly(user, value, target)
	target = pshy.speedfly_GetTarget(user, target, "!fly")
	value = value or not flyers[target]
	pshy.speedfly_Fly(target, value)
	return true
end 
pshy.commands["fly"] = {func = ChatCommandFly, desc = "toggle fly mode", argc_min = 0, argc_max = 2, arg_types = {"bool", "player"}}
pshy.help_pages["pshy_speedfly"].commands["fly"] = pshy.commands["fly"]
pshy.perms.cheats["!fly"] = true
pshy.perms.admins["!fly-others"] = true
pshy.ChatCommandFly = ChatCommandFly -- @TODO: remove (Required now because another module may use that function)



--- !tpp (teleport to player)
local function ChatCommandTpp(user, destination, target)
	target = pshy.speedfly_GetTarget(user, target, "!tpp")
	destination = pshy.FindPlayerNameOrError(destination)
	tfm.exec.movePlayer(target, tfm.get.room.playerList[destination].x, tfm.get.room.playerList[destination].y, false, 0, 0, true)
	return true, string.format("Teleported %s to %s.", target, destination)
end
pshy.commands["tpp"] = {func = ChatCommandTpp, desc = "teleport to a player", argc_min = 1, argc_max = 2, arg_types = {"player", "player"}, arg_names = {"destination", "target_player"}}
pshy.help_pages["pshy_speedfly"].commands["tpp"] = pshy.commands["tpp"]
pshy.perms.cheats["!tpp"] = true
pshy.perms.admins["!tpp-others"] = true



--- !tpl (teleport to location)
local function ChatCommandTpl(user, x, y, target)
	target = pshy.speedfly_GetTarget(user, target, "!tpl")
	tfm.exec.movePlayer(target, x, y, false, 0, 0, true)
	return true, string.format("Teleported %s to %d; %d.", target, x, y)
end
pshy.commands["tpl"] = {func = ChatCommandTpl, desc = "teleport to a location", argc_min = 2, argc_max = 3, arg_types = {"number", "number", "player"}, arg_names = {"x", "y", "target_player"}}
pshy.help_pages["pshy_speedfly"].commands["tpl"] = pshy.commands["tpl"]
pshy.perms.cheats["!tpl"] = true
pshy.perms.admins["!tpl-others"] = true



--- !coords
local function ChatCommandTpl(user)
	local tfm_player = tfm.get.room.playerList[user]
	return true, string.format("Coordinates: (%d; %d).", tfm_player.x, tfm_player.y)
end
pshy.commands["coords"] = {func = ChatCommandTpl, desc = "get your coordinates", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_speedfly"].commands["coords"] = pshy.commands["coords"]
pshy.perms.cheats["!coords"] = true
