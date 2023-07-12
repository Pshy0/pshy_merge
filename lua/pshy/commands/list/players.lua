--- pshy.commands.list.players
--
-- Adds fun commands everyone can use.
-- Expected to be used in chill rooms, such as villages.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local help_pages = pshy.require("pshy.help.pages")
local utils_tfm = pshy.require("pshy.utils.tfm")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Mice"}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Internal use:
local link_wishes = {}			-- map of player names requiring a link to another one
local players_balloon_id = {}



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.require("pshy.commands.get_target_or_error")



__MODULE__.commands = {
	["shaman"] = {
		perms = "cheats",
		aliases = {"sham"},
		desc = "switch you to a shaman",
		argc_min = 0,
		argc_max = 2,
		arg_types = {"bool", "player"},
		arg_names = {"on/off"},
		func = function(user, value, target)
			target = GetTarget(user, target, "!shaman")
			if value == nil then
				value = not tfm.get.room.playerList[target].isShaman
			end
			tfm.exec.setShaman(target, value)
			return true, string.format("%s %s", target, value and "is now a shaman." or "is no longer a shaman.")
		end
	},
	["shamanmode"] = {
		perms = "cheats",
		desc = "choose your shaman mode (0/1/2)",
		argc_min = 0,
		argc_max = 2,
		arg_types = {"number", "player"},
		func = function(user, mode, target)
			target = GetTarget(user, target, "!shamanmode")
			if mode ~= 0 and mode ~= 1 and mode ~= 2 then
				return false, "Mode must be 0 (normal), 1 (hard) or 2 (divine)."		
			end
			return true, string.format("Set %s's shaman mode to %d.", target, mode)
		end
	},
	["vampire"] = {
		perms = "cheats",
		desc = "switch you to a vampire",
		argc_min = 0,
		argc_max = 2,
		arg_types = {"bool", "player"},
		arg_names = {"on/off"},
		func = function(user, value, target)
			target = GetTarget(user, target, "!vampire")
			if value == nil then
				value = not tfm.get.room.playerList[target].isVampire
			end
			tfm.exec.setVampirePlayer(target, value)
			return true, string.format("%s %s", target, value and "is now a vampire." or "is no longer a vampire.")
		end
	},
	["cheese"] = {
		perms = "cheats",
		desc = "toggle your cheese",
		argc_min = 0,
		argc_max = 2,
		arg_types = {"bool", "player"},
		arg_names = {"yes/no"},
		func = function(user, value, target)
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
	},
	["win"] = {
		aliases = {"victory"},
		perms = "cheats",
		desc = "play the win animation",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"player"},
		func = function(user, target)
			target = GetTarget(user, target, "!win")
			tfm.exec.giveCheese(target)
			tfm.exec.playerVictory(target)
			return true, string.format("%s won.", target)
		end
	},
	["kill"] = {
		perms = "cheats",
		desc = "kill yourself",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"player"},
		func = function(user, target)
			target = GetTarget(user, target, "!kill")
			tfm.exec.killPlayer(target)
			return true, string.format("%s killed.", target)
		end
	},
	["respawn"] = {
		perms = "cheats",
		desc = "resurect yourself",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"player"},
		func = function(user, target)
			target = GetTarget(user, target, "!respawn")
			tfm.exec.respawnPlayer(target)
			return true, string.format("%s respawned.", target)
		end
	},
	["freeze"] = {
		perms = "cheats",
		desc = "freeze yourself",
		argc_min = 1,
		argc_max = 3,
		arg_types = {"bool", "player", "bool"},
		arg_names = {"yes/no"},
		func = function(user, value, target, visible)
			target = GetTarget(user, target, "!freeze")
			tfm.exec.freezePlayer(target, value, visible)
			return true, string.format("%s %s", target, value and "frozen." or "no longer frozen.")
		end
	},
	["size"] = {
		perms = "cheats",
		desc = "change your size",
		argc_min = 1,
		argc_max = 2,
		arg_types = {"number", "player"},
		func = function(user, size, target)
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
	},
	["namecolor"] = {
		perms = "cheats",
		desc = "change your name's color",
		argc_min = 1,
		argc_max = 2,
		arg_types = {"color", "player"},
		func = function(user, color, target)
			target = GetTarget(user, target, "!namecolor")
			tfm.exec.setNameColor(target, color)
			return true, string.format("%s'name color is now <font color='#%06x'>#%06x</font>.", target, color, color)
		end
	},
	["balloon"] = {
		perms = "cheats",
		desc = "attach a balloon to yourself",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"player"},
		func = function(user, target)
			target = GetTarget(user, target, "!balloon")
			if players_balloon_id[target] then
				tfm.exec.removeObject(players_balloon_id[target])
				players_balloon_id[target] = nil
			end
			players_balloon_id[target] = tfm.exec.attachBalloon(target, true, math.random(1, 4), true)
			return true, string.format("Attached a balloon to %s.", target)
		end
	},
	["link"] = {
		perms = "cheats",
		desc = "attach yourself to another player (yourself to stop)",
		argc_min = 1,
		argc_max = 2,
		arg_types = {"player", "player"},
		func = function(user, wish, target)
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
	}
}
