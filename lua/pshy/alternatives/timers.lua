--- pshy.alternatives.timers
--
-- Adds timers for scripts ran in tribehouse.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
pshy.require("pshy.utils.print")
local room = pshy.require("pshy.room")



--- Namespace:
local alternative_timers = {}



--- Internal use:
local have_sync_access = room.is_funcorp
local timers = {}								-- replacement for game timers



--- Replacement for `system.addTimer`.
-- @todo Test this.
local function newTimer(callback, time, loop, arg1, arg2, arg3, arg4)
	-- params checks
	if time < 500 then
		print_error("newTimer: minimum time is 500 (you passed %d)!", time)
		return
	end
	-- find an id
	local timer_id = 1
	while timers[timer_id] do
		timer_id = timer_id + 1
	end
	-- create
	timers[timer_id] = {}
	timer = timers[timer_id]
	timer.timer_id = timer_id
	timer.callback = callback
	timer.time = time
	timer.loop = loop
	timer.arg1 = arg1
	timer.arg2 = arg2
	timer.arg3 = arg3
	timer.arg4 = arg4
	timer.next_run_time = os.time() + timer.time
	return timer_id
end



--- Replacement for `system.removeTimer`.
local function removeTimer(timer_id)
	if timer_id then
		timers[timer_id] = nil
	end
end



--- Run pending timers.
function alternative_timers.RunTimers()
	local time = os.time()
	if not have_sync_access then
		local ended_timers = {}
		local timers_copy = {}
		local timers_cnt = 0
		for i_timer, timer in pairs(timers) do
			timers_copy[i_timer] = timer
			timers_cnt = timers_cnt + 1
		end
		for i_timer, timer in pairs(timers_copy) do
			if timer.next_run_time < time then
				timer.callback(timer.timer_id, timer.arg1, timer.arg2, timer.arg3, timer.arg4)
				if timer.loop then
					timer.next_run_time = timer.next_run_time + timer.time -- math.min(, ..)
				else
					ended_timers[i_timer] = true
				end
			end
		end
		for i_ended_timer in pairs(ended_timers) do
			timers[i_ended_timer] = nil
		end
	end
end



if not have_sync_access then
	system.newTimer = newTimer
	system.removeTimer = removeTimer
	
	
	
	function eventLoop()
		alternative_timers.RunTimers()
	end
end



return alternative_timers
