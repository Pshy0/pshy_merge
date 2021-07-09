--- pshy_antileve.lua
--
-- Allow the room admin to place leve traps.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_ban.lua
-- @require pshy_help.lua
-- @require pshy_merge.lua
-- @require pshy_perms.lua
-- @require pshy_ui.lua



--- Module Help Page.
pshy.help_pages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"] or {back = "pshy", restricted = true, text = "", commands = {}, subpages = {}}
pshy.help_pages["pshy"].subpages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"]
pshy.help_pages["pshy_antileve"] = {back = "pshy", restricted = true, text = "This module allow you to place leve traps on any running map.\nPress the antileve key (F1 by default), then click once on the top of a vertical wall (but on the horizontal surface), then on the bottom edge of a wall to trap it. Try to aim for the edge, and be as accurate as possible.\nAll admins can use the key.\n", examples = {}}
pshy.help_pages["pshy_antileve"].commands = {}
pshy.help_pages["pshy_antileve"].examples["luaget pshy.antileve_key"] = "get the current key"
pshy.help_pages["pshy_antileve"].examples["luaget pshy.antileve_key"] = "set the key to TAB"
pshy.help_pages["pshy_antileve"].examples["!luaset pshy.antileve_trap_color 0xff0000"] = "traps you set will be visible"
pshy.help_pages["pshy_anticheats"].subpages["pshy_antileve"] = pshy.help_pages["pshy_antileve"]



--- Module settings.
pshy.antileve_key = 112			-- key to press to start making an antileve trap (121 -> `F10`)
pshy.antileve_arbitrary_ui_id = 69		-- id used for the inteface
pshy.antileve_arbitrary_ground_id = 380	-- first Id used for grounds
pshy.antileve_bad_keys = {}			-- set of player leve switch keys
pshy.antileve_bad_keys[9] = "TAB"
pshy.antileve_bad_keys[16] = "SHIFT"
pshy.antileve_trap_friction = 0.01		-- friction of leve traps
pshy.antileve_trap_angle = 1.2		-- angle of leve traps walls
pshy.antileve_trap_color = nil		-- angle of leve traps walls



--- Internal use.
pshy.antileve_active = false			-- is an antileve trap active this game (true after the first trap is set)
pshy.antileve_trap_setter = nil		-- admin currently setting the trap
pshy.antileve_trap_x1 = nil
pshy.antileve_trap_y1 = nil
pshy.antileve_trap_next_ground_id = pshy.antileve_arbitrary_ground_id



--- TFM event eventMouse
function eventMouse(player_name, x, y)
	if player_name == pshy.antileve_trap_setter then
		if not pshy.antileve_trap_x1 then
			pshy.antileve_trap_x1 = x
			pshy.antileve_trap_y1 = y
			tfm.exec.chatMessage("<j>[Antileve] Click at the bottom SIDE of the wall.</j>", player_name)
		else
			if math.abs(pshy.antileve_trap_x1 - x) < 32 then
				local new_h = math.abs(pshy.antileve_trap_y1 - y)
				if new_h > 40 then
					local new_x = (x < pshy.antileve_trap_x1) and (x + 4) or (x - 4)
					local new_y = (pshy.antileve_trap_y1 + y) / 2
					local new_angle = (x < pshy.antileve_trap_x1) and -pshy.antileve_trap_angle or pshy.antileve_trap_angle
					tfm.exec.addPhysicObject(pshy.antileve_trap_next_ground_id, new_x, new_y, {type = 12, width = 10, height = new_h, foreground = false, friction = pshy.antileve_trap_friction, restitution = 0.0, angle = new_angle, color = pshy.antileve_trap_color, miceCollision = true, groundCollision = false})
					pshy.antileve_active = true
					pshy.antileve_trap_next_ground_id = pshy.antileve_trap_next_ground_id + 1
					pshy.Log("<rose>[Antileve] Trap set!</rose>")
				else
					tfm.exec.chatMessage("<r>[Antileve] The surface is not tall enough.</r>", player_name)
				end
			else
				tfm.exec.chatMessage("[Antileve] You are not accurate enough.", player_name)
			end
			pshy.antileve_trap_setter = nil
			pshy.antileve_trap_x1 = nil
			pshy.antileve_trap_y1 = nil	
		end
	end
end



--- TFM event eventKeyboard
function eventKeyboard(player_name, key_code, down, x, y)
	-- start trap
	if key_code == pshy.antileve_key and pshy.admins[player_name] then
		if not pshy.antileve_trap_setter then
			pshy.antileve_trap_setter = player_name
			system.bindMouse(player_name, true)
			tfm.exec.chatMessage("<j>[Antileve] Click at the top of a wall to place the trap on.</j>", player_name)
		else
			tfm.exec.chatMessage("<r>[Antileve] A room admin is already setting the trap.</r>", player_name)
		end
	end
	-- list key trapped players
	if pshy.antileve_active and pshy.antileve_bad_keys[key_code] then
		--print("[Antileve] While trap active: " .. player_name .. " " .. pshy.antileve_bad_keys[key_code] .. " " .. (down and "down" or "up") .. "!")
		pshy.Log("[Antileve] While trap active: " .. player_name .. " " .. pshy.antileve_bad_keys[key_code] .. " " .. (down and "down" or "up") .. "!")
	end
end



--- TFM event eventNewGame
function eventNewGame()
	for admin, void in pairs(pshy.admins) do
		system.bindKeyboard(admin, pshy.antileve_key, true, true)
	end
	pshy.antileve_active = false
	pshy.antileve_trap_setter = nil
	pshy.antileve_trap_next_ground_id = pshy.antileve_arbitrary_ground_id
end



--- TFM event eventNewPlayer
function eventNewPlayer(player_name)	
	for key, void in pairs(pshy.antileve_bad_keys) do
		system.bindKeyboard(player_name, key, true, true)
		system.bindKeyboard(player_name, key, false, true)
	end
end



--- Initialization
system.bindKeyboard(pshy.host, pshy.antileve_key, true, true)	-- bind antileve key to the host
for player_name, void in pairs(tfm.get.room.playerList) do
	for key, void in pairs(pshy.antileve_bad_keys) do
		system.bindKeyboard(player_name, key, true, true)
		system.bindKeyboard(player_name, key, false, true)
	end
end



-- TMP
--tfm.exec.disableAutoShaman(true)
