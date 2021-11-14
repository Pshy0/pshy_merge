--- pshy_mapinfo.lua
--
-- Provide a `pshy.mapinfo` table with informations about the current map.
-- This table's fields are:
--	`author`				the map's author
--	`current_map`			equals `tfm.get.room.currentMap`
--  `map_code`				the map's code (equals to `current_map` or nil for vanilla maps)
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
--	`grounds`				a list of grounds with the folowing fields:
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
-- @require pshy_merge.lua
-- @require pshy_mapdb.lua
-- @require pshy_newgame.lua
--
-- @require_priority WRAPPER
pshy = pshy or {}



--- Module Settings (@TODO)
pshy.mapinfo_parse_grounds = true
pshy.mapinfo_parse_shaman_objects = true
pshy.mapinfo_parse_decorations = true



--- Public `pshy.mapinfo` table:
pshy.mapinfo = {}



--- Get a param value from an xml's inner params.
-- @param inner_xml The string containing the params.
-- @param name The name of the field to get the value of.
-- @param convert_function Optional function to apply to the obtained string before returning.
-- @return `nil` or the param's value converted with `convert_function`.
local function GetParam(inner_xml, name, convert_function)
	assert(inner_xml ~= nil, "passed a null inner_xml to GetParam")
	local value_string = string.match(inner_xml, string.format(' %s="(.-)" ', name))
	if not value_string or not convert_function then
		return value_string
	end
	return convert_function(value_string)
end



