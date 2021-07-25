--- pshy_basic_weathers.lua
--
-- Some basic weathers.
--
-- @cf pshy_weather.lua
-- @author Pshy
-- @require pshy_weather.lua
-- @require pshy_utils.lua
-- @hardmerge
-- @namespace pshy
pshy = pshy or {}



--- Random Rain weather
pshy.weathers.random_object_rain = {}
function pshy.weathers.random_object_rain.Begin()
	pshy.weathers.random_object_rain.object_type_id = pshy.RandomTFMObjectId()
	pshy.weathers.random_object_rain.spawned_object_ids = {}
end
function pshy.weathers.random_object_rain.Tick()
	local self = pshy.weathers.random_object_rain
	if math.random(0, 2) == 0 then 
		local new_id = tfm.exec.addShamanObject(self.object_type_id, math.random(0, 800), -60, math.random(0, 359), 0, 0, math.random(0, 8) == 0)
		table.insert(self.spawned_object_ids, new_id)
	end
	if #self.spawned_object_ids > 8 then
		tfm.exec.removeObject(table.remove(self.spawned_object_ids, 1))
	end
end
function pshy.weathers.random_object_rain.End()
	for i, id in ipairs(pshy.weathers.random_object_rain.spawned_object_ids) do
		tfm.exec.removeObject(id)
	end
	pshy.weathers.random_object_rain.spawned_object_ids = {}
end



--- Snow weather
pshy.weathers.snow = {}
function pshy.weathers.snow.Tick()
	tfm.exec.snow(2, 10)
end
