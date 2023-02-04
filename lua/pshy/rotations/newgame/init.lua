--- pshy.rotations.newgame
--
-- Override and replace `tfm.exec.newGame`.
-- Adds custom map features.
-- Calls `eventGameEnded` just before a map change.
--
-- Listed map and rotation tables can have the following fields:
--	- begin_func: Function to run when the map started.
--	- end_func: Function to run when the map stopped.
--	- replace_func: Function to run on the map's xml (or name if not present) that is supposed to return the final xml.
--	- autoskip: If true, the map will change at the end of the timer.
--	- duration: Duration of the map.
--	- shamans: Count of shamans (Currently, only 0 is supported to disable the shaman).
--	- xml (maps only): The true map's xml code.
--	- hidden (rotations only): Do not show the rotation is being used to players.
--	- modules: list of module names to enable while the map is playing (to trigger events).
--	- troll: bool telling if the rotation itself is a troll (may help other modules about how to handle the rotation).
--	- unique_items: bool telling if the items are supposed to be unique (duplicates are removed on eventInit).
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script)
--
-- @TODO: replace pshy namespace function by locals when appropriate
-- @TODO: override disableAutoNewGame() and override its behavior (in pshy_newgame_ext)
-- @TODO: spawn the shamans from `mapinfo.mapinfo.shaman_spawns` (in pshy_newgame_ext)
-- @TODO: move bonus spawning to ext ?
-- @TODO: check what feature do utility support
local command_list = pshy.require("pshy.commands.list")
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")
pshy.require("pshy.utils.print")
local Rotation = pshy.require("pshy.utils.rotation")
pshy.require("pshy.moduleswitch")
local utils_tables = pshy.require("pshy.utils.tables")
local utils_tfm = pshy.require("pshy.utils.tfm")
local maps = pshy.require("pshy.maps.list")
local rotations = pshy.require("pshy.rotations.list")
pshy.require("pshy.rotations.list.transformice")
local mapinfo = pshy.require("pshy.rotations.mapinfo", false)
local perms = pshy.require("pshy.perms")
local room = pshy.require("pshy.room")
local newgame_settings_override = pshy.require("pshy.rotations.newgame.settings_override")



--- Namespace.
local newgame = {}



--- Module Help Page:
help_pages["pshy_newgame"] = {back = "pshy", title = "Rotations", text = "Replaces tfm.exec.newGame, adding features.\n", commands = {}}
help_pages["pshy"].subpages["pshy_newgame"] = help_pages["pshy_newgame"]



--- Module Settings:
newgame.default = "default"			-- default rotation, can be a rotation of rotations
rotations["default"]					= Rotation:New({hidden = true, items = {"transformice"}})	-- default rotation, can only use other rotations, no maps
newgame.default_rotation 				= rotations["default"]
newgame.delay_next_map					= false
newgame.error_map						= "error_map"
newgame.update_map_name_on_new_player	= true



--- Internal Use:
local autorespawn = false
local respawning_players = {}



-- Old
newgame.event_new_game_triggered	= false
local newgame_called				= false
local players_alive_changed			= false
local newgame_time					= os.time() - 3001
local newgame_too_early_notified	= false
local newgame_last_call_arg			= nil
local current_map_input				= nil
local previous_map_input			= nil
local player_recently_joined		= false



-- Relevent to map being loaded
newgame.loading_map_identifying_name	= nil		-- Identifier of the map being loaded. `nil` if loading a xml or category.
newgame.loading_map_numeric_code		= nil		-- Code of the map being loaded. `nil` if not numeric.
newgame.loading_rotations				= {}
local loading_rotation_names 			= {}		-- Set of rotation names loading, used to prevent rotation recursion.
newgame.loading_map						= nil
newgame.loading_map_settings			= {}		-- All properties recovered from rotations and the map table.



