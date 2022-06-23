--- pshy.compiler.require
--
-- Define a `pshy.require` function.
-- The function behave like the Lua `require` one.
-- Calls to the function are also parsed by the compiler to include the right files.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @preload
pshy = pshy or {}



--- List of functions to load after a new module have been loaded.
-- They will be called with the name of the loaded module.
pshy.require_postload_functions = {}



--- Load a module from the `pshy.modules` table.
-- Load a module if it have not been loaded already.
-- @param module_name The name of the module.
-- @param optional The module may or may not be loaded. If present, whatever the value, the compiler will ignore the call.
-- @return The module's return.
function pshy.require(module_name, optional)
	local module = pshy.modules[module_name]
	if not module then
		if not optional then
			print(string.format("<r>[ERROR]: <n>require: Module `%s` not found!", module_name))
		end
		return nil
	end
	if not module.loaded then
		if module.loading then
			error(string.format("<r> Module `%s` recursively required!", module_name))
		end
		module.loading = true
		local success
		success, module.value = pcall(module.load)
		if not success then
			if not optional then
				error(string.format("<r>Loading %s: %s", module_name, module.value))
			end
			module.value = nil
		end
		module.loading = false
		module.loaded = true
		for i_postload_function, postload_function in ipairs(pshy.require_postload_functions) do
			postload_function(module_name)
		end 
	end
	return pshy.modules[module_name].value
end
