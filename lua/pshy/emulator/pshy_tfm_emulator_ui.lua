--- pshy_tfm_emulator_ui.lua
--
-- Simulate ui functions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_tfm_emulator_basic_environment.lua
--
-- @require_priority DEBUG
pshy = pshy or {}



--- Internal use:
local last_image_id = 0



--- Override of `tfm.exec.addImage`:
tfm.exec.addImage = function(...)
	last_image_id = last_image_id + 1
	return last_image_id
end
