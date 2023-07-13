--- pshy.rotations.list.racing_troll
--
-- Troll maps and rotations.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script)
-- @author other (maps, see source)
local utils_tables = pshy.require("pshy.utils.tables")
local Rotation = pshy.require("pshy.utils.rotation")
local rotations = pshy.require("pshy.rotations.list")



--- Map lists:
-- The Holy Document of Troll Maps v3 (source: https://docs.google.com/spreadsheets/d/1f-ntqw9hidFVvqmNVUU5FyvM6wrA62a8NmOV6h9XX5w (11/01/2021-01-11))
local maps_trollmapsv3_racing = {6273752, 6273694, 6418619, 6704790, 6883225, 6901245, 6901260, 6716047, 7106829, 7143225, 7143229, 7143231, 7143235}
-- TODO: Troll Map Submissions 3.0 - pending newests submissions (source: https://atelier801.com/topic?f=6&t=892614&p=1)
local maps_trollmapsv3_pending_racing = {}
-- Nnaaaz#0000's trolls (source: https://atelier801.com/topic?f=6&t=892706&p=1 (2021-08-23))
local maps_nnaaaz_trolls_racing = {7781575, 7783458, 7783472, 7784221, 7784236, 7786652, 7786707, 7786960, 7787034, 7788567, 7788596, 7788673, 7788967, 7788985, 7788990, 7789010, 7789484, 7789524, 7790734, 7790746, 7790938, 7791293, 7791550, 7791709, 7791865, 7791877, 7792434, 7765843, 7794331, 7794726, 7792626, 7794874, 7795585, 7796272, 7799753, 7800330, 7800998, 7801670, 7805437, 7792149, 7809901, 7809905, 7810816, 7812751, 7789538, 7813075, 7813248, 7814099, 7819315, 7815695, 7815703, 7816583, 7816748, 7817111, 7782820}
-- Pshy#3752's trolls
local maps_racing_troll = {7178114, 399075, 615973}



-- Rotations:
rotations["racing_troll"]	= Rotation:New({desc = "trolls for racings", duration = 60, shamans = 0, troll = true, items = {}, unique_items = true})
utils_tables.ListAppend(rotations["racing_troll"].items, maps_trollmapsv3_racing)
utils_tables.ListAppend(rotations["racing_troll"].items, maps_nnaaaz_trolls_racing)
utils_tables.ListAppend(rotations["racing_troll"].items, maps_trollmapsv3_pending_racing)
utils_tables.ListAppend(rotations["racing_troll"].items, maps_racing_troll)



return rotations
