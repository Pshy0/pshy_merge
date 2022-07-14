Introduction
===

This document is intended to describe design choices regarding this project.
The goal is to explain why things are being done in a way and not in another.
Each explaination may begin with an introduction about the feature or topic, 
and then be folowed by an explaination about why other designs were not chosen.



Original Purpose
===

The original purpose of the script was to merge existing ready-to-run TFM Lua scripts.
It was supposed to take several TFM Lua scripts as an input, 
and output a new TFM Lua script with the functionalities of all of the input scripts.

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



Requiring with `pshy.require()`
===

The `require` function is a vanilla Lua feature, with a specific behavior.
The `pshy.require` function has a similar behavior, but not strictly identical.
The later name is used, rather than the first, for the following reasons:
 - To not create confusion with a vanilla Lua feature.
 - To not create confusion with non-identical `require` functions implemented in other scripts/repositories.
 - To allow the compiler to know what module were made knowing how it would be compiled or not.
 - To avoid compatibility isses in some scenarios.
 - It is better suited for a pre-compiler module rather than an interpreted one.

The main similarities are:
 - The required modules use the same naming than in the vanilla one (for instance "`path.to.module`").
 - Modules are first loaded when required.
 - Modules returns are only loaded once and cached.
 - The function returns what the module has returned.

The main differences are:
 - There is no path used at runtime (since it must be precompiled).
 - The `package` table is replaced by a `pshy.modules` table with a different implementation.
 - It allows you to optionaly require a module only if it is included in the compiled file with `pshy.require("module.name", true)`.



Why not using lists of ordered scripts
===

Relying on a list of ordered scripts is bad, because the list itself does not allow you to determine dependencies.
If the following modules were listed in a way similar to this pseudocode:
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
and the files themselves could require each other too.
In this case the order would not be determined by that file.

Technically, it is still possible to enforce a module order in this project from a list.
This can, for instance, be done in a Makefile, or a shell script.
But this should only be done with scripts that are not requiring each other already, and may not be necessary.



The docstring `-- @preload`
===

Including this string in a Lua module to be loaded immediately when it is included, rather than only when required.
Any script required by this one will be loaded at that time as well.

This can allow you to hook or override some of the loading features early.



Norm (Code Style)
===

Most identifiers uses the `lowercase_with_underscores` naming style, as the spacing provided by `_` makes it easier to read.

Functions use the "`CapitalCamelCasing`" when they are constant locals or constant namespace fields, so they are easier to identify.

The "`lowercaseChamelCasing`" is not used because it is too close to the function's naming and single words would be identical to what is used for other identifiers.



\*.tfm.lua.txt
===

The source files are the ones nammed `*.lua`.
To distinguish between the source files and the compiled ones that can be run in TFM, 
the later used to have names in `*.tfm.lua`.
Because some users had troubles opening those files, they are now nammed as `*.tfm.lua.txt`.
