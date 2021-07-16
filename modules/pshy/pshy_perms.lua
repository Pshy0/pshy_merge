--- pshy_perms
--
-- This module adds permission functionalities.
--
-- Main features (also check the settings):
--	- `pshy.host`: The script launcher.
--	- `pshy.admins`: Set of admin names.
--	- `pshy.HavePerm(player_name, permission)`: Check if a player have a permission (always true for admins).
--	- `pshy.perms.everyone`: Set of permissions every player have by default.
--	- `pshy.perms.PLAYER#0000`: Set of permissions the player "PLAYER#0000" have.
--
-- Some players are automatically added as admin after the first eventNewGame or after they joined.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
pshy = pshy or {}



--- Module Settings and Public Members:
pshy.host = string.match(({pcall(nil)})[2], "^(.-)%.")	-- script loader
pshy.admins = {}										-- set of room admins
pshy.admins[pshy.host] = true							-- should the host be an admin
pshy.perms = {}											-- map of players's sets of permissions (a perm is a string, preferably with no ` ` nor `.`, prefer `-`, `/` is reserved for future use)
pshy.perms.everyone = {}								-- set of permissions for everyone
pshy.perms_auto_admin_admins = true						-- add the admins as room admin automatically
pshy.perms_auto_admin_moderators = true					-- add the moderators as room admin automatically
pshy.perms_auto_admin_funcorps = true					-- add the funcorps as room admin automatically (from a list, ask to be added in it)
pshy.funcorps = {}										-- set of funcorps who asked to be added
pshy.funcorps["Pshy#3752"] = true
pshy.perms_auto_admin_authors = true					-- add the authors of the final modulepack as admin
pshy.authors = {}										-- set of modulepack authors (add them from your module script)



--- Internal use:
pshy.perms_has_new_game_been = false



--- Check if a player have a permission.
-- @public
-- @param The name of the player.
-- @param perm The permission name.
-- @return true if the player have the required permission.
function pshy.HavePerm(player_name, perm)
	assert(type(perm) == "string", "permission must be a string")
	if pshy.admins[player_name] or pshy.perms.everyone[perm] or (pshy.perms[player_name] and pshy.perms[player_name][perm]) then
		return true
	end
	return false
end



--- Add an admin with a reason, and broadcast it to other admins.
-- @private
function pshy.AddAdmin(new_admin, reason)
	pshy.admins[new_admin] = true
	for admin, void in pairs(pshy.admins) do
		tfm.exec.chatMessage("<r>[PshyPerms]</r> " .. new_admin .. " added as a room admin" .. (reason and (" (" .. reason .. ")") or "") .. ".", admin)
	end
end



--- Give admin to a player if the settings allow it.
-- @private
function pshy.PermsAutoAddAdminCheck(player_name)
	if pshy.admins[player_name] then
		return
	elseif player_name == pshy.host then
		pshy.AddAdmin(player_name, "Room Host")
	elseif pshy.perms_auto_admin_admins and string.sub(player_name, -5) == "#0001" then
		pshy.AddAdmin(player_name, "Admin &lt;3")
	elseif pshy.perms_auto_admin_funcorps and string.sub(player_name, -5) == "#0010" then
		pshy.AddAdmin(player_name, "Moderator")
	elseif pshy.perms_auto_admin_funcorps and pshy.funcorps[player_name] then
		pshy.AddAdmin(player_name, "FunCorp")
	elseif pshy.perms_auto_admin_authors and pshy.authors[player_name] then
		pshy.AddAdmin(player_name, "Author")
	end
end



--- TFM event eventNewPlayer.
-- Automatically add moderator as room admins.
function eventNewPlayer(player_name)
	pshy.PermsAutoAddAdminCheck(player_name)
end



--- TFM event eventNewGame
-- Adding admins upon the first new game event.
function eventNewGame()
	if not pshy.perms_has_new_game_been then
		pshy.perms_has_new_game_been = true
		for player_name in pairs(tfm.get.room.playerList) do
			pshy.PermsAutoAddAdminCheck(player_name)
		end
	end
end
