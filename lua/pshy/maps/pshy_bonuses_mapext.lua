--- pshy_bonuses_mapext.lua
--
-- Allow maps to contain custom bonuses in the form of 
-- custom foreground invisible and non-colliding circle ground.
--
-- @require pshy_bonuses.lua
-- @require pshy_mapdb.lua
-- @require pshy_mapinfo.lua
-- @require pshy_newgame.lua
-- @require pshy_print.lua
--
-- @require_priority UTILS



--- Bonuses Bindings:
-- from pshy_basic_bonuses.lua
local round_bonuses			= {}
round_bonuses["F00000"]		= "BonusShrink"
round_bonuses["0000F0"]		= "BonusGrow"
round_bonuses["008080"]		= "BonusAttachBalloon"
round_bonuses["F0F0F0"]		= "BonusFly"
round_bonuses["F04040"]		= "BonusHighSpeed"
round_bonuses["F080F0"]		= "BonusShaman"
round_bonuses["804020"]		= "BonusTransformations"
round_bonuses["8080F0"]		= "BonusFreeze"
round_bonuses["4040F0"]		= "BonusIce"
round_bonuses["101010"]		= "BonusStrange"
round_bonuses["F0F000"]		= "BonusCheese"
round_bonuses["E0E0E0"]		= "BonusCheckpoint"
round_bonuses["E0E0E1"]		= "BonusSpawnpoint"
round_bonuses["00F000"]		= "BonusTeleporter"
round_bonuses["00F001"]		= "Teleporter"			-- sprite may change, shared lasting bonus
round_bonuses["F05040"]		= "BonusCircle"
round_bonuses["F08080"]		= "BonusMarry"
round_bonuses["F08081"]		= "BonusDivorce"
round_bonuses["202020"]		= "BonusCannonball"
round_bonuses["F06000"]		= "BonusFish"
round_bonuses["E04040"]		= "BonusDeath"
-- from pshy_misc_bonuses.lua
round_bonuses["805040"]		= "MouseTrap"
round_bonuses["E00000"]		= "GoreDeath"			-- shouldnt be used
round_bonuses["D0D000"]		= "PickableCheese"
round_bonuses["D0F000"]		= "CorrectCheese"
round_bonuses["F0D000"]		= "WrongCheese"
-- from pshy_mario_bonuses.lua
round_bonuses["4d6101"]		= "MarioCoin"
round_bonuses["4d6102"]		= "MarioMushroom"		-- not working yet
round_bonuses["4d6103"]		= "MarioFlower"
round_bonuses["4d6104"]		= "MarioCheckpoint"		-- not working yet



--- Check a ground.
-- @param ground Ground table from `pshy.mapinfo.grounds`.
local function CheckGround(ground)
	if ground.type == 13 and ground.width == 10 and ground.collisions == 4 and ground.invisible == true then --  and ground.foreground == true ?
		local bonus_color = ground.color
		if not bonus_color then
			print_warn("bonus had no color")
			return
		end
		local bonus_x = ground.x
		local bonus_y = ground.y
		local bonus_type = round_bonuses[string.upper(bonus_color)]
		if bonus_type then
			local bonus_id = pshy.bonuses_Add(bonus_type, bonus_x, bonus_y, true, ground.rotation or 0)
		else
			print_warn("not recognized bonus with color %s", bonus_color)
		end
	end
end



function eventNewGame()
	assert(pshy.mapinfo, "pshy.mapinfo wasnt defined")
	if (pshy.mapinfo.grounds == nil) then
		print_warn("pshy.mapinfo.grounds was nil")
		return
	end
	for i_ground, ground in ipairs(pshy.mapinfo.grounds) do
		CheckGround(ground)
	end
end



function eventInit()
	if __IS_MAIN_MODULE__ then
		pshy.newgame_ChatCommandRotc(nil, "luamaps_bonuses")
		tfm.exec.newGame()
	end
end
