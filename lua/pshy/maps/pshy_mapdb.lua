--- pshy_mapdb.lua
--
-- List of maps and rotations.
-- Custom settings may be used by other modules.
--
-- Listed map and rotation tables can have the folowing fields:
--	- begin_func: Function to run when the map started.
--	- end_func: Function to run when the map stopped.
--	- replace_func: Function to run on the map's xml (or name if not present) that is supposed to return the final xml.
--	- autoskip: If true, the map will change at the end of the timer.
--	- duration: Duration of the map.
--	- shamans: Count of shamans (Currently, only 0 is supported to disable the shaman).
--	- xml (maps only): The true map's xml code.
--	- hidden (rotations only): Do not show the rotation is being used to players.
--	- modules: list of module names to enable while the map is playing (to trigger events).
--	- troll: bool telling if the rotation itself is a troll (may help other modules about how to handle the rotation).
--	- unique_items: bool telling if the items are supposed to be unique (duplicates are removed on eventInit).
-- See `pshy_madb_misc_maps.lua` for a more complete list of maps and rotations.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script)
-- @require pshy_rotation.lua
--
-- @require_priority UTILS
--
-- @TODO: remove dependencies



--- Module Settings:
pshy.mapdb_maps = {}						-- map of maps
pshy.mapdb_rotations = {}					-- map of rotations



--- Map Lists:
-- Vanilla:
pshy.mapdb_maps_vanilla = {}
local deleted_vanilla_maps = {[29] = true, [108] = true, [110] = true, [111] = true, [112] = true, [113] = true, [135] = true, [169] = true, [193] = true, [194] = true, [195] = true, [196] = true, [197] = true, [198] = true, [199] = true}
for i = 0, 210 do
	if not deleted_vanilla_maps[i] then
		table.insert(pshy.mapdb_maps_vanilla, i)
	end
end



--- Test Map:
pshy.mapdb_maps["test"]						= {author = "Test#0801", title = "Test Map", title_color="#ff7700", background_color = "#FF00FF", xml = [[<C><P F="0" shaman_tools="1,33,102,110,111,202,302,402,608,1002,2802,2,2806" MEDATA=";;;;-0;0:::1-"/><Z><S><S T="6" X="400" Y="250" L="120" H="40" P="0,0,0.3,0.2,0,0,0,0"/></S><D><F X="432" Y="218"/><P X="393" Y="230" T="11" P="0,0"/><DC X="362" Y="213"/><DS X="436" Y="107"/></D><O/><L/></Z></C>]]}
pshy.mapdb_maps["error_map"]				= {author = "Error", duration = 20, title = "an error happened", xml = 7893612}



--- Rotation aliases:
local rotation_aliases = {}
rotation_aliases["standard"]		= "P0"
rotation_aliases["protected"]		= "P1"
rotation_aliases["shaman"]			= "P4"
rotation_aliases["art"]				= "P5"
rotation_aliases["mechanisms"]		= "P6"
rotation_aliases["nosham"]			= "P7"
rotation_aliases["no_shaman"]		= "P7"
rotation_aliases["dual_shaman"]		= "P8"
rotation_aliases["misc"]			= "P9"
rotation_aliases["miscellaneous"]	= "P9"
rotation_aliases["racing"]			= "P17"
rotation_aliases["defilante"]		= "P18"
rotation_aliases["racing_test"]		= "P38"
rotation_aliases["thematic"]		= "P66"



--- Basic Rotations.
pshy.mapdb_rotations["vanilla"]						= {desc = "0-210", duration = 120, items = pshy.mapdb_maps_vanilla}
pshy.mapdb_rotations["P0"]							= {desc = "P0 - standard", duration = 120, items = {"#0"}}
pshy.mapdb_rotations["P1"]							= {desc = "P1 - protected", duration = 120, items = {"#1"}}
pshy.mapdb_rotations["P4"]							= {desc = "P4 - shaman", duration = 120, items = {"#4"}}
pshy.mapdb_rotations["P5"]							= {desc = "P5 - art", duration = 120, items = {"#5"}}
pshy.mapdb_rotations["P6"]							= {desc = "P6 - mechanisms", duration = 120, items = {"#6"}}
pshy.mapdb_rotations["P7"]							= {desc = "P7 - no shaman", duration = 60, shamans = 0, items = {"#7"}}
pshy.mapdb_rotations["P8"]							= {desc = "P8 - dual shaman", duration = 60, shamans = 0, items = {"#8"}}
pshy.mapdb_rotations["P9"]							= {desc = "P9 - miscellaneous", duration = 60, shamans = 0, items = {"#9"}}
pshy.mapdb_rotations["P17"]							= {desc = "P17 - racing", duration = 60, shamans = 0, items = {"#17"}}
pshy.mapdb_rotations["P18"]							= {desc = "P18 - defilante", duration = 60, shamans = 0, items = {"#18"}}
pshy.mapdb_rotations["P38"]							= {desc = "P38 - racing test", duration = 60, shamans = 0, items = {"#38"}}
pshy.mapdb_rotations["P66"]							= {desc = "P66 - thematic", duration = 60, shamans = 0, items = {"#66"}}
pshy.mapdb_rotations["transformice"]				= {is_random = false, items = {"vanilla", "#4", "#9", "#5", "#1", "vanilla", "#8", "#6", "#7", "#66", "#0"}}



--- Get a rotation table.
function pshy.mapdb_GetRotation(rotation_name)
	while rotation_aliases[rotation_name] do
		rotation_name = rotation_aliases[rotation_name]
	end
	return pshy.mapdb_rotations[rotation_name]
end
