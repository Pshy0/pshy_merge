--- pshy.bonuses.checkpoints
--
-- Custom bonuses list.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local checkpoints = pshy.require("pshy.bases.checkpoints")
local bonuses = pshy.require("pshy.bonuses")
pshy.require("pshy.events")
pshy.require("pshy.images.list.bonuses")



--- Internal Use:
local spawnpoints = {}



--- BonusCheckpoint.
-- Checkpoint the player (if the checkpoint module is available).
function bonuses.callback_BonusCheckpoint(player_name, bonus)
	checkpoints.SetPlayerCheckpoint(player_name, bonus.x, bonus.y)
	tfm.exec.chatMessage("<d>Checkpoint!</d>", player_name)
end
bonuses.types["BonusCheckpoint"] = {image = "17e59dbef1e.png", func = bonuses.callback_BonusCheckpoint}



--- BonusSpawnpoint.
-- Set a player's spawn point.
-- As soon as the player have a spawnpoint, they also will keep the cheese.
function bonuses.callback_BonusSpawnpoint(player_name, bonus)
	local tfm_player = tfm.get.room.playerList[player_name]
	spawnpoints[player_name] = {x = bonus.x, y = bonus.y, has_cheese = tfm_player.hasCheese}
	tfm.exec.chatMessage("<d>Spawnpoint set!</d>", player_name)
end
bonuses.types["BonusSpawnpoint"] = {image = "17bf4c421bb.png", func = bonuses.callback_BonusSpawnpoint}



function eventPlayerDied(player_name)
	if spawnpoints[player_name] then
		tfm.exec.respawnPlayer(player_name)
	end
end



function eventPlayerGetCheese(player_name)
	if spawnpoints[player_name] then
		spawnpoints[player_name].has_cheese = true
	end
end



--- TFM event eventPlayerRespawn.
function eventPlayerRespawn(player_name)
	if spawnpoints[player_name] then
		local spawn = spawnpoints[player_name]
		tfm.exec.movePlayer(player_name, spawn.x, spawn.y, false, -1, -1, false)
		if spawn.has_cheese then
			tfm.exec.giveCheese(player_name)
		end
	end
end



--- TFM event eventnewGame
function eventNewGame()
	spawnpoints = {}
end
