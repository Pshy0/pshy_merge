--- pshy.alternatives.data
--
-- Allow some scripts using restricted lua features to still work when those are not available.
--
-- Implements:
--	- system.loadFile(fileNumber)
--	- system.loadPlayerData(playerName)
--	- system.saveFile(data, fileNumber)
--	- system.savePlayerData(playerName, data)
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.alternatives.chat")
pshy.require("pshy.alternatives.timers")
local command_list = pshy.require("pshy.commands.list")
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")
pshy.require("pshy.utils.print")
local utils_strings = pshy.require("pshy.utils.strings")
local room = pshy.require("pshy.room")
local ids = pshy.require("pshy.utils.ids")



--- Namespace:
local alternatives_plus = {}



--- Module Settings:
alternatives_plus.popup_id = ids.AllocPopupId()
alternatives_plus.hash_salt = nil												-- salt to use to check that a save file have not been messed with (set a unique one per private script)
alternatives_plus.hash_size = 0
alternatives_plus.data_fragment_size = 160



--- Original functions
local original_loadFile = system.loadFile
local original_loadPlayerData = system.loadPlayerData
local original_saveFile = system.saveFile
local original_savePlayerData = system.savePlayerData



--- Internal Use:
local has_file_permissions = system.loadPlayerData(room.loader) == true			-- do we have permissions to use the api file functions
local players_data = {}															-- saved players data (entries are false when their loading were required)
local players_with_new_data = {}
local players_data_requested_to_load = {}
local files_data = {}															-- saved files data (entries are false when their loading were required)
local loading_players = {}
local player_load_instructions = "Please input the next save fragment (line %d):"
local first_loader_data_event_to_be_ignored = has_file_permissions



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.require("pshy.commands.get_target_or_error")



local utf8_to_graph_chars = {
	{"\\", "▣"};
	{"\a", "\\a"};
	{"\b", "\\b"};
	{"\f", "\\f"};
	{"\n", "\\n"};
	{"\r", "\\r"};
	{"\t", "\\t"};
	{"\v", "\\v"};
	{" ", "\\_"};
}
for c = 17,20 do
	table.insert(utf8_to_graph_chars, {string.char(c), "\\x" .. string.format("%02x", c)})
end
table.insert(utf8_to_graph_chars, {"▣", "\\\\"})



local function UTF8ToGraph(text)
	assert(text ~= nil)
	for i_c_map, c_map in ipairs(utf8_to_graph_chars) do
		text = string.gsub(text, c_map[1], c_map[2])
	end
	return text
end



local function GraphToUTF8(text)
	for i_c_map = #utf8_to_graph_chars, 1, -1 do
		local c_map = utf8_to_graph_chars[i_c_map]
		text = string.gsub(text, c_map[2], c_map[1])
	end
	return text
end




--- Continue loading player data until none is remaining
-- @TODO: implement simple hash
local function ContinueSetData(user, data, target)
	if not loading_players[user] then
		loading_players[user] = {}
		loading_players[user].data = ""
		loading_players[user].hash = nil
		loading_players[user].count = 0
		loading_players[user].frag_len = alternatives_plus.data_fragment_size
		loading_players[user].target = target or user
	end
	if data ~= nil then
		loading_players[user].count = loading_players[user].count + 1
		loading_players[user].data = loading_players[user].data .. data
	end
	if data == "" then
		local text = GraphToUTF8(loading_players[user].data)
		local target = loading_players[user].target
		if type(target) == "string" then
			players_data[target] = text
		else
			files_data[target] = text
		end
		loading_players[user] = nil
		return true
	else
		ui.addPopup(alternatives_plus.popup_id, 2, string.format(player_load_instructions, loading_players[user].count + 1), user, 40, nil, 700, true)
	end
end



--- Override `system.loadPlayerData`.
-- @brief player_name The player Name#0000 to load from.
function new_loadPlayerData(player_name)
	if has_file_permissions then
		return original_loadPlayerData(player_name)
	end
	if not tfm.get.room.playerList[player_name] then
		return false
	end
	if players_data[player_name] then
		if eventPlayerDataLoaded then
			eventPlayerDataLoaded(player_name, players_data[player_name])
			return true
		end
	else
		players_data[player_name] = false
		players_data_requested_to_load[player_name] = players_data_requested_to_load[player_name] or 0
		players_data_requested_to_load[player_name] = players_data_requested_to_load[player_name] + 1
		if players_data_requested_to_load[player_name] == 1 and loading_players[player_name] == nil then
			ContinueSetData(player_name, nil, player_name)
		end
		return true
	end
end



--- Override `system.savePlayerData`.
-- @brief player_name The player Name#0000 to save to.
-- @param data String to save to the file.
function new_savePlayerData(player_name, data)
	if has_file_permissions then
		return original_savePlayerData(player_name, data)
	end
	if data ~= nil and players_data[player_name] == data then
		return
	end
	players_data[player_name] = data
	if not players_with_new_data[player_name] then
		tfm.exec.chatMessage("▣ <vi>New player data available. You can use !getplayerdata and save it!</vi>", player_name)
	end
	players_with_new_data[player_name] = true
end



--- Override `system.loadFile`.
-- @brief file_id The number of the file to load.
function new_loadFile(file_id)
	if has_file_permissions then
		return original_loadFile(file_id)
	end
	if file_id < 0 or file_id > 99 then
		return false
	end
	if files_data[file_id] then
		if eventFileLoaded then
			eventFileLoaded(file_id, files_data[file_id])
			return true
		end
	else
		files_data[file_id] = false
		return true
	end
end



