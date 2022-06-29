--- pshy.tfm_emulator.environment.ui
--
-- Simulate ui functions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.tfm_emulator.environment.base")
local tfmenv = pshy.require("pshy.compiler.tfmenv")



--- Internal use:
local last_image_id = 0



--- Override of `tfm.exec.addImage`:
tfmenv.env.tfm.exec.addImage = function(...)
	last_image_id = last_image_id + 1
	return last_image_id
end
