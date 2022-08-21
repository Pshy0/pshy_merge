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
    p = subprocess.Popen(["git describe --tags"], stdout = subprocess.PIPE, shell = True, encoding = "utf-8", cwd = directory)
    (output, err) = p.communicate()
    p_status = p.wait()
    if p_status != 0:
        raise Exception(err)
    return output.strip(" \t\r\n")



def GetCommitsSinceTag(directory, tag):
    #git rev-list v0.3..HEAD --count  
    #git rev-list  `git rev-list --tags --no-walk --max-count=1`..HEAD --count
    p = subprocess.Popen(["git rev-list " + tag + "..HEAD --count"], stdout = subprocess.PIPE, shell = True, encoding = "utf-8", cwd = directory)
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



def InsertBeforeReturn(source, addition):
    lines = source.rstrip('\n').rsplit('\n', 1)
    if lines[1].startswith("return "):
    	return lines[0] + "\n" + addition + lines[1] + "\n"
    else:
    	return source + addition



class LUAModule:
    """ Represent a single Lua Script. """

    def __init__(self, file = None, name = None, vanilla_require = False):
        self.m_file = file
        self.m_friendly_file = None
        if self.m_file:
            self.m_friendly_file = re.sub('.*/pshy_merge/', 'pshy_merge/', self.m_file, flags=re.MULTILINE)
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

    def RemoveComments(self):
        # remove `---[[...`
        self.m_source = re.sub(r'-+--\[\[.*$', '', self.m_source, flags=re.MULTILINE)
        # remove `--...--[[...`
        self.m_source = re.sub(r'--.*--\[\[.*$', '', self.m_source, flags=re.MULTILINE)
        # remove `--`
        self.m_source = re.sub(r'^--[^\[\r\n]*$', '', self.m_source, flags=re.MULTILINE)
        # remove `-- `
        self.m_source = re.sub(r'^--\s.*$', '', self.m_source, flags=re.MULTILINE)
        # remove `--...`
        self.m_source = re.sub(r'\t+--.*$', '', self.m_source, flags=re.MULTILINE)
        # remove blank lines        
        self.m_source = re.sub(r'^\s*$', '', self.m_source, flags=re.MULTILINE)
        self.m_source = self.m_source.replace("\n\n","\n").lstrip("\n")

    def Minimize(self, remove_comments):
        """ Reduce the script's size without changing its behavior. """
        # This is hacky but i will implement something better later.
        # Currently this will beak codes using multiline features.
        if remove_comments:
            self.RemoveComments(self)
        # remove blank lines
        self.m_source = re.sub(r'^\s*$', '', self.m_source, flags=re.MULTILINE)
        self.m_source = self.m_source.replace("\n\n","\n").lstrip("\n")
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
        self.m_requires = []               # Module names explicitely required on the command-line.
        self.m_modules = {}                # Map of modules.
        self.m_ordered_modules = []        # List of modules in loaded order.
        self.m_compiled_module = None
        self.m_main_module = None
        self.m_minimize = False
        self.m_localpshy = False
        self.m_deps_file = None
        self.m_out_file = None
        self.m_include_sources = False
        self.m_reference_locals = False
        self.m_test_init = False
        self.m_werror = False
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
        test_source = "do _ENV.pshy = {{require = require}}  package.path = package.path .. \";./lua/?.lua;./lua/?/init.lua;{0}/lua/?.lua;{0}/lua/?/init.lua\"  _ENV = require(\"pshy.compiler.tfmenv\").env {1} end".format(CURRENT_DIRECTORY, source)
        WriteFile(".pshy_merge_test.tmp.lua", test_source)
        p = subprocess.Popen(["cat .pshy_merge_test.tmp.lua | " + (self.m_lua_command or "lua")], stdout = subprocess.PIPE, stderr = subprocess.PIPE, shell = True, encoding = "utf-8")
        (output, err) = p.communicate()
        p_status = p.wait()
        if p_status != 0 or err != "":
            print("-- WARNING: Initialization may fail:", file=sys.stderr)
            print(output + "\n" + err, file=sys.stderr)
            if self.m_werror:
                sys.exit(1)
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
        # Compiled module
        self.m_compiled_module = LUAModule()
        header_chunk = ""
        # Wrapping Locals
        localwrapper_header = None
        localwrapper_access = None
        localwrapper_chunk = ""
        if self.m_reference_locals:
            localwrapper_header = LUAModule("./lua/pshy/compiler/localwrapper/header.lua", "pshy.compiler.localwrapper.header")
            localwrapper_header.RemoveComments()
            localwrapper_access = LUAModule("./lua/pshy/compiler/localwrapper/access.lua", "pshy.compiler.localwrapper.access")
            localwrapper_access.RemoveComments()
        # Add explicit module headers
        for i_module in range(len(self.m_ordered_modules) - 1, -1, -1):
            module = self.m_ordered_modules[i_module]
            if module.m_header != None:
                for line in module.m_header:
                    header_chunk += "--- " + line + "\n"
        # Add the pshy header
        pshy_version = GetVersion(CURRENT_DIRECTORY)
        main_version = None
        if CURRENT_DIRECTORY != WORKING_DIRECTORY:
            main_version = GetVersion(WORKING_DIRECTORY)
        if self.m_out_file:
            header_chunk += "---- " + self.m_out_file + "\n"
        else:
            header_chunk += "---- STDOUT\n"
        header_chunk += "--- \n"
        header_chunk += "--- This script is a compilation of other scripts.\n"
        header_chunk += "--- Compiler: pshy_merge (https://github.com/Pshy0/pshy_merge).\n"
        header_chunk += "--- pshy version: {0}\n".format(pshy_version)
        if main_version:
            header_chunk += "--- script version: {0}\n".format(main_version)
        header_chunk += "--- \n"
        header_chunk += "\n"
        # Entering main scrope
        header_chunk += "do\n"
        header_chunk += "local pshy = {}\n"
        header_chunk += "pshy.PSHY_VERSION = pshy.PSHY_VERSION or \"{0}\"\n".format(pshy_version)
        if main_version:
            header_chunk += "pshy.MAIN_VERSION = pshy.MAIN_VERSION or \"{0}\"\n".format(main_version)
        header_chunk += "pshy.BUILD_TIME = pshy.BUILD_TIME or \"{0}\"\n".format(str(time.time()))
        header_chunk += "pshy.INIT_TIME = os.time()\n"
        header_chunk += "math.randomseed(os.time())\n"
        header_chunk += "if not _ENV then _ENV = _G end\n"
        header_chunk += "_ENV.pshy = pshy\n"
        header_chunk += "print(\" \")\n"
        # Add basic module definitions
        header_chunk += "pshy.modules_list = pshy.modules_list or {}\n"
        # Add a module map
        postindex_chunk = ""
        postindex_chunk += "pshy.modules = pshy.modules or {}\n"
        postindex_chunk += "for i_module, module in ipairs(pshy.modules_list) do\n"
        postindex_chunk += "	pshy.modules[module.name] = module\n"
        postindex_chunk += "end\n"
        # Modules
        index_chunk = ""
        codes_chunk = ""
        sources_chunk = ""
        for i_module in range(len(self.m_ordered_modules)):
            module = self.m_ordered_modules[i_module]
            # add code
            # code header
            source_header = ""
            if module.m_name == self.m_main_module_name:
                source_header += "local __IS_MAIN_MODULE__ = true\n"
            if "__MODULE_INDEX__" in module.m_source:
                source_header += "local __MODULE_INDEX__ = {0}\n".format(i_module + 1)
            if "__MODULE_NAME__" in module.m_source:
                source_header += "local __MODULE_NAME__ = {0}\n".format("\"" + module.m_name + "\"")
            # code footer
            source_footer = ""
            if self.m_reference_locals:
                source_footer_locals = ""
                had_local = False
                for line in module.m_source.split("\n"):
                    matches = re.findall(r'^local\s*(?:function)?\s*(\w*).*$', line)
                    if len(matches) == 1:
                        if not had_local:
                            had_local = True
                        source_footer_locals += localwrapper_access.m_source.replace("LOCAL_NAME", matches[0])
                if had_local:
                    source_footer += localwrapper_header.m_source.replace("__MODULE_NAME__", "\"" + module.m_name + "\"").replace("LOCAL_DEFS", source_footer_locals)
            # code
            start_line = header_chunk.count('\n') + len(self.m_ordered_modules) + postindex_chunk.count('\n') + codes_chunk.count('\n') + source_header.count('\n') + 2
            end_line = start_line + module.m_source.count('\n')
            source = module.m_source
            if len(source_footer) > 0:
                source = InsertBeforeReturn(source, source_footer)
            if not module.m_preload:
                codes_chunk += "pshy.modules[\"{0}\"].load = function()\n{1}{2}end\n".format(module.m_name, source_header, source)
            else:
                codes_chunk += "do\n{0}{1}end\n".format(source_header, module.m_source)
            if module.m_preload:
                codes_chunk += "pshy.modules[\"{0}\"].loaded = true\n".format(module.m_name)
            if module.m_name == "pshy_require" and self.m_lua_command:
                codes_chunk += "require = pshy.require\n"
            # add index
            index_chunk += "pshy.modules_list[{0}] = {{name = \"{1}\", file = \"{2}\", start_line = {3}, end_line = {4}}}\n".format(i_module + 1, module.m_name, module.m_friendly_file, start_line, end_line)
        # add sources (optional)
        for module in self.m_ordered_modules:
            if self.m_include_sources or module.m_include_source:
                sources_chunk += "pshy.modules_list.source = [=[\n{1}]=]\n".format(module.m_name, module.m_source.replace("[=[", "[=========[").replace("]=]", "]=========]"))
        # Add module sources
        footer_chunk = ""
        # Add command-line requires
        for module_name in self.m_requires:
            footer_chunk += "pshy.require(\"{0}\")\n".format(module_name)
        # Create events
        if "pshy.events" in self.m_modules:
            footer_chunk += "pshy.require(\"pshy.events\").CreateFunctions()\n"
        # Initialization done
        footer_chunk += "print(string.format(\"<v>Loaded <ch2>%d files</ch2> in <vp>%d ms</vp>.\", #pshy.modules_list, os.time() - pshy.INIT_TIME))\n"
        # Exiting main scrope
        footer_chunk += "end\n"
        # Putting all chunks together
        self.m_compiled_module.m_source = ""
        self.m_compiled_module.m_source += header_chunk
        self.m_compiled_module.m_source += index_chunk
        self.m_compiled_module.m_source += postindex_chunk
        self.m_compiled_module.m_source += codes_chunk
        self.m_compiled_module.m_source += sources_chunk
        self.m_compiled_module.m_source += footer_chunk

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
        if argv[i_arg] == "--referencelocals":
            c.m_reference_locals = True
            i_arg += 1
            continue
        if argv[i_arg] == "--addpath":
            i_arg += 1
            c.m_pathes.append(argv[i_arg])
            i_arg += 1
            continue
        if argv[i_arg] == "--adddir":
            i_arg += 1
            c.m_pathes.append(argv[i_arg] + "/?.lua")
            c.m_pathes.append(argv[i_arg] + "/?/init.lua")
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
        if argv[i_arg] == "--werror":
            c.m_werror = True
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
    sys.exit(0)

if __name__ == "__main__":
    Main(len(sys.argv), sys.argv)
