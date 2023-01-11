--- pshy.utils.ids
--
-- Allocates ids to avoid conflicts.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



--- Namespace.
local ids = {}



--- Internal Use:
local init_done = true
local pools = {}		-- ids pools to allocate from
pools["Popup"]			= {first_id = 4624, last_id = 14624}
pools["ColorPicker"]	= {first_id = 4624, last_id = 14624}
pools["TextArea"]		= {first_id = 4624, last_id = 14624}
pools["PhysicObject"]	= {first_id = 4624, last_id = 14624}	-- note: Objects removed on new game.
pools["Joint"]			= {first_id = 4624, last_id = 14624}	-- note: Objects removed on new game.
pools["Bonus"]			= {first_id = 4624, last_id = 14624}	-- note: Objects removed on new game.



--- Define Alloc*Id(), Reserve*Id(new_id) and Free*Id(old_id):
for pool_name, pool in pairs(pools) do
	pool.allocated = {}					-- map of allocated ids
	pool.freed = {}						-- map of freed ids
	pool.next_id = pool.first_id		-- biggest automatically allocated id
	pool.init_id = pool.next_id			-- last allocated id after eventInit + 1
	local allocated = pool.allocated
	local freed = pool.freed
	local last_id = pool.last_id
	


	--- Alloc*Id()
	-- Allocate an id from a pool.
	ids["Alloc" .. pool_name .. "Id"] = function()
		local new_id
		-- allocate from pool.freed
		if #freed > 0 then
			new_id = freed[#freed]
			table.remove(freed, #freed)
		end
		-- allocate from pool.next_id
		if not new_id then
			for id = pool.next_id, last_id do
				if not allocated[id] then
					new_id = id
					break
				end
			end
		end
		assert(new_id)
		allocated[new_id] = true
		pool.next_id = new_id + 1
		return new_id
	end
	
	
	
	--- Reserve*Id(new_id)
	-- Allocate a specific id from a pool.
	ids["Reserve" .. pool_name .. "Id"] = function(new_id)
		assert(type(new_id) == "number")
		if new_id < first_id or new_id > last_id then
			return
		end
		allocated[new_id] = true
		return new_id
	end
	
	
	
	--- Free*Id(old_id)
	-- Release an id.
	ids["Free" .. pool_name .. "Id"] = function(old_id)
		if allocated[old_id] then
			allocated[old_id] = false
			if old_id >= pool.init_id then
				table.insert(freed, #freed + 1, old_id)
			end
		end
	end
	
	
	
end



function eventInit()
	init_done = true
	for pool_name, pool in pairs(pools) do
		pool.init_id = pool.next_id
	end
end



-- @TODO: Non-pshy modules may start using ids before initialization.
-- Those could be automatically reserved by wrapping some functions.



return ids
