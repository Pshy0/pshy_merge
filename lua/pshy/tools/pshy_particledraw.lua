---- pshy_particledraw.lua
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_keycodes.lua
-- @require pshy_merge.lua
-- @require pshy_players.lua
pshy = pshy or {}



--- Module Help Page:
pshy.help_pages["pshy_particledraw"] = {back = "pshy", title = "Particle Drawing", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_particledraw"] = pshy.help_pages["pshy_particledraw"]



--- Tool types enum.
pshy.particledraw_tools = {}
pshy.particledraw_tools.none = 0
pshy.particledraw_tools.pen = 1
pshy.particledraw_tools.paste = 2


--- Predefined:
pshy.particledraw_shapes = {}
pshy.particledraw_shapes.joyeux_anniversaire = {{8, 8}, {8, 12}, {8, 16}, {8, 20}, {8, 24}, {8, 28}, {8, 32}, {8, 36}, {8, 40}, {8, 44}, {16, 24}, {16, 28}, {20, 16}, {20, 20}, {20, 32}, {20, 36}, {24, 16}, {24, 36}, {28, 16}, {28, 36}, {32, 20}, {32, 24}, {32, 28}, {32, 32}, {36, 16}, {40, 16}, {40, 20}, {40, 24}, {40, 28}, {40, 44}, {44, 28}, {44, 32}, {44, 36}, {44, 40}, {48, 24}, {48, 28}, {48, 32}, {52, 16}, {52, 20}, {56, 24}, {56, 28}, {60, 16}, {60, 20}, {60, 24}, {60, 32}, {60, 36}, {64, 16}, {64, 24}, {64, 36}, {68, 16}, {68, 24}, {68, 36}, {72, 20}, {72, 24}, {72, 32}, {80, 16}, {80, 20}, {80, 24}, {80, 28}, {80, 32}, {80, 36}, {84, 36}, {88, 36}, {92, 16}, {92, 20}, {92, 24}, {92, 28}, {92, 32}, {92, 36}, {100, 16}, {100, 20}, {100, 32}, {100, 36}, {104, 20}, {104, 24}, {104, 28}, {104, 32}, {108, 20}, {108, 24}, {108, 28}, {108, 32}, {112, 16}, {112, 20}, {112, 32}, {112, 36}, {128, 20}, {128, 28}, {128, 32}, {128, 36}, {132, 16}, {132, 20}, {132, 28}, {132, 36}, {136, 16}, {136, 24}, {136, 36}, {140, 16}, {140, 20}, {140, 24}, {140, 32}, {144, 20}, {144, 24}, {144, 28}, {144, 32}, {144, 36}, {152, 16}, {152, 20}, {152, 24}, {152, 28}, {152, 32}, {152, 36}, {156, 16}, {160, 16}, {164, 16}, {164, 20}, {164, 24}, {164, 28}, {164, 32}, {164, 36}, {172, 16}, {172, 20}, {172, 24}, {172, 28}, {172, 32}, {172, 36}, {176, 16}, {176, 20}, {180, 16}, {184, 16}, {184, 20}, {184, 24}, {184, 28}, {184, 32}, {184, 36}, {188, 20}, {188, 24}, {188, 28}, {188, 32}, {188, 36}, {192, 8}, {192, 12}, {192, 16}, {192, 20}, {192, 24}, {192, 28}, {192, 32}, {192, 36}, {200, 16}, {200, 20}, {204, 20}, {204, 24}, {204, 28}, {208, 32}, {208, 36}, {212, 24}, {212, 28}, {212, 32}, {216, 16}, {216, 20}, {220, 24}, {220, 28}, {224, 16}, {224, 20}, {224, 24}, {224, 32}, {224, 36}, {228, 16}, {228, 24}, {228, 36}, {232, 16}, {232, 24}, {232, 36}, {236, 20}, {236, 24}, {236, 32}, {244, 16}, {244, 20}, {244, 24}, {244, 28}, {244, 32}, {244, 36}, {248, 16}, {248, 20}, {252, 16}, {256, 20}, {256, 24}, {256, 32}, {256, 36}, {260, 16}, {260, 24}, {260, 36}, {264, 16}, {264, 28}, {264, 36}, {268, 16}, {268, 20}, {268, 28}, {268, 32}, {268, 36}, {276, 20}, {276, 28}, {276, 32}, {276, 36}, {280, 16}, {280, 28}, {280, 36}, {284, 16}, {284, 24}, {284, 36}, {288, 16}, {288, 20}, {288, 24}, {288, 28}, {288, 32}, {288, 36}, {292, 36}, {300, 8}, {300, 12}, {300, 16}, {300, 20}, {300, 24}, {300, 28}, {300, 32}, {300, 36}, {308, 16}, {308, 20}, {308, 24}, {308, 28}, {308, 32}, {308, 36}, {312, 16}, {312, 20}, {316, 16}, {320, 20}, {320, 24}, {320, 28}, {320, 32}, {324, 16}, {324, 24}, {324, 36}, {328, 16}, {328, 24}, {328, 36}, {332, 16}, {332, 20}, {332, 24}, {332, 32}, {332, 36}, {336, 20}, {336, 24}, {336, 32}, {352, 32}, {352, 36}, {356, 8}, {356, 12}, {356, 16}, {356, 20}, {356, 24}, {356, 32}, {356, 36}}







--- Internal Use:
local particle_type_list = {}
local loop_index = 0



local function TouchPlayer(player_name)
	local player = pshy.players[player_name]
	player.particledraw_particles = {}
	player.particledraw_brush = {particle_type_index = 1, particle_type = tfm.enum.particle[particle_type_list[1]], delay = 1, delay_start = 0, tool = pshy.particledraw_tools.none}
	system.bindMouse(player_name, true)
end



local function Clear(player_name)
	local player = pshy.players[player_name]
	player.particledraw_particles = {}
end



function eventMouse(player_name, x, y)
	local player = pshy.players[player_name]
	local brush = player.particledraw_brush
	local particles = player.particledraw_particles
	if brush.tool == pshy.particledraw_tools.pen then
		
		local new_particle = {}
		new_particle.x = x
		new_particle.y = y
		new_particle.type = player.particledraw_brush.particle_type
		new_particle.delay = player.particledraw_brush.delay
		new_particle.delay_start = player.particledraw_brush.delay_start % player.particledraw_brush.delay
		player.particledraw_brush.delay_start = player.particledraw_brush.delay_start + 1
		for prop, val in pairs(player.particledraw_brush) do
			new_particle[prop] = val
		end
		table.insert(particles, new_particle)
	
	elseif brush.tool == pshy.particledraw_tools.paste then
		for i_coords, coords in ipairs(pshy.particledraw_shapes.joyeux_anniversaire) do
			local x = x + coords[1] * 1
			local y = y + coords[2] * 1
			
			local new_particle = {}
			new_particle.x = x
			new_particle.y = y
			new_particle.type = player.particledraw_brush.particle_type
			new_particle.delay = player.particledraw_brush.delay
			new_particle.delay_start = player.particledraw_brush.delay_start % player.particledraw_brush.delay
			player.particledraw_brush.delay_start = player.particledraw_brush.delay_start + 1
			for prop, val in pairs(player.particledraw_brush) do
				new_particle[prop] = val
			end
			table.insert(particles, new_particle)
			
		end
	end
end



function eventPlayerLeft(player_name)
	Clear(player_name)
end



function eventLoop()
	loop_index = loop_index + 1
	for player_name, player in pairs(pshy.players) do
		for i_particle, particle in pairs(player.particledraw_particles) do
			if (loop_index + particle.delay_start) % particle.delay == 0 then
				tfm.exec.displayParticle(particle.type, particle.x, particle.y, 0, 0, 0, 0, nil)
			end
		end
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



--- !particletypes
local function ChatCommandParticletypes(user, target)
	for particle_type in pairs(tfm.enum.particle) do
		tfm.exec.chatMessage(particle_type, user)
	end
	return true
end 
pshy.commands["particletypes"] = {func = ChatCommandParticletypes, desc = "list particle types", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_particledraw"].commands["particletypes"] = pshy.commands["particletypes"]



--- !particletype
local function ChatCommandParticletype(user, particle_type)
	local player = pshy.players[user]
	local brush = player.particledraw_brush
	brush.particle_type = particle_type
end 
pshy.commands["particletype"] = {func = ChatCommandParticletype, desc = "choose the particle to use", argc_min = 1, argc_max = 1, arg_types = {tfm.enum.particle}}
pshy.help_pages["pshy_particledraw"].commands["particletype"] = pshy.commands["particletype"]



--- !particledelay
local function ChatCommandParticledelay(user, delay)
	local player = pshy.players[user]
	local brush = player.particledraw_brush
	brush.delay = delay
end 
pshy.commands["particledelay"] = {func = ChatCommandParticledelay, desc = "choose the delay between particles", argc_min = 1, argc_max = 1, arg_types = {"number"}}
pshy.help_pages["pshy_particledraw"].commands["particledelay"] = pshy.commands["particledelay"]



--- !particletool
local function ChatCommandParticletool(user, tool)
	local player = pshy.players[user]
	local brush = player.particledraw_brush
	brush.tool = tool
end 
pshy.commands["particletool"] = {func = ChatCommandParticletool, desc = "choose the particle tool", argc_min = 1, argc_max = 1, arg_types = {pshy.particledraw_tools}}
pshy.help_pages["pshy_particledraw"].commands["particletool"] = pshy.commands["particletool"]



--- !particleclear
local function ChatCommandParticleclear(user, tool)
	local player = pshy.players[user]
	player.particledraw_particles = {}
end 
pshy.commands["particleclear"] = {func = ChatCommandParticleclear, desc = "clear your particles", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_particledraw"].commands["particleclear"] = pshy.commands["particleclear"]
