--- pshy.alternatives.uniqueplayers
--
-- Replaces a module-team-only variable.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")



local namespace = {}



namespace.have_uniqueplayers_access = tfm.get.room.uniquePlayers ~= nil



if not namespace.have_uniqueplayers_access then



	local unique_players = 0
	for player_name, player in pairs(tfm.get.room.playerList) do
		unique_players = unique_players + 1
	end
	tfm.get.room.uniquePlayers = unique_players



	function eventNewPlayer()
		unique_players = unique_players + 1
		tfm.get.room.uniquePlayers = unique_players
	end



	function eventPlayerLeft()
		unique_players = unique_players - 1
		tfm.get.room.uniquePlayers = unique_players
	end
	
	
	
end



return namespace
