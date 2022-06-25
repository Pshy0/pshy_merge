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
local command_list = {}



return command_list
