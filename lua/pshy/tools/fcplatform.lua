--- pshy.tools.fcplatform
--
-- This module add a command to spawn an orange plateform and tp on it.
--
-- @author TFM: Pshy#3752
pshy.require("pshy.bases.doc")
pshy.require("pshy.bases.events")
pshy.require("pshy.bases.perms")



--- Platform Settings.
pshy.fcplatform_x = -100
pshy.fcplatform_y = 100
pshy.fcplatform_w = 60
pshy.fcplatform_h = 10
pshy.fcplatform_friction = 0.4
pshy.fcplatform_members = {}		-- set of players to always tp on the platform
pshy.fcplatform_jail = {}		-- set of players to always tp on the platform, event when they escape ;>
pshy.fcplatform_pilots = {}		-- set of players who pilot the platform
pshy.fcplatform_autospawn = false
pshy.fcplatform_color = 0xff7000



--- Internal use:
pshy.fcplatform_spawned = false



--- Module Help Page.
pshy.help_pages["pshy_fcplatform"] = {back = "pshy", title = "FC Platform",text = "Adds a platform you can teleport on to spectate.\nThe players on the platform move with it.\n"}
pshy.help_pages["pshy_fcplatform"].commands = {}
pshy.help_pages["pshy"].subpages["pshy_fcplatform"] = pshy.help_pages["pshy_fcplatform"]



--- Get a set of players on the platform.
local function GetPlayersOnFcplatform()
	if not pshy.fcplatform_spawned then
		return {}
	end
	local ons = {}
	for player_name, player in pairs(tfm.get.room.playerList) do
		if player.y < pshy.fcplatform_y - pshy.fcplatform_h / 2 and player.y > pshy.fcplatform_y - pshy.fcplatform_h / 2 - 60 and player.x > pshy.fcplatform_x - pshy.fcplatform_w / 2 and player.x < pshy.fcplatform_x + pshy.fcplatform_w / 2 then
			ons[player_name] = true
		end
	end
	return ons
end



--- !fcplatform [x] [y]
-- Create a funcorp plateform and tp on it
function ChatCommandFcplatform(user, x, y)
	local ons = GetPlayersOnFcplatform() -- set of players on the platform
	local offset_x = 0
	local offset_y = 0
	if x then
		offset_x = x - pshy.fcplatform_x
		pshy.fcplatform_x = x
	end
	if y then
		offset_y = y - pshy.fcplatform_y
		pshy.fcplatform_y = y
	end
	if pshy.fcplatform_x and pshy.fcplatform_y then
		tfm.exec.addPhysicObject(199, pshy.fcplatform_x, pshy.fcplatform_y, {type = 12, width = pshy.fcplatform_w, height = pshy.fcplatform_h, foreground = false, friction = pshy.fcplatform_friction, restitution = 0.0, angle = 0, color = pshy.fcplatform_color, miceCollision = true, groundCollision = false})
		pshy.fcplatform_spawned = true
		for player_name, void in pairs(ons) do
			tfm.exec.movePlayer(player_name, offset_x, offset_y, true, 0, 0, true)
		end
		for player_name, void in pairs(pshy.fcplatform_members) do
			if not ons[player_name] or user == nil then
				tfm.exec.movePlayer(player_name, pshy.fcplatform_x, pshy.fcplatform_y - 20, false, 0, 0, false)
			end
		end
	end
end
pshy.commands["fcplatform"] = {aliases = {"fcp"}, perms = "admins", func = ChatCommandFcplatform, desc = "Create a funcorp plateform.", argc_min = 0, argc_max = 2, arg_types = {'number', 'number'}}
pshy.commands["fcplatform"].help = "Create a platform at given coordinates, or recreate the previous platform. Accept variables as arguments.\n"
pshy.help_pages["pshy_fcplatform"].commands["fcplatform"] = pshy.commands["fcplatform"]



--- !fcplatformpilot [player_name]
local function ChatCommandFcpplatformpilot(user, target)
	target = target or user
	if not pshy.fcplatform_pilots[target] then
		system.bindMouse(target, true)
		pshy.fcplatform_pilots[target] = true
		return true, string.format("%s is now the platform's pilot!", target)
	else
		pshy.fcplatform_pilots[target] = nil
		return true, string.format("%s is no longer the platform's pilot.", target)
	end
end
pshy.commands["fcplatformpilot"] = {aliases = {"fcpp"}, perms = "admins", func = ChatCommandFcpplatformpilot, desc = "Set yourself or a player as a fcplatform pilot.", argc_min = 0, argc_max = 1, arg_types = {'string'}}
pshy.help_pages["pshy_fcplatform"].commands["fcplatformpilot"] = pshy.commands["fcplatformpilot"]



