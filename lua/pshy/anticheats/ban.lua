--- pshy.anticheats.ban
--
-- Allow to ban players from the room.
-- Players are not realy made to leave the room, just prevented from playing.
--
-- You can also shadowban a player.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")
local players = pshy.require("pshy.players")
local player_list = players.list			-- optimization
local ids = pshy.require("pshy.utils.ids")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {restricted = true, back = "pshy", title = "Kick / Ban", text = ""}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Namespace.
local ban = {}



--- Public Members:
ban.banned_players = {}
ban.shadow_banned_players = {}
ban.shadowban_simulate_death = false
ban.shadowban_abort_winning = true



--- Internal use:
local player_list = players.list
local ban_mask_ui_id = ids.AllocTextAreaId()
local pass_next_event_player_died = false
local banned_players = ban.banned_players
local shadow_banned_players = ban.shadow_banned_players



--- Override for `tfm.exec.respawnPlayer`.
local tfm_exec_respawnPlayer = tfm.exec.respawnPlayer
tfm.exec.respawnPlayer = function(player_name, ...)
	if banned_players[player_name] then
		return
	end
	return tfm_exec_respawnPlayer(player_name, ...)
end



--- Proceed with what have to be done on a banned player.
-- @param player_name The Name#0000 of the player to apply the ban effects on.
-- @private
local function ApplyBanEffects(player_name)
	tfm.exec.removeCheese(player_name)
	tfm.exec.movePlayer(player_name, -1001, -1001, false, 0, 0, true)
	tfm.exec.killPlayer(player_name)
	ui.addTextArea(ban_mask_ui_id, "", player_name, -999, -999, 800 + 2002, 400 + 2002, 0x111111, 0, 0.01, false)
	tfm.exec.setPlayerScore(player_name, -1, false)
end



--- Ban a player from the running script (unban him on leave).
-- @param player_name The player's Name#0000.
-- @param reason The official ban reason.
function ban.KickPlayer(player_name, reason)
	local player = player_list[player_name]
	if player.banned then
		return false, "This player is already banned."
	end
	banned_players[player_name] = player
	player.kicked = true
	player.banned = true
	player.ban_reason = reason or "reason not provided"
	ApplyBanEffects(player_name)
	return true, string.format("%s script kicked (%s)", player_name, player.ban_reason)
end



--- Ban a player from the running script.
-- @param player_name The player's Name#0000.
-- @param reason The official ban reason.
function ban.BanPlayer(player_name, reason)
	local player = player_list[player_name]
	if player.banned and not player.kicked then
		return false, "This player is already banned."
	end
	banned_players[player_name] = player
	player.kicked = false
	player.banned = true
	player.ban_reason = reason or "reason not provided"
	ApplyBanEffects(player_name)
	return true, string.format("%s script banned (%s)", player_name, player.ban_reason)
end



--- ShadowBan a player from the running script.
-- @param player_name The player's Name#0000.
-- @param reason A ban reason visible only to the room admins.
function ban.ShadowBanPlayer(player_name, reason)
	local player = player_list[player_name]
	shadow_banned_players[player_name] = player
	player.kicked = false
	player.banned = false
	player.shadow_banned = true
	player.shadow_ban_score = tfm.get.room.playerList[player_name].score
	player.ban_reason = reason or "reason not provided"
	-- simulate the player's death
	if ban.shadowban_simulate_death then
		pass_next_event_player_died = true
		eventPlayerDied(player_name)
	end
	return true, string.format("%s script shadowbanned (%s)", player_name, player.ban_reason)
end



--- Unban a player
function ban.UnbanPlayer(player_name)
	local player = player_list[player_name]
	if not player then
		return false, "This player does not exist."
	end
	if not player.kicked and not player.banned and not player.shadow_banned then
		return false, "This player is not banned."
	end
	banned_players[player_name] = nil
	shadow_banned_players[player_name] = nil
	player.kicked = false
	player.banned = false
	player.shadow_banned = false
	ui.removeTextArea(ban_mask_ui_id, player_name)
	return true, string.format("Unbanned %s.", player_name)
end



