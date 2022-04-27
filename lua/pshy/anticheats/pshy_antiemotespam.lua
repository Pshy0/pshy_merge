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
	player.game_emote_count = 0
end



function eventEmotePlayed(player_name)
	local player = pshy_players[player_name]
	player.loop_emote_count = player.loop_emote_count + 1
	player.game_emote_count = player.game_emote_count + 1
	if player.loop_emote_count > 3 then
		pshy.ban_BanPlayer(player_name, "Emote spam (>3/500ms)")
		pshy.adminchat_Message("Anticheat", string.format("%s room banned (Emote spam (>4/500ms))!", player_name))
		return false
	end
end



function eventLoop()
	for player_name, player in pairs(pshy_players_in_room) do
		player.loop_emote_count = 0
		if pshy.antiemotespam_max_emotes_per_game and player.game_emote_count >= pshy.antiemotespam_max_emotes_per_game then
			tfm.exec.killPlayer(player_name)
		end
	end
end



function eventNewGame()
	for player_name, player in pairs(pshy_players_in_room) do
		player.game_emote_count = 0
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
