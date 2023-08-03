--- pshy.commands.list
--
-- The commands's list.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



--- Commands lists
-- keys represent the lowecase command name.
-- values are tables with the following fields:
-- - func: the function to run
--   the functions will take the player name as the first argument,
--   then the remaining ones.
-- - help: the help string to display when querying for help.
-- - arg_types: an array the argument types (not including the player name).
--   if arg_types is undefined then this is determined automatically.
-- - arg_names:
-- - no_user: true if the called function doesnt take the command user as
--   a first argument.
local help_pages = pshy.require("pshy.help.pages")
pshy.require("pshy.events")



local command_dict = {}



function eventInit()
	for i_module, m in ipairs(pshy.module_list) do
		local m_name = m.name
		if m.commands then
			local help_page = help_pages[m_name]
			if help_page then
				help_page.commands = help_page.commands or {}
			else
				print_error("no help page for %s", m_name)
			end
			for command_name, command in pairs(m.commands) do
				command_dict[command_name] = command
				if help_page then
					help_page.commands[command_name] = command
				end
			end
		end
	end
end



return command_dict