__MODULE__.commands = {
	["kick"] = {
		perms = "admins",
		desc = "'Kick' a player from the script (they need to rejoin).",
		no_user = true,
		argc_min = 1,
		argc_max = 1,
		arg_types = {"player"},
		func = ban.KickPlayer
	},
	["ban"] = {
		perms = "admins",
		desc = "'ban' a player from the script.",
		no_user = true,
		argc_min = 1,
		argc_max = 1,
		arg_types = {"player"},
		func = ban.BanPlayer
	},
	["shadowban"] = {
		perms = "admins",
		desc = "Disable most of the script's features for this player.",
		no_user = true,
		argc_min = 1,
		argc_max = 1,
		arg_types = {"player"},
		func = ban.ShadowBanPlayer
	},
	["unban"] = {
		perms = "admins",
		desc = "Unban a player from the room.",
		no_user = true,
		argc_min = 1,
		argc_max = 1,
		arg_types = {"string"},
		func = ban.UnbanPlayer
	},
	["banlist"] = {
		perms = "admins",
		desc = "See the bans list.",
		argc_min = 0,
		argc_max = 0,
		arg_types = {},
		func = function(user)
			tfm.exec.chatMessage("<r><b>SCRIPT-BANNED PLAYERS:</b></r>", user)
			for player_name, player in pairs(player_list) do
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
	}
}



--- TFM event eventNewPlayer.
-- Apply ban effects on banned players who rejoined.
function eventNewPlayer(player_name)
	if banned_players[player_name] then
        ApplyBanEffects(player_name)
    end
end



--- TFM event eventPlayerLeft.
-- Remove the ban for kicked players.
function eventPlayerLeft(player_name)
	local player = banned_players[player_name]
	if player and player.kicked then
		banned_players[player_name] = nil
	    player.kicked = false
	    player.banned = false
    end
end



--- TFM event eventNewGame.
-- Apply the ban effects on banned players.
function eventNewGame()
	for player_name in pairs(banned_players) do
		if tfm.get.room.playerList[player_name] then
		    ApplyBanEffects(player_name)
		end
    end
    for player_name in pairs(shadow_banned_players) do
    	if tfm.get.room.playerList[player_name] then
    		if not banned_players[player_name] then
		   		pass_next_event_player_died = true
				eventPlayerDied(player_name)
			end
		end
    end
end



function eventPlayerDied(player_name)
	-- ignore shadowbanned player's win
	local player = player_list[player_name]
	if (player.shadow_banned and ban.shadowban_simulate_death) or player.banned then
		if pass_next_event_player_died then
			pass_next_event_player_died = false
			return
		end
        return false
    end
    -- make shadowbanneds dead (cause ban to function on Floor Is Random)
    if ban.shadowban_simulate_death then
		for player_name in pairs(shadow_banned_players) do
			if tfm.get.room.playerList[player_name] then
		    	tfm.get.room.playerList[player_name].isDead = true
		    end
		end
    end
end



--- TFM event eventPlayerRespawn.
-- Apply the ban effects on banned players who respawn.
function eventPlayerRespawn(player_name)
	if banned_players[player_name] then
        ApplyBanEffects(player_name)
    elseif ban.shadowban_simulate_death and shadow_banned_players[player_name] then
        tfm.exec.killPlayer(player_name)
    end
end



--- TFM event eventChatCommand.
-- Return false for banned players to hope that the command processing will be canceled.
function eventChatCommand(player_name, message)
    if banned_players[player_name] then
        return false
    end
end



--- TFM event eventPlayerWon.
-- Cancel this event for shadow_banned players.
-- Also override the player's score in `tfm.get.room.playerList`.
function eventPlayerWon(player_name)
	if player_list[player_name].shadow_banned and ban.shadowban_abort_winning then
		local player = player_list[player_name]
		player.won = false
		tfm.exec.setPlayerScore(player_name, player.shadow_ban_score, false)
		tfm.get.room.playerList[player_name].score = player.shadow_ban_score
        return false
    end
end



--- TFM event eventPlayerGetCheese.
-- Cancel this event for shadow_banned players.
function eventPlayerGetCheese(player_name)
	if player_list[player_name].shadow_banned then
        return false
    end
end



function eventPlayerBonusGrabbed(player_name)
	if shadow_banned_players[player_name] then
		return false
	end
end



return ban
