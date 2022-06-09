--- pshy_wheel.lua
--
-- Summon a fortune wheel.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



--- TFM Settings
tfm.exec.disableAfkDeath()
tfm.exec.disableAutoNewGame()
tfm.exec.disableAutoTimeLeft()
tfm.exec.disableAutoShaman()



--- Internal use
local images = {}
images["star"] = {image = "17c41856d4a.png", w = 30, h = 30}
local anchor_object_id = 16
local anchor_joint_id = 17
local wheel_object_id = 18
local wheel_front_object_id = 19
local wheel_lines_id_start = 25
local wheel_lines_id_next = wheel_lines_id_start
local wheel_image_ground_id_start = 25
local wheel_image_ground_next = wheel_image_ground_id_start
local background_lines_width = 20
local background_lines_angle_interval = 0.1
local x = 300
local y = 200
local width = 128
local back_color = 0x371d10
local prices = {}
local required_background_lines = 80 * width / 128
for i = 1,6 do
	table.insert(prices, {color = math.random(0, 0xffffff), image = images["star"]})
end
--[[
table.insert(prices, {color = 0xffff00})
table.insert(prices, {color = 0xff2222})
table.insert(prices, {color = 0xffff22})
table.insert(prices, {color = 0xff2222})
table.insert(prices, {color = 0xff00ff})
--table.insert(prices, {color = 0xff2222})
--]]--



function eventNewGame()
	-- Precomputing
	local angle_delta = 2 * math.pi / #prices
	for i_price, price in ipairs(prices) do
		price.start_angle = (i_price - 1) * angle_delta
		price.avg_angle = price.start_angle + angle_delta / 2
		price.stop_angle = price.start_angle + angle_delta
	end
	-- Spawning the wheel
	tfm.exec.addPhysicObject(anchor_object_id, x, y, {type = 13, width = 10, color = 0x0000ff, height = 10, miceCollision = false, groundCollision = false})
	tfm.exec.addPhysicObject(wheel_object_id, x, y, {type = 13, width = width, height = 10, color = 0, friction = 40, restitution = 0, mass = 2000, dynamic = true, miceCollision = true, groundCollision = false, linearDamping = 5})
	tfm.exec.addJoint(anchor_joint_id, anchor_object_id, wheel_object_id, {type = 3, color = 0x00ff00})
	--tfm.exec.addPhysicObject(wheel_front_object_id, x, y, {type = 13, width = width / 4, height = 10, color = back_color, friction = 40, dynamic = false, miceCollision = false, groundCollision = false, foreground = true})
	-- transparent wheel
	tfm.exec.addImage("1813f40a2f6.png", "+" .. tostring(wheel_object_id), 0, 0, nil, 0.005, 0.005, 0, nil, nil, true)
	-- Draw wheel background
	local center_str = string.format("%d,%d", x, y)
	local center_str_p = string.format("%d,%d", x + 1, y + 1)
	--tfm.exec.addJoint(wheel_lines_id_next, wheel_object_id, wheel_object_id, {type = 0, point1 = center_str, point2 = center_str_p, line = width * 2, color = back_color, foreground = false})
	wheel_lines_id_next = wheel_lines_id_next + 1
	-- Draw wheel inside
	for i_price, price in ipairs(prices) do
		local point1_x = x + math.cos(price.avg_angle) * background_lines_width / 2
		local point1_y = y + math.sin(price.avg_angle) * background_lines_width / 2
		local point1_str = string.format("%d,%d", point1_x, point1_y)
		for angle = price.start_angle+background_lines_angle_interval,price.stop_angle,background_lines_angle_interval do
			local side_x = x + math.cos(angle) * (width - background_lines_width)
			local side_y = y + math.sin(angle) * (width - background_lines_width)
			local side_str = string.format("%d,%d", side_x, side_y)
			tfm.exec.addJoint(wheel_lines_id_next, wheel_object_id, wheel_object_id, {type = 0, point1 = point1_str, point2 = side_str, line = background_lines_width, color = price.color, foreground = false})
			wheel_lines_id_next = wheel_lines_id_next + 1
		end
		-- Image
		if price.image then
			local img_x = math.cos(price.avg_angle) * (width * 2 / 3)
			local img_y = math.sin(price.avg_angle) * (width * 2 / 3)
			local img_coords_str = string.format("%d,%d", x + img_x, y + img_y)
			tfm.exec.addPhysicObject(wheel_image_ground_next, x + img_x, y + img_y, {type = 13, width = 10, color = 0xff000000, mass = 0.0000001, miceCollision = false, groundCollision = false, dynamic = true})
			tfm.exec.addJoint(wheel_lines_id_next, wheel_object_id, wheel_image_ground_next, {type = 1, point1 = img_coords_str, point2 = img_coords_str, axis = "1,0", limit1 = 0, limit2 = 0, line = 2, color = 0xffffff, foreground = true})
			wheel_lines_id_next = wheel_lines_id_next + 1
			tfm.exec.addImage(price.image.image, "+" .. wheel_image_ground_next, - price.image.w / 2, - price.image.h / 2, nil, 1, 1, 0, 1, nil, nil)
			wheel_image_ground_next = wheel_image_ground_next + 1
		end
	end
	-- Draw wheel limits
	for i_price, price in ipairs(prices) do
		local side_x = x + math.cos(price.start_angle) * (width - 10)
		local side_y = y + math.sin(price.start_angle) * (width - 10)
		local side_str = string.format("%d,%d", side_x, side_y)
		tfm.exec.addJoint(wheel_lines_id_next, wheel_object_id, wheel_object_id, {type = 0, point1 = center_str, point2 = side_str, line = 10, color = 0x000000, foreground = true})
		wheel_lines_id_next = wheel_lines_id_next + 1
	end
end



tfm.exec.newGame(25)
