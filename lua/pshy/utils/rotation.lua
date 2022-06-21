--- pshy.utils.rotation
--
-- Adds a table type that can be used to create random rotations.
--
-- A rotation is a table with the folowing fields:
--	- items: List of items to be randomly returned.
--	- next_indices: Private list of item indices that have not been done yet.
--	- is_random: `false` to disable randomness.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



--- Rotation.
-- Represent a collection of items that can be obtained one after another.
local Rotation = {
	items = {},				-- The items in the rotation.
	next_indices = {},		-- The indices of the items remaining to return.
	is_random = true,		-- Should the items be returned in a random order?
}
Rotation.__index = Rotation



--- Create a rotation.
-- You can then add items in its `items` field.
function Rotation:New(o)
	assert(self == Rotation)
	local o = o or {}
	o.items = o.items or {}
	o.next_indices = o.next_indices or {}
	setmetatable(o, self)
	return o
end



--- Reset a rotation.
-- Its state will be back as if you had never poped items from it.
function Rotation:Reset(start_index)
	assert(self ~= Rotation)
	self.next_indices = {}
	if #self.items > 0 then
		local table_insert = table.insert
		local next_indices = self.next_indices
		for i = 1, #self.items do
			table_insert(next_indices, i)
		end
	end
end



--- Get the index of an item in the rotation.
function Rotation:IndexOf(search_item)
	assert(self ~= Rotation)
	for i_item, item in ipairs(self.items) do
		if item == search_item then
			return i_item
		end
	end
end



function Rotation:SkipIndex(index)
	assert(self ~= Rotation)
	table.remove(self.next_indices, index)	
	if not self.is_random then
		self.next_indices = {}
		if #self.items > 0 then
			local table_insert = table.insert
			local next_indices = self.next_indices
			for i = 1, #self.items do
				if start_index > i then
					table_insert(next_indices, i)
				end
			end
		end
	end
end



--- Skip to a given item.
-- If the item is not found then nothing is done.
function Rotation:SkipItem(item)
	assert(self ~= Rotation)
	local index = self:IndexOf(item)
	if index then
		return self:SkipIndex(index)
	end
end



--- Get a random item from a rotation.
-- @return A random item from the rotation.
function Rotation:Next()
	assert(self ~= Rotation)
	if #self.items == 0 then
		return nil
	end
	-- reset the rotation if needed
	self.next_indices = self.next_indices or {}
	if #self.next_indices == 0 then
		self:Reset()
	end
	-- pop the item
	
	local i_index = (self.is_random == false) and 1 or math.random(#self.next_indices)
	local item = self.items[self.next_indices[i_index]]
	table.remove(self.next_indices, i_index)
	-- returning
	return item
end



return Rotation