--- Override `system.saveFile`.
-- @param data String to save to the file.
-- @param file_id The file number to save to.
function new_saveFile(data, file_id)
	if has_file_permissions then
		return original_saveFile(file_id)
	end
	files_data[file_id] = data
	tfm.exec.chatMessage(string.format("▣ <vi>New data available for file <j>%d</j>.</vi>", file_id), room.loader)
end



function eventPopupAnswer(popup_id, player_name, answer)
	if popup_id == alternatives_plus.popup_id then
		ContinueSetData(player_name, answer)
		return false
	end
end



function eventFileLoaded(file_id, data)
	print_debug("eventFileLoaded(%d, #%d...)", file_id, #data)
end



function eventFileSaved(file_id)
	print_debug("eventFileSaved(%s)", file_id)
end



function eventPlayerDataLoaded(player_name, data)
	if first_loader_data_event_to_be_ignored and player_name == room.loader then
		first_loader_data_event_to_be_ignored = false
		return false
	end
	print_debug("eventPlayerDataLoaded(%s, #%d)", player_name, #data)
end



function eventLoop()
	local loaded_players = {}
	for player_name, count in pairs(players_data_requested_to_load) do
		if players_data[player_name] then
			for i = 1, count do
				eventPlayerDataLoaded(player_name, players_data[player_name] or "")
			end
			loaded_players[player_name] = true
		end
	end
	for player_name in pairs(loaded_players) do
		players_data_requested_to_load[player_name] = nil
	end
end



--- !getfiledata.
local function ChatCommandGetFileData(user, file_id)
	target = GetTarget(user, target, "!getfiledata")
	if not files_data[file_id] then
		return false, string.format("No player data for %s.", target)
	end
	tfm.exec.chatMessage(string.format("▣ <vi>File %d's Data:</vi>", file_id), user)
	local graph = UTF8ToGraph(files_data[file_id])
	local parts = utils_strings.LenSplit(graph, alternatives_plus.data_fragment_size)
	for i_part, part in ipairs(parts) do
		if i_part % 2 == 0 then
			tfm.exec.chatMessage("<ch>" .. part, user)
		else
			tfm.exec.chatMessage("<ch2>" .. part, user)
		end
	end
	return true, string.format("Copy the above to save progress (one line per color).")
end
command_list["getfiledata"] = {perms = "admins", func = ChatCommandGetFileData, desc = "get a file data (saved data)", argc_min = 1, argc_max = 1, arg_types = {"number"}}
help_pages["pshy_alternatives"].commands["getfiledata"] = command_list["getfiledata"]



--- !setfiledata.
local function ChatCommandSetFileData(user, file_id)
	loading_players[user] = nil
	ContinueSetData(user, data, file_id)
	return true, "Folow instructions on screen."
end
command_list["setfiledata"] = {perms = "admins", func = ChatCommandSetFileData, desc = "set a file data (saved data)", argc_min = 1, argc_max = 1, arg_types = {"number"}}
help_pages["pshy_alternatives"].commands["setfiledata"] = command_list["setfiledata"]



--- !getplayerdata.
local function ChatCommandGetPlayerData(user, target)
	target = GetTarget(user, target, "!getplayerdata")
	if not players_data[target] then
		return false, string.format("No player data for %s.", target)
	end
	tfm.exec.chatMessage(string.format("▣ <vi>%s's Player Data:</vi>", target), user)
	--local graph = pshy.Encodegraph(players_data[target])
	local graph = UTF8ToGraph(players_data[target])
	local parts = utils_strings.LenSplit(graph, 160)
	for i_part, part in ipairs(parts) do
		if i_part % 2 == 0 then
			tfm.exec.chatMessage("<ch>" .. part, user)
		else
			tfm.exec.chatMessage("<ch2>" .. part, user)
		end
	end
	players_with_new_data[target] = nil
	return true, "Copy the above to save your progress (one line per color)."
end
command_list["getplayerdata"] = {perms = "everyone", func = ChatCommandGetPlayerData, desc = "get your player data (saved data)", argc_min = 0, argc_max = 1, arg_types = {"player"}}
help_pages["pshy_alternatives"].commands["getplayerdata"] = command_list["getplayerdata"]



--- !setplayerdata.
local function ChatCommandSetPlayerData(user, target)
	target = GetTarget(user, target, "!setplayerdata")
	loading_players[user] = nil
	ContinueSetData(user, nil, target)
	return true, "Follow instructions on screen."
end
command_list["setplayerdata"] = {perms = "everyone", func = ChatCommandSetPlayerData, desc = "set your player data (saved data)", argc_min = 0, argc_max = 1, arg_types = {"player"}}
help_pages["pshy_alternatives"].commands["setplayerdata"] = command_list["setplayerdata"]



--- !eventplayerdataloaded.
local function ChatCommandEventplayerdataloaded(user, target)
	target = GetTarget(user, target, "!eventplayerdataloaded")
	if eventPlayerDataLoaded then
		eventPlayerDataLoaded(target, players_data[target] or "")
	end
end
command_list["eventplayerdataloaded"] = {perms = "everyone", func = ChatCommandEventplayerdataloaded, desc = "call eventPlayerDataLoaded(user, nil)", argc_min = 0, argc_max = 1, arg_types = {"player"}}
help_pages["pshy_alternatives"].commands["eventplayerdataloaded"] = command_list["eventplayerdataloaded"]



if not has_file_permissions then
	system.loadFile = new_loadFile
	system.loadPlayerData = new_loadPlayerData
	system.saveFile = new_saveFile
	system.savePlayerData = new_savePlayerData
end



return alternatives_plus
