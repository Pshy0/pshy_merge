--- pshy_luaperftest.lua
--
-- Test the performances of some lua basic features.
--
-- To do so, functions using the feature 100 times are called.
-- The time taken is measured.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_keycodes.lua
-- @require pshy_perms.lua
-- @require pshy_timing.lua



--- Test Map:
-- every test perform an operation 100 times.
local tests = {}



-- Test "os.time()":
tests["os.time()"] = function()
	for i = 1, 10 do
		os.time()
		os.time()
		os.time()
		os.time()
		os.time()
		os.time()
		os.time()
		os.time()
		os.time()
		os.time()
	end
end



-- Test "numeric_for_iteration":
tests["numeric_for_iteration"] = function()
	for i = 1, 10 do
		for j = 1, 10 do
		end
	end
end



-- Test "ipairs_iteration":
local test_ipairs_table = {"az", "po", "ml", "nj", "op", "ze", "et", "qf", "qo", "ja"}
tests["ipairs_iteration"] = function()
	for i = 1, 10 do
		for key, value in ipairs(test_ipairs_table) do
		end
	end
end



-- Test "pairs_iteration":
local test_pairs_table = {"az" = 1, "po" = 2, "ml" = 3, "nj" = 4, "op" = 5, "ze" = 6, "et" = 7, "qf" = 8, "qo" = 9, "ja" = 10}
tests["pairs_iteration"] = function()
	for i = 1, 10 do
		for key, value in pairs(test_pairs_table) do
		end
	end
end



-- Test "local=int":
local test_local_eq_int
tests["local=int"] = function()
	for i = 1, 10 do
		test_local_eq_int = 6
		test_local_eq_int = 1
		test_local_eq_int = 4
		test_local_eq_int = 2
		test_local_eq_int = 8
		test_local_eq_int = 9
		test_local_eq_int = 5
		test_local_eq_int = 7
		test_local_eq_int = 0
		test_local_eq_int = 3
	end
end



-- Test "local=string":
local test_local_eq_str
tests["local=string"] = function()
	for i = 1, 10 do
		test_local_eq_str = "66666666"
		test_local_eq_str = "11111111"
		test_local_eq_str = "44444444"
		test_local_eq_str = "22222222"
		test_local_eq_str = "88888888"
		test_local_eq_str = "99999999"
		test_local_eq_str = "55555555"
		test_local_eq_str = "77777777"
		test_local_eq_str = "00000000"
		test_local_eq_str = "33333333"
	end
end



-- Test "global=":
test_global_eq = -1
tests["global=int"] = function()
	for i = 1, 10 do
		test_global_eq = 6
		test_global_eq = 1
		test_global_eq = 4
		test_global_eq = 2
		test_global_eq = 8
		test_global_eq = 9
		test_global_eq = 5
		test_global_eq = 7
		test_global_eq = 0
		test_global_eq = 3
	end
end



-- Test "call()":
local function test_call()
end
tests["call()"] = function()
	for i = 1, 10 do
		test_call()
		test_call()
		test_call()
		test_call()
		test_call()
		test_call()
		test_call()
		test_call()
		test_call()
		test_call()
	end
end



