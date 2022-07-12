--- pshy.games.pokeball
--
-- Catch mice with pokeballs.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local newgame = pshy.require("pshy.rotations.newgame")
pshy.require("pshy.rotations.list.pokemon")
pshy.require("pshy.essentials")
pshy.require("pshy.events")
local players = pshy.require("pshy.players")



-- pokeball sprites: 181f3072374.png (default), 181f32eaacb.png (green), 181f3329429.png (red)



--- Internal Use:
local player_list = players.list
local pokeballs = {}
local players_pokeballs_ids = {}



local function RecoverPokeball(player_name, ground_id)
	local pokeball = pokeballs[ground_id]
	if pokeball.catched then
		local catcher_player = player_list[pokeball.launcher]
		catcher_player.catched_player = pokeball.catched
		tfm.exec.chatMessage(string.format("<j>Added <ch>%s</ch> to your inventory!</j>", pokeball.catched), pokeball.launcher)
		tfm.exec.chatMessage(string.format("<r>You are now in <ch2>%s</ch2>'s inventory!</j>", pokeball.launcher), pokeball.catched)
	end
	players_pokeballs_ids[pokeball.launcher] = nil
	pokeballs[ground_id] = nil
	tfm.exec.removePhysicObject(ground_id)
end



local function ThrowPokeball(player_name, x, y, vx, vy)
	-- remove previous ball
	if players_pokeballs_ids[player_name] then
		RecoverPokeball(player_name, players_pokeballs_ids[player_name])
	end
	-- find available id
	local ground_id = 44
	while pokeballs[ground_id] do
		ground_id = ground_id + 1
	end
	--
	local player = player_list[player_name]
	-- add the ball
	players_pokeballs_ids[player_name] = ground_id
	if not player.catched_player then
		pokeballs[ground_id] = {launcher = player_name, catching = true, timeout = 5}
	else
		pokeballs[ground_id] = {launcher = player_name, catched = player.catched_player, timeout = 1, release_x = x + vx, release_y = y}
		tfm.exec.chatMessage(string.format("<j>You summoned <ch>%s</ch>!</j>", player.catched_player), player_name)
		tfm.exec.chatMessage(string.format("<r>Summoned by <ch2>%s</ch2>!</r>", player_name), player.catched_player)
		player.catched_player = nil
	end
	-- throw the ball
	tfm.exec.playEmote(player_name, tfm.enum.emote.highfive_1)
	tfm.exec.addPhysicObject(ground_id, x, y, {type = 13, width = 10, color = 0, friction = 0.3, restitution = 0.2, mass = 1, dynamic = true, miceCollision = true, groundCollision = true, contactListener = true})
	tfm.exec.movePhysicObject(ground_id, x, y, false, vx, vy, false)
	tfm.exec.addImage("181f3072374.png", "+" .. tostring(ground_id), -10, -10)
end



function TouchPlayer(player_name)
	system.bindKeyboard(player_name, 32, true, true)
end



function eventKeyboard(player_name, keycode, down, x, y, vx, vy)
	if keycode == 32 and down then
		if math.abs(vx) < 2 and math.abs(vy) < 2 then
			tfm.exec.chatMessage("<r>Move to give your pokeball some speed!</j>", player_name)
			return
		end
		local pvx = math.max(-80, math.min(80, vx * 15))
		local pvy = math.max(-80, math.min(80, vy * 15))
		ThrowPokeball(player_name, x + pvx, y + pvy, pvx, pvy)
	end
end



function eventContactListener(player_name, ground_id, contact_info)
	local pokeball = pokeballs[ground_id]
	if not pokeball then
		return
	end
	if player_name == pokeball.launcher then
		RecoverPokeball(player_name, ground_id)
		return
	end
	if not pokeball.catching then
		return
	end
	tfm.exec.chatMessage(string.format("<j>You catched a <ch>%s</ch>!</j>", player_name), pokeball.launcher)
	tfm.exec.chatMessage(string.format("<r>Catched by <ch2>%s</ch2>!</j>", pokeball.launcher), player_name)
	tfm.exec.displayParticle(tfm.enum.particle.mouseTeleportation, contact_info.playerX, contact_info.playerY)
	tfm.exec.movePhysicObject(ground_id, 0, 0, true, 0, -3, false)
	tfm.exec.killPlayer(player_name)
	tfm.exec.addImage("181f32eaacb.png", "+" .. tostring(ground_id), -10, -10)
	pokeball.catched = player_name
	pokeball.catching = false
	pokeball.release_x = contact_info.playerX
	pokeball.release_y = contact_info.playerY
	pokeball.timeout = 20
end



function eventLoop()
	for ground_id, pokeball in pairs(pokeballs) do
		if pokeball.timeout then
			pokeball.timeout = pokeball.timeout - 1
			if pokeball.timeout < 0 then
				pokeball.timeout = nil
				if pokeball.catching then
					pokeball.catching = false
					tfm.exec.addImage("181f3329429.png", "+" .. tostring(ground_id), -10, -10)
				end
				if pokeball.catched then
					tfm.exec.respawnPlayer(pokeball.catched)
					tfm.exec.movePlayer(pokeball.catched, pokeball.release_x, pokeball.release_y)
					tfm.exec.displayParticle(tfm.enum.particle.mouseTeleportation, pokeball.release_x, pokeball.release_y)
					pokeball.catched = nil
					tfm.exec.addImage("181f3329429.png", "+" .. tostring(ground_id), -10, -10)
					tfm.exec.movePhysicObject(ground_id, 0, 0, true, 0, -3, false)
				end
			end
		end
	end
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
end



function eventPlayerLeft(player_name)
	local player = player_list[player_name]
	player.catched_player = nil
end



function eventNewGame(player_name)
	for player_name, player in pairs(player_list) do
			print(player_name .. " has " .. tostring(player.catched_player))
		if player.catched_player then
			tfm.exec.killPlayer(player.catched_player)
		end
	end
end



function eventInit()
	for player_name in pairs(tfm.get.room.playerList) do
		TouchPlayer(player_name)
	end
	if __IS_MAIN_MODULE__ then
		tfm.exec.disableAutoTimeLeft()
		tfm.exec.disableAfkDeath()
		newgame.SetRotation("pokemon")
		tfm.exec.newGame()
	end
end
