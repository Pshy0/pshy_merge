# Introduction

This project contains a Python script to merge TFM lua scripts/modules, 
and some TFM modules I made as well.
**TAKE CAUTION USING THOSE SCRIPTS, THEY MAY BE VERY UNSTABLE BEFORE 1.0**



# Compiled TFM Lua Scripts

You can find ready-to-run-in-game compiled scripts [here](https://github.com/Pshy0/pshy_merge/releases/latest).
You should find the same scripts in the `tfm_lua` folder after running `make`.

**Some scripts exist in an anticheat variant, ask Pshy to get them (only for FunCorps).**

Scripts included in this repository:
- [123 Soleil !](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy.games.123soleil.tfm.lua.txt): Grandmother's footsteps (**EXPERIMENTAL**).
- [Essentials Everything](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy.essentials.everything.tfm.lua.txt): Many scripts in one.
- [FastTime](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy.games.fasttime.tfm.lua.txt): Mice have 3 minutes to make the best score on nosham maps.
- [Bonuses](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy.rotations.list.bonuses.tfm.lua.txt): Vanilla but with custom bonuses.
- [Chicken Game](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy.games.chickengame.tfm.lua.txt): My levels for Nnaaaz's chicken game (singleplayer puzzle).
- [Pacmice](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy.games.pacmice.tfm.lua.txt): Mice have to run away from a Pac-Cheese.
- [Pshy's VS](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy.games.vs.tfm.lua.txt): Another VS script (**NOT FINISHED**).
- [Pshy's VS + Commentator](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy.games.vs_with_commentator.tfm.lua.txt): Same as the VS script but with gameplay comments (**NOT FINISHED**).
- [The Best Shaman](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy.games.thebestshaman.tfm.lua.txt): Allow mice to rank their shaman (**NOT FINISHED**).
- [Anvilclick](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy.games.anvilclick.tfm.lua.txt): Mice can click to throw anvils (**EXPERIMENTAL**).
- [Pokeball](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy.games.pokeball.tfm.lua.txt): Catch mice inside pokeballs (**EXPERIMENTAL**).
- [Valentines Racing](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy.games.valentines_racing.tfm.lua.txt): Racing mode in teams of two.

Older scripts (Not maintained):
- [Mario 1](https://github.com/Pshy0/pshy_merge/releases/download/v0.8.8/pshy_mario.tfm.lua.txt): Script that runs nnaaaz's Mario 1 map (**DISMAINTAINED**).

Projects using pshy_merge:
- [Nnaaaz's Chicken Game](https://pastebin.com/Zqgc4BXh)
- [Nnaaaz's Death Maze](https://github.com/nnaaaz/DeathMaze)
- [Nnaaaz's Mario 2](https://github.com/nnaaaz/Mario_TFM)

Help about ingame commands is available [here](./HELP.md).

You can also see [all previous and pre-release versions here](https://github.com/Pshy0/pshy_merge/releases).



# Compiling Modules

The compiler script `combine.py` compiles the given Lua modules 
into a single script that can run in TFM.

By defaults, modules will be looked for in `./lua/` and `./pshy_merge/lua/`.
Folders containing an `init.lua` files are also considered modules.
Modules are included in the order given on the command-line, 
except if an early module requires a later one.

Options:
 - `--out <file>`: Specifies the file to output to (Outputs on stdout by default).
 - `--deps <file>`: Outputs a dependency file includable by Makefiles.
 - `--add-path <path>:` Adds a Lua path to look for modules at.
 - `--lua-command <interpreter>`: Allows including Lua modules installed on your computer. The argument is the interpreter name. Then you can use the `require()` function.
 - `--include-sources`: Next modules will have their source included in the output as a string (see `pshy.compiler.modules`).
 - `--no-include-sources` (default): Next modules will not have their source added as a string in the output.
 - `--test-init`: Simulate the initialization of the script, and display errors if there would be.
 - `--werror`: If `--testinit` fails then abort and exit with code 1.
 - `--enabled-modules` (default): Next specified modules will be manually enabled by default.
 - `--disabled-modules`: Next specified modules will be manually disabled by default. They can be enabled in-game with `!enablemodule <module_name>` or by enabling modules that depends on them.
 - `--direct-modules`: The next modules are not enabled when they are dependencies for enabled modules. They can be manually or directly enabled or disabled.
 - `--indirect-modules` (default): The next modules are automatically enabled when they are dependencies of enabled modules.
 - `--reference-locals` Adds accessors to locals. See `pshy.debug.glocals`. Use `!ls ~/module.name/~` to list locals and `!ls/set ~/module.name/local_name` to access. Locals must be on their own line.
 - `--minify-comments`: Removes comments from the output script (keep the header).
 - `--minify-spaces`: Removes unnecessary spaces from the output (keep line returns).
 - `--minify`: Equivalent to `--minify-comments --minify-spaces`.
 - `--minify-unreadable`: Removes unnecessary new lines plus `--minify` (minimal gain, becomes unreadable).
 - `--minify-globally`: Minimize the whole generated script instead of minimizing per-module (minimal gain, becomes unreadable).
 - `--minify-strings`: Creates a string index when this saves size (minimal gain, becomes unreadable).
 - `--minify-luamin`: Runs `luamin` over individual modules before they are merged. Gain is slightly better than running `luamin` by itself, and you wont end up with a giant lagging line of code.
 - `--clip`: Send the output to the clipboard.

Example to compile `pshy.games.fasttime`, test that it initialize without error, minify it while keeping it readable, and output the result to your clipboard:
```bash
./combine.py --test-init --minify pshy.games.fasttime --clip
```

The module `pshy.essentials.everything` contains most of this repository features.



# Writing Modules

When reading source files, the compiler includes files based on the `pshy.require()` calls it finds.
Files are ordered accordingly, but their content only runs at runtime.
This means conditional requires should work.

Additionaly, the following doctags can be used:
 - `-- @author`: Adds an author for the file.
 - `-- @header`: Adds a line in the output file's header.
 - `-- @preload`: The module will load where it is included, rather than when it is required.
 - `-- @hardmerge`: The module will be included without being listed in `pshy.modules`.

The compiler also adds some definitions. See [`pshy.compiler.definitions`](./lua/pshy/compiler/definitions.lua) for details.

The compiler will define those per-module variables if you use them:
 - `__IS_MAIN_MODULE__`: Is this module the last specified module on the command-line.
 - `__MODULE_NAME__`: The current module's name.
 - `__MODULE_INDEX__`: Index of this module in `pshy.modules`.
 - `__MODULE__`: A table with information about the current module.

Use `__MODULE__.require_direct_enabling = true` to cause the module to only be enabled either manually or directly, but not by modules requiring it.
This is useful for modules that only run on a specific map.
Modules required by a map can be specified in the map's xml when using `pshy.rotations.newgame` with `pshy.rotations.mapinfo`.

Depending on the modules you use, those additional events may be available:
 - `eventInit(time)`: Called when all modules were loaded, before they are enabled.
 - `eventThisModuleEnabled()`: Called when this module have just been enabled. Dependencies are enabled beforehand (requires `pshy.moduleswitch`).
 - `eventThisModuleDisabled()`: Called when this module have just been disabled. Dependencies are disabled afterhand (requires `pshy.moduleswitch`).
 - `eventModuleEnabled(module_name)`: Called when a module have been enabled (requires `pshy.moduleswitch`).
 - `eventModuleDisabled(module_name)`: Called when a module have been disabled (requires `pshy.moduleswitch`).
 - `eventSoulmateChanged(player_name, new_soulmate_name)`: Called when the player's spouse changed (requires `pshy.bases.events.soulmatechanged`).

The module `pshy.alternatives.mt` replaces most features that are module-team-only, so you can run Lua Event scripts.
You may need to run `!setplayerdata` after loading the script to set your save data, keep that field empty the first time you load it.
You can run `!modulereload event_module_name` to play the event again.



# Fixing conflicts / issues

Commands may optionally be prefixed by either:
- `!pshy.`: Run a command from a `pshy_merge` script.
- `!other.`: Run a command from another script.

The script loader is automatically added as admin in `pshy_merge` scripts, and you can add more admins with `!admin`.
The script will attempt to make `pshy_merge` admins also admin in other included scripts.
However, not all scripts are implemented the same, so you may still need to add your nickname in the other scripts by hand.

The module `pshy.events` contains the features used to make scripts using events compatible.
You need to include it if it is not already included by one of the `pshy_merge` scripts.

When a module abort an event by returning a value, the whole event is aborted in other modules too (except for some events).
ready-to-run scripts should not be doing that anyway since this is not used by TFM, but if they do, this can cause issues.

Modules are currently not run in different environments (perhaps in the near future?).
This means that if two scripts are using the same global identifier names, they may collide.
You can fix this by making the colliding identifiers local.

If several modules use a graphic interfaces or ingame objects, 
they may conflict because of the use of identical ids.
This cannot be fixed yet.

If several modules use the keyboard and mouse, they may obviously conflict.
This cannot be fixed yet.

If a module calls an event itself, then it will be raised in all modules (except if done before `eventInit`).
Avoid calling an event yourself, unless your REALY want all modules to receive the event.
If you want to run some code from more than a single event, you may put this code into its own function and call it instead of calling the event.



# License

This license only applies to the code within this repository for which i am the author.
It does not applies to code or resources from other authors (cf maps or map lists).
It does not applies to ressources that does not mention an author (cf images).
It does not applies to sub-repositories (cf the anticheat).
The content for which this license does not applies may be using a different license.

Provided that:
 - You do not remove credits to the original authors from the souce files.
 - You clearly mark modified source files as such.

Then you are allowed to:
 - Copy the project to your personal storage.
 - Modify the project.
 - Redistribute the project (even modified, if you clearly mention it).
 - Use the project in a private or public environment (for instance in-game).

Additionally:
 - You do not need to give credits if you are reusing minor parts of the code (less than a file).
 - You can alter or remove the credit header appended by the compiler at the beginning of output files.



# See Also

[Transformice lua performance tests.](https://github.com/Pshy0/transformice_lua_perf_tests)