-- Relevent to current map
newgame.current_map_identifying_name	= tfm.get.room.currentMap
newgame.current_map_numeric_code		= nil
newgame.current_rotations				= {}
newgame.current_map						= nil
newgame.current_map_settings			= {}
local current_map_display_name			= nil		-- How is the map name supposed to be displayed.
local current_map_modules				= nil



-- Relevent to next map
local next_map_input = nil							-- Next map to play.
local force_next_map_input = false					-- Should next map be enforced even if a different map is inputted.



local function DisableEnabledModules()
	if current_map_modules then
		for i, module_name in ipairs(current_map_modules) do 
			pshy.DisableModule(module_name)
		end
		current_map_modules = nil
	end
end



local function EnableLoadingMapModules()
	DisableEnabledModules()
	if newgame.loading_map_settings.modules then
		for i, module_name in ipairs(newgame.loading_map_settings.modules) do 
			pshy.EnableModule(module_name)
		end
		current_map_modules = newgame.loading_map_settings.modules
	end
end



--- Finally calls `tfm.exec.newGame`.
-- The purpose is only to know when the original have been called.
-- This will also prevent from loading a map if another is being loaded already.
-- This is an override for local use, the override for other modules is different.
local tfm_exec_newGame = tfm.exec.newGame
local FinallyNewGame = function(mapcode, ...)
	EnableLoadingMapModules()
	if newgame_called then
		print_warn("newgame: tfm.exec.newGame was called while the game was already loading a new map.")
		--return
	end
	if type(mapcode) == "string" and string.find(mapcode, "<", 1, true) ~= 1 and string.find(mapcode, "#", 1, true) ~= 1 and string.find(mapcode, "@", 1, true) ~= 1 and not tonumber(mapcode) then
		print_warn("newgame: invalid rotation `%s`", mapcode)
		return
	end
	if os.time() - newgame_time < 3001 then
		if not newgame_too_early_notified then
			print_error("newgame: tfm.exec.newGame called < 3000ms since last call (single warn).")
			newgame_too_early_notified = true
		end
		return
	else
		newgame_too_early_notified = false
	end
	newgame_time = os.time()
	newgame_called = true
	newgame_last_call_arg = mapcode
	--print_debug("pshy_newgame: tfm.exec.newGame(%s)", tostring(mapcode))
	newgame.loading_map_settings.map_code = mapcode
	return tfm_exec_newGame(mapcode, ...)
end



local function CallBeginFuncs()
	for i_rot, rot in ipairs(newgame.current_rotations) do
		if rot.begin_func then
			rot.begin_func(newgame.current_map_identifying_name)
		end
	end
	if newgame.current_map and newgame.current_map.begin_func then
		rot.begin_func(newgame.current_map_identifying_name)
	end
end



local function CallEndFuncs()
	if newgame.current_map and newgame.current_map.end_func then
		rot.end_func(newgame.current_map_identifying_name)
	end
	for i_rot, rot in ipairs(newgame.current_rotations) do
		if rot.end_func then
			rot.end_func(newgame.current_map_identifying_name)
		end
	end
end



--- End the previous map.
local function EndMap()
	CallEndFuncs()
	if eventGameEnded then
		eventGameEnded()
	end
	newgame_settings_override.OriginalTFMDisableAutoShaman(not newgame_settings_override.auto_shaman)
	DisableEnabledModules()
end



local function ResetLoading()
	newgame_settings_override.OriginalTFMDisableAutoShaman(not newgame_settings_override.auto_shaman)
	loading_rotation_names = {}
	newgame.loading_rotations = {}
	newgame.loading_map = nil
	newgame.loading_map_identifying_name = nil
	newgame.loading_map_numeric_name = nil
	newgame.loading_map_settings = {}
end



local function AbortLoading()
	ResetLoading()
end



--- TFM.exec.newGame override.
-- This is the main override.
-- @private
-- @param mapcode Either a map code or a map rotation code.
tfm.exec.newGame = function(mapcode, ...)
	if os.time() <= newgame_time + 3000 then
		print_error("You must wait 3000 ms before calling `tfm.exec.newGame`.")
		return
	end
	EndMap()
	newgame.event_new_game_triggered = false
	return newgame._Next(mapcode, ...)
