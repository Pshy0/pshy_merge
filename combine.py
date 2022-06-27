#!/usr/bin/python3
import glob
import os
import pathlib
import re
import subprocess
import sys
import time



# current folder
CURRENT_DIRECTORY = str(pathlib.Path(__file__).parent.absolute())
WORKING_DIRECTORY = os.getcwd()



def ReadFile(file_name):
    f = open(file_name, mode="r")
    content = f.read()
    f.close()
    return content



def WriteFile(file_name, content):
    f = open(file_name, mode="w")
    f.write(content)
    f.close()



def ListLineRequires(line, vanilla_require):
    requires = []
    require_regex = r"(--)|\bpshy\.require\s*\(\s*\"(.*?)\"\s*\)|\bpshy\.require\s*\(\s*\'(.*?)\'\s*\)|\bpshy\.require\s*\(\s*\[\[(.*?)\]\]\s*\)|\bpshy\.require\s*\"(.*?)\""
    if vanilla_require:
        require_regex = r"(--)|\brequire\s*\(\s*\"(.*?)\"\s*\)|\brequire\s*\(\s*\'(.*?)\'\s*\)|\brequire\s*\(\s*\[\[(.*?)\]\]\s*\)|\brequire\s*\"(.*?)\""
    matches = re.findall(require_regex, line)
    for match in matches:
        for match_group in match:
            if match_group == '--':
                return requires 
            if match_group != '':
                requires.append(match_group)
    return requires



def ListRequires(code, vanilla_require):
    requires = []
    for line in code.splitlines():
        requires.extend(ListLineRequires(line, vanilla_require))
    return requires



def GetLuaModuleFileName(lua_name):
    """ Get the full file name for a Lua script name. """
    file_name = lua_name
    if not file_name.endswith(".lua"):
        file_name += ".lua"
    for path in glob.glob("./lua/**/" + file_name, recursive = True):
        return path
    for path in glob.glob(CURRENT_DIRECTORY + "/lua/**/" + file_name, recursive = True):
        return path
    raise Exception("module '" + lua_name + "' not found!")
    
    

def GetLatestGitTag(directory):
    #git describe --tags --abbrev=0
    #git tag --sort=version:refname | grep v0 | tail -n 1
    p = subprocess.Popen(["cd " + CURRENT_DIRECTORY + " && git tag --sort=version:refname | grep v0 | tail -n 1"], stdout = subprocess.PIPE, shell = True, encoding = "utf-8")
    (output, err) = p.communicate()
    p_status = p.wait()
    if p_status != 0:
        raise Exception(err)
    return output.strip(" \t\r\n")



def GetCommitsSinceTag(directory, tag):
    #git rev-list v0.3..HEAD --count  
    #git rev-list  `git rev-list --tags --no-walk --max-count=1`..HEAD --count
    p = subprocess.Popen(["cd " + CURRENT_DIRECTORY + " && git rev-list " + tag + "..HEAD --count"], stdout = subprocess.PIPE, shell = True, encoding = "utf-8")
    (output, err) = p.communicate()
    p_status = p.wait()
    if p_status != 0:
        raise Exception(err)
    return output.strip(" \t\r\n")



def GetVersion(directory):
    tag = GetLatestGitTag(directory)
    build = GetCommitsSinceTag(directory, tag)
    if build == "0":
        return tag
    else:
        return tag + "-c" + build



