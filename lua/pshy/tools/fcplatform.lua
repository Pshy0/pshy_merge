--- pshy.tools.fcplatform
--
-- This module add a command to spawn an orange plateform and tp on it.
--
-- @author TFM: Pshy#3752
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")
local ids = pshy.require("pshy.utils.ids")



--- Namespace.
local fcplatform = {}
local ground_id = ids.AllocPhysicObjectId()



--- Platform Settings.
fcplatform.x = -100
fcplatform.y = 100
fcplatform.w = 60
fcplatform.h = 10
fcplatform.friction = 0.4
fcplatform.members = {}		-- set of players to always tp on the platform
fcplatform.jail = {}		-- set of players to always tp on the platform, event when they escape ;>
fcplatform.pilots = {}		-- set of players who pilot the platform
fcplatform.autospawn = false
fcplatform.color = 0xff7000



--- Internal use:
fcplatform.spawned = false



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.require("pshy.commands.get_target_or_error")



--- Module Help Page.
help_pages[__MODULE_NAME__] = {back = "pshy", title = "FC Platform",text = "Adds a platform you can teleport on to spectate.\nThe players on the platform move with it.\n"}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Get a set of players on the platform.
local function GetPlayersOnFcplatform()
	if not fcplatform.spawned then
		return {}
	end
	local ons = {}
	for player_name, player in pairs(tfm.get.room.playerList) do
		if player.y < fcplatform.y - fcplatform.h / 2 and player.y > fcplatform.y - fcplatform.h / 2 - 60 and player.x > fcplatform.x - fcplatform.w / 2 and player.x < fcplatform.x + fcplatform.w / 2 then
			ons[player_name] = true
		end
	end
	return ons
end



__MODULE__.commands = {
	["fcplatform"] = {
		aliases = {"fcp"},
		perms = "admins",
		desc = "Create a funcorp plateform.",
		argc_min = 0,
		argc_max = 2,
		arg_types = {'number', 'number'},
		func = function(user, x, y)
			local ons = GetPlayersOnFcplatform() -- set of players on the platform
			local offset_x = 0
			local offset_y = 0
			if x then
				offset_x = x - fcplatform.x
				fcplatform.x = x
			end
			if y then
				offset_y = y - fcplatform.y
				fcplatform.y = y
			end
			if fcplatform.x and fcplatform.y then
				tfm.exec.addPhysicObject(ground_id, fcplatform.x, fcplatform.y, {type = 12, width = fcplatform.w, height = fcplatform.h, foreground = false, friction = fcplatform.friction, restitution = 0.0, angle = 0, color = fcplatform.color, miceCollision = true, groundCollision = false})
				fcplatform.spawned = true
				for player_name, void in pairs(ons) do
					tfm.exec.movePlayer(player_name, offset_x, offset_y, true, 0, 0, true)
				end
				for player_name, void in pairs(fcplatform.members) do
					if not ons[player_name] or user == nil then
						tfm.exec.movePlayer(player_name, fcplatform.x, fcplatform.y - 20, false, 0, 0, false)
					end
				end
			end
		end
	},
	["fcplatformpilot"] = {
		aliases = {"fcpp"},
		perms = "admins",
		desc = "Set yourself or a player as a fcplatform pilot.",
		argc_min = 0,
		argc_max = 1,
		arg_types = {'string'},
		func = function(user, target)
			target = target or user
			if not fcplatform.pilots[target] then
				system.bindMouse(target, true)
				fcplatform.pilots[target] = true
				return true, string.format("%s is now the platform's pilot!", target)
			else
				fcplatform.pilots[target] = nil
				return true, string.format("%s is no longer the platform's pilot.", target)
			end
		end
	},
	["fcplatformjoin"] = {
		aliases = {"fcpj", "fcpjoin"},
		perms = "admins",
		desc = "Join or leave the fcplatform.",
		argc_min = 0,
		argc_max = 2,
		arg_types = {'bool', 'player'},
		func = function(user, join, target)
			local target = GetTarget(user, target, "!fcplatformjoin")
			local target = target or user
			join = join or not fcplatform.jail[target]
			if fcplatform.jail[target] ~= fcplatform.members[target] then
				return false, "You didnt join the platform by yourself ;>"
			end
			if join then
				if not fcplatform.autospawn then
					return false, "The fcplatform needs to be spawned by room admins for you to join it."
				end
				fcplatform.jail[target] = true
				fcplatform.members[target] = true
				tfm.exec.removeCheese(target)
				return true, "Platform joined!"
			else
				fcplatform.jail[target] = nil
				fcplatform.members[target] = nil
				tfm.exec.killPlayer(user)
				return true, "Platform left!"
			end
		end
	},
	["fcplatformautospawn"] = {
		aliases = {"fcpautospawn"},
		perms = "admins",
		desc = "Enable or disable the platform from respawning between games.",
		argc_min = 0,
		argc_max = 1,
		arg_types = {'bool'},
		func = function(user, enabled)
			if enabled == nil then
				enabled = not fcplatform.autospawn
			end
			fcplatform.autospawn = enabled
			if enabled then
				return true, "The platform will now respawn between games."
			else
				return true, "The platform will no longer respawn between games."
			end
		end
	},
	["fcplatformcolor"] = {
		aliases = {"fcpcolor"},
		perms = "admins",
		desc = "Set the platform's color.",
		argc_min = 1,
		argc_max = 1,
		arg_types = {'color'},
		func = function(user, color)
			fcplatform.color = color
			if fcplatform.spawned then
				return __MODULE__.commands.fcplatform(nil)
			else
				return true, "The platform's color will have changed the next time you spawn it."
			end
		end
	},
	["fcplatformsize"] = {
		aliases = {"fcpsize"},
		perms = "admins",
		desc = "Set the platform's size.",
		argc_min = 1,
		argc_max = 2,
		arg_types = {'number', 'number'},
		func = function(user, width, height)
			height = height or fcplatform.h
			fcplatform.w = width
			fcplatform.h = height
			if fcplatform.spawned then
				return __MODULE__.commands.fcplatform(nil)
			else
				return true, "The platform's size will have changed the next time you spawn it."
			end
		end
	}
}



--- TFM event eventNewgame
function eventNewGame()
	fcplatform.spawned = false
	if fcplatform.autospawn then
		__MODULE__.commands.fcplatform(nil)
		for player_name in pairs(fcplatform.jail) do
			local tfm_player = tfm.get.room.playerList[player_name]
			if tfm_player then
				tfm.exec.movePlayer(player_name, tfm_player.x, tfm_player.y, false, 0, 0, true)
			end
		end
	end
end



--- TFM event eventLoop
function eventLoop(currentTime, timeRemaining)
    for player_name, void in pairs(fcplatform.jail) do
    	player = tfm.get.room.playerList[player_name]
    	if player then
	    	if player.y < fcplatform.y and player.y > fcplatform.y - 60 and player.x > fcplatform.x - fcplatform.w / 2 and player.x < fcplatform.x + fcplatform.w / 2 then
				-- on already
			else
				tfm.exec.movePlayer(player_name, fcplatform.x, fcplatform.y - 20, false, 0, 0, false)
			end
		end
    end
end



--- TFM event eventMouse
function eventMouse(playerName, xMousePosition, yMousePosition)
	if fcplatform.pilots[playerName] then
		__MODULE__.commands.fcplatform(playerName, xMousePosition, yMousePosition)
	end
end



return fcplatform
