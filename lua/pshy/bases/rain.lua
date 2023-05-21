--- pshy.bases.rain
--
-- Start item rains.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local command_list = pshy.require("pshy.commands.list")
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")



--- Namespace.
local rain = {}



--- Module's help page.
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Object Rains", text = "Cause weird rains.", commands = {}}
help_pages[__MODULE_NAME__].commands = {}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Internal use:
rain.enabled = false
rain.next_drop_time = 0
rain.object_types = {}
rain.spawned_object_ids = {}



--- Random TFM objects.
-- List of objects for random selection.
rain.random_object_types = {}
table.insert(rain.random_object_types, 1) -- little box
table.insert(rain.random_object_types, 2) -- box
table.insert(rain.random_object_types, 3) -- little board
table.insert(rain.random_object_types, 6) -- ball
table.insert(rain.random_object_types, 7) -- trampoline
table.insert(rain.random_object_types, 10) -- anvil
table.insert(rain.random_object_types, 17) -- cannon
table.insert(rain.random_object_types, 33) -- chicken
table.insert(rain.random_object_types, 39) -- apple
table.insert(rain.random_object_types, 40) -- sheep
table.insert(rain.random_object_types, 45) -- little board ice
table.insert(rain.random_object_types, 54) -- ice cube
table.insert(rain.random_object_types, 68) -- triangle



--- Get a random TFM object.
local function RandomTFMObjectType()
	return rain.random_object_types[math.random(1, #rain.random_object_types)]
end



--- Spawn a random TFM object in the sky.
local function SpawnRandomTFMObject(object_type)
	return tfm.exec.addShamanObject(object_type or RandomTFMObjectType(), math.random(0, 800), -60, math.random(0, 359), 0, 0, math.random(0, 8) == 0)
end



--- Drop an object in the sky when the rain is active.
-- @private
function rain.Drop()
	if math.random(0, 1) == 0 then 
		if rain.object_types == nil then
			local new_id = SpawnRandomTFMObject()
			table.insert(rain.spawned_object_ids, new_id)
		else
			local new_object_type = rain.object_types[math.random(#rain.object_types)]
			assert(new_object_type ~= nil)
			local new_id = SpawnRandomTFMObject(new_object_type)
			table.insert(rain.spawned_object_ids, new_id)
		end
	end
	if #rain.spawned_object_ids > 8 then
		tfm.exec.removeObject(table.remove(rain.spawned_object_ids, 1))
	end
end



--- Start the rain.
-- @public
-- @param types The object types/id to be summoning durring the rain.
function rain.Start(types)
	rain.enabled = true
	rain.object_types = types
end



--- Stop the rain.
-- @public
function rain.Stop()
	rain.enabled = false
	rain.object_types = nil
	for i, id in ipairs(rain.spawned_object_ids) do
		tfm.exec.removeObject(id)
	end
	rain.spawned_object_ids = {}
end



--- TFM event eventNewGame.
function eventNewGame()
	rain.next_drop_time = nil
end



--- TFM event eventLoop.
function eventLoop(time, time_remaining)
	if rain.enabled then
		rain.next_drop_time = rain.next_drop_time or time - 1
		if rain.next_drop_time < time then
			rain.next_drop_time = rain.next_drop_time + 500 -- run Tick() every 500 ms only
			rain.Drop()
		end
	end
end



--- !rain
local function ChatCommandRain(user, ...)
	local rains_names = {...}
	if #rains_names ~= 0 then
		rain.Start(rains_names)
		return true, "Rain started!"
	elseif rain.enabled then
		rain.Stop()
		return true, "Rain stopped!"
	else
	 	rain.Start(nil)
	 	return true, "Random rain started!"
	end
end
command_list["rain"] = {perms = "admins", func = ChatCommandRain, desc = "start/stop an object/random object rain", argc_min = 0, argc_max = 4, arg_types = {tfm.enum.shamanObject, tfm.enum.shamanObject, tfm.enum.shamanObject, tfm.enum.shamanObject}, arg_names = {"shamanObject", "shamanObject", "shamanObject", "shamanObject"}}
help_pages[__MODULE_NAME__].commands["rain"] = command_list["rain"]



return rain
