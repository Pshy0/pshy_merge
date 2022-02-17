--- pshy_newgame.lua
--
-- Override and replace `tfm.exec.newGame`.
-- Adds custom map features.
-- Calls `eventGameEnded` just before a map change.
--
-- Listed map and rotation tables can have the folowing fields:
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
-- @require pshy_bonuses.lua
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_mapdb.lua
-- @optional_require pshy_mapinfo.lua
-- @require pshy_print.lua
-- @require pshy_rotation.lua
-- @require pshy_utils_tables.lua
-- @require pshy_utils_tfm.lua
--
-- @require_priority WRAPPER
--
-- @TODO: replace pshy namespace function by locals when appropriate
-- @TODO: override disableAutoNewGame() and override its behavior (in pshy_newgame_ext)
-- @TODO: spawn the shamans from `pshy.mapinfo.shaman_spawns` (in pshy_newgame_ext)
-- @TODO: move bonus spawning to ext ?
-- @TODO: check what feature do utility support


--- Module Help Page:
pshy.help_pages["pshy_newgame"] = {back = "pshy", title = "pshy_newgame", text = "Replaces tfm.exec.newGame, adding features.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_newgame"] = pshy.help_pages["pshy_newgame"]



--- Module Settings:
pshy.newgame_default = "default"			-- default rotation, can be a rotation of rotations
pshy.mapdb_rotations["default"]				= {hidden = true, items = {"transformice"}}		-- default rotation, can only use other rotations, no maps
pshy.newgame_default_rotation 				= pshy.mapdb_rotations["default"]				--
pshy.newgame_delay_next_map					= false
pshy.newgame_error_map						= "error_map"



--- Settings for tfm overriden features:
local simulated_tfm_auto_new_game = true
local simulated_tfm_auto_shaman = true



--- Internal Use:
pshy.newgame_current_settings = {}
pshy.newgame_current_settings.shamans = nil
pshy.newgame_current_settings.map_name = nil
pshy.newgame_current_settings.map = nil
pshy.newgame_current_settings.autoskip = true
pshy.newgame_current_settings.duration = 60
pshy.newgame_current_settings.begin_funcs = {}
pshy.newgame_current_settings.end_funcs = {}
pshy.newgame_current_settings.replace_func = nil
pshy.newgame_current_settings.modules = {}			-- list of module names enabled for the map that needs to be disabled
pshy.newgame_current_settings.background_color = nil
pshy.newgame_current_settings.title = nil
pshy.newgame_current_settings.title_color = nil
pshy.newgame_current_settings.author = nil
pshy.newgame_event_new_game_triggered = false
pshy.newgame_next = nil
pshy.newgame_force_next = false
pshy.newgame_current_rotations_names = {}		-- set rotation names we went by when choosing the map
local newgame_called				= false
local players_alive_changed			= false



--- Local override of `tfm.exec.newGame`.
-- The purpose is only to know when the original have been called.
-- This will also prevent from loading a map if another is being loaded already.
-- This is an override for local use, the override for other modules is different.
local jshcjwsbwjc = tfm.exec.newGame
tfm.exec.newGame = function(mapcode, ...)
	if newgame_called then
		print_warn("pshy_newgame: tfm.exec.newGame was called while the game was already loading a new map.")
		--return
	end
	newgame_called = true
	--print_debug("pshy_newgame: tfm.exec.newGame(%s)", tostring(mapcode))
	return jshcjwsbwjc(mapcode, ...)
end



--- Override for `tfm.exec.disableAutoNewGame()`.
local function override_tfm_exec_disableAutoNewGame(disable)
	--print_debug("override_tfm_exec_disableAutoNewGame(%s)", tostring(disable))
	if disable == nil then
		disable = true
	end
	simulated_tfm_auto_new_game = not disable
end
tfm.exec.disableAutoNewGame(true)
tfm.exec.disableAutoNewGame = override_tfm_exec_disableAutoNewGame



--- Override for `tfm.exec.disableAutoShaman()`.
local function override_tfm_exec_disableAutoShaman(disable)
	--print_debug("override_tfm_exec_disableAutoShaman(%s)", tostring(disable))
	if disable == nil then
		disable = true
	end
	simulated_tfm_auto_shaman = not disable
