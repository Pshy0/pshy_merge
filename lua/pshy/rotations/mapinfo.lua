--- pshy.rotations.mapinfo
--
-- Provide a `mapinfo.mapinfo` table with informations about the current map.
-- This table's fields are:
--	`author`				the map's author
--	`current_map`			equals `tfm.get.room.currentMap`
--  `map_code`				the map's code (equals to `tfm.get.room.mapCode` or `current_map` (may be a string or a number))
--	`name`					the map's name (by default this is the map's code)
--	`perm_code`				the map's perm code (or "vanilla" or "xml")
--  `title`					title to display in the place of the map's author and name (or nil)
--	`xml`:					the map's xml
--	`width`					the map's width ("L")
--	`height`				the maps's height ("H")
--	`gravity`				the maps's gravity ("G"(1))
--	`wind`					the maps's wind ("G"(2))
--	`collision`				are mice collisions enabled ? ("C")
--	`nightmode`				are the player's field of view limited by darkness ? ("C")
--	`soulmate`				do mic ehave a soulmaye on this map ? ("A")
--	`portals`				do shamans have portals on this map ? ("P")
--	`aie`					do mice take fall/kinetic damage ? ("aie")
--	`dodue`					is the map using multi-cheese mode ? ("dodue")
-- @TODO: utility supports custom features via additional fields such as "id", "reload", "mgoc"
-- @TODO: check what fields adds an editor
--	`original`				the map code of the original map on which the current one is based on ("original").
--	`spawns`				a list of mouse spawn
--	`shaman_spawns`			a list of shaman coords (up to 3)
--	`grounds`				a list of grounds with the following fields:
--		`type`
--		`x`
--		`y`
--		`width`
--		`height`
--		`foreground`
--		`invisible`
--		`color`
--		`collisions`		`4` for no collision
--		`lua_id`
--
-- /!\ To use this module, you need to require it, 
-- but you also need to enable the settings you need (do not touch what you dont use).
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @TODO: handle inverted maps!
-- @TODO: newgame.current_settings.map_name
-- @TODO: map causing error: @5929021 @5651178 @7819384 @7819390 @5858647
pshy.require("pshy.events")
pshy.require("pshy.utils.print")
local newgame



--- Namespace.
local mapinfo = {}



--- Module Settings (@TODO)
mapinfo.parse_grounds = true			-- @TODO
mapinfo.parse_shaman_objects = true		-- @TODO
mapinfo.parse_decorations = true		-- @TODO
mapinfo.max_grounds = 50				-- maximum amount of grounds the script may attempt to retrieve from ther xml
mapinfo.warn_on_big_maps = false



--- Map info table.
mapinfo.mapinfo = {}



--- Internal Use:
local next_new_game_arg = nil
local lua_string_match = string.match
local lua_string_format = string.format
local table_insert = table.insert
local lua_string_gmatch = string.gmatch
local lua_string_find = string.find



--- `tfm.exec.newGame` override.
-- Collect the argument passed to the function.
local tfm_exec_newGame = tfm.exec.newGame
tfm.exec.newGame = function(mapcode, ...)
	next_new_game_arg = mapcode
	--print_debug("pshy_mapinfo: tfm.exec.newGame(%s)", tostring(mapcode))
	return tfm_exec_newGame(mapcode, ...)
end



--- Get a param value from an xml's inner params.
-- @param inner_xml The string containing the params.
-- @param name The name of the field to get the value of.
-- @param convert_function Optional function to apply to the obtained string before returning.
-- @return `nil` or the param's value converted with `convert_function`.
local function GetParam(inner_xml, name, convert_function)
	assert(inner_xml ~= nil, "passed a null inner_xml to GetParam")
	local value_string = lua_string_match(inner_xml, ' ' .. name .. '="(.-)"')
	if not value_string or not convert_function then
		return value_string
	end
	return convert_function(value_string)
end



