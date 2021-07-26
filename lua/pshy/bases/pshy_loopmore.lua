--- pshy_loopmore.lua
--
-- Triggers an event `eventLoopMore` with higger frequency than the default `eventLoop`.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
pshy = pshy or {}



--- Module Settings:
pshy.loopmore_call_standard_loop = false			-- if true, call `eventLoop` on `eventLoopOften`
pshy.loopmore_down_keys = {0, 1, 2, 3}				-- keys to listen to when pressed (used to trigger events, not needed if you bind these yourself)
pshy.loopmore_up_keys = {0, 2}						-- keys to listen to when released (used to trigger events, not needed if you bind these yourself)



--- Internal use:
pshy.loopmore_interval = nil						-- interval between calls to `eventLoopMore`
pshy.loopmore_tfm_timers_interval = nil				-- chosen interval for timers
pshy.loopmore_map_start_os_time = nil				-- map start os time
pshy.loopmore_map_end_os_time = nil					-- expected map end os time
pshy.loopmore_last_loopmore_os_time = os.time()		-- last time of last loopmore loop
pshy.loopmore_anticipated_skips = 0					-- @todo used to skip event when there is too many, avoiding calls to os.time()
pshy.loopmore_missing_time = 0						-- as loops may not be 100% accurate, store what time is missing
pshy.loopmore_missed_loops_to_recover = 1.0			-- how many missed loops to recover
pshy.loopmore_timers = {}							-- store timers and timers sync

--system.newTimer ( callback, time, loop, arg1, arg2, arg3, arg4 )

--- Set the loop_more interval.
-- @public
-- @param interval New loop interval (have limitations).
function pshy.loopmore_SetInterval(interval)
	assert(type(interval) == "number")
	assert(interval >= 100)
	assert(interval <= 500)
	pshy.loopmore_interval = interval
	-- destroy timers
	for i_timer, timer in ipairs(pshy.loopmore_timers) do
		system.removeTimer(timer.id)
	end
	pshy.loopmore_timers = {}
	-- choose tfm timers intervals and count
	local tfm_interval = interval
	while tfm_interval < 1000 do
		tfm_interval = tfm_interval + interval
	end
	pshy.loopmore_tfm_timers_interval = tfm_interval
	local timer_count = tfm_interval / interval
	assert(timer_count >= 1)
	assert(timer_count <= 10)
	-- make place for new timers
	for i_timer = 1, timer_count do
		pshy.loopmore_timers[i_timer] = {}
		pshy.loopmore_timers[i_timer].id = nil
		pshy.loopmore_timers[i_timer].i_timer = i_timer
		pshy.loopmore_timers[i_timer].wished_time = interval * (i_timer - 1)
	end
end



--- Pshy event eventLoopMore.
function eventLoopMore(time, time_remaining)
	if pshy.loopmore_call_standard_loop and eventLoop then
		eventLoop(time, time_remaining)
	end
end



--- Tells the module a player is in the room or just joined it.
-- @private
function pshy.loopmore_BindPlayerKeys(player_name)
	for i_key, key in ipairs(pshy.loopmore_down_keys) do
		tfm.exec.bindKeyboard(player_name, key, true, true)
	end
	for i_key, key in ipairs(pshy.loopmore_up_keys) do
		tfm.exec.bindKeyboard(player_name, key, false, true)
	end
end



--- Trigger an `eventLoopMore`.
function pshy.loopmore_RunLoopMore()
	-- skip initial times (information missing)
	if not pshy.loopmore_map_start_os_time or not pshy.loopmore_map_end_os_time then
		return
	end
	-- ok, loop
	local os_time = os.time()
	eventLoopMore(os_time - pshy.loopmore_map_start_os_time, pshy.loopmore_map_end_os_time - os_time)
	pshy.loopmore_last_loopmore_os_time = os_time
end



--- Call on arbitrary event to make the timers more and more accurate.
function pshy.loopmore_ArbitraryEvent()
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
	local elapsed = (os_time - pshy.loopmore_last_loopmore_os_time) + pshy.loopmore_missing_time
	if elapsed < pshy.loopmore_interval then
		return
	end
	-- update missing time
	pshy.loopmore_missing_time = elapsed - pshy.loopmore_interval
	pshy.loopmore_missing_time = math.min(pshy.loopmore_missing_time, pshy.loopmore_interval * pshy.loopmore_missed_loops_to_recover)
	-- ok, loop
	eventLoopMore(os_time - pshy.loopmore_map_start_os_time, pshy.loopmore_map_end_os_time - os_time)
	pshy.loopmore_last_loopmore_os_time = os_time
	-- update timers
	local half_interval = (pshy.loopmore_interval / 2)
	local tick_time = os_time % pshy.loopmore_tfm_timers_interval - half_interval
	for i_timer = 1, #pshy.loopmore_timers do
		timer = pshy.loopmore_timers[i_timer]
		assert(timer ~= nil)
		if tick_time > timer.wished_time - half_interval and tick_time < timer.wished_time + half_interval then
			-- right timer found, updating if more accurate
			if not timer.sync_time or math.abs(tick_time - timer.wished_time) < math.abs(timer.sync_time - timer.wished_time) then
				-- more accurate, updating
				-- @todo should loop right there
				print("recreating timer #" .. tostring(i_timer) .. " from id " .. tostring(timer.id))
				if timer.sync_time then print(" old_accuracy: " .. tostring(timer.sync_time - timer.wished_time) .. " new accuracy: " .. tostring(tick_time - timer.wished_time)) end
				if timer.id then
					system.removeTimer(timer.id)
					timer.id = nil
				end
				timer.id = system.newTimer(pshy.loopmore_TimerCallback, pshy.loopmore_tfm_timers_interval, true, i_timer)
				timer.sync_time = tick_time
			end
		end
	end
end



--- Timer callback
function pshy.loopmore_TimerCallback(tfmid, id)
	local timer = pshy.loopmore_timers[id]
	print("timer #" .. tostring(id) .. "/" .. tostring(#pshy.loopmore_timers) .. ": " .. tostring(os.time() % 10000))
	assert(timer ~= nil, "timer #" .. tostring(id) .. "/" .. tostring(#pshy.loopmore_timers) .. ": " .. tostring(os.time() % 10000))
	--timer.sync_time = os.time() % pshy.loopmore_tfm_timers_interval
	pshy.loopmore_Check()
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
function eventKeyboard()
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
pshy.loopmore_SetInterval(250)
