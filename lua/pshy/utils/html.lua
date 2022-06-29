--- pshy.utils.html
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local utils_html = {}



function utils_html.SplitMarkups(html)
	lt_array = {}
	local search = "<"
	local start = 1
	while true do
		local hit = string.find(html, search, start, true)
		if not hit then
			break
		end
		table.insert(lt_array, string.sub(html, start, hit - 1))
		search = (search == "<") and ">" or "<"
		start = hit + 1
	end
	table.insert(lt_array, string.sub(html, start, #html))
	return lt_array
end



return utils_html
