--- pshy.utils.math
--
-- Basic math functions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local utils_math = {}



--- Distance between points.
-- @return The distance between the points.
function utils_math.Distance(x1, y1, x2, y2)
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end



return utils_math
