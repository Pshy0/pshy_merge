--- pshy_mapdb.lua
--
-- Handle advanced map features and rotations.
-- Override `tfm.exec.newGame` for easy usage.
--
-- This script may list maps from other authors.
--
-- Listed map and rotation tables can have the folowing fields:
--	- func_begin (map only): Function to run when the map started.
--	- func_end (map only): Function to run when the map stopped.
--	- func_replace (map only): Function to run on the rotation item to get the final map.
--	- autoskip: If true, the map will change at the end of the timer.
--	- duration: Duration of the map.
--
-- @author: TFM:Pshy#3752 DC:Pshy#7998 (script)
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_rotation.lua



--- Module Help Page:
pshy.help_pages["pshy_mapdb"] = {back = "pshy", title = "Maps / Rotations", text = "Includes maps from <ch>Nnaaaz#0000</ch>\nIncludes maps from <ch>Pshy#3752</ch>\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_mapdb"] = pshy.help_pages["pshy_mapdb"]



--- Module Settings:
pshy.mapdb_default = "default"			-- default rotation, can be a rotation of rotations
pshy.mapdb_maps = {}					-- map of maps
pshy.mapdb_rotations = {}				-- map of rotations
pshy.mapdb_rotations["default"]			= {hidden = true, items = {}}					-- default rotation, can only use other rotations, no maps
pshy.mapdb_default_rotation 			= pshy.mapdb_rotations["default"]				--



--- Defaults/Examples:
--pshy.mapdb_maps["pshy_first_troll"] = {author = "Pshy#3752", func_begin = nil, func_end = nil, func_replace = nil, xml = '<C><P F="0" /><Z><S><S H="250" X="400" L="100" Y="275" c="3" P="0,0,0.3,0.2,0,0,0,0" T="5" /><S H="250" X="430" L="30" Y="290" c="1" P="1,0,0,1.2,0,0,0,0" T="2" /><S H="250" L="30" Y="290" c="1" X="370" P="1,0,0,1.2,0,0,0,0" T="2" /><S X="400" L="10" Y="392" H="10" P="0,0,0,14.0,0,0,0,0" T="2" /><S X="406" L="10" Y="184" H="10" P="1,0,0,0.2,0,0,5,0" T="1" /><S X="394" L="10" Y="184" H="10" P="1,0,0,0.2,0,0,5,0" T="1" /><S X="400" L="10" Y="170" H="10" P="0,0,0,1.2,0,0,0,0" T="2" /><S X="400" L="98" Y="156" H="10" P="0,0,0.3,0.2,0,0,0,0" T="0" /><S X="400" L="100" Y="275" c="4" H="250" P="0,0,0.3,0.2,0,0,0,0" T="6" /></S><D><DS X="435" Y="134" /><DC X="367" Y="133" /><T X="400" Y="148" /><F X="312" Y="358" /><F X="484" Y="357" /></D><O><O C="11" X="430" P="0" Y="410" /><O C="11" X="370" P="0" Y="410" /></O></Z></C>'}
--pshy.mapdb_rotations["pshy_troll_maps"] = {items = "pshy_first_troll"}



