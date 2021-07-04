--- pshy_levetrap.lua
--
-- Allow the room admin to place leve traps.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_perms.lua
-- @require pshy_help.lua
-- @require pshy_ui.lua



--- Module Help Page.
pshy.help_pages["pshy_levetrap"] = {back = "pshy", restricted = true, text = "This module allow you to place leve traps on any running map.\nPress the levetrap key (F1 by default), then click once on the top of a vertical wall (but on the horizontal surface), then on the bottom edge of a wall to trap it. Try to aim for the edge, and be as accurate as possible.\nAll admins can use the key.\n", examples = {}}
pshy.help_pages["pshy_levetrap"].commands = {}
pshy.help_pages["pshy_levetrap"].examples["luaget pshy.levetrap_key"] = "Get the current key."
pshy.help_pages["pshy_levetrap"].examples["luaget pshy.levetrap_key"] = "Set the key to TAB."
pshy.help_pages["pshy_levetrap"].examples["!luaset pshy.levetrap_trap_color 0xff0000"] = "Traps you set will be visible."
pshy.help_pages["pshy"].subpages["pshy_levetrap"] = pshy.help_pages["pshy_levetrap"]



--- Module settings.
pshy.levetrap_key = 112			-- key to press to start making an levetrap trap (121 -> `F10`)
pshy.levetrap_arbitrary_ui_id = 69		-- id used for the inteface
pshy.levetrap_arbitrary_ground_id = 380	-- first Id used for grounds
pshy.levetrap_bad_keys = {}			-- set of player leve switch keys
pshy.levetrap_bad_keys[9] = true
pshy.levetrap_bad_keys[16] = true
pshy.levetrap_trap_friction = 0.01		-- friction of leve traps
pshy.levetrap_trap_angle = 1.2		-- angle of leve traps walls
pshy.levetrap_trap_color = nil		-- angle of leve traps walls



--- Internal use.
pshy.levetrap_active = false			-- is an levetrap trap active this game (true after the first trap is set)
pshy.levetrap_trap_setter = nil		-- admin currently setting the trap
pshy.levetrap_trap_x1 = nil
pshy.levetrap_trap_y1 = nil
pshy.levetrap_trap_next_ground_id = pshy.levetrap_arbitrary_ground_id



--- TFM event eventMouse
function eventMouse(player_name, x, y)
	if player_name == pshy.levetrap_trap_setter then
		if not pshy.levetrap_trap_x1 then
			pshy.levetrap_trap_x1 = x
			pshy.levetrap_trap_y1 = y
			tfm.exec.chatMessage("<j>[Pshylevetrap] Click at the bottom SIDE of the wall.</j>", player_name)
		else
			if math.abs(pshy.levetrap_trap_x1 - x) < 32 then
				local new_h = math.abs(pshy.levetrap_trap_y1 - y)
				if new_h > 40 then
					local new_x = (x < pshy.levetrap_trap_x1) and (x + 4) or (x - 4)
					local new_y = (pshy.levetrap_trap_y1 + y) / 2
					local new_angle = (x < pshy.levetrap_trap_x1) and -pshy.levetrap_trap_angle or pshy.levetrap_trap_angle
					tfm.exec.addPhysicObject(pshy.levetrap_trap_next_ground_id, new_x, new_y, {type = 12, width = 10, height = new_h, foreground = false, friction = pshy.levetrap_trap_friction, restitution = 0.0, angle = new_angle, color = pshy.levetrap_trap_color, miceCollision = true, groundCollision = false})
					pshy.levetrap_active = true
					pshy.levetrap_trap_next_ground_id = pshy.levetrap_trap_next_ground_id + 1
					tfm.exec.chatMessage("<rose>[Pshylevetrap] Trap set!</rose>", player_name)
				else
					tfm.exec.chatMessage("<r>[Pshylevetrap] The surface is not tall enough.</r>", player_name)
				end
			else
				tfm.exec.chatMessage("[Pshylevetrap] You are not accurate enough.", player_name)
			end
			pshy.levetrap_trap_setter = nil
			pshy.levetrap_trap_x1 = nil
			pshy.levetrap_trap_y1 = nil	
		end
	end
end



--- TFM event eventKeyboard
function eventKeyboard(player_name, key_code, down, x, y)
	-- start trap
	if key_code == pshy.levetrap_key and pshy.admins[player_name] then
		if not pshy.levetrap_trap_setter then
			pshy.levetrap_trap_setter = player_name
			system.bindMouse(player_name, true)
			tfm.exec.chatMessage("<j>[Pshylevetrap] Click at the top of a wall to place the trap on.</j>", player_name)
		else
			tfm.exec.chatMessage("<r>[Pshylevetrap] An admin is already setting the trap.</r>", player_name)
		end
	end
	-- list key trapped players
	if pshy.levetrap_active and pshy.levetrap_bad_keys[key_code] then
		print("[Pshylevetrap] " .. player_name .. "key " .. key_code .. " " .. (down and "down" or "up") .. "!")
		for admin, void in pairs(pshy.admins) do
			tfm.exec.chatMessage("[Pshylevetrap] " .. player_name .. "key " .. key_code .. " " .. (down and "down" or "up") .. "!", admin)
		end
	end
end



--- TFM event eventNewGame
function eventNewGame()
	for admin, void in pairs(pshy.admins) do
		system.bindKeyboard(admin, pshy.levetrap_key, true, true)
	end
	pshy.levetrap_active = false
	pshy.levetrap_trap_setter = nil
	pshy.levetrap_trap_next_ground_id = pshy.levetrap_arbitrary_ground_id
end



--- TFM event eventNewPlayer
function eventNewPlayer(player_name)	
	for key, void in pairs(pshy.levetrap_bad_keys) do
		system.bindKeyboard(player_name, key, true, true)
		system.bindKeyboard(player_name, key, false, true)
	end
end



--- Initialization
system.bindKeyboard(pshy.host, pshy.levetrap_key, true, true)	-- bind levetrap key to the host
for player_name, void in pairs(tfm.get.room.playerList) do
	for key, void in pairs(pshy.levetrap_bad_keys) do
		system.bindKeyboard(player_name, key, true, true)
		system.bindKeyboard(player_name, key, false, true)
	end
end



-- TMP
--tfm.exec.disableAutoShaman(true)
