--- pshy.rotations.newgame.settings_override
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script)



local namespace = {}



tfm.exec.disableAutoNewGame(true)
tfm.exec.disableAutoTimeLeft(true)



--- Original Functions:
namespace.OriginalTFMDisableAutoNewGame = tfm.exec.disableAutoNewGame
namespace.OriginalTFMDisableAutoTimeLeft = tfm.exec.disableAutoTimeLeft
namespace.OriginalTFMDisableAutoShaman = tfm.exec.disableAutoShaman
namespace.OriginalTFMDisableAfkDeath = tfm.exec.disableAfkDeath



--- Simulated TFM settings override:
namespace.auto_new_game = true
namespace.auto_time_left = true
namespace.auto_shaman = true
namespace.afk_death = true



tfm.exec.disableAutoNewGame = function(disabled)
	namespace.auto_new_game = ((disabled ~= nil) and not disabled) or false
end



tfm.exec.disableAutoTimeLeft = function(disabled)
	namespace.auto_time_left = ((disabled ~= nil) and not disabled) or false
end



tfm.exec.disableAutoShaman = function(disabled)
	namespace.auto_shaman = ((disabled ~= nil) and not disabled) or false
end



tfm.exec.disableAfkDeath = function(disabled)
	namespace.afk_death = ((disabled ~= nil) and not disabled) or false
	return namespace.OriginalTFMDisableAfkDeath(disabled)
end



return namespace
