--- pshy_mapdb.lua
--
-- List of maps and rotations.
-- Custom settings may be used by other modules.
--
-- Listed map and rotation tables can have the folowing fields:
--	- begin_func: Function to run when the map started.
--	- end_func: Function to run when the map stopped.
--	- replace_func: Function to run on the map's xml (or name if not present) that is supposed to return the final xml.
--	- autoskip: If true, the map will change at the end of the timer.
--	- duration: Duration of the map.
--	- shamans: Count of shamans (Currently, only 0 is supported to disable the shaman).
--	- xml (maps only): The true map's xml code.
--	- hidden (rotations only): Do not show the rotation is being used to players.
--	- modules: list of module names to enable while the map is playing (to trigger events).
--	- troll: bool telling if the rotation itself is a troll (may help other modules about how to handle the rotation).
--	- unique_items: bool telling if the items are supposed to be unique (duplicates are removed on eventInit).
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script)
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_rotation.lua
-- @require pshy_bonuses.lua
-- @TODO: remove dependencies



--- Module Help Page:
pshy.help_pages["pshy_mapdb"] = {back = "pshy", title = "Maps / Rotations", text = "Use /info to know who made the current map.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_mapdb"] = pshy.help_pages["pshy_mapdb"]



--- Module Settings:
pshy.mapdb_maps = {}						-- map of maps
pshy.mapdb_rotations = {}					-- map of rotations



--- Custom maps:
-- Shaman no objects
pshy.mapdb_maps["v0_noskills"]				= {xml = [[<C><P shaman_tools="33,63,65,80,89,95" F="0" /><Z><S><S H="50" L="800" Y="378" X="400" P="0,0,0.3,0.2,0,0,0,0" T="6" /><S H="40" L="120" Y="173" X="541" P="0,0,0.3,0.2,0,0,0,0" T="6" /><S H="27" L="35" Y="482" X="254" P="0,0,0.3,0.2,90,0,0,0" T="6" /></S><D><P X="542" P="0,1" T="12" Y="353" /><P X="49" P="1,0" T="0" Y="355" /><T X="120" Y="356" /><P X="228" P="0,0" T="3" Y="355" /><P X="249" P="0,0" T="11" Y="354" /><P X="296" P="0,1" T="11" Y="353" /><P X="311" P="0,0" T="3" Y="354" /><P X="729" P="0,0" T="11" Y="353" /><P X="672" P="0,1" T="3" Y="356" /><P X="283" P="0,0" T="3" Y="353" /><P X="273" P="0,0" T="3" Y="354" /><P X="353" P="0,1" T="3" Y="353" /><P X="692" P="0,0" T="5" Y="356" /><P X="390" P="0,1" T="3" Y="354" /><P X="706" P="0,0" T="1" Y="356" /><F X="541" Y="149" /><P X="495" P="0,0" T="11" Y="154" /><DS X="122" Y="343" /><DC X="122" Y="341" /></D><O /></Z></C>]]}
-- Test
pshy.mapdb_maps["test"]						= {xml = [[<C><P shaman_tools="1,33,102,110,111,202,302,402,608,1002,2802,2,2806" F="0" /><Z><S><S H="50" L="800" Y="378" X="400" P="0,0,0.3,0.2,0,0,0,0" T="6" /><S H="40" L="120" Y="173" X="541" P="0,0,0.3,0.2,0,0,0,0" T="6" /><S H="27" L="35" Y="482" X="254" P="0,0,0.3,0.2,90,0,0,0" T="6" /></S><D><P X="542" P="0,1" T="12" Y="353" /><P X="49" P="1,0" T="0" Y="355" /><T X="120" Y="356" /><P X="228" P="0,0" T="3" Y="355" /><P X="249" P="0,0" T="11" Y="354" /><P X="296" P="0,1" T="11" Y="353" /><P X="311" P="0,0" T="3" Y="354" /><P X="729" P="0,0" T="11" Y="353" /><P X="672" P="0,1" T="3" Y="356" /><P X="283" P="0,0" T="3" Y="353" /><P X="273" P="0,0" T="3" Y="354" /><P X="353" P="0,1" T="3" Y="353" /><P X="692" P="0,0" T="5" Y="356" /><P X="390" P="0,1" T="3" Y="354" /><P X="706" P="0,0" T="1" Y="356" /><F X="541" Y="149" /><P X="495" P="0,0" T="11" Y="154" /><DS X="122" Y="343" /><DC X="122" Y="341" /></D><O /></Z></C>]]}



