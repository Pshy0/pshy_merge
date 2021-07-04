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



--- Module Help Page.
pshy.help_pages["pshy_rotations"] = {back = "pshy", text = "This module allows to control the way maps rotate.\n", examples = {}, commands = {}}
--pshy.help_pages["pshy_rotations"].examples["luaset pshy.rotations_alive_shorting_player_count 3"] = "Short the timer when only 3 players are alive."
--pshy.help_pages["pshy_rotations"].examples["luaset pshy.rotations_alive_shorting_time 5"] = "Set the time remaining after a few players are alive to 5 seconds."
--pshy.help_pages["pshy_rotations"].examples["luaset pshy.rotations_win_shorting_player_count 3"] = "Short the timer when 3 players won."
--pshy.help_pages["pshy_rotations"].examples["luaset pshy.rotations_win_shorting_time 10"] = "Set the time remaining after a few players won to 10 seconds."
pshy.help_pages["pshy"].subpages["pshy_rotations"] = pshy.help_pages["pshy_rotations"]



--- Module Settings.
-- Map rotations consist of the given fields:
--	maps: list of randomly selected maps.
--	duration: duration of each game.
--	weight: integer representing the default frequency of the rotation.
--	chance: 0, change at runtime, used to choose the next map.
pshy.rotations	= {}					-- map of rotations
pshy.rotations["standard"]		= {desc = "P0", duration = 120, weight = 0, maps = {"#0"}, chance = 0}
pshy.rotations["protected"]		= {desc = "P1", duration = 120, weight = 0, maps = {"#1"}, chance = 0}
pshy.rotations["mechanisms"]		= {desc = "P6", duration = 120, weight = 0, maps = {"#6"}, chance = 0}
pshy.rotations["nosham"]		= {desc = "P7", duration = 60, weight = 1, maps = {"#7"}, chance = 0}
pshy.rotations["racing"]		= {desc = "P17", duration = 60, weight = 1, maps = {"#17"}, chance = 0}
pshy.rotations["defilante"]		= {desc = "P18", duration = 60, weight = 0, maps = {"#18"}, chance = 0}
pshy.rotations["vanilla"]		= {desc = "1-210", duration = 120, weight = 0, maps = {}, chance = 0} for i = 0, 210 do table.insert(pshy.rotations["vanilla"].maps, i) end
pshy.rotations["nosham_vanilla"]	= {desc = "1-210*", duration = 60, weight = 0, maps = {"2", "8", "11", "12", "14", "19", "22", "24", "26", "27", "28", "31", "33", "40", "41", "44", "45", "49", "50", "53", "55", "57", "58", "59", "61", "62", "65", "67", "69", "70", "71", "73", "74", "79", "80", "85", "86", "89", "92", "100", "117", "119", "120", "121", "123", "127", "138", "142", "145", "148", "149", "150", "172", "173", "174", "175", "176", "185", "189"}, chance = 0}
pshy.rotations["nosham_mechanisms"]	= {desc = nil, duration = 60, weight = 0, maps = {"@3514715", "@3537313", "@1709809", "@169959", "@313281", "@2868361", "@73039", "@73039", "@2913703", "@2789826", "@298802", "@357666", "@1472765", "@271283", "@3702177", "@2355739", "@4652835", "@164404", "@7273005", "@3061566", "@3199177", "@157312", "@7021280", "@2093284", "@5752223", "@7070948", "@3146116", "@3613020", "@1641262", "@119884", "@3729243", "@1371302", "@6854109", "@2964944", "@3164949", "@149476", "@155262", "@6196297", "@1789012", "@422271", "@3369351", "@3138985", "@3056261", "@5848606", "@931943", "@181693", "@227600", "@2036283", "@6556301", "@3617986", "@314416", "@3495556", "@3112905", "@1953614", "@2469648", "@3493176", "@1009321", "@221535", "@2377177", "@6850246", "@5761423", "@211171", "@1746400", "@1378678", "@246966", "@2008933", "@2085784", "@627958", "@1268022", "@2815209", "@1299248", "@6883670", "@3495694", "@4678821", "@2758715", "@1849769", "@3155991", "@6555713", "@3477737", "@873175", "@141224", "@2167410", "@2629289", "@2888435", "@812822", "@4114065", "@2256415", "@3051008", "@7300333", "@158813", "@3912665", "@6014154", "@163756", "@3446092", "@509879", "@2029308", "@5546337", "@1310605", "@1345662", "@2421802", "@2578335", "@2999901", "@6205570", "@7242798", "@756418", "@2160073", "@3671421", "@5704703", "@3088801", "@7092575", "@3666756", "@3345115", "@1483745", "@3666745", "@2074413", "@2912220", "@3299750"}, chance = 0}
--pshy.rotations["NOSHAM_TRAPS"]	= {desc = nil, duration = 120, weight = 0, maps = {"@5940448", "@203292", "@108937", "@445078", "@133916", "@7840661", "@115767", "@2918927", "@4684884", "@2868361", "@192144", "@73039", "@1836340", "@726048"}, chance = 0} -- sham: @171290 @453115
--pshy.rotations["NOSHAM_COOP"]	= {desc = "vanilla", duration = 120, weight = 0, maps = {"@209567", "@7485555", "@2618581", "@133916", "@144888", "@1991022", "@7247621", "@3591685", "@6437833", "@3381659", "@121043", "@180468", "@220037", "@882270", "@3265446"}, chance = 0}
pshy.rotations_randomness = 0.5			-- randomness of the rotations selection ([0.0-1.0[)
pshy.rotations_auto_next_map = true			-- change map at the end of timer
pshy.rotations_win_shorting_player_count = 1		-- amount of players who need to win for the timer to be shorted
pshy.rotations_win_shorting_time = 5			-- time
pshy.rotations_alive_shorting_player_count = 0	-- amount of players who need to remain alive for the timer to be shorted
pshy.rotations_alive_shorting_time = 5		-- time



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
	-- reset rotation next map candidates if needed
	if not next_rotation.next_maps or #next_rotation.next_maps == 0 then
		next_rotation.next_maps = {}
		for i_map, map_name in ipairs(next_rotation.maps) do
			table.insert(next_rotation.next_maps, map_name)
		end
	end
	-- random map from rotation
	local next_map
	local i_map = math.random(1, #next_rotation.next_maps)
	next_map = next_rotation.next_maps[i_map]
	table.remove(next_rotation.next_maps, i_map)
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
		-- buttons
		html = html .. "<b>"
		if rot.weight > 0 then
			html = html .. "<a href='event:apcmd rotw " .. i_rot .. " " .. tostring(rot.weight - 1) .. "\napcmd rots'><font size='20' color='#ff0000'> - </font></a>"
		else
			html = html .. "      "
		end
		html = html .. "<a href='event:apcmd rotw " .. i_rot .. " " .. tostring(rot.weight + 1) .. "\napcmd rots'><font size='18' color='#00ff00'>+ </font></a>"
		html = html .. "</b></font>"
		-- name/desc
		html = html .. "\t<font color='#" .. ((rot.weight > 0) and "aaffaa" or "aa7777") .. "'>" .. i_rot .. (rot.desc and (" (" .. rot.desc .. ")") or "")
		if total_weight > 0 then
			html = html .. "    " .. tostring(math.floor(rot.weight * 100 / total_weight)) .. "% "
		end
		html = html .. "\n"
	end
	html = html .. "</font><p align='right'><a href='event:closeall'>[close]</a></p></b>"
	local ui = pshy.UICreate(html)
	ui.id = arbitrary_id
	ui.x = 20
	ui.y = 40
	ui.w = 220
	ui.h = nil
	ui.border_color = 0xffffff
	ui.back_color = 0x003311
	ui.alpha = 0.5
	pshy.UIShow(ui, nil)
end
pshy.chat_commands["rotations"] = {func = pshy.ChatCommandRotations, desc = "Show the rotations interface ('false' to hide).", argc_min = 0, argc_max = 1, arg_types = {"boolean"}}
pshy.chat_command_aliases["rots"] = "rotations"
pshy.help_pages["pshy_rotations"].commands["rots"] = pshy.chat_commands["rotations"]



--- !skip
function pshy.ChatCommandSkip(user, map)
	if map then
		pshy.rotations_next_map_name = map
	end
	pshy.rotations_skip_requested = true
end
pshy.chat_commands["skip"] = {func = pshy.ChatCommandSkip, desc = "Skip the current map.", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.chat_command_aliases["np"] = "skip"
pshy.help_pages["pshy_rotations"].commands["skip"] = pshy.chat_commands["skip"]



--- !next
function pshy.ChatCommandNext(user, map)
	pshy.rotations_next_map_name = map
end
pshy.chat_commands["next"] = {func = pshy.ChatCommandNext, desc = "Set the next map or rotation.", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.chat_command_aliases["npp"] = "next"
pshy.help_pages["pshy_rotations"].commands["next"] = pshy.chat_commands["next"]




--- Initialization
tfm.exec.disableAutoTimeLeft(true)
tfm.exec.disableAutoNewGame(true)
