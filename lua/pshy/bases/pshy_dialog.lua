--- pshy_dialog.lua
--
-- Abstraction to show dialogs to a player, using a callback.
-- See pshy.dialog_Ask* functions.
-- The callbacks are called as `callback(player_name, answer)`.
--
-- @author TFM:Pshy#3752 DC:7998
--
-- @require pshy_merge.lua
-- @require pshy_print.lua
--
-- @require_priority UTILS
pshy = pshy or {}



--- Module Settings:
pshy.dialog_arbitrary_popup_id = 8
pshy.dialog_arbitrary_color_picker_id = 8
pshy.dialog_x = 300
pshy.dialog_y = 100



--- Internal use:
pshy.dialog_players_callbacks = {}



--- Open a boolean dialog.
-- @param player_name The player's Name#0000.
-- @param text Text to display in the popup.
-- @param callback A function ton call when the player have answered.
-- @cf pshy.dialog_SetPlayerCallback
function pshy.dialog_AskForYesOrNo(player_name, text, callback)
	pshy.dialog_players_callbacks[player_name] = callback
	ui.addPopup(pshy.dialog_arbitrary_popup_id, 1, text, player_name)
end



--- Open a text dialog.
-- @param player_name The player's Name#0000.
-- @param text Text to display in the popup.
-- @param callback A function ton call when the player have answered.
-- @cf pshy.dialog_SetPlayerCallback
function pshy.dialog_AskForText(player_name, text, callback)
	pshy.dialog_players_callbacks[player_name] = callback
	ui.addPopup(pshy.dialog_arbitrary_popup_id, 2, text, player_name)
end



--- Open a color dialog.
-- @param player_name The player's Name#0000.
-- @param title Text to display in the popup.
-- @param callback A function ton call when the player have answered.
-- @cf pshy.dialog_SetPlayerCallback
function pshy.dialog_AskForColor(player_name, title, callback, default_color)
	pshy.dialog_players_callbacks[player_name] = callback
	ui.showColorPicker(pshy.dialog_arbitrary_color_picker_id, player_name, default_color or 0xffffff, title)
end



--- Called when a player answered a question.
-- @private
-- @param player_name The player's Name#0000.
local function Answered(player_name, answer)
	local callback = pshy.dialog_players_callbacks[player_name]
	if callback then
		pshy.dialog_players_callbacks[player_name] = nil
		callback(player_name, answer)
	else
		print_warn("pshy_dialog: no callback for %s: %s", player_name, tostring(answer))
	end
end



--- TFM event eventPopupAnswer.
function eventPopupAnswer(popup_id, player_name, answer)
	if popup_id == pshy.dialog_arbitrary_popup_id then
		Answered(player_name, answer)
	end
end



--- TFM event eventColorPicked.
function eventColorPicked(popup_id, player_name, color)
	if popup_id == pshy.dialog_arbitrary_color_picker_id then
		Answered(player_name, color)
	end
end
