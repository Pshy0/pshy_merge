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
antiemotespam = pshy.require("pshy.anticheats.antiemotespam", false)
pshy.require("pshy.bases.lobby")
pshy.require("pshy.bases.version")
pshy.require("pshy.commands")
pshy.require("pshy.commands.list.players")
pshy.require("pshy.commands.list.modules")
pshy.require("pshy.commands.list.room")
pshy.require("pshy.commands.list.tfm")
pshy.require("pshy.events")
pshy.require("pshy.essentials.funcorp")
pshy.require("pshy.help")
pshy.require("pshy.rotations.list.ctmce")
pshy.require("pshy.rotations.list.racing_vanilla")
pshy.require("pshy.rotations.list.troll")
local newgame = pshy.require("pshy.rotations.newgame")
local teams = pshy.require("pshy.teams")
pshy.require("pshy.teams.racingvs")
pshy.require("pshy.tools.fcplatform")
pshy.require("pshy.tools.motd")
pshy.require("pshy.tools.untrustedmaps")
pshy.require("pshy.utils.messages")



--- Pshy Settings:
if antiemotespam then
	antiemotespam.max_emotes_per_game = 10
end
newgame.delay_next_map = true
newgame.update_map_name_on_new_player = false



--- TFM Settings:
tfm.exec.disableDebugCommand(true)
tfm.exec.disablePhysicalConsumables(true)
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAfkDeath(true)
tfm.exec.disableAutoTimeLeft(true)
system.disableChatCommandDisplay(nil, true)



newgame.SetRotation("racing_vanilla")
tfm.exec.newGame("lobby")
