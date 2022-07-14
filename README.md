# Introduction

This project contains a Python script to merge TFM lua scripts/modules, 
and some TFM modules I made as well.
**TAKE CAUTION USING THOSE SCRIPTS, THEY MAY BE VERY UNSTABLE BEFORE 1.0**



# Compiled TFM Lua Scripts

You can find ready-to-run-in-game compiled scripts [here](https://github.com/Pshy0/pshy_merge/releases/latest).
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
- [Anvilclick](https://github.com/Pshy0/pshy_merge/releases/latest/download/pokeball.tfm.lua.txt): Catch mice inside pokeballs (**EXPERIMENTAL**).

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

The compiler script `combine.py` compiles the given Lua modules 
into a single script that can run in TFM.

By defaults, modules will be looked for in `./lua/` and `./pshy_merge/lua/`.
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
 - `--testinit`: Simulate the in initialization of the script, and display errors if there would be.
 - `--werror`: If `--testinit` fails then abort and exit with code 1.

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
 - `-- @preload`: The module will load where it is included, rather than when it is required.
 - `-- @hardmerge`: The module will be included without being listed in `pshy.modules`.

The compiler also adds some definitions. See [`pshy.compiler.definitions`](./lua/pshy/compiler/definitions.lua) for details.



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
This means that if two scripts are using the same global identifier names, they might colliding.
You can fix this by making the colliding identifiers local.

If several modules use a graphic interfaces or ingame objects, 
they may conflict because of the use of identical ids.
This cannot be fixed yet.

If several modules use the keyboard and mouse, they may obviously conflict.
This cannot be fixed yet.

If a module calls a function itself (unfortunately this is frequent), then this event will be raised to all modules, including the ones not expecting it.
Avoid calling an event yourself after initialization, unless your REALY want all modules to receive the event.
For instance, if you call `eventNewPlayer()` yourself, then all modules will receive this call.
If several modules do so, then the event will be called that many times.
This is probably not what you want.
You should instead call a function (for instance `local function TouchPlayer(player_name)`) from `eventNewGame`, and for each player, from `eventInit` (or at the end of your code).
The same goes for all events.



# License

This license only applies to the code withing this repository for which i am the author.
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
