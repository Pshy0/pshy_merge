--- pacmouse.lua
--
-- @require pshy_perms.lua
-- @require pshy_lua_commands.lua
-- @require pshy_fun_commands.lua
-- @require pshy_speedfly.lua
-- @require pshy_keycodes.lua



--- TFM Settings
tfm.exec.disableAutoNewGame(true)



--- Pshy Settings:
pshy.perms_auto_admin_authors = true
pshy.authors["Nnaaaz#0000"] = true



--- Module Settings:
xml = [[<C><P H="700" MEDATA=";;;;-0;0:::1-"/><Z><S><S T="12" X="168" Y="90" L="56" H="56" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="614" Y="90" L="56" H="56" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="286" Y="90" L="79" H="56" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="492" Y="90" L="79" H="56" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="248" Y="246" L="10" H="160" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="533" Y="246" L="10" H="160" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="388" Y="12" L="610" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="91" Y="113" L="10" H="210" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="690" Y="113" L="10" H="210" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="142" Y="221" L="108" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="641" Y="221" L="108" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="196" Y="258" L="10" H="81" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="586" Y="260" L="10" H="85" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="143" Y="299" L="113" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="636" Y="297" L="101" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="91" Y="326" L="10" H="62" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="682" Y="326" L="10" H="62" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="145" Y="352" L="111" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="635" Y="353" L="100" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="196" Y="391" L="10" H="83" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="586" Y="391" L="10" H="81" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="145" Y="428" L="105" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="638" Y="428" L="105" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="90" Y="558" L="10" H="270" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="690" Y="558" L="10" H="270" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="391" Y="689" L="605" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="390" Y="65" L="32" H="108" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="392" Y="169" L="180" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="390" Y="428" L="130" H="10" P="0,0,0.3,0.2,360,0,0,0" o="324650"/><S T="12" X="401" Y="533" L="135" H="10" P="0,0,0.3,0.2,360,0,0,0" o="324650"/><S T="12" X="234" Y="638" L="185" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="548" Y="638" L="181" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="170" Y="169" L="50" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="612" Y="169" L="50" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="390" Y="197" L="32" H="56" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="390" Y="459" L="32" H="55" P="0,0,0.3,0.2,360,0,0,0" o="324650"/><S T="12" X="390" Y="585" L="32" H="103" P="0,0,0.3,0.2,360,0,0,0" o="324650"/><S T="12" X="172" Y="481" L="55" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="609" Y="481" L="55" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="195" Y="532" L="10" H="107" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="586" Y="532" L="10" H="107" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="286" Y="481" L="73" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="494" Y="481" L="76" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="248" Y="403" L="10" H="55" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="533" Y="403" L="10" H="56" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="248" Y="583" L="10" H="100" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="533" Y="583" L="10" H="99" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="289" Y="221" L="75" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="495" Y="221" L="71" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="118" Y="559" L="52" H="54" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="664" Y="559" L="52" H="54" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="393" Y="376" L="181" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="300" Y="326" L="10" H="109" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="481" Y="326" L="10" H="108" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="325" Y="275" L="60" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="456" Y="274" L="60" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="9" X="391" Y="324" L="158" H="77" P="0,0,0,0,0,0,0,0" m=""/><S T="12" X="312" Y="585" L="30" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="469" Y="585" L="30" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/></S><D><DS X="390" Y="316"/></D><O/><L/></Z></C>]]
path_cells = {}
map_x = 12
map_y = 12
cell_w = 26
cell_h = 26
cur_x = 0
cur_y = 0
grid_w = 40
grid_h = 40
generating = true
linear_grid = {}
wall_size = 10
pilot = ""
pacman_image_id = nil
pacman_direction = 0 -- 0 90 180 270




--- Distance
-- @todo Move this to utils.
function Distance(x1, y1, x2, y2)
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end



--- Generate a default grid.
function GenerateGrid(w, h)
	grid_w = w
	grid_h = h
	for y = 0, (h - 1) do
		for x = 0, (w - 1) do
			--linear_grid[y * w] = nil
		end
	end
end



--- Get a cell value.
function GridGet(x, y)
	return linear_grid[y * grid_w + x]
end



--- Set a cell value.
function GridSet(x, y, value)
	linear_grid[y * grid_w + x] = value
end



