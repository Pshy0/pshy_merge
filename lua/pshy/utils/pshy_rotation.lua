--- pshy_rotation.lua
--
-- Adds a table type that can be used to create random rotations.
--
-- A rotation is a table with the folowing fields:
--	- items: List of items to be randomly returned.
--	- done_items: List of items that have been returned and are waiting for a reset.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @hardmerge
-- @require pshy_utils.lua
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
-- Its state will be back as if you had never poped items from it.
function pshy.rotation_Reset(rotation)
	assert(type(rotation) == "table", "unexpected type " .. type(rotation))
	-- reset done items
	if #rotation.items > #rotation.done_items then
		pshy.ListAppend(rotation.items, rotation.done_items)
		rotation.done_items = {}
	else
		pshy.ListAppend(rotation.done_items, rotation.items)
		rotation.items = rotation.done_items
		rotation.done_items = {}
	end
end



--- Get a random item from a rotation.
-- @param rotation The rotation table.
-- @return A random item from the rotation.
function pshy.rotation_Pop(rotation)
	assert(type(rotation) == "table", "unexpected type " .. type(rotation))
	assert(#rotation.items + #rotation.done_items > 0, "no item in rotation")
	-- reset the rotation if needed
	if #rotation.items <= 0 then
		pshy.rotation_Reset(rotation)
	end
	-- pop the item
	local i_item = math.random(#rotation.items)
	local item = rotation.items[i_item]
	table.insert(rotation.done_items, item)
	table.remove(rotation.items, i_item)
	-- returning
	return item
end
