-- @require pshy_keycodes.lua
-- @require pshy_merge.lua
-- @require pshy_players.lua



--- Internal Use:
local particle_type_list = {}




local function TouchPlayer(player_name)
	local player = pshy.players[player_name]
	player.particledraw_particles = {}
	player.particledraw_brush = {particle_type_index = 1, particle_type = tfm.enum.particle[particle_type_list[1]]}
	system.bindKeyboard(player_name, pshy.keycodes.U, true, true)
	system.bindKeyboard(player_name, pshy.keycodes.C, true, true)
	system.bindKeyboard(player_name, pshy.keycodes.P, true, true)
	tfm.exec.chatMessage("U - Undo", player_name)
	tfm.exec.chatMessage("C - Clear", player_name)
	tfm.exec.chatMessage("P - Tool", player_name)
	system.bindMouse(player_name, true)
end



local function Clear(player_name)
	local player = pshy.players[player_name]
	player.particledraw_particles = {}
end



function eventMouse(player_name, x, y)
	local player = pshy.players[player_name]
	local particles = player.particledraw_particles
	local new_particle = {}
	new_particle.x = x
	new_particle.y = y
	new_particle.type = player.particledraw_brush.particle_type
	for prop, val in pairs(player.particledraw_brush) do
		new_particle[prop] = val
	end
	table.insert(particles, new_particle)
end



function eventPlayerLeft(player_name)
	Clear(player_name)
end



function eventLoop()
	for player_name, player in pairs(pshy.players) do
		for i_particle, particle in pairs(player.particledraw_particles) do
			tfm.exec.displayParticle(particle.type, particle.x, particle.y, 0, 0, 0, 0, nil)
		end
	end
end



function eventKeyboard(player_name, keycode)
	local player = pshy.players[player_name]
	if keycode == pshy.keycodes.P then
		local brush = player.particledraw_brush
		brush.particle_type_index = brush.particle_type_index % #particle_type_list + 1
		brush.particle_type = tfm.enum.particle[particle_type_list[brush.particle_type_index]]
		tfm.exec.chatMessage(string.format("Using particle '%s'.", particle_type_list[brush.particle_type_index]), player_name)
	elseif keycode == pshy.keycodes.U then
		if #player.particledraw_particles > 0 then
			table.remove(player.particledraw_particles, #player.particledraw_particles)
		end
	elseif keycode == pshy.keycodes.C then
		player.particledraw_particles = {}
	end
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
end



function eventInit()
	for particle_name, value in pairs(tfm.enum.particle) do
		table.insert(particle_type_list, particle_name)
	end
	for player_name in pairs(tfm.get.room.playerList) do
		TouchPlayer(player_name)
	end
end
