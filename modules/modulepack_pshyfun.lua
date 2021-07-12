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



-- Pshy Settings:
pshy.rotations_auto_next_map = false
pshy.help_pages[""].subpages["pshy_fun_commands"] = pshy.help_pages["pshy_fun_commands"]



--- TFM Settings:
tfm.exec.disableWatchCommand(false)
tfm.exec.disableDebugCommand(true)
tfm.exec.disableMinimalistMode(false)
tfm.exec.disablePhysicalConsumables(true)
system.disableChatCommandDisplay(nil, true)
--tfm.exec.disablePrespawnPreview(false)
