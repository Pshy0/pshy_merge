--- pshy.rotations.list
--
-- List of maps and rotations.
-- Custom settings may be used by other modules.
--
-- Listed map and rotation tables can have the following fields:
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



--- Rotations Map:
local rotations = {}					-- map of rotations



--- Aliases:
pshy.mapdb_rotation_aliases = {}



--- Get a rotation table.
function pshy.mapdb_GetRotation(rotation_name)
	while pshy.mapdb_rotation_aliases[rotation_name] do
		rotation_name = pshy.mapdb_rotation_aliases[rotation_name]
	end
	return rotations[rotation_name]
end



function eventInit()
	for rotation_name, rotation in pairs(rotations) do
		rotation.name = rotation.name or rotation_name
	end
end



return rotations
