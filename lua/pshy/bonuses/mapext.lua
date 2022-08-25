--- pshy.bonuses.mapext
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
local bonuses = pshy.require("pshy.bonuses")
local bonus_types = pshy.require("pshy.bonuses.list")
local map_list = pshy.require("pshy.maps.list")
local newgame = pshy.require("pshy.rotations.newgame")
pshy.require("pshy.bonuses.xmlext", false)



function eventNewGame()
	if newgame.current_settings.map and newgame.current_settings.map.bonuses then
		if bonuses then
			for i_bonus, bonus in ipairs(newgame.current_settings.map.bonuses) do
				bonuses.AddNoCopy(bonus)
			end
		end
	end
end
