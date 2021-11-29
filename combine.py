#!/usr/bin/python3
import sys
import re
import pathlib
import glob
import subprocess



# Require priorities.
# This is used for modules that do not depend on each.
REQUIRE_PRIORITIES = {}
REQUIRE_PRIORITIES["DEBUG"]				= 0.0	# Run before anything else
REQUIRE_PRIORITIES["WRAPPER"]			= 1.0	# Override functions, so have high priority
REQUIRE_PRIORITIES["ANTICHEAT"]			= 3.0	# Anticheats must intercept many things
REQUIRE_PRIORITIES["DEFAULT"]			= 5.0	# Default
REQUIRE_PRIORITIES["GAMEPLAY"]			= 10.0	# Gameplay is often low priority because it uses the other scripts
REQUIRE_PRIORITIES["MAIN"]				= 50.0	# RESERVED to override the main script's priority (since it probably require others).



def GetLuaModuleFileName(lua_name):
    """ Get the full file name for a Lua script name. """
    for path in glob.glob("./lua/**/" + lua_name, recursive = True):
        return path
    raise Exception("module '" + lua_name + "' not found!")



def GetLatestGitTag():
    p = subprocess.Popen(["git describe --tags --abbrev=0"], stdout = subprocess.PIPE, shell = True, encoding = "utf-8")
    (output, err) = p.communicate()
    p_status = p.wait()
    if p_status != 0:
        raise Exception(err)
    return output.strip(" \t\r\n")



def GetCommitsSinceLastTag():
    p = subprocess.Popen(["git rev-list  `git rev-list --tags --no-walk --max-count=1`..HEAD --count"], stdout = subprocess.PIPE, shell = True, encoding = "utf-8")
    (output, err) = p.communicate()
    p_status = p.wait()
    if p_status != 0:
        raise Exception(err)
    return output.strip(" \t\r\n")



def GetVersion():
    build = GetCommitsSinceLastTag()
    if build == "0":
        return GetLatestGitTag()
    else:
        return GetLatestGitTag() + "." + build



class LUAModule:
    """ Represent a single Lua Script. """
    
    def __init__(self, name = None):
        self.m_name = ""
        self.m_code = ""
        self.m_authors = []
        self.m_explicit_dependencies = []
        self.m_implicit_dependencies = []
        self.m_optional_dependencies = []
        self.m_hard_merge = False
        self.m_require_priority = 5.0
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
        self.m_explicit_dependencies = []
        for whole_line in self.m_code.split("\n"):
            line = whole_line.strip()
            if line.startswith("-- @author "):
                self.m_authors.append(line.split(" ", 2)[2])
            elif line.startswith("-- @require "):
                self.m_explicit_dependencies.append(line.split(" ", 2)[2])
            elif line.startswith("-- @optional_require "):
                self.m_optional_dependencies.append(line.split(" ", 2)[2])
            elif line.startswith("-- @require_priority "):
                require_priority = line.split(" ", 2)[2]
                if require_priority in REQUIRE_PRIORITIES:
                    self.m_require_priority = REQUIRE_PRIORITIES[require_priority]
                else:
                    self.m_require_priority = float(line.split(" ", 2)[2])
            elif line == "-- @hardmerge":
                self.m_hard_merge = True
                #print("-- WARNING: " + name + " uses deprecated -- @hardmerge", file=sys.stderr)
            elif line.startswith("-- @namespace "):
                pass
                #print("-- WARNING: " + name + " uses deprecated -- @namespace", file=sys.stderr)
            elif line.startswith("-- @mapmodule "):
                print("-- WARNING: " + name + " uses non-yet supported -- @mapmodule", file=sys.stderr)
            elif line.startswith("-- @todo "):
                pass
            elif line.startswith("-- @TODO:"):
                pass
            elif line.startswith("-- @TODO"):
                pass
            elif line.startswith("-- @brief "):
                pass
            elif line.startswith("-- @param "):
                pass
            elif line.startswith("-- @return "):
                pass
            elif line.startswith("-- @note "):
                pass
            elif line.startswith("-- @version "):
                pass
            elif line == "-- @public":
                pass
            elif line == "-- @private":
                pass
            elif line.startswith("-- @deprecated ") or line == "-- @deprecated":
                pass
            elif line.startswith("-- @"):
                print("-- WARNING: " + name + " uses unknown " + line, file=sys.stderr)
    
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
    
    def DependencyCompare(a, b):
        """ Compare the merging order of two modules, but only on dependencies. """
        if (b.m_name in a.m_implicit_dependencies and a.m_name in b.m_implicit_dependencies):
            raise Exception(a.m_name + " and " + b.m_name + " require each other!")
        if (a.m_name in b.m_implicit_dependencies):
            return -1
        if (b.m_name in a.m_implicit_dependencies):
            return +1
        return 0

    def PriorityCompare(a, b):
        """ Compare the merging order of two modules, but only on priority. """
        return a.m_require_priority - b.m_require_priority

    def Compare(a, b):
        """ Compare the merging order of two modules. """
        if (b.m_name in a.m_implicit_dependencies and a.m_name in b.m_implicit_dependencies):
            raise Exception(a.m_name + " and " + b.m_name + " require each other!")
        if (a.m_name in b.m_implicit_dependencies):
            return -1
        if (b.m_name in a.m_implicit_dependencies):
            return +1
        return a.m_require_priority - b.m_require_priority

