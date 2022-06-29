--- pshy.tfm_emulator.environment.room.lua
--
-- Simulate misc features.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.tfm_emulator.environment.base")
local tfmenv = pshy.require("pshy.compiler.tfmenv")



--- Internal use:
local last_object_id = 0



--- Override of `tfm.exec.addImage`:
tfmenv.env.tfm.exec.addShamanObject = function(...)
	last_object_id = last_object_id + 1
	return last_object_id
end



--- Override function `tfm.exec.setRoomMaxPlayers`:
tfmenv.env.tfm.exec.setRoomMaxPlayers = function(max_players)
	tfmenv.env.tfm.get.room.maxPlayers = max_players
end



--- Override function `tfm.exec.setRoomPassword`:
tfmenv.env.tfm.exec.setRoomPassword = function(password)
	if password then
		tfmenv.env.tfm.get.room.passwordProtected = true
	else
		tfmenv.env.tfm.get.room.passwordProtected = false
	end
	tfmenv.tfm_password = password
end
