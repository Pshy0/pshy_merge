--- pshy.ui.dialog
--
-- Abstraction to show dialogs to a player, using a callback.
-- See dialog.Ask* functions.
-- The callbacks are called as `callback(player_name, answer)`.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
pshy.require("pshy.utils.print")
local ids = pshy.require("pshy.utils.ids")



--- Namespace:
local dialog = {}



--- Module Settings:
local dialog_popup_id = ids.AllocPopupId()
local dialog_color_picker_id = ids.AllocColorPickerId()
local dialog_x = 300
local dialog_y = 100



--- Internal use:
local dialog_players_callbacks = {}



--- Open a boolean dialog.
-- @param player_name The player's Name#0000.
-- @param text Text to display in the popup.
-- @param callback A function ton call when the player have answered.
-- @cf dialog.SetPlayerCallback
function dialog.AskForYesOrNo(player_name, text, callback)
	dialog_players_callbacks[player_name] = callback
	ui.addPopup(dialog_popup_id, 1, text, player_name, dialog_x, dialog_y, nil, true)
end



--- Open a text dialog.
-- @param player_name The player's Name#0000.
-- @param text Text to display in the popup.
-- @param callback A function ton call when the player have answered.
-- @cf dialog.SetPlayerCallback
function dialog.AskForText(player_name, text, callback)
	dialog_players_callbacks[player_name] = callback
	ui.addPopup(dialog_popup_id, 2, text, player_name, dialog_x, dialog_y, nil, true)
end



--- Open a color dialog.
-- @param player_name The player's Name#0000.
-- @param title Text to display in the popup.
-- @param callback A function ton call when the player have answered.
-- @cf dialog.SetPlayerCallback
function dialog.AskForColor(player_name, title, callback, default_color)
	dialog_players_callbacks[player_name] = callback
	ui.showColorPicker(dialog_color_picker_id, player_name, default_color or 0xffffff, title)
end



--- Called when a player answered a question.
-- @private
-- @param player_name The player's Name#0000.
local function Answered(player_name, answer)
	local callback = dialog_players_callbacks[player_name]
	if callback then
		dialog_players_callbacks[player_name] = nil
		callback(player_name, answer)
	else
		print_warn("pshy_dialog: no callback for %s: %s", player_name, tostring(answer))
	end
end



--- TFM event eventPopupAnswer.
function eventPopupAnswer(popup_id, player_name, answer)
	if popup_id == dialog_popup_id then
		Answered(player_name, answer)
	end
end



--- TFM event eventColorPicked.
function eventColorPicked(popup_id, player_name, color)
	if popup_id == dialog_color_picker_id then
		Answered(player_name, color)
	end
end



return dialog
