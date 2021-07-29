--- pshy_utils_tables.lua
--
-- Basic functions related to LUA tables.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @hardmerge
-- @namespace pshy
pshy = pshy or {}



--- Get a table's keys as a list.
-- @public
-- @param t The table.
-- @return A list of the keys from the given table.
function pshy.TableKeys(t)
	local keys
	for key in pairs(t) do
		table.insert(keys, key)
	end
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



--- Append a list to another.
-- @param dst_list The list receiving the new items/
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
function pshy.TableGetRandomKey(t)
	local keylist = {}
	for k in pairs(t) do
	    table.insert(keylist, k)
	end
	return keylist[math.random(#keylist)]
end
