--- pshy_bonuses_mario.lua
--
-- Mario related bonuses.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_bonuses.lua
-- @require pshy_checkpoints.lua
-- @require pshy_imagedb_bonuses.lua
-- @require pshy_merge.lua
-- @require pshy_players.lua
-- @require pshy_players_keyboard.lua



--- Module Settings
pshy.mario_powerball_delay = 3000



-- Internal Use:
local pshy_players = pshy.players			-- represent the player
--		.mario_coins						-- coint of coins grabbed
--		.mario_grown						-- if the player was grown
--		.mario_flower						-- if the player unlocked powerballs
--		.mario_thrown_powerball_id			-- object id of the thrown powerball
--		.mario_next_powerball_time			-- next time the powerball can be used
local tfm_exec_displayParticle = tfm.exec.displayParticle



--- Touch a player.
-- @TODO: this is probably the wrong place.
local function TouchPlayer(player_name)
	local player = pshy_players[player_name]
	player.mario_coins = player.mario_coins or 0
	player.mario_grown = player.mario_grown or false
	player.mario_flower = player.mario_flower or false
	player.powerball_type = tfm.enum.shamanObject.snowBall --tfm.enum.shamanObject.(snowBall powerBall chicken)
	player.mario_thrown_powerball_id = player.mario_thrown_powerball_id or nil
	player.mario_next_powerball_time = player.mario_next_powerball_time or nil
	player.mario_name_color = player.mario_name_color or 0xbbbbbb
	tfm.exec.setNameColor(player_name, player.mario_name_color)
end



--- MarioCoin.
function pshy.bonuses_callback_MarioCoin(player_name, bonus)
	local player = pshy_players[player_name]
	player.mario_coins = player.mario_coins + 1
	tfm.exec.setPlayerScore(player_name, 1, true)
	tfm_exec_displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y - 1, 0, -6, 0, 0.4, player_name)
	tfm_exec_displayParticle(tfm.enum.particle.yellowGlitter, bonus.x - 1, bonus.y, 0, -6, 0, 0.4, player_name)
	tfm_exec_displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y + 1, 0, -6, 0, 0.4, player_name)
	tfm_exec_displayParticle(tfm.enum.particle.yellowGlitter, bonus.x + 1, bonus.y, 0, -6, 0, 0.4, player_name)
	-- update player color
	if player.mario_coins == 9 then
		player.mario_name_color = 0x6688ff -- blue
	elseif player.mario_coins == 25 then
		player.mario_name_color = 0x00eeee -- cyan
	elseif player.mario_coins == 35 then
		player.mario_name_color = 0x77ff77 -- green
	elseif player.mario_coins == 55 then
		player.mario_name_color = 0xeeee00 -- yellow
	elseif player.mario_coins == 75 then
		player.mario_name_color = 0xff7700 -- orange
	elseif player.mario_coins == 100 then
		player.mario_name_color = 0xff0000 -- red
	elseif player.mario_coins == 150 then
		player.mario_name_color = 0xff00bb -- pink
	elseif player.mario_coins == 200 then
		player.mario_name_color = 0xbb00ff -- purple
	else
		return
	end
	tfm.exec.setNameColor(player_name, player.mario_name_color)
end
pshy.bonuses_types["MarioCoin"] = {image = "17aa6f22c53.png", func = pshy.bonuses_callback_MarioCoin}



--- MarioMushroom.
function pshy.bonuses_callback_MarioMushroom(player_name, bonus)
	local player = pshy_players[player_name]
	tfm.exec.changePlayerSize(player_name, 1.4)
	player.mario_grown = true
	tfm_exec_displayParticle(tfm.enum.particle.redGlitter, bonus.x - 1, bonus.y, 0, -2, 0, 0.1, player_name)
	tfm_exec_displayParticle(tfm.enum.particle.redGlitter, bonus.x + 0, bonus.y, 0, -2, 0, 0.1, player_name)
	tfm_exec_displayParticle(tfm.enum.particle.redGlitter, bonus.x + 1, bonus.y, 0, -2, 0, 0.1, player_name)
end
pshy.bonuses_types["MarioMushroom"] = {image = "17c431c5e88.png", func = pshy.bonuses_callback_MarioMushroom, respawn = true}



