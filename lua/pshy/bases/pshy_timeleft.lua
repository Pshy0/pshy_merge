--- pshy_timeleft.lua
--
-- Handle .
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_utils.lua
-- @require pshy_help.lua
--
-- @deprecated This module was replaced by another.



--- Module Help Page:
pshy.help_pages["pshy_rotations"] = {back = "pshy", title = "Rotations", text = "Set custom map rotation.\n", examples = {}, commands = {}}
--pshy.help_pages["pshy_rotations"].examples["luaset pshy.rotations_alive_shorting_player_count 3"] = "Short the timer when only 3 players are alive."
--pshy.help_pages["pshy_rotations"].examples["luaset pshy.rotations_alive_shorting_time 5"] = "Set the time remaining after a few players are alive to 5 seconds."
--pshy.help_pages["pshy_rotations"].examples["luaset pshy.rotations_win_shorting_player_count 3"] = "Short the timer when 3 players won."
--pshy.help_pages["pshy_rotations"].examples["luaset pshy.rotations_win_shorting_time 10"] = "Set the time remaining after a few players won to 10 seconds."
pshy.help_pages["pshy"].subpages["pshy_rotations"] = pshy.help_pages["pshy_rotations"]



--- Module Settings:
pshy.rotations_randomness = 0.5					-- randomness of the rotations selection ([0.0-1.0[)
pshy.rotations_auto_next_map = true				-- change map at the end of timer
pshy.rotations_win_shorting_player_count = -1	-- amount of players who need to win for the timer to be shorted
pshy.rotations_win_shorting_time = 5			-- time
pshy.rotations_alive_shorting_player_count = 0	-- amount of players who need to remain alive for the timer to be shorted
pshy.rotations_alive_shorting_time = 3			-- time
pshy.mapdb_rotations["rotation"] = {items = {}}
pshy.mapdb_default = "rotation"



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
			html = html .. "<font size='18'>"
			if rot.weight > 0 then
				html = html .. "<a href='event:apcmd rotw " .. i_rot .. " " .. tostring(rot.weight - 1) .. "\napcmd rots'><r> - </r></a>"
			else
				html = html .. "<g> - </g>"
			end
			html = html .. "<a href='event:apcmd rotw " .. i_rot .. " " .. tostring(rot.weight + 1) .. "\napcmd rots'><vp>+ </vp></a>"
			html = html .. "</font>"
			-- name/desc
			html = html .. "\t" .. ((rot.weight > 0) and "<vp>" or "<bl>") .. "" .. i_rot .. (rot.desc and (" (" .. rot.desc .. ")") or "")
			html = html .. ((rot.weight > 0) and "</vp>" or "</bl>")
			if rot.weight > 0 then
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



--- Initialization
tfm.exec.disableAutoTimeLeft(true)
tfm.exec.disableAutoNewGame(true)
