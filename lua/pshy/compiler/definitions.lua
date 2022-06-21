--- pshy.compiler.definitions
--
-- This file provides example definitions for things defined by the compiler.
-- The compiler itself define those, you must not require this script.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @error Please do not require this module.



--- pshy
-- Namespace of pshy's script, also used for some of the compiler variables.
local pshy = {}
_G.pshy = pshy



--- pshy.MAIN_VERSION
-- The version of this script (obtained from the repository tag).
-- Not present if only compiling pshy components.
pshy.MAIN_VERSION = "v0.0.3"



--- pshy.PSHY_VERSION
-- The version of pshy's script (obtained from the repository tag).
-- Not present if only compiling pshy components.
pshy.MAIN_VERSION = "v0.9"



--- pshy.BUILD_TIME
-- The time at which the script was built.
pshy.BUILD_TIME = 72748764824



--- pshy.INIT_TIME
-- The time at which the script started initializing.
-- This is simply a call to `os.time()`.
pshy.INIT_TIME = os.time()



--- pshy.modules
-- A map of module names to module tables.
-- See `pshy.compiler.modules` (`./modules.lua`).
pshy.modules = {}



--- pshy.modules_list
-- A list of module tables in unconditional require order.
-- When executing, scripts may be required in a different order.
pshy.modules_list = {}



--- pshy.require
-- Function behaving similarly to the Lua `require`.
-- See `pshy.compiler.require` (`./require.lua`).



--- __IS_MAIN_MODULE__
-- Defined as a local within the main module.
-- The main module is usually the last one included on the command-line.
local __IS_MAIN_MODULE__ = true
