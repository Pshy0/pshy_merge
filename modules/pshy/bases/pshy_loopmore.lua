--- pshy_loopmore.lua
--
-- Triggers an event `eventLoopMore` with higger frequency than the default `eventLoop`.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
pshy = pshy or {}



--- Module Settings:
pshy.loopmore_call_standard_loop = false			-- if true, call `eventLoop` on `eventLoopOften`
pshy.loopmore_minimum_interval = 20					-- minimum intervals between calls to `eventLoopMore`
pshy.accuracy_down_keys = {0, 1, 2, 3}				-- keys to listen to when pressed (used to trigger events, not needed if you bind these yourself)
pshy.accuracy_up_keys = {0, 2}						-- keys to listen to when released (used to trigger events, not needed if you bind these yourself)



--- Internal use:
pshy.loopmore_map_start_os_time = nil				-- map start os time
pshy.loopmore_map_end_os_time = nil					-- expected map end os time
pshy.loopmore_last_loopmore_os_time = os.time()		-- last time of last loopmore loop
pshy.loopmore_anticipated_skips = 0					-- @todo used to skip event when there is too many, avoiding calls to os.time()



--- Pshy event eventLoopMore.
function eventLoopMore(time, time_remaining)
	if pshy.loopmore_call_standard_loop and eventLoop then
		eventLoop(time, time_remaining)
	end
end



--- Tells the module a player is in the room or just joined it.
-- @private
function pshy.loopmore_BindPlayerkeys(player_name)
	for i_key, key in ipairs(pshy.loopmore_down_keys) do
		tfm.exec.bindKeyboard(player_name, key, true, true)
	end
	for i_key, key in ipairs(pshy.loopmore_up_keys) do
		tfm.exec.bindKeyboard(player_name, key, false, true)
	end
end



--- Call this function on events to attempt to run `eventLoopMore`.
function pshy.loopmore_Check()
	-- pop an anticipated skip
	if pshy.loopmore_anticipated_skips > 0 then
		pshy.loopmore_anticipated_skips = pshy.loopmore_anticipated_skips - 1
		return
	end
	-- skip initial times (information missing)
	if not pshy.loopmore_map_start_os_time or not pshy.loopmore_map_end_os_time then
		return
	end
	-- check if enough time have passed
	local os_time = os.time()
	if (os_time - pshy.loopmore_last_loopmore_os_time) < pshy.loopmore_minimum_interval then
		return
	end
	-- ok, loop
	eventLoopMore(os_time - pshy.loopmore_map_start_os_time, pshy.loopmore_map_end_os_time - os_time)
	pshy.loopmore_last_loopmore_os_time = os_time
end



--- TFM event eventNewGame()
function eventNewGame()
	pshy.loopmore_map_start_os_time = os.time()
	pshy.loopmore_map_end_os_time = nil
	pshy.loopmore_anticipated_skips = 0
end



--- TFM event eventLoop()
function eventLoop(time, time_remaining)
	local os_time = os.time()
	-- eventLoop can also be used to update our information
	pshy.loopmore_map_start_os_time = os_time - time
	pshy.loopmore_map_end_os_time = os_time + time_remaining
	pshy.loopmore_Check()
end



--- TFM even eventKeyboard()
-- This event is likely to be called more often than others.
function eventkeyboard()
	pshy.loopmore_Check()
end



--- Override of `tfm.exec.setGameTime`.
function pshy.loopmore_setGameTime(time_remaining, init)
	local os_time = os.time()
	if init then
		pshy.loopmore_map_end_os_time = os_time + time_remaining
	elseif pshy.loopmore_map_end_os_time and time_remaining < (pshy.loopmore_map_end_os_time - os_time) then
		pshy.loopmore_map_end_os_time = os_time + time_remaining
	end
	pshy.loopmore_original_setGameTime(time_remaining, init)
end
pshy.loopmore_original_setGameTime = tfm.exec.setGameTime
tfm.exec.setGameTime = pshy.loopmore_setGameTime



--- TFM event eventNewPlayer.
function eventNewPlayer(player_name)
	pshy.loopmore_BindPlayerKeys(player_name)
end



--- Initialization:
for player_name in pairs(tfm.get.room.playerList) do
	pshy.loopmore_BindPlayerKeys(player_name)
end
