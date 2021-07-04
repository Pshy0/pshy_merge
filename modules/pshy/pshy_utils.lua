--- pshy_uyils.lua
--
-- This module contains basic functions.
--
-- @author DC:Pshy#7998 TFM:Pshy#3752
-- @hardmerge
-- @namespace pshy
-- @require pshy_perms.lua
pshy = pshy and pshy or {}



--- Simulate the behavior of lua unpack for arrays of up to 8 args
-- @param t table to unpack
function pshy.Unpack(t)
	if #t == 0 then return end
	if #t == 1 then return t[1] end
	if #t == 2 then return t[1], t[2] end
	if #t == 3 then return t[1], t[2], t[3] end
	if #t == 4 then return t[1], t[2], t[3], t[4] end
	if #t == 5 then return t[1], t[2], t[3], t[4], t[5] end
	if #t == 6 then return t[1], t[2], t[3], t[4], t[5], t[6] end
	if #t == 7 then return t[1], t[2], t[3], t[4], t[5], t[6], t[7] end
	if #t == 8 then return t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8] end
	error("not supported unpack count")
end



--- Print a message to the host
function pshy.Log(msg)
	tfm.exec.chatMessage("log: " .. tostring(msg), pshy.host)
	print("log: " .. tostring(msg))
end



--- Show the dialog window with a message (simplified)
function pshy.Popup(player_name, message)
	ui.addPopup(4097, 0, tostring(message), player_name, 40, 20, 720, true)
end



--- Show a html title at the top of the screen.
-- @param html The html to display, or nil to hide.
-- @param player_name The player name to display the title to, or nil for all players.
function pshy.Title(html, player_name)
	html = html or nil
	player_name = player_name or nil
	local title_id = 82 -- arbitrary random id
	if html then
		ui.addTextArea(title_id, html, player_name, 0, 0, 800, nil, 0x000000, 0x000000, 1.0, true)
	else
		ui.RemoveTextArea(title_id, player_name)
	end
end



--- string.isalnum(str)
-- us this instead: `not str:match("%W")`


--- Count keys in a map table
function pshy.TableCountKeys(t)
	local count = 0
	for key, value in pairs(t) do
		count = count + 1	
	end
	return count
end



--- Split a string
-- @param str String to split.
-- @param separator Char to split at, default to whitespaces.
-- @param max Max amount of returned strings.
function pshy.StrSplit(str, separator, max)
	assert(type(str) == "string", debug.traceback())
	separator = separator or "%s"
	max = max or -1
	remlen = #str
	local parts = {}
	for part in string.gmatch(str, "([^" .. separator .. "]+)") do
		if max == 1 and remlen >= 0 then
			table.insert(parts, string.sub(str, -remlen))
			return parts
		end
		table.insert(parts, part)
		remlen = remlen - #part - 1
		max = max - 1
	end
	return parts
end



--- Convert a string to a boolean
-- @param string "true" or "false", or numbers 0 and 1
-- @return boolean true or false, or nil
function pshy.ToBoolean(value)
	if value == "true" or value == "1" then
		return true
	end
	if value == "false" or value == "0" then
		return false
	end
	return nil
end



--- Interpret a namespace expression (resolve lua path from string)
-- @param path lua path (such as "tfm.enum.bonus")*
-- @return the object represented by path or nil if not found
function pshy.LuaGet(path)
	assert(type(path) == "string", debug.traceback())
	local parts = pshy.StrSplit(path, ".")
	local cur = _G
	for index, value in pairs(parts) do
		cur = cur[value]
		if cur == nil then
			return nil
		end
	end
	return cur
end



--- Set the value to a lua object.
-- The path is created if it does not exist.
-- @param obj_path Lua path to the object.
-- @param value Value to set, any type.
function pshy.LuaSet(obj_path, value)
	assert(type(obj_path) == "string", debug.traceback())
	local parts = pshy.StrSplit(obj_path, ".")
	local cur = _G
	for i_part, part in pairs(parts) do
		if i_part == #parts then
			-- last iteration
			cur[part] = value
			return cur[part]
		end
		cur[part] = cur[part] or {}
		if type(cur) ~= "table" then
			return nil
		end
		cur = cur[part]
	end
	error("unreachable code")
end



