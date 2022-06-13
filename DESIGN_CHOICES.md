Introduction
===

This document is intended to describe design choices regarding this project.
The goal is to explain why things are being done in a way and not in another.
Each explaination may begin with an introduction to what is the feature for, 
and then be folowed by an explaination about why other designs were not chosen.

The choice of topics in this document are often due to interactions with other persons in the community.



Original Purpose
===

The original purpose of the script was to merge existing ready-to-run Lua scripts.
It was supposed to take several runnable TFM Lua scripts as an input, 
and output a new runnable TFM Lua script having the functionalities of both.

A command to merge third-party modules `module1.lua` and `module2.lua` would be:
```bash
./combine.py module1.lua module2.lua
```
In the above example, there is no need to modify either `module1.lua` or `module2.lua`.
The output is done on stdout so it can be redirected to the file of your choice.
This way, merging already-built third-party modules is trivial.



Basic Additional Scripts
===

Basic scripts with a single functionality in each were added to the repository.
This would have allowed to add functionnalities from those scripts by merging them together.
For instance, a script would add custom emoticons, another would add a spectator platform, etc..
This example merges `module1.lua`, `module2.lua`, and object rains functionalities to it:
```bash
./combine.py pshy_rain.lua module1.lua module2.lua
```
Note that neither `module1.lua` nor `module2.lua` is supposed to know about `pshy_rain.lua`.
Because none of the modules depends on each other, the order does not realy matter.
Also `pshy_rain.lua` could be merged "alone", 
which would result in only having the object rains functionalities in the output script.



Why not using `require()`
===

The `require` function is supposed to be part of Lua.
Altering or re-implementing it in a different way would make the source files using it not valid Lua files anymore.
Of course, everything else in the file would remain valid lua, but no longer would the file as a whole.

For instance, the folowing file is one valid Lua module:
```lua
--- first.lua
local module_table = {}
function module_table.Function()
	print("Hello World")
end
return module_table
```
And this a valid usage of that module:
```lua
local module_table_namespace = require("first")
module_table_namespace.Function()
```
This behavior is often not re-implemented properly, 
and the result is that `require` becomes a pre-processing directive rather than lua instruction, 
that despite being an existing Lua function, does not behave as it is supposed to.

`require` is supposed to be a function ran at runtime, not a precompiler directive.
This project is about compiling scripts into one, so something else seamed more appropriate.



Why not using lists of ordered scripts
===

Relying on a list of ordered scripts is bad, because the list itself does not allow you to determine dependencies.
If the folowing modules were listed in a way similar to this pseudocode:
```lua
--- init.lua
require "A"
require "B"
require "C"
```
This is not enough to know if `B` needs `A`, if `C` needs `B`, or if `C` needs `A`.
If nor `B` nor `C` were depending on `A`, but you wanted to use a function of `C` in `A`, you would need to check at all the files in between in case they depend on `C` too so that you can reorder the files properly.
For this informations to be clear, it would be preferable to have each file list its dependencies.
And no manual re-ordering would be necessary.

Note that a file supposed to represent a whole functionality, made out of the other files in the same folder, 
could perfectly require all the other files in that folder, 
and the files themselves could require each other.
In this case the order would not be determined by that file.

 
Technically, it is still possible to enforce a module order in this project from a list.
This can, for instance, be done in a Makefile, or any a shell script.
But this should only be done with scripts that are not requiring each other already, and may not be necessary.



The docstring `-- @require <module_name>`
===

In source files, the string `-- @require <module_name>` tells the merging script that the current scripts needs another one to function properly.
Required scripts will be automatically added the the output, and ordered automatically, even if you do not mention them explicitely.
The order of scripts can still be forced from the command-line, and the compilation will purposefully fail if you order the scripts wrong.
You may specify scripts that wont be forcefully ordered by separating them with `--` like in the folowing:
```bash
./combine.py pshy_rain.lua -- pshy_emoticons.lua
```
This will let the compiler choose the best order automatically (in this case any order will do).

