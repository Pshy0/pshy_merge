--- pshy.tools.echo_scores
--
-- Includes several scripts adding basic features for room admins.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")



function eventPlayerWon(player_name, time, time_since_respawn)
	local msg = string.format("<vp><v>%s</v> completed the map after <ch>%f</ch> seconds.</vp>", player_name, time/100)
	tfm.exec.chatMessage(msg, nil)
	print(msg)
end
