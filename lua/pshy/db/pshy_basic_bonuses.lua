--- pshy_basic_bonuses.lua
--
-- Custom bonuses list.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_checkpoints.lua
-- @require pshy_speedfly.lua
-- @require pshy_bonuses.lua
-- @require pshy_imagedb.lua


-- Transformations, Free link, explosion, grow, shrink, shaman, vampire, balloon, snowflake, turn into cheese, checkpoint, heart/broken heart, fly, speed, loose-cheeze
-- cross, teleporter, mousetrap




--- Internal Use:
local last_heart_grabber = nil
local strange_players = true


--- BonusShrink.
function pshy.bonuses_callback_BonusShrink(player_name, bonus)
	tfm.exec.changePlayerSize(player_name, bonus.value or 0.5)
end
pshy.bonuses_types["BonusShrink"] = {image = "17bf4b63aaa.png", func = pshy.bonuses_callback_BonusShrink}



--- BonusGrow.
function pshy.bonuses_callback_BonusGrow(player_name, bonus)
	tfm.exec.changePlayerSize(player_name, bonus.value or 2.0)
end
-- TODO: bonus image
pshy.bonuses_types["BonusGrow"] = {image = "17bf4b67579.png", func = pshy.bonuses_callback_BonusGrow}



--- BonusAttachBalloon.
-- Attack a balloon to the player.
-- bonus.ghost: is the balloon ghosted.
function pshy.bonuses_callback_BonusAttachBalloon(player_name, bonus)
	tfm.exec.attachBalloon(player_name, true)
end
pshy.bonuses_types["BonusAttachBalloon"] = {image = "17bf4b80fc3.png", func = pshy.bonuses_callback_BonusAttachBalloon}



--- BonusFly.
function pshy.bonuses_callback_BonusFly(player_name, bonus)
	pshy.speedfly_Fly(player_name, 50)
end
pshy.bonuses_types["BonusFly"] = {image = "17bf4b7250e.png", func = pshy.bonuses_callback_BonusFly}



--- BonusHighSpeed.
function pshy.bonuses_callback_BonusHighSpeed(player_name, bonus)
	pshy.speedfly_Speed(player_name, 200)
end
pshy.bonuses_types["BonusHighSpeed"] = {image = "17bf4b9af56.png", func = pshy.bonuses_callback_BonusHighSpeed}



--- BonusShaman.
-- Turn the first player to grab it into shaman.
function pshy.bonuses_callback_BonusShaman(player_name, bonus)
	tfm.exec.setShaman(player_name, true)
end
pshy.bonuses_types["BonusShaman"] = {image = "17bf4b8c42d.png", func = pshy.bonuses_callback_BonusShaman, shared = true}



--- BonusTransformations.
function pshy.bonuses_callback_BonusTransformations(player_name, bonus)
	tfm.exec.giveTransformations(player_name, true)
end
pshy.bonuses_types["BonusTransformations"] = {image = "17bf4b6f226.png", func = pshy.bonuses_callback_BonusTransformations}



--- BonusFreeze.
-- Freeze the picker.
function pshy.bonuses_callback_BonusFreeze(player_name, bonus)
	tfm.exec.freezePlayer(player_name, true)
end
pshy.bonuses_types["BonusFreeze"] = {image = "17bf4b94d8a.png", func = pshy.bonuses_callback_BonusFreeze}



--- BonusIce.
-- Turn the player into an ice block.
function pshy.bonuses_callback_BonusIce(player_name, bonus)
	local tfm_player = tfm.get.room.playerList[player_name]
	local speed_x = tfm_player.vx
	local speed_y = tfm_player.vy
	tfm.exec.killPlayer(player_name)
	local obj_id = tfm.exec.addShamanObject(tfm.enum.shamanObject.iceCube, bonus.x, bonus.y, angle, speed_x, speed_y, false)
end
pshy.bonuses_types["BonusIce"] = {image = "17bf4b977f5.png", func = pshy.bonuses_callback_BonusIce}



--- BonusStrange.
function pshy.bonuses_callback_BonusStrange(player_name, bonus)
	pshy.setVampirePlayer(player_name, true)
	pshy.imagedb_AddImageMin("17bf4b75aa7.png", "%" .. player_name, 0, 0, player_name, 30, 30, 0, 1.0)
	--strange_players[player_name] = true
	strange_players = true
end
pshy.bonuses_types["BonusStrange"] = {image = "17bf4b75aa7.png", func = pshy.bonuses_callback_BonusStrange}



