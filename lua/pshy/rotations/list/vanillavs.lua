--- pshy.rotations.list.vanillavs
--
-- Rotations of maps suited for vanilla vs scripts.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script only)
-- @author other (maps, see source)
local Rotation = pshy.require("pshy.utils.rotation")
local utils_tables = pshy.require("pshy.utils.tables")
local rotations = pshy.require("pshy.rotations.list")



--- Map lists:
-- The "private" maps are the ones not present in a public rotation.
local maps_vanilla_racing = {2, 11, 12, 19, 22, 40, 44, 45, 55, 57, 62, 67, 69, 70, 71, 73, 74, 79, 86, 127, 138, 142, 145, 149, 150, 172, 173, 174, 189, 191, 217, 220, 221, 222, 224, 225}
local maps_vanilla_racing_pshy = {7897852, 7897853, 7897854, 7897855, 7897856, 7897858, 7897860, 7897862, 7897863, 7897864}
--TODO: test and add: 7897857, 7897859, 4984982
--TODO: remove maps similar to: 7897853, 7897857, 7897859, 7897860, 7897863
local maps_vanilla_racing_mattseba = {7833263, 7833266}
local maps_vanilla_racing_mattseba_private = {7833271} -- basic maps only
local maps_vanilla_racing_camjho = {7833260, 7833265, 7833268, 7833270, 7833279, 7833282, 7833288, 7833289, 7833291, 7833292, 7833293}
local maps_vanilla_racing_camjho_private = {7831136, 7833259, 7833269, 7833281, 7833290, 7838910, 7838914, 7838930, 7839046, 7839352, 7839368, 7839942, 7840110, 7840122, 7840635} -- not on discord / permission obtained
local maps_vanilla_racing_sebaslife_private = {7838967, 7839014, 7839461, 7839493, 7839507, 7839806, 7840176, 7840186, 7840207, 7840379, 7840564, 7840728, 7844642, 7844645, 7844648, 7844660, 7844661, 7844664, 7844856, 7844984, 7848605, 7848738, 7848782} -- permission obtained -- bad maps: 7840159
local maps_vanilla_racing_notheav_private = {7863947, 7863949, 7863950, 7863951, 7863952, 7863953, 7863955, 7863958, 7863961, 7908718, 7908721} -- permission obtained
local maps_vanilla_racing_keticoh = {2111371}
local maps_vanilla_racing_epoki = {763961, 6714567}
local maps_vanilla_racing_deforche = {7815151, 7815374, 7815665}
local maps_vanilla_racing_ricklein = {1830174}
local maps_vanilla_racing_thejkb = {238365}
local maps_vanilla_racing_kiinhz = {2638619}
local maps_vanilla_racing_ferretking = {541114}
local maps_vanilla_racing_papero = {5974640}
-- trolls (see `pshy.rotations.rotations.troll` for authors):
local maps_vanilla_vs_trolls = {4273525, 5018836, 5436707, 5595910, 5704629, 5724763, 5724765, 5858595, 5858628, 5858632, 5875461, 5910077, 5910116, 6094395, 6127589, 6136351, 6203629, 6205095, 6205714, 6207848, 6299508, 6332528, 6411135, 6411306, 6411306, 6498958, 6715840, 6823206, 7323508, 7326399, 7723923, 7793398, 7797132, 7803900, 7823952, 7871141, 7871145, 56293112}



--- Rotations:
rotations["vanilla_vs"]			= Rotation:New({desc = "vanilla racing", shamans = 0, duration = 60, items = {}})
utils_tables.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_pshy)
utils_tables.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_mattseba)
utils_tables.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_mattseba_private)
utils_tables.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_camjho)
utils_tables.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_camjho_private)
utils_tables.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_sebaslife_private)
utils_tables.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_notheav_private)
utils_tables.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_keticoh)
utils_tables.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_epoki)
utils_tables.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_deforche)
utils_tables.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_ricklein)
utils_tables.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_thejkb)
utils_tables.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_kiinhz)
utils_tables.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_ferretking)
utils_tables.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_papero)
rotations["vanilla_vs_troll"]	= Rotation:New({desc = "trolls for vanilla_vs", duration = 60, shamans = 0, troll = true, items = {}, unique_items = true})
utils_tables.ListAppend(rotations["vanilla_vs_troll"].items, maps_vanilla_vs_trolls)



return rotations
