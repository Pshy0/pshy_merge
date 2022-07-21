--- pshy.utils.tfm
--
-- Basic functions related to TFM.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local utils_lua = pshy.require("pshy.utils.lua")
local utils_strings = pshy.require("pshy.utils.strings")
local utils_tfm = {}



--- Get the display nick of a player.
-- @param player_name The player name.
-- @return either the part of the name before '#' or an entry from `pshy.nicks`.
function utils_tfm.GetPlayerNick(player_name)
	return string.match(player_name, "([^#]*)")
end



--- Find a player's full Name#0000.
-- @param partial_name The beginning of the player name.
-- @return The player full name or (nil, reason).
-- @todo Search in nicks as well.
function utils_tfm.FindPlayerName(partial_name)
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
		if not real_name then
			return nil, "player not found"
		end
		return real_name -- found
	end
end



--- Find a player's full Name#0000 or throw an error.
-- @return The player full Name#0000 (or throw an error).
function utils_tfm.FindPlayerNameOrError(partial_name)
	local real_name, reason = utils_tfm.FindPlayerName(partial_name)
	if not real_name then
		error(reason)
	end
	return real_name
end



--- Convert a tfm enum index to an interger, searching in all tfm enums.
-- Search in bonus, emote, ground, particle and shamanObject.
-- @param index a string, either representing a tfm enum value or integer.
-- @return the existing enum value or nil
function utils_tfm.EnumGet(index)
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
function utils_tfm.CountPlayersAlive()
	local count = 0
	for player_name, player in pairs(tfm.get.room.playerList) do
		if not player.isDead then
			count = count + 1
		end
	end
	return count
end



return utils_tfm