--- !fcplatformjoin [player_name]
-- Jail yourself on the fcplatform.
local function ChatCommandFcpplatformjoin(user, join, target)
	local target = pshy.commands_GetTargetOrError(user, target, "!fcplatformjoin")
	local target = target or user
	join = join or not pshy.fcplatform_jail[target]
	if pshy.fcplatform_jail[target] ~= pshy.fcplatform_members[target] then
		return false, "You didnt join the platform by yourself ;>"
	end
	if join then
		if not pshy.fcplatform_autospawn then
			return false, "The fcplatform needs to be spawned by room admins for you to join it."
		end
		pshy.fcplatform_jail[target] = true
		pshy.fcplatform_members[target] = true
		tfm.exec.removeCheese(target)
		return true, "Platform joined!"
	else
		pshy.fcplatform_jail[target] = nil
		pshy.fcplatform_members[target] = nil
		tfm.exec.killPlayer(user)
		return true, "Platform left!"
	end
end
pshy.commands["fcplatformjoin"] = {aliases = {"fcpj", "fcpjoin"}, perms = "admins", func = ChatCommandFcpplatformjoin, desc = "Join or leave the fcplatform.", argc_min = 0, argc_max = 2, arg_types = {'bool', 'player'}}
pshy.help_pages["pshy_fcplatform"].commands["fcplatformjoin"] = pshy.commands["fcplatformjoin"]



--- !fcplatformautospawn [enabled]
local function ChatCommandFcplatformautospawn(user, enabled)
	if enabled == nil then
		enabled = not pshy.fcplatform_autospawn
	end
	pshy.fcplatform_autospawn = enabled
	if enabled then
		return true, "The platform will now respawn between games."
	else
		return true, "The platform will no longer respawn between games."
	end
end
pshy.commands["fcplatformautospawn"] = {aliases = {"fcpautospawn"}, perms = "admins", func = ChatCommandFcplatformautospawn, desc = "Enable or disable the platform from respawning between games.", argc_min = 0, argc_max = 1, arg_types = {'bool'}}
pshy.help_pages["pshy_fcplatform"].commands["fcplatformautospawn"] = pshy.commands["fcplatformautospawn"]



--- !fcplatformcolor [color]
local function ChatCommandFcplatformcolor(user, color)
	pshy.fcplatform_color = color
	if pshy.fcplatform_spawned then
		return ChatCommandFcplatform(nil)
	else
		return true, "The platform's color will have changed the next time you spawn it."
	end
end
pshy.commands["fcplatformcolor"] = {aliases = {"fcpcolor"}, perms = "admins", func = ChatCommandFcplatformcolor, desc = "Set the platform's color.", argc_min = 1, argc_max = 1, arg_types = {'color'}}
pshy.help_pages["pshy_fcplatform"].commands["fcplatformcolor"] = pshy.commands["fcplatformcolor"]



--- !fcplatformsize [color]
local function ChatCommandFcplatformsize(user, width, height)
	height = height or pshy.fcplatform_h
	pshy.fcplatform_w = width
	pshy.fcplatform_h = height
	if pshy.fcplatform_spawned then
		return ChatCommandFcplatform(nil)
	else
		return true, "The platform's size will have changed the next time you spawn it."
	end
end
pshy.commands["fcplatformsize"] = {aliases = {"fcpsize"}, perms = "admins", func = ChatCommandFcplatformsize, desc = "Set the platform's size.", argc_min = 1, argc_max = 2, arg_types = {'number', 'number'}}
pshy.help_pages["pshy_fcplatform"].commands["fcplatformsize"] = pshy.commands["fcplatformsize"]



--- TFM event eventNewgame
function eventNewGame()
	pshy.fcplatform_spawned = false
	if pshy.fcplatform_autospawn then
		ChatCommandFcplatform(nil)
		for player_name in pairs(pshy.fcplatform_jail) do
			local tfm_player = tfm.get.room.playerList[player_name]
			if tfm_player then
				tfm.exec.movePlayer(player_name, tfm_player.x, tfm_player.y, false, 0, 0, true)
			end
		end
	end
end



--- TFM event eventLoop
function eventLoop(currentTime, timeRemaining)
    for player_name, void in pairs(pshy.fcplatform_jail) do
    	player = tfm.get.room.playerList[player_name]
    	if player then
	    	if player.y < pshy.fcplatform_y and player.y > pshy.fcplatform_y - 60 and player.x > pshy.fcplatform_x - pshy.fcplatform_w / 2 and player.x < pshy.fcplatform_x + pshy.fcplatform_w / 2 then
				-- on already
			else
				tfm.exec.movePlayer(player_name, pshy.fcplatform_x, pshy.fcplatform_y - 20, false, 0, 0, false)
			end
		end
    end
end



--- TFM event eventMouse
function eventMouse(playerName, xMousePosition, yMousePosition)
	if pshy.fcplatform_pilots[playerName] then
		ChatCommandFcplatform(playerName, xMousePosition, yMousePosition)
	end
end