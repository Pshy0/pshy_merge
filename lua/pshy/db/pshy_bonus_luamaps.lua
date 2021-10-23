--- pshy_bonus_luamaps.lua
--
-- Add lua maps based on special bonuses.
--
-- @require pshy_mapdb.lua
-- @require pshy_basic_bonuses.lua
-- @require pshy_misc_bonuses.lua
-- @require pshy_mario_bonuses.lua
-- @require pshy_bonuses.lua



--- Maps:
-- Gore trolls:
pshy.mapdb_maps["luatroll_chainsaw"]		= {xml = 2623223, shamans = nil, bonuses = {{type = "GoreDeath", x = 449, y = 288}, {type = "GoreDeath", x = 481, y = 277}, {type = "GoreDeath", x = 515, y = 272}, {type = "GoreDeath", x = 549, y = 265}, {type = "GoreDeath", x = 585, y = 260}, {type = "GoreDeath", x = 618, y = 253}, {type = "GoreDeath", x = 656, y = 249}, {type = "GoreDeath", x = 709, y = 238}, {type = "GoreDeath", x = 749, y = 255}, {type = "GoreDeath", x = 777, y = 285}}}
pshy.mapdb_maps["luatroll_blender"]			= {xml = 3358845, shamans = nil, bonuses = {{type = "GoreDeath", x = 757, y = 180}, {type = "Teleporter", x = 754, y = 210, dst_x = 754, dst_y = 100, image = "none", shared = true, remain = false}}}
-- Teleporter demo:
pshy.mapdb_maps["luatroll_v0_1"]			= {xml = 0, shamans = 0, bonuses = {{type = "Teleporter", x = 400, y = 330}}}
-- Balloon bonus demo:
pshy.mapdb_maps["luatroll_v0_2"]			= {xml = 0, shamans = 0, bonuses = {{type = "BonusAttachBalloon", x = 400, y = 330}}}
pshy.mapdb_maps["luatroll_v161_1"]			= {xml = 161, shamans = nil, bonuses = {{type = "BonusAttachBalloon", x = 400, y = 360}}}
-- Strange bonus demo:
pshy.mapdb_maps["luatroll_v0_7"]			= {xml = 0, shamans = nil, bonuses = {{type = "BonusStrange", x = 600, y = 300}}}
pshy.mapdb_maps["luatroll_v153_1"]			= {xml = 153, shamans = nil, bonuses = {{type = "BonusStrange", x = 80, y = 80}}}
-- MouseTrap demo:
pshy.mapdb_maps["luatroll_v0_3"]			= {xml = 0, bonuses = {{type = "MouseTrap", x = 400, y = 335}, {type = "MouseTrap", x = 200, y = 335}, {type = "MouseTrap", x = 250, y = 335}, {type = "MouseTrap", x = 300, y = 335}, {type = "MouseTrap", x = 350, y = 335}, {type = "MouseTrap", x = 400, y = 335}, {type = "MouseTrap", x = 450, y = 335}, {type = "MouseTrap", x = 500, y = 135}, {type = "MouseTrap", x = 550, y = 135}, {type = "MouseTrap", x = 600, y = 135}}}
pshy.mapdb_maps["luatroll_v17_0"]			= {xml = 17, shamans = nil, bonuses = {{type = "MouseTrap", x = 400, y = 335}, {type = "MouseTrap", x = 350, y = 335}, {type = "MouseTrap", x = 450, y = 335}, {type = "MouseTrap", x = 300, y = 335}, {type = "MouseTrap", x = 500, y = 335}, {type = "MouseTrap", x = 250, y = 335}, {type = "MouseTrap", x = 550, y = 335}, {type = "MouseTrap", x = 375, y = 325}, {type = "MouseTrap", x = 425, y = 325}}}
-- Shaman bonus demo:
pshy.mapdb_maps["luatroll_v0_4"]			= {xml = 0, shamans = 0, bonuses = {{type = "BonusShaman", x = 400, y = 330}}}
pshy.mapdb_maps["luatroll_v116_1"]			= {xml = 116, shamans = 0, bonuses = {{type = "BonusShaman", x = 770, y = 168}}}
-- Circle bonus demo:
pshy.mapdb_maps["luatroll_v0_5"]			= {xml = 0, shamans = nil, bonuses = {{type = "BonusCircle", x = 690, y = 140}}}
-- Speed/Fly bonus demo:
pshy.mapdb_maps["luatroll_v89_1"]			= {xml = 89, shamans = nil, bonuses = {{type = "BonusHighSpeed", x = 537, y = 280}}}
pshy.mapdb_maps["luatroll_v72_1"]			= {xml = 72, shamans = nil, bonuses = {{type = "BonusHighSpeed", x = 160, y = 350}, {type = "BonusFly", x = 640, y = 350}}}
pshy.mapdb_maps["luatroll_v77_1"]			= {xml = 77, shamans = nil, bonuses = {{type = "BonusHighSpeed", x = 420, y = 275}, {type = "BonusHighSpeed", x = 370, y = 275}, {type = "BonusHighSpeed", x = 470, y = 275}}}
pshy.mapdb_maps["luatroll_v98_1"]			= {xml = 98, shamans = nil, bonuses = {{type = "BonusFly", x = 291, y = 177}}}
pshy.mapdb_maps["luatroll_v114_1"]			= {xml = 114, shamans = 0, bonuses = {{type = "BonusHighSpeed", x = 20, y = 320}}}
pshy.mapdb_maps["luatroll_v166_1"]			= {xml = 166, shamans = 0, bonuses = {{type = "BonusFly", x = 20, y = 345}, {type = "BonusHighSpeed", x = 780, y = 345}}}
pshy.mapdb_maps["luatroll_v184_1"]			= {xml = 184, shamans = 0, bonuses = {{type = "BonusFly", x = 170, y = 335}}}
pshy.mapdb_maps["luatroll_v186_1"]			= {xml = 186, shamans = 0, bonuses = {{type = "BonusFly", x = 20, y = 335}, {type = "BonusFly", x = 780, y = 335}}}
-- Checkpoints demo:
pshy.mapdb_maps["luatroll_v22_1"]			= {xml = 22, shamans = 0, bonuses = {{type = "BonusCheckpoint", x = 100, y = 330}, {type = "BonusCheckpoint", x = 700, y = 330}}}
-- Freeze bonus demo:
pshy.mapdb_maps["luatroll_v56_1"]			= {xml = 56, shamans = nil, bonuses = {{type = "BonusFreeze", x = 400, y = 210}}}
pshy.mapdb_maps[7879598]					= {xml = 7879598, shamans = 0, bonuses = {{type = "BonusFreeze", x = 273, y = 303}}}
-- Marry/Divorce bonus demo:
pshy.mapdb_maps["luatroll_v67_1"]			= {xml = 67, shamans = 0, bonuses = {{type = "BonusMarry", x = 225, y = 180}, {type = "BonusDivorce", x = 620, y = 180}}}
pshy.mapdb_maps["luatroll_v182_1"]			= {xml = 182, shamans = 0, bonuses = {{type = "BonusMarry", x = 120, y = 178}, {type = "BonusMarry", x = 680, y = 178}}}
-- Transformations bonus demo:
pshy.mapdb_maps["luatroll_v86_1"]			= {xml = 86, shamans = 0, bonuses = {{type = "BonusTransformations", x = 620, y = 180}}}
-- Ice bonus demo:
pshy.mapdb_maps[7876714]					= {xml = 7876714, shamans = nil, bonuses = {{type = "BonusIce", x = 500, y = 100}}}
-- Grow bonus demo:
pshy.mapdb_maps[7876829]					= {xml = 7876829, shamans = 0, bonuses = {{type = "BonusGrow", x = 400, y = 290}}}
-- Shrink bonus demo:
pshy.mapdb_maps[7876830]					= {xml = 7876830, shamans = nil, bonuses = {{type = "BonusShrink", x = 79, y = 68}}}
-- Cheese bonus demo:
pshy.mapdb_maps[7876832]					= {xml = 7876832, shamans = nil, bonuses = {{type = "BonusCheese", x = 463, y = 137}}}
pshy.mapdb_maps["luatroll_v163_1"]			= {xml = 163, shamans = nil, bonuses = {{type = "BonusCheese", x = 500, y = 255}}}
-- Pickable demo:
pshy.mapdb_maps[7876834]					= {xml = 7876834, shamans = nil, bonuses = {{type = "PickableCheese", x = 592, y = 715}, {type = "PickableCheese", x = 642, y = 715}, {type = "PickableCheese", x = 690, y = 715}, {type = "PickableCheese", x = 620, y = 693}, {type = "PickableCheese", x = 672, y = 693}, {type = "PickableCheese", x = 647, y = 670}}}
-- 6x7 demo:
pshy.mapdb_maps[7876828]					= {xml = 7876828, shamans = nil, bonuses = {{type = "CorrectCheese", x = 675, y = 131}, {type = "WrongCheese", x = 80, y = 118},  {type = "WrongCheese", x = 344, y = 123},  {type = "WrongCheese", x = 634, y = 258}}}
-- Mario flower
pshy.mapdb_maps[7879591]					= {xml = 7879591, shamans = 0, bonuses = {{type = "MarioFlower", x = 60, y = 90}}}



