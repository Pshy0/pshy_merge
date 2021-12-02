--- pshy_xmlmap.lua
--
-- /!\ This module was experimental and shouldnt be used anymore!
--
-- Parse the map's xml into a tree.
-- `pshy.xm`
-- Every markup has a `type` string field,
-- as well as a `properties` and a `childs` table.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_utils_lua.lua
pshy = pshy or {}



--- Parsed map output.
--
-- This represent a tree of markups such as every markup has the folowing fields:
--	- `type`		- the type of the markup
--	- `properties`	- a table of properties in the markup
--	- `childs`		- a list of markups that are childs of this one
--
-- The first item in the list is the "C" type markup (representing the map).
--
-- @public
pshy.xmlmap = nil



--- Get an array of strings contained the markups from an xml string.
local function GetMarkupStringContents(xml)
	-- split markups
	local markups = pshy.StrSplit(xml, ">")
	for i_content, content in ipairs(markups) do
		if #content == 0 then
			markups[i_content] = nil
			break
		end
		assert(string.sub(content, 1, 1) == "<", "malformed xml map?")
		markups[i_content] = string.sub(content, 2, #content)
	end
	return markups
end



--- Update the `pshy.xmlmap` table.
function pshy.xmlmap_Update()
	pshy.xmlmap = nil
	if not tfm.get.room.xmlMapInfo then
		return
	end
	local xml = tfm.get.room.xmlMapInfo.xml
	if not xml then
		return
	end
	
	start_time = os.time()
	local markups = GetMarkupStringContents(xml)
	print("A took " .. tostring(os.time() - start_time))
	
	start_time = os.time()
	-- convert to (type + properties/values) | closing
	local types = {}
	for i_markup, content in ipairs(markups) do
		local markup = {}
		markup.properties = {}
		if string.sub(content, 1, 1) == "/" then
			-- closing markup
			markup.closing = true
			content = string.sub(content, 2, #content)
			markup.type = content
		else
			if string.sub(content, #content, #content) == "/" then
				-- self-closing markup
				markup.self_closing = true
				content = string.sub(content, 1, #content - 1)
			end
			markup._fields = pshy.StrSplit(content, " ")
		end
		markups[i_markup] = markup
	end
	print("B took " .. tostring(os.time() - start_time) .. " for #markups " .. tostring(#markups))
	
	
	start_time = os.time()
	for i_markup, markup in ipairs(markups) do
		if markup._fields then
			local fields = markup._fields
			-- markup's type
			markup.type = fields[1]
			-- markup's fields (properties)
			for i_field, field in ipairs(fields) do
				if i_field > 1 and #field > 0 then
					local pnameandvalue = pshy.StrSplit(field, "=", 2)
					-- @todo: it looks like vanilla asserts are slow
					assert(#pnameandvalue[1] > 0, "malformed xml (empty property name)?")
					assert(string.sub(pnameandvalue[2], 1, 1) == "\"", "malformed xml (property's first quote)?")
					assert(string.sub(pnameandvalue[2], #pnameandvalue[2], #pnameandvalue[2]) == "\"", "malformed xml (property's last quote)?")
					markup.properties[pnameandvalue[1]] = string.sub(pnameandvalue[2], 2, #pnameandvalue[2] - 1)
				end
			end
		end
	end
	print("C took " .. tostring(os.time() - start_time) .. " for #markups " .. tostring(#markups))
	
	
	start_time = os.time()
	-- create the xml tree (and fill 'parent' and 'childs')
	local tree = {}
	local focus = tree
	for i_markup, markup in ipairs(markups) do
		markup.parent = focus
		--print(markup.type .. tostring(markup.closing) .. " " .. tostring(markup.self_closing))
		if markup.closing then
			assert(markup.type == focus.type, "malformed xml (closed a non-open makup)?")
			focus = focus.parent
		else
			if markup.parent == tree then
				table.insert(markup.parent, markup)
			else
				table.insert(markup.parent.childs, markup)
			end
			if not markup.self_closing then
				focus = markup
				markup.childs = {}
			end
		end
	end
	assert(focus == tree, "malformed xml (partial tree)?")
	print("D took " .. tostring(os.time() - start_time))
	
	-- all done ;>
	assert(tree[1].type == "C")
	pshy.xmlmap = tree[1]
end



--- Get the xml node corresponding to grounds.
function pshy.xmlmap_GetGroundNode()
	if not pshy.xmlmap then
		return nil
	end
	for i_child, child in ipairs(pshy.xmlmap.childs) do
		if child.childs then
			if child.type == "Z" then
				if child.childs then
					for i_child, child in ipairs(child.childs) do
						if child.type == "S" then
							return child
						end
					end
				end
			end
		end
	end
end



-- TFM event eventNewGame.
function eventNewGame()
	pshy.xmlmap_Update()
end
