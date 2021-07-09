--- pshy_antihack.lua
--
-- Countermesures to common hacks:
--	- summoning while not a shaman
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_ban.lua
-- @require pshy_help.lua
-- @require pshy_merge.lua
pshy = pshy or {}



--- Module Help Page:
pshy.help_pages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"] or {back = "pshy", restricted = true, text = "", commands = {}, subpages = {}}
pshy.help_pages["pshy"].subpages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"]
pshy.help_pages["pshy_antihack"] = {back = "pshy", restricted = true, text = "Countermeasures to common hacks.\n", examples = {}}
pshy.help_pages["pshy_antihack"].commands = {}
pshy.help_pages["pshy_antihack"].examples["luaset pshy.antihack_autoban false"] = "disable autoban of hacks"
pshy.help_pages["pshy_antihack"].examples["luaset pshy.antihack_autoban true"] = "enable autoban of hacks"
pshy.help_pages["pshy_antihack"].examples["luaset pshy.antihack_delay 4"] = "wait 4 hacks before banning"
pshy.help_pages["pshy_anticheats"].subpages["pshy_antihack"] = pshy.help_pages["pshy_antihack"]



--- Module Settings:
pshy.antihack_autoban = true		-- ban detected hacks
pshy.antihack_delay = 8		-- count of hacks before banning (fake an unprotected room)
pshy.antihack_round_delay = 3000	-- time before some detections start



--- Internal Use:
pshy.antihack_hack_counter = {}
pshy.antihack_detection_started = false
pshy.antihack_just_died = {}



--- A player have hacked.
-- This bans the player if they hack too much.
function pshy.AntihackPlayerHacked(player_name)
	if not pshy.antihack_hack_counter[player_name] then
		pshy.antihack_hack_counter[player_name] = 0
	end
	if pshy.antihack_autoban and pshy.antihack_hack_counter[player_name] == pshy.antihack_delay then
		pshy.BanPlayer(player_name)
		pshy.Log("<r>[AntiHack] " .. player_name .. " room banned!</r>")
		return true
	end
	pshy.antihack_hack_counter[player_name] = pshy.antihack_hack_counter[player_name] + 1
	return false
end



--- TFM event eventNewGame
function eventNewGame()
	pshy.antihack_detection_started = false
end



--- TFM event eventPlayerDied
function eventPlayerDied(player_name)
	pshy.antihack_just_died[player_name] = true
end



--- TFM event eventLoop
function eventLoop(time, time_remaining)
	if not pshy.antihack_detection_started and time > pshy.antihack_round_delay then
		pshy.antihack_detection_started = true
	end
	pshy.antihack_just_died = {}
end



--- TFM event eventSummoningEnd
function eventSummoningEnd(player_name, object_type, x, y, angle, object_data)
	if not pshy.antihack_detection_started then
		return
	end
	if pshy.antihack_just_died[player_name] then
		-- bubbles
		return
	end
	local tfm_player = tfm.get.room.playerList[player_name]
	if not tfm_player.isShaman then
		pshy.Log("<r>[AntiHack] " .. player_name .. " summoned while not shaman (SummoningEnd, possible bug, sy==" .. tfm.exec.getPlayerSync() .. ")!</r>")
		--pshy.AntihackPlayerHacked(player_name)
	end
end



--- TFM event eventSummoningStart
function eventSummoningStart(player_name, object_type, x, y, angle)
	if not pshy.antihack_detection_started then
		return
	end
	local tfm_player = tfm.get.room.playerList[player_name]
	if not tfm_player.isShaman then
		pshy.Log("<r>[AntiHack] " .. player_name .. " possibly hacking (SummoningStart)!</r>")
		pshy.AntihackPlayerHacked(player_name)
	end
end