--- Get grid coordinates from a point on screen.
function GetGridCoords(x, y)
	x = math.floor((x - map_x) / cell_w + 0.5)
	y = math.floor((y - map_y) / cell_h + 0.5)
	return x, y
end



--- Export the grid.
function GridExportPathes(player_name)
	local total = "{"
	-- generate export string
	for y = 0, (grid_h - 1) do
		for x = 0, (grid_w - 1) do
			if GridGet(x, y) then
				if #total > 1 then
					total = total .. ", "
				end
				total = total .. "{" .. tostring(x) .. ", " .. tostring(y) .. "}"
			end
		end
	end
	total = total .. "}"
	-- export
	while #total > 0 do
		subtotal = string.sub(total, 1, 200)
		tfm.exec.chatMessage(total, player_name)
		total = string.sub(total, 201, #total)
	end
end



--- Redraw the cursor.
function DrawCursor()
	local x = cur_x * cell_w + map_x
	local y = cur_y * cell_h + map_y
	if pacman_image_id then
			tfm.exec.removeImage(pacman_image_id)
	end
	if generating then
		tfm.exec.addPhysicObject(1, x + cell_w / 2, y, {type = tfm.enum.ground.rectangle, width = 5, height = 2000, foreground = false, color = 0xdd4400, miceCollision = false})
		tfm.exec.addPhysicObject(2, x - cell_w / 2, y, {type = tfm.enum.ground.rectangle, width = 5, height = 2000, foreground = false, color = 0xdd4400, miceCollision = false})
		tfm.exec.addPhysicObject(3, x, y + cell_h / 2, {type = tfm.enum.ground.rectangle, width = 2000, height = 5, foreground = false, color = 0xdd4400, miceCollision = false})
		tfm.exec.addPhysicObject(4, x, y - cell_h / 2, {type = tfm.enum.ground.rectangle, width = 2000, height = 5, foreground = false, color = 0xdd4400, miceCollision = false})
	end
	local size = (cell_w * 2) - wall_size
	--tfm.exec.addPhysicObject(1, x, y, {type = tfm.enum.ground.rectangle, width = size, height = size, foreground = false, color = 0xffff00, miceCollision = false})
	pacman_image_id = tfm.exec.addImage("1718e694e82.png", "!0", x, y, nil, 0.5, 0.5, pacman_direction, 1.0, 0.5, 0.5)
end



--- TFM event eventMouse.
function eventMouse(player_name, x, y)
	if player_name == pilot then
		cur_x, cur_y = GetGridCoords(x, y)
		DrawCursor()
	end
end



--- TFM event eventkeyboard.
function eventKeyboard(player_name, key_code, down, x, y)
	if down and player_name == pilot then
		new_x = cur_x
		new_y = cur_y
		if key_code == pshy.keycodes.UP then
			new_y = cur_y - 1
			pacman_direction = (math.pi / 2) * 1
		elseif key_code == pshy.keycodes.DOWN then
			new_y = cur_y + 1
			pacman_direction =  (math.pi / 2) * 3
		elseif key_code == pshy.keycodes.LEFT then
			new_x = cur_x - 1
			pacman_direction = 0
		elseif key_code == pshy.keycodes.RIGHT then
			new_x = cur_x + 1
			pacman_direction = (math.pi / 2) * 2
		end
		-- map bounds
		if new_x < 0 then
			new_x = 0
		end
		if new_y < 0 then
			new_y = 0
		end
		if new_x > grid_w then
			new_x = grid_w
		end
		if new_y > grid_h then
			new_y = grid_h
		end
		-- walls
		if generating then
			GridSet(new_x, new_y, true)
		elseif not GridGet(new_x, new_y) then
			return
		end
		-- update
		cur_x = new_x
		cur_y = new_y
		-- redraw
		DrawCursor()
	end
end



--- Initialization:
GenerateGrid(grid_w, grid_h)
for i_path, path in ipairs(path_cells) do
	GridSet(path.x, path.y, true)
end
for player_name in pairs(tfm.get.room.playerList) do
	system.bindMouse(player_name, true)
	system.bindKeyboard(player_name, pshy.keycodes.UP, true, true)
	system.bindKeyboard(player_name, pshy.keycodes.DOWN, true, true)
	system.bindKeyboard(player_name, pshy.keycodes.LEFT, true, true)
	system.bindKeyboard(player_name, pshy.keycodes.RIGHT, true, true)
end
tfm.exec.newGame(xml)
