--- modulepack_pshyfun.lua
--
-- Fun modulepack (mainly for villages or chilling).
--
-- @author pshy
--
-- @hardmerge
-- @require pshy_merge.lua
-- @require pshy_commands.lua
-- @require pshy_lua_commands.lua
-- @require pshy_fun_commands.lua
-- @require pshy_fcplatform.lua
-- @require pshy_nicks.lua
-- @require pshy_checkpoints.lua
-- @require pshy_motd.lua
-- @require pshy_weather.lua
-- @require pshy_basic_weathers.lua
-- @require pshy_rotations.lua
-- @require pshy_emoticons.lua



-- Pshy Settings:
pshy.rotations_auto_next_map = false
pshy.help_pages[""].subpages["pshy_fun_commands"] = pshy.help_pages["pshy_fun_commands"]
pshy.help_pages[""].subpages["pshy_emoticons"] = pshy.help_pages["pshy_emoticons"]



--- TFM Settings:
tfm.exec.disableAutoNewGame(true)	-- you probably dont want this script with AutonewGame
tfm.exec.disableAutoShaman(disable)	-- you probably dont want this script with AutonewShaman
tfm.exec.disableAutoTimeLeft(true)
tfm.exec.disableAllShamanSkills(true)	-- avoid skills induced lags
tfm.exec.disableDebugCommand(true)
tfm.exec.disableMinimalistMode(false)
tfm.exec.disablePhysicalConsumables(true)
tfm.exec.disableWatchCommand(false)
system.disableChatCommandDisplay(nil, true)
--tfm.exec.disablePrespawnPreview(false)
