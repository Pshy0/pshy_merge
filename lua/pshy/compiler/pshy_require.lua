--- pshy_require.lua
--
-- Define a `pshy.require` function.
-- The function behave like the Lua `require` one.
-- Calls to the function are also parsed by the compiler to include the right files.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @hardmerge
pshy = pshy or {}



--- List of functions to load after a new module have been loaded.
-- They will be called with the name of the loaded module.
pshy.require_postload_functions = {}



--- Load a module from the `pshy.modules` table.
-- Load a module if it have not been loaded already.
-- @param module_name The name of the module.
-- @return The module's return.
function pshy.require(module_name)
	if not pshy.modules[module_name].loaded then
		pshy.modules[module_name].value = pshy.modules[module_name].load()
		pshy.modules[module_name].loaded = true
		for i_postload_function, postload_function in ipairs(pshy.require_postload_functions) do
			postload_function(module_name)
		end 
	end
	return pshy.modules[module_name].value
end
