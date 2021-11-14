--- pshy_bonuses_mapext.lua
--
-- Allow maps to contain custom bonuses in the form of 
-- custom foreground invisible and non-colliding circle ground.
--
-- @require pshy_mapdb.lua
-- @require pshy_bonus_luamaps.lua
-- @require pshy_bonuses.lua
-- @require pshy_mapinfo.lua
-- @require pshy_newgame.lua



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
round_bonuses["00F000"]		= "BonusTeleporter"
round_bonuses["00F001"]		= "Teleporter"			-- sprite may change, shared lasting bonus
round_bonuses["F05040"]		= "BonusCircle"
round_bonuses["F08080"]		= "BonusMarry"
round_bonuses["F08081"]		= "BonusDivorce"
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
			print("WARNING: bonus had no color")
			return
		end
		local bonus_x = ground.x
		local bonus_y = ground.y
		local bonus_type = round_bonuses[bonus_color]
		if bonus_type then
			pshy.bonuses_Add(bonus_type, bonus_x, bonus_y)
		else
			print(string.format("WARNING: not recognized bonus with color %s", bonus_color))
		end
	end
end



function eventNewGame()
	assert(pshy.mapinfo, "pshy.mapinfo wasnt defined")
	if (pshy.mapinfo.grounds == nil) then
		print("WARNING: pshy.mapinfo.grounds was nil")
		return
	end
	for i_ground, ground in ipairs(pshy.mapinfo.grounds) do
		CheckGround(ground)
	end
end



function eventInit()
	if __IS_MAIN_MODULE__ then
		pshy.newgame_ChatCommandRotc(nil, "luamaps_bonuses_ext")
		tfm.exec.newGame()
	end
end