class LUAModule:
    """ Represent a single Lua Script. """

    def __init__(self, file = None, name = None, vanilla_require = False):
        self.m_file = file
        self.m_name = name
        self.m_source = None
        self.m_authors = []
        self.m_header = None
        self.m_requires = []
        self.m_hard_merge = False
        self.m_preload = False
        self.m_include_source = False
        if file != None:
            self.Load(file, vanilla_require)

    def Load(self, file, vanilla_require):
        """ Load this module (read it). """
        print("-- loading {0} from {1}...".format(self.m_name, self.m_file), file=sys.stderr)
        self.m_source = ReadFile(self.m_file).replace("\r\n", "\n")
        if not self.m_source.endswith("\n"):
            self.m_source += "\n"
        # look for special tags
        self.m_explicit_dependencies = []
        for whole_line in self.m_source.split("\n"):
            line = whole_line.strip()
            if line.startswith("-- @author "):
                self.m_authors.append(line.split(" ", 2)[2])
            elif line.startswith("-- @brief "):
                pass
            elif line.startswith("-- @cf "):
                pass
            elif line.startswith("-- @deprecated ") or line == "-- @deprecated":
                pass
            elif line == "-- @header":
                if self.m_header == None:
                    self.m_header = []
                self.m_header.append("")
            elif line == "-- @hardmerge":
                self.m_hard_merge = True
                print("-- WARNING: " + self.m_name + " uses non-implemented `-- @hardmerge`, did you mean `-- @preload`?", file=sys.stderr)
            elif line.startswith("-- @header "):
                if self.m_header == None:
                    self.m_header = []
                self.m_header.append(line.split(" ", 2)[2])
            elif line.startswith("-- @namespace "):
                pass
            elif line.startswith("-- @note "):
                pass
            elif line.startswith("-- @optional_require "):
                print("-- WARNING: " + self.m_name + " uses deprecated -- @optional_require", file=sys.stderr)
            elif line.startswith("-- @param "):
                pass
            elif line == "-- @preload":
                self.m_preload = True
            elif line == "-- @private":
                pass
            elif line == "-- @public":
                pass
            elif line.startswith("-- @require "):
                raise Exception("-- @require is no longer supported")
            elif line.startswith("-- @require_priority "):
                print("-- WARNING: " + self.m_name + " uses deprecated -- @require_priority", file=sys.stderr)
            elif line.startswith("-- @return "):
                pass
            elif line.startswith("-- @source "):
                pass
            elif line.startswith("-- @TODO"):
                pass
            elif line.startswith("-- @TODO:"):
                pass
            elif line.startswith("-- @todo "):
                pass
            elif line.startswith("-- @version "):
                pass
            elif line.startswith("-- @"):
                print("-- WARNING: " + self.m_name + " uses unknown " + line, file=sys.stderr)
        # Add files using the experimental syntax
        self.m_requires.extend(ListRequires(self.m_source, vanilla_require))
        # Check header module name
        first_lines = self.m_source.split("\n", 3)
        if len(first_lines) > 2 and first_lines[0].startswith("--- ") and ("." in first_lines[0]) and first_lines[1] == "--":
            if first_lines[0] != "--- " + self.m_name:
                print("-- WARNING: " + self.m_file + " has wrong module name in its header!", file=sys.stderr)

    def Minimize(self, remove_comments):
        """ Reduce the script's size without changing its behavior. """
        # This is hacky but i will implement something better later.
        # Currently this will beak codes using multiline features.
        if remove_comments:
            print("-- INFO: removing comments...", file=sys.stderr)
            # remove `---[[...`
            self.m_source = re.sub(r'-+--\[\[.*$', '', self.m_source, flags=re.MULTILINE)
            # remove `--...--[[...`
            self.m_source = re.sub(r'--.*--\[\[.*$', '', self.m_source, flags=re.MULTILINE)
            # remove `--`
            self.m_source = re.sub(r'^--[^\[\r\n]*$', '', self.m_source, flags=re.MULTILINE)
            # remove `--...`
            self.m_source = re.sub(r'\t+--.*$', '', self.m_source, flags=re.MULTILINE)
            self.m_source = re.sub(r'^\s*', '', self.m_source, flags=re.MULTILINE)
        # remove blank lines        
        self.m_source = re.sub(r'^\s*$', '', self.m_source, flags=re.MULTILINE)
        self.m_source = self.m_source.replace("\n\n","\n")
        # remove trailing spaces 
        self.m_source = re.sub(r'\s*$', '', self.m_source, flags=re.MULTILINE)
        # add back the last line feed
        self.m_source += "\n"



