--- pshy_tfm_emulator_room.lua
--
-- Simulate misc features.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_tfm_emulator_basic_environment.lua
--
-- @require_priority DEBUG
pshy = pshy or {}



--- Internal use:
local last_object_id = 0



--- Override of `tfm.exec.addImage`:
tfm.exec.addShamanObject = function(...)
	last_object_id = last_object_id + 1
	return last_object_id
end



--- Override function `tfm.exec.setRoomMaxPlayers`:
tfm.exec.setRoomMaxPlayers = function(max_players)
	tfm.get.room.maxPlayers = max_players
end



--- Override function `tfm.exec.setRoomPassword`:
tfm.exec.setRoomPassword = function(password)
	if password then
		tfm.get.room.passwordProtected = true
	else
		tfm.get.room.passwordProtected = false
	end
end
