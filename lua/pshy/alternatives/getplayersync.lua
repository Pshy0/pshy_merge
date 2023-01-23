--- pshy.alternatives.getplayersync
--
-- Implements tfm.exec.getPlayerSync to not display too many warnings from tfm.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



local have_sync_access = (tfm.exec.getPlayerSync() ~= nil)



--- Replacement for `tfm.exec.getPlayerSync`.
-- Yes, the return is wrong, the goal is only to let modules work without spamming the log.
local function getPlayerSync()
	return nil
end



function eventInit()
	if not have_sync_access then
		tfm.exec.getPlayerSync = getPlayerSync
	end
end
