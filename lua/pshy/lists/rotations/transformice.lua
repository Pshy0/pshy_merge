--- pshy.lists.rotations.transformice
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script)
local rotations = pshy.require("pshy.lists.rotations")



--- Map Lists:
-- Vanilla:
local maps_vanilla = {}
local deleted_vanilla_maps = {[29] = true, [108] = true, [110] = true, [111] = true, [112] = true, [113] = true, [135] = true, [169] = true, [193] = true, [194] = true, [195] = true, [196] = true, [197] = true, [198] = true, [199] = true}
for i = 0, 210 do
	if not deleted_vanilla_maps[i] then
		table.insert(maps_vanilla, i)
	end
end



--- Basic Rotations.
rotations["vanilla"]		= Rotation:New({desc = "0-210", duration = 120, items = maps_vanilla})
rotations["P0"]				= Rotation:New({desc = "P0 - standard", duration = 120, items = {"#0"}})
rotations["P1"]				= Rotation:New({desc = "P1 - protected", duration = 120, items = {"#1"}})
rotations["P4"]				= Rotation:New({desc = "P4 - shaman", duration = 120, items = {"#4"}})
rotations["P5"]				= Rotation:New({desc = "P5 - art", duration = 120, items = {"#5"}})
rotations["P6"]				= Rotation:New({desc = "P6 - mechanisms", duration = 120, items = {"#6"}})
rotations["P7"]				= Rotation:New({desc = "P7 - no shaman", duration = 60, shamans = 0, items = {"#7"}})
rotations["P8"]				= Rotation:New({desc = "P8 - dual shaman", duration = 60, shamans = 0, items = {"#8"}})
rotations["P9"]				= Rotation:New({desc = "P9 - miscellaneous", duration = 60, shamans = 0, items = {"#9"}})
rotations["P17"]			= Rotation:New({desc = "P17 - racing", duration = 60, shamans = 0, items = {"#17"}})
rotations["P18"]			= Rotation:New({desc = "P18 - defilante", duration = 60, shamans = 0, items = {"#18"}})
rotations["P38"]			= Rotation:New({desc = "P38 - racing test", duration = 60, shamans = 0, items = {"#38"}})
rotations["P66"]			= Rotation:New({desc = "P66 - thematic", duration = 60, shamans = 0, items = {"#66"}})
rotations["transformice"]	= Rotation:New({is_random = false, items = {"vanilla", "#4", "#9", "#5", "#1", "vanilla", "#8", "#6", "#7", "#0"}})



--- Rotation aliases:
pshy.mapdb_rotation_aliases = {}
pshy.mapdb_rotation_aliases["standard"]			= "P0"
pshy.mapdb_rotation_aliases["protected"]		= "P1"
pshy.mapdb_rotation_aliases["shaman"]			= "P4"
pshy.mapdb_rotation_aliases["art"]				= "P5"
pshy.mapdb_rotation_aliases["mechanisms"]		= "P6"
pshy.mapdb_rotation_aliases["nosham"]			= "P7"
pshy.mapdb_rotation_aliases["no_shaman"]		= "P7"
pshy.mapdb_rotation_aliases["dual_shaman"]		= "P8"
pshy.mapdb_rotation_aliases["misc"]				= "P9"
pshy.mapdb_rotation_aliases["miscellaneous"]	= "P9"
pshy.mapdb_rotation_aliases["racing"]			= "P17"
pshy.mapdb_rotation_aliases["defilante"]		= "P18"
pshy.mapdb_rotation_aliases["racing_test"]		= "P38"
pshy.mapdb_rotation_aliases["thematic"]			= "P66"



return rotations
