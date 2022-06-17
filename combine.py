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



def ListLineRequires(line):
    requires = []
    matches = re.findall(r"(--)|\bpshy\.require\s*\(\s*\"(.*?)\"\s*\)|\bpshy\.require\s*\(\s*\'(.*?)\'\s*\)|\bpshy\.require\s*\(\s*\[\[(.*?)\]\]\s*\)", line)
    for match in matches:
        for match_group in match:
            if match_group == '--':
                return requires 
            if match_group != '':
                requires.append(match_group)
    return requires



def ListRequires(code):
    requires = []
    for line in code.splitlines():
        requires.extend(ListLineRequires(line))
    return requires



def GetLuaModuleFileName(lua_name):
    """ Get the full file name for a Lua script name. """
    if not lua_name.endswith(".lua"):
        lua_name += ".lua"
    for path in glob.glob("./lua/**/" + lua_name, recursive = True):
        return path
    for path in glob.glob(CURRENT_DIRECTORY + "/lua/**/" + lua_name, recursive = True):
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

    def __init__(self, name = None):
        self.m_file = None
        self.m_name = name
        self.m_source = None
        self.m_authors = []
        self.m_header = None
        self.m_requires = []
        self.m_hard_merge = False
        self.m_include_source = False
        if name != None:
            self.Load(name)

    def Load(self, name):
        """ Load this module (read it). """
        print("-- loading " + name + "...", file=sys.stderr)
        self.m_name = name
        if self.m_name.endswith(".lua"):
            self.m_name = self.m_name[:-4]
        self.m_file = GetLuaModuleFileName(name)
        self.m_source = ReadFile(self.m_file)
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
            elif line.startswith("-- @header "):
                if self.m_header == None:
                    self.m_header = []
                self.m_header.append(line.split(" ", 2)[2])
            elif line.startswith("-- @namespace "):
                pass
            elif line.startswith("-- @note "):
                pass
            elif line.startswith("-- @optional_require "):
                print("-- WARNING: " + name + " uses deprecated -- @optional_require", file=sys.stderr)
            elif line.startswith("-- @param "):
                pass
            elif line == "-- @private":
                pass
            elif line == "-- @public":
                pass
            elif line.startswith("-- @require "):
                self.m_requires.append(line.split(" ", 2)[2])
            elif line.startswith("-- @require_priority "):
                print("-- WARNING: " + name + " uses deprecated -- @require_priority", file=sys.stderr)
            elif line.startswith("-- @return "):
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
        self.m_requires.extend(ListRequires(self.m_source))

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



class LUACompiler:
    """ Hold several scripts, and combine them into a single one. """

    def __init__(self):
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
        self.LoadModule("pshy_require")

    def RequireModule(self, module_name):
        self.m_requires.append(module_name)
        return self.LoadModule(module_name)

    def LoadModule(self, module_name):
        if not module_name in self.m_modules:
            module = LUAModule(module_name)
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
        self.m_compiled_module.m_source += "_G.pshy = _G.pshy or {}\n"
        self.m_compiled_module.m_source += "local pshy = _G.pshy\n"
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
            self.m_compiled_module.m_source += "pshy.modules[\"{0}\"].start_line = {1}\n".format(module.m_name, self.m_compiled_module.m_source.count('\n') + 3)
            if not module.m_hard_merge:
                self.m_compiled_module.m_source += "pshy.modules[\"{0}\"].load = function()\n{1}end\n".format(module.m_name, module.m_source)
            else:
                self.m_compiled_module.m_source += "do\n{0}end\n".format(module.m_source)
            self.m_compiled_module.m_source += "pshy.modules[\"{0}\"].end_line = {1}\n".format(module.m_name, self.m_compiled_module.m_source.count('\n') - 1)
            if module.m_hard_merge:
                self.m_compiled_module.m_source += "pshy.modules[\"{0}\"].loaded = true\n".format(module.m_name)
        # Add module sources
        for module in self.m_ordered_modules:
            if self.m_include_sources or module.m_include_source:
                self.m_compiled_module.m_source += "pshy.modules[\"{0}\"].source = [=[\n{1}]=]\n".format(module.m_name, module.m_source.replace("[=[", "[=========[").replace("]=]", "]=========]"))
        # Add command-line requires
        for module_name in self.m_requires:
            self.m_compiled_module.m_source += "pshy.require(\"{0}\")\n".format(module_name)
        # Create events
        if "pshy_events" in self.m_modules:
            self.m_compiled_module.m_source += "pshy.events_CreateFunctions()\n"
    
    def Compile(self):
        """ Load dependencies and merge the scripts. """
        self.Minimize()
        self.Merge()

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
