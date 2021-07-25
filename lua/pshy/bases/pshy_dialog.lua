--- pshy_dialog.lua
--
-- Create callbacks for your dialog messages.
--
-- @author TFM:Pshy#3752 DC:7998
-- @namespace pshy
-- @require pshy_utils.lua
pshy = pshy or {}



--- Module Settings:
pshy.dialog_arbitrary_popup_id = 8
pshy.dialog_arbitrary_color_picker_id = 8
pshy.dialog_x = 20
pshy.dialog_y = 100



--- Internal use:
pshy.dialog_players_callbacks = {}		-- store callbacks for players
										--	- func: the function to call
										--	- argc: the function's argument count
										--	- argv: a table of arguments to pass to the function
										--	- i_arg: the argument to replace with the player's answer
										--	- convert_type: a type to convert the player's answer to



--- Open a boolean dialog.
-- @param text Text to display in the popup.
-- @param player_name The player's Name#0000.
-- @cf pshy.dialog_SetPlayerCallback
function pshy.dialog_AskForYesOrNo(text, player_name, func, argc, argv, i_arg, convert_type)
	pshy.dialog_SetPlayerCallback(player_name, func, argc, argv, i_arg, convert_type)
	ui.addPopup(pshy.dialog_arbitrary_popup_id, 1, text, player_name)
end



--- Open a text dialog.
-- @param text Text to display in the popup.
-- @param player_name The player's Name#0000.
-- @cf pshy.dialog_SetPlayerCallback
function pshy.dialog_AskForText(text, player_name, func, argc, argv, i_arg, convert_type)
	pshy.dialog_SetPlayerCallback(player_name, func, argc, argv, i_arg, convert_type)
	ui.addPopup(pshy.dialog_arbitrary_popup_id, 2, text, player_name)
end



--- Open a color dialog.
-- @param title Text to display in the popup.
-- @param player_name The player's Name#0000.
-- @cf pshy.dialog_SetPlayerCallback
function pshy.dialog_AskForColor(title, player_name, func, argc, argv, i_arg, convert_type)
	pshy.dialog_SetPlayerCallback(player_name, func, argc, argv, i_arg, convert_type)
	ui.showColorPicker(pshy.dialog_arbitrary_color_picker_id, player_name, 0xffffff, title)
end



--- Set a player's callback informations.
-- @private
-- @param player_name The player's Name#0000.
-- @param func The function to call.
-- @param argc The function's argument count.
-- @param args A table of arguments to pass to the function.
-- @param i_arg The index of the argulent to be replaced with the player's answer.
-- @private
function pshy.dialog_SetPlayerCallback(player_name, func, argc, argv, i_arg, convert_type)
	assert(type(func) == "function")
	pshy.dialog_players_callbacks = pshy.dialog_players_callbacks[player_name] or {}
	local player_callback = pshy.dialog_players_callbacks[player_name]
	player_callback.func = func
	player_callback.argc = argc or 1
	player_callback.argv = argv or {""}
	player_callback.i_arg = i_arg or 1
	player_callback.convert_type = convert_type or "string"
end



--- Called when a player answered a question.
-- @private
-- @param player_name The player's Name#0000.
function pshy.dialog_Answered(player_name, answer)
	player_callback = pshy.dialog_players_callbacks[player_name]
	if not player_callback then
		return
	end
	rst = pshy.ToType(player_name, answer)
	player_callback.argv[i_arg] = rst
	pcall(player_callback.func, table.unpack(player_callback.argv))
	pshy.dialog_players_callbacks[player_name]
end



--- TFM event eventPopupAnswer.
function eventPopupAnswer(popup_id, player_name, answer)
	if popup_id ~= pshy.dialog_arbitrary_popup_id then
		return
	end
	pshy.dialog_Answered(player_name, answer)
end



--- TFM event eventColorPicked.
function eventColorPicked(popup_id, player_name, color)
	if popup_id ~= pshy.dialog_arbitrary_color_picker_id then
		return
	end
	pshy.dialog_Answered(player_name, color)
end
