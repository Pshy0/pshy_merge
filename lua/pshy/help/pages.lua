--- pshy.help.pages
--
-- Base list for help pages.
--
-- @author tfm:Pshy#3752



--- Help pages.
-- Key is the name page.
-- Value is the help table (help page).
-- Help pages fields:
--	string:back			- upper page.
--	string:title		- title of the page.
--	string:text			- text to display at the top of the page.
--	set:commands		- set of chat command names.
--	set:examples		- map of action (string) -> command (string) (click to run).
--	set:subpages		- set of pages to be listed in that one at the bottom.
--	bool:restricted		- if true, require the permission "!help page_name"
local help_pages = {}



help_pages[""] = {title = "Main Help", text = "Use '<j>*</j>' to run a command on all players.\nPrefix commands with `<j>pshy.</j>` or <j>`other.`</j> in case of conflict.\n", details = "Commands syntax:\n\n<p align='left'><v>!command(aliases) &lt;required_argument&gt; [optional_argument]</v></p>\nCommands color code:\n\n<p align='left'><v>GREEN - Commands everyone can use (commands may still not allow some actions).<v>\n<j>YELLOW - Cheat commands that are enabled when an admin use `!enablecheats`.</j>\n<r>RED - Admin only commands.</r>\n<vi>PURPLE - Script loader only commands.</vi></p>\n", subpages = {}}
help_pages["pshy"] = {back = "", title = "Pshy", text = "Pshy version '<ch2>" .. tostring(pshy.PSHY_VERSION) .. "</ch2>'.\n", subpages = {}}
help_pages[""].subpages["pshy"] = help_pages["pshy"]



return help_pages
