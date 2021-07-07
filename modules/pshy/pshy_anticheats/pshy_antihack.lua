--- pshy_antihack.lua
--
-- Countermesures to common hacks:
--	- summoning while not a shaman
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_ban.lua
-- @require pshy_help
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



--- Internal Use:
pshy.antihack_hack_counter = {}



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



--- TFM event eventSummoningEnd
function eventSummoningEnd(player_name, object_type, x, y, angle, object_data)
	local tfm_player = tfm.get.room.playerList[player_name]
	if not tfm_player.isShaman then
		pshy.Log("<r>[AntiHack] " .. player_name .. " possibly hacking (SummoningEnd)!</r>")
		pshy.AntihackPlayerHacked(player_name)
	end
end



--- TFM event eventSummoningStart
function eventSummoningStart(player_name, object_type, x, y, angle)
	local tfm_player = tfm.get.room.playerList[player_name]
	if not tfm_player.isShaman then
		pshy.Log("<r>[AntiHack] " .. player_name .. " possibly hacking (SummoningStart)!</r>")
		pshy.AntihackPlayerHacked(player_name)
	end
end
