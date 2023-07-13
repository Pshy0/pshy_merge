--- pshy.utils.functions
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



--- Namespace.
local utils_functions = {}



--- Create a new function calling a function with given arguments.
-- @param func Function to wrap.
-- @param args Arguments to call the function with.
-- @return A function that will call the one given with the arguments given.
function utils_functions.Bind(func, ...)
    local args = {...}
    local new_func
    if #args == 1 then
        new_func = function(...)
            return func(args[1], ...)
        end
    else
        new_func = function(...)
            local args2 = {...}
            if #args2 == 0 then
                return func(table.unpack(args))
            end
            for i_arg, arg in ipairs(args) do
                table.insert(args2, i_arg, arg)
            end
            return func(table.unpack(args2))
        end
    end
    return new_func
end



return utils_functions
