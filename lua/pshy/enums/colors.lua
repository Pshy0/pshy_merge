--- pshy.enums.colors
--
-- Simple enumeration of color codes
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @hardmerge



--- Public Map:
local colors = {}
-- primary colors
colors.red			= 0xff0000
colors.lime			= 0x00ff00
colors.blue			= 0x0000ff
-- secondary colors
colors.yellow		= 0xffff00
colors.magenta		= 0xff00ff
colors.cyan			= 0x00ffff
-- greys
colors.transparent	= 0x000000	-- because TFM may count 0x000000 as transparent.
colors.black		= 0x010101	-- because TFM may count 0x000000 as transparent.
colors.grey			= 0x808080
colors.gray			= 0x808080
colors.silver		= 0xc0c0c0
colors.white		= 0xffffff
-- odd
colors.maroon		= 0x800000
colors.green		= 0x008000
colors.navy			= 0x000080
colors.olive		= 0x808000
colors.purple		= 0x800080
colors.teal			= 0x008080
-- common
colors.aquamarine	= 0x7fffd4
colors.brown		= 0xa52a2a
colors.bronze		= 0x967444
colors.coral		= 0xff7f50
colors.darkgreen	= 0x006400
colors.gold			= 0xffd700
colors.indigo		= 0x4b0082
colors.lavender		= 0xb2a4d4
colors.orange		= 0xffa500
colors.pink			= 0xffc0cb
colors.tan			= 0xd2b48c
colors.turquoise	= 0x40e0d0
colors.violet		= 0x9b26b6
-- TFM
colors.funcorp		= 0xff8000



return colors
