--- pshy_tfm_emulator.lua
--
-- Allow to emulate a TFM Lua module outside of TFM.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_tfm_emulator_environment.lua
--
-- @require_priority GAMEPLAY
pshy = pshy or {}



---
--- REPLACE THIS LINE WITH YOUR SCRIPT IF YOU DIDNT BUILD THIS ONE WITH `pshy_merge`!
---



--- Example function that runs the script.
function pshy.tfm_emulator_BasicTest()
	-- Initialize room
	pshy.tfm_emulator_init_NewPlayer("Pshy#3752")
	pshy.tfm_emulator_init_NewPlayer("*invite_died")
	pshy.tfm_emulator_init_NewPlayer("*invite_cheese")
	pshy.tfm_emulator_init_NewPlayer("*invite_won")
	pshy.tfm_emulator_NewPlayer("*Souris_65bc")
	pshy.tfm_emulator_ChatMessage("*Souris_65bc", "hello!")
	pshy.tfm_emulator_NewPlayer("*Souris_0000")
	pshy.tfm_emulator_PlayerLeft("*Souris_65bc")
	pshy.tfm_emulator_time_Add(500)
	pshy.tfm_emulator_Loop(500, 199500)
	pshy.tfm_emulator_NewPlayer("*Souris_65bc")
	pshy.tfm_emulator_PlayerDied("*invite_died")
	pshy.tfm_emulator_PlayerGetCheese("*invite_cheese")
	pshy.tfm_emulator_PlayerGetCheese("*invite_won")
	pshy.tfm_emulator_PlayerWon("*invite_won")
	pshy.tfm_emulator_PlayerLeft("*Souris_65bc")
	pshy.tfm_emulator_PlayerLeft("*Souris_0000")
	pshy.tfm_emulator_time_Add(500)
	pshy.tfm_emulator_Loop(1000, 199000)
end
