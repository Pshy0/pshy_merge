--- pshy.utils.print
--
-- Custom print functions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @preload



local function nothrow_format(format, ...)
	local rst, rtn = pcall(string.format, format, ...)
	return rtn
end



function print_debug(format, ...)
	print("<bv>DEBUG: </bv>" .. nothrow_format(tostring(format), ...))
end



function print_info(format, ...)
	print("<ch>INFO: </ch>" .. nothrow_format(tostring(format), ...))
end



function print_warn(format, ...)
	print("<o>WARN: </o>" .. nothrow_format(tostring(format), ...))
end



function print_error(format, ...)
	print("<r>ERROR: </r>" .. nothrow_format(tostring(format), ...))
end



function print_critical(format, ...)
	print("<r>CRITICAL: </r>" .. nothrow_format(tostring(format), ...))
end