end



local function SkipFromRotations(mapcode)
	for i, rotation_name in ipairs(newgame.default_rotation.items) do
		local rotation = rotations[rotation_name]
		if rotation then
			rotation:SkipItem(mapcode)
		end
	end
end



--- Add custom settings to the next map.
-- Some maps or map rotations have special settings.
-- This function handle both of them
local function AddCustomMapSettings(t)
	-- Override settings
	for p, v in pairs(t) do
		if type(v) == "table" then
			newgame.loading_map_settings[p] = newgame.loading_map_settings[p] or {}
			if type(newgame.loading_map_settings[p]) == "table" then
				for i_vv, vv in ipairs(v) do
					table.insert(newgame.loading_map_settings[p], vv)
				end
			end
		else
			newgame.loading_map_settings[p] = v
		end
	end
	-- Special cases
	if t.shamans ~= nil then
		assert(t.shamans == 0, "only a shaman count of 0 or nil is supported yet")
		newgame_settings_override.OriginalTFMDisableAutoShaman(true)
	end
end



--- newgame.newGame but only for rotations listed to this module.
-- @private
local function LoadDBRotation(rotation_name, rotation)
	if rotation.items == nil then
		print_error("Empty rotation!")
		AbortLoading()
		return tfm.exec.newGame(newgame.error_map)
	end
	rotation_name = rotation.name or rotation_name -- resolving aliases
	if loading_rotation_names[rotation_name] then
		print_error("Cyclic map rotation (%s)!", rotation_name)
		AbortLoading()
		return tfm.exec.newGame(newgame.error_map)
	end
	loading_rotation_names[rotation_name] = true
	table.insert(newgame.loading_rotations, rotation)
	AddCustomMapSettings(rotation)
	local next_map_name = rotation:Next()
	return newgame._Next(next_map_name)
end



--- newgame.newGame but only for maps listed to this module.
-- @private
local function LoadDBMap(map_name, map)
	newgame.loading_map_numeric_code = map_name
	newgame.loading_map = map
	AddCustomMapSettings(map)
	local map_xml
	if map.xml then
		map_xml = map.xml
		tfm.get.room.xmlMapInfo = {}
		tfm.get.room.xmlMapInfo.author = map.author
	else
		map_xml = map_name
	end
	if newgame.loading_map_settings.replace_func then
		local rst
		rst, map_xml = pcall(newgame.loading_map_settings.replace_func, map_xml)
		if not rst then
			print_error(map_xml)
			AbortLoading()
			return tfm.exec.newGame(newgame.error_map)
		end
	end
	return FinallyNewGame(map_xml)
end



local function NextCategoryMapCode(category)
	newgame.loading_map_identifying_name = nil
	newgame.loading_map_numeric_code = nil
	FinallyNewGame(category)
end



local function LoadXMLMapCode(xml)
	newgame.loading_map_identifying_name = nil
	newgame.loading_map_numeric_code = nil
	FinallyNewGame(xml)
end



local function LoadAtMapCode(at_map_code)
	newgame.loading_map_numeric_code = tonumber(string.sub(at_map_code, 2))
	FinallyNewGame(at_map_code)
end



local function LoadNumericMapCode(numeric_map_code)
	if numeric_map_code >= 1000 then
		newgame.loading_map_identifying_name = string.format("@%d", numeric_map_code)
	end
	FinallyNewGame(numeric_map_code)
end



