--- pshy.bonuses.xmlext
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
local bonuses = pshy.require("pshy.bonuses")
local bonus_types = pshy.require("pshy.bonuses.list")
local map_list = pshy.require("pshy.maps.list")
local mapinfo = pshy.require("pshy.rotations.mapinfo")
local newgame = pshy.require("pshy.rotations.newgame")
pshy.require("pshy.utils.print")



--- Pshy settings:
mapinfo.parse_grounds = true



--- Bonuses Bindings:
-- Basic
bonuses.color_bindings = bonuses.color_bindings or {}
local round_bonuses			= bonuses.color_bindings
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
-- Checkpoints
round_bonuses["E0E0E0"]		= "BonusCheckpoint"
round_bonuses["E0E0E1"]		= "BonusSpawnpoint"
-- Speedfly
round_bonuses["F0F0F0"]		= "BonusFly"
round_bonuses["F04040"]		= "BonusHighSpeed"
-- Misc
round_bonuses["805040"]		= "MouseTrap"
round_bonuses["E00000"]		= "GoreDeath"			-- shouldnt be used
round_bonuses["D0D000"]		= "PickableCheese"
round_bonuses["D0F000"]		= "CorrectCheese"
round_bonuses["F0D000"]		= "WrongCheese"
-- Mario
round_bonuses["4D6101"]		= "MarioCoin"
round_bonuses["4D6102"]		= "MarioMushroom"		-- not working yet
round_bonuses["4D6103"]		= "MarioFlower"
round_bonuses["4D6104"]		= "MarioCheckpoint"		-- not working yet
-- Disabled
round_bonuses["324650"]		= false					-- default color
-- [0000..] is reserved.
-- [3333..] will never be added to this list (it can be used by gameplay modules).
-- [4d61..] is reserved for Nnaaaz modules.
-- [FFFF..] is reserved.
-- [13F013] and [F01313] are reserved.



--- Check a ground.
-- @param ground Ground table from `mapinfo.mapinfo.grounds`.
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
			local bonus_id = bonuses.AddNoCopy({type_name = bonus_type, x = bonus_x, y = bonus_y, angle = (ground.rotation or 0)})
		elseif bonus_type ~= false then
			print_warn("not recognized bonus with color %s in map %s", bonus_color, tfm.get.room.currentMap or "?")
		end
	end
end



function eventNewGame()
	if (mapinfo.mapinfo == nil) then
		print_error("mapinfo.mapinfo was nil")
		return
	end
	if (mapinfo.mapinfo.grounds == nil) then
		print_warn("mapinfo.mapinfo.grounds was nil")
		return
	end
	for i_ground, ground in ipairs(mapinfo.mapinfo.grounds) do
		CheckGround(ground)
	end
end
