--- pshy.utils.print
--
-- Custom print functions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @preload
pshy = pshy or {}



function printf(format, ...)
	print(string.format(format, ...))
end



function print_debug(format, ...)
	print("<bv>DEBUG: </bv>" .. string.format(format, ...))
end



function print_info(format, ...)
	print("<ch>INFO: </ch>" .. string.format(format, ...))
end



function print_warn(format, ...)
	print("<o>WARN: </o>" .. string.format(format, ...))
end



function print_error(format, ...)
	print("<r>ERROR: </r>" .. string.format(format, ...))
end



function print_critical(format, ...)
	print("<r>CRITICAL: </r>" .. string.format(format, ...))
end
