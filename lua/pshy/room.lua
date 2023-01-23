--- pshy.room
--
-- Provides basic room informations.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")



--- Namespace.
local room = {}



--- Module loader.
-- This is the person on who's account the script is running.
room.loader = string.match(({pcall(nil)})[2], "^(.-)%.")



--- Module launcher.
-- If there is only one player in the room then they are the launcher.
-- Otherwise the launcher will be set to the loader.
room.launcher = nil
for player_name in pairs(tfm.get.room.playerList) do
	if room.launcher then
		room.launcher = room.loader
		break
	end
	room.launcher = player_name
end



--- Is the room private.
room.is_private = string.sub(tfm.get.room.name, 1, 1) == "@"



--- Is the room a tribehouse.
room.is_tribehouse = tfm.get.room.isTribeHouse



--- Is the room in funcorp mode.
-- In fact this will only tell if some features are available.
room.is_funcorp = not room.is_tribehouse



return room
