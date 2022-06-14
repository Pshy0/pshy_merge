--- pshy_vs.lua
--
-- This file builds the pshy_vs tfm lua script.
-- The gameplay is mainly located in `pshy_teams_racingvs.lua` and `pshy_teams.lua`.
-- This file is only listing wished features.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_alternatives.lua
-- @require pshy_commands_fun.lua
-- @require pshy_commands_modules.lua
-- @require pshy_essentials.lua
-- @require pshy_fcplatform.lua
-- @require pshy_loadersync.lua
-- @require pshy_lobby.lua
-- @require pshy_mapdb_troll.lua
-- @require pshy_mapdb_vanillavs.lua
-- @require pshy_merge.lua
-- @require pshy_motd.lua
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
