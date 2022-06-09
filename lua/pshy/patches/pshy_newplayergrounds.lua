--- pshy_newplayergrounds.lua
--
-- Causes new players to see lua grounds
--
-- @author TFM:Pshy#3752 DC:PSHY#7998
--
-- @require pshy_merge.lua


--- Internal Use:
local grounds = {}



local tfm_exec_addPhysicObject = tfm.exec.addPhysicObject
tfm.exec.addPhysicObject = function(id, x, y, definition, ...)
	grounds[id] = {x = x, y = y, definition = definition}
	return tfm_exec_addPhysicObject(id, x, y, definition, ...)
end



local tfm_exec_removePhysicObject = tfm.exec.removePhysicObject
tfm.exec.removePhysicObject = function(id)
	grounds[id] = nil
	return tfm_exec_removePhysicObject(id)
end



function eventNewPlayer(player_name)
	for i_ground, ground in pairs(grounds) do
		if not ground.definition.dynamic then
			tfm_exec_addPhysicObject(i_ground, ground.x, ground.y, ground.definition)
		end
	end
end
