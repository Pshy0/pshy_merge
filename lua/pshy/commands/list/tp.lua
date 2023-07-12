--- pshy.commands.list.tp
--
-- Commands to teleport.
--
-- @author DC:Pshy#7998 TFM:Pshy#3752
local help_pages = pshy.require("pshy.help.pages")
local utils_tfm = pshy.require("pshy.utils.tfm")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Teleportation"}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.require("pshy.commands.get_target_or_error")



__MODULE__.commands = {
	["tpp"] = {
		perms = "cheats",
		desc = "teleport to a player",
		argc_min = 1,
		argc_max = 2,
		arg_types = {"player", "player"},
		arg_names = {"destination", "target_player"},
		func = function(user, destination, target)
			target = GetTarget(user, target, "!tpp")
			destination = utils_tfm.FindPlayerNameOrError(destination)
			tfm.exec.movePlayer(target, tfm.get.room.playerList[destination].x, tfm.get.room.playerList[destination].y, false, 0, 0, true)
			return true, string.format("Teleported %s to %s.", target, destination)
		end
	},
	["tpl"] = {
		perms = "cheats",
		desc = "teleport to a location",
		argc_min = 2,
		argc_max = 3,
		arg_types = {"number", "number", "player"},
		arg_names = {"x", "y", "target_player"},
		func = function(user, x, y, target)
			target = GetTarget(user, target, "!tpl")
			tfm.exec.movePlayer(target, x, y, false, 0, 0, true)
			return true, string.format("Teleported %s to %d; %d.", target, x, y)
		end
	},
	["coords"] = {
		perms = "cheats",
		desc = "get your coordinates",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			local tfm_player = tfm.get.room.playerList[user]
			return true, string.format("Coordinates: (%d; %d).", tfm_player.x, tfm_player.y)
		end
	}
}
