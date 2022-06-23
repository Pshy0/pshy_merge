--- pshy.bases.speedfly
--
-- Fly, speed boost, and teleport features.
--
-- @author DC:Pshy#7998 TFM:Pshy#3752
pshy.require("pshy.bases.doc")
pshy.require("pshy.events")



--- Namespace.
local speedfly = {}



--- Module Help Page:
pshy.help_pages["pshy_speedfly"] = {back = "pshy", title = "Speed / Fly / Teleport", text = "Fly and speed boost.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_speedfly"] = pshy.help_pages["pshy_speedfly"]



--- Settings:
speedfly.reset_on_new_game = true



--- Internal Use:
local flyers = {}		-- flying players
local speedies = {}		-- speedy players (value is the speed)



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.commands_GetTargetOrError



--- Give speed to a player.
function speedfly.Speed(player_name, speed)
	if speed == nil then
		speed = 20
	end
	if speed <= 1 or speed == false or speed == speedies[player_name] then
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
function speedfly.Fly(player_name, value)
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
	if speedfly.reset_on_new_game then
		flyers = {}
		speedies = {}
	end
end



--- !speed
local function ChatCommandSpeed(user, speed, target)
	target = GetTarget(user, target, "!speed")
	speed = speed or (speedies[target] and 0 or 50)
	assert(speed >= 0, "the minimum speed boost is 0")
	assert(speed <= 200, "the maximum speed boost is 200")
	speedfly.Speed(target, speed)
	return true
end 
pshy.commands["speed"] = {perms = "cheats", func = ChatCommandSpeed, desc = "toggle fast acceleration mode", argc_min = 0, argc_max = 2, arg_types = {"number", "player"}, arg_names = {"speed", "target_player"}}
pshy.help_pages["pshy_speedfly"].commands["speed"] = pshy.commands["speed"]
pshy.ChatCommandSpeed = ChatCommandSpeed -- @TODO: remove (Required now because another module may use that function)



--- !fly
local function ChatCommandFly(user, value, target)
	target = GetTarget(user, target, "!fly")
	value = value or not flyers[target]
	speedfly.Fly(target, value)
	return true
end 
pshy.commands["fly"] = {perms = "cheats", func = ChatCommandFly, desc = "toggle fly mode", argc_min = 0, argc_max = 2, arg_types = {"bool", "player"}}
pshy.help_pages["pshy_speedfly"].commands["fly"] = pshy.commands["fly"]
pshy.ChatCommandFly = ChatCommandFly -- @TODO: remove (Required now because another module may use that function)



return speedfly
