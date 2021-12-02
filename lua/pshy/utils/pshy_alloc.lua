--- pshy_alloc.lua
--
-- Functions to allocate unique ids for your modules, to avoid conflicts.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require_priority HARDMERGE
pshy = pshy or {}



--- Internal Use:
pshy.alloc_id_pools = {}				-- map of id pools
pshy.alloc_id_pools["Popup"]			= {first = 20, last = 200, allocated = {}}
pshy.alloc_id_pools["ColorPicker"]		= {first = 20, last = 200, allocated = {}}
pshy.alloc_id_pools["Bonus"]			= {first = 200, last = 1000, allocated = {}}	-- note: Game bonuses are deleted by TFM on eventNewGame.
pshy.alloc_id_pools["Joint"]			= {first = 20, last = 1000, allocated = {}}		-- note: Game joints are deleted by TFM on eventNewGame.
pshy.alloc_id_pools["TextArea"]			= {first = 20, last = 1000, allocated = {}}
-- No "ShamanObject": returned by tfm.exec.addShamanObject.
-- No "Image": returned by tfm.exec.addImage.



--- Alloc an Id.
-- @public
-- @param pool The Id pool to allocate from.
-- @return An unique id, or nil if no id is available.
function pshy.AllocId(pool)
	if type(pool) == "string" then
		pool = pshy.alloc_id_pools[pool]
	end
	local found_id
	-- finding an id
	if pool.last_freed_id and not pool.allocated[pool.last_freed_id] then
		-- last freed id is available
		found_id = pool.last_freed_id
		if pool.last_freed_id - 1 >= pool.first and not pool.allocated[pool.last_freed_id - 1] then
			-- so the next allocation will check 
			pool.last_freed_id = pool.last_freed_id - 1
		end
	else
		-- last resort: check every id
		local id = pool.first
		while pool.allocated[id] do
			id = id + 1
		end
		if id > pool.last then
			return nil
		end
	end
	-- return
	pool.allocated[found_id] = true
	pool.last_allocated_id = found_id
	return found_id
end



--- Free an Id.
-- @param pool The Id pool to free from.
-- @param id The id to free in the pool.
-- @public
function pshy.FreeId(pool, id)
	if type(pool) == "string" then
		pool = pshy.alloc_id_pools[pool]
	end
	assert(type(id) == "number")
	assert(type(id) == pool.allocated[id], "this id is not allocated")
	pool.allocated[id] = nil
	pool.last_freed_id = id
end
