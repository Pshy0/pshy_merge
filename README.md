# Introduction

This project contains a Python script to merge TFM lua scripts/modules, 
and some TFM modules I made as well.
**TAKE CAUTION USING THOSE SCRIPTS, THEY MAY BE VERY UNSTABLE BEFORE 1.0**



# Combined TFM Lua Scripts

You can find ready-to-run-in-game combined scripts [here](https://github.com/Pshy0/pshy_merge/releases/tag/latest).
You should find the same scripts in the `tfm.lua` folder after running `make`.

**Some scripts exist in an anticheat variant, ask Pshy to get them (only for FunCorps).**

Scripts included in this repository:
- [123 Soleil !](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy_123soleil.tfm.lua.txt): Grandmother's footsteps (**EXPERIMENTAL**).
- [Essentials Plus](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy_essentials_plus.tfm.lua.txt): Many scripts in one.
- [FastTime](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy_fasttime.tfm.lua.txt): Mice have 3 minutes to make the best score on nosham maps.
- [Fun](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy_fun.tfm.lua.txt): Many scripts in one, cheat commands are available to everyone.
- [Bonuses](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy_mapdb_bonuses.tfm.lua.txt): Vanilla but with custom bonuses.
- [Chicken Game](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy_mapdb_chickengame.tfm.lua.txt): My levels for Nnaaaz's chicken game (singleplayer puzzle).
- [Pacmice](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy_pacmice.tfm.lua.txt): Mice have to run away from a Pac-Cheese.
- [Pshy's VS](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy_vs.tfm.lua.txt): Another VS script (**NOT FINISHED**).
- [Pshy's VS + Commentator](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy_vs_with_commentator.tfm.lua.txt): Same as the VS script but with gameplay comments (**NOT FINISHED**).
- [The Best Shaman](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy_thebestshaman.tfm.lua.txt): Allow mice to rank their shaman (**NOT FINISHED**).
- [Anvilclick](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy_anvilclick.tfm.lua.txt): Mice can click to throw anvils (**EXPERIMENTAL**).

Older scripts (No maintained):
- [Mario 1](https://github.com/Pshy0/pshy_merge/releases/download/v0.8.8/pshy_mario.tfm.lua.txt): Script that runs nnaaaz's Mario 1 map.

Additionaly, the folowing script allow to test TFM scripts for errors outside of TFM:
- [TFM Test Emulator](https://github.com/Pshy0/pshy_merge/releases/latest/download/pshy_vs.tfm.lua.txt): Simulate the execution of your module in tfm, with a pre-made scenario, in accelerated time (**NOT FINISHED**).
Run this scipt in a Lua console before another Lua script, then call `pshy.tfm_emulator_BasicTest()` to simulate a random run of your script.
See `pshy_tfm_emulator.lua` for details about how to make your own scenarios.

Projects using pshy_merge:
- [Nnaaaz's Chicken Game](https://pastebin.com/Zqgc4BXh)
- [Nnaaaz's Death Maze](https://github.com/nnaaaz/DeathMaze)
- [Nnaaaz's Mario 2](https://github.com/nnaaaz/Mario_TFM)

Help about ingame commands is available [here](./HELP.md).

You can also see [all previous and pre-release versions here](https://github.com/Pshy0/pshy_merge/releases).



# Compiling Modules

The compiler script `combine.py` combines the given Lua modules 
into a single script that can run in TFM.

By defaults, modules will be looked for in `./lua/` and `./pshy/lua/`.
Folders containing an `init.lua` files are also considered modules.
Modules are included in the order given on the command-line, 
except if an early module requires a later one.

Options:
 - `--out <file>`: Specifies the file to output to (Outputs on stdout by default).
 - `--deps <file>`: Outputs a dependency file includable by Makefiles.
 - `--minimize`: Removes the comments, empty lines and trailing spaces from the output file.
 - `--addpath <path>:` Adds a Lua path to look for modules at.
 - `--luacommand <interpreter>`: Allows including Lua modules installed on your computer. The argument is the interpreter name.
 - `--includesources|--includesource <module.name>`: Includes the module's source in the output (see `pshy.compiler.modules`).

Example to compile `pshy.essentials_plus` and output the result to your clipboard:
```bash
./combine.py pshy.essentials_plus.lua | xclip -selection clipboard
```



# Writing Modules

When reading source files, the compiler includes files based on the `pshy.require()` calls it finds.
Files are ordered accordingly, but their content only runs at runtime.
This means conditional requires should work.

Additionaly, the following doctags can be used:
 - `-- @author`: Adds an author for the file.
 - `-- @header`: Adds a line in the output file's header.
 - `-- @hardmerge`: The module will be included without being listed in `pshy.modules`.
 - `-- @preload`: The module will load where it is included, rather than when it is required.

The compiler also adds some definitions. See [`pshy.compiler.definitions`](./lua/pshy/compiler/definitions.lua) for details.



# Fixing conflicts / issues

Pshy's commands may be called using the `!pshy.` prefix. You can also enforce this (if another module use the same command name):
lua:
```lua
pshy.commands_require_prefix = true
```
ingame:
```
!pshy.set pshy.commands_require_prefix true
```
You can use another script's commands by prefixing them with `!other.`.

If you are not admin or do not have all the admin features, try using `!admin YourName#0000`.
If this does not work, you may have to add your name in a thirdparty script.

If several modules use a graphic interfaces or ingame objects, 
they may conflict because of the use of identical ids.
This cannot be fixed.

If several modules use the keyboard and mouse, they may obviously conflict.
This cannot be fixed.

If a module calls a function itself (unfortunately this is frequent), then this event will be raised to all modules, including the ones not expecting it.
Avoid calling an event yourself after initialization, unless your REALY want all modules to receive the event.
For instance, if you call `eventNewPlayer()` yourself, then all modules will receive this call.
If several modules do so, then the event will be called that many times.
This is probably not what you want.
You should instead call a function (for instance `local function TouchPlayer(player_name)`) from `eventNewGame`, and for each player, from `eventInit` (or at the end of your code).
The same goes for all events.

The merging scripts abort an event if you return either True or False from it.
In this case, later modules will not receive the event.
This does not work with all modules (see the `pshy.merge_minimize_events` set in `pshy_merge.lua`).



# License

This license applies to the content of this repository, including the builds from the "releases" section.
It does not apply to builds released outside of this repository (mainly the anticheat variants).

You are allowed to use, copy, modify, or redistribute the whole project, or parts of it, as long as mentions to the original authors remain in the source files.
You do not need to give credits to reuse minor parts of the code (less than a file).
