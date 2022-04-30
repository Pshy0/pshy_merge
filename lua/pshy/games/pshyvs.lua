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



--- Pshy Settings:
pshy.antiemotespam_max_emotes_per_game = 10
pshy.newgame_update_map_name_on_new_player = false



--- TFM Settings:
tfm.exec.disableDebugCommand(true)
tfm.exec.disablePhysicalConsumables(true)
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAfkDeath(true)
tfm.exec.disableAutoTimeLeft(true)
system.disableChatCommandDisplay(nil, true)



pshy.newgame_SetRotation("vanilla_vs")
tfm.exec.newGame("lobby")