--- MarioFlower.
function pshy.bonuses_callback_MarioFlower(player_name, bonus)
	local player = pshy_players[player_name]
	tfm.exec.bindKeyboard(player_name, 32, true, true)
	player.mario_flower = true
	player.mario_next_powerball_time = os.time()
	tfm.exec.chatMessage("<ch>Press SPACE to throw a fireball.</ch2>", player_name)
	tfm_exec_displayParticle(tfm.enum.particle.orangeGlitter, bonus.x - 1, bonus.y, 0, -2, 0, 0.1, player_name)
	tfm_exec_displayParticle(tfm.enum.particle.orangeGlitter, bonus.x + 0, bonus.y, 0, -2, 0, 0.1, player_name)
	tfm_exec_displayParticle(tfm.enum.particle.orangeGlitter, bonus.x + 1, bonus.y, 0, -2, 0, 0.1, player_name)
end
pshy.bonuses_types["MarioFlower"] = {image = "17c41851d61.png", func = pshy.bonuses_callback_MarioFlower}



--- MarioCheckpoint.
function pshy.bonuses_callback_MarioCheckpoint(player_name, bonus)
	local player = pshy_players[player_name]
	tfm.exec.bindKeyboard(player_name, 32, true, true)
	player.mario_flower = true
	player.mario_next_powerball_time = os.time()
	tfm.exec.chatMessage("<d>Checkpoint!</d>", player_name)
	pshy.checkpoints_SetPlayerCheckPoint(player_name)
end
-- TODO: bonus image
pshy.bonuses_types["MarioCheckpoint"] = {image = "17bf4c421bb.png", func = pshy.bonuses_callback_MarioCheckpoint, remain = true}



--- TFM event eventKeyboard
-- Handle player teleportations for pipes.
function eventKeyboard(player_name, key_code, down, x, y)
	if key_code == 32 and down then
		local player = pshy_players[player_name]
		if player.mario_flower and player.mario_next_powerball_time + pshy.mario_powerball_delay < os.time() then
			if player.mario_thrown_powerball_id then
				tfm.exec.removeObject(player.mario_thrown_powerball_id)
				player.mario_thrown_powerball_id = nil
			end
			tfm.exec.playEmote(player_name, tfm.enum.emote.highfive_1, nil)
			local speed = player.is_facing_right and 11 or -11
			player.mario_thrown_powerball_id = tfm.exec.addShamanObject(player.powerball_type, x + speed * 2, y, 0, speed, 0, false)
			tfm.exec.displayParticle(tfm.enum.particle.redGlitter, x + speed * 2, y, speed * 0.15, -0.15)
			tfm.exec.displayParticle(tfm.enum.particle.orangeGlitter, x + speed * 2, y, speed * 0.3, 0)
			tfm.exec.displayParticle(tfm.enum.particle.redGlitter, x + speed * 2, y, speed * 0.4, 0)
			tfm.exec.displayParticle(tfm.enum.particle.orangeGlitter, x + speed * 2, y, speed * 0.26, 0.15)
			player.mario_next_powerball_time = os.time()
		end
	end
end



--- TFM event eventPlayerDied.
function eventPlayerDied(player_name)
	local player = pshy_players[player_name]
	if player.mario_grown then
		local death_x = tfm.get.room.playerList[player_name].x
		local death_y = tfm.get.room.playerList[player_name].y
		player.mario_grown = false
		tfm.exec.changePlayerSize(player_name, 1)
		tfm.exec.respawnPlayer(player_name)
		tfm.exec.movePlayer(player_name, death_x, death_y - 30, false)
	end
end



--- Cancel changes the module have made.
local function CancelChanges()
	for player_name, player in pairs(pshy_players) do
		tfm.exec.changePlayerSize(player_name, 1.0)
		player.mario_coins = 0 -- @TODO: do i realy want to reset this ?
		player.mario_grown = false
		player.mario_flower = false -- @TODO: do i realy want to reset this ?
	end
end



--- Pshy event eventGameEnded()
function eventGameEnded()
	CancelChanges()
end



--- TFM event eventnewGame
function eventNewGame()
	for player_name, player in pairs(pshy_players) do
		player.mario_thrown_powerball_id = nil
		player.mario_next_powerball_time = 0
	end
	CancelChanges()
end



--- TFM event eventNewPlayer.
function eventNewPlayer(player_name)
	TouchPlayer(player_name)
end



--- Pshy event eventInit.
function eventInit()
	for player_name in pairs(tfm.get.room.playerList) do
		TouchPlayer(player_name)
	end
end