--- Setup the next map (possibly a rotation), calling newGame.
-- @private
function newgame._Next(mapcode)
	-- Choose next map
	if mapcode == nil or force_next_map_input then
		if next_map_input then
			mapcode = next_map_input
			if type(mapcode) == "string" and #mapcode < 64 then
				SkipFromRotations(mapcode)
			end
		else
			mapcode = newgame.default
		end
	end
	force_next_map_input = false
	next_map_input = nil
	-- Call appropriate function from type
	if string.sub(mapcode, 1, 1) == "<" then
		return LoadXMLMapCode(mapcode)
	end
	newgame.loading_map_numeric_code = mapcode
	newgame.loading_map_identifying_name = mapcode
	local db_map = maps[mapcode]
	if db_map then
		return LoadDBMap(mapcode, db_map)
	end
	local db_rotation = pshy.mapdb_GetRotation(mapcode)
	if db_rotation then
		return LoadDBRotation(mapcode, db_rotation)
	end
	if string.sub(mapcode, 1, 1) == "@" then
		return LoadAtMapCode(mapcode)
	end
	if string.sub(mapcode, 1, 1) == "#" then
		return NextCategoryMapCode(mapcode)
	end
	local mapcode_number = tonumber(mapcode)
	if mapcode_number then
		return LoadNumericMapCode(mapcode_number)
	end
	print_error("Invalid Map!")
	AbortLoading()
	return tfm.exec.newGame(newgame.error_map)
end



--- Refresh the map's title.
-- You may override this function.
function newgame.RefreshMapName()
	current_map_display_name = nil
	local author = newgame.current_map_settings.author or (mapinfo and mapinfo.mapinfo and mapinfo.mapinfo.author)
	local title = newgame.current_map_settings.title or (mapinfo and mapinfo.mapinfo and mapinfo.mapinfo.title) or newgame.current_map_settings.map_name or newgame.current_map_identifying_name
	if author or title then
		local full_map_name = ""
		local title_color = newgame.current_map_settings.title_color or (mapinfo and mapinfo.mapinfo and mapinfo.mapinfo.title_color)
		if author then
			full_map_name = full_map_name .. author
		end
		title = title or newgame.current_map_settings.map_name
		if mapinfo and mapinfo.mapinfo and not title then
			title = mapinfo.mapinfo.current_map
		end
		if title then
			if author then
				full_map_name = full_map_name .. "<bl> - "
			end
			if title_color then
				full_map_name = full_map_name .. string.format('<font color="%s">', title_color)
			end
			full_map_name = full_map_name .. title
			if title_color then
				full_map_name = full_map_name .. "</font>"
			end
		end
		current_map_display_name = full_map_name
		ui.setMapName(current_map_display_name)
	end
end



--- Set the next map.
-- This map will be used on the next call to tfm.exec.newGame().
-- @param code Map code.
-- @param force Should the map be forced (even if another map is chosen).
function newgame.SetNextMap(code, force)
	next_map_input = code
	force_next_map_input = force or false
end



function newgame.SetRotation(rotname)
	if not pshy.mapdb_GetRotation(rotname) then
		return false, string.format("Rotation %s does not exist!", rotname)
	end
	newgame.default_rotation.items = {}
	if rotname then
		table.insert(newgame.default_rotation.items, rotname)
		return true, string.format("Disabled all rotations and enabled %s.", rotname)
	end
	return true, "Disabled all rotations."
end