end
tfm.exec.disableAutoShaman(false)
local OriginalTFMDisableAutoShaman = tfm.exec.disableAutoShaman
tfm.exec.disableAutoShaman = override_tfm_exec_disableAutoShaman



--- Set the next map.
-- This map will be used on the next call to tfm.exec.newGame().
-- @param code Map code.
-- @param force Should the map be forced (even if another map is chosen).
function pshy.newgame_SetNextMap(code, force)
	pshy.newgame_next = code
	pshy.newgame_force_next = force or false
end



--- End the previous map.
-- @private
-- @param aborted true if the map have not even been started.
local function EndMap(aborted)
	if not aborted then
		for i_func, end_func in ipairs(pshy.newgame_current_settings.end_funcs) do
			end_func(pshy.newgame_current_settings.map_name)
		end
		if eventGameEnded then
			eventGameEnded()
		end
	end
	pshy.newgame_current_settings.shamans = nil
	OriginalTFMDisableAutoShaman(not simulated_tfm_auto_shaman)
	pshy.newgame_current_settings.map_name = nil
	pshy.newgame_current_settings.map = nil
	pshy.newgame_current_settings.autoskip = nil
	pshy.newgame_current_settings.duration = nil
	pshy.newgame_current_settings.begin_funcs = {}
	pshy.newgame_current_settings.end_funcs = {}
	pshy.newgame_current_settings.replace_func = nil
	pshy.newgame_current_settings.background_color = nil
	pshy.newgame_current_settings.title = nil
	pshy.newgame_current_settings.title_color = nil
	pshy.newgame_current_settings.author = nil
	pshy.newgame_current_rotations_names = {}
	pshy.merge_DisableModules(pshy.newgame_current_settings.modules)
	pshy.newgame_current_settings.modules = {}
	-- On every new game:
	--for player_name in pairs(tfm.get.room.playerList) do
		--tfm.exec.changePlayerSize(player_name, 1.0)
		--tfm.exec.giveTransformations(player_name, false)
		--tfm.exec.linkMice(player_name, player_name, false) -- TODO: check player.soulmate ?
	--end
	-- clean tfm.get.room.xmlMapInfo because TFM doesnt
	tfm.get.room.xmlMapInfo = nil
end



--- TFM.exec.newGame override.
-- @private
-- @brief mapcode Either a map code or a map rotation code.
local tfm_exec_newGame = tfm.exec.newGame
tfm.exec.newGame = function(mapcode, ...)
	--print_debug("pshy.newgame_newGame(%s)", tostring(mapcode))
	EndMap()
	pshy.newgame_event_new_game_triggered = false
	return pshy.newgame_Next(mapcode)
end



--- Add custom settings to the next map.
-- Some maps or map rotations have special settings.
-- This function handle both of them
local function AddCustomMapSettings(t)
	if t.autoskip ~= nil then
		pshy.newgame_current_settings.autoskip = t.autoskip 
	end
	if t.shamans ~= nil then
		assert(t.shamans == 0, "only a shaman count of 0 or nil is supported yet")
		pshy.newgame_current_settings.shamans = t.shamans 
		OriginalTFMDisableAutoShaman(true)
	end
	if t.duration ~= nil then
		pshy.newgame_current_settings.duration = t.duration 
	end
	if t.begin_func ~= nil then
		table.insert(pshy.newgame_current_settings.begin_funcs, t.begin_func)
	end
	if t.end_func ~= nil then
		table.insert(pshy.newgame_current_settings.end_funcs, t.end_func)
	end
	if t.replace_func ~= nil then
		pshy.newgame_current_settings.replace_func = t.replace_func 
	end
	if t.background_color ~= nil then
		pshy.newgame_current_settings.background_color = t.background_color
	end
	if t.title ~= nil then
		pshy.newgame_current_settings.title = t.title 
	end
	if t.title_color ~= nil then
		pshy.newgame_current_settings.title_color = t.title_color 
	end
	if t.author ~= nil then
		pshy.newgame_current_settings.author = t.author 
	end
	if t.modules then
		for i, module_name in pairs(t.modules) do
			table.insert(pshy.newgame_current_settings.modules, module_name)
		end
	end
