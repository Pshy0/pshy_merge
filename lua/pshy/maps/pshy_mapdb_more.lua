--- pshy_mapdb_more.lua
--
-- Additional maps and rotations to extend `pshy_mapdb.lua`.
--
-- @author: TFM:Pshy#3752 DC:Pshy#7998 (script)
--
-- @require pshy_mapdb.lua
-- @require pshy_utils_tables.lua



--- Map Lists:
-- @TODO: The maps list names may change in future versions, but should eventually be definitive.
-- Listed by Pshy#3752:
pshy.mapdb_maps_tfm_art = {3580460, 3678933, 3566536, 3395336, 7205612, 3934734, 4365311, 5178088, 4164063, 3219677, 3912610, 2981085, 7623034, 5779484, 6736785, 4149609, 4656673, 4346298, 2661228, 3390119, 6287276, 5047342, 3430549, 5377045, 2571307, 2148268, 2388455, 2840043, 7315810, 5226799}
pshy.mapdb_maps_tfm_art_ext1 = {3582445, 7853185, 2442606, 4586150, 4675706, 5257496, 4973378, 6522457, 5781406, 3665811, 7513328, 1944538, 4057263, 2922928, 3882463, 3889663, 1803212, 1711836, 2852625, 3466964, 2801395, 2156965, 2623803, 3651831}
pshy.mapdb_maps_tfm_art_ext2 = {1778870, 5961606, 5820090, 2641541, 2624724, 2117194, 1778762, 1782034, 1519771, 1728484}
pshy.mapdb_maps_tfm_art_aewingv2 = {3950540, 1916839, 2172603, 154859, 2311296, 1702825, 1947597, 1720912, 3035794, 2243177, 2028226, 1724122, 2605044, 3159424, 2203217, 2661228, 1936506, 2955795, 804667, 2266732, 2623223, 1959434, 2121201, 1695882, 1795000, 1704637, 1792267, 2581086, 663595, 2576455, 2973863, 1942268, 2163526, 1806133, 2521847, 2627056, 2920274, 2767545, 2956808, 2095009, 2226640, 2401105, 1822790, 3246478, 2415437, 3993637, 2149644, 1474863, 2742902, 2145552, 3831792, 1814431, 2195692, 1706288, 1791048, 2577378, 3143355, 2923270, 2391364, 2770692, 2199068, 1904664, 1720281, 3235436, 1749453, 2188489, 2635263, 2945688, 2789609, 2477782, 2433668, 2009802, 2146261, 2749187, 2720487, 2636351, 3119297, 2839982, 1949605, 2802138, 2163526, 1786967, 2055189, 2957089, 1994092, 1964673, 2805172, 3595347, 2707698, 2270344, 2684631, 666106, 2030616, 2700505, 2610838, 2750977, 1855696, 2386489, 2209037, 3205133, 2153314, 1794589, 2097415, 1779011, 1833908, 1992539, 2714086, 3210100, 2705765, 2425475, 2454936, 334645, 2571239, 2679669, 3413453, 2542832, 2290792, 3864906, 3326059, 2146340, 1768040, 2074923, 2205008, 2285624, 1989772, 2626828, 2895406, 2348177, 2344972, 2164981, 1715891, 2392654, 2498542, 2621192, 1709589, 1728099, 2078035, 3219677, 1928276, 1807144, 1762785, 2093166, 2240697, 1930228, 1964446, 2586989, 2814018, 2517471, 2255816, 1912443, 1083194, 3190133, 4114443, 1808990, 3171824, 2930435, 1742593, 2789232, 2580252, 1707317, 1765431, 2016716, 2623223, 2165057, 1949415, 2383247, 3097937, 2412122, 2214562, 3120021, 2427867, 3864399, 2549315, 2670766, 3175494, 1728248, 2400240, 3176790, 2186777, 2116858, 1879558, 2760008, 2754663, 2749095, 3656937, 2673363, 2534765, 2649340, 2672948, 2649340, 2525761, 2573397, 2199655, 2578109, 3401577, 2160116, 3478997}
pshy.mapdb_maps_vanistyle = {1677202, 3497933, 690334, 7227540, 3583744, 1345447, 1744845, 2908950, 5487150, 2152053, 933074, 1411844, 2715035, 7126330, 4901402, 959187, 7257395, 3881440, 1396768, 3065717, 1879480, 1300215, 1276300, 1927363, 1927475, 3399799, 986241, 2045218, 326777, 2872578, 1929346, 886573, 7221109, 3558594, 1904494, 625224, 4011152, 1676255, 956030, 3919642, 3999440, 7022248, 3251691, 233256, 238365, 7059000, 1378332, 7512702, 7826883, 4003463, 401137, 2999057, 5154237, 1310944, 3688504, 2013190, 1466862, 1280404, 2527971, 389123, 7833268, 7833282, 2174259, 2638619, 1830174, 758488}
pshy.mapdb_maps_sync_or_coop = {2574738, 6860453, 3828619, 3270078, 4958062, 133508, 3197968, 3203248, 196950, 144888, 1327222, 161177, 3147926, 3325842, 4722827, 7108594, 423796, 7083472, 7041335, 6795659, 6400313, 269622, 1713335, 4848796, 7233643, 117269, 569959, 2808564}
pshy.mapdb_maps_meme = {7466942}
pshy.mapdb_maps_funny = {2453556, 1816586, 4117469, 1408189, 6827968, 7111104, 6980069, 748712, 3344068, 7169831, 7788801, 5781406, 3611575, 7850272, 1928572, 6827968}
pshy.mapdb_maps_minigame_mice = {6530982, 6693550, 4143127, 4140588, 7418736, 6013828, 1959098, 3146116, 250491, 7825263, 7300033, 7637845, 7867573, 7867574, 7867575, 6509155}
pshy.mapdb_maps_minigame_sham = {7299396}
pshy.mapdb_maps_custom_racing_list = {4933905, 277517, 333714}
pshy.mapdb_maps_hmm = {7273816, 2146239, 7285161, 3344068, 6003432, 6926916, 6189772}
pshy.mapdb_maps_learn = {185985, 229834, 233230, 1364063, 1132639}
-- chain racing: 3518418
-- TODO: maps from Kattshup Muntz?
-- harder than vanilla: 3819161
-- sham coop: 5934902 6670220
-- mouse: 6189772
-- fashion map: @7761632
-- cute: 3477640 7725885
-- alien: 1762519
-- newen: 7841150
-- dinosaurs: 3572111
-- adventure: 7850261