--- TFM event eventNewGame.
function eventNewGame()
	respawning_players = {}
	local loaded_map_input = newgame.loading_map_identifying_name or tfm.get.room.currentMap
	if (loaded_map_input ~= current_map_input) then
		previous_map_input = current_map_input
		current_map_input = loaded_map_input
	end
	newgame.loading_map_numeric_code = nil
	newgame_called = false
	-- Move loading map variables to current map variables
	newgame.current_rotations = newgame.loading_rotations
	newgame.current_map = newgame.loading_map
	newgame.current_map_identifying_name = newgame.loading_map_identifying_name or tfm.get.room.currentMap
	newgame.current_map_numeric_code = newgame.loading_map_numeric_code
	newgame.current_map_settings = newgame.loading_map_settings
	ResetLoading()
	-- clean tfm.get.room.xmlMapInfo because TFM doesnt
	local current_map = tostring(tfm.get.room.currentMap)
	if string.sub(current_map, 1, 1) == "@" then
		current_map = string.sub(current_map, 2)
	end
	current_map = tonumber(current_map)
	if tfm.get.room.xmlMapInfo and current_map ~= tfm.get.room.xmlMapInfo.mapCode then
		tfm.get.room.xmlMapInfo = nil
	end
	local trusted = (not tfm.get.room.xmlMapInfo) or (tfm.get.room.xmlMapInfo.permCode ~= 22) or perms.IsTrustedMapper(tfm.get.room.xmlMapInfo.author)
	if tfm.get.room.xmlMapInfo and room.is_funcorp and not trusted then
		print_warn("Loaded non-trusted map @%d from %s.", current_map, tfm.get.room.xmlMapInfo.author or "?")
	end
	if not newgame.event_new_game_triggered then
		CallBeginFuncs()
		if newgame.current_map_settings.duration then
			tfm.exec.setGameTime(newgame.current_map_settings.duration + 3, true)
		end
		if newgame.current_map_settings.background_color then
			ui.setBackgroundColor(newgame.current_map_settings.background_color)
		end
		-- @TODO: move this to a mapext ? check the image is not already displayed (because supported images)
		if mapinfo and mapinfo.mapinfo and mapinfo.mapinfo.background_images and mapinfo.mapinfo.foreground_images then
			if trusted then
				for i_img, img in ipairs(mapinfo.mapinfo.background_images) do
					tfm.exec.addImage(img.image, "?0", img.x, img.y)
				end
				for i_img, img in ipairs(mapinfo.mapinfo.foreground_images) do
					tfm.exec.addImage(img.image, "!0", img.x, img.y)
				end
			end
		end
		newgame.RefreshMapName()
	else
		-- tfm loaded a new map
		print_error("TFM bypassed the newGame override, did you use `/np %s`?", tostring(tfm.get.room.currentMap))
		EndMap()
		if newgame.current_map_settings.map then
			newgame_settings_override.OriginalTFMDisableAutoShaman(false)
		end
	end
	newgame.event_new_game_triggered = true
	players_alive_changed = false
end



--- TFM event eventLoop.
-- Skip the map when the timer is 0.
function eventLoop(time, time_remaining)
	if newgame_called then
		--print_warn("eventLoop called between newGame() and eventNewGame()")
		--return
	end
	if time_remaining <= 400 and time > 3000 then
		if (newgame.current_map_settings.autoskip ~= false and newgame_settings_override.auto_new_game) or newgame.current_map_settings.autoskip then
			--print_debug("changing map because time is low")
			tfm.exec.setGameTime(4, true)
			tfm.exec.newGame(nil)
		end
	end
	for player_name in pairs(respawning_players) do
		tfm.exec.respawnPlayer(player_name)
	end
	respawning_players = {}
	if newgame_called then
		return
	end
	if players_alive_changed then
		if not autorespawn then
			local players_alive = utils_tfm.CountPlayersAlive()
			if players_alive == 0 then
				if (newgame.current_map_settings.autoskip ~= false and newgame_settings_override.auto_new_game) or newgame.current_map_settings.autoskip then
					tfm.exec.setGameTime(5, false)
					if not newgame.delay_next_map then
						--print_debug("changing map because no player remaining, autoskip == %s", tostring(newgame.current_map_settings.autoskip))
						tfm.exec.setGameTime(4, true)
						tfm.exec.newGame(nil)
					end
				end
			elseif players_alive < 3 and newgame_settings_override.auto_time_left then
				tfm.exec.setGameTime(20, false)
			end
		end
		players_alive_changed = false
	end
	if player_recently_joined then
		if newgame.update_map_name_on_new_player then
			if newgame.current_map_settings.background_color then
				ui.setBackgroundColor(newgame.current_map_settings.background_color)
			end
			if current_map_display_name then
				ui.setMapName(current_map_display_name)
			end
		end
		player_recently_joined = false
	end
