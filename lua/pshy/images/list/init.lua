--- pshy.images.list
--
-- Images available for TFM scripts.
-- Note: I did not made the images,
-- I only gathered and classified them in this script.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script)



--- Map of images.
-- The key is the image code.
-- The value is a table with the following fields:
--	- w: The pixel width of the picture.
--	- h: The pixel height of the picture (default to `w`).
local image_map = {}



--- example:
--image_map["00000000000.png"] = {w = nil, h = nil, desc = ""}



--- Image used as a default by some scripts:
image_map["15568238225.png"] = {meme = true, w = 40, h = 40, desc = "FUUU"}



return image_map
