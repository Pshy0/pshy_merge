--- pshy_mapdb_vanillavs.lua
--
-- Optional extension of `pshy_mapdb.lua` adding Ctmce#0000's maps and map rotations.
--
-- @author: TFM:Pshy#3752 DC:Pshy#7998 (script only)
-- @author: other (basic maps)
--
-- @require pshy_mapdb.lua
-- @require pshy_mapdb_bonuses.lua
-- @require pshy_utils_tables.lua



--- Map lists:
-- The "private" maps are the ones not present in a public rotation.
pshy.mapdb_maps_vanilla_racing = {2, 11, 12, 19, 22, 40, 44, 45, 55, 57, 62, 67, 69, 70, 71, 73, 74, 79, 86, 127, 138, 142, 145, 149, 150 172, 173, 174, 189, 191}
pshy.mapdb_maps_vanilla_racing_pshy = {}
pshy.mapdb_maps_vanilla_racing_pshy_bonus = {"luatroll_v0_8"} -- 7876829, 7876830, 7838009, 7823124, 7812697, 
pshy.mapdb_maps_vanilla_racing_mattseba = {7833266, 7833263}
pshy.mapdb_maps_vanilla_racing_mattseba_private = {7833271}
pshy.mapdb_maps_vanilla_racing_camjho = {7833268, 7833270, 7833288, 7833293, 7833289, 7833279, 7833291, 7833292, 7833282, 7833260}
pshy.mapdb_maps_vanilla_racing_camjho_private = {7838914, 7838910, 7839352, 7833281, 7833269, 7839046, 7839942, 7833259, 7831136, 7833290, 7840122, 7840635}
pshy.mapdb_maps_vanilla_racing_sebaslife_private = {7848738, 7839806, 7844660, 7848738, 7840379, 7844645, 7844642, 7844661, 7848782, 7844664, 7844984, 7839461, 7840186, 7838967, 7844648, 7839493, 7840176, 7839507, 7840728, 7840207, 7848605, 7840564, 7839014, 7844856}
pshy.mapdb_maps_vanilla_racing_notheav_private = {7863949, 7863951, 7863958, 7863953, 7863947, 7863955, 7863961}
pshy.mapdb_maps_vanilla_racing_keticoh = {2111371}
pshy.mapdb_maps_vanilla_racing_epoki = {763961, 6714567}
pshy.mapdb_maps_vanilla_racing_deforche = {7815151, 7815374, 7815665}
pshy.mapdb_maps_vanilla_racing_ricklein = {1830174}
pshy.mapdb_maps_vanilla_racing_thejkb = {238365}
pshy.mapdb_maps_vanilla_racing_kiinhz = {2638619}
pshy.mapdb_maps_vanilla_racing_ferretking = {541114}



--- Rotations:
pshy.mapdb_rotations["vanillavs"]				= {desc = "vanilla racing", shamans = 0, duration = 60, items = {}}
pshy.ListAppend(pshy.mapdb_rotations["vanilla_vs"].items, pshy.mapdb_maps_vanilla_racing_pshy)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_vs"].items, pshy.mapdb_maps_vanilla_racing_pshy_bonus)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_vs"].items, pshy.mapdb_maps_vanilla_racing_mattseba)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_vs"].items, pshy.mapdb_maps_vanilla_racing_mattseba_private)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_vs"].items, pshy.mapdb_maps_vanilla_racing_camjho)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_vs"].items, pshy.mapdb_maps_vanilla_racing_camjho_private)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_vs"].items, pshy.mapdb_maps_vanilla_racing_sebaslife_private)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_vs"].items, pshy.mapdb_maps_vanilla_racing_notheav_private)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_vs"].items, pshy.mapdb_maps_vanilla_racing_keticoh)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_vs"].items, pshy.mapdb_maps_vanilla_racing_epoki)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_vs"].items, pshy.mapdb_maps_vanilla_racing_deforche)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_vs"].items, pshy.mapdb_maps_vanilla_racing_ricklein)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_vs"].items, pshy.mapdb_maps_vanilla_racing_thejkb)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_vs"].items, pshy.mapdb_maps_vanilla_racing_kiinhz)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_vs"].items, pshy.mapdb_maps_vanilla_racing_ferretking)