--- Get a random key from a table.
function pshy.LuaRandomTableKey(t)
	local keylist = {}
	for k in pairs(t) do
	    table.insert(keylist, k)
	end
	return keylist[math.random(#keylist)]
end



--- Convert a tfm anum index to an interger, searching in all tfm enums.
-- Search in bonus, emote, ground, particle and shamanObject.
-- @param index a string, either representing a tfm enum value or integer.
-- @return the existing enum value or nil
function pshy.TFMEnumGet(index)
	assert(type(index) == "string")
	local value
	for enum_name, enum in pairs(tfm.enum) do
		value = enum[index]
		if value then
			return value
		end
	end
	return nil
end



--- Convert a string value to the given type.
-- nil value is not supported for bool, number and string
-- @param value String to convert.
-- @param type string representing the type to convert to.
-- @return the same value represented by the best type possible (bool/number/string).
function pshy.ToType(value, t)
	assert(type(value) == "string", "wrong argument type")
	assert(type(t) == "string", "wrong argument type")
	-- boolean
	if t == "bool" or t == "boolean" then
		return pshy.ToBoolean(value)
	end
	-- number
	if t == "number" then
		return tonumber(value)
	end
	-- string
	if t == "string" then
		return value
	end
	-- nil
	if value == "nil" then
		return nil
	end
	-- enums
	local enum = pshy.LuaGet(t)
	if type(enum) == "table" then
		return enum[value]
	end
	-- not supported
	error("type not supported")
end



--- Convert an argument to anoter type automatically.
-- @param value String to convert.
-- @return the same value represented by the best type possible (bool/number/string).
function pshy.AutoType(value)
	assert(type(value) == "string", "wrong argument type")
	local rst
	-- nil
	if value == "nil" then
		return nil
	end
	-- boolean
	if value == "true" then
		return true
	end
	if value == "false" then
		return false
	end
	-- number
	rst = tonumber(value, 10)
	if rst then
		return rst
	end
	-- empty table
	if value == "{}" then
		return {}
	end
	-- tfm enums
	rst = pshy.TFMEnumGet(value)
	if rst then
		return rst
	end
	-- lua object
	rst = pshy.LuaGet(value)
	if rst then
		return rst
	end
	-- color code / hex number
	if string.sub(value, 1, 1) == '#' then
		rst = tonumber(string.sub(value, 2, #value), 16)
		if rst then
			return rst
		end
	end
	-- string
	return value
end



--- Convert string arguments of a table to the specified types, 
-- or attempt to guess the types.
-- @param args Table of elements to convert.
-- @param types Table of types.
function pshy.TableStringsToType(args, types)
	for index = 1, #args do
		if types and index <= #types then
			args[index] = pshy.ToType(args[index], types[index])
		else
			args[index] = pshy.AutoType(args[index])
		end
	end	
end



--- Apply default pshy's setup for TFM.
-- @param is_vanilla Boolean value (default false) indicating if 
-- this game will be based on a vanilla game mode (not necessarily "vanilla").
function pshy.DefaultTFMSetup(is_vanilla)
	--tfm.exec.disableAfkDeath(true)
	tfm.exec.disableMortCommand(true)
	tfm.exec.disableDebugCommand(true)
	tfm.exec.disableWatchCommand(true)
	tfm.exec.disableMinimalistMode(true)
	--tfm.exec.setAutoMapFlipMode(nil)
	if not is_vanilla then
		tfm.exec.disableAutoTimeLeft(true)
		tfm.exec.setGameTime(0, true)
		tfm.exec.disableAutoNewGame(true)
		tfm.exec.disableAutoScore(true)
		tfm.exec.disableAutoShaman(true)
		tfm.exec.disableAllShamanSkills(true)
		tfm.exec.setAutoMapFlipMode(false)
		tfm.exec.disablePhysicalConsumables(true)
		--tfm.exec.disablePrespawnPreview(true)
	end
	system.disableChatCommandDisplay(nil, true)
end



--- Get how many players are alive in tfm.get
function pshy.CountPlayersAlive()
	local count = 0
	for player_name, player in pairs(tfm.get.room.playerList) do
		if not player.isDead then
			count = count + 1
		end
	end
	return count
end



--- Random TFM objects
-- List of objects for random selection.
pshy.random_objects = {}
table.insert(pshy.random_objects, 1) -- little box
table.insert(pshy.random_objects, 2) -- box
table.insert(pshy.random_objects, 3) -- little board
table.insert(pshy.random_objects, 6) -- ball
table.insert(pshy.random_objects, 7) -- trampoline
table.insert(pshy.random_objects, 10) -- anvil
table.insert(pshy.random_objects, 17) -- cannon
table.insert(pshy.random_objects, 33) -- chicken
table.insert(pshy.random_objects, 39) -- apple
table.insert(pshy.random_objects, 40) -- sheep
table.insert(pshy.random_objects, 45) -- little board ice
table.insert(pshy.random_objects, 54) -- ice cube
table.insert(pshy.random_objects, 68) -- triangle
table.insert(pshy.random_objects, 85) -- rock
--- Get a random TFM object
function pshy.RandomTFMObjectId()
	return pshy.random_objects[math.random(1, #pshy.random_objects)]
end
--- Spawn a random TFM object in the sky.
function pshy.SpawnRandomTFMObject()
	tfm.exec.addShamanObject(pshy.RandomTFMObjectId(), math.random(200, 600), -60, math.random(0, 359), 0, 0, math.random(0, 8) == 0)
end
