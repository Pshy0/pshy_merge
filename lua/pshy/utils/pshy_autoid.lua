--- pshy_autoid.lua
--
-- Makes TFM functions requiring an arbitrary id now accepting `nil` as an id.
-- In this case, the function will return the automatically chosen id.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_merge.lua
-- @require pshy_print.lua
-- @require pshy_utils_lua.lua
--
-- @require_priority HARDMERGE
pshy = pshy or {}



--- Internal Use:
local pools = {}
pools.grounds		= {first = 200}
pools.popups		= {first = 200}
pools.color_pickers = {first = 200}
pools.bonuses		= {first = 200}
pools.joints		= {first = 200}
pools.text_areas	= {first = 200}
for pool_name, pool in pairs() do
	pool.excluded = {}
	pool.reserved = {}
	pool.next_id = pool.first
end



--- Module Settings:
local overrides = {}				-- bind tfm functions to overrides
overrides["AddJoint"]			= {pool = pools.joints, tfm_function = "tfm.exec.addJoint", pool = pools.joints, alloc = true}
overrides["RemoveJoint"]		= {pool = pools.joints, tfm_function = "tfm.exec.removeJoint", alloc = false}
overrides["AddPhysicObject"]	= {pool = pools.grounds, tfm_function = "tfm.exec.addPhysicObject", alloc = true}
overrides["UpdatePhysicObject"]	= {pool = pools.grounds, tfm_function = "tfm.exec.updatePhysicObject", alloc = false}
overrides["RemovePhysicObject"]	= {pool = pools.grounds, tfm_function = "tfm.exec.removePhysicObject", alloc = false}
overrides["AddTextArea"]		= {pool = pools.text_areas, tfm_function = "ui.addTextArea", alloc = true}
overrides["UpdateTextArea"]		= {pool = pools.text_areas, tfm_function = "ui.updateTextArea", alloc = false}
overrides["RemoveTextArea"]		= {pool = pools.text_areas, tfm_function = "ui.removeTextArea", alloc = false}
overrides["AddPopup"]			= {pool = pools.popups, tfm_function = "ui.addPopup", alloc = true}
overrides["ShowColorPicker"]	= {pool = pools.color_pickers, tfm_function = "ui.showColorPicker", alloc = true}
for name, override in pairs() do
	override.original = pshy.LuaGet(override.tfm_function)
end



--- Lock an id so it wont be used in the pool.
local function LockID(pool, id)
	print_debug("autoid: locking %s: %d", pool.name, id)
	pool.excluded[id] = true
end



--- Reserve an available id from a pool.
local function AllocID(pool)
	while true do
		local next_id = pool.next
		if not pool.excluded[next_id] and not pool.reserved[next_id] then
			next_id = next_id + 1
			print_debug("autoid: allocated %s: %d", pool.name, id)
			return next_id
		end
		next_id = next_id + 1
	end
end



--- Free an ID.
-- This may not actually do anything, 
-- as ids may be reused.
local function FreeID(pool, id)
	-- do nothing
end



--- Free everything from the pool, except locked ids.
local function ResetPool(pool)
	pool.next_id = pool.first
	pool.reserved = {}
end



--- Reset pools that needs to on new game.
function eventNewGame()
	ResetPool(pools.grounds)
	ResetPool(pools.bonuses)
	ResetPool(pools.joints)
end



--- Functions Overrides as `pshy.autoid_OriginalName`.
for name, override in pairs(overrides) do
	local func_name = "autoid_" .. name
	pshy[func_name] = function(id, ...)
		local pool = override.pool	
		if override.alloc and id == nil then
			id = AllocID(pool)
		elseif id == nil then
			print_warn("%s: id was %s", func_name, tostring(id))
		else
			if not pool.excluded[id] and not pool.reserved[id] then
				LockID(pool, id)
			end
		end
		return override.original(id, ...)
	end
	pshy.LuaSet(override.tfm_function, pshy[func_name])
end
