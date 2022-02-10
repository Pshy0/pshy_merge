--- pshy_ban.lua
--
-- Allow to ban players from the room.
-- Players are not realy made to leave the room, just prevented from playing.
--
-- You can also shadowban a player.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_help.lua
-- @require pshy_merge.lua
-- @require pshy_commands.lua
-- @require pshy_players.lua
--
-- @require_priority ANTICHEAT
pshy = pshy or {}



--- Module Help Page:
pshy.help_pages["pshy_ban"] = {restricted = true, back = "pshy", text = "", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_ban"] = pshy.help_pages["pshy_ban"]



--- Internal use:
pshy.ban_mask_ui_arbitrary_id = 73



--- Proceed with what have to be done on a banned player.
-- @param player_name The Name#0000 of the player to apply the ban effects on.
-- @private
local function ApplyBanEffects(player_name)
	tfm.exec.removeCheese(player_name)
	tfm.exec.movePlayer(player_name, -1001, -1001, false, 0, 0, true)
	tfm.exec.killPlayer(player_name)
	ui.addTextArea(pshy.ban_mask_ui_arbitrary_id, "", player_name, -999, -999, 800 + 2002, 400 + 2002, 0x111111, 0, 0.01, false)
	tfm.exec.setPlayerScore(player_name, -1, false)
end



--- Ban a player from the running script (unban him on leave).
-- @param player_name The player's Name#0000.
-- @param reason The official ban reason.
function pshy.ban_KickPlayer(player_name, reason)
	local player = pshy.players[player_name]
	if player.banned then
		return false, "This player is already banned."
	end
	player.kicked = true
	player.banned = true
	player.ban_reason = reason or "reason not provided"
	ApplyBanEffects(player_name)
	return true, string.format("%s script kicked (%s)", player_name, player.ban_reason)
end
pshy.commands["kick"] = {func = pshy.ban_KickPlayer, desc = "'Kick' a player from the script (they need to rejoin).", no_user = true, argc_min = 1, argc_max = 1, arg_types = {"player"}}
pshy.help_pages["pshy_ban"].commands["kick"] = pshy.commands["kick"]
pshy.perms.admins["!kick"] = true



--- Ban a player from the running script.
-- @param player_name The player's Name#0000.
-- @param reason The official ban reason.
function pshy.ban_BanPlayer(player_name, reason)
	local player = pshy.players[player_name]
	player.kicked = false
	player.banned = true
	player.ban_reason = reason or "reason not provided"
	ApplyBanEffects(player_name)
	return true, string.format("%s script banned (%s)", player_name, player.ban_reason)
end
pshy.commands["ban"] = {func = pshy.ban_BanPlayer, desc = "'ban' a player from the script.", no_user = true, argc_min = 1, argc_max = 1, arg_types = {"player"}}
pshy.help_pages["pshy_ban"].commands["ban"] = pshy.commands["ban"]
pshy.perms.admins["!ban"] = true



--- ShadowBan a player from the running script.
-- @param player_name The player's Name#0000.
-- @param reason A ban reason visible only to the room admins.
function pshy.ban_ShadowBanPlayer(player_name, reason)
	local player = pshy.players[player_name]
	player.kicked = false
	player.banned = false
	player.shadow_banned = true
	player.shadow_ban_score = tfm.get.room.playerList[player_name].score
	player.ban_reason = reason or "reason not provided"
	return true, string.format("%s script shadowbanned (%s)", player_name, player.ban_reason)
end
pshy.commands["shadowban"] = {func = pshy.ban_ShadowBanPlayer, desc = "Disable most of the script's features for this player.", no_user = true, argc_min = 1, argc_max = 1, arg_types = {"player"}}
pshy.help_pages["pshy_ban"].commands["shadowban"] = pshy.commands["shadowban"]
pshy.perms.admins["!shadowban"] = true



--- Unban a player
function pshy.ban_UnbanPlayer(player_name)
	local player = pshy.players[player_name]
	if not player then
		return false, "This player does not exist."
	end
	if not player.kicked and not player.banned and not player.shadow_banned then
		return false, "This player is not banned."
	end
	player.kicked = false
	player.banned = false
	player.shadow_banned = false
	ui.removeTextArea(pshy.ban_mask_ui_arbitrary_id, player_name)
	return true, string.format("Unbanned %s.", player_name)
end
pshy.commands["unban"] = {func = pshy.ban_UnbanPlayer, desc = "Unban a player from the room.", no_user = true, argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_ban"].commands["unban"] = pshy.commands["unban"]
pshy.perms.admins["!unban"] = true



--- TFM event eventNewPlayer.
-- Apply ban effects on banned players who rejoined.
function eventNewPlayer(player_name)
	if pshy.players[player_name].banned then
        ApplyBanEffects(player_name)
    end
end



--- TFM event eventPlayerLeft.
-- Remove the ban for kiked players.
function eventPlayerLeft(player_name)
	local player = pshy.players[player_name]
	if player.kicked then
        player.kicked = false
        player.banned = false
    end
end



--- TFM event eventNewGame.
-- Apply the ban effects on banned players.
function eventNewGame()
	for player_name in pairs(tfm.get.room.playerList) do
        if pshy.players[player_name].banned then
        	ApplyBanEffects(player_name)
    	end
    end
end



--- TFM event eventPlayerRespawn.
-- Apply the ban effects on banned players who respawn.
function eventPlayerRespawn(player_name)
	if pshy.players[player_name].banned then
        ApplyBanEffects(player_name)
    end
end



--- TFM event eventChatCommand.
-- Return false for banned players to hope that the command processing will be canceled.
function eventChatCommand(player_name, message)
    if pshy.players[player_name].banned then
        return false
    end
end



--- TFM event eventPlayerWon.
-- Cancel this event for shadow_banned players.
-- Also override the player's score in `tfm.get.room.playerList`.
function eventPlayerWon(player_name)
	if pshy.players[player_name].shadow_banned then
		local player = pshy.players[player_name]
		player.won = false
		tfm.exec.setPlayerScore(player_name, player.shadow_ban_score, false)
		tfm.get.room.playerList[player_name].score = player.shadow_ban_score
        return false
    end
end



--- TFM event eventPlayerGetCheese.
-- Cancel this event for shadow_banned players.
function eventPlayerGetCheese(player_name)
	if pshy.players[player_name].shadow_banned then
        return false
    end
end



--- Display a list of banned players.
local function ChatCommandBanlist(user)
	tfm.exec.chatMessage("<r><b>SCRIPT-BANNED PLAYERS:</b></r>", user)
	for player_name, player in pairs(pshy.players) do
		if player.kicked then
			tfm.exec.chatMessage(string.format("<j>%s KICKED:<j> %s", player_name, player.ban_reason), user)
		elseif player.banned then
			tfm.exec.chatMessage(string.format("<r>%s BANNED:<r> %s", player_name, player.ban_reason), user)
		elseif player.shadow_banned then
			tfm.exec.chatMessage(string.format("<vi>%s SHADOW BANNED:<vi> %s", player_name, player.ban_reason), user)
		end
	end
	return true
end
pshy.commands["banlist"] = {func = ChatCommandBanlist, desc = "See the bans list.", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_ban"].commands["banlist"] = pshy.commands["banlist"]
pshy.perms.admins["!banlist"] = true