--- Update `pshy.mapinfo`'s fields related to the xml code only.
-- Does not reset the table.
function pshy.mapinfo_UpdateFromXML()
	local mapinfo = pshy.mapinfo
	local xml = mapinfo.xml
	if not xml then
		if mapinfo.perm_code == "vanilla" then
			print("DEBUG: vanilla map didnt have an xml")
			return
		end
		print("WARN: non-vanilla map didnt have an xml")
		return
	end
	assert(type(xml) == "string", "map didnt have an xml?")
	-- TFM fields
	local map_params = string.match(xml, "<C><P (.-) -/><Z><")
	mapinfo.width = GetParam(map_params, "L", tonumber) or 800
	mapinfo.height = GetParam(map_params, "H", tonumber) or 400
	local map_G = GetParam(map_params, "G", tonumber) or "10;0"
	mapinfo.gravity = tonumber(string.match(map_G, "(.-);"))
	mapinfo.wind = tonumber(string.match(map_G, ";(.-)"))
	mapinfo.collision = GetParam(map_params, "C") or false
	mapinfo.nightmode = GetParam(map_params, "N") or false
	mapinfo.soulmate = GetParam(map_params, "A") or false
	mapinfo.portals = GetParam(map_params, "P") or false
	mapinfo.aie = GetParam(map_params, "aie") or false
	mapinfo.dodue = GetParam(map_params, "dodue", tonumber) or false
	-- mapinfo.shaman_tools = GetParam(map_params, "shaman_tools") or false -- @TODO
	-- Custom fields:
	mapinfo.author = GetParam(map_params, "author") or mapinfo.author
	mapinfo.name = GetParam(map_params, "name") or mapinfo.name
	mapinfo.title = GetParam(map_params, "title") or mapinfo.title
	mapinfo.original = GetParam(map_params, "original") or mapinfo.original
	-- Spawns
	mapinfo.spawns = {}
	for spawn_params in string.gmatch(xml, "><DS [^/]+/><") do
		local spawn = {}
		table.insert(mapinfo.spawns, spawn)
        spawn.x = GetParam(spawn_params, "X", tonumber)
		spawn.y = GetParam(spawn_params, "Y", tonumber)
    end
    -- Shaman spawns
	mapinfo.shaman_spawns = {}
	local dc1_params = string.match(xml, "><DC (.-) -/><")
	if dc1_params then
		table.insert(mapinfo.shaman_spawns, {x = GetParam(dc1_params, "X", tonumber), y = GetParam(dc1_params, "Y", tonumber)})
		local dc2_params = string.match(xml, "><DC2 (.-) -/><")
		if dc2_params then
			table.insert(mapinfo.shaman_spawns, {x = GetParam(dc2_params, "X", tonumber), y = GetParam(dc2_params, "Y", tonumber)})
			-- Custom tri-shamans maps
			local dc3_params = string.match(xml, "><DC3 (.-) -/><")
			if dc3_params then
				table.insert(mapinfo.shaman_spawns, {x = GetParam(dc3_params, "X", tonumber), y = GetParam(dc3_params, "Y", tonumber)})
			end		
		end
	end
	-- @TODO: holes
	-- @TODO: cheeses
	-- Grounds
	-- @TODO: dont handle more than 200 grounds?
	mapinfo.grounds = {}
	for ground_params in string.gmatch(xml, "<S [^/]+/>") do
		local ground = {}
		table.insert(mapinfo.grounds, ground)
		ground.type = GetParam(ground_params, "T", tonumber)
		ground.x = GetParam(ground_params, "X", tonumber)
		ground.y = GetParam(ground_params, "Y", tonumber)
		ground.width = GetParam(ground_params, "L", tonumber)
		ground.height = GetParam(ground_params, "H", tonumber) or ground.width
		ground.foreground = GetParam(ground_params, "N") and true or false
		ground.invisible = GetParam(ground_params, "m") and true or false
		ground.color = GetParam(ground_params, "o") or nil
		ground.collisions = GetParam(ground_params, "c", tonumber) or 1
		ground.lua_id = GetParam(ground_params, "lua", tonumber) or nil
		--ground.vanish_time = GetParam(ground_params, "v", tonumber) or nil
		local ground_properties = pshy.StrSplit2(GetParam(ground_params, "P"), ",")
		assert(#ground_properties == 8, "ground properties had " .. tostring(#ground_properties) .. " fields (" .. ground_params:gsub("<","&lt;"):gsub("<&gt;") .. ")!")
		ground.dynamic = (ground_properties[1] ~= "0")
		ground.mass = tonumber(ground_properties[2])
		ground.friction = tonumber(ground_properties[3])
		ground.restitution = tonumber(ground_properties[4])
		ground.rotation = tonumber(ground_properties[5])
	end
	-- @TODO: Shaman Objects
	-- @TODO: Decorations
end



--- Update `pshy.mapinfo`.
-- This function is called automatically on eventNewGame.
function pshy.mapinfo_Update()
	pshy.mapinfo = {}
	local mapinfo = pshy.mapinfo
	-- Infos from `tfm.get.room`
	mapinfo.current_map = tfm.get.room.currentMap
	-- Infos from `tfm.get.room.xmlMapInfo`
	if tfm.get.room.xmlMapInfo then
		mapinfo.author = tfm.get.room.xmlMapInfo.author
		mapinfo.map_code = tfm.get.room.xmlMapInfo.mapCode
		mapinfo.perm_code = tfm.get.room.xmlMapInfo.permCode
		mapinfo.xml = tfm.get.room.xmlMapInfo.xml
	else
		-- @TODO: handle xml passed to tfm.exec.newGame() ?
		--error("check this case " .. xml:sub(1, 100):gsub("<","&lt;"):gsub("<&gt;"))
		return
	end
	-- Infos from the xml
	pshy.mapinfo_UpdateFromXML()
	-- Infos from `pshy.newgame_...`
	if pshy.newgame_current_map_name then
		mapinfo.name = pshy.newgame_current_map_name
	end
	if pshy.newgame_current_map then
		local newgame_map = pshy.newgame_current_map
		if newgame_map.name then
			mapinfo.name = newgame_map.name
		end
		if newgame_map.author then
			mapinfo.author = newgame_map.author
		end
		if newgame_map.title then
			mapinfo.title = newgame_map.title
		end
	end
	-- @TODO: use mapdb
end



function eventNewGame()
	pshy.mapinfo_Update()
end
