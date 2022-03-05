--- pshy_encoding_graph.lua
--
-- Functions to encode/decode to a format only containing graphical chars.
-- The format uses escape codes to do so.
--
-- Non-print text is not supported, but \x codes are not supported by TFM anyway.
--
-- @require pshy_utils_lua.lua
--
-- @require_priority HARDMERGE
pshy = pshy or {}



--- Internal Use:
local escape_codes = {}		-- available escape sequences
--table.insert(escape_codes, {code = "\\a", value = "\a"}) -- Code "\a" is used internaly, so is not defined here but is supported.
table.insert(escape_codes, {code = "\\b", value = "\b"})
table.insert(escape_codes, {code = "\\f", value = "\f"})
table.insert(escape_codes, {code = "\\n", value = "\n"})
table.insert(escape_codes, {code = "\\r", value = "\r"})
table.insert(escape_codes, {code = "\\s", value = " "})
table.insert(escape_codes, {code = "\\t", value = "\t"})
table.insert(escape_codes, {code = "\\v", value = "\v"})
table.insert(escape_codes, {code = "\\L", value = "<"}) -- for html support
--table.insert(escape_codes, {code = "\\G", value = ">"}) -- for html support (not in use but reserved)
table.insert(escape_codes, {code = "\\A", value = "&"}) -- for html support
table.insert(escape_codes, {code = "\\D", value = "-"}) -- for fast selection with double-clic
--table.insert(escape_codes, {code = "\\\\", value = "\\"}) -- Code "\\" is used internaly, so is not defined here but is supported.



--- Encode a text to graph-only characters.
-- @param A printable text to encode.
-- @return The graph-only text.
function pshy.EncodeGraph(text)
	local parts = pshy.StrSplit2(text, "\a")
	text = ""
	for i_part, part in ipairs(parts) do
		if #text > 0 then
			text = test .. "\\a"
		end
		text = text .. string.gsub(part, "\\", "\a")
	end
	for i_escape_code, escape_code in ipairs(escape_codes) do
		text = string.gsub(text, escape_code.value, escape_code.code)
	end
	text = string.gsub(text, "\a", "\\\\")
	return text
end



--- Decode a text from graph-only characters.
-- @param A encoded text.
-- @return The original printable text.
function pshy.DecodeGraph(text)
	for i_escape_code, escape_code in ipairs(escape_codes) do
		text = string.gsub(text, escape_code.code, escape_code.value)
	end
	text = string.gsub(text, "\\a", "\a")
	text = string.gsub(text, "\\\\", "\\")
	return text
end
