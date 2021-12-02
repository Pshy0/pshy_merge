--- pshy_html_styles.lua
--
-- TFM available html markups map.
--
-- @source Shamousey https://atelier801.com/topic?f=6&t=781139#m1
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @hardmerge
pshy = pshy or {}



--- Public Map:
pshy.html_styles = {}
-- Misk
pshy.html_styles.BOLD			= {"<b>", "</b>"}
pshy.html_styles.UNDERLINED		= {"<u>", "</u>"}
pshy.html_styles.ITALIC			= {"<i>", "</i>"}
pshy.html_styles.STRIKEDOUT		= {"<strike>", "</strike>"}
-- Colors
pshy.html_styles.OVER			= {"<a:active>", "</a:active>"}		-- yellow
pshy.html_styles.ACTIVE			= {"<a:over>", "</a:over>"}			-- lime
pshy.html_styles.MAPCREW		= {"<bv>", "</bv>"}					-- blue
pshy.html_styles.SYSTEMMESSAGE	= {"<bl>", "</bl>"}					-- dark blue
pshy.html_styles.WHISPERNAME	= {"<ce>", "</ce>"}					-- light orange
pshy.html_styles.WHISPERMESSAGE	= {"<cep>", "</cep>"}				-- pale orange
pshy.html_styles.WHISPER3		= {"<cs>", "</cs>"}					-- pale yellow
pshy.html_styles.CHAMAN			= {"<ch>", "</ch>"}					-- light cyan
pshy.html_styles.CHAMAN2		= {"<ch2>", "</ch2>"}				-- light pink
pshy.html_styles.WHISPER4		= {"<d>", "</d>"}					-- light yellow
pshy.html_styles.OFFLINE		= {"<g>", "</g>"}					-- dark blue
pshy.html_styles.FUNCORP		= {"<fc>", "</fc>"}					-- orange
pshy.html_styles.HELP			= {"<j>", "</j>"}					-- yellow
pshy.html_styles.MESSAGES		= {"<n>", "</n>"}					-- white
pshy.html_styles.DISABLED		= {"<n2>", "</n2>"}					-- grey
pshy.html_styles.ORANGE			= {"<o>", "</o>"}					-- orange
pshy.html_styles.ERROR			= {"<r>", "</r>"}					-- red
pshy.html_styles.MODERATION		= {"<rose>", "</rose>"}				-- pink
pshy.html_styles.CHATMESSAGE	= {"<s>", "</s>"}					-- pale pink
pshy.html_styles.CHATNAME		= {"<ps>", "</ps>"}					-- bright pale green
pshy.html_styles.TRIBEMESSAGE	= {"<t>", "</t>"}					-- light green
pshy.html_styles.TRIBENAME		= {"<v>", "</v>"}					-- green
pshy.html_styles.TUTORIAL		= {"<vp>", "</vp>"}					-- light green
pshy.html_styles.PURPLE			= {"<vi>", "</vi>"}					-- purple
