--- pshy.bonuses.misc
--
-- Custom bonuses list (advanced list, contains bonuses that dont look like ones).
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.bonuses")
pshy.require("pshy.events")
pshy.require("pshy.lists.images.bonuses")



--- Internal Use:
local removed_grounds = {}



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
pshy.bonuses_types["MouseTrap"] = {image = "17bf4b7a091.png", func = pshy.bonuses_callback_MouseTrap, behavior = PSHY_BONUS_BEHAVIOR_SHARED}



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
pshy.bonuses_types["GoreDeath"] = {image = nil, func = pshy.bonuses_callback_GoreDeath, behavior = PSHY_BONUS_BEHAVIOR_REMAIN}



--- Cheese.
-- Act like a cheese.
function pshy.bonuses_callback_Cheese(player_name, bonus)
	if tfm.get.room.playerList[player_name].hasCheese then
		return false
	end
	tfm.exec.giveCheese(player_name)
end
pshy.bonuses_types["Cheese"] = {image = "155592fd7d0.png", func = pshy.bonuses_callback_Cheese, behavior = PSHY_BONUS_BEHAVIOR_REMAIN}



--- Hole.
-- Act like an hole.
function pshy.bonuses_callback_Hole(player_name, bonus)
	if not tfm.get.room.playerList[player_name].isDead then
		return false
	end
	tfm.exec.playerVictory(player_name)
end
pshy.bonuses_types["Hole"] = {image = "17cc269a03d.png", func = pshy.bonuses_callback_Hole, behavior = PSHY_BONUS_BEHAVIOR_REMAIN}



--- PickableCheese.
-- If a player take the cheese then others cant pick it.
function pshy.bonuses_callback_PickableCheese(player_name, bonus)
	if tfm.get.room.playerList[player_name].hasCheese then
		return false
	end
	tfm.exec.giveCheese(player_name)
end
pshy.bonuses_types["PickableCheese"] = {image = "155592fd7d0.png", func = pshy.bonuses_callback_PickableCheese, behavior = PSHY_BONUS_BEHAVIOR_SHARED}



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



--- BonusRemoveGround.
-- If the mouse grabs it, then a specific ground disapear.
function pshy.bonuses_callback_BonusRemoveGround(player_name, bonus)
	if type(bonus.remove_ground_id) == "number" then
		tfm.exec.removePhysicObject(bonus.remove_ground_id)
	else
		for i_id, id in ipairs(bonus.remove_ground_id) do
			tfm.exec.removePhysicObject(id)
			table.insert(removed_grounds, id)
		end
	end
	if bonus.chat_message then
		tfm.exec.chatMessage(string.format(bonus.chat_message, player_name), nil)
	end
end
pshy.bonuses_types["BonusRemoveGround"] = {image = "17bef4f49c5.png", func = pshy.bonuses_callback_BonusRemoveGround, behavior = PSHY_BONUS_BEHAVIOR_SHARED}



function eventNewGame()
	removed_grounds = {}
end



function eventNewPlayer(player_name)
	for i_removed_ground, removed_ground in ipairs(removed_grounds) do
		tfm.exec.removePhysicObject(removed_ground)
	end
end
