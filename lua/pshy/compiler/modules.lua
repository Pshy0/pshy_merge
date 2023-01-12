--- pshy.compiler.modules
--
-- This file provides a definition of `pshy.modules`.
-- It may actually not be included in the compiled script.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



--- Module map.
-- This map is filled by the compiler.
-- Keys are module names, values are tables representing each module.
-- Each of those tables have the followinf fields:
-- Fields reserved for internal use:
--	- load:						Function that loads the module.
--	- return:					What the module returned when it was loaded.	
-- Read-only fields:
--	- name:						The name of the module.
--	- file:						The full file name of the module.
--	- loaded:					`true` when the module has already been loaded.
--	- source:					A string whith the module's code.
--	- start_line:				The line at which this module is included in the compiled code.
--	- end_line:					Last line of this module in the compiled code.
--	- locals:					Map of local accessors as defined in `./localwrapper/access.lua`.
--	- enabled:					Is this module enabled.
--	- enable_count:				How many times this module was required to be enabled.
--	- required_modules:			Modules required by this one.
--	- manually_enabled:			If the module was enabled by the command-line or `!enablemodule`.
-- Fields that can be set before eventInit():
--	- require_direct_enabling:	The module will not be enabled automatically as a dependency.
pshy.modules = pshy.modules or {}
