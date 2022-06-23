--- pshy.bonuses.basic
--
-- Custom bonuses list.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local bonuses = pshy.require("pshy.bonuses")
pshy.require("pshy.events")
pshy.require("pshy.lists.images.bonuses")



--- Internal Use:
local changed_sizes = {}
local last_heart_grabber = nil
local linked_mice = {}
local transformices = {}
local strange_players = false



--- BonusShrink.
function bonuses.callback_BonusShrink(player_name, bonus)
	local new_size = bonus.scale or 0.5
	tfm.exec.changePlayerSize(player_name, new_size)
	changed_sizes[player_name] = new_size
end
bonuses.types["BonusShrink"] = {image = "17bf4b63aaa.png", func = bonuses.callback_BonusShrink}



--- BonusGrow.
function bonuses.callback_BonusGrow(player_name, bonus)
	local new_size = bonus.scale or 1.8
	tfm.exec.changePlayerSize(player_name, new_size)
	changed_sizes[player_name] = new_size
end
bonuses.types["BonusGrow"] = {image = "17bf4b67579.png", func = bonuses.callback_BonusGrow}



--- BonusAttachBalloon.
-- Attack a balloon to the player.
-- bonus.ghost: is the balloon ghosted.
function bonuses.callback_BonusAttachBalloon(player_name, bonus)
	tfm.exec.attachBalloon(player_name, true)
end
bonuses.types["BonusAttachBalloon"] = {image = "17bf4b80fc3.png", func = bonuses.callback_BonusAttachBalloon}



--- BonusShaman.
-- Turn the first player to grab it into shaman.
function bonuses.callback_BonusShaman(player_name, bonus)
	tfm.exec.setShaman(player_name, true)
end
bonuses.types["BonusShaman"] = {image = "17bf4b8c42d.png", func = bonuses.callback_BonusShaman, behavior = bonuses.BEHAVIOR_SHARED}



--- BonusTransformations.
function bonuses.callback_BonusTransformations(player_name, bonus)
	tfm.exec.giveTransformations(player_name, true)
	transformices[player_name] = true
end
bonuses.types["BonusTransformations"] = {image = "17bf4b6f226.png", func = bonuses.callback_BonusTransformations}



--- BonusFreeze.
-- Freeze the picker.
function bonuses.callback_BonusFreeze(player_name, bonus)
	tfm.exec.freezePlayer(player_name, true)
end
bonuses.types["BonusFreeze"] = {image = "17bf4b94d8a.png", func = bonuses.callback_BonusFreeze}



--- BonusIce.
-- Turn the player into an ice block.
function bonuses.callback_BonusIce(player_name, bonus)
	local tfm_player = tfm.get.room.playerList[player_name]
	local speed_x = tfm_player.vx
	local speed_y = tfm_player.vy
	tfm.exec.killPlayer(player_name)
	local obj_id = tfm.exec.addShamanObject(tfm.enum.shamanObject.iceCube, bonus.x, bonus.y, angle, speed_x, speed_y, false)
end
bonuses.types["BonusIce"] = {image = "17bf4b977f5.png", func = bonuses.callback_BonusIce}



--- BonusStrange.
function bonuses.callback_BonusStrange(player_name, bonus)
	tfm.exec.setVampirePlayer(player_name, true)
	pshy.imagedb_AddImageMin("17bf4b75aa7.png", "%" .. player_name, 0, 0, nil, 30, 30, 0, 1.0)
	strange_players = true
end
bonuses.types["BonusStrange"] = {image = "17bf4b75aa7.png", func = bonuses.callback_BonusStrange}



--- BonusCheese.
-- Turn the player into a cheese.
function bonuses.callback_BonusCheese(player_name, bonus)
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
bonuses.types["BonusCheese"] = {image = "17bf4b6b157.png", func = bonuses.callback_BonusCheese}