--- BonusCheese.
-- Turn the player into a cheese.
function pshy.bonuses_callback_BonusCheese(player_name, bonus)
	tfm.exec.killPlayer(player_name)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, -2, -6.8, 0, 1, nil)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, -1, -7, 0, 1, nil)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, 0, -7.1, 0, 1, nil)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, 1, -7, 0, 1, nil)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, 2, -6.8, 0, 1, nil)
	local tfm_player = tfm.get.room.playerList[player_name]
	local speed_x = tfm_player.vx
	local speed_y = tfm_player.vy
	local obj_id = tfm.exec.addShamanObject(tfm.enum.shamanObject.littleBox, bonus.x, bonus.y, angle, speed_x, speed_y, false)
	pshy.imagedb_AddImage("155592fd7d0.png", "#" .. tostring(obj_id), 0, 0, nil, nil, nil, 0.0, 1.0)
end
pshy.bonuses_types["BonusCheese"] = {image = "17bf4b6b157.png", func = pshy.bonuses_callback_BonusCheese}



--- MouseTrap.
-- Same as BonusCheese but with a mouse trap image and a little board, and shared.
function pshy.bonuses_callback_MouseTrap(player_name, bonus)
	tfm.exec.killPlayer(player_name)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, -2, -6.8, 0, 1, nil)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, -1, -7, 0, 1, nil)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, 0, -7.1, 0, 1, nil)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, 1, -7, 0, 1, nil)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, 2, -6.8, 0, 1, nil)
	local obj_id = tfm.exec.addShamanObject(tfm.enum.shamanObject.tinyBoard, bonus.x, bonus.y, angle, 1, -4, false)
	-- TODO: use a mouse trap image:
	pshy.imagedb_AddImage("17bf4b7ddd6.png", "#" .. tostring(obj_id), 0, 0, nil, nil, nil, 0.0, 1.0)
end
pshy.bonuses_types["MouseTrap"] = {image = "17bf4b7a091.png", func = pshy.bonuses_callback_MouseTrap, shared = true}



--- BonusCheckpoint.
-- Checkpoint the player (if the checkpoint module is available).
function pshy.bonuses_callback_BonusCheckpoint(player_name, bonus)
	if pshy.checkpoints_SetPlayerCheckpoint then
		pshy.checkpoints_SetPlayerCheckpoint(player_name, bonus.x, bonus.y)
	end
end
pshy.bonuses_types["BonusCheckpoint"] = {image = "17bf4c421bb.png", func = pshy.bonuses_callback_BonusCheckpoint}



--- BonusTeleporter.
-- bonus.dst_x: tp coordinates (or random).
-- bonus.dst_y: tp coordinates (or random).
function pshy.bonuses_callback_BonusTeleporter(player_name, bonus)
	local dst_x = bonus.dst_x or (400 + math.random(-400, 400))
	local dst_y = bonus.dst_y or (200 + math.random(-200, 200))
	tfm.exec.displayParticle(tfm.enum.particle.mouseTeleportation, bonus.x, bonus.y, 0, 0, 0, 0, nil)
	tfm.exec.movePlayer(player_name, dst_x, dst_y)
	tfm.exec.displayParticle(tfm.enum.particle.mouseTeleportation, dst_x, dst_y, 0, 0, 0, 0, nil)
end
pshy.bonuses_types["BonusTeleporter"] = {image = "17bf4ba4ce5.png", func = pshy.bonuses_callback_BonusTeleporter}
pshy.bonuses_types["Teleporter"] = {image = "17bf4ba4ce5.png", func = pshy.bonuses_callback_BonusTeleporter, remain = true}



--- BonusCircle.
-- If the mouse grabs it, then it become the bonus.
function pshy.bonuses_callback_BonusCircle(player_name, bonus)
	tfm.exec.killPlayer(player_name)
	pshy.imagedb_AddImage("17bf4b868c3.png", "!0", bonus.x, bonus.y, player_name, nil, nil, 0.0, 1.0)
end
pshy.bonuses_types["BonusCircle"] = {image = "17bef4f49c5.png", func = pshy.bonuses_callback_BonusCircle}



--- BonusMarry.
function pshy.bonuses_callback_BonusMarry(player_name, bonus)
	if last_heart_grabber == nil then
		last_heart_grabber = player_name
	elseif last_heart_grabber ~= player_name then
		tfm.exec.linkMice(player_name, last_heart_grabber, true)
		last_heart_grabber = nil
	end
end
pshy.bonuses_types["BonusMarry"] = {image = "17bf4b8f9e4.png", func = pshy.bonuses_callback_BonusMarry}



--- BonusDivorce.
-- Remove any soulmate link this mouse has.
function pshy.bonuses_callback_BonusDivorce(player_name, bonus)
	tfm.exec.linkMice(player_name, player_name, true)
	tfm.exec.linkMice(player_name, player_name, false)
	if last_heart_grabber == player_name then
		last_heart_grabber = nil
	end
