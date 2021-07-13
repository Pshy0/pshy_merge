


Introduction
============

This file explain how to use the pshy modules features in your own ones.
**The current document is supposed to describe a later version, the current one should not be used yet!**



## The pshy namespace

The global table `pshy` is used as a namespace.
This means all features from Pshy are in this table.
This allow to avoid conflicts with other modules using the same object names.
This also allow to enumerate the objects inside it, even if it would be made a local in the future.

## Submodules namespaces

Some modules, specifically the bigger ones with a lot of features, may use their own namespace.
In this case, the namespace is not a table (as this could cause confusion because of the names used, as lua does not realy define a type for namespaces),  
but a prefix in the form `pshy.modulename_`.
Note that, in this case, an object `pshy.modulename` may still exist if it represent the main purpose of the module.

