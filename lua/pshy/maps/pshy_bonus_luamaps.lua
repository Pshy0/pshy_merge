--- pshy_bonus_luamaps.lua
--
-- Add lua maps based on special bonuses.
--
-- @require pshy_basic_bonuses.lua
-- @require pshy_bonuses.lua
-- @require pshy_bonuses_mapext.lua
-- @require pshy_mapdb.lua
-- @require pshy_mario_bonuses.lua
-- @require pshy_misc_bonuses.lua
-- @require pshy_newgame.lua
--
-- @require_priority UTILS



--- Pshy#3752's hardcoded maps:
pshy.mapdb_maps_bonus_pshy_hardcoded 		= {"luatroll_v0_1", "luatroll_v0_2", "luatroll_v161_1", "luatroll_v0_7", "luatroll_v153_1", "luatroll_v0_3", "luatroll_v17_0", "luatroll_v0_4", "luatroll_v116_1", "luatroll_v0_5", "luatroll_v89_1", "luatroll_v72_1", "luatroll_v77_1", "luatroll_v98_1", "luatroll_v114_1", "luatroll_v166_1", "luatroll_v184_1", "luatroll_v186_1", "luatroll_v22_1", "luatroll_v56_1", "luatroll_v67_1", "luatroll_v182_1", "luatroll_v86_1", 7876714, 7876829, 7876830, 7876832, "luatroll_v163_1", 7876834, 7876828, 7879591, 7879598, "luatroll_68_1", "luatroll_43_1", "luatroll_v0_8", "luatroll_v0_9", "luatroll_v37_0", "luatroll_v34_0", "luatroll_v136_0"}
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
pshy.mapdb_maps["luatroll_v98_1"]			= {xml = 98, shamans = 0, bonuses = {{type = "BonusFly", x = 291, y = 177}}}
pshy.mapdb_maps["luatroll_v114_1"]			= {xml = 114, shamans = 0, bonuses = {{type = "BonusHighSpeed", x = 20, y = 320}}}
pshy.mapdb_maps["luatroll_v166_1"]			= {xml = 166, shamans = 0, bonuses = {{type = "BonusFly", x = 20, y = 345}, {type = "BonusHighSpeed", x = 780, y = 345}}}
pshy.mapdb_maps["luatroll_v184_1"]			= {xml = 184, shamans = 0, bonuses = {{type = "BonusFly", x = 170, y = 335}}}
pshy.mapdb_maps["luatroll_v186_1"]			= {xml = 186, shamans = 0, bonuses = {{type = "BonusFly", x = 20, y = 335}, {type = "BonusFly", x = 780, y = 335}}}
pshy.mapdb_maps["luatroll_68_1"]			= {xml = 68, shamans = 0, bonuses = {{type = "BonusHighSpeed", x = 400, y = 200}}}
pshy.mapdb_maps["luatroll_43_1"]			= {xml = 43, shamans = nil, bonuses = {{type = "BonusHighSpeed", x = 400, y = 180}}}
-- Spawnpoint demo:
pshy.mapdb_maps["luatroll_v22_1"]			= {xml = 22, shamans = 0, bonuses = {{type = "BonusSpawnpoint", x = 100, y = 330}, {type = "BonusSpawnpoint", x = 700, y = 330}}}
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
pshy.mapdb_maps[7876830]					= {xml = 7876830, shamans = nil, bonuses = {{type = "BonusShrink", x = 79, y = 68}}} -- TODO: un-hardcode ?
-- Cheese bonus demo:
pshy.mapdb_maps[7876832]					= {xml = 7876832, shamans = nil, bonuses = {{type = "BonusCheese", x = 463, y = 137}}}
pshy.mapdb_maps["luatroll_v163_1"]			= {xml = 163, shamans = nil, bonuses = {{type = "BonusCheese", x = 500, y = 255}}}
-- Pickable demo:
pshy.mapdb_maps[7876834]					= {xml = 7876834, shamans = nil, bonuses = {{type = "PickableCheese", x = 592, y = 715}, {type = "PickableCheese", x = 642, y = 715}, {type = "PickableCheese", x = 690, y = 715}, {type = "PickableCheese", x = 620, y = 693}, {type = "PickableCheese", x = 672, y = 693}, {type = "PickableCheese", x = 647, y = 670}}}
-- 6x7 demo:
pshy.mapdb_maps[7876828]					= {xml = 7876828, shamans = nil, bonuses = {{type = "CorrectCheese", x = 675, y = 131}, {type = "WrongCheese", x = 80, y = 118},  {type = "WrongCheese", x = 344, y = 123},  {type = "WrongCheese", x = 634, y = 258}}}
-- Mario flower
pshy.mapdb_maps[7879591]					= {xml = 7879591, shamans = 0, bonuses = {{type = "MarioFlower", x = 60, y = 90}}}
-- Cannonball demo:
pshy.mapdb_maps["luatroll_v0_8"]			= {xml = 0, shamans = 0, bonuses = {{type = "BonusCannonball", x = 400, y = 330, angle = -90}, {type = "BonusCannonball", x = 500, y = 120, angle = 180}, {type = "BonusCannonball", x = 585, y = 120, angle = 180}}}
pshy.mapdb_maps["luatroll_v37_0"]			= {xml = 37, shamans = 0, bonuses = {{type = "BonusCannonball", x = 140, y = 120, angle = 180}, {type = "BonusCannonball", x = 660, y = 120, angle = 180}}}
pshy.mapdb_maps["luatroll_v34_0"]			= {xml = 34, shamans = 0, bonuses = {{type = "BonusCannonball", x = 50, y = 230, angle = 90}, {type = "BonusCannonball", x = 770, y = 230, angle = -90}}}
pshy.mapdb_maps["luatroll_v136_0"]			= {xml = 136, shamans = nil, bonuses = {{type = "BonusCannonball", x = 300, y = 330, angle = -90}, {type = "BonusCannonball", x = 350, y = 330, angle = -90}, {type = "BonusCannonball", x = 400, y = 330, angle = -90}, {type = "BonusCannonball", x = 450, y = 330, angle = -90}, {type = "BonusCannonball", x = 500, y = 530, angle = -90}, {type = "BonusCannonball", x = 550, y = 330, angle = -90}, {type = "BonusCannonball", x = 300, y = 240, angle = -90}, {type = "BonusCannonball", x = 350, y = 240, angle = -90}, {type = "BonusCannonball", x = 400, y = 240, angle = -90}, {type = "BonusCannonball", x = 450, y = 240, angle = -90}, {type = "BonusCannonball", x = 500, y = 240, angle = -90}, {type = "BonusCannonball", x = 550, y = 240, angle = -90}}}

