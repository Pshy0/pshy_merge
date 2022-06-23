--- pshy.bases.cannons
--
-- Adds automatic cannons.
-- Extends `pshy_mapdb` maps with an optional `cannons` table.
-- See below for details.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy_events")



--- Module Settings:
local object_cannons = {}
-- Example:
-- local OBJECT_TYPE_APPLE_CANNON = 1705
-- local OBJECT_TYPE_ARROW = 35
-- table.insert(object_cannons, {loop_delay = 4, loop_delay_offset = 0, type = OBJECT_TYPE_APPLE_CANNON, x = 3065, y = 354, angle = -135})
-- table.insert(object_cannons, {loop_delay = 4, loop_delay_offset = 1, type = OBJECT_TYPE_APPLE_CANNON, x = 2816, y = 426, angle = 135})
-- table.insert(object_cannons, {loop_delay = 4, loop_delay_offset = 2, type = OBJECT_TYPE_APPLE_CANNON, x = 3104, y = 610, angle = -135})
-- table.insert(object_cannons, {loop_delay = 2, loop_delay_offset = 0, type = OBJECT_TYPE_ARROW, x = 3765, y = 740, angle = -45, vx = 25, vy = -20})
-- table.insert(object_cannons, {loop_delay = 2, loop_delay_offset = 1, type = OBJECT_TYPE_ARROW, x = 3905, y = 629, angle = -135, vx = -25, vy = -20})
-- table.insert(object_cannons, {loop_delay = 2, loop_delay_offset = 0, type = OBJECT_TYPE_ARROW, x = 3709, y = 485, angle = -45, vx = 25, vy = -20})
-- Those can also be added in mapbd's maps in the `cannons` table.



--- Internal Use:
local loop_index = 0



function eventLoop()
	-- loop index
	loop_index = loop_index + 1
	-- Object cannons
	for i_cannon, cannon in ipairs(object_cannons) do
		-- shoot a new projectile if appropriate
		if loop_index % cannon.loop_delay == cannon.loop_delay_offset then
			-- delete the last shot projectile
			if cannon.pending_object_delete_id then
				tfm.exec.removeObject(cannon.pending_object_delete_id)
				cannon.pending_object_delete_id = nil
			end
			cannon.pending_object_delete_id = tfm.exec.addShamanObject(cannon.type, cannon.x, cannon.y, cannon.angle, cannon.vx, cannon.vy)
		end
	end
end



function eventNewGame()
	for i_cannon, cannon in ipairs(object_cannons) do
		cannon.pending_object_delete_id = nil
	end
	object_cannons = {}
	if type(pshy.newgame_current_map) == "table" then
		object_cannons = pshy.newgame_current_map.cannons
	end
end