-- Test "pass_arg(ints)":
local function test_pass_arg(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
end
tests["pass_arg(ints)"] = function()
	test_pass_arg(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
	test_pass_arg(0, 2, 3, 4, 5, -4, 7, 3, 9, 1)
	test_pass_arg(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
	test_pass_arg(0, 2, 3, 4, 5, -4, 7, 6, 9, 1)
	test_pass_arg(1, 2, 2, 4, 2, 6, 7, 8, 4, 10)
	test_pass_arg(0, 2, 3, 4, 5, -4, 7, 6, 9, 1)
	test_pass_arg(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
	test_pass_arg(0, 1, 3, 4, 5, -4, 7, 6, 9, 1)
	test_pass_arg(1, 2, 3, 4, 5, 6, 7, 2, 9, 10)
	test_pass_arg(0, 2, 3, 4, 5, -4, 7, 6, 9, 1)
end



-- Test "pass_arg(strings)":
local function test_pass_str(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
end
tests["pass_arg(strings)"] = function()
	test_pass_str("11111111", "22222222", "33333333", "44444444", "55555555", "66666666", "77777777", "88888888", "99999999", "99991010")
	test_pass_str("aaaaaaaa", "bbbbbbbb", "cccccccc", "44444444", "55555555", "66666666", "77777777", "88888888", "99999999", "vvvvvvvv")
	test_pass_str("11111111", "22222222", "33333333", "44444444", "55555555", "66666666", "77777777", "88888888", "99999999", "99991010")
	test_pass_str("aaaaaaaa", "bbbbbbbb", "cccccccc", "44444444", "55555555", "66666666", "77777777", "88888888", "99999999", "vvvvvvvv")
	test_pass_str("11111111", "22222222", "33333333", "44444444", "55555555", "66666666", "77777777", "88888888", "99999999", "99991010")
	test_pass_str("aaaaaaaa", "bbbbbbbb", "cccccccc", "44444444", "55555555", "66666666", "77777777", "88888888", "99999999", "vvvvvvvv")
	test_pass_str("11111111", "22222222", "33333333", "44444444", "55555555", "66666666", "77777777", "88888888", "99999999", "99991010")
	test_pass_str("aaaaaaaa", "bbbbbbbb", "cccccccc", "dddddddd", "55555555", "66666666", "77777777", "88888888", "99999999", "vvvvvvvv")
	test_pass_str("11111111", "22222222", "33333333", "44444444", "55555555", "66666666", "77777777", "88888888", "99999999", "99991010")
	test_pass_str("aaaaaaaa", "bbbbbbbb", "cccccccc", "44444444", "uuuuuuuu", "66666666", "77777777", "88888888", "99999999", "vvvvvvvv")
end



-- Test "call()":
local function call()
end
tests["call()"] = function()
	for i = 1, 10 do
		call()
		call()
		call()
		call()
		call()
		call()
		call()
		call()
		call()
		call()
	end
end



-- Test "string==string":
local function call()
end
tests["string==string"] = function()
	for i = 1, 10 do
		if "aaze" == "qzdqzdz" then end
		if "sdqsd" == "4444" then end
		if "aasqdsdze" == "qzdqzdz" then end
		if "aaqsdqze" == "aaqsdqze" then end
		if "aazqsdqe" == "444" then endz
		if "aadsqze" == "qzdq44zdz" then end
		if "aaqze" == "qzd4qzdz" then end
		if "aqsaze" == "aqsaze" then end
		if "asqdaze" == "qzdqzdz" then end
		if "aadsqdze" == "qzdqzdz" then end
	end
end



--- Run a test by index.
local function RunTest(test_key)
	local func = tests[test_index]
	pshy_timing_Start(test_key)
	func()
	pshy_timing_Stop(test_key)
end



--- Main method running several tests.
local function RunTests()
	local tmp_keys = {}
	for key in pairs(tests) do
		table.insert(tmp_keys, key)
	end
	local random_keys = {}
	while #tmp_keys > 0 do
		local remove_index = math.random(1, #tmp_keys)
		rable.insert(random_keys, tmp_keys[remove_index])
		table.remove(tmp_keys, remove_index)
	end
	for n_test, test_key in pairs(random_keys) do
		RunTest(test_key)
	end
end



local function eventKeyboard(player_name, keycode, down, x, y)
	if keycode == pshy.keycodes.F1 and down and player_name == pshy.loader then
		RunTests()
	end
	if keycode == pshy.keycodes.F2 and down and player_name == pshy.loader then
		pshy.timing_PrintMeasures()
	end
end



function eventInit()
	system.bindKeyboard(pshy.loader, pshy.keycodes.F1, true, true)
	tfm.exec.chatMessage("<vi>[TEST] Press F1 to run performance measures.</vi>", pshy.loader)
	system.bindKeyboard(pshy.loader, pshy.keycodes.F2, true, true)
	tfm.exec.chatMessage("<vi>[TEST] Press F2 to display results.</vi>", pshy.loader)
end