In most languages, `-- @sometext` are used as docstrings.
They are used to generate documentation automatically.
So the first advantage of this is that automatically generated documention will contain informations about dependencies.
Also the files themselves contains this information.

Docstrings are also comments, so they wont realy execute.
This means that the individual files using them are still valid Lua files, even if they require the merging script to output something that can runs in TFM.



The docstring `-- @optional_require <module_name>`
===

This means that the current module use features from another one, but will still work if the other module is not available.
This can be because the script first check if the feature is available.

This allow to not include a module if the features it would add the that script are not realy needed or not wished in a specific release.



Using relative file names VS unique file names
===

This project uses unique file names.
This means that every Lua source file name that can be merged is unique within the repository.
This have pros and cons.
Pros:
 - Knowing the module name is enough to include it when merging, the whole path is not needed.
 It's also easier to remember.
 - When re-organizing modules, for instance switching one from the private repository to the public one,
 there is no need to change the pathes in all files, just to move the file.
 - Most of the files are single features with a specific name. As such they have unique names anyway.
Cons:
 - File names must be unique withing the repository, even in different folders.
 So features that are split in several files need longer prefixes to avoid collision.
 
Eventually, I may change this to relative pathes with multiple roots, like what `require` does with pathes.
I may retain the possibility of not using the full pathes for modules prefixed with `pshy_` that will have unique names anyway.
Currently, it is like if all subdirectories in `lua/` was a Lua path.



Organizing Files
===

Source files are organized in several folders or subfolders.
A folder may correspond either to:
 - A complex feature that is split into several files, in wich case there is a single file you can include to get all the functionalities from there (cf `lua/pshy/emulator`).
 - A category of smaller features (cf `lua/pshy/tools`).
 - An author or visibility (cf `lua/pshy_private/`).

A few features may be splitted in several scripts.
For instance, this is the case of the anticheat (private) or the emulator (used to rapidly test scripts).
You only need to require `pshy_anticheat.lua` or `pshy_emulator.lua` to get all the other files as well.
There is also a script `pshy_essentials_plus.lua` that includes mostly everything from the repository.

However, not all the features are organized this way, because:
 - There is numerous small features, splitting them would result in a realy big number of small files.
 - Some features are not always required, so being able to select the scripts used will make the output smaller and more customized.
 - This is not a project with tons of classes with many functions in each that form a single atomic whole when combined.



The docstring `-- @require_priority <priority>`
===

While some scripts requires each other, making their ordering determinable, it may not be the case for others.
In fact, most of the scripts that does not require each other can be merged in any order without affecting the functionalities.
When needed, dependencies can be added when merging, if you, for instance, need a debug script to be put before `module2.lua`:
```bash
./combine.py module1.lua -- debug_script.lua module2.lua
```

As mentioned, this secondary ordering is often not necessary for scripts to work, but in may have an effect in the folowing scenarios:
 - A feature is wrapping a function. 
 It altering the behavior of that functions means it's preferable that it is included early.
 - A feature is causing an event to abort. 
 This is the case for scripts that, to save performances, abort an even, causing the later modules to not receive it.

Too make things simpler, the `-- @require_priority` let you specify a category (require priority) for the script.
After ordering the scripts depending on what other scripts they require, when possible, the merging script will order depending on the require priority.
This is not equivalent to a dependency, as dependencies are handled first.
This have the folowing benefits:
 - You have an alternative to explicitely ordering scripts. 
 This is especially useful when using the command-line to create combinations of scripts, 
 rather than having to edit and maintain a list of scripts in the right order.
 - This optimizes the default behavior for the script ordering.
 - Decreases the chances of errors due to improper ordering of files by the developper.
 To discover and fix such errors, it may be preferable to let them happen.
 But for released scripts, it is not preferable to increase the chances of those errors happening while users are running them.




