--- pshy_tfm_utils.lua
--
-- Basic functions related to TFM.
--
-- @author DC:Pshy#7998 TFM:Pshy#3752
-- @hardmerge
-- @namespace pshy
-- @require pshy_perms.lua
-- @require pshy_lua_utils.lua
pshy = pshy or {}



--- Log a message and also display it to the host.
-- @param msg Message to log.
function pshy.Log(msg)
	tfm.exec.chatMessage("log: " .. tostring(msg), pshy.loader)
	print("log: " .. tostring(msg))
end



--- Show the dialog window with a message (simplified)
-- @param player_name The player who see the popup.
-- @param message The message the player will see.
function pshy.Popup(player_name, message)
	ui.addPopup(4097, 0, tostring(message), player_name, 40, 20, 720, true)
end



--- Show a html title at the top of the screen.
-- @param html The html to display, or nil to hide.
-- @param player_name The player name to display the title to, or nil for all players.
function pshy.Title(html, player_name)
	html = html or nil
	player_name = player_name or nil
	local title_id = 82 -- arbitrary random id
	if html then
		ui.addTextArea(title_id, html, player_name, 0, 20, 800, nil, 0x000000, 0x000000, 1.0, true)
	else
		ui.removeTextArea(title_id, player_name)
	end
end



--- Get the display nick of a player.
-- @param player_name The player name.
-- @return either the part of the name before '#' or an entry from `pshy.nicks`.
function pshy.GetPlayerNick(player_name)
	if pshy.nicks and pshy.nicks[player_name] then
		return pshy.nicks[player_name]
	else
		return pshy.StrSplit(player_name, "#", 2)[1]
	end
end



--- Find a player's full Name#0000.
-- @param partial_name The beginning of the player name.
-- @return The player full name or (nil, reason).
-- @todo Search in nicks as well.
function pshy.FindPlayerName(partial_name)
	local player_list = tfm.get.room.playerList
	if player_list[partial_name] then
		return partial_name
	else
		local real_name
		for player_name in pairs(player_list) do
			if string.sub(player_name, 1, #partial_name) == partial_name then
				if real_name then
					return nil, "several players found" -- 2 players have this name
				end
				real_name = player_name
			end
		end
		if pshy.nicks then
			for player_name, nick in pairs(pshy.nicks) do
				if string.sub(nick, 1, #partial_name) == partial_name then
					if real_name then
						return nil, "several players found" -- 2 players have this name
					end
					real_name = player_name
				end
			end
		end
		if not real_name then
			return nil, "player not found"
		end
		return real_name -- found
	end
end



--- Find a player's full Name#0000 or throw an error.
-- @return The player full Name#0000 (or throw an error).
function pshy.FindPlayerNameOrError(partial_name)
	local real_name, reason = pshy.FindPlayerName(partial_name)
	if not real_name then
		error(reason)
	end
	return real_name
end



--- Convert a tfm anum index to an interger, searching in all tfm enums.
-- Search in bonus, emote, ground, particle and shamanObject.
-- @param index a string, either representing a tfm enum value or integer.
-- @return the existing enum value or nil
function pshy.TFMEnumGet(index)
	assert(type(index) == "string")
	local value
	for enum_name, enum in pairs(tfm.enum) do
		value = enum[index]
		if value then
			return value
		end
	end
	return nil
end



--- Get how many players are alive in tfm.get
function pshy.CountPlayersAlive()
	local count = 0
	for player_name, player in pairs(tfm.get.room.playerList) do
		if not player.isDead then
			count = count + 1
		end
	end
	return count
end
