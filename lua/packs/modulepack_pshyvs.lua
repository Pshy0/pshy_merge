--- modulepack_pshyvs.lua
--
-- This file builds the pshyvs modulepack.
--
-- @author pshy
-- @hardmerge
-- @require pshy_changeimage.lua
-- @require pshy_fcplatform.lua
-- @require pshy_fun_commands.lua
-- @require pshy_emoticons.lua
-- @require pshy_lobby.lua
-- @require pshy_lua_commands.lua
-- @require pshy_motd.lua
-- @require pshy_nicks.lua
-- @require pshy_rain.lua
-- @require pshy_speedfly.lua
-- @require pshy_teams.lua
-- @require pshy_tfm_commands.lua



--- TFM setup:
tfm.exec.disableWatchCommand(false)
tfm.exec.disableDebugCommand(true)
tfm.exec.disableMinimalistMode(false)
tfm.exec.disablePhysicalConsumables(true)
system.disableChatCommandDisplay(nil, true)
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAfkDeath(true)
--tfm.exec.disablePrespawnPreview(false)
