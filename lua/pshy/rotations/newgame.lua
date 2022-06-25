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
-- @optional_require pshy_bonuses_mapext.lua
-- @optional_require pshy_mapinfo.lua
--
-- @TODO: replace pshy namespace function by locals when appropriate
-- @TODO: override disableAutoNewGame() and override its behavior (in pshy_newgame_ext)
-- @TODO: spawn the shamans from `mapinfo.mapinfo.shaman_spawns` (in pshy_newgame_ext)
-- @TODO: move bonus spawning to ext ?
-- @TODO: check what feature do utility support
pshy.require("pshy.bases.doc")
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")
pshy.require("pshy.utils.print")
local Rotation = pshy.require("pshy.utils.rotation")
local DisableModule = pshy.require("pshy.events.disable")
local EnableModule = pshy.require("pshy.events.enable")
local utils_tables = pshy.require("pshy.utils.tables")
local utils_tfm = pshy.require("pshy.utils.tfm")
local maps = pshy.require("pshy.maps.list")
local rotations = pshy.require("pshy.rotations.list")
pshy.require("pshy.rotations.list.transformice")
local mapinfo = pshy.require("pshy.rotations.mapinfo", true)



--- Namespace.
local newgame = {}


--- Module Help Page:
help_pages["pshy_newgame"] = {back = "pshy", title = "pshy_newgame", text = "Replaces tfm.exec.newGame, adding features.\n", commands = {}}
help_pages["pshy"].subpages["pshy_newgame"] = help_pages["pshy_newgame"]



--- Module Settings:
newgame.default = "default"			-- default rotation, can be a rotation of rotations
rotations["default"]					= Rotation:New({hidden = true, items = {"transformice"}})	-- default rotation, can only use other rotations, no maps
newgame.default_rotation 				= rotations["default"]
newgame.delay_next_map					= false
newgame.error_map						= "error_map"
newgame.update_map_name_on_new_player	= true



--- Public Members:
newgame.current_map = nil				-- the map table currently playing



--- Internal Use:
local autorespawn = false



--- Settings for tfm overriden features:
local simulated_tfm_auto_new_game = true
local simulated_tfm_auto_shaman = true



--- Internal Use:
newgame.current_settings = {}
newgame.current_settings.map_code = nil		-- the code finaly passed to the newGame function
newgame.current_settings.shamans = nil
newgame.current_settings.map_name = nil
newgame.current_settings.map = nil
newgame.current_settings.autoskip = nil
newgame.current_settings.duration = 60
newgame.current_settings.begin_funcs = {}
newgame.current_settings.end_funcs = {}
newgame.current_settings.replace_func = nil
newgame.current_settings.modules = {}			-- list of module names enabled for the map that needs to be disabled
newgame.current_settings.background_color = nil
newgame.current_settings.title = nil
newgame.current_settings.title_color = nil
newgame.current_settings.author = nil
newgame.event_new_game_triggered = false
newgame.next = nil
newgame.force_next = false
newgame.current_rotations_names = {}			-- set rotation names we went by when choosing the map
local newgame_called				= false
local players_alive_changed			= false
local newgame_time = os.time() - 3001
local displayed_map_name = nil						-- used as cache, cf `RefreshMapName()`



--- Finally calls `tfm.exec.newGame`.
-- The purpose is only to know when the original have been called.
-- This will also prevent from loading a map if another is being loaded already.
-- This is an override for local use, the override for other modules is different.
local tfm_exec_newGame = tfm.exec.newGame
local FinallyNewGame = function(mapcode, ...)
	newgame_time = os.time()
	if newgame_called then
		print_warn("newgame: tfm.exec.newGame was called while the game was already loading a new map.")
		--return
	end
	if type(mapcode) == "string" and string.find(mapcode, "<", 1, true) ~= 1 and string.find(mapcode, "#", 1, true) ~= 1 and not tonumber(mapcode) then
		print_warn("newgame: invalid rotation `%s`", mapcode)
		return
	end
	newgame_called = true
	--print_debug("pshy_newgame: tfm.exec.newGame(%s)", tostring(mapcode))
	newgame.current_settings.map_code = mapcode
	return tfm_exec_newGame(mapcode, ...)
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
function newgame.SetNextMap(code, force)
	newgame.next = code
	newgame.force_next = force or false
end



