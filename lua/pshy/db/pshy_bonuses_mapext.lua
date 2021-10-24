--- pshy_bonuses_mapext.lua
--
-- Allow maps to contain custom bonuses in the form of 
-- custom foreground invisible and non-colliding circle ground.
--
-- @require pshy_mapdb.lua
-- @require pshy_bonus_luamaps.lua
-- @require pshy_bonuses.lua
-- @require pshy_xmlmap.lua



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
local function CheckGround(ground)
	if ground["T"] == "13" and ground["L"] == "10" and ground["c"] == "4" and ground["m"] == "" then --  and ground["N"] == ""
		local bonus_color = ground["o"]
		if not bonus_color then
			print("WARNING: bad xml")
			return
		end
		local bonus_x = ground["X"]
		local bonus_y = ground["Y"]
		local bonus_type = round_bonuses[bonus_color]
		if bonus_type then
			print("adding bonus")
			pshy.bonuses_Add(bonus_type, bonus_x, bonus_y)
		end
	end
end



--- TFM event eventNewGame.
function eventNewGame()
	if pshy.xmlmap then
		print("checking objects")
		local grounds_node = pshy.xmlmap_GetGroundNode()
		assert(type(grounds_node) == "table")
		for i_ground_node, ground_node in ipairs(grounds_node.childs) do
			assert(ground_node.type == "S")
			if ground_node.type == "S" then
				CheckGround(ground_node.properties)
			end
		end
	end
end



--- Pshy event eventInit().
function eventInit()
	if __IS_MAIN_MODULE__ then
		pshy.mapdb_ChatCommandRotc(nil, "luamaps_bonuses_ext")
		tfm.exec.newGame()
	end
end
