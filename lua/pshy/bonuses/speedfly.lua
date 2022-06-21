--- pshy.bonuses.speedfly
--
-- Bonuses using the speedfly module.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.bases.speedfly")
pshy.require("pshy.bonuses")
pshy.require("pshy.events")
pshy.require("pshy.images.bonuses")



--- BonusFly.
function pshy.bonuses_callback_BonusFly(player_name, bonus)
	pshy.speedfly_Fly(player_name, 50)
end
pshy.bonuses_types["BonusFly"] = {image = "17bf4b7250e.png", func = pshy.bonuses_callback_BonusFly}



--- BonusHighSpeed.
function pshy.bonuses_callback_BonusHighSpeed(player_name, bonus)
	pshy.speedfly_Speed(player_name, 200)
end
pshy.bonuses_types["BonusHighSpeed"] = {image = "17bf4b9af56.png", func = pshy.bonuses_callback_BonusHighSpeed}
