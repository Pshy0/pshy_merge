--- pshy_basic_bonuses.lua
--
-- Custom bonuses list.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_bonuses.lua



--- BonusAttachBalloon.
-- Attack a balloon to the player.
-- bonus.ghost: is the balloon ghosted.
function pshy.bonuses_callback_BonusAttachBalloon(player_name, bonus)
	tfm.exec.attachBalloon(player_name, bonus.ghost)
end
-- TODO: balloon bonus image
pshy.bonuses_types["BonusAttachBalloon"] = {image = "17aa6f22c53.png", func = pshy.bonuses_callback_BonusAttachBalloon}



--- BonusCheckpoint.
-- Checkpoint the player (if the checkpoint module is available).
function pshy.bonuses_callback_BonusCheckpoint(player_name, bonus)
	if pshy.checkpoints_SetPlayerCheckpoint then
		pshy.checkpoints_SetPlayerCheckpoint(player_name, bonus.x, bonus.y)
	end
end
-- TODO: checkpoint bonus image
pshy.bonuses_types["BonusCheckpoint"] = {image = "17aa6f22c53.png", func = pshy.bonuses_callback_BonusCheckpoint}



--- BonusFreeze.
-- Freeze the picker.
function pshy.bonuses_callback_BonusFreeze(player_name, bonus)
	tfm.exec.freezePlayer(player_name, true)
end
-- TODO: freeze bonus image
pshy.bonuses_types["BonusFreeze"] = {image = "17aa6f22c53.png", func = pshy.bonuses_callback_BonusFreeze}



--- BonusIce.
-- Turn the player into an ice block.
function pshy.bonuses_callback_BonusIce(player_name, bonus)
	local tfm_player = tfm.get.room.playerList[player_name]
	local speed_x = tfm_player.vx
	local speed_y = tfm_player.vy
	tfm.exec.killPlayer(player_name)
	local obj_id = tfm.exec.addShamanObject(tfm.enum.shamanObject.iceCube, bonus.x, bonus.y, angle, speed_x, speed_y, false)
end
-- TODO: freeze bonus image
pshy.bonuses_types["BonusIce"] = {image = "17aa6f22c53.png", func = pshy.bonuses_callback_BonusIce}



--- Teleporter.
-- bonus.dst_x: tp coordinates (or random).
-- bonus.dst_y: tp coordinates (or random).
function pshy.bonuses_callback_Teleporter(player_name, bonus)
	local dst_x = bonus.dst_x or (bonus.x + math.random(-400, 400))
	local dst_y = bonus.dst_y or (bonus.y + math.random(-200, 200))
	tfm.exec.displayParticle(tfm.enum.particle.mouseTeleportation, bonus.x, bonus.y, 0, 0, 0, 0, nil)
	tfm.exec.movePlayer(player_name, dst_x, dst_y)
	tfm.exec.displayParticle(tfm.enum.particle.mouseTeleportation, dst_x, dst_y, 0, 0, 0, 0, nil)
end
-- TODO: Teleporter image
pshy.bonuses_types["Teleporter"] = {image = "17aa6f22c53.png", func = pshy.bonuses_callback_Teleporter, remain = true}



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
pshy.bonuses_types["PickableCheese"] = {image = "155593003fc.png", func = pshy.bonuses_callback_PickableCheese, shared = true}



--- PickableWrongCheese.
-- The first player taking this cheese dies.
function pshy.bonuses_callback_PickableWrongCheese(player_name, bonus)
	tfm.exec.killPlayer(player_name)
	-- TODO: draw a cross
	pshy.imagedb_AddImage("16f5d8c7401.png", "#" .. tostring(obj_id), 0, 0, nil, nil, nil, 0.0, 1.0)
end
pshy.bonuses_types["PickableWrongCheese"] = {image = "155593003fc.png", func = pshy.bonuses_callback_PickableWrongCheese, shared = true}



--- PickableVictory.
-- The player wins if he reach this, but then others cant.
function pshy.bonuses_callback_PickableVictory(player_name, bonus)
	tfm.exec.giveCheese(player_name)
	tfm.exec.playerVictory(player_name)
end
pshy.bonuses_types["PickableVictory"] = {image = "17aa6f22c53.png", func = pshy.bonuses_callback_PickableVictory, shared = true}



--- MouseTrap.
-- A player walking on this triggers the trap that flies up.
function pshy.bonuses_callback_MouseTrap(player_name, bonus)
	tfm.exec.killPlayer(player_name)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, -2, -6.8, 0, 1, nil)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, -1, -7, 0, 1, nil)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, 0, -7.1, 0, 1, nil)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, 1, -7, 0, 1, nil)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, 2, -6.8, 0, 1, nil)
	local obj_id = tfm.exec.addShamanObject(tfm.enum.shamanObject.tinyBoard, bonus.x, bonus.y, angle, 1, -4, true)
	-- TODO: use a mouse trap image:
	pshy.imagedb_AddImage("155593003fc.png", "#" .. tostring(obj_id), 0, 0, nil, nil, nil, 0.0, 1.0)
end
-- TODO: use a mouse trap image:
pshy.bonuses_types["MouseTrap"] = {image = "155593003fc.png", func = pshy.bonuses_callback_MouseTrap, shared = true}
