--- pshy.commands.list.unused
--
-- Rarely used commands that have been moved from other modules to save space.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local commands = pshy.require("pshy.commands")
local help_pages = pshy.require("pshy.help.pages")
pshy.require("pshy.utils.lua")
pshy.require("pshy.utils.print")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "Unused", title = "Unused commands.", text = ""}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



__MODULE__.commands = {
	["rejoin"] = {
		perms = "admins",
		desc = "simulate a rejoin (events left + join + died)",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"string"},
		func = function(user, target)
			target = target or user
			tfm.exec.killPlayer(target)
			eventPlayerLeft(target)
			eventNewPlayer(target)
			return true, "Simulating a rejoin..."
		end
	},
	["runas"] = {
		desc = "run a command as another player",
		argc_min = 2,
		argc_max = 2,
		arg_types = {"player", "string"},
		func = function(player_name, target_player, command)
			print_warn("Player %s running command as %s: %s", player_name, target_player, command)
			commands.Run(target_player, command)
		end
	},
	["luaversion"] = {
		perms = "everyone",
		desc = "Show LUA's version.",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			if type(_VERSION) == "string" then
				return true, string.format("LUA version: %s", tostring(_VERSION))
			else
				return false, "LUA not properly implemented."
			end
		end
	},
	["jitversion"] = {
		perms = "everyone",
		desc = "Show JIT's version.",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			if type(jit) == "table" then
				return true, string.format("LUA JIT version: %s", tostring(jit.version))
			else
				return false, "JIT not used or not properly implemented."
			end
		end
	}
}
