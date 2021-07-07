--- pshy_ban.lua
--
-- Allow to ban players from the room.
-- Players are not realy made to leave the room, just prevented from playing.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_ban.lua
-- @require pshy_help
-- @require pshy_merge.lua
-- @require pshy_commands.lua
pshy = pshy or {}



--- Module Help Page:
pshy.help_pages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"] or {back = "pshy", restricted = true, text = "", commands = {}, subpages = {}}
pshy.help_pages["pshy"].subpages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"]



--- Module Settings:
pshy.ban_mask_ui_arbitrary_id = 71



--- Internal Use:
pshy.banlist = {}



--- Ban a player
function pshy.BanPlayer(player_name)
	pshy.banlist[player_name] = true
	pshy.BanRefreshPlayer(player_name)
end
pshy.chat_commands["ban"] = {func = pshy.BanPlayer, desc = "Ban a player from the room.", no_user = true, argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_anticheats"].commands["ban"] = pshy.chat_commands["ban"]



--- Unban a player
function pshy.UnbanPlayer(player_name)
	pshy.banlist[player_name] = true
	ui.removeTextArea(pshy.ban_mask_ui_arbitrary_id, player_name)
end
pshy.chat_commands["unban"] = {func = pshy.UnbanPlayer, desc = "Unban a player from the room.", no_user = true, argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_anticheats"].commands["unban"] = pshy.chat_commands["unban"]



--- Proceed with what have to be done on a banned player.
-- @private
function pshy.BanRefreshPlayer(player_name)
	tfm.exec.removeCheese("player_name")
	tfm.exec.movePlayer(player_name, -1001, -1001, false, 0, 0, true)
	tfm.exec.killPlayer("player_name")
	ui.addTextArea(pshy.ban_mask_ui_arbitrary_id, "", player_name, -199, -199, 800 + 401, 400 + 401, 0, 0, 0.01, false)
	tfm.exec.setPlayerScore(player_name, -1, false)
end



--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	if pshy.banlist[player_name] then
        	pshy.BanRefreshPlayer(player_name)
        end
end



--- TFM event eventNewGame
function eventNewGame()
	for player_name, banned in pairs(pshy.banlist) do
        	pshy.BanRefreshPlayer(player_name)
        end
end



--- TFM event eventPlayerRespawn
function eventPlayerRespawn(player_name)
	if pshy.banlist[player_name] then
        	pshy.BanRefreshPlayer(player_name)
        end
end



--- TFM event eventChatCommand
-- Return false for banned players to hope that the command processing will be canceled.
function eventChatCommand(player_name, message)
        if pshy.banlist[player_name] then
        	return false
        end
end



--- Unban a player
function pshy.ChatCommandBanlist(user)
	local s = "PSHY ROOM BANS:\n"
	for player_name, banned in pairs(pshy.banlist) do
        	s = s .. player_name .. "\n"
        end
	ui.addPopup(1, 0, s, user, 0, 0, 200, true)
end
pshy.chat_commands["banlist"] = {func = pshy.ChatCommandBanlist, desc = "See the bans list.", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_anticheats"].commands["banlist"] = pshy.chat_commands["banlist"]
