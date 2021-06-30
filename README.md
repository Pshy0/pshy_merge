# Introduction

This project contains a Python script to merge TFM lua modules,  
and some TFM modules as well.



# Merge modules

You can merge modules using `./compile.py pshy_merge.lua [module_names_to_merge]` script.

The merging script will look for `-- @require` directives,  
and determine a dependancy tree of the required modules.
Then, all of the content of the files are concatenated,  
in the order of the dependencies, the main module being last,  
excluding the TFM events callbacks of the non-main modules.
The contents of the different events are then merged per-function.

Example to merge the modules listed in modulepack_vs.lua and  
put the result in the clipboard:
```bash
./compile.py .lua | xclip -selection clipboard
```



# Use Pshy modules as dependancies

You can, but be aware that the current version may include substantial changes.



# License

This is a TODO.
