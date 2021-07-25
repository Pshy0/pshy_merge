#!/usr/bin/python3
import sys
import re
import pathlib
import glob

def GetLuaModuleFileName(lua_name):
    """ Get the full file name for a Lua script name. """
    for path in glob.glob("./lua/**/" + lua_name, recursive = True):
        return path
    raise Exception("module '" + lua_name + "' not found!")

class LUAModule:
    """ Represent a single Lua Script. """
    def __init__(self, name = None):
        self.m_code = ""
        self.m_name = ""
        self.m_dependencies = []
        self.m_hard_merge = False
        if name != None:
            self.Load(name)
    def Load(self, name):
        """ Load this module (read it). """
        print("-- loading " + name + "...", file=sys.stderr)
        self.m_name = name
        file_name = GetLuaModuleFileName(name)
        f = open(file_name, mode="r")
        self.m_code = f.read()
        f.close()
        # look for special tags
        self.m_dependencies = []
        for whole_line in self.m_code.split("\n"):
            line = whole_line.strip()
            if line.startswith("-- @require "):
                self.m_dependencies.append(line.split(" ", 2)[2])
            if line == "-- @hardmerge":
                self.m_hard_merge = True
    def Minimize(self):
        """ Reduce the script's size without changing its behavior. """
        # This is hacky but i will implement something better later.
        # Currently this will beak codes using multiline features.
        # remove `---[[`
        self.m_code = re.sub(r'-+--\[\[.*$', '', self.m_code, flags=re.MULTILINE)
        # remove `-- --[[`
        self.m_code = re.sub(r'--.*--\[\[.*$', '', self.m_code, flags=re.MULTILINE)
        # remove --
        self.m_code = re.sub(r'\s*--[^\[].*$', '', self.m_code)
        self.m_code = re.sub(r'^--[^\[].*$', '', self.m_code)
        # remove blank lines        
        self.m_code = re.sub(r'^\s*$', '', self.m_code, flags=re.MULTILINE)
        self.m_code = self.m_code.replace("\n\n","\n")
        # remove useless spaces (breaks strings)
        #self.m_code = self.m_code.replace("    ","\t")
        #self.m_code = self.m_code.replace("  "," ")
        #self.m_code = self.m_code.replace("\t\t","\t")
        #self.m_code = self.m_code.replace(", ",",")
        #self.m_code = self.m_code.replace(" .. ","..")
    def cmp(a, b):
        """ Dependency order comparizon function. """
        if a in b.m_dependencies:
            if b in a.m_dependencies:
                raise a.m_name + " and " + b.m_name + " depends on each other!"
            return -1
        if b in a.m_dependencies:
            return +1
        return 0

class LUACompiler:
    """ Hold several scripts, and combine them into a single one. """
    def __init__(self):
        self.m_loaded_modules = {}  # modules by name
        self.m_dependencies = []    # modules by order
        self.m_compiled_module = None
        self.m_advanced_merge = False
    def LoadModule(self, name):
        """  """
        self.m_loaded_modules[name] = LUAModule(name)
        if not name in self.m_dependencies:
            self.m_dependencies.append(name)
        if name == "pshy_merge.lua":
            self.m_advanced_merge = True
    def AddDependencyIfPossible(self, mod_name_a, mod_name_b):
        """ Make b depends on a if a does not already depends on b. """
        mod_a = self.m_loaded_modules[mod_name_a]
        mod_b = self.m_loaded_modules[mod_name_b]
        if not mod_name_b in mod_a.m_dependencies:
            mod_b.m_dependencies.append(mod_name_a)
    def LoadDependencies(self):
        """ Automatically load modules required by the ones already loaded. """
        # load dependency modules
        new_dep = True
        while new_dep:
            new_dep = False
            for modname, m in self.m_loaded_modules.items():
                for d in m.m_dependencies:
                    if not d in self.m_dependencies:
                        self.m_dependencies.append(d)
                        new_dep = True
            for d in self.m_dependencies:
                if not d in self.m_loaded_modules:
                    self.LoadModule(d)
        self.SortDependencies()
    def SortDependencies(self):
        """ Internally sort the modules. """
        # yes this is not supported by Python3's sort() or sorted()...
        ordered = []
        while len(ordered) != len(self.m_loaded_modules):
            prev_len = len(ordered)
            for modname in self.m_dependencies:
                if not modname in ordered:
                    met = True
                    for d in self.m_loaded_modules[modname].m_dependencies:
                        if not d in ordered:
                            met = False
                            break
                    if met:
                        ordered.append(modname)
            if prev_len == len(ordered):
                raise Exception("cyclic dependencies!")
        self.m_dependencies = ordered
    def Merge(self):
        """ Merge the loaded modules. """
        self.m_compiled_module = LUAModule()
        was_merge_lua_loaded = False
        for modname in self.m_dependencies:
            advanced = self.m_advanced_merge and not self.m_loaded_modules[modname].m_hard_merge
            print("-- merging " + modname + "...", file=sys.stderr)
            if advanced:
                assert was_merge_lua_loaded == True, modname + " began before the merge script!"
                self.m_compiled_module.m_code += "pshy.merge_ModuleBegin(\"" + modname + "\")\n"
            elif self.m_advanced_merge and was_merge_lua_loaded:
                self.m_compiled_module.m_code += "pshy.merge_ModuleHard(\"" + modname + "\")\n"
            self.m_compiled_module.m_code += self.m_loaded_modules[modname].m_code
            if advanced:
                assert was_merge_lua_loaded == True, modname + " ended before the merge script!"
                self.m_compiled_module.m_code += "pshy.merge_ModuleEnd()\n"
            if modname == "pshy_merge.lua":
                was_merge_lua_loaded = True
        if self.m_advanced_merge:
            self.m_compiled_module.m_code += "pshy.merge_Finish()\n"    
    def Minimize(self):
        """ reduce the output script's size """
        self.m_compiled_module.Minimize()

def Main(argc, argv):
    c = LUACompiler()
    last_module = None
    for i_arg in range(1, argc):
        if argv[i_arg] == "--":
            last_module = None
            continue
        c.LoadModule(argv[i_arg])
        if last_module != None:
            c.AddDependencyIfPossible(last_module, argv[i_arg])
        last_module = argv[i_arg]
    c.LoadDependencies()
    c.Merge()
    c.Minimize()
    print(c.m_compiled_module.m_code)

if __name__ == "__main__":
    Main(len(sys.argv), sys.argv)
