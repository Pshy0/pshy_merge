--- pshy.perms
--
-- Handles permissions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.bases.doc")
pshy.require("pshy.events")
local room = pshy.require("pshy.room")



--- Namespace.
local perms = {}



--- Help page:
pshy.help_pages["perms_map"] = {title = "Permissions", text = "Handles permissions.\n", commands = {}}



--- Room admins.
-- Admins will have access to most of the functionalities of the scripts.
-- The module loader is automatically added as an admin.
-- Settings starting in `perms.auto_admin_*` define who can join room admins by themselves using `!adminme`.
perms.admins = {}
perms.admins[room.loader] = true
perms.auto_admin_admins = true
perms.auto_admin_moderators = true
perms.auto_admin_funcorps = true
perms.auto_admin_authors = false



--- Script authors.
-- Authors will be allowed to join room admins if `perms.auto_admin_authors` is `true`.
-- They can always join room admins in private rooms.
perms.authors = {}
perms.authors[105766424] = "Pshy#3752"



--- Funcorp map.
-- Those players can join room admins if `perms.auto_admin_funcorps` is `true`.
perms.funcorps = {}
perms.funcorps[105766424] = "Pshy#3752"



--- Permissions map.
-- This map store per-player and per-groups sets of permissions.
perms.perms = {}
perms.perms.everyone = {}			-- permissions everyone has
perms.perms.cheats = {}				-- permissions given to everyone when cheats are enabled
perms.perms.admins = {}				-- admins permissions



--- Messages shown to players who can join room admins before they do.
perms.admin_instructions = {}



--- Are permissions in `perms.perms.cheats` available to everyone.
perms.cheats_enabled = false									-- do players have the permissions in `perms.perms.cheats`



--- Internal use:
local admins = perms.admins
local perms_map = perms.perms
local perms_admins = perms.perms.admins
local perms_cheats = perms.perms.cheats
local perms_everyone = perms.perms.everyone



--- Check if a player have a permission.
-- @param The name of the player.
-- @param perm The permission name.
-- @return true if the player have the required permission.
function perms.HavePerm(player_name, perm)
	assert(type(perm) == "string", "permission must be a string")
	if perms_everyone[perm] then
		return true
	elseif perms.perms_cheats_enabled and perms_cheats[perm] then
		return true
	elseif admins[player_name] and (perms_admins[perm] or perms_cheats[perm]) then
		return true
	elseif perms_map[player_name] then
		return true
	elseif player_name == room.loader then
		return true
	end
	return false
end



--- Add an admin with a reason, and broadcast it to other admins.
-- @param new_admin The new room admin's Name#0000.
-- @param reason A message displayed as the reason for the promotion.
local function AddAdmin(new_admin, reason)
	admins[new_admin] = true
	for an_admin, void in pairs(admins) do
		tfm.exec.chatMessage("<r>[Perms]</r> " .. new_admin .. " added as a room admin" .. (reason and (" (" .. reason .. ")") or "") .. ".", an_admin)
	end
end



--- Check if a player could be set as admin automatically.
-- @param player_name The player's Name#0000.
-- @return true/false (can become admin), reason
local function CanAutoAdmin(player_name)
	local player_id = tfm.get.room.playerList[player_name].id
	if admins[player_name] then
		return false, "Already Admin"
	elseif player_name == perms.loader then
		return true, "Script Loader"
	elseif perms.perms_auto_admin_admins and string.sub(player_name, -5) == "#0001" then
		return true, "Admin &lt;3"
	elseif perms.perms_auto_admin_moderators and string.sub(player_name, -5) == "#0010" then
		return true, "Moderator"
	elseif perms.perms_auto_admin_funcorps and perms.funcorps[player_id] then
		return true, string.format("FunCorp %s", perms.funcorps[player_id])
	elseif (perms.perms_auto_admin_authors or room.is_private or room.is_tribehouse) and perms.authors[player_id] then
		return true, string.format("Author %s", perms.authors[player_id])
	else
		return false, "Not Allowed"
	end
end



--- Check if a player can use `!adminme` and notify them if so.
-- @param player_name The player's Name#0000.
local function TouchPlayer(player_name)
	local can_admin, reason = CanAutoAdmin(player_name)
	if can_admin then
		tfm.exec.chatMessage("<r>[Perms]</r> <j>You may join room admins (" .. reason .. ").</j>", player_name)
		for instruction in ipairs(perms.admin_instructions) do
			tfm.exec.chatMessage("<r>[Perms]</r> <fc>" .. instruction .. "</fc>", player_name)
		end
		tfm.exec.chatMessage("<r>[Perms]</r> <j>To become a room admin, use `<fc>!adminme</fc>`</j>", player_name)
		print(string.format("<r>[Perms]</r> Current settings are allowing %s to join room admins (%s).", player_name, reason))
	end
end



--- TFM event eventNewPlayer.
function eventNewPlayer(player_name)
	TouchPlayer(player_name)
end



--- !admin <NewAdmin#0000>
-- Add an admin in the perms.admins set.
local function ChatCommandAdmin(user, new_admin_name)
	admins[new_admin_name] = true
	AddAdmin(new_admin_name, "by " .. user)
end
pshy.commands["admin"] = {perms = "admins", func = ChatCommandAdmin, desc = "add a room admin", argc_min = 1, argc_max = 1, arg_types = {"string"}, arg_names = {"Newadmin#0000"}}
pshy.help_pages["perms_map"].commands["admin"] = pshy.commands["admin"]



--- !unadmin <OldAdmin#0000>
-- Remove an admin from the perms.admins set.
local function ChatCommandUnadmin(user, admin_name)
	admins[admin_name] = nil
	for admin_name, void in pairs(admins) do
		tfm.exec.chatMessage("<r>[Perms]</r> " .. user .. " removed " .. admin_name .. " from room admins.", admin_name)
	end
