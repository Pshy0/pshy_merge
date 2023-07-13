--- pshy.perms
--
-- Handles permissions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")
local room = pshy.require("pshy.room")



--- Namespace.
local perms = {}



--- Help page:
help_pages[__MODULE_NAME__] = {title = "Permissions", text = "Handles permissions.\n"}



--- Room admins.
-- Admins will have access to most of the functionalities of the scripts.
-- The module loader is automatically added as an admin.
-- Settings starting in `perms.auto_admin_*` define who can join room admins by themselves using `!adminme`.
perms.admins = {}
perms.admins[room.loader] = 0
perms.auto_admin_admins = true
perms.auto_admin_moderators = true
perms.auto_admin_funcorps = true
perms.auto_admin_authors = false



--- Script authors.
-- Authors will be allowed to join room admins if `perms.auto_admin_authors` is `true`.
-- They can always join room admins in private rooms.
perms.authors = {}
perms.authors["Pshy#3752"] = true



--- Approved mappers.
-- Disable some warnings when playing their maps and enable some features.
perms.approved_mappers = {
	["#Module#0000"] = true;
	["Mattseba#0000"] = true;
	["Nnaaaz#0000"] = true;
}



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
local admin_add_count = 1
local admins_added = {}						-- table of list of added admins by admin
local admins = perms.admins
local authors = perms.authors
local perms_map = perms.perms
local perms_admins = perms.perms.admins
local perms_cheats = perms.perms.cheats
local perms_everyone = perms.perms.everyone
local approved_mappers = perms.approved_mappers



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



--- Check if a player's content is to be trusted.
-- @return `true` if the player's content can be trusted.
function perms.IsTrustedMapper(map_author)
	if admins[map_author] or authors[map_author] or approved_mappers[map_author] then
		return true
	end
	return false
end



function perms.IsTrustedMap()
	return (not tfm.get.room.xmlMapInfo) or (tfm.get.room.xmlMapInfo.permCode ~= 22) or perms.IsTrustedMapper(tfm.get.room.xmlMapInfo.author)
end



local function ShowAdminMOTDTo(player_name)
	for i, instruction in ipairs(perms.admin_instructions) do
		tfm.exec.chatMessage("<r>[Perms]</r> <fc>" .. instruction .. "</fc>", new_admin)
	end
	return #perms.admin_instructions > 0
end



--- Add an admin with a reason, and broadcast it to other admins.
-- @param new_admin The new room admin's Name#0000.
-- @param reason A message displayed as the reason for the promotion.
local function AddAdmin(new_admin, reason, by)
	if admins[new_admin] then
		return false, "This user is already admin!"
	end
	admins[new_admin] = admin_add_count
	admin_add_count = admin_add_count + 1
	if by then
		admins_added[by] = admins_added[by] or {}
		table.insert(admins_added[by], new_admin)
	end
	for an_admin, void in pairs(admins) do
		tfm.exec.chatMessage(string.format("<r>[Perms]</r> %s added to room admins%s.", new_admin, reason and (" (" .. reason .. ")") or ""), an_admin)
	end
	ShowAdminMOTDTo(new_admin)
	return true
end



--- Remove a room admin and all admins they added.
local function RemoveAdmin(old_admin, reason, by)
	if not admins[old_admin] then
		return false, "This user is not a room admin."
	end
	if by then
		if (admins[by] ~= true and admins[old_admin] ~= true) and (admins[old_admin] < admins[by]) then
			return false, "Cannot remove an older room admin!"
		end
	end
	admins[old_admin] = nil
	for admin_name, void in pairs(admins) do
		tfm.exec.chatMessage(string.format("<r>[Perms]</r> %s removed from room admins%s.", old_admin, reason and (" (" .. reason .. ")") or ""), an_admin)
	end
	if admins_added[old_admin] then
		for _, another_old_admin in ipairs(admins_added[old_admin]) do
			RemoveAdmin(another_old_admin, "recursive removal", by)
		end
	end
	return true
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
	elseif perms.perms_auto_admin_funcorps and tfm.get.room.playerList[player_name].isFunCorp then
		return true, "FunCorp"
	elseif (perms.perms_auto_admin_authors or room.is_private or room.is_tribehouse) and perms.authors[player_name] then
		return true, "Author"
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
		ShowAdminMOTDTo(player_name)
		tfm.exec.chatMessage("<r>[Perms]</r> <j>To become a room admin, use `<fc>!adminme</fc>`</j>", player_name)
		print(string.format("<r>[Perms]</r> Current settings are allowing %s to join room admins (%s).", player_name, reason))
	end
