--- pshy.games.fun
--
-- Fun modulepack (mainly for villages or chilling).
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.alternatives.chat")
pshy.require("pshy.anticheats.antiguest")
pshy.require("pshy.bases.rain")
pshy.require("pshy.commands")
pshy.require("pshy.commands.list.players")
pshy.require("pshy.commands.list.modules")
pshy.require("pshy.commands.list.tfm")
pshy.require("pshy.essentials")
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")
pshy.require("pshy.images.changeimage")
pshy.require("pshy.images.list.misc")
pshy.require("pshy.rotations.list.more")
pshy.require("pshy.rotations.list.troll")
pshy.require("pshy.rotations.newgame")
pshy.require("pshy.tools.fcplatform")
pshy.require("pshy.tools.motd")
local perms = pshy.require("pshy.perms")



-- Pshy Settings:
perms.cheats_enabled = true
pshy.rotations_auto_next_map = false
help_pages[""].subpages["pshy_commands_fun"] = help_pages["pshy_commands_fun"]
help_pages[""].subpages["pshy_emoticons"] = help_pages["pshy_emoticons"]
help_pages[""].subpages["pshy_speedfly"] = help_pages["pshy_speedfly"]



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
