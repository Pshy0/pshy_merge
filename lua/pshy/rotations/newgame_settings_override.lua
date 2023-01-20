--- pshy.rotations.newgame_settings_override
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script)



local namespace = {}



tfm.exec.disableAutoNewGame(true)
tfm.exec.disableAutoTimeLeft(true)



--- Original Functions:
namespace.OriginalTFMDisableAutoNewGame = tfm.exec.disableAutoNewGame
namespace.OriginalTFMDisableAutoTimeLeft = tfm.exec.disableAutoTimeLeft
namespace.OriginalTFMDisableAutoShaman = tfm.exec.disableAutoShaman



--- Simulated TFM settings override:
namespace.auto_new_game = true
namespace.auto_time_left = true
namespace.auto_shaman = true



tfm.exec.disableAutoNewGame = function(disabled)
	namespace.auto_new_game = ((disabled == nil) and true) or not disabled
end



tfm.exec.disableAutoTimeLeft = function(disabled)
	namespace.auto_time_left = ((disabled == nil) and true) or not disabled
end



tfm.exec.disableAutoShaman = function(disabled)
	namespace.auto_shaman = ((disabled == nil) and true) or not disabled
end



return namespace