end



function eventNewPlayer(player_name)
	player_recently_joined = true
	if newgame.update_map_name_on_new_player then
		if mapinfo and mapinfo.mapinfo and mapinfo.mapinfo.background_images and mapinfo.mapinfo.foreground_images then
			for i_img, img in ipairs(mapinfo.mapinfo.background_images) do
				tfm.exec.addImage(img.image, "?0", img.x, img.y, player_name)
			end
			for i_img, img in ipairs(mapinfo.mapinfo.foreground_images) do
				tfm.exec.addImage(img.image, "!0", img.x, img.y, player_name)
			end
		end
	end
end



function eventPlayerDied(player_name)
	tfm.get.room.playerList[player_name].isDead = true
	if autorespawn then
		respawning_players[player_name] = true
		return
	else
		players_alive_changed = true
	end
end



function eventPlayerWon(player_name)
	tfm.get.room.playerList[player_name].isDead = true
	if autorespawn then
		respawning_players[player_name] = true
		return
	else
		players_alive_changed = true
	end
end



function eventInit()
	current_map_input = tfm.get.room.currentMap
end



--- !next [map]
local function ChatCommandNext(user, code, force)
	newgame.SetNextMap(code, force)
	return true, string.format("The next map or rotation will be %s.", code)
end
command_list["next"] = {aliases = {"np", "npp"}, perms = "admins", func = ChatCommandNext, desc = "set the next map to play (no param to cancel)", argc_min = 1, argc_max = 2, arg_types = {"string", "bool"}, arg_names = {"map code", "force"}}
help_pages["pshy_newgame"].commands["next"] = command_list["next"]



--- !previous
local function ChatCommandPrevious(user)
	return true, string.format("The previous non-xml map was %s.", tostring(previous_map_input))
end
command_list["previous"] = {perms = "everyone", func = ChatCommandPrevious, desc = "get the previous map's code", argc_min = 0, argc_max = 0}
help_pages["pshy_newgame"].commands["previous"] = command_list["previous"]



--- !skip [map]
local function ChatCommandSkip(user, code)
	next_map_input = code or next_map_input
	force_next_map_input = code ~= nil
	if not next_map_input and #newgame.default_rotation.items == 0 then
		return false, "First use !rotw to set the rotations you want to use (use !rots for a list)."
	end
	tfm.exec.setGameTime(0, false)
	tfm.exec.newGame(next_map_input)
	return true
end
command_list["skip"] = {aliases = {"map"}, perms = "admins", func = ChatCommandSkip, desc = "play a different map right now", argc_min = 0, argc_max = 1, arg_types = {"string"}, arg_names = {"map code"}}
help_pages["pshy_newgame"].commands["skip"] = command_list["skip"]



--- !back
local function ChatCommandBack(user)
	if not previous_map_input then
		return false, "No previous map."
	end
	return ChatCommandSkip(user, previous_map_input)
end
command_list["back"] = {perms = "admins", func = ChatCommandBack, desc = "go back to previous map", argc_min = 0, argc_max = 0}
help_pages["pshy_newgame"].commands["back"] = command_list["back"]



--- !repeat
local function ChatCommandRepeat(user)
	return ChatCommandSkip(user, current_map_input)
end
command_list["repeat"] = {aliases = {"r", "replay", "rt", "retry"}, perms = "admins", func = ChatCommandRepeat, desc = "repeat the last map", argc_min = 0, argc_max = 0}
help_pages["pshy_newgame"].commands["repeat"] = command_list["repeat"]



--- !nextrepeat
local function ChatCommandNextrepeat(user)
	newgame.SetNextMap(current_map_input, false)
	return true, "The current map will be replayed."
end
command_list["nextrepeat"] = {aliases = {"nr", "nrt"}, perms = "admins", func = ChatCommandNextrepeat, desc = "the next map will be the current map", argc_min = 0, argc_max = 0}
help_pages["pshy_newgame"].commands["nextrepeat"] = command_list["nextrepeat"]



