--- pshy.tfm_emulator.environment
--
-- Allow to emulate a TFM Lua module outside of TFM.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.tfm_emulator.environment.base")
pshy.require("pshy.tfm_emulator.environment.callevent")
pshy.require("pshy.tfm_emulator.environment.controls")
pshy.require("pshy.tfm_emulator.environment.game")
pshy.require("pshy.tfm_emulator.environment.players")
pshy.require("pshy.tfm_emulator.environment.room")
pshy.require("pshy.tfm_emulator.environment.tfm_settings")
pshy.require("pshy.tfm_emulator.environment.time")
pshy.require("pshy.tfm_emulator.environment.ui")
return pshy.require("pshy.compiler.tfmenv")
