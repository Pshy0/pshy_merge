--- pshy.utils.math
--
-- Basic math functions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @hardmerge
pshy = pshy or {}



--- Distance between points.
-- @return The distance between the points.
function pshy.Distance(x1, y1, x2, y2)
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end
