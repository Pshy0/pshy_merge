--- pshy.games.fun
--
-- Fun modulepack (mainly for villages or chilling).
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.anticheats.antiguest")
pshy.require("pshy.bases.alternatives")
pshy.require("pshy.bases.doc")
pshy.require("pshy.bases.rain")
pshy.require("pshy.commands")
pshy.require("pshy.commands.players")
pshy.require("pshy.commands.modules")
pshy.require("pshy.commands.tfm")
pshy.require("pshy.essentials")
pshy.require("pshy.events")
pshy.require("pshy.images.changeimage")
pshy.require("pshy.lists.images.misc")
pshy.require("pshy.lists.rotations.more")
pshy.require("pshy.lists.rotations.troll")
pshy.require("pshy.rotations.newgame")
pshy.require("pshy.tools.fcplatform")
pshy.require("pshy.tools.motd")



-- Pshy Settings:
pshy.perms_cheats_enabled = true
pshy.rotations_auto_next_map = false
pshy.help_pages[""].subpages["pshy_commands_fun"] = pshy.help_pages["pshy_commands_fun"]
pshy.help_pages[""].subpages["pshy_emoticons"] = pshy.help_pages["pshy_emoticons"]
pshy.help_pages[""].subpages["pshy_speedfly"] = pshy.help_pages["pshy_speedfly"]



--- TFM Settings:
tfm.exec.disableAutoNewGame(true)			-- you probably dont want this script with AutonewGame
tfm.exec.disableAutoShaman(true)			-- you probably dont want this script with AutonewShaman
tfm.exec.disableAutoTimeLeft(true)
tfm.exec.disableAllShamanSkills(true)		-- avoid skills induced lags
tfm.exec.disableDebugCommand(true)
tfm.exec.disableMinimalistMode(false)
tfm.exec.disablePhysicalConsumables(false)
tfm.exec.disableWatchCommand(false)
system.disableChatCommandDisplay(nil, true)
--tfm.exec.disablePrespawnPreview(false)