-- BonusFish demo:
pshy.mapdb_maps["luatroll_v0_9"]			= {xml = 0, shamans = nil, bonuses = {{type = "BonusFish", x = 400, y = 330}}}



--- Pshy#3752's maps
pshy.mapdb_maps_bonus_pshy					= {7882268, 7882270, 7882271, 7882273, 7883625, 7883626, 7883628}
pshy.mapdb_maps[7882268]					= {shamans = 0}
pshy.mapdb_maps[7882270]					= {shamans = 0}
pshy.mapdb_maps[7883625]					= {shamans = 0} -- todo: make the 2 variants
pshy.mapdb_maps[7882271]					= {shamans = 0}
pshy.mapdb_maps[7882273]					= {shamans = 0}
pshy.mapdb_maps[7883626]					= {shamans = 0}



--- Nnaaazz#0000's maps
pshy.mapdb_maps_bonus_nnaaaz_sham			= {7827570, 7827574, 7828148, 7829407, 7831081, 7832539, 7833387, 7834102, 7834142, 7834148, 7834151, 7834155, 7834207, 7834221, 7834288, 7834560, 7835171, 7835178, 7835184, 7822287, 7835185, 7836299, 7836300, 7836486, 7836650, 7836703, 7823103, 7838016, 7838341, 7838539, 7838550, 7838614, 7838637, 7838642, 7838896, 7838897, 7839338, 7839340, 7839618, 7839683, 7839867, 7839986, 7839987, 7840155, 7840173, 7841167, 7843820, 7866075, 7866078, 7866472, 7866560, 7866561, 7866563, 7866564, 7867576, 7867577, 7868050, 7870259, 7870263, 7870846, 7870848, 7882324, 7823106, 7823109, 7824384, 7866562, 7814680, 7815856}
pshy.mapdb_maps_bonus_nnaaaz_nosham 		= {7826675, 7829571, 7831156, 7831662, 7834593, 7838010, 7838531, 7816581, 7838899, 7866076, 7823111, 7823117, 7823122, 7823124, 7823372, 7824394, 7824706, 7825125, 7825791, 7825844, 7834610, 7838009, 7838014, 7838898, 7811011, 7812697}
for i_map, mapcode in ipairs(pshy.mapdb_maps_bonus_nnaaaz_nosham) do
	pshy.mapdb_maps[mapcode] = {shamans = 0}	
end
pshy.mapdb_maps_bonus_nnaaaz_other			= {7871785, 7866073}
pshy.mapdb_maps[7866073]					= {shamans = 0, title = "Aneimone - @233535 (modified)"}



--- Rotations:
pshy.mapdb_rotations["luamaps_bonuses_hardcoded"]	= {desc = "Bonus lua maps (hardcoded)", duration = 120, troll = true, items = pshy.mapdb_maps_bonus_pshy_hardcoded}
pshy.mapdb_rotations["luamaps_bonuses_ext"]			= {desc = "Bonus lua maps (extended)", duration = 120, troll = true, items = {}}
pshy.ListAppend(pshy.mapdb_rotations["luamaps_bonuses_ext"].items, pshy.mapdb_maps_bonus_pshy_hardcoded)
pshy.ListAppend(pshy.mapdb_rotations["luamaps_bonuses_ext"].items, pshy.mapdb_maps_bonus_pshy)
pshy.ListAppend(pshy.mapdb_rotations["luamaps_bonuses_ext"].items, pshy.mapdb_maps_bonus_nnaaaz_sham)
pshy.ListAppend(pshy.mapdb_rotations["luamaps_bonuses_ext"].items, pshy.mapdb_maps_bonus_nnaaaz_nosham)
pshy.ListAppend(pshy.mapdb_rotations["luamaps_bonuses_ext"].items, pshy.mapdb_maps_bonus_nnaaaz_other)



--- Pshy event eventInit().
function eventInit()
	if __IS_MAIN_MODULE__ then
		pshy.newgame_ChatCommandRotc(nil, "luamaps_bonuses_ext")
		tfm.exec.newGame()
	end
end
