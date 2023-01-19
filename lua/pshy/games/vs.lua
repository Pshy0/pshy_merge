--- pshy.games.vs
--
-- This file builds the pshy_vs tfm lua script.
-- The gameplay is mainly located in `pshy_teams_racingvs.lua` and `pshy_teams.lua`.
-- This file is only listing wished features.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.alternatives.chat")
pshy.require("pshy.anticheats.ban")
pshy.require("pshy.anticheats.loadersync")
pshy.require("pshy.bases.lobby")
pshy.require("pshy.bases.version")
pshy.require("pshy.commands")
pshy.require("pshy.commands.list.players")
pshy.require("pshy.commands.list.modules")
pshy.require("pshy.commands.list.room")
pshy.require("pshy.commands.list.tfm")
pshy.require("pshy.events")
pshy.require("pshy.help")
pshy.require("pshy.rotations.list.troll")
pshy.require("pshy.rotations.list.vanillavs")
local newgame = pshy.require("pshy.rotations.newgame")
local teams = pshy.require("pshy.teams")
pshy.require("pshy.teams.racingvs")
pshy.require("pshy.tools.fcplatform")
pshy.require("pshy.tools.motd")
pshy.require("pshy.utils.messages")



--- Pshy Settings:
pshy.antiemotespam_max_emotes_per_game = 10
newgame.update_map_name_on_new_player = false



--- TFM Settings:
tfm.exec.disableDebugCommand(true)
tfm.exec.disablePhysicalConsumables(true)
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAfkDeath(true)
tfm.exec.disableAutoTimeLeft(true)
system.disableChatCommandDisplay(nil, true)



newgame.SetRotation("vanilla_vs")
tfm.exec.newGame("lobby")
