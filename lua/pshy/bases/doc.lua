--- pshy.bases.doc
--
-- Basic documentation definitions.
-- Other scripts may either fill those tables or use their content.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



--- Help Pages.
-- Help pages contains help accessible via the `!help` command.
-- keys are the page name.
-- Values are tables with the followinf fields:
--	- back:			Name of the previous table.		
--	- title:		Displayed at the very top.
--	- desc:			Short description of the page.
--	- text:			Main body of the page.
--	- restricted:	Hide this page from non-admins.		
--	- examples:		Map of full commands to description.		
--	- commands:		Map of commands.			
--	- subpages:		Map of subpages.		
pshy.help_pages = pshy.help_pages or {}



--- Main help page (`!help`).
-- This page describe the help available.
pshy.help_pages[""] = {title = "Main Help", text = "Use '<j>*</j>' to run a command on all players.\nPrefix commands with `<j>pshy.</j>` or <j>`other.`</j> in case of conflict.\n", details = "Commands syntax:\n\n<p align='left'><v>!command(aliases) &lt;required_argument&gt; [optional_argument]</v></p>\nCommands color code:\n\n<p align='left'><v>GREEN - Commands everyone can use (commands may still not allow some actions).<v>\n<j>YELLOW - Cheat commands that are enabled when an admin use `!enablecheats`.</j>\n<r>RED - Admin only commands.</r>\n<vi>PURPLE - Script loader only commands.</vi></p>\n", subpages = {}}
pshy.help_pages["pshy"] = {back = "", title = "Pshy", text = "Pshy version '<ch2>" .. tostring(pshy.PSHY_VERSION) .. "</ch2>'.\n", subpages = {}}
pshy.help_pages[""].subpages["pshy"] = pshy.help_pages["pshy"]



--- Commands.
-- Keys are the main command name.
-- Entries are tables with the following fields:
--	- name:			The command's name.
--	- desc:			A brief description.
--	- func:			The function called when the command is used.
--	- aliases:		A list of alternative names.
--	- argc_min:		The minimum amount of arguments accepted.
--	- argc_max:		The maximum amount of arguments accepted.
--	- arg_names:	A list of argument names.
--	- arg_types:	A list of argument types (as strings).
--	- restricted:	Set to true if the command should not be displayed to everyone.
--	- perms:		The lowest rank having access to the command.
pshy.commands = pshy.commands or {}
