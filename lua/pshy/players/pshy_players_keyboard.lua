--- pshy_players_keyboard.lua
--
-- Extends `pshy.players` with features using the `eventKeyboard` event.
--
-- Adds the folowing fields:
-- - `is_facing_right`: Is the player facing right.
--
-- Adds the folowing events:
-- - `eventPlayerDirectionChanged(player_name, is_facing_right)`
-- - `eventPlayerJumpKey(player_name)`
-- - `eventPlayerCrouchKey(player_name)`
-- - `eventPlayerMeepKey(player_name)`
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_merge.lua
-- @require pshy_players.lua
--
-- @require_priority WRAPPER



--- Internal Use:
local players = pshy.players			-- optimization



--- Tell the script that a player exist.
local function TouchPlayer(player_name)
	-- direction
	players[player_name].is_facing_right = true
	system.bindKeyboard(player_name, 0, true, true)
	system.bindKeyboard(player_name, 2, true, true)
end



function eventPlayerRespawn(player_name)
	-- direction
	players[player_name].is_facing_right = true
end



function eventKeyboard(player_name, keycode, down, x, y)
	local player = players[player_name]
	if down then
		-- direction
		if keycode == 0 then
			if player.is_facing_right ~= false then
				player.is_facing_right = false
				if eventPlayerDirectionChanged then
					eventPlayerDirectionChanged(player_name, false)
				end
			end
		elseif keycode == 2 then
			if player.is_facing_right ~= true then
				player.is_facing_right = true
				if eventPlayerDirectionChanged then
					eventPlayerDirectionChanged(player_name, true)
				end
			end
		-- eventPlayerJumpKey
		--elseif keycode == 1 then
		--	if eventPlayerJumpKey then
		--		eventPlayerJumpKey(player_name)
		--	end
		-- eventPlayerCrouchKey
		--elseif keycode == 3 then
		--	if eventPlayerCrouchKey then
		--		eventPlayerCrouchKey(player_name)
		--	end
		-- eventPlayerMeepKey
		--elseif keycode == 32 then
		--	if eventPlayerMeepKey then
		--		eventPlayerMeepKey(player_name)
		--	end
		--end
	end
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
end



function eventNewGame()
	for player_name in pairs(tfm.get.room.playerList) do
		-- direction
		players[player_name].is_facing_right = true
	end
end



function eventInit()
	for player_name in pairs(tfm.get.room.playerList) do
		TouchPlayer(player_name)
	end
end
