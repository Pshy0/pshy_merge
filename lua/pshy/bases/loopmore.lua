--- pshy.bases.loopmore
--
-- Triggers an event `eventLoopMore` with higger frequency than the default `eventLoop`.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")



--- Namespace.
local loopmore = {}



--- Module Settings:
loopmore.call_standard_loop = false			-- if true, call `eventLoop` on `eventLoopOften`
loopmore.down_keys = {0, 1, 2, 3}				-- keys to listen to when pressed (used to trigger events, not needed if you bind these yourself)
loopmore.up_keys = {0, 2}						-- keys to listen to when released (used to trigger events, not needed if you bind these yourself)



--- Internal use:
local interval = nil						-- interval between calls to `eventLoopMore`
local tfm_timers_interval = nil				-- chosen interval for timers
local map_start_os_time = nil				-- map start os time
local map_end_os_time = nil					-- expected map end os time
local last_loopmore_os_time = os.time()		-- last time of last loopmore loop
local anticipated_skips = 0					-- @todo used to skip event when there is too many, avoiding calls to os.time()
local timers = {}							-- store timers and timers sync



--- Trigger an `eventLoopMore`.
local function RunLoopMore()
	-- skip initial times (information missing)
	if not map_start_os_time or not map_end_os_time then
		return
	end
	-- ok, loop
	local os_time = os.time()
	eventLoopMore(os_time - map_start_os_time, map_end_os_time - os_time)
	--if last_loopmore_os_time then
	--	print("duration: " .. tostring(os_time - last_loopmore_os_time))
	--end
	last_loopmore_os_time = os_time
end



--- Timer callback
local function TimerCallback(tfmid, id)
	local timer = timers[id]
	--print("timer #" .. tostring(id) .. "/" .. tostring(#timers) .. ": " .. tostring(os.time() % 10000))
	assert(timer ~= nil, "timer #" .. tostring(id) .. "/" .. tostring(#timers) .. ": " .. tostring(os.time() % 10000))
	--timer.sync_time = os.time() % tfm_timers_interval
	RunLoopMore()
end



--- Callback supposed to create the initial timers with different sync times.
-- When this function is called, the timer is recreated to loop in constent time.
local function InitTimerCallback(tid, i_timer)
	local timer = timers[i_timer]
	assert(timer.id ~= nil)
	system.removeTimer(timer.id)
	timer.id = system.newTimer(TimerCallback, tfm_timers_interval, true, i_timer)
end



--- Set the loop_more interval.
-- @public
-- @param interval New loop interval (have limitations).
function loopmore.SetInterval(interval)
	assert(type(interval) == "number")
	assert(interval >= 50)
	assert(interval <= 250)
	interval = interval
	-- destroy timers
	for i_timer, timer in ipairs(timers) do
		system.removeTimer(timer.id)
	end
	timers = {}
	-- choose tfm timers intervals and count
	local tfm_interval = interval
	while tfm_interval < 500 do
		tfm_interval = tfm_interval + interval
	end
	tfm_timers_interval = tfm_interval
	local timer_count = tfm_interval / interval
	assert(timer_count >= 1)
	assert(timer_count <= 10)
	-- make place for new timers
	for i_timer = 1, timer_count do
		timers[i_timer] = {}
		local timer = timers[i_timer]
		timer.sync_time = interval * (i_timer - 1)
		timer.id = system.newTimer(InitTimerCallback, tfm_timers_interval + timer.sync_time, false, i_timer)
		timer.i_timer = i_timer
	end
end




--- Pshy event eventLoopMore.
function eventLoopMore(time, time_remaining)
	if loopmore.call_standard_loop and eventLoop then
		eventLoop(time, time_remaining)
	end
end



--- TFM event eventNewGame()
function eventNewGame()
	map_start_os_time = os.time()
	map_end_os_time = nil
	anticipated_skips = 0
end



--- TFM event eventLoop()
function eventLoop(time, time_remaining)
	local os_time = os.time()
	-- eventLoop can also be used to update our information
	map_start_os_time = os_time - time
	map_end_os_time = os_time + time_remaining
	--loopmore.Check()
end



--- Override of `tfm.exec.setGameTime`.
function loopmore.setGameTime(time_remaining, init)
	local os_time = os.time()
	if init then
		map_end_os_time = os_time + time_remaining
	elseif map_end_os_time and time_remaining < (map_end_os_time - os_time) then
		map_end_os_time = os_time + time_remaining
	end
	loopmore.original_setGameTime(time_remaining, init)
end
loopmore.original_setGameTime = tfm.exec.setGameTime
tfm.exec.setGameTime = loopmore.setGameTime



--- Initialization:
loopmore.SetInterval(250)



return loopmore