--- End the previous map.
-- @private
-- @param aborted true if the map have not even been started.
local function EndMap(aborted)
	if not aborted then
		for i_func, end_func in ipairs(newgame.current_settings.end_funcs) do
			end_func(newgame.current_settings.map_name)
		end
		if eventGameEnded then
			eventGameEnded()
		end
	end
	newgame.current_settings.shamans = nil
	OriginalTFMDisableAutoShaman(not simulated_tfm_auto_shaman)
	newgame.current_settings.map_code = nil
	newgame.current_settings.map_name = nil
	newgame.current_settings.map = nil
	newgame.current_settings.autoskip = nil
	newgame.current_settings.duration = nil
	newgame.current_settings.begin_funcs = {}
	newgame.current_settings.end_funcs = {}
	newgame.current_settings.replace_func = nil
	newgame.current_settings.background_color = nil
	newgame.current_settings.title = nil
	newgame.current_settings.title_color = nil
	newgame.current_settings.author = nil
	newgame.current_rotations_names = {}
	for i, module_name in ipairs(newgame.current_settings.modules) do 
		DisableModule(module_name)
	end
	newgame.current_settings.modules = {}
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
-- This is the main override.
-- @private
-- @param mapcode Either a map code or a map rotation code.
tfm.exec.newGame = function(mapcode, ...)
	if os.time() <= newgame_time + 3000 then
		print_error("You must wait 3000 ms before calling `tfm.exec.newGame`.")
		return
	end
	--print_debug("newgame.newGame(%s)", tostring(mapcode))
	EndMap()
	newgame.event_new_game_triggered = false
	return newgame.Next(mapcode, ...)
end



--- Add custom settings to the next map.
-- Some maps or map rotations have special settings.
-- This function handle both of them
local function AddCustomMapSettings(t)
	if t.autoskip ~= nil then
		newgame.current_settings.autoskip = t.autoskip 
	end
	if t.shamans ~= nil then
		assert(t.shamans == 0, "only a shaman count of 0 or nil is supported yet")
		newgame.current_settings.shamans = t.shamans 
		OriginalTFMDisableAutoShaman(true)
	end
	if t.duration ~= nil then
		newgame.current_settings.duration = t.duration 
	end
	if t.begin_func ~= nil then
		table.insert(newgame.current_settings.begin_funcs, t.begin_func)
	end
	if t.end_func ~= nil then
		table.insert(newgame.current_settings.end_funcs, t.end_func)
	end
	if t.replace_func ~= nil then
		newgame.current_settings.replace_func = t.replace_func 
	end
	if t.background_color ~= nil then
		newgame.current_settings.background_color = t.background_color
	end
	if t.title ~= nil then
		newgame.current_settings.title = t.title 
	end
	if t.title_color ~= nil then
		newgame.current_settings.title_color = t.title_color 
	end
	if t.author ~= nil then
		newgame.current_settings.author = t.author 
	end
	if t.modules then
		for i, module_name in pairs(t.modules) do
			table.insert(newgame.current_settings.modules, module_name)
		end
	end
end



--- newgame.newGame but only for maps listed to this module.
-- @private
local function NextDBMap(map_name)
	local map = maps[map_name]
	AddCustomMapSettings(map)
	newgame.current_settings.map_name = map_name
	newgame.current_settings.map = map
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
	if newgame.current_settings.replace_func then
		map_xml = newgame.current_settings.replace_func(map.xml)
	end
	for i, module_name in ipairs(newgame.current_settings.modules) do 
		EnableModule(module_name)
	end
	return FinallyNewGame(map_xml)
end



--- newgame.newGame but only for rotations listed to this module.
-- @private
local function NextDBRotation(rotation_name)
	if rotation_name == "default" and #newgame.default_rotation.items == nil then
		-- empty rotation, just not changing map
		return nil
	end
	local rotation = pshy.mapdb_GetRotation(rotation_name)
	rotation_name = rotation.name or rotation_name -- resolving aliases
	if newgame.current_rotations_names[rotation_name] then
		print_warn("Cyclic map rotation (%s)! Running newGame(error_map)!", rotation_name)
		EndMap(true)
		return FinallyNewGame(newgame.error_map)
	end
	newgame.current_rotations_names[rotation_name] = true
	AddCustomMapSettings(rotation)
	newgame.current_rotation_name = rotation_name
	newgame.current_rotation = rotation
	local next_map_name = rotation:Next()
	return newgame.Next(next_map_name)
end



local function SkipFromRotations(mapcode)
	for i, rotation_name in ipairs(newgame.default_rotation.items) do
		local rotation = rotations[rotation_name]
		if rotation then
			rotation:SkipItem(mapcode)
		end
	end
end



