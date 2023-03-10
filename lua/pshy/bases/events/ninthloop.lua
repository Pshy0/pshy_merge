--- pshy.bases.events.ninthloop
--
-- Adds an event: `eventNinthLoop(time_elapsed, time_remaining)`.
-- Some expensive computations may be done on new game event.
-- Waiting a runtime measure may be a way to avoid running out.
-- This event is just about that, and also not executing if remaining time is too low.
--
-- @author DC:Pshy#7998 TFM:Pshy#3752
pshy.require("pshy.events")



local i_loop = 0



function eventNewGame()
	i_loop = 0
end



function eventLoop(elapsed, remaining)
	if i_loop < 9 then
		i_loop = i_loop + 1
		if i_loop == 9 and remaining > 4200 then
			if eventNinthLoop then
				eventNinthLoop(elapsed, remaining)
			end
		end
	end
end
