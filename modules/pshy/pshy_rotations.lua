--- pshy_rotations.lua
--
-- This module allow to customize the maps rotation.
-- For antileve, see the pshy_anticheat.lua module.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_utils.lua
-- @require pshy_help.lua



--- Module Help Page:
pshy.help_pages["pshy_rotations"] = {back = "pshy", text = "This module allows to control the way maps rotate.\n", examples = {}, commands = {}}
--pshy.help_pages["pshy_rotations"].examples["luaset pshy.rotations_alive_shorting_player_count 3"] = "Short the timer when only 3 players are alive."
--pshy.help_pages["pshy_rotations"].examples["luaset pshy.rotations_alive_shorting_time 5"] = "Set the time remaining after a few players are alive to 5 seconds."
--pshy.help_pages["pshy_rotations"].examples["luaset pshy.rotations_win_shorting_player_count 3"] = "Short the timer when 3 players won."
--pshy.help_pages["pshy_rotations"].examples["luaset pshy.rotations_win_shorting_time 10"] = "Set the time remaining after a few players won to 10 seconds."
pshy.help_pages["pshy"].subpages["pshy_rotations"] = pshy.help_pages["pshy_rotations"]



--- Module Settings:
-- Map rotations consist of the given fields:
--	maps			- list of randomly selected maps
--	duration		- duration of each game
--	weight 		- integer representing the default frequency of the rotation
--	chance 		- 0, change at runtime, used to choose the next map
--	hidden 		- if true, will not show in the interface
--	map_replace_func	- function that will be called with the map name and should return a replacement
pshy.rotations	= {}					-- map of rotations
pshy.rotations["standard"]			= {desc = "P0", duration = 120, weight = 0, maps = {"#0"}, chance = 0}
pshy.rotations["protected"]			= {desc = "P1", duration = 120, weight = 0, maps = {"#1"}, chance = 0}
pshy.rotations["mechanisms"]			= {desc = "P6", duration = 120, weight = 0, maps = {"#6"}, chance = 0}
pshy.rotations["nosham"]			= {desc = "P7", duration = 60, weight = 0, maps = {"#7"}, chance = 0}
pshy.rotations["nosham_troll"]		= {hidden = true, desc = "Nnaaaz#0000", duration = 60, weight = 0, maps = {"@7781189", "@7781560", "@7782831", "@7783745", "@7787472", "@7814117", "@7814126", "@7814248", "@7814488", "@7817779"}, chance = 0}
pshy.rotations["racing"]			= {desc = "P17", duration = 60, weight = 1, maps = {"#17"}, chance = 0}
pshy.rotations["racing_troll"]		= {hidden = true, desc = "Nnaaaz#0000", duration = 60, weight = 0, maps = {"@7781575", "@7783458", "@7783472", "@7784221", "@7784236", "@7786652", "@7786707", "@7786960", "@7787034", "@7788567", "@7788596", "@7788673", "@7788967", "@7788985", "@7788990", "@7789010", "@7789484", "@7789524", "@7790734", "@7790746", "@7790938", "@7791293", "@7791550", "@7791709", "@7791865", "@7791877", "@7792434", "@7765843", "@7794331", "@7794726", "@7792626", "@7794874", "@7795585", "@7796272", "@7799753", "@7800330", "@7800998", "@7801670", "@7805437", "@7792149", "@7809901", "@7809905", "@7810816", "@7812751", "@7789538", "@7813075", "@7813248", "@7814099", "@7819315", "@7815695", "@7815703", "@7816583", "@7816748", "@7817111", "@7782820"}, chance = 0}
pshy.rotations["defilante"]			= {desc = "P18", duration = 60, weight = 0, maps = {"#18"}, chance = 0}
pshy.rotations["vanilla"]			= {desc = "1-210", duration = 120, weight = 0, maps = {}, chance = 0} for i = 0, 210 do table.insert(pshy.rotations["vanilla"].maps, i) end
pshy.rotations["nosham_vanilla_troll"]	= {hidden = true, desc = "Nnaaaz#0000", duration = 60, weight = 0, maps = {"@7801848", "@7801850", "@7802588", "@7802592", "@7803100", "@7803618", "@7803013", "@7803900", "@7804144", "@7804211"}, chance = 0} -- https://atelier801.com/topic?f=6&t=892706&p=1
pshy.rotations["nosham_vanilla"]		= {desc = "1-210*", duration = 60, weight = 1, maps = {"2", "8", "11", "12", "14", "19", "22", "24", "26", "27", "28", "30", "31", "33", "40", "41", "44", "45", "49", "52", "53", "55", "57", "58", "59", "61", "62", "65", "67", "69", "70", "71", "73", "74", "79", "80", "85", "86", "89", "92", "96", "100", "117", "119", "120", "121", "123", "126", "127", "138", "142", "145", "148", "149", "150", "172", "173", "174", "175", "176", "185", "189"}, chance = 0}
pshy.rotations["nosham_mechanisms"]		= {desc = nil, duration = 60, weight = 0, maps = {"@176936", "@3514715", "@3150249", "@2030030", "@479001", "@3537313", "@1709809", "@169959", "@313281", "@2868361", "@73039", "@73039", "@2913703", "@2789826", "@298802", "@357666", "@1472765", "@271283", "@3702177", "@2355739", "@4652835", "@164404", "@7273005", "@3061566", "@3199177", "@157312", "@7021280", "@2093284", "@5752223", "@7070948", "@3146116", "@3613020", "@1641262", "@119884", "@3729243", "@1371302", "@6854109", "@2964944", "@3164949", "@149476", "@155262", "@6196297", "@1789012", "@422271", "@3369351", "@3138985", "@3056261", "@5848606", "@931943", "@181693", "@227600", "@2036283", "@6556301", "@3617986", "@314416", "@3495556", "@3112905", "@1953614", "@2469648", "@3493176", "@1009321", "@221535", "@2377177", "@6850246", "@5761423", "@211171", "@1746400", "@1378678", "@246966", "@2008933", "@2085784", "@627958", "@1268022", "@2815209", "@1299248", "@6883670", "@3495694", "@4678821", "@2758715", "@1849769", "@3155991", "@6555713", "@3477737", "@873175", "@141224", "@2167410", "@2629289", "@2888435", "@812822", "@4114065", "@2256415", "@3051008", "@7300333", "@158813", "@3912665", "@6014154", "@163756", "@3446092", "@509879", "@2029308", "@5546337", "@1310605", "@1345662", "@2421802", "@2578335", "@2999901", "@6205570", "@7242798", "@756418", "@2160073", "@3671421", "@5704703", "@3088801", "@7092575", "@3666756", "@3345115", "@1483745", "@3666745", "@2074413", "@2912220", "@3299750"}, chance = 0}
pshy.rotations["burlas"]			= {desc = "Ctmce#0000", duration = 60, weight = 0, maps = {"@7652017" , "@7652019" , "@7652033" , "@7652664" , "@5932565" , "@7652667" , "@7652670" , "@7652674" , "@7652679" , "@7652686" , "@7652691" , "@7652790" , "@7652791" , "@7652792" , "@7652793" , "@7652796" , "@7652797" , "@7652798" , "@7652944" , "@7652954" , "@7652958" , "@7652960" , "@7007413" , "@7653108" , "@7653124" , "@7653127" , "@7653135" , "@7653136" , "@7653139" , "@7653142" , "@7653144" , "@7653149" , "@7653151" , "@7420052" , "@7426198" , "@7426611" , "@7387658" , "@7654229" , "@7203871" , "@7014223" , "@7175013" , "@7165042" , "@7154662" , "@6889690" , "@6933442" , "@7002430" , "@6884221" , "@6886514" , "@6882315" , "@6927305" , "@7659190" , "@7659197" , "@7659203" , "@7659205" , "@7659208" , "@7660110" , "@7660117" , "@7660104" , "@7660502" , "@7660703" , "@7660704" , "@7660705" , "@7660706" , "@7660709" , "@7660710" , "@7660714" , "@7660716" , "@7660718" , "@7660721" , "@7660723" , "@7660727" , "@7661057" , "@7661060" , "@7661062" , "@7661063" , "@7661067" , "@7661072" , "@7662547" , "@7662555" , "@7662559" , "@7662562" , "@7662565" , "@7662566" , "@7662569" , "@7662759" , "@7662768" , "@7662777" , "@7662780" , "@7662796" , "@7663423" , "@7663428" , "@7663429" , "@7663430" , "@7663432" , "@7663435" , "@7663437" , "@7663438" , "@7663439" , "@7663440" , "@7663444" , "@7663445"}, chance = 0}
pshy.rotations["nosham_almost_vanilla"]	= {desc = nil, duration = 120, weight = 0, maps = {"@602906", "@381669", "@4147040", "@564413", "@504951", "@1345805", "@501364"}, chance = 0} -- soso @1356823 @2048879 @2452915 @2751980
--pshy.rotations["NOSHAM_TRAPS"]		= {desc = nil, duration = 120, weight = 0, maps = {"@5940448", "@2080757", "@7453256", "@203292", "@108937", "@445078", "@133916", "@7840661", "@115767", "@2918927", "@4684884", "@2868361", "@192144", "@73039", "@1836340", "@726048"}, chance = 0} -- sham: @171290 @453115
--pshy.rotations["NOSHAM_COOP"]		= {desc = "vanilla", duration = 120, weight = 0, maps = {"@169909", "@209567", "@273077", "@7485555", "@2618581", "@133916", "@144888", "@1991022", "@7247621", "@3591685", "@6437833", "@3381659", "@121043", "@180468", "@220037", "@882270", "@3265446"}, chance = 0}
-- coop ?:		@1327222 @161177 @3147926 @3325842
-- troll traps:	@75050
pshy.rotations_randomness = 0.5			-- randomness of the rotations selection ([0.0-1.0[)
pshy.rotations_auto_next_map = true			-- change map at the end of timer
pshy.rotations_win_shorting_player_count = 1		-- amount of players who need to win for the timer to be shorted
pshy.rotations_win_shorting_time = 5			-- time
pshy.rotations_alive_shorting_player_count = 0	-- amount of players who need to remain alive for the timer to be shorted
pshy.rotations_alive_shorting_time = 3		-- time



--- Module state (internal use)
pshy.rotations_a_player_recently_died = false
pshy.rotations_current_map_win_count = 0
pshy.rotations_skip_requested = false			-- set by !skip
pshy.rotations_next_map_name = nil			-- set by !next <map_name> (can be a rotation name as well)
pshy.rotations_current = nil				-- represent the current rotation, set before changing



--- Get Total map's probability weight
function pshy.RotationsTotalWeight()
	local total = 0
	for rot_name, rot in pairs(pshy.rotations) do
		total = total + rot.weight
	end
	return total
end



--- Pop a map in a rotation
-- @param rotation Rotation table or name.
function pshy.RotationsPopRotationMap(rotation)
	rotation = (type(rotation) == "string") and pshy.rotations[rotation] or rotation
	assert(type(rotation) == "table")
	-- reset rotation next map candidates if needed
	if not rotation.next_maps or #rotation.next_maps == 0 then
		rotation.next_maps = {}
		for i_map, map_name in ipairs(rotation.maps) do
			table.insert(rotation.next_maps, map_name)
		end
	end
	-- random map from rotation
	local i_map = math.random(1, #rotation.next_maps)
	local next_map = rotation.next_maps[i_map]
	if rotation.map_replace_func then
		next_map = rotation.map_replace_func(next_map)
	end
	table.remove(rotation.next_maps, i_map)
	return next_map
end



--- Start the next map.
-- This take the current rotation settings into account.
function pshy.RotationNext(next_map)
	local next_rotation = nil
	local total_weight = pshy.RotationsTotalWeight()
	if next_map then
		pshy.rotations_next_map_name = next_map
	end
	-- choose rotation and map
	if pshy.rotations[pshy.rotations_next_map_name] then
		-- enforced rotation
		next_rotation = pshy.rotations[pshy.rotations_next_map_name]
	elseif pshy.rotations_next_map_name then
		-- enforced map
		if string.sub(pshy.rotations_next_map_name, 1, 1) == "@" then
			pshy.rotations_next_map_name = string.sub(pshy.rotations_next_map_name, 2, #pshy.rotations_next_map_name)
		end
		pshy.rotations_current = nil
		tfm.exec.newGame(pshy.rotations_next_map_name, nil)
		pshy.rotations_next_map_name = nil
		return
	else
		-- random rotation
		for rot_name, rot in pairs(pshy.rotations) do
			if rot.weight > 0 then
				rot.random_chance = rot.chance + math.random(-total_weight, total_weight) * pshy.rotations_randomness -- randomize next rotation a little
				if not next_rotation or rot.random_chance > next_rotation.random_chance then
					next_rotation = rot
				end
			end
		end
		-- update rotation chances
		for rot_name, rot in pairs(pshy.rotations) do
			rot.chance = rot.chance + rot.weight
		end
	end
	if not next_rotation then
		tfm.exec.newGame()
		return	
	end
	next_rotation.chance = 0 + (next_rotation.chance - total_weight) * 0.9
	pshy.rotations_current = next_rotation
	-- get a map from the rotation
	local next_map = pshy.RotationsPopRotationMap(next_rotation)
	tfm.exec.newGame(next_map)
end



--- TFM event eventLoop
function eventLoop(current_time, time_remaining)
	-- check players alive
	if pshy.rotations_a_player_recently_died then
		pshy.rotations_a_player_recently_died = false
		if pshy.CountPlayersAlive() <= pshy.rotations_alive_shorting_player_count then
			tfm.exec.setGameTime(pshy.rotations_alive_shorting_time, false)
		end
	end
	-- skip checks the first 3 seconds
	if current_time <= 3500 then
		return
	end
	-- next map request
	if pshy.rotations_skip_requested then
		pshy.RotationNext()
	end
	-- check timer end
	if pshy.rotations_auto_next_map and time_remaining <= 0 then
		pshy.RotationNext()
	end
end



--- TFM event eventPlayerDied
function eventPlayerDied(player_name)
	pshy.rotations_a_player_recently_died = true
end



--- TFM event eventPlayerWon
function eventPlayerWon(player_name)
	pshy.rotations_current_map_win_count = pshy.rotations_current_map_win_count + 1
	if pshy.rotations_win_shorting_player_count >= 0 and pshy.rotations_current_map_win_count >= pshy.rotations_win_shorting_player_count then
		tfm.exec.setGameTime(pshy.rotations_win_shorting_time, false)
	end
end



--- TFM event eventNewGame
function eventNewGame()
	pshy.rotations_a_player_recently_died = false
	pshy.rotations_current_map_win_count = 0
	pshy.rotations_skip_requested = false
	pshy.rotations_next_map_name = nil
	if pshy.rotations_current then
		tfm.exec.setGameTime(pshy.rotations_current.duration, false)
	end
end



--- !rotationweight <rot> <weight>
function pshy.ChatCommandRotationweight(user, rot_name, weight)
	assert(type(rot_name) == "string")
	assert(type(weight) == "number")
	local rotation = pshy.rotations[rot_name]
	if not rotation then
		error("Invalid rotation.")
	end
	rotation.weight = weight
	--tfm.exec.chatMessage(rot_name .. "'s weight set to " .. weight, user)
end
pshy.chat_commands["rotationweight"] = {func = pshy.ChatCommandRotationweight, desc = "Set the frequency weight of a rotation.", argc_min = 2, argc_max = 2, arg_types = {"string", "number"}}
pshy.chat_command_aliases["rotw"] = "rotationweight"
pshy.help_pages["pshy_rotations"].commands["rotw"] = pshy.chat_commands["rotationweight"]



--- !rotations
function pshy.ChatCommandRotations(user, visible)
	arbitrary_id = 78
	-- close
	if visible == false then
		ui.removeTextArea(arbitrary_id, nil)
		return
	end
	-- count total weight
	local total_weight = 0
	for i_rot, rot in pairs(pshy.rotations) do
		total_weight = total_weight + rot.weight
	end
	-- html
	local html = "<b><p align='center'>ROTATIONS</p><font size='12'>"
	for i_rot, rot in pairs(pshy.rotations) do
		if not rot.hidden then
			-- buttons
			html = html .. "<b><font size='18'>"
			if rot.weight > 0 then
				html = html .. "<a href='event:apcmd rotw " .. i_rot .. " " .. tostring(rot.weight - 1) .. "\napcmd rots'><r> - </r></a>"
			else
				html = html .. "<g> - </g>"
			end
			html = html .. "<a href='event:apcmd rotw " .. i_rot .. " " .. tostring(rot.weight + 1) .. "\napcmd rots'><vp>+ </vp></a>"
			html = html .. "</font></b>"
			-- name/desc
			html = html .. "\t" .. ((rot.weight > 0) and "<vp>" or "<bl>") .. "" .. i_rot .. (rot.desc and (" (" .. rot.desc .. ")") or "")
			html = html .. ((rot.weight > 0) and "</vp>" or "</bl>")
			if total_weight > 0 then
				html = html .. "    " .. tostring(math.floor(rot.weight * 100 / total_weight)) .. "% "
			end
			html = html .. "\n"
		end
	end
	html = html .. "</font><p align='right'><a href='event:closeall'>[close]</a></p></b>"
	local ui = pshy.UICreate(html)
	ui.id = arbitrary_id
	ui.x = 20
	ui.y = 60
	ui.w = 240
	ui.h = nil
	ui.border_color = 0xffffff
	ui.back_color = 0x003311
	ui.alpha = 0.6
	pshy.UIShow(ui, nil)
end
pshy.chat_commands["rotations"] = {func = pshy.ChatCommandRotations, desc = "Show the rotations interface ('false' to hide).", argc_min = 0, argc_max = 1, arg_types = {"boolean"}}
pshy.chat_command_aliases["rots"] = "rotations"
pshy.help_pages["pshy_rotations"].commands["rots"] = pshy.chat_commands["rotations"]



--- !skip [map]
function pshy.RotationsSkipMap(map)
	if map then
		pshy.rotations_next_map_name = map
	end
	pshy.rotations_skip_requested = true
end
pshy.chat_commands["skip"] = {func = pshy.RotationsSkipMap, desc = "Skip the current map.", no_user = true, argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.chat_command_aliases["np"] = "skip"
pshy.help_pages["pshy_rotations"].commands["skip"] = pshy.chat_commands["skip"]



--- !next <map>
function pshy.RotationsNextMap(map)
	pshy.rotations_next_map_name = map
end
pshy.chat_commands["next"] = {func = pshy.RotationsNextMap, desc = "Set the next map or rotation.", no_user = true, argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.chat_command_aliases["npp"] = "next"
pshy.help_pages["pshy_rotations"].commands["next"] = pshy.chat_commands["next"]



--- Initialization
tfm.exec.disableAutoTimeLeft(true)
tfm.exec.disableAutoNewGame(true)
