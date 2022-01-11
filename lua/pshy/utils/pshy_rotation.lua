--- pshy_rotation.lua
--
-- Adds a table type that can be used to create random rotations.
--
-- A rotation is a table with the folowing fields:
--	- items: List of items to be randomly returned.
--	- next_indices: Private list of item indices that have not been done yet.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_utils.lua
--
-- @hardmerge
pshy = pshy or {}



--- Create a rotation.
-- @public
-- You can then add items in its `items` field.
function pshy.rotation_Create()
	local rotation = {}
	rotation.items = {}
	return rotation
end



--- Reset a rotation.
-- @public
-- Its state will be back as if you had never poped items from it.
function pshy.rotation_Reset(rotation)
	assert(type(rotation) == "table", "unexpected type " .. type(rotation))
	rotation.next_indices = {}
	if #rotation.items > 0 then
		for i = 1, #rotation.items do
			table.insert(rotation.next_indices, i)
		end
	end
end



--- Get a random item from a rotation.
-- @param rotation The rotation table.
-- @return A random item from the rotation.
function pshy.rotation_Next(rotation)
	assert(type(rotation) == "table", "unexpected type " .. type(rotation))
	assert(type(rotation.items) == "table", "rotation table had no item")
	if #rotation.items == 0 then
		return nil
	end
	-- reset the rotation if needed
	rotation.next_indices = rotation.next_indices or {}
	if #rotation.next_indices == 0 then
		pshy.rotation_Reset(rotation)
	end
	-- pop the item
	local i_index = math.random(#rotation.next_indices)
	local item = rotation.items[rotation.next_indices[i_index]]
	table.remove(rotation.next_indices, i_index)
	-- returning
	return item
end
