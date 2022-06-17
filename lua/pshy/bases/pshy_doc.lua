--- pshy_modules.lua
--
-- Basic documentation definitions.
-- Other scripts may either fill those tables or use their content.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy = pshy or {}



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
