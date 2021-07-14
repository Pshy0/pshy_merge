# Introduction

This project contains a Python script to merge TFM lua scripts/modules,  
and some TFM modules I made as well.



# Modulepacks

I define a modulepack simply as being a set of TFM lua scripts merged together.

You can find ready-tu-run modulepacks in `modulepacks/`.

- `pshyvs.modulepack.lua`: My main TFM vs script.
- `pshyfun.modulepack.lua`: My main chill script, used for funcorp villages.
- `mario.modulepack.lua`: Module to run Nnaaaz#0000's Mario map.

The folowing scripts require you to download third-party scripts separately,  
place those in `modules/other/`,  
then run `make modulepacks/SCRIPT_NAME.lua`.

- `vsteamsantimacro.modulepack.lua`: Mattseba#0000's V/S Teams script with additions (see `!pshy.help vs`).
- `vsteams.modulepack.lua`: Mattseba#0000's V/S Teams script with additions (see `!pshy.help vs`), and an alternative antimacro.

Mattseba's scripts: https://atelier801.com/topic?f=6&t=894050&p=1#m13 (Name the files `vs_teams_with_antimacro.lua` and `vs_teams_without_antimacro.lua`.).
Note that the latest versions should accept the `!vs.` command prefix.

Run `make allall` to compile every modulepack possible, but this require you to download every single third-party script.



# Merge modules

You can merge modules using `./compile.py pshy_merge.lua [module_names_to_merge]` script.

Your modules must be located in a filder within `modules/`, by default, choose `modules/other/`.

When including `pshy_merge.lua`, either on the command line or with `-- require pshy_merge.lua`,  
you can merge modules even if they would otherwise be conflicting because they use the same events.

The merging script will look for `-- @require` directives,  
and determine a dependancy tree of the required modules.
Then, all of the content of the files are concatenated,  
in the order of the dependencies, the main module being last,  
excluding the TFM events callbacks of the non-main modules.
The contents of the different events are then merged per-function.

Example to merge the modules listed in modulepack_pshyfun.lua and  
put the result in the clipboard with `xclip` (`sudo apt install xclip`):
```bash
./compile.py modulepack_pshyfun.lua | xclip -selection clipboard
```



# Fixing conflicts

Pshy commands may be called using the `!pshy.` prefix. You can also enforce this (if another module use the same command name):
lua:
```lua
pshy.commands_require_prefix = true
```
ingame:
```
!pshy.set pshy.commands_require_prefix true
```

I may add the ability to use a prefix for any module in the future.

If several modules use a graphic interfaces or ingame objects,  
they may conflict because of the use of identical ids.
This cannot be fixed yet by `pshy_merge`.
I recommend using arbitrary random ids to dodge the issue (but I will add a function for that in the future).

If several modules use the keyboard and mouse, they may obviously conflict.
This cannot be fixed yet (but I may create a keyboard remapping script to fix this).



# Use Pshy modules as dependancies

You can, but be aware that the current version may see substantial changes.



# License

This is a TODO.
