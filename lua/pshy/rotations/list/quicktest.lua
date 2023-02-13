--- pshy.rotations.list.quicktest
--
-- /!\ This script is just a template for testing raw lists of maps.
--
-- @author TFM:Mattseba#0000 (map list)
pshy.require("pshy.bases.lobby")
pshy.require("pshy.debug.watchlogs")
pshy.require("pshy.events")
local rotation_map = pshy.require("pshy.rotations.list")
local newgame = pshy.require("pshy.rotations.newgame")
newgame.delay_next_map = true
pshy.require("pshy.tools.untrustedmaps")
local Rotation = pshy.require("pshy.utils.rotation")
local utils_strings = pshy.require("pshy.utils.strings")



local quicktest_maps_str = [[

]]



local quicktest_maps_list = {

}



local quicktest_maps = utils_strings.Split("\n")
for i, c in ipairs(quicktest_maps_list) do
	quicktest_maps[#quicktest_maps + 1] = c
end
table.insert(quicktest_maps, "lobby")



--- Rotations:
rotation_map["quicktest"]	= Rotation:New({desc = "QUICKTEST", duration = 60, shamans = 0, troll = false, items = quicktest_maps, unique_items = true, is_random = false})
rotation_map["quicktest4s"]	= Rotation:New({desc = "4 SECONDS", duration = 2, shamans = 0, troll = false, items = quicktest_maps, unique_items = true, is_random = false})



local maps_played = 0



function eventInit()
	if __IS_MAIN_MODULE__ then
		maps_played = -1
		newgame.SetRotation("quicktest4s")
	end
end



function eventNewGame()
	maps_played = maps_played + 1
	if __IS_MAIN_MODULE__ then
		ui.setShamanName(string.format(" <n>-  <g>|</g>  Maps played: <vp>%d</vp></n>", maps_played))
	end
end