end
pshy.commands["unadmin"] = {func = ChatCommandUnadmin, desc = "remove a room admin", argc_min = 1, argc_max = 1, arg_types = {"string"}, arg_names = {"Oldadmin#0000"}}
pshy.help_pages["perms_map"].commands["unadmin"] = pshy.commands["unadmin"]



--- !adminme
-- Add yourself as an admin if allowed by the module configuration.
local function ChatCommandAdminme(user)
	local allowed, reason = CanAutoAdmin(user)
	if allowed then
		AddAdmin(user, reason)
		return true
	else
		return false, reason
	end
end
pshy.commands["adminme"] = {perms = "everyone", func = ChatCommandAdminme, desc = "join room admins if allowed", argc_min = 0, argc_max = 0}
pshy.help_pages["perms_map"].commands["adminme"] = pshy.commands["adminme"]



--- !admins
-- Add yourself as an admin if allowed by the module configuration.
local function ChatCommandAdmins(user)
	local strlist = ""
	for an_admin, is_admin in pairs(admins) do
		if is_admin then
			if #strlist > 0 then
				strlist = strlist .. ", "
			end
			strlist = strlist .. an_admin
		end
	end
	tfm.exec.chatMessage("<r>[Perms]</r> Script Loader: " .. tostring(room.loader), user)
	tfm.exec.chatMessage("<r>[Perms]</r> Room admins: " .. strlist .. ".", user)
	return true
end
pshy.commands["admins"] = {perms = "everyone", func = ChatCommandAdmins, desc = "see a list of room admins", argc_min = 0, argc_max = 0}
pshy.help_pages["perms_map"].commands["admins"] = pshy.commands["admins"]



--- !enablecheats
-- Add yourself as an admin if allowed by the module configuration.
local function ChatCommandEnablecheats(user, cheats_enabled)
	perms.perms_cheats_enabled = cheats_enabled
	if cheats_enabled then
		return true, "cheat commands enabled for everyone"
	else
		return true, "cheat commands enabled for admins only"
	end
end
pshy.commands["enablecheats"] = {perms = "admins", func = ChatCommandEnablecheats, desc = "enable cheats commands for everyone", argc_min = 1, argc_max = 1, arg_types = {'boolean'}}
pshy.help_pages["perms_map"].commands["enablecheats"] = pshy.commands["enablecheats"]



--- !setperm
-- Add yourself as an admin if allowed by the module configuration.
local function ChatCommandSetcommandperms(user, target, perm, value)
	if not perms.HavePerm(user, perm) then
		return false, "you cannot give permissions for a command you do not have permissions for"
	end
	perms_map[target] = perms_map[target] or {}
	perms_map[target][perm] = value
	local rst = string.format("permission %s %s %s by %s", perm, (value and "given to" or "removed from"), target, user)
	for an_admin, void in pairs(admins) do
		tfm.exec.chatMessage("<r>[Perms]</r> " .. rst, an_admin)
	end
	return true, rst
end
pshy.commands["setperm"] = {perms = "admins", func = ChatCommandSetcommandperms, desc = "set permissions for a command", argc_min = 3, argc_max = 3, arg_types = {'string', 'string', 'bool'}, arg_names = {"Player#0000|admins|cheats|everyone", "!command", "yes|no"}}
pshy.help_pages["perms_map"].commands["setperm"] = pshy.commands["setperm"]



--- Check if a table is equivalent in syntax to `perms.admins` and set it to `perms.admins` if so
local function SetThirdpartyAdminSet(parent_table, admin_table_name)
	local admin_table = parent_table[admin_table_name]
	if not admin_table or type(admin_table) ~= "table" then
		return false
	end
	if admin_table[1] then
		return false
	end
	local has_player_keys = false
	for key, value in pairs(admin_table) do
		if string.match(key, "#....$") and value == true then
			has_player_keys = true
		end
		break
	end
	if has_player_keys then
		parent_table[admin_table_name] = perms.admins
		return true
	end
	return false
end



--- Add the script loader as admin in a thirdparty admin list
local function InsertIntoThirdpartyAdminList(admin_table, admin)
	if admin_table[1] and type(admin_table[1]) == "string" then
		table.insert(admin_table, admin)
		return true
	end
	return false
end



--- Pshy event eventInit.
function eventInit()
	assert(admins == perms.admins)
	assert(perms_map == perms.perms)
	assert(perms_admins == perms.perms.admins)
	assert(perms_cheats == perms.perms.cheats)
	assert(perms_everyone == perms.perms.everyone)
	for player_name in pairs(tfm.get.room.playerList) do
		TouchPlayer(player_name)
	end
	if (not room.is_private and not room.is_tribehouse) and perms.perms_auto_admin_authors then
		print("<r>[Perms]</r> Current settings are allowing script authors to join as admin.")
	end
	-- Add single admin in thirdparty scripts
	if _G.admin and type(_G.admin) == "string" then
		_G.admin = room.loader
	end
	if _G.Admin and type(_G.Admin) == "string" then
		_G.Admin = room.loader
	end
	-- Merge possible existing thirdparty admin sets
	local need_add_loader_admin = false
	SetThirdpartyAdminSet(_G, "admin")
	SetThirdpartyAdminSet(_G, "admins")
	if _G.game then
		SetThirdpartyAdminSet(_G.game, "admins")
	end
	-- Add loader to thirdparty admin lists
	if _G.admins and type(_G.admins) == "table" then
		InsertIntoThirdpartyAdminList(_G.admins, room.loader)
	end
	if _G.game and _G.game.admins and type(_G.game.admins) == "table" then
		InsertIntoThirdpartyAdminList(_G.game.admins, room.loader)
	end
end



return perms