--- Map Lists:
pshy.mapdb_maps_luamaps_bonuses 			= {"luatroll_v0_1", "luatroll_v0_2", "luatroll_v161_1", "luatroll_v0_7", "luatroll_v153_1", "luatroll_v153_1", "luatroll_v0_3", "luatroll_v17_0", "luatroll_v0_4", "luatroll_v116_1", "luatroll_v0_5", "luatroll_v89_1", "luatroll_v72_1", "luatroll_v77_1", "luatroll_v98_1", "luatroll_v114_1", "luatroll_v166_1", "luatroll_v184_1", "luatroll_v186_1", "luatroll_v22_1", "luatroll_v56_1", "luatroll_v67_1", "luatroll_v182_1", "luatroll_v86_1", 7876714, 7876829, 7876830, 7876832, "luatroll_v163_1", 7876834, 7876828, 7879591, 7879598}



--- Rotations:
pshy.mapdb_rotations["luamaps_bonuses"]		= {desc = "Bonus lua maps", duration = 120, troll = true, items = pshy.mapdb_maps_luamaps_bonuses}



--- Pshy event eventInit().
function eventInit()
	if __IS_MAIN_MODULE__ then
		pshy.mapdb_ChatCommandRotc(nil, "luamaps_bonuses")
		tfm.exec.newGame()
	end
end
