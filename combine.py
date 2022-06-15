#!/usr/bin/python3
import sys
import re
import pathlib
import glob
import subprocess
import time



# current folder
CURRENT_DIRECTORY = str(pathlib.Path(__file__).parent.absolute())



def ReadFile(file_name):
    f = open(file_name, mode="r")
    content = f.read()
    f.close()
    return content



def WriteFile(file_name, content):
    f = open(file_name, mode="w")
    f.write(content)
    f.close()



def GetLuaModuleFileName(lua_name):
    """ Get the full file name for a Lua script name. """
    for path in glob.glob("./lua/**/" + lua_name, recursive = True):
        return path
    for path in glob.glob(CURRENT_DIRECTORY + "/lua/**/" + lua_name, recursive = True):
        return path
    raise Exception("module '" + lua_name + "' not found!")



def GetLatestGitTag():
    #git describe --tags --abbrev=0
    #git tag --sort=version:refname | grep v0 | tail -n 1
    p = subprocess.Popen(["cd " + CURRENT_DIRECTORY + " && git tag --sort=version:refname | grep v0 | tail -n 1"], stdout = subprocess.PIPE, shell = True, encoding = "utf-8")
    (output, err) = p.communicate()
    p_status = p.wait()
    if p_status != 0:
        raise Exception(err)
    return output.strip(" \t\r\n")



def GetCommitsSinceTag(tag):
    #git rev-list v0.3..HEAD --count  
    #git rev-list  `git rev-list --tags --no-walk --max-count=1`..HEAD --count
    p = subprocess.Popen(["cd " + CURRENT_DIRECTORY + " && git rev-list " + tag + "..HEAD --count"], stdout = subprocess.PIPE, shell = True, encoding = "utf-8")
    (output, err) = p.communicate()
    p_status = p.wait()
    if p_status != 0:
        raise Exception(err)
    return output.strip(" \t\r\n")



def GetVersion():
    tag = GetLatestGitTag()
    build = GetCommitsSinceTag(tag)
    if build == "0":
        return tag
    else:
        return tag + "-c" + build



class LUAModule:
    """ Represent a single Lua Script. """

    def __init__(self, name = None):
        self.m_file = None
        self.m_name = name
        self.m_code = None
        self.m_authors = []
        self.m_header = None
        self.m_requires = []
        self.m_hard_merge = False
        if name != None:
            self.Load(name)

    def Load(self, name):
        """ Load this module (read it). """
        print("-- loading " + name + "...", file=sys.stderr)
        self.m_name = name
        self.m_file = GetLuaModuleFileName(name)
        self.m_code = ReadFile(self.m_file)
        if not self.m_code.endswith("\n"):
            self.m_code += "\n"
        # look for special tags
        self.m_explicit_dependencies = []
        for whole_line in self.m_code.split("\n"):
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

    def Minimize(self, remove_comments):
        """ Reduce the script's size without changing its behavior. """
        # This is hacky but i will implement something better later.
        # Currently this will beak codes using multiline features.
        if remove_comments:
            print("-- INFO: removing comments...", file=sys.stderr)
            # remove `---[[...`
            self.m_code = re.sub(r'-+--\[\[.*$', '', self.m_code, flags=re.MULTILINE)
            # remove `--...--[[...`
            self.m_code = re.sub(r'--.*--\[\[.*$', '', self.m_code, flags=re.MULTILINE)
            # remove `--`
            self.m_code = re.sub(r'^--[^\[\r\n]*$', '', self.m_code, flags=re.MULTILINE)
            # remove `--...`
            self.m_code = re.sub(r'\t+--.*$', '', self.m_code, flags=re.MULTILINE)
            self.m_code = re.sub(r'^\s*', '', self.m_code, flags=re.MULTILINE)
        # remove blank lines        
        self.m_code = re.sub(r'^\s*$', '', self.m_code, flags=re.MULTILINE)
        self.m_code = self.m_code.replace("\n\n","\n")
        # remove trailing spaces 
        self.m_code = re.sub(r'\s*$', '', self.m_code, flags=re.MULTILINE)
        # remove useless spaces (breaks strings)
        #self.m_code = self.m_code.replace("    ","\t")
        #self.m_code = self.m_code.replace("  "," ")
        #self.m_code = self.m_code.replace("\t\t","\t")
        #self.m_code = self.m_code.replace(", ",",")
        #self.m_code = self.m_code.replace(" .. ","..")



