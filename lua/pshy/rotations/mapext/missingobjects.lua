--- pshy.rotations.mapext.missingobjects
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
local mapinfo = pshy.require("pshy.rotations.mapinfo")
local newgame = pshy.require("pshy.rotations.newgame")
pshy.require("pshy.utils.print")



--- Pshy settings:
mapinfo.max_shaman_objects = math.max(mapinfo.max_shaman_objects, 2)



--- Internal Use:
local object_types_to_spawn = {
	[26] = true;
	[27] = true;
}



--- Check an object.
-- @param obj Shaman object table from `mapinfo.mapinfo.shaman_objects`.
local function CheckObj(obj)
	if obj.type and object_types_to_spawn[obj.type] then
		tfm.exec.addShamanObject(obj.type, obj.x, obj.y, obj.rotation, 0, 0)
	end
end



function eventNewGame()
	if (mapinfo.mapinfo == nil) then
		print_error("mapinfo.mapinfo was nil")
		return
	end
	if mapinfo.mapinfo.shaman_objects then
		for i_obj, obj in ipairs(mapinfo.mapinfo.shaman_objects) do
			CheckObj(obj)
		end
	end
end