--- Rotations.
-- Basics:
pshy.mapdb_rotations["standard"]					= {desc = "P0", duration = 120, items = {"#0"}}
pshy.mapdb_rotations["protected"]					= {desc = "P1", duration = 120, items = {"#1"}}
pshy.mapdb_rotations["mechanisms"]					= {desc = "P6", duration = 120, items = {"#6"}}
pshy.mapdb_rotations["nosham"]						= {desc = "P7", duration = 60, items = {"#7"}}
pshy.mapdb_rotations["racing"]						= {desc = "P17", duration = 60, items = {"#17"}}
pshy.mapdb_rotations["defilante"]					= {desc = "P18", duration = 60, items = {"#18"}}
pshy.mapdb_rotations["vanilla"]						= {hidden = true, desc = "0-210", duration = 120, items = {}} for i = 0, 210 do table.insert(pshy.mapdb_rotations["vanilla"].items, i) end
pshy.mapdb_rotations["nosham_vanilla"]				= {desc = "0-210*", duration = 60, items = {"2", "8", "11", "12", "14", "19", "22", "24", "26", "27", "28", "30", "31", "33", "40", "41", "44", "45", "49", "52", "53", "55", "57", "58", "59", "61", "62", "65", "67", "69", "70", "71", "73", "74", "79", "80", "85", "86", "89", "92", "96", "100", "117", "119", "120", "121", "123", "126", "127", "138", "142", "145", "148", "149", "150", "172", "173", "174", "175", "176", "185", "189"}}
-- Pshy#3752
pshy.mapdb_rotations["pshy_nosham_troll"]			= {hidden = true, desc = "Pshy#3752", duration = 60, items = {"@7840661"}}
pshy.mapdb_rotations["pshy_nosham_vanilla_troll"]	= {hidden = true, desc = "Pshy#3752", duration = 60, items = {}}
-- Nnaaaz#0000:
pshy.mapdb_rotations["nnaaaz_nosham_troll"]			= {hidden = true, desc = "Nnaaaz#0000", duration = 60, items = {"@7781189", "@7781560", "@7782831", "@7783745", "@7787472", "@7814117", "@7814126", "@7814248", "@7814488", "@7817779"}}
pshy.mapdb_rotations["nnaaaz_nosham_vanilla_troll"]	= {hidden = true, desc = "Nnaaaz#0000", duration = 60, items = {"@7801848", "@7801850", "@7802588", "@7802592", "@7803100", "@7803618", "@7803013", "@7803900", "@7804144", "@7804211"}} -- https://atelier801.com/topic?f=6&t=892706&p=1
pshy.mapdb_rotations["nnaaaz_racing_troll"]			= {hidden = true, desc = "Nnaaaz#0000", duration = 60, items = {"@7781575", "@7783458", "@7783472", "@7784221", "@7784236", "@7786652", "@7786707", "@7786960", "@7787034", "@7788567", "@7788596", "@7788673", "@7788967", "@7788985", "@7788990", "@7789010", "@7789484", "@7789524", "@7790734", "@7790746", "@7790938", "@7791293", "@7791550", "@7791709", "@7791865", "@7791877", "@7792434", "@7765843", "@7794331", "@7794726", "@7792626", "@7794874", "@7795585", "@7796272", "@7799753", "@7800330", "@7800998", "@7801670", "@7805437", "@7792149", "@7809901", "@7809905", "@7810816", "@7812751", "@7789538", "@7813075", "@7813248", "@7814099", "@7819315", "@7815695", "@7815703", "@7816583", "@7816748", "@7817111", "@7782820"}}
-- Mix
pshy.mapdb_rotations["nosham_troll"]				= {hidden = true, desc = "mix of troll maps", duration = 60, items = {}}
for i_map, map in ipairs(pshy.mapdb_rotations["nnaaaz_nosham_troll"].items) do table.insert(pshy.mapdb_rotations["nosham_troll"].items, map) end
for i_map, map in ipairs(pshy.mapdb_rotations["pshy_nosham_troll"].items) do table.insert(pshy.mapdb_rotations["nosham_troll"].items, map) end
pshy.mapdb_rotations["nosham_vanilla_troll"]				= {hidden = true, desc = "mix of troll maps", duration = 60, items = {}}
for i_map, map in ipairs(pshy.mapdb_rotations["nnaaaz_nosham_vanilla_troll"].items) do table.insert(pshy.mapdb_rotations["nosham_vanilla_troll"].items, map) end
for i_map, map in ipairs(pshy.mapdb_rotations["pshy_nosham_vanilla_troll"].items) do table.insert(pshy.mapdb_rotations["nosham_vanilla_troll"].items, map) end
-- Misc:
pshy.mapdb_rotations["nosham_mechanisms"]			= {desc = nil, duration = 60, items = {"@1919402", "@7264140", "@1749725", "@176936", "@3514715", "@3150249", "@3506224", "@2030030", "@479001", "@3537313", "@1709809", "@169959", "@313281", "@2868361", "@73039", "@73039", "@2913703", "@2789826", "@298802", "@357666", "@1472765", "@271283", "@3702177", "@2355739", "@4652835", "@164404", "@7273005", "@3061566", "@3199177", "@157312", "@7021280", "@2093284", "@5752223", "@7070948", "@3146116", "@3613020", "@1641262", "@119884", "@3729243", "@1371302", "@6854109", "@2964944", "@3164949", "@149476", "@155262", "@6196297", "@1789012", "@422271", "@3369351", "@3138985", "@3056261", "@5848606", "@931943", "@181693", "@227600", "@2036283", "@6556301", "@3617986", "@314416", "@3495556", "@3112905", "@1953614", "@2469648", "@3493176", "@1009321", "@221535", "@2377177", "@6850246", "@5761423", "@211171", "@1746400", "@1378678", "@246966", "@2008933", "@2085784", "@627958", "@1268022", "@2815209", "@1299248", "@6883670", "@3495694", "@4678821", "@2758715", "@1849769", "@3155991", "@6555713", "@3477737", "@873175", "@141224", "@2167410", "@2629289", "@2888435", "@812822", "@4114065", "@2256415", "@3051008", "@7300333", "@158813", "@3912665", "@6014154", "@163756", "@3446092", "@509879", "@2029308", "@5546337", "@1310605", "@1345662", "@2421802", "@2578335", "@2999901", "@6205570", "@7242798", "@756418", "@2160073", "@3671421", "@5704703", "@3088801", "@7092575", "@3666756", "@3345115", "@1483745", "@3666745", "@2074413", "@2912220", "@3299750"}}
pshy.mapdb_rotations["nosham_simple"]				= {desc = nil, duration = 120, items = {"@1378332", "@485523", "@7816865", "@763608", "@1616913", "@383202", "@2711646", "@446656", "@815716", "@333501", "@7067867", "@973782", "@763961", "@7833293", "@7833270", "@7833269", "@7815665", "@7815151", "@7833288", "@1482492", "@1301712", "@6714567", "@834490", "@712905", "@602906", "@381669", "@4147040", "@564413", "@504951", "@1345805", "@501364"}} -- soso @1356823 @2048879 @2452915 @2751980
pshy.mapdb_rotations["nosham_traps"]				= {desc = nil, duration = 120, items = {"@297063", "@5940448", "@2080757", "@7453256", "@203292", "@108937", "@445078", "@133916", "@7840661", "@115767", "@2918927", "@4684884", "@2868361", "@192144", "@73039", "@1836340", "@726048"}}
pshy.mapdb_rotations["nosham_coop"]					= {desc = nil, duration = 120, items = {"@169909", "@209567", "@273077", "@7485555", "@2618581", "@133916", "@144888", "@1991022", "@7247621", "@3591685", "@6437833", "@3381659", "@121043", "@180468", "@220037", "@882270", "@3265446"}}
-- vanillart? @3624983 @2958393 @624650 @635128 @510084 @7404832 @3463369
-- coop ?:		@1327222 @161177 @3147926 @3325842
-- troll traps:	@75050 @923485
-- sham troll: @3659540 @6584338
-- almost vanilla sham: @3688504 @2013190
-- lol: @7466942 @696995 @4117469
-- almost lol: @7285161 @1408189
-- sham traps: @171290 @453115



