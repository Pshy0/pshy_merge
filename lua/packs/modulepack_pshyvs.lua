--- modulepack_pshyvs.lua
--
-- This file builds the pshyvs modulepack.
--
-- @author pshy
-- @hardmerge
-- @require pshy_merge.lua
-- @require pshy_perms.lua
-- @require pshy_commands.lua
-- @require pshy_lua_commands.lua
-- @require pshy_fcplatform.lua
-- @require pshy_weather.lua
-- @require pshy_basic_weathers.lua
-- @require pshy_motd.lua
-- @require pshy_ui.lua
-- @require pshy_nicks.lua
-- @require pshy_rotations.lua
-- @require pshy_scores.lua
-- @require pshy_emoticons.lua
-- @require pshy_teams.lua



--- Perms:
pshy.perms.everyone["!nick"] = nil



--- TFM setup:
tfm.exec.disableWatchCommand(false)
tfm.exec.disableDebugCommand(true)
tfm.exec.disableMinimalistMode(false)
tfm.exec.disablePhysicalConsumables(true)
system.disableChatCommandDisplay(nil, true)
tfm.exec.disableAutoShaman(true)
--tfm.exec.disablePrespawnPreview(false)
