--- pshy.utils.messages
--
-- Basic functions related to sending messages to players.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @hardmerge
pshy = pshy or {}



--- Formatted print.
function pshy.PrintF(str, ...)
	return print(string.format(str, ...))
end
if not printf then
	printf = pshy.PrintF
end



--- Answer a player's command.
-- @param msg The message to send.
-- @param player_name The player who will receive the message.
function pshy.Answer(msg, player_name)
	assert(player_name ~= nil)
	tfm.exec.chatMessage("<n> ↳ " .. tostring(msg), player_name)
end



--- Answer a player's command (on error).
-- @param msg The message to send.
-- @param player_name The player who will receive the message.
function pshy.AnswerError(msg, player_name)
	assert(player_name ~= nil)
	tfm.exec.chatMessage("<r> × " .. tostring(msg), player_name)
end



--- Send a message.
-- @param msg The message to send.
-- @param player_name The player who will receive the message (nil for everyone).
function pshy.Message(msg, player_name)
	tfm.exec.chatMessage("<n> ⚛ " .. tostring(msg), player_name)
end



--- Send a message as the module.
-- @param msg The message to send.
-- @param player_name The player who will receive the message (nil for everyone).
function pshy.System(msg, player_name)
	tfm.exec.chatMessage("<n> ⚒ " .. tostring(msg), player_name)
end



--- Log a message and also display it to the host.
-- @param msg Message to log.
-- @todo This may have to be overloaded by pshy_perms?
function pshy.Log(msg)
	tfm.exec.chatMessage("log: " .. tostring(msg), pshy.loader)
	print("log: " .. tostring(msg))
end



--- Show the dialog window with a message (simplified)
-- @param player_name The player who see the popup.
-- @param message The message the player will see.
function pshy.Popup(player_name, message)
	ui.addPopup(4097, 0, tostring(message), player_name, 40, 20, 720, true)
end



--- Show a html title at the top of the screen.
-- @param html The html to display, or nil to hide.
-- @param player_name The player name to display the title to, or nil for all players.
function pshy.Title(html, player_name)
	html = html or nil
	player_name = player_name or nil
	local title_id = 82 -- arbitrary random id
	if html then
		ui.addTextArea(title_id, html, player_name, 0, 20, 800, nil, 0x000000, 0x000000, 1.0, true)
	else
		ui.removeTextArea(title_id, player_name)
	end
end


