--- pshy.tools.getxml
--
-- Adds a command to get the map's xml.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local help_pages = pshy.require("pshy.help.pages")
local utils_strings = pshy.require("pshy.utils.strings")
local room = pshy.require("pshy.room")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Get XML", text = "Get a map's xml."}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Internal use:
local last_map = nil
local lines = {}
local map_print_function = tfm.exec.chatMessage
local max_chars_per_line = 200
local max_lines_per_chunks = 40



local function ComputeLines()
	-- getting xml
	local xml = tfm.get.room.xmlMapInfo.xml
	local split_xml = utils_strings.Split2(xml, "<")
	-- getting lines
	lines = {}
	local line = ""
	for i_part, part in ipairs(split_xml) do
		if i_part ~= 1 then
			part = "&lt;" .. part
		end
		part = string.gsub(part, ">", "&gt;")
		if #line + #part > max_chars_per_line then
			table.insert(lines, line)
			line = ""
		end
		while #part > max_chars_per_line do
			table.insert(lines, string.sub(part, 1, max_chars_per_line))
			part = string.sub(part, max_chars_per_line + 1)
		end
		line = line .. part
	end
	if #line > 0 then
		table.insert(lines, line)
	end
	last_map = tfm.get.room.currentMap
end



__MODULE__.commands = {
	["getxml"] = {
		perms = "admins",
		desc = "get the current map's xml (only for @maps)",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"integer"},
		arg_names = {"part index"},
		func = function(user, index)
			-- getting lines
			if index == nil and last_map ~= tfm.get.room.currentMap then
				if not tfm.get.room.xmlMapInfo or not tfm.get.room.xmlMapInfo.xml then
					return false, "This map does not have an xml."
				end
				ComputeLines()
			end
			-- printing
			index = index or 1
			local index_max = math.floor((#lines - 1) / max_lines_per_chunks) + 1
			if index > index_max then
				return false, string.format("There is only %d parts.", index_max)
			end
			local i_line_start = (index - 1) * max_lines_per_chunks + 1
			local i_line_end =  math.min(i_line_start + max_lines_per_chunks - 1, #lines)
			map_print_function(string.format("<ch>Map %s (part %d/%d):", last_map, index, index_max), user)
			for i_line = i_line_start, i_line_end do
				local line = lines[i_line]
				if #line > 0 then
					map_print_function(line, user)
				end
			end
			if index_max == 1 then
				return true, map_print_function(string.format("^ XML of map '%s'.", last_map), user)
			else
				if index < index_max then
					return true, map_print_function(string.format("^ XML of map '%s' (part %d/%d). <fc>Use `!getxml %d` to get the next part.</fc>", last_map, index, index_max, index + 1), user)
				else
					return true, map_print_function(string.format("^ XML of map '%s' (part %d/%d)", last_map, index, index_max), user)
				end
			end
		end
	}
}



function eventInit()
	if not room.is_funcorp then
		map_print_function = print
		max_chars_per_line = 2000
		max_lines_per_chunks = 10
	end
end
