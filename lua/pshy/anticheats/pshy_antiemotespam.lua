--- pshy_antiemotespam.lua
--
-- Countermesures to emote spam.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_adminchat.lua
-- @require pshy_anticheats_common.lua
-- @require pshy_ban.lua
-- @require pshy_funcorponly.lua
-- @require pshy_help.lua
-- @require pshy_merge.lua
-- @require pshy_perms.lua
-- @require pshy_players.lua
--
-- @require_priority ANTICHEAT
pshy = pshy or {}



--- Module Settings:
pshy.antiemotespam_max_emotes_per_game = nil



--- Internal use:
local pshy_players = pshy.players
local pshy_players_in_room = pshy.players_in_room



local function TouchPlayer(player_name)
	local player = pshy_players[player_name]
	player.loop_emote_count = 0
	player.emote_count = 0
	player.emote_count_start_time = os.time()
	player.emote_count_last_time = player.emote_count_start_time
end



function eventEmotePlayed(player_name)
	tfm.exec.chatMessage("emote", player_name)
	local player = pshy_players[player_name]
	player.loop_emote_count = player.loop_emote_count + 1
	if player.loop_emote_count == 4 then
		pshy.ban_BanPlayer(player_name, "Emote spam (4/500ms)")
		pshy.adminchat_Message("Anticheat", string.format("%s room banned (Emote spam (4/500ms))!", player_name))
		return false
	end
	if pshy.antiemotespam_max_emotes_per_game then
		player.emote_count = player.emote_count + 1
		if player.emote_count >= pshy.antiemotespam_max_emotes_per_game and not player.antiemotespam_killed then
			tfm.exec.killPlayer(player_name)
			player.antiemotespam_killed = true
		end
	else
		local os_time = os.time()
		if os_time - player.emote_count_last_time > 2000 or not player.emote_count_start_time or os_time - player.emote_count_start_time > 8000 then
			-- punish
			if player.emote_count >= 12 then
				player.emote_count = player.emote_count + 1
				pshy.ban_BanPlayer(player_name, "Emote spam (%d/8s)", player.emote_count)
				pshy.adminchat_Message("Anticheat", string.format("%s room banned (Emote spam (%d/8s))!", player_name, player.emote_count))
			end
			-- reset
			player.emote_count = 1
			player.emote_count_start_time = os_time
		elseif player.emote_count == 7 and os_time - player.emote_count_start_time < 5000 then
			player.emote_count = player.emote_count + 1
			tfm.exec.killPlayer(player_name)
			tfm.exec.chatMessage("<r>Please avoid spamming emotes.</r>", player_name)
		else
			player.emote_count = player.emote_count + 1
		end
		player.emote_count_last_time = os_time
	end
end



function eventLoop()
	for player_name, player in pairs(pshy_players_in_room) do
		player.loop_emote_count = 0
	end
end



function eventNewGame()
	if pshy.antiemotespam_max_emotes_per_game then
		for player_name, player in pairs(pshy_players_in_room) do
			player.emote_count = 0
			player.antiemotespam_killed = false
		end
	end
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
end



function eventInit()
	for player_name in pairs(tfm.get.room.playerList) do
		TouchPlayer(player_name)
	end
end