--- Internal Use:
pshy.mapdb_current_map_name = nil
pshy.mapdb_current_map = nil
pshy.mapdb_current_map_autoskip = false
pshy.mapdb_current_map_duration = 60
pshy.mapdb_event_new_game_triggered = false
pshy.mapdb_next = nil
pshy.mapdb_force_next = false
pshy.mapdb_current_rotations_names = {}		-- set rotation names we went by when choosing the map



--- Set the next map
-- @param code Map code.
-- @param force Should the map be forced (even if another map is chosen).
function pshy.mapdb_SetNextMap(code, force)
	pshy.mapdb_next = code
	pshy.mapdb_force_next = force or false
end



--- TFM.exec.newGame override.
-- @private
-- @brief mapcode Either a map code or a map rotation code.
function pshy.mapdb_newGame(mapcode)
	--print("called pshy.mapdb_newGame " .. tostring(mapcode))
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
	pshy.mapdb_current_map_autoskip = nil
	pshy.mapdb_current_map_duration = nil
	pshy.mapdb_current_rotations_names = {}
end



--- Setup the next map (possibly a rotation), calling newGame.
-- @private
function pshy.mapdb_Next(mapcode)
	--print("called pshy.mapdb_Next " .. tostring(mapcode))
	if mapcode == nil or pshy.mapdb_force_next then
		if pshy.mapdb_next then
			mapcode = pshy.mapdb_next
		else
			mapcode = pshy.mapdb_default
		end
	end
	pshy.mapdb_force_next = false
	pshy.mapdb_next = nil
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
	--print("called pshy.mapdb_NextDBMap " .. tostring(mapcode))
	local map = pshy.mapdb_maps[map_name]
	if map.autoskip ~= nil then
		pshy.mapdb_current_map_autoskip = map.autoskip 
	end
	if map.duration ~= nil then
		pshy.mapdb_current_map_duration = map.duration 
	end
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
	--print("called pshy.mapdb_NextDBRotation " .. tostring(mapcode))
	if pshy.mapdb_current_rotations_names[rotation_name] then
		print("<r>/!\\ Cyclic map rotation! Going to nil!</r>")
		return pshy.mapdb_tfm_newGame(nil)
	end
	pshy.mapdb_current_rotations_names[rotation_name] = true
	local rotation = pshy.mapdb_rotations[rotation_name]
	if rotation.autoskip ~= nil then
		pshy.mapdb_current_map_autoskip = rotation.autoskip 
	end
	if rotation.duration ~= nil then
		pshy.mapdb_current_map_duration = rotation.duration 
	end
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
		if pshy.mapdb_current_map_duration then
			tfm.exec.setGameTime(pshy.mapdb_current_map_duration, true)
		end
	else
		-- tfm loaded a new map
		pshy.mapdb_EndMap()
	end
	pshy.mapdb_event_new_game_triggered = true