class LUACompiler:
    """ Hold several scripts, and combine them into a single one. """

    def __init__(self):
        self.m_lua_command = None
        path_roots = ["./lua", CURRENT_DIRECTORY + "/lua", CURRENT_DIRECTORY + "/lua/pshy_private"]
        self.m_pathes = []
        for path in path_roots:
            self.m_pathes.append(path + "/?.lua")
            self.m_pathes.append(path + "/?/init.lua")
        self.m_requires = []            # Module names explicitely required on the command-line.
        self.m_modules = {}                # Map of modules.
        self.m_ordered_modules = []        # List of modules in loaded order.
        self.m_compiled_module = None
        self.m_main_module = None
        self.m_minimize = False
        self.m_localpshy = False
        self.m_deps_file = None
        self.m_out_file = None
        self.m_include_sources = False
        self.m_test_init = False
        self.LoadModule("pshy.compiler.require")

    def GetDefaultLuaPathes(self):
        p = subprocess.Popen(["echo \"print(package.path)\" | " + self.m_lua_command], stdout = subprocess.PIPE, shell = True, encoding = "utf-8")
        (output, err) = p.communicate()
        p_status = p.wait()
        if p_status != 0:
            print("-- WARN: Invalid Lua command!", file=sys.stderr)
            return []
        return output.strip("\r\n").split(";")
    
    def FindModuleFile(self, module_name):
        for path in self.m_pathes:
            full_file_name = path.replace("?", module_name.replace(".", "/"))
            if os.path.exists(full_file_name):
                if not full_file_name.endswith(".lua"):
                    raise Exception("File {0}'s extension is not supported!".format(full_file_name))
                return full_file_name
        raise Exception("Module {0} not found!".format(module_name))

    def TestInit(self):
        source = self.m_compiled_module.m_source
        test_source = "do _ENV = require(\"lua.pshy.compiler.tfmenv\").env {0} end".format(source)
        WriteFile(".pshy_merge_test.tmp", test_source)
        p = subprocess.Popen(["cat .pshy_merge_test.tmp | " + (self.m_lua_command or "lua")], stdout = subprocess.PIPE, shell = True, encoding = "utf-8")
        (output, err) = p.communicate()
        p_status = p.wait()
        if p_status != 0 or err != None:
            print("-- WARN: Initialization may fail: \n{0}".format(err), file=sys.stderr)
            return False
        return True

    def RequireModule(self, module_name):
        self.m_requires.append(module_name)
        self.m_main_module_name = module_name
        return self.LoadModule(module_name)

    def LoadModule(self, module_name):
        if not module_name in self.m_modules:
            module_file = self.FindModuleFile(module_name)
            module = LUAModule(module_file, module_name, self.m_lua_command != None)
            self.m_modules[module_name] = module
            for i_require in range(0, len(module.m_requires)):
                self.LoadModule(module.m_requires[i_require])
            self.m_ordered_modules.append(module)
            return module
        else:
            return self.m_modules[module_name]

    def Merge(self):
        """ Merge the loaded modules. """
        self.m_compiled_module = LUAModule()
        self.m_compiled_module.m_source = ""
        # Add explicit module headers
        for i_module in range(len(self.m_ordered_modules) - 1, -1, -1):
            module = self.m_ordered_modules[i_module]
            if module.m_header != None:
                for line in module.m_header:
                    self.m_compiled_module.m_source += "--- " + line + "\n"
        # Add the pshy header
        pshy_version = GetVersion(CURRENT_DIRECTORY)
        main_version = None
        if CURRENT_DIRECTORY != WORKING_DIRECTORY:
            main_version = GetVersion(WORKING_DIRECTORY)
        if self.m_out_file:
            self.m_compiled_module.m_source += "---- " + self.m_out_file + "\n"
        else:
            self.m_compiled_module.m_source += "---- STDOUT\n"
        self.m_compiled_module.m_source += "--- \n"
        self.m_compiled_module.m_source += "--- This script is a compilation of other scripts.\n"
        self.m_compiled_module.m_source += "--- The compiler used was pshy_merge:\n"
        self.m_compiled_module.m_source += "--- https://github.com/Pshy0/pshy_merge\n"
        self.m_compiled_module.m_source += "--- pshy version: {0}\n".format(pshy_version)
        if main_version:
            self.m_compiled_module.m_source += "--- script version: {0}\n".format(main_version)
        self.m_compiled_module.m_source += "--- \n"
        self.m_compiled_module.m_source += "\n"
        # Entering main scrope
        self.m_compiled_module.m_source += "do\n"
        self.m_compiled_module.m_source += "local pshy = {}\n"
        self.m_compiled_module.m_source += "pshy.PSHY_VERSION = pshy.PSHY_VERSION or \"{0}\"\n".format(pshy_version)
        if main_version:
            self.m_compiled_module.m_source += "pshy.MAIN_VERSION = pshy.MAIN_VERSION or \"{0}\"\n".format(main_version)
        self.m_compiled_module.m_source += "pshy.BUILD_TIME = pshy.BUILD_TIME or \"{0}\"\n".format(str(time.time()))
        self.m_compiled_module.m_source += "pshy.INIT_TIME = os.time()\n"
        self.m_compiled_module.m_source += "math.randomseed(os.time())\n"
        self.m_compiled_module.m_source += "print(\" \")\n"
        # Add basic module definitions
        self.m_compiled_module.m_source += "pshy.modules = pshy.modules or {}\n"
        for module in self.m_ordered_modules:
            self.m_compiled_module.m_source += "pshy.modules[\"{0}\"] = {{name = \"{0}\", file = \"{1}\"}}\n".format(module.m_name, module.m_file)
        # Add ordered module list
        self.m_compiled_module.m_source += "pshy.modules_list = pshy.modules_list or {}\n"
        for module in self.m_ordered_modules:
            self.m_compiled_module.m_source += "table.insert(pshy.modules_list, pshy.modules[\"{0}\"])\n".format(module.m_name)
        # Add module codes
        for module in self.m_ordered_modules:
            source_header = ""
            if module.m_name == self.m_main_module_name:
                source_header += "local __IS_MAIN_MODULE__ = true\n"
            self.m_compiled_module.m_source += "pshy.modules[\"{0}\"].start_line = {1}\n".format(module.m_name, self.m_compiled_module.m_source.count('\n') + 3 + source_header.count("\n"))
            if not module.m_preload:
                self.m_compiled_module.m_source += "pshy.modules[\"{0}\"].load = function()\n{1}{2}end\n".format(module.m_name, source_header, module.m_source)
            else:
                self.m_compiled_module.m_source += "do\n{0}{1}end\n".format(source_header, module.m_source)
            self.m_compiled_module.m_source += "pshy.modules[\"{0}\"].end_line = {1}\n".format(module.m_name, self.m_compiled_module.m_source.count('\n') - 1)
            if module.m_preload:
                self.m_compiled_module.m_source += "pshy.modules[\"{0}\"].loaded = true\n".format(module.m_name)
            if module.m_name == "pshy_require" and self.m_lua_command:
                self.m_compiled_module.m_source += "require = pshy.require\n"
        # Add module sources
        for module in self.m_ordered_modules:
            if self.m_include_sources or module.m_include_source:
                self.m_compiled_module.m_source += "pshy.modules[\"{0}\"].source = [=[\n{1}]=]\n".format(module.m_name, module.m_source.replace("[=[", "[=========[").replace("]=]", "]=========]"))
        # Add command-line requires
        for module_name in self.m_requires:
            self.m_compiled_module.m_source += "pshy.require(\"{0}\")\n".format(module_name)
        # Create events
        if "pshy.events" in self.m_modules:
            self.m_compiled_module.m_source += "pshy.require(\"pshy.events\").CreateFunctions()\n"
        # Initialization done
        self.m_compiled_module.m_source += "print(string.format(\"<v>Loaded <ch2>%d files</ch2> in <vp>%d ms</vp>.\", #pshy.modules_list, os.time() - pshy.INIT_TIME))\n"
        # Exiting main scrope
        self.m_compiled_module.m_source += "end\n"

    def Compile(self):
        """ Load dependencies and merge the scripts. """
        if self.m_lua_command:
            self.m_pathes.extend(self.GetDefaultLuaPathes())
        self.Minimize()
        self.Merge()
        if self.m_test_init:
            self.TestInit()

    def Minimize(self):
        """ Minimize loaded scripts. """
        if not self.m_include_sources:
            for module in self.m_ordered_modules:
                if not module.m_include_source:
                    module.Minimize(self.m_minimize)

    def Output(self):
        self.OutputDependencies()
        self.OutputResult()

    def OutputDependencies(self):
        if self.m_deps_file != None:
            deps_str = ""
            if self.m_out_file != None:
                deps_str = self.m_out_file + ": "
            else:
                deps_str = "deps/" + self.m_dependencies[len(self.m_dependencies) - 1].replace(".lua", ".tfm.lua.txt.d") + ": "
            for module in self.m_modules.values():
                deps_str += " " + module.m_file
            deps_str += "\n"
            WriteFile(self.m_deps_file, deps_str)

    def OutputResult(self):
        if self.m_out_file != None:
            WriteFile(self.m_out_file, self.m_compiled_module.m_source)
        else:
            print(self.m_compiled_module.m_source)