class LUACompiler:
    """ Hold several scripts, and combine them into a single one. """
    
    def __init__(self):
        self.m_loaded_modules = {}  # modules by name
        self.m_dependencies = []    # modules by order
        self.m_compiled_module = None
        self.m_advanced_merge = False
        self.m_main_module = None
    
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
        if not mod_name_b in mod_a.m_explicit_dependencies:
            mod_b.m_explicit_dependencies.append(mod_name_a)
            print("-- Debug: Made " + mod_name_a + " required by " + mod_name_b + "!", file=sys.stderr)
        else:
            print("-- WARNING: Could not make " + mod_name_a + " be required by " + mod_name_b + "!", file=sys.stderr)
    
    def LoadDependencies(self):
        """ Automatically load modules required by the ones already loaded. """
        # load dependency modules until no module have remaining unmet dependency
        new_dep = True
        while new_dep:
            new_dep = False
            for modname, m in self.m_loaded_modules.items():
                for d in m.m_explicit_dependencies:
                    if not d in self.m_dependencies:
                        self.m_dependencies.append(d)
                        new_dep = True
            for d in self.m_dependencies:
                if not d in self.m_loaded_modules:
                    self.LoadModule(d)
    
    def ComputeImplicitDependencies(self):
        """ Fill all modules's internal implicit dependency lists """
        # recursive check
        for module_name, module in self.m_loaded_modules.items():
            if module_name == self.m_main_module:
                module.m_require_priority = REQUIRE_PRIORITIES["MAIN"]
            for dependency_name in module.m_explicit_dependencies:
                self.ComputeImplicitDependenciesForModuleModule(module, self.m_loaded_modules[dependency_name])
            for optional_dependency_name in module.m_explicit_dependencies:
                if not optional_dependency_name in module.m_implicit_dependencies:
                    if optional_dependency_name in self.m_dependencies:
                        module.m_implicit_dependencies.append(dependency.m_name)
    
    def ComputeImplicitDependenciesForModuleModule(self, module, dependency):
        """ Recursively fill the internal implicit dependency list of a module with dependencies of another module """
        if not dependency.m_name in module.m_implicit_dependencies:
            module.m_implicit_dependencies.append(dependency.m_name)
        for dependency_name in dependency.m_explicit_dependencies:
            self.ComputeImplicitDependenciesForModuleModule(module, self.m_loaded_modules[dependency_name])
            
    def SortDependencies(self):
        """ Internally sort the modules. """
        # yes this is not supported by Python3's sort() or sorted()...
        ordered = []
        while len(ordered) != len(self.m_loaded_modules):
            prev_len = len(ordered)
            # find modules without dependency requirements
            orderable = []
            for modname in self.m_dependencies:
                if not modname in ordered:
                    # check that the module doesnt have unmet dependencies
                    ok = True
                    for depname in self.m_loaded_modules[modname].m_implicit_dependencies:
                        if not depname in ordered:
                            ok = False
                            break
                    if ok:
                        orderable.append(modname)
            if len(orderable) == 0:
                # Dependency issue (probably cyclic)
                for modname in self.m_dependencies:
                    if not modname in ordered:
                        print("-- ERROR: cannot order dependencies for " + modname + ": ", file=sys.stderr)
                        for depname in self.m_loaded_modules[modname].m_implicit_dependencies:
                            if not depname in ordered:
                                print("-- \t" + depname, file=sys.stderr)
                raise Exception("Cyclic dependencies!?")
            # choose the module to add based on priority
            best_priority = 100
            best_module_name = None
            for modname in orderable:
                module = self.m_loaded_modules[modname]
                if module.m_require_priority < best_priority:
                    best_priority = module.m_require_priority
                    best_module_name = modname
            assert(best_module_name != None)
            ordered.append(best_module_name)
        self.m_dependencies = ordered
    
    def Merge(self):
        """ Merge the loaded modules. """
        pshy_version = GetVersion()
        self.m_compiled_module = LUAModule()
        self.m_compiled_module.m_code += "--- OUTPUT " + self.m_compiled_module.m_name + "\n"
        self.m_compiled_module.m_code += "--- \n"
        self.m_compiled_module.m_code += "--- This lua script is a compilation of other scripts.\n"
        self.m_compiled_module.m_code += "--- It was generated by pshy's merging script.\n"
        self.m_compiled_module.m_code += "--- https://framagit.org/Pshy/pshy.tfm.lua" + "\n"
        self.m_compiled_module.m_code += "--- version " + pshy_version + "\n"
        self.m_compiled_module.m_code += "-- \n"
        self.m_compiled_module.m_code += "\n"
        self.m_compiled_module.m_code += "__PSHY_VERSION__ = " + pshy_version + "\n"
        was_merge_lua_loaded = False
        for modname in self.m_dependencies:
            advanced = self.m_advanced_merge and was_merge_lua_loaded
            print("-- merging " + modname + "...", file=sys.stderr)
            if advanced:
                self.m_compiled_module.m_code += "local new_mod = pshy.merge_ModuleBegin(\"" + modname + "\")\n"
                self.m_compiled_module.m_code += "function new_mod.Content()\n"
                if self.m_main_module == modname:
                    self.m_compiled_module.m_code += "\tlocal __IS_MAIN_MODULE__ = true\n"
            self.m_compiled_module.m_code += self.m_loaded_modules[modname].m_code
            if advanced:
                self.m_compiled_module.m_code += "end\n"
                self.m_compiled_module.m_code += "new_mod.Content()\n"
                self.m_compiled_module.m_code += "pshy.merge_ModuleEnd()\n"
            if modname == "pshy_merge.lua":
                was_merge_lua_loaded = True
        if self.m_advanced_merge:
            self.m_compiled_module.m_code += "pshy.merge_Finish()\n"
    
    def Compile(self):
        """ Load dependencies and merge the scripts. """
        self.LoadDependencies()
        self.ComputeImplicitDependencies()
        self.SortDependencies()
        self.Merge()
        self.Minimize()
    
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
        c.m_main_module = argv[i_arg]
    c.Compile()
    print(c.m_compiled_module.m_code)

if __name__ == "__main__":
    Main(len(sys.argv), sys.argv)
