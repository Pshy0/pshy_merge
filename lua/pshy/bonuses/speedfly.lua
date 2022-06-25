--- pshy.bonuses.speedfly
--
-- Bonuses using the speedfly module.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local speedfly = pshy.require("pshy.bases.speedfly")
local bonuses = pshy.require("pshy.bonuses")
pshy.require("pshy.events")
pshy.require("pshy.images.list.bonuses")



--- BonusFly.
function bonuses.callback_BonusFly(player_name, bonus)
	speedfly.Fly(player_name, 50)
end
bonuses.types["BonusFly"] = {image = "17bf4b7250e.png", func = bonuses.callback_BonusFly}



--- BonusHighSpeed.
function bonuses.callback_BonusHighSpeed(player_name, bonus)
	speedfly.Speed(player_name, 200)
end
bonuses.types["BonusHighSpeed"] = {image = "17bf4b9af56.png", func = bonuses.callback_BonusHighSpeed}