--- Map Lists:
-- @TODO: The maps list names may change in future versions, but should eventually be definitive.
-- Listed by Pshy#3752:
pshy.mapdb_maps_tfm_art = {4365311, 5178088, 4164063, 3219677, 3912610, 2981085, 7623034, 5779484, 6736785, 4149609, 4656673, 4346298, 2661228, 3390119, 6287276, 5047342, 3430549, 5377045, 2571307, 2148268, 2388455, 2840043, 7315810}
pshy.mapdb_maps_tfm_art_ext1 = {6522457, 5781406, 3665811, 7513328, 1944538, 4057263, 2922928, 3882463, 3889663, 1803212, 1711836, 2852625, 3466964, 2801395, 2156965, 2623803, 3651831}
pshy.mapdb_maps_tfm_art_ext2 = {5820090, 2641541, 2624724, 2117194, 1778762, 1782034, 1519771, 1728484}
pshy.mapdb_maps_tfm_art_aewingv2 = {3950540, 1916839, 2172603, 154859, 2311296, 1702825, 1947597, 1720912, 3035794, 2243177, 2028226, 1724122, 2605044, 3159424, 2203217, 2661228, 1936506, 2955795, 804667, 2266732, 2623223, 1959434, 2121201, 1695882, 1795000, 1704637, 1792267, 2581086, 663595, 2576455, 2973863, 1942268, 2163526, 1806133, 2521847, 2627056, 2920274, 2767545, 2956808, 2095009, 2226640, 2401105, 1822790, 3246478, 2415437, 3993637, 2149644, 1474863, 2742902, 2145552, 3831792, 1814431, 2195692, 1706288, 1791048, 2577378, 3143355, 2923270, 2391364, 2770692, 2199068, 1904664, 1720281, 3235436, 1749453, 2188489, 2635263, 2945688, 2789609, 2477782, 2433668, 2009802, 2146261, 2749187, 2720487, 2636351, 3119297, 2839982, 1949605, 2802138, 2163526, 1786967, 2055189, 2957089, 1994092, 1964673, 2805172, 3595347, 2707698, 2270344, 2684631, 666106, 2030616, 2700505, 2610838, 2750977, 1855696, 2386489, 2209037, 3205133, 2153314, 1794589, 2097415, 1779011, 1833908, 1992539, 2714086, 3210100, 2705765, 2425475, 2477782, 2454936, 334645, 2571239, 2679669, 3413453, 2542832, 2290792, 3864906, 3326059, 2146340, 1768040, 2074923, 2205008, 2285624, 1989772, 2626828, 2895406, 2348177, 2344972, 2164981, 1715891, 2392654, 2498542, 2621192, 1709589, 1728099, 2078035, 3219677, 1928276, 1807144, 1762785, 2093166, 2240697, 1930228, 1964446, 2586989, 2814018, 2517471, 2255816, 1912443, 1083194, 3190133, 4114443, 1808990, 3171824, 2930435, 1742593, 2789232, 2580252, 1707317, 1765431, 2016716, 2623223, 2165057, 1949415, 2383247, 3097937, 2412122, 2214562, 3120021, 2427867, 3864399, 2549315, 2670766, 3175494, 1728248, 2400240, 3176790, 2186777, 2116858, 1879558, 2760008, 2754663, 2749095, 3656937, 2673363, 2534765, 2649340, 2672948, 2649340, 2525761, 2573397, 2199655, 2578109, 3401577, 2160116, 3478997}
pshy.mapdb_maps_trap_mice = {2914627, 171290, 75050, 923485, 323597, 3295997, 264362, 6937385, 976524, 279568, 3754693, 108982, 1836340, 118564} -- trap maps not requiring a shaman
pshy.mapdb_maps_trap_sham = {3389368, 201192, 1979847, 3659540, 6584338, 171290, 453115, 2680593, 234665, 1493128, 7812024, 1493128, 2447229, 4457285, 6937385, 4405505, 1006122, 344332, 7279280} -- traps triggered by or requiring the shaman
pshy.mapdb_maps_vanilla_troll = {7847625, 4136008, 363251, 7439980}
pshy.mapdb_maps_vanistyle = {7059000, 1378332, 7512702, 7826883, 4003463, 401137, 2999057, 5154237, 1310944, 3688504, 2013190, 1466862, 1280404, 2527971, 389123, 7833268, 7833282, 2174259, 2638619, 1830174, 758488}
pshy.mapdb_maps_sync_or_coop = {6860453, 3828619, 3270078, 4958062, 133508, 3197968, 3203248, 196950, 144888, 1327222, 161177, 3147926, 3325842, 4722827, 7108594, 423796, 7083472, 7041335, 6795659, 6400313, 269622, 1713335, 4848796, 7233643, 117269, 569959, 2808564}
pshy.mapdb_maps_meme = {7466942}
pshy.mapdb_maps_funny = {2453556, 1816586, 4117469, 1408189, 6827968, 7111104, 6980069, 748712, 3344068, 7169831, 7788801, 5781406, 3611575, 7850272, 1928572, 6827968}
pshy.mapdb_maps_minigame_mice = {4140588, 7418736, 6013828, 1959098, 3146116, 250491, 7825263, 7300033}
pshy.mapdb_maps_minigame_sham = {7299396}
pshy.mapdb_maps_custom_racing_list = {4933905, 277517, 333714}
pshy.mapdb_maps_vanilla_vs = {}
pshy.mapdb_maps_hmm = {7273816, 2146239, 7285161, 3344068, 6003432, 6926916, 6189772}
-- Aewing's other troll list (source: https://docs.google.com/spreadsheets/d/1zO9ifeP8EwPOU9LMTFovunl0TDHHcJfrhisooYVHHLc/edit#gid=1143900591 (2017-05-11))
pshy.mapdb_maps_trollmapsv2_other = {6125351, 5900622, 1133326, 383709, 5316364, 5463804, 5482590, 549590, 5574163, 5629308, 5836056, 585024, 585028, 5852789, 5858850, 5875457, 5919103, 5922975, 5966472, 6121905, 6137199, 6162603, 625932, 668003, 690871, 722816, 722820, 731615, 6205708, 6216966, 6216666, 6216605, 6206313, 6396394, 6134379, 6376080, 6453361, 6445328, 6212486, 2711798, 558407, 6296389, 6296422, 6299503, 6096572, 6080913, 6299597, 5940448, 6818735, 6052780, 6883328, 6839471}
-- The Holy Document of Troll Maps v3 (source: https://docs.google.com/spreadsheets/d/1f-ntqw9hidFVvqmNVUU5FyvM6wrA62a8NmOV6h9XX5w (11/01/2021-01-11))
pshy.mapdb_maps_trollmapsv3_vanilla = {5651178, 5018395, 6010060, 6124757, 6123862, 5929021, 6178788, 6127609, 6222523, 6222598, 6222662, 6113351, 6422227, 6575209, 6083498, 6355317, 7306821, 5479119, 5403145, 3067644, 7326348, 7306268, 7797096, 5018481, 5543945, 6122745, 6130459, 6313103, 7307080, 7326356, 7718570, 5966405, 5018508, 5858646, 6127224, 6123442, 5977759, 6135200, 5932565, 6110650, 6526938, 6498941, 6085234, 7326399, 7306953, 7797106, 5018552, 5528077, 7326404, 7307961, 7313763, 7797124, 5018625, 5858647, 1395371, 6207985, 6218403, 6329560, 6345898, 7316626, 7152731, 5622009, 5875455, 6192664, 4888545, 5018731, 7316586, 5858583, 5858585, 5966424, 5966445, 5704644, 6173496, 5436800, 6329565, 5018771, 5719514, 5704627, 6125960, 6127589, 6127747, 6192402, 6184390, 6329568, 6411135, 5994239, 6358824, 7317620, 5018836, 5719492, 5858628, 6124001, 5564186, 6217094, 6649205, 6501429, 7323960, 7318393, 5018961, 5858631, 5640463, 6217035, 6186461, 4040403, 7323461, 7319739, 5019057, 5621250, 6172370, 5436588, 6207483, 6222159, 6062298, 6821665, 7321072, 5019123, 7321926, 5019191, 6126005, 5436981, 4214766, 7322227, 7794773, 5019223, 6501480, 7324070, 6232081, 6232089, 6232095, 6232098, 7797132, 5019302, 5440478, 6526742, 6818892, 6206380, 6695005, 6127550, 6136351, 6217055, 7323482, 6369921, 6108198, 6623156, 6358865, 6883967, 7718563, 5873692, 5019328, 5629311, 5803326, 5858564, 5858586, 5858587, 5966392, 1193082, 6186304, 5543399, 6704726, 5019350, 5719394, 5949452, 6115548, 6477206, 6526318, 6299220, 5019382, 6173592, 6172417, 6772912, 5019421, 6186328, 7321827, 6126256, 5543671, 5019530, 5564274, 6205274, 7324153, 5048881, 6156082, 6277845, 5621395, 5724761, 5724763, 5724765, 6094395, 5565050, 6515469, 6342950, 5605309, 6277853, 6313226, 6819729, 6408356, 7324135, 5049526, 5704629, 7111346, 7323508, 6270048, 6526750, 5910464, 5966432, 5966438, 6126145, 6127710, 6127719, 6377332, 6148478, 6314518, 6299153, 6821666, 6127135, 5621346, 6526760, 6473951, 6452812, 4888705, 5049660, 5875460, 5875461, 5628930, 6172472, 6186377, 6189703, 5910501, 6127290, 6223454, 6838787, 6132502, 6127154, 6332528, 6516797, 5018652, 5836826, 5858595, 5858625, 5858639, 3195916, 6124832, 6127211, 5602310, 7324527, 6244710, 6250422, 6299335, 5595910, 6526776, 6498946, 6813933, 4891010, 6823206, 5858644, 6147952, 6474382, 3765697, 3765697, 5621139, 5621147, 6272568, 6498958, 6836851, 7723923, 5621219, 5910108, 6107893, 6821667, 6190625, 5584431, 6823223, 5605249, 6254763, 5910088, 6119333, 5966429, 5949462, 6203629, 6186396, 6205616, 6207848, 6522504, 4157329, 7322706, 5910104, 6173687, 6116175, 6819107, 7344547, 5910095, 6189594, 6313270, 3711456, 5858581, 5858632, 6104360, 5436707, 6329552, 6400422, 6823081, 6824065, 5803313, 6819128, 6819712, 5649499, 6174089, 5621196, 6125319, 6299508, 7322433, 6205095, 6205714, 6498981, 6715840, 5949349, 6062306, 6580093, 5723872, 5836910, 5858598, 5902874, 6127184, 5591651, 6201987, 6335762, 5858641, 7322471, 5902875, 7324077, 7797162, 6127705, 5605065, 4273525, 6445760, 7270457, 7793398, 6205203, 6100256, 4517700, 6300895, 6473496, 6431883, 5621555, 6411306, 5910116, 6174019, 4273441, 5910077, 6451557, 6573645, 5862868, 5862874, 6192863, 5621716, 5852948, 5854243, 5621865, 6818861, 6122725, 6113306, 6445749, 5836845, 6185835, 6613860, 5050018, 6189570, 2721399, 5875458, 6900569, 6527648, 6400412, 6794502, 6794509, 6794515, 6837067, 6794527, 6794531, 6798232, 6794500, 7276028, 6798283, 7128420, 7097044}
pshy.mapdb_maps_trollmapsv3_racing = {6273752, 6273694, 6418619, 6704790, 6883225, 6901245, 6901260, 6716047, 7106829, 7143225, 7143229, 7143231, 7143235}
pshy.mapdb_maps_trollmapsv3_rotations_noracing = {4759150, 5858703, 5858770, 5859434, 5859447, 5859532, 5859542, 5892506, 5892558, 5902822, 5902827, 5902895, 5918103, 5918111, 5921487, 5966400, 5966408, 5966409, 5966414, 5966418, 5966462, 5966473, 6019882, 6019890, 6019900, 6299490, 6299901, 5949845, 5049453, 5575085, 5858562, 5858669, 5858762, 5859410, 5859501, 5860620, 5863395, 5863423, 5875462, 5875465, 5875466, 5875467, 5966389, 5966417, 5966459, 5966465, 6019894, 6082932, 6122126, 6020836, 1746071, 6242044, 6299312, 6299328, 6299369, 6308474, 5946610, 5946626, 5946613, 4636732, 6902434, 5575159, 5575195, 5858602, 4247610, 6305517, 6305551, 6305617, 6305707, 6314480, 6299413, 6299384, 5946634, 5946669, 5951369, 5951378, 6376011, 6299277, 5951362, 6874219, 7143240, 5049384, 5575096, 5575108, 5621496, 5858558, 5858720, 5858784, 5859579, 5859594, 5859607, 5859617, 5862892, 5863475, 5863515, 5863529, 5863583, 5863631, 5863649, 5863705, 5875449, 5887738, 5902850, 5902868, 5910128, 5966453, 5982510, 5991843, 6019895, 6127308, 6123903, 6123935, 6190773, 6190661, 6190270, 6190252, 6190231, 6190196, 6280663, 6309152, 6309162, 6309194, 6314505, 6316487, 6316519, 6316552, 6627603, 6272125, 6299376, 6299378, 6299380, 6299421, 6418640, 6553484, 6689054, 6389621, 5069907, 6689069, 6627605, 6299426, 5948428, 6823381, 6191953, 5070084, 5278887, 5247557, 5541815, 6340475, 6920196, 6219374, 6105038, 6431185, 5949881, 5982422, 6050752, 6314533, 6036135, 6299351, 6840743, 6839461, 6920189, 6920187, 6920192, 6716039}
-- TODO: Troll Map Submissions 3.0 - pending newests submissions (source: https://atelier801.com/topic?f=6&t=892614&p=1)
pshy.mapdb_maps_trollmapsv3_pending_racing = {}
pshy.mapdb_maps_trollmapsv3_pending_vanilla = {}
pshy.mapdb_maps_trollmapsv3_pending_other = {}
-- Nnaaaz#0000's trolls (source: https://atelier801.com/topic?f=6&t=892706&p=1 (2021-08-23))
pshy.mapdb_maps_nnaaaz_trolls_vanilla = {7805164, 7801845, 7801848, 7801850, 7801929, 7802215, 7802221, 7802404, 7802588, 7802592, 7803100, 7803618, 7803013, 7803900, 7804144, 7804211, 7804405, 7804709, 7804243, 7805109}
pshy.mapdb_maps_nnaaaz_trolls_vanilla_nosham = {7781189, 7781560, 7782831, 7783745, 7787472, 7814117, 7814126, 7814248, 7814488, 7817779}
pshy.mapdb_maps_nnaaaz_trolls_racing = {7781575, 7783458, 7783472, 7784221, 7784236, 7786652, 7786707, 7786960, 7787034, 7788567, 7788596, 7788673, 7788967, 7788985, 7788990, 7789010, 7789484, 7789524, 7790734, 7790746, 7790938, 7791293, 7791550, 7791709, 7791865, 7791877, 7792434, 7765843, 7794331, 7794726, 7792626, 7794874, 7795585, 7796272, 7799753, 7800330, 7800998, 7801670, 7805437, 7792149, 7809901, 7809905, 7810816, 7812751, 7789538, 7813075, 7813248, 7814099, 7819315, 7815695, 7815703, 7816583, 7816748, 7817111, 7782820}
-- Pshy#3752's trolls 
pshy.mapdb_maps_pshy_trolls_vanilla_nosham = {7871137, 7871139, 7871138, 7871140, 7871142, 7871141, 7871143, 7871144, 7871145, 7871146, 7871152, 7871148, 7871147, 7871154, 7871160, 7871158, 7871136, 7876183, 7876188}
pshy.mapdb_maps_pshy_trolls_vanilla_sham = {7871134, 7871157, 7871155, 7876185, 7876194, "v0_noskills"}
pshy.mapdb_maps_pshy_trolls_misc_nosham = {7840661, 7871156, 7871159, 7871161}
pshy.mapdb_maps_racing_troll = {7178114, 399075, 615973}
pshy.mapdb_maps_other_troll = {399075, 615973}
-- Bisammoeen14#7506's trolls (source: https://atelier801.com/topic?f=6&t=892706&p=1#m16)
pshy.mapdb_maps_bisammoeen14_trolls_vanilla = {7819384, 7819386, 7819387, 7819388, 7819389, 7819390, 7819391, 7819394, 7819719, 7819720, 7819721, 7823948, 7823952, 7823954, 7823956, 7823957, 7823958, 7824387, 7824388, 7824390, 7824392} 
-- TODO: Check Aewing's mechanisms originals list
-- The Holy Document of Troll Maps v3 Rotation/Racing (originals) (source: https://docs.google.com/spreadsheets/d/1f-ntqw9hidFVvqmNVUU5FyvM6wrA62a8NmOV6h9XX5w (11/01/2021-01-11))
-- 1405249, 6112855, 2101747, 407294, 1657360, 4645670, 4645670, 4645670, 7021812, 6835898, 6771291, 7062105
-- TODO: Remove racings from other_troll
--todo: 586175 2135750 949687 500601 406463 817645 6245851(getxml) 2270500 2344006 1605979 1871815 1514137 6773628 348918 122333
-- TODO: maps from Kattshup Muntz?
-- harder than vanilla: 3819161
-- sham coop: 5934902 6670220
-- mouse: 6189772
-- fashion map: @7761632



--- Rotations.
-- Basics (Classic/Sham)
pshy.mapdb_rotations["vanilla"]						= {desc = "0-210", duration = 120, items = {900}} for i = 0, 210 do table.insert(pshy.mapdb_rotations["vanilla"].items, i) end
pshy.mapdb_rotations["standard"]					= {desc = "P0", duration = 120, items = {"#0"}}
pshy.mapdb_rotations["protected"]					= {desc = "P1", duration = 120, items = {"#1"}}
pshy.mapdb_rotations["art"]							= {desc = "P5", duration = 120, items = {"#5"}}
pshy.mapdb_rotations["mechanisms"]					= {desc = "P6", duration = 120, items = {"#6"}}
-- Basics (Racing/Nosham)
pshy.mapdb_rotations["racing"]						= {desc = "P17", duration = 60, shamans = 0, items = {"#17"}}
pshy.mapdb_rotations["nosham"]						= {desc = "P7", duration = 60, shamans = 0, items = {"#7"}}
pshy.mapdb_rotations["defilante"]					= {desc = "P18", duration = 60, shamans = 0, items = {"#18"}}
pshy.mapdb_rotations["vanilla_nosham"]				= {desc = "0-210*", duration = 60, shamans = 0, items = {900, 2, 8, 11, 12, 14, 19, 22, 24, 26, 27, 28, 30, 31, 33, 40, 41, 44, 45, 49, 52, 53, 55, 57, 58, 59, 61, 62, 65, 67, 69, 70, 71, 73, 74, 79, 80, 85, 86, 89, 92, 96, 100, 117, 119, 120, 121, 123, 126, 127, 138, 142, 145, 148, 149, 150, 172, 173, 174, 175, 176, 185, 189}}
-- Customs
pshy.mapdb_rotations["mech_racing"]					= {desc = "custom rotation of racing mechanisms", duration = 60, shamans = 0, items = {7821431, 3518087, 1919402, 7264140, 7000017, 7063481, 1749725, 3382919, 176936, 3514715, 3150249, 3506224, 2030030, 479001, 3537313, 1709809, 169959, 313281, 2868361, 73039, 73039, 2913703, 2789826, 298802, 357666, 1472765, 271283, 3702177, 2355739, 4652835, 164404, 7273005, 3061566, 3199177, 157312, 7021280, 2093284, 5752223, 7070948, 3146116, 3613020, 1641262, 119884, 3729243, 1371302, 6854109, 2964944, 3164949, 149476, 155262, 6196297, 1789012, 422271, 3369351, 3138985, 3056261, 5848606, 931943, 181693, 227600, 2036283, 6556301, 3617986, 314416, 3495556, 3112905, 1953614, 2469648, 3493176, 1009321, 221535, 2377177, 6850246, 5761423, 211171, 1746400, 1378678, 246966, 2008933, 2085784, 627958, 1268022, 2815209, 1299248, 6883670, 3495694, 4678821, 2758715, 1849769, 3155991, 6555713, 3477737, 873175, 141224, 2167410, 2629289, 2888435, 812822, 4114065, 2256415, 3051008, 7300333, 158813, 3912665, 6014154, 163756, 3446092, 509879, 2029308, 5546337, 1310605, 1345662, 2421802, 2578335, 2999901, 6205570, 7242798, 756418, 2160073, 3671421, 5704703, 3088801, 7092575, 3666756, 3345115, 1483745, 3666745, 2074413, 2912220, 3299750}}
pshy.mapdb_rotations["nosham_simple"]				= {desc = nil, duration = 120, shamans = 0, items = {1378332, 485523, 7816865, 763608, 1616913, 383202, 2711646, 446656, 815716, 333501, 7067867, 973782, 763961, 7833293, 7833270, 7833269, 7815665, 7815151, 7833288, 1482492, 1301712, 6714567, 834490, 712905, 602906, 381669, 4147040, 564413, 504951, 1345805, 501364}} -- soso @1356823 @2048879 @2452915 @2751980
pshy.mapdb_rotations["nosham_traps"]				= {desc = nil, duration = 120, shamans = 0, items = {297063, 5940448, 2080757, 7453256, 203292, 108937, 445078, 133916, 7840661, 115767, 2918927, 4684884, 2868361, 192144, 73039, 1836340, 726048}}
pshy.mapdb_rotations["nosham_coop"]					= {desc = nil, duration = 120, shamans = 0, items = {169909, 209567, 273077, 7485555, 2618581, 133916, 144888, 1991022, 7247621, 3591685, 6437833, 3381659, 121043, 180468, 220037, 882270, 3265446}}
pshy.mapdb_rotations["minigame_maps"]				= {desc = nil, duration = 120, shamans = 0, items = pshy.mapdb_maps_minigame_mice}
pshy.mapdb_rotations["tfm_art"]						= {desc = "for TFM addicts", duration = 120, items = {}, unique_items = true}
pshy.ListAppend(pshy.mapdb_rotations["tfm_art"].items, pshy.mapdb_maps_tfm_art)
pshy.ListAppend(pshy.mapdb_rotations["tfm_art"].items, pshy.mapdb_maps_tfm_art_ext1)
--pshy.ListAppend(pshy.mapdb_rotations["tfm_art"].items, pshy.mapdb_maps_tfm_art_ext2)
pshy.ListAppend(pshy.mapdb_rotations["tfm_art"].items, pshy.mapdb_maps_tfm_art_aewingv2)
pshy.mapdb_rotations["vanilla_like"]				= {desc = nil, duration = 120, shamans = 0, items = pshy.mapdb_maps_vanistyle}
-- Vanilla VS:
--pshy.mapdb_rotations["vanilla_vs"]				= {desc = "nosham vanilla racing", duration = 60, shamans = 0, items = pshy.mapdb_maps_vanilla_vs}
-- Trolls
pshy.mapdb_rotations["vanilla_troll"]				= {desc = "vanilla troll maps", duration = 120, troll = true, items = {}, unique_items = true}
pshy.ListAppend(pshy.mapdb_rotations["vanilla_troll"].items, pshy.mapdb_maps_trollmapsv3_vanilla)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_troll"].items, pshy.mapdb_maps_nnaaaz_trolls_vanilla)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_troll"].items, pshy.mapdb_maps_pshy_trolls_vanilla_nosham)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_troll"].items, pshy.mapdb_maps_pshy_trolls_vanilla_sham)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_troll"].items, pshy.mapdb_maps_trollmapsv3_pending_vanilla)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_troll"].items, pshy.mapdb_maps_bisammoeen14_trolls_vanilla)
pshy.mapdb_rotations["vanilla_nosham_troll"]		= {desc = "trolls for vanilla racings", duration = 60, shamans = 0, troll = true, items = {}, unique_items = true}
pshy.ListAppend(pshy.mapdb_rotations["vanilla_nosham_troll"].items, pshy.mapdb_maps_pshy_trolls_vanilla_nosham)
pshy.mapdb_rotations["racing_troll"]				= {desc = "trolls for racings", duration = 60, shamans = 0, troll = true, items = {}, unique_items = true}
pshy.ListAppend(pshy.mapdb_rotations["racing_troll"].items, pshy.mapdb_maps_trollmapsv3_racing)
pshy.ListAppend(pshy.mapdb_rotations["racing_troll"].items, pshy.mapdb_maps_nnaaaz_trolls_racing)
pshy.ListAppend(pshy.mapdb_rotations["racing_troll"].items, pshy.mapdb_maps_trollmapsv3_pending_racing)
pshy.ListAppend(pshy.mapdb_rotations["racing_troll"].items, pshy.mapdb_maps_racing_troll)
pshy.mapdb_rotations["other_troll"]					= {desc = "misc trolls", duration = 120, troll = true, items = {}, unique_items = true}
pshy.ListAppend(pshy.mapdb_rotations["other_troll"].items, pshy.mapdb_maps_trollmapsv2_other)
pshy.ListAppend(pshy.mapdb_rotations["other_troll"].items, pshy.mapdb_maps_pshy_trolls_misc_nosham)
pshy.ListAppend(pshy.mapdb_rotations["other_troll"].items, pshy.mapdb_maps_trollmapsv3_rotations_noracing)
pshy.ListAppend(pshy.mapdb_rotations["other_troll"].items, pshy.mapdb_maps_trollmapsv3_pending_other)
pshy.mapdb_rotations["traps"]						= {desc = "sham and no-sham traps", duration = 120, troll = false, items = {}, unique_items = true}
pshy.ListAppend(pshy.mapdb_rotations["traps"].items, pshy.mapdb_maps_trap_mice)
pshy.ListAppend(pshy.mapdb_rotations["traps"].items, pshy.mapdb_maps_trap_sham)
