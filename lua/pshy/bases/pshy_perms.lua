--- pshy_perms.lua
--
-- This module adds permission functionalities.
--
-- Main features (also check the settings):
--	- `pshy.loader`: The script launcher.
--	- `pshy.admins`: Set of admin names (use `pshy.authors` to add permanent admins).
--	- `pshy.HavePerm(player_name, permission)`: Check if a player have a permission (always true for admins).
--	- `pshy.perms.everyone`: Set of permissions every player have by default.
--	- `pshy.perms.PLAYER#0000`: Set of permissions the player "PLAYER#0000" have.
--
-- Some players are automatically added as admin after the first eventNewGame or after they joined.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require_priority UTILS
pshy = pshy or {}



--- Module Settings and Public Members:
pshy.loader = string.match(({pcall(nil)})[2], "^(.-)%.")		-- script loader
pshy.admins = {}												-- set of room admins
pshy.admins[pshy.loader] = true									-- should the loader be an admin
pshy.perms = {}													-- map of players's sets of permissions (a perm is a string, preferably with no ` ` nor `.`, prefer `-`, `/` is reserved for future use)
pshy.perms.everyone = {}										-- set of permissions everyone has
pshy.perms.cheats = {}											-- set of permissions everyone has when cheats are enabled
pshy.perms.admins = {}											-- set of permissions room admins have
pshy.perms_auto_admin_admins = true								-- add the game admins as room admin automatically
pshy.perms_auto_admin_authors = true							-- add the authors of the final modulepack as admin
pshy.authors = {}												-- set of modulepack authors (add them from your module script)
pshy.authors["Pshy#3752"] = true
pshy.perms_auto_admin_funcorps = true							-- add the funcorps as room admin automatically (from a list, ask to be added in it)
pshy.funcorps = {}												-- set of funcorps who asked to be added, they can use !adminme
pshy.funcorps["Pshy#3752"] = true
pshy.perms_auto_admin_moderators = true							-- add the moderators as room admin automatically
pshy.funcorp = tfm.exec.getPlayerSync() ~= nil				-- are funcorp features available
pshy.is_tribehouse = string.byte(tfm.get.room.name, 2) == 3		-- is the room a tribehouse
pshy.public_room = string.sub(tfm.get.room.name, 1, 1) ~= "@"	-- limit admin features in public rooms
pshy.private_room = not pshy.public_room
pshy.admin_instructions = {}									-- add instructions to admins
pshy.perms_cheats_enabled = false								-- do players have the permissions in `pshy.perms.cheats`



--- Help page:
pshy.help_pages = pshy.help_pages or {}						-- touching the help_pages table
pshy.help_pages["pshy_perms"] = {title = "Permissions", text = "Player permissions are stored in sets such as `pshy.perms.Player#0000`.\n`pshy.perms.everyone` contains default permissions.\nRoom admins from the set `pshy.admins` have all permissions.\n", commands = {}}



--- Internal use:
pshy.commands = pshy.commands or {}				-- touching the commands table



--- Check if a player have a permission.
-- @public
-- @param The name of the player.
-- @param perm The permission name.
-- @return true if the player have the required permission.
function pshy.HavePerm(player_name, perm)
	assert(type(perm) == "string", "permission must be a string")
	if player_name == pshy.loader or pshy.admins[player_name] and ((not pshy.public_room) or pshy.perms.admins[perm] or pshy.perms.cheats[perm]) then
		return true
	end
	if pshy.perms.everyone[perm] or (pshy.perms_cheats_enabled and pshy.perms.cheats[perm]) or (pshy.perms[player_name] and pshy.perms[player_name][perm])then
		return true
	end
	return false
end



--- Add an admin with a reason, and broadcast it to other admins.
-- @private
-- @param new_admin The new room admin's Name#0000.
-- @param reason A message displayed as the reason for the promotion.
function pshy.perms_AddAdmin(new_admin, reason)
	pshy.admins[new_admin] = true
	for an_admin, void in pairs(pshy.admins) do
		tfm.exec.chatMessage("<r>[PshyPerms]</r> " .. new_admin .. " added as a room admin" .. (reason and (" (" .. reason .. ")") or "") .. ".", an_admin)
	end
end



--- Check if a player could me set as admin automatically.
-- @param player_name The player's Name#0000.
-- @return true/false (can become admin), reason
-- @private
function pshy.perms_CanAutoAdmin(player_name)
	if pshy.admins[player_name] then
		return false, "Already Admin"
	elseif player_name == pshy.loader then
		return true, "Script Loader"
	elseif pshy.perms_auto_admin_admins and string.sub(player_name, -5) == "#0001" then
		return true, "Admin &lt;3"
	elseif pshy.perms_auto_admin_moderators and string.sub(player_name, -5) == "#0010" then
		return true, "Moderator"
	elseif pshy.perms_auto_admin_funcorps and pshy.funcorps[player_name] then
		return true, "FunCorp"
	elseif pshy.perms_auto_admin_authors and pshy.authors[player_name] then
		return true, "Author"
	else
		return false, "Not Allowed"
	end
