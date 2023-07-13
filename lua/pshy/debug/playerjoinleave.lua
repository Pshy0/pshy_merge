--- pshy.debug.playerjoinleave
--
-- Simulates a player joining and then immediatelly leaving the room.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.commands")
local help_pages = pshy.require("pshy.help.pages")
local utils_tables = pshy.require("pshy.utils.tables")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Dbg Plyr J/L"}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Internal Use
local any_player
for player_name, player in pairs(tfm.get.room.playerList) do
	any_player = player
	break
end



--- Get a random player name.
local function RandomPlayerName()
	local alphabet = "abcdefghijklmnopqrstuvwxyz_"
	local name = ""
	local name_len = math.random(6, 12)
	for i = 1, name_len do
		local i_alphabet = math.random(1, #alphabet)
		name = name .. string.sub(alphabet, i_alphabet, i_alphabet)
	end
	return name .. "#" .. tostring(math.random(1000, 9999))
end



--- Get a new player table to put in tfm's player list.
local function NewPlayerTable(player_name)
	local player = utils_tables.Copy(any_player)
	player.playerName = player_name
	player.id = math.random(100000, 10000000)
	return player
end



__MODULE__.commands = {
	["playerjoinleave"] = {
		desc = "Simulates a player joining and leaving.",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"string"},
		func = function(user, player_name)
			if not player_name then
				player_name = RandomPlayerName()
			end
			tfm.get.room.playerList[player_name] = NewPlayerTable(player_name)
			_G.eventNewPlayer(player_name)
			_G.eventPlayerLeft(player_name)
			tfm.get.room.playerList[player_name] = nil
			return true, "simulated player " .. player_name
		end
	},
	["playerjoinleaves"] = {
		desc = "Simulates several players joining and leaving.",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"number"},
		func = function(user, player_count)
			for i = 1, player_count do
				__MODULE__.commands.playerjoinleave(user)
			end
		end
	}
}
