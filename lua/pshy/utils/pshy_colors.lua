--- pshy_colors.lua
--
-- Simple enumeration of color codes
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @hardmerge
pshy = pshy or {}



--- Public Map:
pshy.colors = {}
-- primary colors
pshy.colors.red			= 0xff0000
pshy.colors.lime		= 0x00ff00
pshy.colors.blue		= 0x0000ff
-- secondary colors
pshy.colors.yellow		= 0xffff00
pshy.colors.magenta		= 0xff00ff
pshy.colors.cyan		= 0x00ffff
-- greys
pshy.colors.transparent	= 0x000000	-- because TFM may count 0x000000 as transparent.
pshy.colors.black		= 0x010101	-- because TFM may count 0x000000 as transparent.
pshy.colors.grey		= 0x808080
pshy.colors.gray		= 0x808080
pshy.colors.silver		= 0xc0c0c0
pshy.colors.white		= 0xffffff
-- odd
pshy.colors.maroon		= 0x800000
pshy.colors.green		= 0x008000
pshy.colors.navy		= 0x000080
pshy.colors.olive		= 0x808000
pshy.colors.purple		= 0x800080
pshy.colors.teal		= 0x008080
-- common
pshy.colors.aquamarine	= 0x7fffd4
pshy.colors.brown		= 0xa52a2a
pshy.colors.coral		= 0xff7f50
pshy.colors.darkgreen	= 0x006400
pshy.colors.gold		= 0xffd700
pshy.colors.indigo		= 0x4b0082
pshy.colors.orange		= 0xffa500
pshy.colors.pink		= 0xffc0cb
pshy.colors.tan			= 0xd2b48c
-- TFM
pshy.colors.funcorp		= 0xff8000
