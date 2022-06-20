--- pshy.bases.alternatives_plus
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
pshy.require("pshy.bases.alternatives")
pshy.require("pshy.bases.doc")
pshy.require("pshy.bases.encoding_graph")
pshy.require("pshy.bases.events")
pshy.require("pshy.bases.perms")
pshy.require("pshy.utils.print")



--- Module Settings:
pshy.alternatives_arbitrary_popup_id = 203
pshy.alternatives_hash_salt = nil												-- salt to use to check that a save file have not been messed with (set a unique one per private script)
pshy.alternatives_hash_size = 0
pshy.alternatives_data_fragment_size = 160



--- Internal Use:
local has_file_permissions = tfm.exec.loadPlayerData(pshy.loader) or tfm.exec.savePlayerData(pshy.loader, nil)	-- do we have permissions to use the api file functions
local players_data = {}															-- saved players data (entries are false when their loading were required)
local files_data = {}															-- saved files data (entries are false when their loading were required)
local loading_players = {}
local player_load_instructions = "Please input the next save fragment (line %d):"



--- Continue loading player data until none is remaining
-- @TODO: implement simple hash
local function ContinueSetData(user, data, target)
	if not loading_players[user] then
		loading_players[user] = {}
		loading_players[user].data = nil
		loading_players[user].hash = nil
		loading_players[user].count = 0
		loading_players[user].frag_len = pshy.alternatives_data_fragment_size
		loading_players[user].target = target or user
	end
	if data ~= nil then
		loading_players[user].data = loading_players[user].data .. data
	end
	if loading_players[user].count > 0 and (data == nil or #data ~= loading_players[user].frag_len) then
		text = pshy.DecodeGraph(loading_players[user].data)
		local target = loading_players[user].target
		if type(target) == "string" then
			players_data[target] = text
		else
			files_data[target] = text
		end
		loading_players[user] = nil
		return true
	else
		ui.addPopup(pshy.alternatives_arbitrary_popup_id, 2, string.format(player_load_instructions, loading_players[user].count + 1), user, 100, nil, 600, true)
	end
end



--- Override `system.loadPlayerData`.
-- @brief player_name The player Name#0000 to load from.
function new_loadPlayerData(player_name)
	if players_data[player_name] then
		if eventPlayerDataLoaded then
			eventPlayerDataLoaded(player_name, players_data[player_name])
			return true
		end
	else
		players_data[player_name] = false
		return true
	end
end



--- Override `system.savePlayerData`.
-- @brief player_name The player Name#0000 to save to.
-- @param data String to save to the file.
function new_savePlayerData(player_name, data)
	players_data[player_name] = data
	tfm.exec.chatMessage("<vi>▣ New player data available. You can use !getplayerdata and save it!</vi>", player_name)
end



--- Override `system.loadFile`.
-- @brief file_id The number of the file to load.
function new_loadFile(file_id)
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
	files_data[file_id] = data
	tfm.exec.chatMessage(string.format("<vi>▣ New data available for file <b>%d</b>.", file_id), pshy.loader)
end



function eventPopupAnswer(popup_id, player_name, answer)
	if popup_id == pshy.alternatives_arbitrary_popup_id then
		ContinueSetData(player_name, answer)
		return false
	end
end



function eventFileLoaded(file_id, data)
	print_debug("eventFileLoaded(%d, #%d...)", file_id, (data and #data or 0))
end



function eventFileSaved(file_id)
	print_debug("eventFileSaved(%s)", file_id)
end



function eventPlayerDataLoaded(player_name, data)
	print_debug("eventPlayerDataLoaded(%s, #%d)", player_name, (data and #data or 0))
end



--- !getfiledata.
local function ChatCommandGetFileData(user, file_id)
	target = pshy.commands_GetTargetOrError(user, target, "!getplayerdata")
	if not files_data[file_id] then
		return false, string.format("No player data for %s.", target)
	end
	tfm.exec.chatMessage(string.format("<b><vi>▣ File %d's Data:</b>", file_id), user)
	local graph = pshy.EncodeGraph(files_data[file_id])
	local parts = pshy.StrLenSplit(graph, pshy.alternatives_data_fragment_size)
	for i_part, part in ipairs(parts) do
		if i_part % 2 == 0 then
			tfm.exec.chatMessage("<ch>" .. part, user)
		else
			tfm.exec.chatMessage("<ch2>" .. part, user)
		end
	end
	return true, string.format("Copy the above to save progress (one line per color).")
end
pshy.commands["getfiledata"] = {func = ChatCommandGetFileData, desc = "get a file data (saved data)", argc_min = 1, argc_max = 1, arg_types = {"number"}}
pshy.help_pages["pshy_alternatives"].commands["getfiledata"] = pshy.commands["getfiledata"]
pshy.perms.admins["!getfiledata"] = true



--- !setfiledata.
local function ChatCommandSetFileData(user, file_id)
	loading_players[user] = nil
	ContinueSetData(user, data, file_id)
	return true, "Folow instructions on screen."
end
pshy.commands["setfiledata"] = {func = ChatCommandSetFileData, desc = "set a file data (saved data)", argc_min = 1, argc_max = 1, arg_types = {"number"}}
pshy.help_pages["pshy_alternatives"].commands["setfiledata"] = pshy.commands["setfiledata"]
pshy.perms.admins["!setfiledata"] = true



--- !getplayerdata.
local function ChatCommandGetPlayerData(user, target)
	target = pshy.commands_GetTargetOrError(user, target, "!getplayerdata")
	if not players_data[target] then
		return false, string.format("No player data for %s.", target)
	end
	tfm.exec.chatMessage(string.format("<b><vi>▣ %s's Player Data:</b>", target), user)
	local graph = pshy.Encodegraph(players_data[target])
	local parts = pshy.StrLenSplit(graph, 160)
	for i_part, part in ipairs(parts) do
		if i_part % 2 == 0 then
			tfm.exec.chatMessage("<ch>" .. part, user)
		else
			tfm.exec.chatMessage("<ch2>" .. part, user)
		end
	end
	return true, "Copy the above to save your progress (one line per color)."
end
pshy.commands["getplayerdata"] = {func = ChatCommandGetPlayerData, desc = "get your player data (saved data)", argc_min = 0, argc_max = 1, arg_types = {"player"}}
pshy.help_pages["pshy_alternatives"].commands["getplayerdata"] = pshy.commands["getplayerdata"]
pshy.perms.everyone["!getplayerdata"] = true



--- !setplayerdata.
local function ChatCommandSetPlayerData(user, data, target)
	target = pshy.commands_GetTargetOrError(user, target, "!setplayerdata")
	loading_players[user] = nil
	ContinueSetData(user, data, target)
	return true, "Folow instructions on screen."
end
pshy.commands["setplayerdata"] = {func = ChatCommandSetPlayerData, desc = "set your player data (saved data)", argc_min = 0, argc_max = 1, arg_types = {"player"}}
pshy.help_pages["pshy_alternatives"].commands["setplayerdata"] = pshy.commands["setplayerdata"]
pshy.perms.everyone["!setplayerdata"] = true



function eventInit()
	if not has_file_permissions then
		system.loadFile = new_loadFile
		system.loadPlayerData = new_loadPlayerData
		system.saveFile = new_saveFile
		system.savePlayerData = new_savePlayerData
	end
end
