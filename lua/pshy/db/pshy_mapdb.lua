--- pshy_mapdb.lua
--
-- Handle advanced map features and rotations.
-- Override `tfm.exec.newGame` for easy usage.
--
-- This script may list maps from other authors.
--
-- @author: TFM:Pshy#3752 DC:Pshy#7998 (script)
-- @require pshy_rotation.lua



--- Module Settings:
pshy.mapdb_rotation_name = nil			-- default rotation, can be a rotation of rotations
pshy.mapdb_maps = {}					-- map of maps
pshy.mapdb_rotations = {}				-- map of rotations



--- Defaults/Examples:
pshy.mapdb_maps["pshy_first_troll"] = {author = "Pshy#3752", func_begin = nil, func_end = nil, func_replace = nil, xml = '<C><P F="0" /><Z><S><S H="250" X="400" L="100" Y="275" c="3" P="0,0,0.3,0.2,0,0,0,0" T="5" /><S H="250" X="430" L="30" Y="290" c="1" P="1,0,0,1.2,0,0,0,0" T="2" /><S H="250" L="30" Y="290" c="1" X="370" P="1,0,0,1.2,0,0,0,0" T="2" /><S X="400" L="10" Y="392" H="10" P="0,0,0,14.0,0,0,0,0" T="2" /><S X="406" L="10" Y="184" H="10" P="1,0,0,0.2,0,0,5,0" T="1" /><S X="394" L="10" Y="184" H="10" P="1,0,0,0.2,0,0,5,0" T="1" /><S X="400" L="10" Y="170" H="10" P="0,0,0,1.2,0,0,0,0" T="2" /><S X="400" L="98" Y="156" H="10" P="0,0,0.3,0.2,0,0,0,0" T="0" /><S X="400" L="100" Y="275" c="4" H="250" P="0,0,0.3,0.2,0,0,0,0" T="6" /></S><D><DS X="435" Y="134" /><DC X="367" Y="133" /><T X="400" Y="148" /><F X="312" Y="358" /><F X="484" Y="357" /></D><O><O C="11" X="430" P="0" Y="410" /><O C="11" X="370" P="0" Y="410" /></O></Z></C>'}
pshy.mapdb_rotations["pshy_troll_maps"] = {items = "pshy_first_troll"}



--- Internal Use:
pshy.mapdb_current_map_name = nil
pshy.mapdb_current_map = nil
pshy.mapdb_event_new_game_triggered = false



--- TFM.exec.newGame override.
-- @private
-- @brief mapcode Either a map code or a map rotation code.
function pshy.mapdb_newGame(mapcode)
	pshy.mapdb_EndMap()
	pshy.mapdb_event_new_game_triggered = false
	return pshy.mapdb_Next(mapcode)
end
pshy.mapdb_tfm_newGame = tfm.exec.newGame
tfm.exec.newGame = pshy.mapdb_newGame



--- End the previous map.
-- @private
function pshy.mapdb_EndMap()
	if pshy.mapdb_current_map and pshy.mapdb_current_map.func_end then
		pshy.mapdb_current_map.func_end(pshy.mapdb_current_map_name)
	end
	pshy.mapdb_current_map_name = nil
	pshy.mapdb_current_map = nil
end



--- Setup the next map (possibly a rotation), calling newGame.
-- @private
function pshy.mapdb_Next(mapcode)
	if mapcode == nil then
		mapcode = pshy.mapdb_rotation_name
	end
	if pshy.mapdb_maps[mapcode] then
		return pshy.mapdb_NextDBMap(mapcode)
	end
	if pshy.mapdb_rotations[mapcode] then
		return pshy.mapdb_NextDBRotation(mapcode)
	end
	if tonumber(mapcode) then
		pshy.mapdb_current_map_name = mapcode
		return pshy.mapdb_tfm_newGame(mapcode)
	end
	--if #mapcode > 32 then
	--	-- probably an xml
	--	return pshy.mapdb_tfm_newGame(mapcode)
	--end
	return pshy.mapdb_tfm_newGame(mapcode)
end



--- pshy.mapdb_newGame but only for maps listed to this module.
-- @private
function pshy.mapdb_NextDBMap(map_name)
	local map = pshy.mapdb_maps[map_name]
	pshy.mapdb_current_map_name = map_name
	pshy.mapdb_current_map = map
	local map_xml
	if map.xml then
		map_xml = map.xml
	else
		map_xml = map_name
	end
	if map.func_replace then
		map_xml = map.func_replace(map.xml)
	end
	return pshy.mapdb_tfm_newGame(map_xml)
end



--- pshy.mapdb_newGame but only for rotations listed to this module.
-- @private
function pshy.mapdb_NextDBRotation(rotation_name)
	local rotation = pshy.mapdb_rotations[rotation_name]
	pshy.mapdb_current_rotation_name = rotation_name
	pshy.mapdb_current_rotation = rotation
	local next_map_name = pshy.rotation_Next(rotation)
	return pshy.mapdb_Next(next_map_name)
end



--- TFM event eventNewGame.
function eventNewGame()
	if not pshy.mapdb_event_new_game_triggered then
		if pshy.mapdb_current_map and pshy.mapdb_current_map.func_begin then
			pshy.mapdb_current_map.func_begin(pshy.mapdb_current_map_name)
		end
	else
		-- tfm loaded a new map
		pshy.mapdb_EndMap()
	end
	pshy.mapdb_event_new_game_triggered = true
end
