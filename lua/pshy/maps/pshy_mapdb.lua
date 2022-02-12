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



--- Basic Rotations.
pshy.mapdb_rotations["vanilla"]						= {desc = "0-210", duration = 120, items = pshy.mapdb_maps_vanilla}
pshy.mapdb_rotations["standard"]					= {desc = "P0", duration = 120, items = {"#0"}}
pshy.mapdb_rotations["protected"]					= {desc = "P1", duration = 120, items = {"#1"}}
pshy.mapdb_rotations["shaman"]						= {desc = "P4", duration = 120, items = {"#4"}}
pshy.mapdb_rotations["art"]							= {desc = "P5", duration = 120, items = {"#5"}}
pshy.mapdb_rotations["mechanisms"]					= {desc = "P6", duration = 120, items = {"#6"}}
pshy.mapdb_rotations["nosham"]						= {desc = "P7", duration = 60, shamans = 0, items = {"#7"}}
pshy.mapdb_rotations["dual_shaman"]					= {desc = "P9", duration = 60, shamans = 0, items = {"#8"}}
pshy.mapdb_rotations["misc"]						= {desc = "P9", duration = 60, shamans = 0, items = {"#9"}}
pshy.mapdb_rotations["racing"]						= {desc = "P17", duration = 60, shamans = 0, items = {"#17"}}
pshy.mapdb_rotations["defilante"]					= {desc = "P18", duration = 60, shamans = 0, items = {"#18"}}
pshy.mapdb_rotations["racing_test"]					= {desc = "P38", duration = 60, shamans = 0, items = {"#38"}}
pshy.mapdb_rotations["thematic"]					= {desc = "P66", duration = 60, shamans = 0, items = {"#66"}}
pshy.mapdb_rotations["transformice"]				= {is_random = false, items = {"vanilla", "#4", "#9", "#5", "#1", "vanilla", "#8", "#6", "#7", "#66", "#0"}}	