class LUACompiler:
    """ Hold several scripts, and combine them into a single one. """

    def __init__(self):
        self.m_modules = {}
        self.m_ordered_modules = []
        self.m_compiled_module = None
        self.m_main_module = None
        self.m_minimize = False
        self.m_localpshy = False
        self.m_deps_file = None
        self.m_out_file = None

    def LoadModule(self, module_name):
        if not module_name in self.m_modules:
            module = LUAModule(module_name)
            self.m_modules[module_name] = module
            for i_require in range(0, len(module.m_requires)):
                self.LoadModule(module.m_requires[i_require])
            self.m_ordered_modules.append(module)

    def Merge(self):
        """ Merge the loaded modules. """
        self.m_compiled_module = LUAModule()
        self.m_compiled_module.m_code = ""
        # Add explicit module headers
        for i_module in range(len(self.m_ordered_modules) - 1, -1, -1):
            module = self.m_ordered_modules[i_module]
            if module.m_header != None:
                for line in module.m_header:
                    self.m_compiled_module.m_code += "--- " + line + "\n"
        # Add the pshy header
        pshy_version = GetVersion()
        if self.m_out_file:
            self.m_compiled_module.m_code += "---- " + self.m_out_file + "\n"
        else:
            self.m_compiled_module.m_code += "---- OUTPUT\n"
        self.m_compiled_module.m_code += "--- \n"
        self.m_compiled_module.m_code += "--- This lua script is a compilation of other scripts.\n"
        self.m_compiled_module.m_code += "--- It was generated by pshy's merging script.\n"
        self.m_compiled_module.m_code += "--- https://github.com/Pshy0/pshy_merge" + "\n"
        self.m_compiled_module.m_code += "--- version " + pshy_version + "\n"
        self.m_compiled_module.m_code += "-- \n"
        self.m_compiled_module.m_code += "\n"
        self.m_compiled_module.m_code += "__PSHY_VERSION__ = \"" + pshy_version + "\"\n"
        self.m_compiled_module.m_code += "__PSHY_TIME__ = \"" + str(time.time()) + "\"\n"
        self.m_compiled_module.m_code += "print(\" \")\n"
        self.m_compiled_module.m_code += "local pshy = pshy or {}\n"
        self.m_compiled_module.m_code += "_G.pshy = pshy\n"
        self.m_compiled_module.m_code += "math.randomseed(math.random() + math.random() + os.time())\n"
        was_merge_lua_loaded = False
        # Add modules
        # TODO: localize modules even when not using pshy_merge
        for module in self.m_ordered_modules:
            print("-- merging " + module.m_name + "...", file=sys.stderr)
            if was_merge_lua_loaded:
                self.m_compiled_module.m_code += "local new_mod = pshy.merge_ModuleBegin(\"" + module.m_name + "\")\n"
                self.m_compiled_module.m_code += "function new_mod.Content()\n"
                if self.m_main_module == module.m_name:
                    self.m_compiled_module.m_code += "\tlocal __IS_MAIN_MODULE__ = true\n"
            self.m_compiled_module.m_code += module.m_code
            if was_merge_lua_loaded:
                self.m_compiled_module.m_code += "end\n"
                self.m_compiled_module.m_code += "pshy.modules[\"" + module.m_name + "\"].require_result = new_mod.Content()\n"
                self.m_compiled_module.m_code += "pshy.merge_ModuleEnd()\n"
            if module.m_name == "pshy_merge.lua":
                was_merge_lua_loaded = True
        if was_merge_lua_loaded:
            self.m_compiled_module.m_code += "pshy.merge_Finish()\n"
    
    def Compile(self):
        """ Load dependencies and merge the scripts. """
        self.Merge()
        self.Minimize()

    def Minimize(self):
        """ reduce the output script's size """
        self.m_compiled_module.Minimize(self.m_minimize)

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
            WriteFile(self.m_out_file, self.m_compiled_module.m_code)
        else:
            print(self.m_compiled_module.m_code)



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
        if argv[i_arg] == "--":
            i_arg += 1
            continue
        c.LoadModule(argv[i_arg])
        c.m_main_module = argv[i_arg]
        i_arg += 1
    c.Compile()
    c.Output()

if __name__ == "__main__":
    Main(len(sys.argv), sys.argv)
