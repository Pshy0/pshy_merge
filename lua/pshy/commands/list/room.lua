--- pshy.commands.list.room
--
-- Commands related to the room.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.commands")
local help_pages = pshy.require("pshy.help.pages")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Room"}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.require("pshy.commands.get_target_or_error")



__MODULE__.commands = {
	["autonewgame"] = {
		perms = "admins",
		desc = "enable (or disable) TFM automatic map changes",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"bool"},
		func = function(user, autonewgame)
			if autonewgame == nil then
				autonewgame = true
			end
			tfm.exec.disableAutoNewGame(not autonewgame)
		end
	},
	["autoshaman"] = {
		perms = "admins",
		desc = "enable (or disable) TFM automatic shaman choice",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"bool"},
		func = function(user, autoshaman)
			if autoshaman == nil then
				autoshaman = true
			end
			tfm.exec.disableAutoShaman(not autoshaman)
		end
	},
	["autotimeleft"] = {
		perms = "admins",
		desc = "enable (or disable) TFM automatic lowering of time",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"bool"},
		func = function(user, autotimeleft)
			if autotimeleft == nil then
				autotimeleft = true
			end
			tfm.exec.disableAutoTimeLeft(not autotimeleft)
		end
	},
	["playerscore"] = {
		perms = "admins",
		desc = "set the TFM score of a player in the scoreboard",
		argc_min = 1,
		argc_max = 2,
		arg_types = {"number", "player"},
		func = function(user, score, target)
			score = score or 0
			target = GetTarget(user, target, "!playerscore")
			tfm.exec.setPlayerScore(target, score, false)
		end
	},
	["afkdeath"] = {
		perms = "admins",
		desc = "enable (or disable) TFM's killing of AFK players",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"bool"},
		func = function(user, afkdeath)
			if afkdeath == nil then
				afkdeath = true
			end
			tfm.exec.disableAfkDeath(not afkdeath)
		end
	},
	["allowmort"] = {
		perms = "admins",
		desc = "allow (or prevent) TFM's /mort command",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"bool"},
		func = function(user, allowmort)
			tfm.exec.disableMortCommand(not allowmort)
		end
	},
	["allowwatch"] = {
		perms = "admins",
		desc = "allow (or prevent) TFM's /watch command",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"bool"},
		func = function(user, allowwatch)
			tfm.exec.disableWatchCommand(not allowwatch)
		end
	},
	["allowdebug"] = {
		perms = "admins",
		desc = "allow (or prevent) TFM's /debug command",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"bool"},
		func = function(user, allowdebug)
			tfm.exec.disableDebugCommand(not allowdebug)
		end
	},
	["minimalist"] = {
		perms = "admins",
		desc = "allow (or prevent) TFM's minimalist mode",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"bool"},
		func = function(user, enabled)
			tfm.exec.disableMinimalistMode(not enabled)
		end
	},
	["consumables"] = {
		perms = "admins",
		desc = "allow (or prevent) the use of physical consumables",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"bool"},
		func = function(user, consumables)
			tfm.exec.disablePhysicalConsumables(not consumables)
		end
	},
	["chatcommandsdisplay"] = {
		perms = "admins",
		desc = "show (or hide) all chat commands",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"bool"},
		func = function(user, display)
			system.disableChatCommandDisplay(nil, not display)
		end
	},
	["password"] = {
		perms = "admins",
		desc = "set the room's password",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"string"},
		func = function(user, pass)
			tfm.exec.setRoomPassword(pass)
			return true, "Password " .. (pass and "set" or "unset")
		end
	},
	["mapflipmode"] = {
		perms = "admins",
		desc = "Set TFM to use mirrored maps (yes/no or no param for default)",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"bool"},
		func = function(user, mapflipmode)
			tfm.exec.setAutoMapFlipMode(mapflipmode)
		end
	},
	["shamanskills"] = {
		perms = "admins",
		desc = "enable (or disable) TFM shaman's skills",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"bool"},
		func = function(user, shamanskills)
			if shamanskills == nil then
				shamanskills = true
			end
			tfm.exec.disableAllShamanSkills(not shamanskills)
		end
	},
	["autoscore"] = {
		perms = "admins",
		desc = "enable (or disable) TFM score handling",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"bool"},
		func = function(user, autoscore)
			if autoscore == nil then
				autoscore = true
			end
			tfm.exec.disableAutoScore(not autoscore)
		end
	},
	["prespawnpreview"] = {
		perms = "admins",
		desc = "show (or hide) what the shaman is spawning",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"bool"},
		func = function(user, prespawnpreview)
			tfm.exec.disablePrespawnPreview(not prespawnpreview)
		end
	}
}
