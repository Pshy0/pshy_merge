--- pshyvs.lua
--
-- This file builds the pshyvs modulepack.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_essentials.lua
-- @require pshy_fcplatform.lua
-- @require pshy_lobby.lua
-- @require pshy_mapdb_troll.lua
-- @require pshy_mapdb_vanillavs.lua
-- @require pshy_newgame.lua
-- @require pshy_teams.lua
-- @require pshy_teams_racingvs.lua
-- @require pshy_utils_messages.lua
--
-- @hardmerge


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



pshy.newgame_ChatCommandRotc(pshy.loader, "vanilla_vs")
tfm.exec.newGame("lobby")
