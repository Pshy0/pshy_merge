--- pshy.enums.colors
--
-- Simple enumeration of color codes.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



local colors = {
	-- primary
	red				= 0xff0000;
	lime			= 0x00ff00;
	blue			= 0x0000ff;
	-- secondary
	yellow			= 0xffff00;
	magenta			= 0xff00ff;
	cyan			= 0x00ffff;
	-- greys
	transparent		= 0x000000;	-- because TFM may count 0x000000 as transparent.
	black			= 0x010101;	-- because TFM may count 0x000000 as transparent.
	grey			= 0x808080;
	gray			= 0x808080;
	silver			= 0xc0c0c0;
	white			= 0xffffff;
	-- odd
	maroon			= 0x800000;
	green			= 0x008000;
	navy			= 0x000080;
	olive			= 0x808000;
	purple			= 0x800080;
	teal			= 0x008080;
	-- common
	aquamarine		= 0x7fffd4;
	brown			= 0xa52a2a;
	bronze			= 0x967444;
	coral			= 0xff7f50;
	darkgreen		= 0x006400;
	gold			= 0xffd700;
	indigo			= 0x4b0082;
	lavender		= 0xb2a4d4;
	orange			= 0xffa500;
	pink			= 0xffc0cb;
	tan				= 0xd2b48c;
	turquoise		= 0x40e0d0;
	violet			= 0x9b26b6;
	-- TFM
	funcorp			= 0xff8000;
}



return colors
