#!/usr/bin/python3
import sys
import re
import pathlib
import glob

def get_lua_module_file_name(lua_name):
    for path in glob.glob("./modules/**/" + lua_name, recursive = True):
        return path
    for path in glob.glob("./modulepacks/**/" + lua_name, recursive = True):
        return path
    print("module '" + lua_name + "' not found! Check your @require(s)!", file=sys.stderr)
    exit()

class LUAModule:
    def __init__(self, name = None):
        self.m_code = ""
        self.m_name = ""
        self.m_dependencies = []
        self.m_hard_merge = False
        if name != None:
            self.load(name)
    def load(self, name):
        print("-- loading " + name + "...", file=sys.stderr)
        self.m_name = name
        file_name = get_lua_module_file_name(name)
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
    def minimize(self):
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
        if a in b.m_dependencies:
            if b in a.m_dependencies:
                raise a.m_name + " and " + b.m_name + " depends on each other!"
            return -1
        if b in a.m_dependencies:
            return +1
        return 0

class LUACompiler:
    def __init__(self):
        self.m_loaded_modules = {}  # modules by name
        self.m_dependencies = []    # modules by order
        self.m_compiled_module = None
        self.m_advanced_merge = False
    def load_module(self, name):
        self.m_loaded_modules[name] = LUAModule(name)
        if not name in self.m_dependencies:
            self.m_dependencies.append(name)
        if name == "pshy_merge.lua":
            self.m_advanced_merge = True
    def load_dependencies(self):
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
                    self.load_module(d)
        self._sort_dependencies()
    def _sort_dependencies(self):
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
                pass #raise "cyclic dependencies!"
        self.m_dependencies = ordered
    def merge(self):
        self.m_compiled_module = LUAModule()
        for modname in self.m_dependencies:
            advanced = self.m_advanced_merge and not self.m_loaded_modules[modname].m_hard_merge
            print("-- merging " + modname + "...", file=sys.stderr)
            if advanced:
                self.m_compiled_module.m_code += "pshy.ModuleBegin(\"" + modname + "\")\n"
            elif self.m_advanced_merge:
                self.m_compiled_module.m_code += "print('Pasting " + modname + "...')\n"  
            self.m_compiled_module.m_code += self.m_loaded_modules[modname].m_code
            if advanced:
                self.m_compiled_module.m_code += "pshy.ModuleEnd()\n"
        if self.m_advanced_merge:
            self.m_compiled_module.m_code += "pshy.MergeFinish()\n"    
    def minimize(self):
        self.m_compiled_module.minimize()

def main(argc, argv):
    c = LUACompiler()
    for i_arg in range(1, argc):
        c.load_module(argv[i_arg])
    c.load_dependencies()
    c.merge()
    c.minimize()
    print(c.m_compiled_module.m_code)

if __name__ == "__main__":
    main(len(sys.argv), sys.argv)
