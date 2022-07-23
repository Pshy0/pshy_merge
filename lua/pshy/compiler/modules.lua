--- pshy.compiler.modules
--
-- This file provides a definition of `pshy.modules`.
-- It may actually not be included in the compiled script.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy = pshy or {}



--- Module map.
-- This map is filled by the compiler.
-- Keys are module names, values are tables.
-- Fields of each entry:
--	- name:				The name of the module.
--	- file:				The full file name of the module.
--	- loaded:			`true` when the module has already been loaded.
--	- load:				Function that loads the module.
--	- return:			What the module returned when it was loaded.	
--	- source:			A string whith the module's code.
--	- start_line:		The line at which this module is included in the compiled code.
--	- end_line:			Last line part of this module in the compiled code.
--	- locals:			Map of local accessors as defined in `./localwrapper/access.lua`.
pshy.modules = pshy.modules or {}