--- !rotations
local function ChatCommandRotations(user)
	tfm.exec.chatMessage("Available rotations:", user)
	local keys = utils_tables.SortedKeys(rotations)
	for i_rot, rot_name in pairs(keys) do
		local rot = pshy.mapdb_GetRotation(rot_name)
		if rot ~= newgame.default_rotation then
			local count = utils_tables.CountValue(newgame.default_rotation.items, rot_name)
			local s = ((count > 0) and "<vp>" or "<fc>")
			s = s .. ((count > 0) and ("<b> ⚖ " .. tostring(count) .. "</b> \t") or "  - \t\t") .. rot_name
			s = s .. ((count > 0) and "</vp>" or "</fc>")
			s = s ..  ": " .. tostring(rot.desc) .. " (" .. #rot.items .. "#)"
			tfm.exec.chatMessage(s, user)
		end
	end
	return true
end
command_list["rotations"] = {aliases = {"rots"}, perms = "admins", func = ChatCommandRotations, desc = "list available rotations", argc_min = 0, argc_max = 0}
help_pages["pshy_newgame"].commands["rotations"] = command_list["rotations"]



--- !rotationweigth <name> <value>
local function ChatCommandRotw(user, rotname, w)
	rotname = pshy.mapdb_rotation_aliases[rotname] or rotname -- check for aliases
	if not pshy.mapdb_GetRotation(rotname) then
		return false, "Unknown rotation."
	end
	if rotname == "default" then
		return false, "It's not rotationception."
	end
	if w == nil then
		w = (utils_tables.CountValue(newgame.default_rotation.items, rotname) ~= 0) and 0 or 1
	end
	if w < 0 then
		return false, "Use 0 to disable the rotation."
	end
	if w > 100 then
		return false, "The maximum weight is 100."
	end
	utils_tables.ListRemoveValue(newgame.default_rotation.items, rotname)
	if w > 0 then
		for i = 1, w do
			table.insert(newgame.default_rotation.items, rotname)
		end
	end
	newgame.default_rotation:Reset()
	return true, "Changed a map frequency."
end
command_list["rotationweigth"] = {aliases = {"rotw"}, perms = "admins", func = ChatCommandRotw, desc = "set how often a rotation is to be played", argc_min = 1, argc_max = 2, arg_types = {"string", "number"}, arg_names = {"rotation", "amount"}}
help_pages["pshy_newgame"].commands["rotationweigth"] = command_list["rotationweigth"]



--- !rotationclean [rotation]
local function ChatCommandRotc(user, rotname)
	return newgame.SetRotation(rotname)
end
command_list["rotationclean"] = {aliases = {"rotc"}, perms = "admins", func = ChatCommandRotc, desc = "clear all rotations, and optionaly set a new one", argc_min = 0, argc_max = 1, arg_types = {"string"}, arg_names = {"new rotation"}}
help_pages["pshy_newgame"].commands["rotationclean"] = command_list["rotationclean"]
newgame.ChatCommandRotc = ChatCommandRotc -- @deprecated



--- !autorespawn <on/off>
local function ChatCommandAutorespawn(user, enabled)
	autorespawn = enabled
	if enabled then
		newgame_settings_override.OriginalTFMDisableAfkDeath(true)
	else
		newgame_settings_override.OriginalTFMDisableAfkDeath(not newgame_settings_override.afk_death)
	end
	return true, string.format("Automatic respawn is now %s.", (autorespawn and "enabled" or "disabled"))
end
command_list["autorespawn"] = {perms = "admins", func = ChatCommandAutorespawn, desc = "enable or disable automatic respawn", argc_min = 0, argc_max = 1, arg_types = {"boolean"}, arg_names = {"on/off"}}
help_pages["pshy_newgame"].commands["autorespawn"] = command_list["autorespawn"]



return newgame