--- Update `mapinfo.mapinfo`'s fields related to the xml code only.
-- Does not reset the table.
function mapinfo.UpdateFromXML()
	local info = mapinfo.mapinfo
	local xml = info.xml
	if not xml then
		if info.perm_code == "vanilla" then
			print_debug("vanilla map didnt have an xml")
			return
		end
		print_warn("non-vanilla map didnt have an xml")
		return
	end
	assert(type(xml) == "string", "map didnt have an xml?")
	-- TFM fields
	local map_params = lua_string_match(xml, "<C><P( .-) -/><Z><")
	info.width = GetParam(map_params, "L", tonumber) or 800
	info.height = GetParam(map_params, "H", tonumber) or 400
	local map_G = GetParam(map_params, "G") or "0;10"
	info.wind = tonumber(lua_string_match(map_G, "(.-);"))
	info.gravity = tonumber(lua_string_match(map_G, ";(.-)"))
	info.collision = GetParam(map_params, "C") or false
	info.nightmode = GetParam(map_params, "N") or false
	info.soulmate = GetParam(map_params, "A") or false
	info.portals = GetParam(map_params, "P") or false
	info.aie = GetParam(map_params, "aie") or false
	info.dodue = GetParam(map_params, "dodue", tonumber) or false
	-- info.shaman_tools = GetParam(map_params, "shaman_tools") or false -- @TODO
	-- Custom fields:
	info.name = GetParam(map_params, "name") or info.name
	info.author = GetParam(map_params, "author") or info.author
	info.title = GetParam(map_params, "title") or info.title
	info.title_color = GetParam(map_params, "title_color") or info.title_color
	info.original = GetParam(map_params, "original") or info.original
	info.spawns = {}
	local multi_mice_spawn = GetParam(map_params, "DS")
	if multi_mice_spawn and string.sub(multi_mice_spawn, 1, 2) == "m;" then
		multi_mice_spawn = string.sub(multi_mice_spawn, 3, #multi_mice_spawn)
		local it = lua_string_gmatch(multi_mice_spawn, "([^,]+)")
		local x = tonumber(it())
		while x ~= nil do
			local y = tonumber(it())
			local spawn = {}
			spawn.x = x
			spawn.y = y
			table_insert(info.spawns, spawn)
			x = tonumber(it())
		end
	end
	-- mice stuff
	local xml_mice_stuff = lua_string_match(xml, "<D>(.-)</D>")
	if xml_mice_stuff then
		-- Spawns
		for spawn_params in lua_string_gmatch(xml_mice_stuff, "<DS [^/]+/>") do
			local spawn = {}
			table_insert(info.spawns, spawn)
		    spawn.x = GetParam(spawn_params, "X", tonumber)
			spawn.y = GetParam(spawn_params, "Y", tonumber)
		end
		-- Shaman spawns
		info.shaman_spawns = {}
		local dc1_params = lua_string_match(xml_mice_stuff, "<DC( .-) -/>")
		if dc1_params then
			table_insert(info.shaman_spawns, {x = GetParam(dc1_params, "X", tonumber), y = GetParam(dc1_params, "Y", tonumber)})
			local dc2_params = lua_string_match(xml_mice_stuff, "<DC2( .-) -/>")
			if dc2_params then
				table_insert(info.shaman_spawns, {x = GetParam(dc2_params, "X", tonumber), y = GetParam(dc2_params, "Y", tonumber)})
				-- Custom tri-shamans maps
				--local dc3_params = lua_string_match(xml, "><DC3( .-) -/><")
				--if dc3_params then
				--	table.insert(info.shaman_spawns, {x = GetParam(dc3_params, "X", tonumber), y = GetParam(dc3_params, "Y", tonumber)})
				--end
			end
		end
		-- @TODO: holes
		info.holes = {}
		for hole_params in lua_string_gmatch(xml_mice_stuff, "<T [^/]+/>") do
			local hole = {}
			table_insert(info.holes, hole)
		    hole.x = GetParam(hole_params, "X", tonumber)
			hole.y = GetParam(hole_params, "Y", tonumber)
			if #info.holes > 4 and mapinfo.warn_on_big_maps then
				print_warn("pshy_mapinfo: More than %d holes, aborting!", #info.holes)
				break
			end
		end
		-- @TODO: cheeses
	end
	-- Grounds
	-- @TODO: dont handle more than 200 grounds?
	local xml_grounds = lua_string_match(xml, "<S>(.-)</S>")
	info.grounds = {}
	local grounds = info.grounds
	local grounds_count = 0
	local max_grounds = mapinfo.max_grounds
	for ground_params in lua_string_gmatch(xml_grounds, "<S [^/]+/>") do
		local ground = {}
		table_insert(grounds, ground)
		grounds_count = grounds_count + 1
		ground.type = GetParam(ground_params, "T", tonumber)
		ground.x = GetParam(ground_params, "X", tonumber)
		ground.y = GetParam(ground_params, "Y", tonumber)
		ground.width = GetParam(ground_params, "L", tonumber)
		ground.height = GetParam(ground_params, "H", tonumber) or ground.width
		ground.foreground = GetParam(ground_params, "N") and true or false
		ground.invisible = GetParam(ground_params, "m") and true or false
		ground.color = GetParam(ground_params, "o") or nil
		ground.collisions = GetParam(ground_params, "c", tonumber) or nil -- 1 ?
		ground.lua_id = GetParam(ground_params, "lua", tonumber) or nil
		--ground.vanish_time = GetParam(ground_params, "v", tonumber) or nil
		local ground_properties_str = GetParam(ground_params, "P")
		if ground_properties_str then
			local ground_properties_iterator = lua_string_gmatch(ground_properties_str, "([^,]*)(,?)")
			--assert(#ground_properties == 8, "ground properties had " .. tostring(#ground_properties) .. " fields (" .. ground_params:gsub("<","&lt;"):gsub("<&gt;") .. ")!")
			-- @TODO: what are de default values ?
			local tmp
			ground.dynamic = (ground_properties_iterator() == "1")
			tmp = ground_properties_iterator()
			ground.mass = tonumber(tmp) or 0
			tmp = ground_properties_iterator()
			ground.friction = tonumber(tmp) or 0
			tmp = ground_properties_iterator()
			ground.restitution = tonumber(tmp) or 0
			tmp = ground_properties_iterator()
			ground.rotation = tonumber(tmp) or 0
		end
		if grounds_count >= max_grounds and mapinfo.warn_on_big_maps then
			print_warn("mapinfo: More than %d grounds, aborting!", max_grounds)
			break
		end
	end
	-- background & foreground images:
	info.background_images = {}
	local background_images_string = GetParam(map_params, "D") or nil
	if background_images_string then
		for img_str in lua_string_gmatch(background_images_string, "([^;]+)") do
			if lua_string_find(img_str, "/") then
				break
			end
			local fields_func = lua_string_gmatch(img_str, "([^,]+)")
			local new_img = {}
			new_img.image = fields_func()
			new_img.x = tonumber(fields_func())
			new_img.y = tonumber(fields_func())
			table_insert(info.background_images, new_img)
		end
	end
	info.foreground_images = {}
	local foreground_images_string = GetParam(map_params, "d") or nil
	if foreground_images_string then
		for img_str in lua_string_gmatch(foreground_images_string, "([^;]+)") do
			if lua_string_find(img_str, "/") then
				break
			end
			local fields_func = lua_string_gmatch(img_str, "([^,]+)")
			local new_img = {}
			new_img.image = fields_func()
			new_img.x = tonumber(fields_func())
			new_img.y = tonumber(fields_func())
			table_insert(info.foreground_images, new_img)
		end
	end
	-- @TODO: Shaman Objects
	-- @TODO: Decorations
end



function mapinfo.UpdateOrError()
	mapinfo.mapinfo = {}
	local info = mapinfo.mapinfo
	-- Last argument passed to `tfm.exec.newGame`
	if next_new_game_arg then
		info.arg1 = next_new_game_arg
		next_new_game_arg = nil
	end
	-- Infos from `tfm.get.room`
	info.current_map = tfm.get.room.currentMap
	-- Infos from `tfm.get.room.xmlMapInfo`
	if tfm.get.room.xmlMapInfo then
		info.publisher = tfm.get.room.xmlMapInfo.author
		if not string.match(info.publisher, "#....$") then
			info.publisher = info.publisher .. "#0000"
		end
		info.author = tfm.get.room.xmlMapInfo.author
		info.map_code = tfm.get.room.xmlMapInfo.mapCode
		info.perm_code = tfm.get.room.xmlMapInfo.permCode
		info.xml = tfm.get.room.xmlMapInfo.xml
	else
		-- @TODO: handle xml passed to tfm.exec.newGame() ?
		--error("check this case " .. xml:sub(1, 100):gsub("<","&lt;"):gsub("<&gt;"))
		return
	end
	if not info.map_code then
		info.map_code = tfm.get.room.currentMap
	end
	-- Infos from the xml
	mapinfo.UpdateFromXML()
	-- Infos from `newgame....`
	if newgame then
		if newgame.current_settings and newgame.current_settings.map_name then
			info.name = newgame.current_settings.map_name
		end
		if newgame.current_map then
			local newgame_map = newgame.current_map
			if newgame_map.name then
				info.name = newgame_map.name
			end
			if newgame_map.author then
				info.author = newgame_map.author
			end
			if newgame_map.title then
				info.title = newgame_map.title
			end
		end
	end
	-- @TODO: use mapdb
end



--- Update `mapinfo.mapinfo`.
-- This function is called automatically on eventNewGame.
-- @return true on full success, false if an error happened.
function mapinfo.Update()
	mapinfo.mapinfo = {}
	local rst, rtn = pcall(mapinfo.UpdateOrError)
	if not rst then
		print_error("Failed to update mapinfo.mapinfo (%s)", tostring(rtn))
	end
	return rst
end



function eventNewGame()
	mapinfo.Update()
end



function eventInit()
	newgame = pshy.require("pshy.rotations.newgame", true)
end



return mapinfo
