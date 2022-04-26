--- pshy_utils_tables.lua
--
-- Basic functions related to LUA tables.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @hardmerge
pshy = pshy or {}



--- Copy a table.
-- @param t The table to copy.
-- @return a copy of the table.
-- disabled because not used
function pshy.TableCopy(t)
	assert(type(t) == "table")
	local new_table = {}
	for key, value in pairs(t) do
		new_table[key] = value
	end
	return new_table
end



--- Copy a table, recursively.
-- @param t The table to copy.
-- @return a copy of the table.
function pshy.TableDeepCopy(t)
	assert(type(t) == "table")
	local new_table = {}
	for key, value in pairs(t) do
		if type(value) == "table" then
			value = pshy.TableDeepCopy(value)
		end
		new_table[key] = value
	end
	return new_table
end



--- Copy a list table.
-- @param t The list table to copy.
-- @return a copy of the list table.
function pshy.ListCopy(t)
	assert(type(t) == "table")
	local new_table = {}
	for key, value in ipairs(t) do
		table.insert(new_table, value)
	end
	return new_table
end



--- Get a table's keys as a list.
-- @public
-- @param t The table.
-- @return A list of the keys from the given table.
function pshy.TableKeys(t)
	local keys = {}
	for key in pairs(t) do
		table.insert(keys, key)
	end
	return keys
end



--- Get a table's keys as a sorted list.
-- @public
-- @param t The table.
-- @return A list of the keys from the given table, sorted.
function pshy.TableSortedKeys(t)
	local keys = pshy.TableKeys(t)
	table.sort(keys)
	return keys
end



--- Count the keys in a table.
-- @public
-- @param t The table.
-- @return The count of keys in the given table.
function pshy.TableCountKeys(t)
	local count = 0
	for key, value in pairs(t) do
		count = count + 1	
	end
	return count
end



--- Check if a table has any key.
-- @public
-- @param t The table.
-- @return true if the table contains a key.
-- disabled because not used
--function pshy.TableHasAnyKey(t)
--	for key in pairs(t) do
--		return true
--	end
--	return false
--end



--- Remove duplicates in a sorted list.
-- @return Count of removed items.
function pshy.SortedListRemoveDuplicates(t)
	local prev_size = #t
	local i = #t - 1
	while i >= 1 do
		if t[i] == t[i + 1] then
			table.remove(t, i + 1)
		end
		i = i - 1
	end
	return prev_size - #t
end



--- Remove duplicates in a table.
-- @return Count of removed items.
-- disabled because not used
--function pshy.TableRemoveDuplicates(t)
--	local prev_size = #t
--	local keys = {}
--	local i = #t
--	while i >= 1 do
--		if keys[t[i]] then
--			table.remove(t, i + 1)
--		else
--			keys[t[i]] = true
--		end
--		i = i - 1
--	end
--	return prev_size - #t
--end



--- Append a list to another.
-- @param dst_list The list receiving the new items.
-- @param src_list The list containing the items to appen to the other list.
function pshy.ListAppend(dst_list, src_list)
	assert(type(dst_list) == "table")
	assert(type(dst_list) == "table")
	for i_item, item in ipairs(src_list) do
		table.insert(dst_list, item)
	end
end



--- Get a random key from a table.
-- @param t The table.
-- disabled because not used
--function pshy.TableGetRandomKey(t)
--	local keylist = {}
--	for k in pairs(t) do
--	    table.insert(keylist, k)
--	end
--	return keylist[math.random(#keylist)]
--end



--- Count a value in a table.
-- @param t The table to count from.
-- @param v The value to search.
function pshy.TableCountValue(t, v)
	local count = 0
	for key, value in pairs(t) do
		if value == v then
			count = count + 1
		end
	end
	return count
end



--- Remove all instances of a value from a list.
-- @param l List to remove from.
-- @param v Value to remove.
function pshy.ListRemoveValue(l, v)
	for i = #l, 1, -1 do
		if l[i] == v then
			table.remove(l, i)
		end
	end
end