--- Setup the next map (possibly a rotation), calling newGame.
-- @private
function newgame.Next(mapcode)
	if mapcode == nil or newgame.force_next then
		if newgame.next then
			mapcode = newgame.next
			if type(mapcode) == "string" and #mapcode < 64 then
				SkipFromRotations(mapcode)
			end
		else
			mapcode = newgame.default
		end
	end
	newgame.force_next = false
	newgame.next = nil
	if maps[mapcode] then
		return NextDBMap(mapcode)
	end
	local mapcode_number = tonumber(mapcode)
	if mapcode_number and maps[mapcode_number] then
		return NextDBMap(mapcode_number)
	end
	local next_rotation = pshy.mapdb_GetRotation(mapcode)
	if next_rotation then
		return NextDBRotation(mapcode)
	end
	if tonumber(mapcode) then
		newgame.current_settings.map_name = mapcode
		for i, module_name in ipairs(newgame.current_settings.modules) do 
			EnableModule(module_name)
		end
		return FinallyNewGame(mapcode)
	end
	if string.sub(mapcode, 1, 1) == "<" then
		tfm.get.room.xmlMapInfo = {}
		tfm.get.room.xmlMapInfo.xml = mapcode
		return FinallyNewGame(mapcode)
	end
	for i, module_name in ipairs(newgame.current_settings.modules) do 
		EnableModule(module_name)
	end
	return FinallyNewGame(mapcode)
end



local function RefreshMapName()
	displayed_map_name = nil
	local author = newgame.current_settings.author or (mapinfo and mapinfo.mapinfo and mapinfo.mapinfo.author)
	local title = newgame.current_settings.title or (mapinfo and mapinfo.mapinfo and mapinfo.mapinfo.title) or newgame.current_settings.map_name
	if author or title then
		local full_map_name = ""
		local title_color = newgame.current_settings.title_color or (mapinfo and mapinfo.mapinfo and mapinfo.mapinfo.title_color)
		if author then
			full_map_name = full_map_name .. author
		end
		title = title or newgame.current_settings.map_name
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
		displayed_map_name = full_map_name
		ui.setMapName(displayed_map_name)
	end
end



--- TFM event eventNewGame.
function eventNewGame()
	newgame_called = false
	newgame.current_map = nil
	if not newgame.event_new_game_triggered then
		newgame.current_map = newgame.current_settings.map
		if newgame.current_settings.map and newgame.current_settings.map.bonuses then
			local bonuses = pshy.require("pshy.bonuses")
			if bonuses then
				for i_bonus, bonus in ipairs(newgame.current_settings.map.bonuses) do
					bonuses.AddNoCopy(bonus)
				end
			end
		end
		for i_func, begin_func in ipairs(newgame.current_settings.begin_funcs) do
			begin_func(newgame.current_settings.map_name)
		end
		if newgame.current_settings.duration then
			tfm.exec.setGameTime(newgame.current_settings.duration, true)
		end
		if newgame.current_settings.background_color then
			ui.setBackgroundColor(newgame.current_settings.background_color)
		end
		if mapinfo and mapinfo.mapinfo and mapinfo.mapinfo.background_images and mapinfo.mapinfo.foreground_images then
			for i_img, img in ipairs(mapinfo.mapinfo.background_images) do
				tfm.exec.addImage(img.image, "?0", img.x, img.y)
			end
			for i_img, img in ipairs(mapinfo.mapinfo.foreground_images) do
				tfm.exec.addImage(img.image, "!0", img.x, img.y)
			end
		end
		RefreshMapName()
	else
		-- tfm loaded a new map
		print_warn("TFM loaded a new game despite the override")
		EndMap()
		if newgame.current_settings.map then
			OriginalTFMDisableAutoShaman(false)
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
		if (newgame.current_settings.autoskip ~= false and simulated_tfm_auto_new_game) or newgame.current_settings.autoskip then
			--print_debug("changing map because time is low")
			tfm.exec.newGame(nil)
		end
	end
	if newgame_called then
		return
	end
	if players_alive_changed then
		local players_alive = utils_tfm.CountPlayersAlive()
		if players_alive == 0 then
			if (newgame.current_settings.autoskip ~= false and simulated_tfm_auto_new_game) or newgame.current_settings.autoskip then
				tfm.exec.setGameTime(5, false)
				if not newgame.delay_next_map then
					--print_debug("changing map because no player remaining, autoskip == %s", tostring(newgame.current_settings.autoskip))
					tfm.exec.newGame(nil)
				end
			end
		end
	end
end



function eventNewPlayer(player_name)
	if newgame.update_map_name_on_new_player then
		if newgame.current_settings.background_color then
			ui.setBackgroundColor(newgame.current_settings.background_color)
		end
		if displayed_map_name then
			ui.setMapName(displayed_map_name)
		end
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



function newgame.SetRotation(rotname)
	rotname = pshy.mapdb_rotation_aliases[rotname] or rotname -- check for aliases
	if rotname and not pshy.mapdb_GetRotation(rotname) then
		return false, string.format("Rotation %s does not exist!", rotname)
	end
	newgame.default_rotation.items = {}
	if rotname then
		table.insert(newgame.default_rotation.items, rotname)
		return true, string.format("Disabled all rotations and enabled %s.", rotname)
	end
	return true, "Disabled all rotations."
