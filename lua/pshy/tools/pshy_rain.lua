--- pshy_rain.lua
--
-- Start item rains.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_utils.lua



--- Module's help page.
pshy.help_pages["pshy_rain"] = {back = "pshy", title = "Object Rains", text = "Cause weird rains.", commands = {}}
pshy.help_pages["pshy_rain"].commands = {}
pshy.help_pages["pshy"].subpages["pshy_rain"] = pshy.help_pages["pshy_rain"]



--- Internal use:
pshy.rain_enabled = false
pshy.rain_next_drop_time = 0
pshy.rain_object_types = {}
pshy.rain_spawned_object_ids = {}



--- Random TFM objects.
-- List of objects for random selection.
pshy.rain_random_object_types = {}
table.insert(pshy.rain_random_object_types, 1) -- little box
table.insert(pshy.rain_random_object_types, 2) -- box
table.insert(pshy.rain_random_object_types, 3) -- little board
table.insert(pshy.rain_random_object_types, 6) -- ball
table.insert(pshy.rain_random_object_types, 7) -- trampoline
table.insert(pshy.rain_random_object_types, 10) -- anvil
table.insert(pshy.rain_random_object_types, 17) -- cannon
table.insert(pshy.rain_random_object_types, 33) -- chicken
table.insert(pshy.rain_random_object_types, 39) -- apple
table.insert(pshy.rain_random_object_types, 40) -- sheep
table.insert(pshy.rain_random_object_types, 45) -- little board ice
table.insert(pshy.rain_random_object_types, 54) -- ice cube
table.insert(pshy.rain_random_object_types, 68) -- triangle



--- Get a random TFM object.
function pshy.rain_RandomTFMObjectType()
	return pshy.rain_random_object_types[math.random(1, #pshy.rain_random_object_types)]
end



--- Spawn a random TFM object in the sky.
function pshy.rain_SpawnRandomTFMObject(object_type)
	return tfm.exec.addShamanObject(object_type or pshy.rain_RandomTFMObjectType(), math.random(0, 800), -60, math.random(0, 359), 0, 0, math.random(0, 8) == 0)
end



--- Drop an object in the sky when the rain is active.
-- @private
function pshy.rain_Drop()
	if math.random(0, 1) == 0 then 
		if pshy.rain_object_types == nil then
			local new_id = pshy.rain_SpawnRandomTFMObject()
			table.insert(pshy.rain_spawned_object_ids, new_id)
		else
			local new_object_type = pshy.rain_object_types[math.random(#pshy.rain_object_types)]
			assert(new_object_type ~= nil)
			local new_id = pshy.rain_SpawnRandomTFMObject(new_object_type)
			table.insert(pshy.rain_spawned_object_ids, new_id)
		end
	end
	if #pshy.rain_spawned_object_ids > 8 then
		tfm.exec.removeObject(table.remove(pshy.rain_spawned_object_ids, 1))
	end
end



--- Start the rain.
-- @public
-- @param types The object types/id to be summoning durring the rain.
function pshy.rain_Start(types)
	pshy.rain_enabled = true
	pshy.rain_object_types = types
end



--- Stop the rain.
-- @public
function pshy.rain_Stop()
	pshy.rain_enabled = false
	pshy.rain_object_types = nil
	for i, id in ipairs(pshy.rain_spawned_object_ids) do
		tfm.exec.removeObject(id)
	end
	pshy.rain_spawned_object_ids = {}
end



--- TFM event eventNewGame.
function eventNewGame()
	pshy.rain_next_drop_time = nil
end



--- TFM event eventLoop.
function eventLoop(time, time_remaining)
	if pshy.rain_enabled then
		pshy.rain_next_drop_time = pshy.rain_next_drop_time or time - 1
		if pshy.rain_next_drop_time < time then
			pshy.rain_next_drop_time = pshy.rain_next_drop_time + 500 -- run Tick() every 500 ms only
			pshy.rain_Drop()
		end
	end
end



--- !rain
function pshy.rain_ChatCommandRain(user, ...)
	rains_names = {...}
	if #rains_names ~= 0 then
		pshy.rain_Start(rains_names)
		pshy.Answer("Rain started!", user)
	elseif pshy.rain_enabled then
		pshy.rain_Stop()
		pshy.Answer("Rain stopped!", user)
	else
	 	pshy.rain_Start(nil)
		pshy.Answer("Random rain started!", user)
	end
end
pshy.chat_commands["rain"] = {func = pshy.rain_ChatCommandRain, desc = "start/stop an object/random object rain", argc_min = 0, argc_max = 4, arg_types = {tfm.enum.shamanObject, tfm.enum.shamanObject, tfm.enum.shamanObject, tfm.enum.shamanObject}, arg_names = {"shamanObject", "shamanObject", "shamanObject", "shamanObject"}}
pshy.help_pages["pshy_rain"].commands["rain"] = pshy.chat_commands["rain"]
pshy.perms.admins["!rain"] = true
