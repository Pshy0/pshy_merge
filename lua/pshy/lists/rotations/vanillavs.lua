--- pshy.rotations.vanillavs
--
-- Rotations of maps suited for vanilla vs scripts.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script only)
-- @author other (maps, see source)
pshy.require("pshy.rotations.base")
pshy.require("pshy.utils.tables")
local Rotation = pshy.require("pshy.utils.rotation")
local rotations = pshy.require("pshy.lists.rotations")



--- Map lists:
-- The "private" maps are the ones not present in a public rotation.
local maps_vanilla_racing = {2, 11, 12, 19, 22, 40, 44, 45, 55, 57, 62, 67, 69, 70, 71, 73, 74, 79, 86, 127, 138, 142, 145, 149, 150, 172, 173, 174, 189, 191}
local maps_vanilla_racing_pshy = {7897852, 7897853, 7897854, 7897855, 7897856, 7897858, 7897860, 7897862, 7897863, 7897864}
--TODO: test and add: 7897857, 7897859, 4984982
--TODO: remove maps similar to: 7897853, 7897857, 7897859, 7897860, 7897863
local maps_vanilla_racing_mattseba = {7833266, 7833263}
local maps_vanilla_racing_mattseba_private = {7833271} -- basic maps only
local maps_vanilla_racing_camjho = {7833268, 7833270, 7833288, 7833293, 7833289, 7833279, 7833291, 7833292, 7833282, 7833260, 7833265}
local maps_vanilla_racing_camjho_private = {7838914, 7838910, 7839352, 7833281, 7833269, 7839046, 7839942, 7833259, 7831136, 7833290, 7840122, 7840635, 7838930} -- not on discord / permission obtained
local maps_vanilla_racing_sebaslife_private = {7848738, 7839806, 7844660, 7840379, 7844645, 7844642, 7844661, 7848782, 7844664, 7844984, 7839461, 7840186, 7838967, 7844648, 7839493, 7840176, 7839507, 7840728, 7840207, 7848605, 7840564, 7839014, 7844856} -- permission obtained
local maps_vanilla_racing_notheav_private = {7863949, 7863951, 7863958, 7863953, 7863947, 7863955, 7863961, 7863950} -- permission obtained
local maps_vanilla_racing_keticoh = {2111371}
local maps_vanilla_racing_epoki = {763961, 6714567}
local maps_vanilla_racing_deforche = {7815151, 7815374, 7815665}
local maps_vanilla_racing_ricklein = {1830174}
local maps_vanilla_racing_thejkb = {238365}
local maps_vanilla_racing_kiinhz = {2638619}
local maps_vanilla_racing_ferretking = {541114}
-- trolls (see `pshy.rotations.rotations.troll` for authors):
local maps_vanilla_vs_trolls = {7871141, 5436707, 6411135, 6411306, 6411306, 6127589, 4273525, 5704629, 5724763, 6203629, 6715840, 6299508, 5875461, 7803900, 5858595, 6332528, 5910077, 6094395, 7793398, 7723923, 6823206, 6205714, 5595910, 7797132, 5018836, 6136351, 7323508, 6207848, 6205095, 5910116, 7823952, 5858628, 5858632, 56293112, 5724765, 6498958, 7326399, 7871145}



--- Rotations:
rotations["vanilla_vs"]			= Rotation:New({desc = "vanilla racing", shamans = 0, duration = 60, items = {}})
pshy.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_pshy)
pshy.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_mattseba)
pshy.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_mattseba_private)
pshy.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_camjho)
pshy.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_camjho_private)
pshy.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_sebaslife_private)
pshy.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_notheav_private)
pshy.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_keticoh)
pshy.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_epoki)
pshy.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_deforche)
pshy.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_ricklein)
pshy.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_thejkb)
pshy.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_kiinhz)
pshy.ListAppend(rotations["vanilla_vs"].items, maps_vanilla_racing_ferretking)
rotations["vanilla_vs_troll"]	= Rotation:New({desc = "trolls for vanilla_vs", duration = 60, shamans = 0, troll = true, items = {}, unique_items = true})
pshy.ListAppend(rotations["vanilla_vs_troll"].items, maps_vanilla_vs_trolls)



return rotations