end



--- TFM event eventLoop.
-- Skip the map when the timer is 0.
function eventLoop(time, time_remaining)
	if pshy.mapdb_current_map_autoskip ~= false and time_remaining <= 0 and time > 3000 then
		tfm.exec.newGame(nil)
	end
end



--- !next [map]
function pshy.mapdb_ChatCommandNext(user, code, force)
	pshy.mapdb_SetNextMap(code, force)
end
pshy.chat_commands["next"] = {func = pshy.mapdb_ChatCommandNext, desc = "set the next map to play (no param to cancel)", argc_min = 0, argc_max = 2, arg_types = {"string", "bool"}, arg_names = {"mapcode", "force"}}
pshy.help_pages["pshy_mapdb"].commands["next"] = pshy.chat_commands["next"]
pshy.perms.admins["!next"] = true
pshy.commands_aliases["np"] = "next"
pshy.commands_aliases["npp"] = "next"



--- !skip [map]
function pshy.mapdb_ChatCommandSkip(user, code)
	pshy.mapdb_next = code or pshy.mapdb_next
	pshy.mapdb_force_next = false
	if not pshy.mapdb_next and #pshy.mapdb_default_rotation.items == 0 then
		return false, "First use !rotw to set the rotations you want to use (use !rots for a list)."
	end
	tfm.exec.newGame(pshy.mapdb_next)
end
pshy.chat_commands["skip"] = {func = pshy.mapdb_ChatCommandSkip, desc = "play a different map right now", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_mapdb"].commands["skip"] = pshy.chat_commands["skip"]
pshy.perms.admins["!skip"] = true
pshy.commands_aliases["map"] = "skip"



--- !rotations
function pshy.mapdb_ChatCommandRotations(user)
	pshy.Answer("Available rotations:", user)
	for rot_name, rot in pairs(pshy.mapdb_rotations) do
		if rot ~= pshy.mapdb_default_rotation then
			local count = pshy.TableCountValue(pshy.mapdb_default_rotation.items, rot_name)
			local s = ((count > 0) and "<vp>" or "<fc>")
			s = s .. ((count > 0) and ("<b> ⚖ " .. tostring(count) .. "</b> \t") or "  - \t\t") .. rot_name
			s = s .. ((count > 0) and "</vp>" or "</fc>")
			s = s ..  ": " .. tostring(rot.desc) .. " (" .. #rot.items .. "#)"
			tfm.exec.chatMessage(s, user)
		end
	end
end
pshy.chat_commands["rotations"] = {func = pshy.mapdb_ChatCommandRotations, desc = "list available rotations", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_mapdb"].commands["rotations"] = pshy.chat_commands["rotations"]
pshy.perms.admins["!rotations"] = true
pshy.chat_command_aliases["rots"] = "rotations"



--- !rotationweigth <name> <value>
function pshy.mapdb_ChatCommandRotw(user, rotname, w)
	if not pshy.mapdb_rotations[rotname] then
		return false, "Unknown rotation."
	end
	if rotname == "default" then
		return false, "It's not rotationception."
	end
	if w == nil then
		w = (pshy.TableCountValue(pshy.mapdb_default_rotation.items, rotname) ~= 0) and 0 or 1
	end
	if w < 0 then
		return false, "Use 0 to disable the rotation."
	end
	if w > 100 then
		return false, "The maximum weight is 100."
	end
	pshy.ListRemoveValue(pshy.mapdb_default_rotation.items, rotname)
	if w > 0 then
		for i = 1, w do
			table.insert(pshy.mapdb_default_rotation.items, rotname)
		end
	end
	pshy.rotation_Reset(pshy.mapdb_default_rotation)
end
pshy.chat_commands["rotationweigth"] = {func = pshy.mapdb_ChatCommandRotw, desc = "set a rotation's frequency weight", argc_min = 1, argc_max = 2, arg_types = {"string", "number"}}
pshy.help_pages["pshy_mapdb"].commands["rotationweigth"] = pshy.chat_commands["rotationweigth"]
pshy.perms.admins["!rotationweigth"] = true
pshy.chat_command_aliases["rotw"] = "rotationweigth"
