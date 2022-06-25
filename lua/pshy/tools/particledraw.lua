---- pshy.tools.particledraw
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local command_list = pshy.require("pshy.commands.list")
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")
pshy.require("pshy.players")



--- Module Help Page:
help_pages["pshy_particledraw"] = {back = "pshy", title = "Particle Drawing", commands = {}}
help_pages["pshy"].subpages["pshy_particledraw"] = help_pages["pshy_particledraw"]



--- Tool types enum.
pshy.particledraw_tools = {}
pshy.particledraw_tools.none = 0
pshy.particledraw_tools.pen = 1
pshy.particledraw_tools.paste = 2



--- Predefined:
pshy.particledraw_shapes = {}
pshy.particledraw_shapes.example = {{0, 0}}



--- Internal Use:
local particle_type_list = {}
local loop_index = 0



local function TouchPlayer(player_name)
	local player = pshy.players[player_name]
	player.particledraw_particles = {}
	player.particledraw_brush = {particle_type_index = 1, particle_type = tfm.enum.particle.redGlitter, delay = 1, delay_start = 0, tool = pshy.particledraw_tools.none, paste = pshy.particledraw_shapes.jac40}
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
		for i_coords, coords in ipairs(brush.paste) do
			local x = x + coords[1]
			local y = y + coords[2]
			
			local new_particle = {}
			new_particle.x = x
			new_particle.y = y
			new_particle.type = player.particledraw_brush.particle_type
			new_particle.delay = player.particledraw_brush.delay
			new_particle.delay_start = player.particledraw_brush.delay_start % player.particledraw_brush.delay
			player.particledraw_brush.delay_start = player.particledraw_brush.delay_start + 1
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
command_list["particletypes"] = {func = ChatCommandParticletypes, desc = "list particle types", argc_min = 0, argc_max = 0, arg_types = {}}
help_pages["pshy_particledraw"].commands["particletypes"] = command_list["particletypes"]



--- !particletype
local function ChatCommandParticletype(user, particle_type)
	local player = pshy.players[user]
	local brush = player.particledraw_brush
	brush.particle_type = particle_type
end 
command_list["particletype"] = {func = ChatCommandParticletype, desc = "choose the particle to use", argc_min = 1, argc_max = 1, arg_types = {tfm.enum.particle}}
help_pages["pshy_particledraw"].commands["particletype"] = command_list["particletype"]



--- !particledelay
local function ChatCommandParticledelay(user, delay)
	local player = pshy.players[user]
	local brush = player.particledraw_brush
	brush.delay = delay
end 
command_list["particledelay"] = {func = ChatCommandParticledelay, desc = "choose the delay between particles", argc_min = 1, argc_max = 1, arg_types = {"number"}}
help_pages["pshy_particledraw"].commands["particledelay"] = command_list["particledelay"]



--- !particletool
local function ChatCommandParticletool(user, tool)
	local player = pshy.players[user]
	local brush = player.particledraw_brush
	brush.tool = tool
end 
command_list["particletool"] = {func = ChatCommandParticletool, desc = "choose the particle tool", argc_min = 1, argc_max = 1, arg_types = {pshy.particledraw_tools}}
help_pages["pshy_particledraw"].commands["particletool"] = command_list["particletool"]



--- !particlepaste
local function ChatCommandParticlepaste(user, paste)
	local player = pshy.players[user]
	local brush = player.particledraw_brush
	brush.paste = paste
end 
command_list["particlepaste"] = {func = ChatCommandParticlepaste, desc = "choose the shape to paste", argc_min = 1, argc_max = 1, arg_types = {pshy.particledraw_shapes}}
help_pages["pshy_particledraw"].commands["particlepaste"] = command_list["particlepaste"]



--- !particleclear
local function ChatCommandParticleclear(user, tool)
	local player = pshy.players[user]
	player.particledraw_particles = {}
end 
command_list["particleclear"] = {func = ChatCommandParticleclear, desc = "clear your particles", argc_min = 0, argc_max = 0, arg_types = {}}
help_pages["pshy_particledraw"].commands["particleclear"] = command_list["particleclear"]