end



--- pshy.newgame_newGame but only for maps listed to this module.
-- @private
local function NextDBMap(map_name)
	local map = pshy.mapdb_maps[map_name]
	AddCustomMapSettings(map)
	pshy.newgame_current_settings.map_name = map_name
	pshy.newgame_current_settings.map = map
	ui.setBackgroundColor("#010101") -- @TODO: make this a map setting
	local map_xml
	if map.xml then
		map_xml = map.xml
		tfm.get.room.xmlMapInfo = {}
		if string.sub(map.xml, 1, 1) == "<" then
			tfm.get.room.xmlMapInfo.xml = map.xml
		end
		tfm.get.room.xmlMapInfo.author = map.author
	else
		map_xml = map_name
	end
	if pshy.newgame_current_settings.replace_func then
		map_xml = pshy.newgame_current_settings.replace_func(map.xml)
	end
	pshy.merge_EnableModules(pshy.newgame_current_settings.modules)
	return tfm_exec_newGame(map_xml)
end



--- pshy.newgame_newGame but only for rotations listed to this module.
-- @private
local function NextDBRotation(rotation_name)
	if rotation_name == "default" and #pshy.newgame_default_rotation.items == nil then
		-- empty rotation, just not changing map
		return nil
	end
	if pshy.newgame_current_rotations_names[rotation_name] then
		print_warn("Cyclic map rotation (%s)! Running newGame(error_map)!", rotation_name)
		EndMap(true)
		return tfm_exec_newGame(pshy.newgame_error_map)
	end
	pshy.newgame_current_rotations_names[rotation_name] = true
	local rotation = pshy.mapdb_GetRotation(rotation_name)
	AddCustomMapSettings(rotation)
	pshy.newgame_current_rotation_name = rotation_name
	pshy.newgame_current_rotation = rotation
	local next_map_name = pshy.rotation_Next(rotation)
	return pshy.newgame_Next(next_map_name)
end



--- Setup the next map (possibly a rotation), calling newGame.
-- @private
function pshy.newgame_Next(mapcode)
	if mapcode == nil or pshy.newgame_force_next then
		if pshy.newgame_next then
			mapcode = pshy.newgame_next
		else
			mapcode = pshy.newgame_default
		end
	end
	pshy.newgame_force_next = false
	pshy.newgame_next = nil
	if pshy.mapdb_maps[mapcode] then
		return NextDBMap(mapcode)
	end
	local mapcode_number = tonumber(mapcode)
	if mapcode_number and pshy.mapdb_maps[mapcode_number] then
		return NextDBMap(mapcode_number)
	end
	local next_rotation = pshy.mapdb_GetRotation(mapcode)
	if next_rotation then
		return NextDBRotation(mapcode)
	end
	if tonumber(mapcode) then
		pshy.newgame_current_settings.map_name = mapcode
		pshy.merge_EnableModules(pshy.newgame_current_settings.modules)
		return tfm_exec_newGame(mapcode)
	end
	if string.sub(mapcode, 1, 1) == "<" then
		tfm.get.room.xmlMapInfo = {}
		tfm.get.room.xmlMapInfo.xml = mapcode
		return tfm_exec_newGame(mapcode)
	end
	pshy.merge_EnableModules(pshy.newgame_current_settings.modules)
	return tfm_exec_newGame(mapcode)
end



