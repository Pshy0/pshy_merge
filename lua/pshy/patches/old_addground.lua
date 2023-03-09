--- pshy.patches.old_addground
--
-- TFM version `1.748` changed the behavior of `tfm.exec.addGround`
-- by changing the speed unit.
-- This module reverts it back to the previous behavior.
--
-- @author TFM:Pshy#3752 DC:PSHY#7998



local incorrect_tfm_exec_moveObject = tfm.exec.moveObject
tfm.exec.moveObject = function(a, b, c, d, e, f, ...)
 	return incorrect_tfm_exec_moveObject(a, b, c, d, (e or 0) / 10, (f or 0) / 10, ...)
end



local incorrect_tfm_exec_addPhysicObject = tfm.exec.addPhysicObject
tfm.exec.addPhysicObject = function(id, x, y, def, ...)
	local real_speed_x, real_speed_y
	if def.xSpeed then
		real_speed_x = def.xSpeed
		def.xSpeed = def.xSpeed / 10
	end
	if def.ySpeed then
		real_speed_y = def.ySpeed
		def.ySpeed = def.ySpeed / 10
	end
 	local to_return = incorrect_tfm_exec_addPhysicObject(id, x, y, def, ...)
 	if real_speed_x then
 		def.xSpeed = real_speed_x
 	end
 	if real_speed_y then
 		def.ySpeed = real_speed_y
 	end
 	return to_return
end



local incorrect_tfm_exec_movePhysicObject = tfm.exec.movePhysicObject
tfm.exec.movePhysicObject = function(id, x, y, pos_offset, vx, vy, speed_offset, ...)
 	return incorrect_tfm_exec_movePhysicObject(id, x, y, pos_offset, (vx or 0) / 10, (vy or 0) / 10, speed_offset, ...)
end
