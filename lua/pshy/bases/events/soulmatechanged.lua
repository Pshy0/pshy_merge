--- pshy.bases.events.soulmatechanged
--
-- Adds an event triggered when a soulmate changed
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")



local current_spouses = {}



function eventSoulmateChanged(player_name, soulmate_name)
	current_spouses[player_name] = soulmate_name
end



function eventLoop()
	for player_name, player in pairs(tfm.get.room.playerList) do
		if player.spouseName ~= current_spouses[player_name] then
			eventSoulmateChanged(player_name, player.spouseName)
		end
	end
end



local function TouchPlayer(player_name)
	current_spouses[player_name] = tfm.get.room.playerList[player_name].spouseName
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
end



function eventInit()
	for player_name in pairs(tfm.get.room.playerList) do
		TouchPlayer(player_name)
	end
end
