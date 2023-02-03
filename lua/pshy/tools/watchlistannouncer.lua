--- pshy.anticheats.watchlistannouncer
--
-- Send a message to room admins when a joining player is on the watchlist.
-- The watchlist itself is currently private.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script)
local adminchat = pshy.require("pshy.anticheats.adminchat")
local watchlist = pshy.require("pshy.watchlist")
pshy.require("pshy.events")



function eventNewPlayer(player_name)
	if watchlist[player_name] then
		adminchat.Message(string.format("%s is on watchlist (%s).", player_name, watchlist[player_name]))
	end
end