end



--- Check if a player use `!adminme` and notify them if so.
-- @private
-- @param player_name The player's Name#0000.
function pshy.perms_TouchPlayer(player_name)
	local can_admin, reason = pshy.perms_CanAutoAdmin(player_name)
	if can_admin then
		tfm.exec.chatMessage("<r>[PshyPerms]</r> <j>You may set yourself as a room admin (" .. reason .. ").</j>", player_name)
		for instruction in ipairs(pshy.admin_instructions) do
			tfm.exec.chatMessage("<r>[PshyPerms]</r> <fc>" .. instruction .. "</fc>", player_name)
		end
		tfm.exec.chatMessage("<r>[PshyPerms]</r> <j>To become a room admin, use `<fc>!adminme</fc>`</j>", player_name)
		print("[PshyPerms] " .. player_name .. " can join room admins.")
	end
end



--- TFM event eventNewPlayer.
function eventNewPlayer(player_name)
	pshy.perms_TouchPlayer(player_name)
end



--- !admin <NewAdmin#0000>
-- Add an admin in the pshy.admins set.
function pshy.perms_ChatCommandAdmin(user, new_admin_name)
	pshy.admins[new_admin_name] = true
	for admin_name, void in pairs(pshy.admins) do
		tfm.exec.chatMessage("<r>[PshyPerms]</r> " .. user .. " added " .. new_admin_name .. " as room admin.", admin_name)
	end
end
pshy.commands["admin"] = {func = pshy.perms_ChatCommandAdmin, desc = "add a room admin", argc_min = 1, argc_max = 1, arg_types = {"string"}, arg_names = {"Newadmin#0000"}}
pshy.help_pages["pshy_perms"].commands["admin"] = pshy.commands["admin"]



--- !unadmin <NewAdmin#0000>
-- Remove an admin from the pshy.admins set.
function pshy.perms_ChatCommandUnadmin(user, admin_name)
	pshy.admins[admin_name] = nil
	for admin_name, void in pairs(pshy.admins) do
		tfm.exec.chatMessage("<r>[PshyPerms]</r> " .. user .. " removed " .. admin_name .. " from room admins.", admin_name)
	end
end
pshy.commands["unadmin"] = {func = pshy.perms_ChatCommandUnadmin, desc = "remove a room admin", argc_min = 1, argc_max = 1, arg_types = {"string"}, arg_names = {"Newadmin#0000"}}
pshy.help_pages["pshy_perms"].commands["unadmin"] = pshy.commands["unadmin"]



--- !adminme
-- Add yourself as an admin if allowed by the module configuration.
function pshy.perms_ChatCommandAdminme(user)
	local allowed, reason = pshy.perms_CanAutoAdmin(user)
	if allowed then
		pshy.perms_AddAdmin(user, reason)
		return true
	else
		return false, reason
	end
end
pshy.commands["adminme"] = {func = pshy.perms_ChatCommandAdminme, desc = "join room admins if allowed", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_perms"].commands["adminme"] = pshy.commands["adminme"]
pshy.perms.everyone["!adminme"] = true



--- !admins
-- Add yourself as an admin if allowed by the module configuration.
function pshy.perms_ChatCommandAdmins(user)
	local strlist = ""
	for an_admin, is_admin in pairs(pshy.admins) do
		if is_admin then
			if #strlist > 0 then
				strlist = strlist .. ", "
			end
			strlist = strlist .. an_admin
		end
	end
	tfm.exec.chatMessage("<r>[PshyPerms]</r> Script Loader: " .. tostring(pshy.loader), user)
	tfm.exec.chatMessage("<r>[PshyPerms]</r> Room admins: " .. strlist .. ".", user)
	return true
end
pshy.commands["admins"] = {func = pshy.perms_ChatCommandAdmins, desc = "see a list of room admins", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_perms"].commands["admins"] = pshy.commands["admins"]
pshy.perms.everyone["!admins"] = true



--- !enablecheats
-- Add yourself as an admin if allowed by the module configuration.
function pshy.perms_ChatCommandEnablecheats(user, cheats_enabled)
	pshy.perms_cheats_enabled = cheats_enabled
	if cheats_enabled then
		return true, "cheat commands enabled for everyone"
	else
		return true, "cheat commands enabled for admins only"
	end
end
pshy.commands["enablecheats"] = {func = pshy.perms_ChatCommandEnablecheats, desc = "enable cheats commands for everyone", argc_min = 1, argc_max = 1, arg_types = {'boolean'}}
pshy.help_pages["pshy_perms"].commands["enablecheats"] = pshy.commands["enablecheats"]
pshy.perms.admins["!enablecheats"] = true



--- Pshy event eventInit.
function eventInit()
	for player_name in pairs(tfm.get.room.playerList) do
		pshy.perms_TouchPlayer(player_name)
	end
end
