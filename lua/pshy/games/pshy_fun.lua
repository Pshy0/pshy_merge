--- pshyfun.lua
--
-- Fun modulepack (mainly for villages or chilling).
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_essentials.lua
-- @require pshy_changeimage.lua
-- @require pshy_commands_fun.lua
-- @require pshy_commands_tfm.lua
-- @require pshy_emoticons.lua
-- @require pshy_fcplatform.lua
-- @require pshy_imagedb_misc.lua
-- @require pshy_mapdb_more.lua
-- @require pshy_merge.lua
-- @require pshy_motd.lua
-- @require pshy_newgame.lua
-- @require pshy_rain.lua



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