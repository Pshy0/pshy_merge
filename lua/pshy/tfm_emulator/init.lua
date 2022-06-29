--- pshy.tfm_emulator
--
-- Allow to emulate a TFM Lua module outside of TFM.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local tfmenv = pshy.require("pshy.tfm_emulator.environment")



--- Internal Use:
local load_start_time = os.clock() * 1000



--- Room state before the module is loaded:
function tfmenv.InitBasicTest()
	tfmenv.NewPlayer("Loader#0000")
	tfmenv.NewPlayer("*invite_died")
	tfmenv.NewPlayer("*invite_cheese")
	tfmenv.NewPlayer("*invite_won")
end



--- Simulate that the script have finished loading.
-- This only print stuff.
local function Loaded()
	print(string.format("#lua:   • # [%s][%s] Lua script loaded in %.0f ms (4000 max)", tfmenv.env.tfm.get.room.name, tfmenv.loader, os.clock() * 1000 - load_start_time))
end



--- Example function that runs the script.
function tfmenv.BasicTest()
	-- Initialize room
	tfmenv.NewPlayer("*Souris_65bc")
	tfmenv.ChatMessage("*Souris_65bc", "hello!")
	tfmenv.NewPlayer("*Souris_0000")
	tfmenv.PlayerLeft("*Souris_65bc")
	--tfmenv.time_Add(500)
	--tfmenv.Loop(500, 199500)
	tfmenv.NewPlayer("*Souris_65bc")
	tfmenv.Wait(510)
	tfmenv.PlayerDied("*invite_died")
	tfmenv.PlayerGetCheese("*invite_cheese")
	tfmenv.PlayerGetCheese("*invite_won")
	tfmenv.PlayerWon("*invite_won")
	tfmenv.PlayerLeft("*Souris_65bc")
	tfmenv.PlayerLeft("*Souris_0000")
	--tfmenv.time_Add(500)
	--tfmenv.Loop(1000, 199000)
	tfmenv.Wait(510)
	tfmenv.Mouse(tfmenv.loader)
	tfmenv.Keyboard(tfmenv.loader, 0, true)
	tfmenv.Keyboard(tfmenv.loader, 0, false)
	tfmenv.Keyboard(tfmenv.loader, 1, true)
	tfmenv.Keyboard(tfmenv.loader, 1, false)
	tfmenv.Keyboard(tfmenv.loader, 2, true)
	tfmenv.Keyboard(tfmenv.loader, 2, false)
	tfmenv.Keyboard(tfmenv.loader, 3, true)
	tfmenv.Keyboard(tfmenv.loader, 3, false)
	tfmenv.Keyboard(tfmenv.loader, 33, true)
	tfmenv.Keyboard(tfmenv.loader, 33, false)
	tfmenv.Mouse(tfmenv.loader)
	--tfmenv.time_Add(100)
	tfmenv.Wait(105)
	tfmenv.Mouse(tfmenv.loader)
	--tfmenv.time_Add(400)
	--tfmenv.Loop(1000, 199000)
	tfmenv.PlayerDied(tfmenv.loader)
	tfmenv.PlayerDied("*invite_cheese")
	tfmenv.Wait(1500)
	tfmenv.PlayerWon(tfmenv.loader)
	tfmenv.Wait(500)
	tfmenv.Wait(20 * 1000)
end



function tfmenv.LoadModule(file_name)
	assert(type(file_name) == "string")
	local file = io.open(file_name, "r")
	local source = file:read("*all")
	file:close()
	
	local func = load(source, nil, "t", tfmenv.env)
	local loadstring = loadstring
	local require = require
	local previous_env = _ENV
	_ENV = tfmenv.env
	tfmenv.loaded_module_result = func()
	tfmenv.env = _ENV
	_ENV = previous_env
	Loaded()
end



return tfmenv
