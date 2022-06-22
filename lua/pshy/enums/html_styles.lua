--- pshy.enums.html_styles
--
-- TFM available html markups map.
--
-- @source Shamousey https://atelier801.com/topic?f=6&t=781139#m1
-- @author TFM:Pshy#3752 DC:Pshy#7998



--- Public Map:
local html_styles = {}
-- Misk
html_styles.BOLD			= {"<b>", "</b>"}
html_styles.UNDERLINED		= {"<u>", "</u>"}
html_styles.ITALIC			= {"<i>", "</i>"}
html_styles.STRIKEDOUT		= {"<strike>", "</strike>"}
-- Colors
html_styles.OVER			= {"<a:active>", "</a:active>"}		-- yellow
html_styles.ACTIVE			= {"<a:over>", "</a:over>"}			-- lime
html_styles.MAPCREW			= {"<bv>", "</bv>"}					-- blue
html_styles.SYSTEMMESSAGE	= {"<bl>", "</bl>"}					-- dark blue
html_styles.WHISPERNAME		= {"<ce>", "</ce>"}					-- light orange
html_styles.WHISPERMESSAGE	= {"<cep>", "</cep>"}				-- pale orange
html_styles.WHISPER3		= {"<cs>", "</cs>"}					-- pale yellow
html_styles.CHAMAN			= {"<ch>", "</ch>"}					-- light cyan
html_styles.CHAMAN2			= {"<ch2>", "</ch2>"}				-- light pink
html_styles.WHISPER4		= {"<d>", "</d>"}					-- light yellow
html_styles.OFFLINE			= {"<g>", "</g>"}					-- dark blue
html_styles.FUNCORP			= {"<fc>", "</fc>"}					-- orange
html_styles.HELP			= {"<j>", "</j>"}					-- yellow
html_styles.MESSAGES		= {"<n>", "</n>"}					-- white
html_styles.DISABLED		= {"<n2>", "</n2>"}					-- grey
html_styles.ORANGE			= {"<o>", "</o>"}					-- orange
html_styles.ERROR			= {"<r>", "</r>"}					-- red
html_styles.MODERATION		= {"<rose>", "</rose>"}				-- pink
html_styles.CHATMESSAGE		= {"<s>", "</s>"}					-- pale pink
html_styles.CHATNAME		= {"<ps>", "</ps>"}					-- bright pale green
html_styles.TRIBEMESSAGE	= {"<t>", "</t>"}					-- light green
html_styles.TRIBENAME		= {"<v>", "</v>"}					-- green
html_styles.TUTORIAL		= {"<vp>", "</vp>"}					-- light green
html_styles.PURPLE			= {"<vi>", "</vi>"}					-- purple



return html_styles
