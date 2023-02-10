--- pshy.rotations.mapext.missingobjects
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
local mapinfo = pshy.require("pshy.rotations.mapinfo")
local newgame = pshy.require("pshy.rotations.newgame")
pshy.require("pshy.utils.print")



--- Pshy settings:
mapinfo.parse_shaman_objects = true



--- Internal Use:
local object_types_to_spawn = {
	[26] = true;
	[27] = true;
}



--- Check a ground.
-- @param ground Ground table from `mapinfo.mapinfo.grounds`.
local function CheckObj(obj)
	if obj.type and object_types_to_spawn[obj.type] then --  and ground.foreground == true ?
		tfm.exec.addShamanObject(obj.type, obj.x, obj.y, obj.rotation, 0, 0)
	end
end



function eventNewGame()
	if (mapinfo.mapinfo == nil) then
		print_error("mapinfo.mapinfo was nil")
		return
	end
	if (mapinfo.mapinfo.grounds == nil) then
		print_warn("mapinfo.mapinfo.grounds was nil")
		return
	end
	for i_obj, obj in ipairs(mapinfo.mapinfo.shaman_objects) do
		CheckObj(obj)
	end
end
