--- pshy_perms
--
-- This module define basic permission functionalities.
--
-- This module is a dependency for my other modules.
-- It is not supposed to run alone.
--
-- @author Pshy
-- @namespace pshy
-- @module pshy_perms
--
pshy = pshy or {}



--- Script Loader Player.
-- This does not set specific permissions.
local rst, rtn = pcall(nil)
pshy.host = string.match(rtn, "^(.-)%.")



--- Admins list
-- set of admins
-- admins are always allowed to use every feature
pshy.admins = {}
pshy.admins[pshy.host] = true



--- Permissions
-- map of players -> set of permissions
-- "everyone" contains default permissions for all players
-- commands permissions starts with "commands."
pshy.perms = {}
pshy.perms.everyone = {}
--pshy.perms.everyone["!help"] = true
--pshy.perms["someuser#0000"]["commands.help"] = true



--- Permission test.
-- @public
-- @param The name of the player.
-- @param perm The permission name.
-- @return true if the player have the required permission.
function pshy.HavePerm(player_name, perm)
	assert(type(perm) == "string")
	if pshy.admins[player_name] or pshy.perms.everyone[perm] or (pshy.perms[player_name] and pshy.perms[player_name][perm]) then
		return true
	end
	return false
end



--- Add an admin with a reason, and broadcast it to other admins.
function pshy.PermsAddAdmin(new_admin, reason)
	pshy.admins[new_admin] = true
	for admin, void in pairs(pshy.admins) do
		tfm.exec.chatMessage("<r>[PshyPerms]</r> " .. new_admin .. " automatically added as a room admin" .. (reason and (" (" .. reason .. ")") or "") .. ".")
	end
end


--- Automatically add moderator as room admins.
function eventNewPlayer(player_name)
	if (string.sub(player_name, -5) == "#0010") then
		pshy.PermsAddAdmin(new_admin, "(Moderator)")
	end
	if (string.sub(player_name, -5) == "#0001") then
		pshy.PermsAddAdmin(new_admin, "(&lt;3)")
	end
end
