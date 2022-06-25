--- pshy.commands.get_target_or_error
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



--- Get a command target player or throw on permission issue.
-- This function can be used to check if a player can run a command on another one.
local function GetTargetOrError(user, target, perm_prefix)
	if not target then
		return user
	end
	if target == user then
		return user
	elseif not perms.HavePerm(user, perm_prefix .. "-others") then
		error("You do not have permission to use this command on others.")
		return
	end
	return target
end



return GetTargetOrError
