--- pshy.debug.assert
--
-- Cause lua assert to provide more informations.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @preload
pshy = pshy or {}



--- Custom assert function.
function pshy.assert(condition, message)
	if not condition then
		local error_message = "\n<u><r>ASSERTION FAILED</r></u>"
		if message then
			error_message = error_message .. "\n<b><o>" .. message .. "</o></b>"
		end
		error_message = error_message .. "\n<i><j>" .. debug.traceback() .. "</j></i>"
		local room = pshy.require("pshy.room")
		if room.launcher then
			tfm.exec.chatMessage(error_message, room.launcher)
		end
		error(error_message)
	end
end
assert = pshy.assert
