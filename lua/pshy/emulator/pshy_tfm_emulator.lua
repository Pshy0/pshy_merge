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



--- Internal Use:
local lua_os_clock = pshy.lua_os_clock
local lua_print = pshy.lua_print
local lua_string_format = pshy.lua_string_format
local load_start_time = lua_os_clock() * 1000



--- Room state before the module is loaded:
pshy.tfm_emulator_init_NewPlayer("Pshy#3752")
pshy.tfm_emulator_init_NewPlayer("*invite_died")
pshy.tfm_emulator_init_NewPlayer("*invite_cheese")
pshy.tfm_emulator_init_NewPlayer("*invite_won")



--- Simulate that the script have finished loading.
-- This only print stuff.
function pshy.tfm_emulator_Loaded()
	lua_print(lua_string_format("#lua:   • # [%s][Pshy#3752] Lua script loaded in %.0f ms (4000 max)", tfm.get.room.name, lua_os_clock() * 1000 - load_start_time))
end



--- Example function that runs the script.
function pshy.tfm_emulator_BasicTest()
	-- Initialize room
	pshy.tfm_emulator_Loaded()
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
	pshy.tfm_emulator_Mouse("Pshy#3752", tfm.get.room.playerList["Pshy#3752"].x, tfm.get.room.playerList["Pshy#3752"].y)
	pshy.tfm_emulator_Keyboard("Pshy#3752", 0, true)
	pshy.tfm_emulator_Keyboard("Pshy#3752", 0, false)
	pshy.tfm_emulator_Keyboard("Pshy#3752", 1, true)
	pshy.tfm_emulator_Keyboard("Pshy#3752", 1, false)
	pshy.tfm_emulator_Keyboard("Pshy#3752", 2, true)
	pshy.tfm_emulator_Keyboard("Pshy#3752", 2, false)
	pshy.tfm_emulator_Keyboard("Pshy#3752", 3, true)
	pshy.tfm_emulator_Keyboard("Pshy#3752", 3, false)
	pshy.tfm_emulator_Keyboard("Pshy#3752", 33, true)
	pshy.tfm_emulator_Keyboard("Pshy#3752", 33, false)
	pshy.tfm_emulator_Mouse("Pshy#3752", tfm.get.room.playerList["Pshy#3752"].x + 1, tfm.get.room.playerList["Pshy#3752"].y + 1)
	pshy.tfm_emulator_time_Add(100)
	pshy.tfm_emulator_Mouse("Pshy#3752", tfm.get.room.playerList["Pshy#3752"].x + 1, tfm.get.room.playerList["Pshy#3752"].y + 1)
	pshy.tfm_emulator_time_Add(400)
	pshy.tfm_emulator_Loop(1000, 199000)
end
