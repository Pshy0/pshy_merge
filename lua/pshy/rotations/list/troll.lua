--- pshy.rotations.list.troll
--
-- Troll maps and rotations.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script)
-- @author other (maps, see source)
local utils_tables = pshy.require("pshy.utils.tables")
local Rotation = pshy.require("pshy.utils.rotation")
local rotations = pshy.require("pshy.rotations.list")



--- Map lists:
-- Troll maps listed by Pshy (when they are not already in another list).
local maps_vanilla_troll = {7847625, 4136008, 363251, 7439980}
-- Aewing's other troll list (source: https://docs.google.com/spreadsheets/d/1zO9ifeP8EwPOU9LMTFovunl0TDHHcJfrhisooYVHHLc/edit#gid=1143900591 (2017-05-11))
local maps_trollmapsv2_other = {6125351, 5900622, 1133326, 383709, 5316364, 5463804, 5482590, 549590, 5574163, 5629308, 5836056, 585024, 585028, 5852789, 5858850, 5875457, 5919103, 5922975, 5966472, 6121905, 6137199, 6162603, 625932, 668003, 690871, 722816, 722820, 731615, 6205708, 6216966, 6216666, 6216605, 6206313, 6396394, 6134379, 6376080, 6453361, 6445328, 6212486, 2711798, 558407, 6296389, 6296422, 6299503, 6096572, 6080913, 6299597, 5940448, 6818735, 6052780, 6883328, 6839471}
-- The Holy Document of Troll Maps v3 (source: https://docs.google.com/spreadsheets/d/1f-ntqw9hidFVvqmNVUU5FyvM6wrA62a8NmOV6h9XX5w (11/01/2021-01-11))
local maps_trollmapsv3_vanilla = {5651178, 5018395, 6010060, 6124757, 6123862, 5929021, 6178788, 6127609, 6222523, 6222598, 6222662, 6113351, 6422227, 6575209, 6083498, 6355317, 7306821, 5479119, 5403145, 3067644, 7326348, 7306268, 7797096, 5018481, 5543945, 6122745, 6130459, 6313103, 7307080, 7326356, 7718570, 5966405, 5018508, 5858646, 6127224, 6123442, 5977759, 6135200, 5932565, 6110650, 6526938, 6498941, 6085234, 7326399, 7306953, 7797106, 5018552, 5528077, 7326404, 7307961, 7313763, 7797124, 5018625, 5858647, 1395371, 6207985, 6218403, 6329560, 6345898, 7316626, 7152731, 5622009, 5875455, 6192664, 4888545, 5018731, 7316586, 5858583, 5858585, 5966424, 5966445, 5704644, 6173496, 5436800, 6329565, 5018771, 5719514, 5704627, 6125960, 6127589, 6127747, 6192402, 6184390, 6329568, 6411135, 5994239, 6358824, 7317620, 5018836, 5719492, 5858628, 6124001, 5564186, 6217094, 6649205, 6501429, 7323960, 7318393, 5018961, 5858631, 5640463, 6217035, 6186461, 4040403, 7323461, 7319739, 5019057, 5621250, 6172370, 5436588, 6207483, 6222159, 6062298, 6821665, 7321072, 5019123, 7321926, 5019191, 6126005, 5436981, 4214766, 7322227, 7794773, 5019223, 6501480, 7324070, 6232081, 6232089, 6232095, 6232098, 7797132, 5019302, 5440478, 6526742, 6818892, 6206380, 6695005, 6127550, 6136351, 6217055, 7323482, 6369921, 6108198, 6623156, 6358865, 6883967, 7718563, 5873692, 5019328, 5629311, 5803326, 5858564, 5858586, 5858587, 5966392, 1193082, 6186304, 5543399, 6704726, 5019350, 5719394, 5949452, 6115548, 6477206, 6526318, 6299220, 5019382, 6173592, 6172417, 6772912, 5019421, 6186328, 7321827, 6126256, 5543671, 5019530, 5564274, 6205274, 7324153, 5048881, 6156082, 6277845, 5621395, 5724761, 5724763, 5724765, 6094395, 5565050, 6515469, 6342950, 5605309, 6277853, 6313226, 6819729, 6408356, 7324135, 5049526, 5704629, 7111346, 7323508, 6270048, 6526750, 5910464, 5966432, 5966438, 6126145, 6127710, 6127719, 6377332, 6148478, 6314518, 6299153, 6821666, 6127135, 5621346, 6526760, 6473951, 6452812, 4888705, 5049660, 5875460, 5875461, 5628930, 6172472, 6186377, 6189703, 5910501, 6127290, 6223454, 6838787, 6132502, 6127154, 6332528, 6516797, 5018652, 5836826, 5858595, 5858625, 5858639, 3195916, 6124832, 6127211, 5602310, 7324527, 6244710, 6250422, 6299335, 5595910, 6526776, 6498946, 6813933, 4891010, 6823206, 5858644, 6147952, 6474382, 3765697, 3765697, 5621139, 5621147, 6272568, 6498958, 6836851, 7723923, 5621219, 5910108, 6107893, 6821667, 6190625, 5584431, 6823223, 5605249, 6254763, 5910088, 6119333, 5966429, 5949462, 6203629, 6186396, 6205616, 6207848, 6522504, 4157329, 7322706, 5910104, 6173687, 6116175, 6819107, 7344547, 5910095, 6189594, 6313270, 3711456, 5858581, 5858632, 6104360, 5436707, 6329552, 6400422, 6823081, 6824065, 5803313, 6819128, 6819712, 5649499, 6174089, 5621196, 6125319, 6299508, 7322433, 6205095, 6205714, 6498981, 6715840, 5949349, 6062306, 6580093, 5723872, 5836910, 5858598, 5902874, 6127184, 5591651, 6201987, 6335762, 5858641, 7322471, 5902875, 7324077, 7797162, 6127705, 5605065, 4273525, 6445760, 7270457, 7793398, 6205203, 6100256, 4517700, 6300895, 6473496, 6431883, 5621555, 6411306, 5910116, 6174019, 4273441, 5910077, 6451557, 6573645, 5862868, 5862874, 6192863, 5621716, 5852948, 5854243, 5621865, 6818861, 6122725, 6113306, 6445749, 5836845, 6185835, 6613860, 5050018, 6189570, 2721399, 5875458, 6900569, 6527648, 6400412, 6794502, 6794509, 6794515, 6837067, 6794527, 6794531, 6798232, 6794500, 7276028, 6798283, 7128420}
local maps_trollmapsv3_racing = {6273752, 6273694, 6418619, 6704790, 6883225, 6901245, 6901260, 6716047, 7106829, 7143225, 7143229, 7143231, 7143235}
local maps_trollmapsv3_rotations_noracing = {4759150, 5858703, 5858770, 5859434, 5859447, 5859532, 5859542, 5892506, 5892558, 5902822, 5902827, 5902895, 5918103, 5918111, 5921487, 5966400, 5966408, 5966409, 5966414, 5966418, 5966462, 5966473, 6019882, 6019890, 6019900, 6299490, 6299901, 5949845, 5049453, 5575085, 5858562, 5858669, 5858762, 5859410, 5859501, 5860620, 5863395, 5863423, 5875462, 5875465, 5875466, 5875467, 5966389, 5966417, 5966459, 5966465, 6019894, 6082932, 6122126, 6020836, 1746071, 6242044, 6299312, 6299328, 6299369, 6308474, 5946610, 5946626, 5946613, 4636732, 6902434, 5575159, 5575195, 5858602, 4247610, 6305517, 6305551, 6305617, 6305707, 6314480, 6299413, 6299384, 5946634, 5946669, 5951369, 5951378, 6376011, 6299277, 5951362, 6874219, 7143240, 5049384, 5575096, 5575108, 5621496, 5858558, 5858720, 5858784, 5859579, 5859594, 5859607, 5859617, 5862892, 5863475, 5863515, 5863529, 5863583, 5863631, 5863649, 5863705, 5875449, 5887738, 5902850, 5902868, 5910128, 5966453, 5982510, 5991843, 6019895, 6127308, 6123903, 6123935, 6190773, 6190661, 6190270, 6190252, 6190231, 6190196, 6280663, 6309152, 6309162, 6309194, 6314505, 6316487, 6316519, 6316552, 6627603, 6272125, 6299376, 6299378, 6299380, 6299421, 6418640, 6553484, 6689054, 6389621, 5069907, 6689069, 6627605, 6299426, 5948428, 6823381, 6191953, 5070084, 5278887, 5247557, 5541815, 6340475, 6920196, 6219374, 6105038, 6431185, 5949881, 5982422, 6050752, 6314533, 6036135, 6299351, 6840743, 6839461, 6920189, 6920187, 6920192, 6716039}
-- TODO: Troll Map Submissions 3.0 - pending newests submissions (source: https://atelier801.com/topic?f=6&t=892614&p=1)
local maps_trollmapsv3_pending_racing = {}
local maps_trollmapsv3_pending_vanilla = {}
local maps_trollmapsv3_pending_other = {}
-- Nnaaaz#0000's trolls (source: https://atelier801.com/topic?f=6&t=892706&p=1 (2021-08-23))
local maps_nnaaaz_trolls_vanilla = {7805164, 7801845, 7801848, 7801850, 7801929, 7802215, 7802221, 7802404, 7802588, 7802592, 7803100, 7803618, 7803013, 7803900, 7804144, 7804211, 7804405, 7804709, 7804243, 7805109}
local maps_nnaaaz_trolls_vanilla_nosham = {7781189, 7781560, 7782831, 7783745, 7787472, 7814117, 7814126, 7814248, 7814488, 7817779}
local maps_nnaaaz_trolls_racing = {7781575, 7783458, 7783472, 7784221, 7784236, 7786652, 7786707, 7786960, 7787034, 7788567, 7788596, 7788673, 7788967, 7788985, 7788990, 7789010, 7789484, 7789524, 7790734, 7790746, 7790938, 7791293, 7791550, 7791709, 7791865, 7791877, 7792434, 7765843, 7794331, 7794726, 7792626, 7794874, 7795585, 7796272, 7799753, 7800330, 7800998, 7801670, 7805437, 7792149, 7809901, 7809905, 7810816, 7812751, 7789538, 7813075, 7813248, 7814099, 7819315, 7815695, 7815703, 7816583, 7816748, 7817111, 7782820}
-- Pshy#3752's trolls 
local maps_pshy_trolls_vanilla_nosham = {7871137, 7871139, 7871138, 7871140, 7871142, 7871141, 7871143, 7871144, 7871145, 7871146, 7871152, 7871148, 7871147, 7871154, 7871160, 7871158, 7871136, 7876183, 7876188}
local maps_pshy_trolls_vanilla_sham = {7871134, 7871157, 7871155, 7876185, 7876194, 7899408}
local maps_pshy_trolls_misc_nosham = {7840661, 7871156, 7871159, 7871161}
local maps_racing_troll = {7178114, 399075, 615973}
local maps_other_troll = {399075, 615973, 6786120, 2043234}
-- Bisammoeen14#7506's trolls (source: https://atelier801.com/topic?f=6&t=892706&p=1#m16)
local maps_bisammoeen14_trolls_vanilla = {7819384, 7819386, 7819387, 7819388, 7819389, 7819390, 7819391, 7819394, 7819719, 7819720, 7819721, 7823948, 7823952, 7823954, 7823956, 7823957, 7823958, 7824387, 7824388, 7824390, 7824392} 
-- TODO: Check Aewing's mechanisms originals list
-- The Holy Document of Troll Maps v3 Rotation/Racing (originals) (source: https://docs.google.com/spreadsheets/d/1f-ntqw9hidFVvqmNVUU5FyvM6wrA62a8NmOV6h9XX5w (11/01/2021-01-11))
-- 1405249, 6112855, 2101747, 407294, 1657360, 4645670, 4645670, 4645670, 7021812, 6835898, 6771291, 7062105
-- TODO: Remove racings from other_troll
--todo: 586175 2135750 949687 500601 406463 817645 6245851(getxml) 2270500 2344006 1605979 1871815 1514137 6773628 348918 122333 6577015 7135698 7485555 201865 1441913 7465509 666589
--todo: 7710350



-- Rotations:
rotations["vanilla_troll"]	= Rotation:New({desc = "vanilla troll maps", duration = 120, troll = true, items = {}, unique_items = true})
utils_tables.ListAppend(rotations["vanilla_troll"].items, maps_trollmapsv3_vanilla)
utils_tables.ListAppend(rotations["vanilla_troll"].items, maps_nnaaaz_trolls_vanilla)
utils_tables.ListAppend(rotations["vanilla_troll"].items, maps_pshy_trolls_vanilla_nosham)
utils_tables.ListAppend(rotations["vanilla_troll"].items, maps_pshy_trolls_vanilla_sham)
utils_tables.ListAppend(rotations["vanilla_troll"].items, maps_trollmapsv3_pending_vanilla)
utils_tables.ListAppend(rotations["vanilla_troll"].items, maps_bisammoeen14_trolls_vanilla)
rotations["racing_troll"]	= Rotation:New({desc = "trolls for racings", duration = 60, shamans = 0, troll = true, items = {}, unique_items = true})
utils_tables.ListAppend(rotations["racing_troll"].items, maps_trollmapsv3_racing)
utils_tables.ListAppend(rotations["racing_troll"].items, maps_nnaaaz_trolls_racing)
utils_tables.ListAppend(rotations["racing_troll"].items, maps_trollmapsv3_pending_racing)
utils_tables.ListAppend(rotations["racing_troll"].items, maps_racing_troll)
rotations["other_troll"]	= Rotation:New({desc = "misc trolls", duration = 120, troll = true, items = {}, unique_items = true})
utils_tables.ListAppend(rotations["other_troll"].items, maps_trollmapsv2_other)
utils_tables.ListAppend(rotations["other_troll"].items, maps_pshy_trolls_misc_nosham)
utils_tables.ListAppend(rotations["other_troll"].items, maps_trollmapsv3_rotations_noracing)
utils_tables.ListAppend(rotations["other_troll"].items, maps_trollmapsv3_pending_other)



return rotations
