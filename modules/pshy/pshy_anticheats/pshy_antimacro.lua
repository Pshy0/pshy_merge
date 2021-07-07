--- pshy_antimacro.lua
--
-- Penalize players pressing keys in a way that should not be humanly possible.
--
-- @author Pshy#3752
-- @namespace pshy
-- @require pshy_ban.lua
-- @require pshy_help
-- @require pshy_merge.lua
pshy = pshy or {}



--- Module settings.
pshy.antimacro_keys = {}		-- map of keys -> display name
--pshy.antimacro_keys[0] = "[&lt;]"	-- Left
pshy.antimacro_keys[1] = "[^]"	-- Up
--pshy.antimacro_keys[2] = "[&gt;]"	-- Right
pshy.antimacro_kps_limit_1 = 12	-- Acceptable key count per second for "up" (prefer 12)
pshy.antimacro_kps_limit_2 = 16	-- Acceptable key count per second for "up" (prefer 16)
-- for a loop every 500 ms, 12 kps means pressed 6 times in half a second



--- Module's help page.
pshy.help_pages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"] or {back = "pshy", restricted = true, text = "", commands = {}, subpages = {}}
pshy.help_pages["pshy"].subpages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"]
pshy.help_pages["pshy_antimacro"] = {back = "pshy", restricted = true, text = "Penalize players pressing keys in a way that should not be humanly possible.\n", examples = {}}
pshy.help_pages["pshy_antimacro"].commands = {}
pshy.help_pages["pshy_antimacro"].examples["luaset pshy.antimacro_kps_limit_1 15"] = "Set the macro warning sensitivity."
pshy.help_pages["pshy_antimacro"].examples["luaset pshy.antimacro_kps_limit_2 15"] = "Set the macro freezing sensitivity."
pshy.help_pages["pshy_anticheats"].subpages["pshy_antimacro"] = pshy.help_pages["pshy_antimacro"]



--- Internal use.
pshy.antimacro_players_ups = {}	-- Count of "up"
pshy.antimacro_last_time = 0		-- last loop time in ms
pshy.antimacro_frozen_players = {}	-- set of frozen players



--- Setup the current script to watch a player for macros.
function pshy.AntimacroWatchPlayer(player_name)
	--for key, void in pairs(pshy.antimacro_keys) do
	--	system.bindKeyboard(player_name, key, true, true)
	--end
	system.bindKeyboard(player_name, 1, true, true)
	pshy.antimacro_players_ups[player_name] = 0
end



--- TFM event eventNewGame()
function eventNewgame()
	--for key, void in pairs(pshy.antimacro_keys) do
	--	pshy.antimacro_players_ups[player_name] = 0
	--end
	for player_name, void in pairs(tfm.get.room.playerList) do
		pshy.antimacro_players_ups[player_name] = 0
	end
	pshy.antimacro_last_time = 0
	for player_name, void in pairs(pshy.antimacro_frozen_players) do
		pshy.AntimacroWatchPlayer(player_name)
	end
	pshy.antimacro_frozen_players = {}
end



--- TFM event eventLoop
function eventLoop(time, time_remaining)
	local elapsed_time = time - pshy.antimacro_last_time	-- in ms
	if elapset_time > 300 and elapsed_time < 700 then -- skip bad measures
		for player_name, count in pairs(pshy.antimacro_players_ups) do
			local rate = count / (elapsed_time / 1000.0) 	-- in k/s
			if not pshy.antimacro_frozen_players[player_name] then
				if rate > pshy.antimacro_kps_limit_2 and count > pshy.antimacro_kps_limit_2 / 2 then
					-- freeze
					tfm.exec.freezePlayer(player_name, true)
					pshy.antimacro_frozen_players[player_name] = true
					tfm.exec.chatMessage("<rose>[Macros]</rose> " .. player_name .. " Frozen because your key input is unlikely to be humanly possible :c", player_name)
					pshy.Log("<rose>[Macros]</rose> " .. player_name .. " Frozen (" .. tostring(rate) .. ")...", nil)
					system.bindKeyboard(player_name, 1, true, false)
				elseif rate > pshy.antimacro_kps_limit_1 then
					-- lag the player
					--tfm.exec.movePlayer(player_name, tfm.get.room.playerList[player_name].x, tfm.get.room.playerList[player_name].y, false, 0, 0, true)
					--tfm.exec.chatMessage("<rose>[Macros]</rose> " .. player_name .. " Hmmm...", player_name)
					pshy.Log("<rose>[Macros]</rose> " .. player_name .. " Hmmm (" .. tostring(rate) .. ")...", nil)
				end
			end
			pshy.antimacro_players_ups[player_name] = 0
		end
	end
	pshy.antimacro_last_time = time
end



--- TFM event eventKeyboard
function eventKeyboard(player_name, key_code, down, x, y)
	if key_code == 1 and down then -- [^]
		if pshy.antimacro_frozen_players[player_name] then
			return false
		end
		local ups = pshy.antimacro_players_ups[player_name]
		pshy.antimacro_players_ups[player_name] = ups + 1
	end
end



--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	pshy.AntimacroWatchPlayer(player_name)
end



--- Initialization.
for player_name, void in pairs(tfm.get.room.playerList) do
	pshy.AntimacroWatchPlayer(player_name)
end