--- BonusTeleporter.
-- bonus.dst: tp coordinates (or random). Should be a table with `x` and `y`, or a list of random destinations.
function bonuses.callback_BonusTeleporter(player_name, bonus)
	local dst_x, dst_y
	if bonus.dst and bonus.dst[1] then
		local random_dst = bonus.dst[math.random(1, #bonus.dst)]
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
bonuses.types["BonusTeleporter"] = {image = "17bf4ba4ce5.png", func = bonuses.callback_BonusTeleporter}
bonuses.types["Teleporter"] = {image = "17bf4ba4ce5.png", func = bonuses.callback_BonusTeleporter, behavior = bonuses.BEHAVIOR_REMAIN}



--- BonusCircle.
-- If the mouse grabs it, then it become the bonus.
function bonuses.callback_BonusCircle(player_name, bonus)
	tfm.exec.killPlayer(player_name)
	pshy.imagedb_AddImage("17bf4b868c3.png", "!0", bonus.x, bonus.y, player_name, nil, nil, 0.0, 1.0)
end
bonuses.types["BonusCircle"] = {image = "17bef4f49c5.png", func = bonuses.callback_BonusCircle}



--- BonusMarry.
function bonuses.callback_BonusMarry(player_name, bonus)
	if last_heart_grabber == nil then
		last_heart_grabber = player_name
	elseif last_heart_grabber ~= player_name then
		tfm.exec.linkMice(player_name, last_heart_grabber, true)
		table.insert(linked_mice, {player_name, last_heart_grabber})
		last_heart_grabber = nil
	end
end
bonuses.types["BonusMarry"] = {image = "17bf4b8f9e4.png", func = bonuses.callback_BonusMarry}



--- BonusDivorce.
-- Remove any soulmate link this mouse has.
function bonuses.callback_BonusDivorce(player_name, bonus)
	tfm.exec.linkMice(player_name, player_name, true)
	tfm.exec.linkMice(player_name, player_name, false)
	if last_heart_grabber == player_name then
		last_heart_grabber = nil
	end
end
bonuses.types["BonusDivorce"] = {image = "17bf4b91c35.png", func = bonuses.callback_BonusDivorce}



--- BonusCannonball.
-- Shoot a cannonball at the player.
function bonuses.callback_BonusCannonball(player_name, bonus)
	local tfm_player = tfm.get.room.playerList[player_name]
	local angle = (bonus.angle or 0)
	local speed_x = math.cos((angle * math.pi * 2.0 / 360.0) - math.pi / 2) * 20
	local speed_y = math.sin((angle * math.pi * 2.0 / 360.0) - math.pi / 2) * 20
	local obj_id = tfm.exec.addShamanObject(tfm.enum.shamanObject.cannon, bonus.x - speed_x * 10, bonus.y - speed_y * 10 - 10, angle, speed_x, speed_y, false)
end
bonuses.types["BonusCannonball"] = {image = "17e53fb43dc.png", func = bonuses.callback_BonusCannonball, behavior = bonuses.BEHAVIOR_SHARED}



--- BonusFish.
-- Summon a load of fishes.
function bonuses.callback_BonusFish(player_name, bonus)
	for i = 1, 40 do
		tfm.exec.addShamanObject(tfm.enum.shamanObject.fish, bonus.x + i % 3, bonus.y - i, 0)
	end
end
bonuses.types["BonusFish"] = {image = "17e59ba43a6.png", func = bonuses.callback_BonusFish, behavior = bonuses.BEHAVIOR_SHARED}



--- BonusDeath.
-- Summon a load of fishes.
function bonuses.callback_BonusDeath(player_name, bonus)
	tfm.exec.killPlayer(player_name)
end
bonuses.types["BonusDeath"] = {image = "17ebfdb85bd.png", func = bonuses.callback_BonusDeath, behavior = bonuses.BEHAVIOR_REMAIN}



--- TFM event eventPlayerRespawn.
function eventPlayerRespawn(player_name)
	if changed_sizes[player_name] then
		tfm.exec.changePlayerSize(player_name, 1.0)
		changed_sizes[player_name] = nil
	end
end



--- TFM event eventPlayerVampire.
function eventPlayerVampire(player_name)
	if strange_players then
		bonuses.callback_BonusStrange(player_name, nil)
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
end
