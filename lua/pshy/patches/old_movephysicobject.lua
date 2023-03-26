--- pshy.patches.old_movephysicobject
--
-- TFM version `1.748` changed the behavior of `tfm.exec.addPhysicObject`
-- by changing the speed unit.
-- This module reverts it back to the previous behavior.
--
-- @author TFM:Pshy#3752 DC:PSHY#7998



local incorrect_tfm_exec_movePhysicObject = tfm.exec.movePhysicObject
tfm.exec.movePhysicObject = function(id, x, y, pos_offset, vx, vy, speed_offset, ...)
	return incorrect_tfm_exec_movePhysicObject(id, x, y, pos_offset, (vx or 0) / 10, (vy or 0) / 10, speed_offset, ...)
end
