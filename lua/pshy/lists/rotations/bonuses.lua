--- pshy.lists.rotations.bonuses
--
-- Add lua maps based on special bonuses.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script and maps)
-- @author TFM:Nnaaaz#0000 (maps)
--
-- @TODO: DELETE FROM TFM: 7879598
pshy.require("pshy.bonuses")
pshy.require("pshy.bonuses.basic")
pshy.require("pshy.bonuses.checkpoints")
pshy.require("pshy.bonuses.mario")
pshy.require("pshy.bonuses.misc")
pshy.require("pshy.bonuses.speedfly")
pshy.require("pshy.events")
pshy.require("pshy.rotations.base")
pshy.require("pshy.rotations.bonuses_mapext")
pshy.require("pshy.rotations.newgame")
local Rotation = pshy.require("pshy.utils.rotation")
local maps = pshy.require("pshy.lists.maps")
local rotations = pshy.require("pshy.lists.rotations")



--- Pshy#3752's hardcoded maps (cannot be exported for different reasons):
local maps_bonus_pshy_hardcoded = {"luatroll_v34_0", "luatroll_v56_1", "luatroll_v114_1", "luatroll_v116_1"}
-- disabled (broken pickable cheese): 7876834
-- Maps with blood (not in rotation):
maps["luatroll_chainsaw"]		= {xml = 2623223, shamans = nil, bonuses = {{type_name = "GoreDeath", x = 449, y = 288}, {type_name = "GoreDeath", x = 481, y = 277}, {type_name = "GoreDeath", x = 515, y = 272}, {type_name = "GoreDeath", x = 549, y = 265}, {type_name = "GoreDeath", x = 585, y = 260}, {type_name = "GoreDeath", x = 618, y = 253}, {type = "GoreDeath", x = 656, y = 249}, {type_name = "GoreDeath", x = 709, y = 238}, {type_name = "GoreDeath", x = 749, y = 255}, {type_name = "GoreDeath", x = 777, y = 285}}}
maps["luatroll_blender"]		= {xml = 3358845, shamans = nil, bonuses = {{type_name = "GoreDeath", x = 757, y = 180}, {type_name = "Teleporter", x = 754, y = 210, dst_x = 754, dst_y = 100, image = "none", behavior = PSHY_BONUS_BEHAVIOR_REMAIN}}}
-- Shaman bonus demo:
maps["luatroll_v116_1"]			= {xml = 116, shamans = 0, bonuses = {{type_name = "BonusShaman", x = 770, y = 168}}}
-- Speed/Fly bonus demo:
maps["luatroll_v114_1"]			= {xml = 114, shamans = 0, bonuses = {{type_name = "BonusHighSpeed", x = 20, y = 320}}}
-- Freeze bonus demo:
maps["luatroll_v56_1"]			= {xml = 56, shamans = nil, bonuses = {{type_name = "BonusFreeze", x = 400, y = 210}}}
-- Mario flower (Cannot export)
maps[7879591]					= {xml = 7879591, shamans = 0, bonuses = {{type_name = "MarioFlower", x = 60, y = 90}}}
-- Cannonball demo:
maps["luatroll_v34_0"]			= {xml = 34, shamans = 0, bonuses = {{type_name = "BonusCannonball", x = 50, y = 230, angle = 90}, {type_name = "BonusCannonball", x = 770, y = 230, angle = -90}}}



--- Pshy#3752's maps
local maps_bonus_pshy_sham		= {7883628, 7876828, 7894816, 7894820, 7894818, 7899003, 7899004, 7899006, 7899007, 7899011, 7899014, 7899017, 7899019, 7899020, 7899733, 7899734, 7876714, 7876830, 7876832, 7879591}
local maps_bonus_pshy_nosham	= {7883626, 7882268, 7882270, 7883625, 7894808, 7894809, 7882271, 7882273, 7899001, 7899002, 7899005, 7899008, 7899010, 7899012, 7899013, 7899015, 7899016, 7899018, 7899021, 7899735, 7899736, 7899738, 7876829}
for i_map, mapcode in ipairs(maps_bonus_pshy_nosham) do
	maps[mapcode] = maps[mapcode] or {}
	maps[mapcode].shamans = 0	
end



--- Nnaaazz#0000's maps
local maps_bonus_nnaaaz_sham	= {7838897, 7827570, 7827574, 7828148, 7829407, 7831081, 7834102, 7834142, 7834148, 7834151, 7834155, 7834207, 7834288, 7834560, 7835178, 7835184, 7822287, 7836300, 7836486, 7836650, 7836703, 7823103, 7838341, 7838539, 7838550, 7838637, 7838642, 7839338, 7839340, 7839618, 7839683, 7840173, 7841167, 7843820, 7866075, 7866078, 7866472, 7866561, 7866564, 7867576, 7867577, 7868050, 7870259, 7870263, 7870846, 7870848, 7882324, 7823106, 7823109, 7824384, 7866562, 7815856}
local maps_bonus_nnaaaz_nosham 	= {7824706, 7823117, 7866076, 7832539, 7826675, 7829571, 7831156, 7831662, 7834593, 7838010, 7838531, 7816581, 7838899, 7823111, 7823122, 7823124, 7823372, 7824394, 7825125, 7825844, 7838009, 7838014, 7838898, 7811011, 7812697, 7835171, 7866563}
-- disabled (too simple or easy): 7834221 7834610 7814680 7838016 7866560 7839986 7825791 7833387 7836299 7838896
-- disabled (too hard): 7839987 7838614
-- disabled (too expensive): 7839867
-- disabled (no bonus): 7836703
-- disabled ("?" bonus supposed to be rare): 7840155 7835185
-- to fix (a bit simple): 7871785 7834288
for i_map, mapcode in ipairs(maps_bonus_nnaaaz_nosham) do
	maps[mapcode] = {shamans = 0}	
end
local maps_bonus_nnaaaz_other	= {7871785, 7866073}
maps[7866073]					= {shamans = 0, author = "Aneimone", title = "@233535 (modified)"}



--- Rotations:
rotations["luamaps_bonuses_ext"]	= Rotation:new({desc = "Bonus lua maps (extended)", duration = 120, troll = true, items = {}})
pshy.ListAppend(rotations["luamaps_bonuses_ext"].items, maps_bonus_pshy_hardcoded)
pshy.ListAppend(rotations["luamaps_bonuses_ext"].items, maps_bonus_pshy_sham)
pshy.ListAppend(rotations["luamaps_bonuses_ext"].items, maps_bonus_pshy_nosham)
pshy.ListAppend(rotations["luamaps_bonuses_ext"].items, maps_bonus_nnaaaz_sham)
pshy.ListAppend(rotations["luamaps_bonuses_ext"].items, maps_bonus_nnaaaz_nosham)
pshy.ListAppend(rotations["luamaps_bonuses_ext"].items, maps_bonus_nnaaaz_other)



--- Pshy event eventInit().
function eventInit()
	if __IS_MAIN_MODULE__ then
		pshy.newgame_SetRotation("luamaps_bonuses_ext")
		tfm.exec.newGame()
	end
end



return rotations
