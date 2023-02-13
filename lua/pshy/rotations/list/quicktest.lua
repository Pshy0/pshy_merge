--- pshy.rotations.list.quicktest
--
-- /!\ This script is just a template for testing raw lists of maps.
--
-- @author TFM:Mattseba#0000 (map list)
pshy.require("pshy.events")
local rotation_map = pshy.require("pshy.rotations.list")
local Rotation = pshy.require("pshy.utils.rotation")
local utils_strings = pshy.require("pshy.utils.strings")
local newgame = pshy.require("pshy.rotations.newgame")
pshy.require("pshy.bases.lobby")



local quicktest_maps_str = [[

]]



local quicktest_maps = utils_strings.Split("\n")
table.insert(quicktest_maps, "lobby")



--- Rotations:
rotation_map["quicktest"]	= Rotation:New({desc = "QUICKTEST", duration = 60, shamans = 0, troll = false, items = quicktest_maps, unique_items = true, ordered = true})
rotation_map["quicktest4s"]	= Rotation:New({desc = "4 SECONDS", duration = 4, shamans = 0, troll = false, items = quicktest_maps, unique_items = true, ordered = true})



function eventInit()
	if __MAIN_MODULE_NAME__ == __MODULE_NAME__ then
		newgame.SetRotation("quicktest4s")
	end
end
