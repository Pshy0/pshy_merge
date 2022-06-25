--- pshy.bases.doc
--
-- Basic documentation definitions.
-- Other scripts may either fill those tables or use their content.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



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