end



--- TFM event eventNewPlayer.
function eventNewPlayer(player_name)
	TouchPlayer(player_name)
end



__MODULE__.commands = {
	["admin"] = {
		perms = "admins",
		desc = "add a room admin",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"string"},
		arg_names = {"Newadmin#0000"},
		func = function(user, new_admin_name)
			return AddAdmin(new_admin_name, "by " .. user, user)
		end
	},
	["unadmin"] = {
		perms = "admins",
		desc = "remove a room admin",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"string"},
		arg_names = {"Oldadmin#0000"},
		func = function(user, admin_name)
			return RemoveAdmin(admin_name, "by " .. user, user)
		end
	},
	["adminme"] = {
		perms = "everyone",
		desc = "join room admins if allowed",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			local allowed, reason = CanAutoAdmin(user)
			if allowed then
				AddAdmin(user, reason)
				return true
			else
				return false, reason
			end
		end
	},
	["setadminmotd"] = {
		perms = "admins",
		desc = "message to display to new admins",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"string"},
		func = function(user, instruction)
			perms.admin_instructions = {}
			if instruction then
				perms.admin_instructions[1] = instruction
				return true, "Admin motd set to `" .. instruction .. "`"
			end
			return true, "Admin motd removed"
		end
	},
	["adminmotd"] = {
		perms = "admins",
		desc = "read the room admin motd",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			if not ShowAdminMOTDTo(new_admin) then
				return false, "No admin motd, set one with `!setadminmotd`."
			end
			return true
		end
	},
	["admins"] = {
		perms = "everyone",
		desc = "see a list of room admins",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
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
			if perms.auto_admin_authors then
				tfm.exec.chatMessage("<r>[Perms]</r> Major authors can join room admins.", user)
			end
			if perms.auto_admin_funcorps then
				tfm.exec.chatMessage("<r>[Perms]</r> Funcorps can join room admins.", user)
			end
			if perms.auto_admin_moderators then
				tfm.exec.chatMessage("<r>[Perms]</r> Moderators can join room admins.", user)
			end
			if perms.auto_admin_moderators or perms.auto_admin_funcorps or perms.auto_admin_authors then
				tfm.exec.chatMessage("<r>[Perms]</r> Disable in settings or with `!setperm everyone adminme no`.", user)
			end
			return true
		end
	},
	["authors"] = {
		perms = "everyone",
		desc = "see a list of authors",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			local strlist = ""
			for author_name, is_major in pairs(perms.authors) do
				if #strlist > 0 then
					strlist = strlist .. ", "
				end
				if is_major then
					strlist = strlist .. "<fc>" .. author_name .. "</fc>"
				else
					strlist = strlist .. author_name
				end
			end
			tfm.exec.chatMessage("<r>[Perms]</r> Authors: " .. strlist .. ".", user)
			return true
		end
	},
	["trust"] = {
		perms = "admins",
		desc = "trust a player's maps (enable advanced features)",
		argc_min = 1,
		argc_max = 1,
		arg_types = {'string'},
		arg_names = {'Player#0000'},
		func = function(user, target_player)
			approved_mappers[target_player] = true
			for admin_name, void in pairs(admins) do
				tfm.exec.chatMessage(string.format("<r>[Perms]</r> %s's content is now trusted (by %s).", target_player, user), admin_name)
			end
			return true
		end
	},
	["enablecheats"] = {
		perms = "admins",
		desc = "enable cheats commands for everyone",
		argc_min = 1,
		argc_max = 1,
		arg_types = {'boolean'},
		func = function(user, cheats_enabled)
			perms.perms_cheats_enabled = cheats_enabled
			if cheats_enabled then
				return true, "cheat commands enabled for everyone"
			else
				return true, "cheat commands enabled for admins only"
			end
		end
	},
	["setperm"] = {
		perms = "admins",
		desc = "set permissions for a command",
		argc_min = 3,
		argc_max = 3, 
		arg_types = {'string', 'string', 'bool'},
		arg_names = {"Player#0000|admins|cheats|everyone", "!command", "yes|no"},
		func = function(user, target, perm, value)
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
	}
}



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
	if perms.auto_admin_authors then
		print("<r>[Perms]</r> Authors can join room admins (`see !admins`).")
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
