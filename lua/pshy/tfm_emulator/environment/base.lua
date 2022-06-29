--- pshy.tfm_emulator.environment.base
--
-- Define basic values and placeholder functions accessible to TFM modules.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local tfmenv = pshy.require("pshy.compiler.tfmenv")



--- Abort if the emulator is ran in TFM or with itself:
if not os.exit and system.exit and tfm then
	error("<r>The emulator script cannot run in TFM! Run it in a Lua terminal instead!</r>")
end



--- Settings:
tfmenv.log_events = true
