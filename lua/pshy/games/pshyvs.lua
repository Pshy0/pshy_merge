--- pshyvs.lua
--
-- This file builds the pshyvs modulepack.
--
-- @author pshy
-- @hardmerge
-- @require pshy_essentials.lua
-- @require pshy_changeimage.lua
-- @require pshy_fcplatform.lua
-- @require pshy_emoticons.lua
-- @require pshy_lobby.lua
-- @require pshy_teams.lua
-- @require pshy_teams_racingvs.lua
-- @require pshy_newgame.lua



--- TFM setup:
tfm.exec.disableWatchCommand(false)
tfm.exec.disableDebugCommand(true)
tfm.exec.disableMinimalistMode(false)
tfm.exec.disablePhysicalConsumables(true)
system.disableChatCommandDisplay(nil, true)
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAfkDeath(true)
tfm.exec.disableAutoTimeLeft(true)
--tfm.exec.disablePrespawnPreview(false)


tfm.exec.newGame("lobby")
