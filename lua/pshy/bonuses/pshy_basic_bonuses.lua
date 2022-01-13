--- pshy_basic_bonuses.lua
--
-- Custom bonuses list.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_checkpoints.lua
-- @require pshy_speedfly.lua
-- @require pshy_bonuses.lua
-- @require pshy_imagedb.lua
-- @require pshy_mario_bonuses.lua
-- @require pshy_misc_bonuses.lua


-- Transformations, Free link, explosion, grow, shrink, shaman, vampire, balloon, snowflake, turn into cheese, checkpoint, heart/broken heart, fly, speed, loose-cheeze
-- cross, teleporter, mousetrap



--- Internal Use:
local changed_sizes = {}
local last_heart_grabber = nil
local linked_mice = {}
local transformices = {}
local strange_players = false
local spawnpoints = {}



--- BonusShrink.
function pshy.bonuses_callback_BonusShrink(player_name, bonus)
	local new_size = bonus.value or 0.5
	tfm.exec.changePlayerSize(player_name, new_size)
	changed_sizes[player_name] = new_size
end
pshy.bonuses_types["BonusShrink"] = {image = "17bf4b63aaa.png", func = pshy.bonuses_callback_BonusShrink}



--- BonusGrow.
function pshy.bonuses_callback_BonusGrow(player_name, bonus)
	local new_size = bonus.value or 1.8
	tfm.exec.changePlayerSize(player_name, new_size)
	changed_sizes[player_name] = new_size
end
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
	transformices[player_name] = true
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
	tfm.exec.setVampirePlayer(player_name, true)
	pshy.imagedb_AddImageMin("17bf4b75aa7.png", "%" .. player_name, 0, 0, nil, 30, 30, 0, 1.0)
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



--- BonusCheckpoint.
-- Checkpoint the player (if the checkpoint module is available).
function pshy.bonuses_callback_BonusCheckpoint(player_name, bonus)
	pshy.checkpoints_SetPlayerCheckpoint(player_name, bonus.x, bonus.y)
	tfm.exec.chatMessage("<d>Checkpoint!</d>", player_name)
end
pshy.bonuses_types["BonusCheckpoint"] = {image = "17bf4c421bb.png", func = pshy.bonuses_callback_BonusCheckpoint}



--- BonusSpawnpoint.
-- Set a player's spawn point.
-- As soon as the player have a spawnpoint, they also will keep the cheese.
function pshy.bonuses_callback_BonusSpawnpoint(player_name, bonus)
	local tfm_player = tfm.get.room.playerList[player_name]
	spawnpoints[player_name] = {x = bonus.x, y = bonus.y, has_cheese = tfm_player.hasCheese}
	tfm.exec.chatMessage("<d>Spawnpoint set!</d>", player_name)
end
pshy.bonuses_types["BonusSpawnpoint"] = {image = "17bf4c421bb.png", func = pshy.bonuses_callback_BonusSpawnpoint}



--- BonusTeleporter.
-- bonus.dst: tp coordinates (or random). Should be a table with `x` and `y`, or a list of random destinations.
function pshy.bonuses_callback_BonusTeleporter(player_name, bonus)
	local dst_x, dst_y
	if bonus.dst and bonus.dst[1] then
		local random_dst = bonus.dst[math.random(1, #bonus.dsts)]
		dst_x = random_dst.x
		dst_y = random_dst.y
	else
		dst_x = bonus.dst and bonus.dst.x or (400 + math.random(-400, 400))
		dst_y = bonus.dst and bonus.dst.y or (200 + math.random(-200, 200))
	end
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
		table.insert(linked_mice, {player_name, last_heart_grabber})
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



--- BonusCannonball.
-- Shoot a cannonball at the player.
function pshy.bonuses_callback_BonusCannonball(player_name, bonus)
	local tfm_player = tfm.get.room.playerList[player_name]
	local angle = (bonus.angle or 0)
	local speed_x = math.cos((angle * math.pi * 2.0 / 360.0) - math.pi / 2) * 20
	local speed_y = math.sin((angle * math.pi * 2.0 / 360.0) - math.pi / 2) * 20
	local obj_id = tfm.exec.addShamanObject(tfm.enum.shamanObject.cannon, bonus.x - speed_x * 10, bonus.y - speed_y * 10 - 10, angle, speed_x, speed_y, false)
end
pshy.bonuses_types["BonusCannonball"] = {image = "17e53fb43dc.png", func = pshy.bonuses_callback_BonusCannonball, shared = true}



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
	if changed_sizes[player_name] then
		tfm.exec.changePlayerSize(player_name, 1.0)
		changed_sizes[player_name] = nil
	end
	if spawnpoints[player_name] then
		local spawn = spawnpoints[player_name]
		tfm.exec.movePlayer(player_name, spawn.x, spawn.y, false, -1, -1, false)
		if spawn.has_cheese then
			tfm.exec.giveCheese(player_name)
		end
	end
end



--- TFM event eventPlayerVampire.
function eventPlayerVampire(player_name)
	if strange_players then
		pshy.bonuses_callback_BonusStrange(player_name, nil)
	end
end



--- Cancel changes the module have made.
local function CancelChanges()
	for player_name in pairs(changed_sizes) do
		tfm.exec.changePlayerSize(player_name, 1.0)
	end
	changed_sizes = {}
	for i_link, pair in pairs(linked_mice) do
		tfm.exec.linkMice(pair[1], pair[2], false)
	end
	linked_mice = {}
	last_heart_grabber = nil
	for player_name in pairs(transformices) do
		tfm.exec.giveTransformations(player_name, false)
	end
	transformices = {}
end



--- Pshy event eventGameEnded()
function eventGameEnded()
	CancelChanges()
end



--- TFM event eventnewGame
function eventNewGame()
	CancelChanges()
	strange_players = false
	spawnpoints = {}
end
