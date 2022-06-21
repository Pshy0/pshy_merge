--- pshy.rotations.bonuses_mapext
--
-- Allow maps to contain custom bonuses in the form of 
-- custom foreground invisible and non-colliding circle ground.
pshy.require("pshy.bonuses")
pshy.require("pshy.events")
pshy.require("pshy.rotations.base")
pshy.require("pshy.rotations.mapinfo")
pshy.require("pshy.utils.print")



--- Bonuses Bindings:
-- from pshy_bonuses_basic.lua
pshy.bonuses_color_bindings = pshy.bonuses_color_bindings or {}
local round_bonuses			= pshy.bonuses_color_bindings
round_bonuses["F00000"]		= "BonusShrink"
round_bonuses["0000F0"]		= "BonusGrow"
round_bonuses["008080"]		= "BonusAttachBalloon"
round_bonuses["F080F0"]		= "BonusShaman"
round_bonuses["804020"]		= "BonusTransformations"
round_bonuses["8080F0"]		= "BonusFreeze"
round_bonuses["4040F0"]		= "BonusIce"
round_bonuses["101010"]		= "BonusStrange"
round_bonuses["F0F000"]		= "BonusCheese"
round_bonuses["00F000"]		= "BonusTeleporter"
round_bonuses["00F001"]		= "Teleporter"			-- sprite may change, shared lasting bonus
round_bonuses["F05040"]		= "BonusCircle"
round_bonuses["F08080"]		= "BonusMarry"
round_bonuses["F08081"]		= "BonusDivorce"
round_bonuses["202020"]		= "BonusCannonball"
round_bonuses["F06000"]		= "BonusFish"
round_bonuses["E04040"]		= "BonusDeath"
-- from pshy_bonuses_checkpoints.lua
round_bonuses["E0E0E0"]		= "BonusCheckpoint"
round_bonuses["E0E0E1"]		= "BonusSpawnpoint"
-- from pshy_bonuses_speedfly.lua
round_bonuses["F0F0F0"]		= "BonusFly"
round_bonuses["F04040"]		= "BonusHighSpeed"
-- from pshy_bonuses_misc.lua
round_bonuses["805040"]		= "MouseTrap"
round_bonuses["E00000"]		= "GoreDeath"			-- shouldnt be used
round_bonuses["D0D000"]		= "PickableCheese"
round_bonuses["D0F000"]		= "CorrectCheese"
round_bonuses["F0D000"]		= "WrongCheese"
-- from pshy_bonuses_mario.lua
round_bonuses["4D6101"]		= "MarioCoin"
round_bonuses["4D6102"]		= "MarioMushroom"		-- not working yet
round_bonuses["4D6103"]		= "MarioFlower"
round_bonuses["4D6104"]		= "MarioCheckpoint"		-- not working yet
-- reserved ranges:
-- [324650] is reserved by a map.
-- [0000..] is reserved.
-- [3333..] will never be added to this list (it can be used by gameplay modules).
-- [4d61..] is reserved for Nnaaaz modules.
-- [FFFF..] is reserved.
-- [13F013] and [F01313] are reserved.
-- Please ask for a range if you need.



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
			local bonus_id = pshy.bonuses_AddNoCopy({type_name = bonus_type, x = bonus_x, y = bonus_y, angle = (ground.rotation or 0)})
		else
			print_warn("not recognized bonus with color %s in map %s", bonus_color, tfm.get.room.currentMap or "?")
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