--- TFM event eventNewGame.
function eventNewGame()
	newgame_called = false
	if not pshy.newgame_event_new_game_triggered then
		if pshy.newgame_current_settings.map and pshy.newgame_current_settings.map.bonuses then
			if pshy.bonuses_SetList then
				pshy.bonuses_SetList(pshy.newgame_current_settings.map.bonuses)
			end
		end
		for i_func, begin_func in ipairs(pshy.newgame_current_settings.begin_funcs) do
			begin_func(pshy.newgame_current_settings.map_name)
		end
		if pshy.newgame_current_settings.duration then
			tfm.exec.setGameTime(pshy.newgame_current_settings.duration, true)
		end
		if pshy.newgame_current_settings.background_color then
			ui.setBackgroundColor(pshy.newgame_current_settings.background_color)
		end
		local author = pshy.newgame_current_settings.author or (pshy.mapinfo and pshy.mapinfo.author)
		local title = pshy.newgame_current_settings.title or (pshy.mapinfo and pshy.mapinfo.title) or pshy.newgame_current_settings.map_name
		if author or title then
			local full_map_name = ""
			local title_color = pshy.newgame_current_settings.title_color or (pshy.mapinfo and pshy.mapinfo.title_color)
			if author then
				full_map_name = full_map_name .. author
			end
			title = title or pshy.newgame_current_settings.map_name
			if pshy.mapinfo and not title then
				title = pshy.mapinfo.current_map
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
			ui.setMapName(full_map_name)
		end
	else
		-- tfm loaded a new map
		print_warn("TFM loaded a new game despite the override")
		EndMap()
		if pshy.newgame_current_settings.map then
			OriginalTFMDisableAutoShaman(false)
		end
	end
	pshy.newgame_event_new_game_triggered = true
	players_alive_changed = false
end



--- TFM event eventLoop.
-- Skip the map when the timer is 0.
function eventLoop(time, time_remaining)
	if newgame_called then
		print_warn("eventLoop called between newGame() and eventNewGame()")
		--return
	end
	if time_remaining <= 400 and time > 3000 then
		if (pshy.newgame_current_settings.autoskip ~= false and simulated_tfm_auto_new_game) or pshy.newgame_current_settings.autoskip then
			--print_debug("changing map because time is low")
			tfm.exec.newGame(nil)
		end
	end
	if newgame_called then
		return
	end
	if players_alive_changed then
		local players_alive = pshy.CountPlayersAlive()
		if players_alive == 0 then
			if (pshy.newgame_current_settings.autoskip ~= false and simulated_tfm_auto_new_game) or pshy.newgame_current_settings.autoskip then
				tfm.exec.setGameTime(5, false)
				if not pshy.newgame_delay_next_map then
					--print_debug("changing map because hmm here...")
					tfm.exec.newGame(nil)
				end
			end
		end
	end
end



function eventNewPlayer(player_name)
	if pshy.newgame_current_settings.background_color then
		ui.setBackgroundColor(pshy.newgame_current_settings.background_color)
	end
end



--- !next [map]
local function ChatCommandNext(user, code, force)
	pshy.newgame_SetNextMap(code, force)
	return true, string.format("The next map or rotation will be %s.", code)
end
pshy.commands["next"] = {func = ChatCommandNext, desc = "set the next map to play (no param to cancel)", argc_min = 1, argc_max = 2, arg_types = {"string", "bool"}, arg_names = {"map code", "force"}}
pshy.help_pages["pshy_newgame"].commands["next"] = pshy.commands["next"]
pshy.perms.admins["!next"] = true
pshy.commands_aliases["np"] = "next"
pshy.commands_aliases["npp"] = "next"



--- !skip [map]
local function ChatCommandSkip(user, code)
	pshy.newgame_next = code or pshy.newgame_next
	pshy.newgame_force_next = code ~= nil
	if not pshy.newgame_next and #pshy.newgame_default_rotation.items == 0 then
		return false, "First use !rotw to set the rotations you want to use (use !rots for a list)."
	end
	tfm.exec.setGameTime(0, false)
	tfm.exec.newGame(pshy.newgame_next)
	return true
