--- pshy.games.vs
--
-- This file builds the pshy_vs tfm lua script.
-- The gameplay is mainly located in `pshy_teams_racingvs.lua` and `pshy_teams.lua`.
-- This file is only listing wished features.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.anticheats.loadersync")
pshy.require("pshy.bases.alternatives")
pshy.require("pshy.bases.doc")
pshy.require("pshy.bases.lobby")
pshy.require("pshy.commands")
pshy.require("pshy.commands.players")
pshy.require("pshy.commands.modules")
pshy.require("pshy.events")
pshy.require("pshy.lists.rotations.troll")
pshy.require("pshy.lists.rotations.vanillavs")
pshy.require("pshy.rotations.newgame")
pshy.require("pshy.teams")
pshy.require("pshy.teams.racingvs")
pshy.require("pshy.tools.fcplatform")
pshy.require("pshy.tools.motd")
pshy.require("pshy.utils.messages")



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
