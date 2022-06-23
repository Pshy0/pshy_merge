--- pshy.tools.commentator
--
-- Made for racing, a bot commenting the game.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")



--- Namespace.
local commentator = {}



--- Module Settings:
commentator.prefix = "<vi>[Commentator]</vi>"



--- Internal use:
local counter_timers = {}
local first = true



--- `tfm.exec.newGame` override.
local original_NewGame = tfm.exec.newGame
local function NewGame(...)
	tfm.exec.chatMessage(string.format("%s <n>Changing map...", commentator.prefix))
	original_NewGame(...)
end
tfm.exec.newGame = NewGame



--- Callback for new game counter timers.
local function CounterTimerCallback(timer_id, text, index)
	tfm.exec.chatMessage(text)
	counter_timers[index] = nil
end



function eventNewGame()
	tfm.exec.chatMessage(string.format("%s 3<n>...", commentator.prefix))
	for i_timer, id in ipairs(counter_timers) do
		system.removeTimer(id)
	end
	counter_timers = {}
	counter_timers[3] = system.newTimer(CounterTimerCallback, 1000, false, string.format("%s 2<n>...", commentator.prefix), 3)
	counter_timers[2] = system.newTimer(CounterTimerCallback, 2000, false, string.format("%s 1<n>...", commentator.prefix), 2)
	counter_timers[1] = system.newTimer(CounterTimerCallback, 3000, false, string.format("%s <n>Go!", commentator.prefix), 1)
	first = false
end



function eventPlayerWon(player_name, time_elapsed)
	if not first then
		tfm.exec.chatMessage(string.format("%s <n>Congratulations to <vi>%s</vi> with a time of <vi>%fs</vi>!", commentator.prefix, player_name, time_elapsed / 100))
	end
	first = true
end



return commentator