end
pshy.commands["skip"] = {func = ChatCommandSkip, desc = "play a different map right now", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_newgame"].commands["skip"] = pshy.commands["skip"]
pshy.perms.admins["!skip"] = true
pshy.commands_aliases["map"] = "skip"



--- !repeat
local function ChatCommandRepeat(user)
	map = pshy.newgame_current_settings.map_name
	if not map then
		return false, "Something wrong happened."
	end
	return ChatCommandSkip(user, pshy.newgame_current_settings.map_name or pshy.mapinfo.arg1)
end
pshy.commands["repeat"] = {func = ChatCommandRepeat, desc = "repeat the last map", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_newgame"].commands["repeat"] = pshy.commands["repeat"]
pshy.perms.admins["!repeat"] = true
pshy.commands_aliases["r"] = "repeat"
pshy.commands_aliases["replay"] = "repeat"



--- !rotations
local function ChatCommandRotations(user)
	tfm.exec.chatMessage("Available rotations:", user)
	local keys = pshy.TableSortedKeys(pshy.mapdb_rotations)
	for i_rot, rot_name in pairs(keys) do
		local rot = pshy.mapdb_GetRotation(rot_name)
		if rot ~= pshy.newgame_default_rotation then
			local count = pshy.TableCountValue(pshy.newgame_default_rotation.items, rot_name)
			local s = ((count > 0) and "<vp>" or "<fc>")
			s = s .. ((count > 0) and ("<b> ⚖ " .. tostring(count) .. "</b> \t") or "  - \t\t") .. rot_name
			s = s .. ((count > 0) and "</vp>" or "</fc>")
			s = s ..  ": " .. tostring(rot.desc) .. " (" .. #rot.items .. "#)"
			tfm.exec.chatMessage(s, user)
		end
	end
	return true
end
pshy.commands["rotations"] = {func = ChatCommandRotations, desc = "list available rotations", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_newgame"].commands["rotations"] = pshy.commands["rotations"]
pshy.perms.admins["!rotations"] = true
pshy.commands_aliases["rots"] = "rotations"



--- !rotationweigth <name> <value>
local function ChatCommandRotw(user, rotname, w)
	if not pshy.mapdb_GetRotation(rotname) then
		return false, "Unknown rotation."
	end
	if rotname == "default" then
		return false, "It's not rotationception."
	end
	if w == nil then
		w = (pshy.TableCountValue(pshy.newgame_default_rotation.items, rotname) ~= 0) and 0 or 1
	end
	if w < 0 then
		return false, "Use 0 to disable the rotation."
	end
	if w > 100 then
		return false, "The maximum weight is 100."
	end
	pshy.ListRemoveValue(pshy.newgame_default_rotation.items, rotname)
	if w > 0 then
		for i = 1, w do
			table.insert(pshy.newgame_default_rotation.items, rotname)
		end
	end
	pshy.rotation_Reset(pshy.newgame_default_rotation)
	return true, "Changed a map frequency."
end
pshy.commands["rotationweigth"] = {func = ChatCommandRotw, desc = "set a rotation's frequency weight", argc_min = 1, argc_max = 2, arg_types = {"string", "number"}}
pshy.help_pages["pshy_newgame"].commands["rotationweigth"] = pshy.commands["rotationweigth"]
pshy.perms.admins["!rotationweigth"] = true
pshy.commands_aliases["rotw"] = "rotationweigth"



--- !rotationclean [rotation]
local function ChatCommandRotc(user, rotname)
	if rotname and not pshy.mapdb_GetRotation(rotname) then
		return false, string.format("Rotation %s does not exist!", rotname)
	end
	pshy.newgame_default_rotation.items = {}
	if rotname then
		table.insert(pshy.newgame_default_rotation.items, rotname)
		return true, string.format("Disabled all rotations and enabled %s.", rotname)
	end
	return true, "Disabled all rotations."
end
pshy.commands["rotationclean"] = {func = ChatCommandRotc, desc = "clear all rotations, and optionaly set a new one", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_newgame"].commands["rotationclean"] = pshy.commands["rotationclean"]
pshy.perms.admins["!rotationclean"] = true
pshy.commands_aliases["rotc"] = "rotationclean"
pshy.newgame_ChatCommandRotc = ChatCommandRotc -- @deprecated



function eventPlayerDied(player_name)
	players_alive_changed = true
	tfm.get.room.playerList[player_name].isDead = true
end



function eventPlayerWon(player_name)
	players_alive_changed = true
	tfm.get.room.playerList[player_name].isDead = true
end



function eventInit()
	for i_rot, rot in pairs(pshy.mapdb_rotations) do
		-- @TODO use a custom compare function
		--if rot.unique_items then
		--	table.sort(rot.items)
		--	pshy.SortedListRemoveDuplicates(rot.items)
		--end
	end
end
