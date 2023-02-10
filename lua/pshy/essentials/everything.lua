--- pshy.essentials.everything
--
-- Requires as many scripts as possible.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.alternatives.chat")
pshy.require("pshy.alternatives.timers")
pshy.require("pshy.anticheats.adminchat")
pshy.require("pshy.anticheats.ban")
pshy.require("pshy.bases.checkpoints")
pshy.require("pshy.bases.emotes")
pshy.require("pshy.bases.emoticons")
pshy.require("pshy.bases.speedfly")
pshy.require("pshy.bases.version")
pshy.require("pshy.bases.rain")
pshy.require("pshy.commands")
pshy.require("pshy.commands.list.all")
pshy.require("pshy.debug")
pshy.require("pshy.help")
pshy.require("pshy.images.changeimage")
pshy.require("pshy.images.list.all")
pshy.require("pshy.rotations.list.all")
pshy.require("pshy.rotations.mapinfo")
pshy.require("pshy.rotations.mapext.missingobjects")
pshy.require("pshy.rotations.newgame")
pshy.require("pshy.tools.bindkey")
pshy.require("pshy.tools.bindmouse")
pshy.require("pshy.tools.entibot")
pshy.require("pshy.tools.fcplatform")
pshy.require("pshy.tools.getxml")
pshy.require("pshy.tools.loadxml")
pshy.require("pshy.tools.motd")
pshy.require("pshy.utils.tfm_enum_fix")
-- Adding the empty script last.
pshy.require("pshy.debug.emptyscriptslot")



if __IS_MAIN_MODULE__ then
	print_info("Running as main module, disabling auto new game...")
	tfm.exec.disableAutoNewGame()
end