def Main(argc, argv):
    c = LUACompiler()
    i_arg = 1
    while i_arg < argc:
        if argv[i_arg] == "--deps":
            i_arg += 1
            c.m_deps_file = argv[i_arg]
            i_arg += 1
            continue
        if argv[i_arg] == "--out":
            i_arg += 1
            c.m_out_file = argv[i_arg]
            i_arg += 1
            continue
        if argv[i_arg] == "--minimize":
            c.m_minimize = True
            i_arg += 1
            continue
        if argv[i_arg] == "--includesource":
            i_arg += 1
            module = c.RequireModule(argv[i_arg])
            module.m_include_source = True
            i_arg += 1
            continue
        if argv[i_arg] == "--includesources":
            c.m_include_sources = True
            i_arg += 1
            continue
        if argv[i_arg] == "--addpath":
            i_arg += 1
            c.m_pathes.append(argv[i_arg])
            i_arg += 1
            continue
        if argv[i_arg] == "--luacommand":
            c.m_lua_command = argv[i_arg]
            i_arg += 1
            continue
        if argv[i_arg] == "--testinit":
            c.m_test_init = True
            i_arg += 1
            continue
        if argv[i_arg] == "--":
            i_arg += 1
            continue
        c.RequireModule(argv[i_arg])
        c.m_main_module = argv[i_arg]
        i_arg += 1
    c.Compile()
    c.Output()

if __name__ == "__main__":
    Main(len(sys.argv), sys.argv)