end
pshy.bonuses_types["BonusDivorce"] = {image = "17bf4b91c35.png", func = pshy.bonuses_callback_BonusDivorce}



--- GoreDeath.
-- This bonus is invisible.
-- Cause the mouse to explode into blood.
function pshy.bonuses_callback_GoreDeath(player_name, bonus)
	tfm.exec.movePlayer(player_name, bonus.x, bonus.y + 10000, false, 0, 0, false)
	tfm.exec.killPlayer(player_name)
	local redConfetti = tfm.enum.particle.redConfetti
	local redGlitter = tfm.enum.particle.redGlitter
	local blood_patches = {{-2.5, -4}, {-1, -5}, {0, -7}, {1, -6}, {2.5, -4}, {0.5, -4}, {-1.5, -4.5}}
	local rnx = math.random(0, 100) / 100
	local rny = math.random(0, 100) / 100
	for i_patch, patch in ipairs(blood_patches) do
		tfm.exec.displayParticle(redConfetti, bonus.x + 1, bonus.y + 2, patch[1] + 0.1 + rnx, patch[2] + 0.2 + rny, 0, 0.3, nil)
		tfm.exec.displayParticle(redConfetti, bonus.x + 2, bonus.y + 1, patch[1] + 0.3 + rnx, patch[2] + 0.0 + rny, 0, 0.3, nil)
		tfm.exec.displayParticle(redConfetti, bonus.x + 3, bonus.y + 2, patch[1] + 0.0 + rnx, patch[2] + 0.4 + rny, 0, 0.3, nil)
		tfm.exec.displayParticle(redConfetti, bonus.x + 2, bonus.y + 1, patch[1] + 0.2 + rnx, patch[2] + 0.1 + rny, 0, 0.3, nil)
		tfm.exec.displayParticle(redConfetti, bonus.x + 1, bonus.y + 2, patch[1] + 0.0 + rnx, patch[2] + 0.2 + rny, 0, 0.3, nil)
	end
end
pshy.bonuses_types["GoreDeath"] = {image = nil, func = pshy.bonuses_callback_GoreDeath, remain = true}



--- PickableCheese.
-- If a player take the cheese then others cant pick it.
function pshy.bonuses_callback_PickableCheese(player_name, bonus)
	if tfm.get.room.playerList[player_name].hasCheese then
		return false
	end
	tfm.exec.giveCheese(player_name)
end
pshy.bonuses_types["PickableCheese"] = {image = "155592fd7d0.png", func = pshy.bonuses_callback_PickableCheese, shared = true}



--- CorrectCheese.
-- Like a normal cheeze but congrats the player.
function pshy.bonuses_callback_CorrectCheese(player_name, bonus)
	tfm.exec.giveCheese(player_name)
	--pshy.imagedb_AddImage("155592fd7d0.png", "!0", bonus.x, bonus.y, player_name, nil, nil, 0.0, 1.0)
	pshy.imagedb_AddImage("17bf4f3f2fb.png", "!0", bonus.x, bonus.y, player_name, nil, nil, 0.0, 1.0)
end
pshy.bonuses_types["CorrectCheese"] = {image = "155592fd7d0.png", func = pshy.bonuses_callback_CorrectCheese}



--- WrongCheese.
-- Like a normal cheeze but kills the player.
function pshy.bonuses_callback_WrongCheese(player_name, bonus)
	tfm.exec.killPlayer(player_name)
	--pshy.imagedb_AddImage("155593003fc.png", "!0", bonus.x, bonus.y, player_name, nil, nil, 0.0, 1.0)
	pshy.imagedb_AddImage("17bf4b89eba.png", "!0", bonus.x, bonus.y, player_name, nil, nil, 0.0, 1.0)
end
pshy.bonuses_types["WrongCheese"] = {image = "155592fd7d0.png", func = pshy.bonuses_callback_WrongCheese}



--- TFM event eventPlayerrespawn.
function eventPlayerRespawn(player_name)
	--for player_name in pairs(tfm.get.room.playerList) do
		tfm.exec.changePlayerSize(player_name, 1.0)
	--end
end



--- TFM event eventPlayerVampire.
function eventPlayerVampire(player_name)
	if strange_players then
		pshy.bonuses_callback_BonusStrange(player_name, nil)
	end
end



--- TFM event eventnewGame
function eventNewGame()
	for player_name in pairs(tfm.get.room.playerList) do
		tfm.exec.changePlayerSize(player_name, 1.0)
	end
	last_heart_grabber = nil
	strange_players = false
end
