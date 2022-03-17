--- pshy_getxml.lua
--
-- Adds a command to get the map's xml.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_perms.lua
-- @require pshy_utils_lua.lua
--
-- @require_priority UTILS



--- Module Help Page:
pshy.help_pages["pshy_getxml"] = {back = "pshy", text = "Get a map's xml.", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_getxml"] = pshy.help_pages["pshy_getxml"]



--- Internal use:
local last_map = nil
local lines = {}



local function ComputeLines()
	-- getting xml
	local xml = tfm.get.room.xmlMapInfo.xml
	xml = string.gsub(xml, "<", "&lt;")
	xml = string.gsub(xml, ">", "&gt;")
	local split_xml = pshy.StrSplit2(xml, "&")
	-- getting lines
	lines = {}
	local line = ""
	for i_part, part in ipairs(split_xml) do
		if i_part ~= 1 then
			part = "&" .. part
		end
		if #line + #part > 200 then
			table.insert(lines, line)
			line = ""
		end
		while #part > 200 do
			table.insert(lines, string.sub(part, 1, 200))
			part = string.sub(part, 200 + 1)
		end
		line = line .. part
	end
	if #line > 0 then
		table.insert(lines, line)
	end
	last_map = tfm.get.room.currentMap
end



--- !getxml
-- @TODO: xml may be cut in the wrong spot!
local function ChatCommandGetxml(user, index)
	-- getting lines
	if index == nil and last_map ~= tfm.get.room.currentMap then
		if not tfm.get.room.xmlMapInfo or not tfm.get.room.xmlMapInfo.xml then
			return false, "This map does not have an xml."
		end
		ComputeLines()
	end
	-- printing
	index = index or 1
	local index_max = math.floor((#lines - 1) / 40) + 1
	if index > index_max then
		return false, string.format("There is only %d parts.", index_max)
	end
	local i_line_start = (index - 1) * 40 + 1
	local i_line_end =  math.min(i_line_start + 40, #lines)
	tfm.exec.chatMessage(string.format("<ch>Map %s (part %d/%d):", last_map, index, index_max), user)
	for i_line = i_line_start, i_line_end do
		print("i_line = " .. tostring(i_line))
		print("i_line_start = " .. tostring(i_line_start))
		print("i_line_end = " .. tostring(i_line_end))
		local line = lines[i_line]
		if #line > 0 then
			tfm.exec.chatMessage(line, user)
		end
	end
	if index_max == 1 then
		return true, string.format("^ XML of map '%s'.", last_map)
	else
		if index < index_max then
			return true, string.format("^ XML of map '%s' (part %d/%d). <fc>Use `!getxml %d` to get the next part.</fc>", last_map, index, index_max, index + 1)
		else
			return true, string.format("^ XML of map '%s' (part %d/%d)", last_map, index, index_max)
		end
	end
end
pshy.commands["getxml"] = {func = ChatCommandGetxml, desc = "get the current map's xml (only for @maps)", argc_min = 0, argc_max = 1, arg_types = {"number"}, arg_names = {"part"}}
pshy.help_pages["pshy_getxml"].commands["getxml"] = pshy.commands["getxml"]
pshy.perms.admins["!getxml"] = true