-- Basics
pshy.mapdb_rotations["vanilla_nosham"]				= {desc = "0-210*", duration = 60, shamans = 0, items = {2, 8, 11, 12, 14, 19, 22, 24, 26, 27, 28, 30, 31, 33, 40, 41, 44, 45, 49, 52, 53, 55, 57, 58, 59, 61, 62, 65, 67, 69, 70, 71, 73, 74, 79, 80, 85, 86, 89, 92, 96, 100, 117, 119, 120, 121, 123, 126, 127, 138, 142, 145, 148, 149, 150, 172, 173, 174, 175, 176, 185, 189}}
-- Customs
pshy.mapdb_rotations["mech_racing"]					= {desc = "custom rotation of racing mechanisms", duration = 60, shamans = 0, items = {7821431, 3518087, 1919402, 7264140, 7000017, 7063481, 1749725, 3382919, 176936, 3514715, 3150249, 3506224, 2030030, 479001, 3537313, 1709809, 169959, 313281, 2868361, 73039, 73039, 2913703, 2789826, 298802, 357666, 1472765, 271283, 3702177, 2355739, 4652835, 164404, 7273005, 3061566, 3199177, 157312, 7021280, 2093284, 5752223, 7070948, 3146116, 3613020, 1641262, 119884, 3729243, 1371302, 6854109, 2964944, 3164949, 149476, 155262, 6196297, 1789012, 422271, 3369351, 3138985, 3056261, 5848606, 931943, 181693, 227600, 2036283, 6556301, 3617986, 314416, 3495556, 3112905, 1953614, 2469648, 3493176, 1009321, 221535, 2377177, 6850246, 5761423, 211171, 1746400, 1378678, 246966, 2008933, 2085784, 627958, 1268022, 2815209, 1299248, 6883670, 3495694, 4678821, 2758715, 1849769, 3155991, 6555713, 3477737, 873175, 141224, 2167410, 2629289, 2888435, 812822, 4114065, 2256415, 3051008, 7300333, 158813, 3912665, 6014154, 163756, 3446092, 509879, 2029308, 5546337, 1310605, 1345662, 2421802, 2578335, 2999901, 6205570, 7242798, 756418, 2160073, 3671421, 5704703, 3088801, 7092575, 3666756, 3345115, 1483745, 3666745, 2074413, 2912220, 3299750}}
pshy.mapdb_rotations["nosham_simple"]				= {desc = nil, duration = 120, shamans = 0, items = {1378332, 485523, 7816865, 763608, 1616913, 383202, 2711646, 446656, 815716, 333501, 7067867, 973782, 763961, 7833293, 7833270, 7833269, 7815665, 7815151, 7833288, 1482492, 1301712, 6714567, 834490, 712905, 602906, 381669, 4147040, 564413, 504951, 1345805, 501364}} -- soso @1356823 @2048879 @2452915 @2751980

pshy.mapdb_rotations["nosham_coop"]					= {desc = nil, duration = 120, shamans = 0, items = {169909, 209567, 273077, 7485555, 2618581, 133916, 144888, 1991022, 7247621, 3591685, 6437833, 3381659, 121043, 180468, 220037, 882270, 3265446}}
pshy.mapdb_rotations["minigame_maps"]				= {desc = nil, duration = 120, shamans = 0, items = pshy.mapdb_maps_minigame_mice}
pshy.mapdb_rotations["tfm_art"]						= {desc = "for TFM addicts", duration = 120, items = {}, unique_items = true}
pshy.ListAppend(pshy.mapdb_rotations["tfm_art"].items, pshy.mapdb_maps_tfm_art)
pshy.ListAppend(pshy.mapdb_rotations["tfm_art"].items, pshy.mapdb_maps_tfm_art_ext1)
--pshy.ListAppend(pshy.mapdb_rotations["tfm_art"].items, pshy.mapdb_maps_tfm_art_ext2)
pshy.ListAppend(pshy.mapdb_rotations["tfm_art"].items, pshy.mapdb_maps_tfm_art_aewingv2)
pshy.mapdb_rotations["vanilla_like"]				= {desc = nil, duration = 120, items = pshy.mapdb_maps_vanistyle}
