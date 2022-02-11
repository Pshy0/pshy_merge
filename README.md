# Introduction

This project contains a Python script to merge TFM lua scripts/modules,  
and some TFM modules I made as well.
**TAKE CAUTION USING THOSE SCRIPTS, THEY MAY BE VERY UNSTABLE BEFORE 1.0**

**/!\\ Due to some issues, individual modules cannot be enabled/disabled after compilation. this should soon be fixed.**



# TODO

My personal TODO list is available [here](./TODO.md).
Feel free to create issues on github if something is not in the list.



# Combined TFM Lua Scripts

Projects using pshy_merge:
- [Nnaaaz's death maze](https://github.com/nnaaaz/DeathMaze)

You can find ready-to-run-in-game combined scripts [here](https://github.com/Pshy0/pshy_merge/releases/tag/latest).
You should find the same scripts in the `examples` folder after running `make`.

- `pacmice.tfm.lua`: A pacman module, but with mice.
- `mario.tfm.lua`: Module to run Nnaaaz#0000's Mario map.
- `bonus_luamaps.tfm.lua`: Custom bonuses demo module.
- `pshyvs.tfm.lua`: My main TFM vs script.
- `pshyfun.tfm.lua`: My main chill script, used for funcorp villages.

Help about ingame commands is available [here](./HELP.md).



# Merge modules

The easiest way to add a single module to an already compiled script in the examples (or from the latest release), 
is to find the folowing lines and place your code in between:
```lua
-- \/ INSERT YOUR SCRIPT JUST BELOW THIS LINE \/
-- /\ INSERT YOUR SCRIPT JUST OVER THIS LINE /\
```
This way, your script will have the functionalities from both your script and the example script you have chosen.

You can merge modules using `./combine.py pshy_merge.lua [additional_module_names_to_merge_in_that_order] <main_module>` script.

Your modules must be located in a folder within `lua/`
The folder `lua/pshy/` is reserved for Pshy's scripts.
The folder `lua/pshy_private/` is reserved for Pshy's private scripts.
The folder `lua/test/` is reserved for test scripts.
The folder `lua/tmp/` is reserved.
Use the `lua/other/` folder by default, or create one for you.

Within your source files, you can use the following documentation tags:
- `-- @require otherscript.lua`: Specify that your script require another one.
- `-- @optional_require otherscript.lua`: Specify that your script require to be included after another one (only if the other script is used).
- `-- @require_priority CATEGORY`: Secondary setting to help choosing the order for script that dont depends on each other (see `combine.py` for possible values).
Those settings help choosing the order in which the different scripts will be merged.
This also define the order in which the events will be called.

When including `pshy_merge.lua`, either on the command line or with `-- @require pshy_merge.lua`,  
you can merge modules even if they would otherwise be conflicting because they use the same events.

Example to merge the modules listed in modulepack_pshyfun.lua and  
put the result in the clipboard with `xclip`:
```bash
./combine.py modulepack_pshyfun.lua | xclip -selection clipboard
```



# Minigames (NOT SUPPORTED YET, BUT SOON)

If you make a minigame script that is supposed to only run when your map is enabled, 
add `-- @mapmodule` somewhere in your script, so that it wont be enabled by default.
You also need to add en entry in `pshy.mapdb_maps` so that your script get loaded when this map is run.
Your other module's events wont be called while the module is disabled (callbacks will still be called).
You can add this at the end of your script to simulate it being ran as a minigame (without the pshy modules):
```lua
if not pshy then
	if eventInit then
		eventInit()
	end
	if eventEnableModule then
		eventEnableModule()
	end
end
```



# Fixing conflicts / issues

Pshy's commands may be called using the `!pshy ` prefix. You can also enforce this (if another module use the same command name):
lua:
```lua
pshy.commands_require_prefix = true
```
ingame:
```
!pshy set pshy.commands_require_prefix true
```

Avoid calling an event yourself, unless your REALY want all modules to receive the event.
For instance, if you call `eventNewPlayer()` yourself, then all modules will receive this call.
This is probably not what you want.
You should instead call a function (for instance `local function TouchPlayer(player_name)`) from `eventNewGame`, and for each player, from `eventInit`.
The same goes for all events.

I may add the ability to use a prefix for any module in the future.

If several modules use a graphic interfaces or ingame objects,  
they may conflict because of the use of identical ids.
This cannot be fixed yet by `pshy_merge`.
I recommend using arbitrary random ids to dodge the issue (but I will add a function for that in the future).

If several modules use the keyboard and mouse, they may obviously conflict.
This cannot be fixed yet (but I may create a keyboard remapping script to fix this).

The merging scripts abort an event if you return either True or False from it.
In this case, later modules will not receive the event.



# Use Pshy modules as dependancies

You can, but be aware that the current version may see substantial changes.



# License

This is a TODO.
But you will be able to reuse the scripts as long as I am mentioned as the original author.
Some scripts may also be from other people (They should be credited in the source files after a `-- @author`).