end



--- !next [map]
local function ChatCommandNext(user, code, force)
	newgame.SetNextMap(code, force)
	return true, string.format("The next map or rotation will be %s.", code)
end
pshy.commands["next"] = {aliases = {"np", "npp"}, perms = "admins", func = ChatCommandNext, desc = "set the next map to play (no param to cancel)", argc_min = 1, argc_max = 2, arg_types = {"string", "bool"}, arg_names = {"map code", "force"}}
help_pages["pshy_newgame"].commands["next"] = pshy.commands["next"]



--- !skip [map]
local function ChatCommandSkip(user, code)
	newgame.next = code or newgame.next
	newgame.force_next = code ~= nil
	if not newgame.next and #newgame.default_rotation.items == 0 then
		return false, "First use !rotw to set the rotations you want to use (use !rots for a list)."
	end
	tfm.exec.setGameTime(0, false)
	tfm.exec.newGame(newgame.next)
	return true
end
pshy.commands["skip"] = {aliases = {"map"}, perms = "admins", func = ChatCommandSkip, desc = "play a different map right now", argc_min = 0, argc_max = 1, arg_types = {"string"}, arg_names = {"map code"}}
help_pages["pshy_newgame"].commands["skip"] = pshy.commands["skip"]



--- !repeat
local function ChatCommandRepeat(user)
	map = newgame.current_settings.map_name
	if not map then
		return false, "Something wrong happened."
	end
	return ChatCommandSkip(user, newgame.current_settings.map_name or (mapinfo and mapinfo.mapinfo.arg1))
end
pshy.commands["repeat"] = {aliases = {"r", "replay"}, perms = "admins", func = ChatCommandRepeat, desc = "repeat the last map", argc_min = 0, argc_max = 0}
help_pages["pshy_newgame"].commands["repeat"] = pshy.commands["repeat"]



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
pshy.commands["rotations"] = {aliases = {"rots"}, perms = "admins", func = ChatCommandRotations, desc = "list available rotations", argc_min = 0, argc_max = 0}
help_pages["pshy_newgame"].commands["rotations"] = pshy.commands["rotations"]



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
	pshy.ListRemoveValue(newgame.default_rotation.items, rotname)
	if w > 0 then
		for i = 1, w do
			table.insert(newgame.default_rotation.items, rotname)
		end
	end
	newgame.default_rotation:Reset()
	return true, "Changed a map frequency."
end
pshy.commands["rotationweigth"] = {aliases = {"rotw"}, perms = "admins", func = ChatCommandRotw, desc = "set how often a rotation is to be played", argc_min = 1, argc_max = 2, arg_types = {"string", "number"}, arg_names = {"rotation", "amount"}}
help_pages["pshy_newgame"].commands["rotationweigth"] = pshy.commands["rotationweigth"]



--- !rotationclean [rotation]
local function ChatCommandRotc(user, rotname)
	return newgame.SetRotation(rotname)
end
pshy.commands["rotationclean"] = {aliases = {"rotc"}, perms = "admins", func = ChatCommandRotc, desc = "clear all rotations, and optionaly set a new one", argc_min = 0, argc_max = 1, arg_types = {"string"}, arg_names = {"new rotation"}}
help_pages["pshy_newgame"].commands["rotationclean"] = pshy.commands["rotationclean"]
newgame.ChatCommandRotc = ChatCommandRotc -- @deprecated



--- !autorespawn <on/off>
local function ChatCommandAutorespawn(user, enabled)
	autorespawn = enabled
	return true, string.format("Automatic respawn is now %s.", (autorespawn and "enabled" or "disabled"))
end
pshy.commands["autorespawn"] = {perms = "admins", func = ChatCommandAutorespawn, desc = "enable or disable automatic respawn", argc_min = 0, argc_max = 1, arg_types = {"boolean"}, arg_names = {"on/off"}}
help_pages["pshy_newgame"].commands["autorespawn"] = pshy.commands["autorespawn"]



function eventPlayerDied(player_name)
	if autorespawn then
		tfm.exec.respawnPlayer(player_name)
		return
	end
	players_alive_changed = true
	tfm.get.room.playerList[player_name].isDead = true
end



function eventPlayerWon(player_name)
	players_alive_changed = true
	tfm.get.room.playerList[player_name].isDead = true
end



function eventInit()
	for i_rot, rot in pairs(rotations) do
		-- @TODO use a custom compare function
		--if rot.unique_items then
		--	table.sort(rot.items)
		--	pshy.SortedListRemoveDuplicates(rot.items)
		--end
	end
end



return newgame
