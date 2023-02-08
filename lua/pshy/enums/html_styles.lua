--- pshy.enums.html_styles
--
-- TFM available html markups map.
--
-- @source Shamousey https://atelier801.com/topic?f=6&t=781139#m1
-- @author TFM:Pshy#3752 DC:Pshy#7998



local html_styles = {
	-- misk
	BOLD			= {"<b>", "</b>"};
	UNDERLINED		= {"<u>", "</u>"};
	ITALIC			= {"<i>", "</i>"};
	STRIKEDOUT		= {"<strike>", "</strike>"};
	-- colors
	OVER			= {"<a:active>", "</a:active>"};	-- yellow
	ACTIVE			= {"<a:over>", "</a:over>"};		-- lime
	MAPCREW			= {"<bv>", "</bv>"};				-- blue
	SYSTEMMESSAGE	= {"<bl>", "</bl>"};				-- dark blue
	WHISPERNAME		= {"<ce>", "</ce>"};				-- light orange
	WHISPERMESSAGE	= {"<cep>", "</cep>"};				-- pale orange
	WHISPER3		= {"<cs>", "</cs>"};				-- pale yellow
	CHAMAN			= {"<ch>", "</ch>"};				-- light cyan
	CHAMAN2			= {"<ch2>", "</ch2>"};				-- light pink
	WHISPER4		= {"<d>", "</d>"};					-- light yellow
	OFFLINE			= {"<g>", "</g>"};					-- dark blue
	FUNCORP			= {"<fc>", "</fc>"};				-- orange
	HELP			= {"<j>", "</j>"};					-- yellow
	MESSAGES		= {"<n>", "</n>"};					-- white
	DISABLED		= {"<n2>", "</n2>"};				-- grey
	ORANGE			= {"<o>", "</o>"};					-- orange
	ERROR			= {"<r>", "</r>"};					-- red
	MODERATION		= {"<rose>", "</rose>"};			-- pink
	CHATMESSAGE		= {"<s>", "</s>"};					-- pale pink
	CHATNAME		= {"<ps>", "</ps>"};				-- light pink
	TRIBEMESSAGE	= {"<t>", "</t>"};					-- light green
	TRIBENAME		= {"<v>", "</v>"};					-- chat green
	TUTORIAL		= {"<vp>", "</vp>"};				-- light green
	PURPLE			= {"<vi>", "</vi>"};				-- purple
}



return html_styles
