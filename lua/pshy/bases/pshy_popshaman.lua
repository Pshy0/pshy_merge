--- pshy_popshaman.lua
--
-- Choose the next shaman.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require_priority WRAPPER
local pshy = pshy or {}



--- Internal Use:
local shamans = {}
local previous_shamans = {}



--- Choose a shaman from their score.
-- The shaman score will be reset to 0 on the next game.
-- @param auto_shaman Turn the player to a shaman (false to handle this yourself).
-- @return The Name#0000 of the player to become shaman.
-- @TODO: choose a shaman that wasnt a shaman last round if possible
function pshy.popshaman_PopShaman(auto_shaman)
	local highest_score_player = nil
	local highest_score = -2
	for player_name, player in pairs(tfm.get.room.playerList) do
		if player.score > highest_score and not shamans[player_name] then
			highest_score = player.score
			highest_score_player = player_name
		end
	end
	if not highest_score_player then
		-- no player can be shaman
		return nil
	end
	shamans[highest_score_player] = true
	if auto_shaman then
		tfm.exec.setShaman(highest_score_player, true)
	end
	return highest_score_player
end



function eventGameEnded()
	for shaman_name in pairs(shamans) do
		tfm.exec.setPlayerScore(shaman_name, 0, false)
	end
	previous_shamans = shamans
	shamans = {}
end



function eventNewGame()
	for shaman_name in pairs(shamans) do
		tfm.exec.setPlayerScore(shaman_name, 0, false)
	end
	previous_shamans = shamans
	shamans = {}
end
