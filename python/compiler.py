#!/usr/bin/python3
import os
import pathlib
import re
import subprocess
import sys
import time

from . import utils as utils
from . import minifier as minifier



# current folder
PSHY_MERGE_DIRECTORY = str(pathlib.Path(__file__).parent.absolute())
assert(PSHY_MERGE_DIRECTORY).endswith("/python")
PSHY_MERGE_DIRECTORY = PSHY_MERGE_DIRECTORY[:-7]
WORKING_DIRECTORY = os.getcwd()



# TFM Script size limit (3 bytes, but limited by connection)
MAX_TFM_SCRIPT_SIZE = 256 * 256 * 256 / 10



# TFM Script size limit (3 bytes, but limited by connection)
MAX_TFM_SCRIPT_SIZE = 256 * 256 * 256 / 10



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
        self.m_preload = False
        self.m_include_source = False
        self.m_manually_enabled = False
        self.m_require_direct_enabling = False
        self.m_wrong_header_module_name = False
        if file != None:
            self.Load(file, vanilla_require)

    def Load(self, file, vanilla_require):
        """ Load this module (read it). """
        print("-- loading {0} from {1}...".format(self.m_name, self.m_file), file=sys.stderr)
        self.m_source = utils.ReadFile(self.m_file).replace("\r\n", "\n")
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
            elif line.startswith("-- @header "):
                if self.m_header == None:
                    self.m_header = []
                self.m_header.append(line.split(" ", 2)[2])
            elif line.startswith("-- @namespace "):
                pass
            elif line.startswith("-- @note "):
                pass
            elif line.startswith("-- @param "):
                pass
            elif line == "-- @preload":
                self.m_preload = True
            elif line == "-- @private":
                pass
            elif line == "-- @public":
                pass
            elif line.startswith("-- @return "):
                pass
            elif line.startswith("-- @source "):
                pass
            elif line.startswith("-- @TODO") or line.startswith("-- @TODO:") or line.startswith("-- @todo "):
                pass
            elif line.startswith("-- @version "):
                pass
            elif line.startswith("-- @"):
                print("-- WARNING: " + self.m_name + " uses unknown " + line, file=sys.stderr)
        # Add files using the experimental syntax
        self.m_requires.extend(utils.ListRequires(self.m_source, vanilla_require))
        # Check header module name
        first_lines = self.m_source.split("\n", 3)
        if len(first_lines) > 2 and first_lines[0].startswith("--- ") and first_lines[1] == "--":
            if first_lines[0] != "--- " + self.m_name:
                print("-- WARNING: " + self.m_file + " has wrong module name in its header!", file=sys.stderr)
                self.m_wrong_header_module_name = True
        else:
            self.m_wrong_header_module_name = True

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



class LUACompiler:
    """ Hold several scripts, and combine them into a single one. """

    def __init__(self):
        self.m_lua_command = None
        path_roots = ["./lua", PSHY_MERGE_DIRECTORY + "/lua", PSHY_MERGE_DIRECTORY + "/lua/pshy_private"]
        self.m_pathes = []
        for path in path_roots:
            self.m_pathes.append(path + "/?.lua")
            self.m_pathes.append(path + "/?/init.lua")
        self.m_requires = []               # Module names explicitely required on the command-line.
        self.m_modules = {}                # Map of modules.
        self.m_ordered_modules = []        # List of modules in loaded order.
        self.m_compiled_module = None
        self.m_main_module = None
        self.m_localpshy = False
        self.m_deps_file = None
        self.m_out_file = None
        self.m_reference_locals = False
        self.m_test_init = False
        self.m_werror = False
        self.m_minifier = minifier.LUAMinifier()
        self.m_minify_globally = False
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
        test_source = "do _ENV.pshy = {{require = require}}  package.path = package.path .. \";./lua/?.lua;./lua/?/init.lua;{0}/lua/?.lua;{0}/lua/?/init.lua\"  _ENV = require(\"pshy.compiler.tfmenv\").env {1} end".format(PSHY_MERGE_DIRECTORY, source)
        utils.WriteFile(".pshy_merge_test.tmp.lua", test_source)
        p = subprocess.Popen(["cat .pshy_merge_test.tmp.lua | " + (self.m_lua_command or "lua5.2")], stdout = subprocess.PIPE, stderr = subprocess.PIPE, shell = True, encoding = "utf-8")
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

    def ManuallyEnableModule(self, module_name):
        module = self.m_modules[module_name]
        module.m_manually_enabled = True

    def GetMergedHeaderChunk(self):
        """ Generate the first chunk of the compiled file, with header comments, basic compiler variables definitions, and early initialization. """
        header_chunk = ""
        # Add explicit module headers
        for i_module in range(len(self.m_ordered_modules) - 1, -1, -1):
            module = self.m_ordered_modules[i_module]
            if module.m_header != None:
                for line in module.m_header:
                    header_chunk += "--- " + line + "\n"
        pshy_version = utils.GetVersion(PSHY_MERGE_DIRECTORY)
        main_version = None
        if PSHY_MERGE_DIRECTORY != WORKING_DIRECTORY:
            main_version = utils.GetVersion(WORKING_DIRECTORY)
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
        # Double Paste Guard
        header_chunk += "if __PSHY_PASTED__ then error(\"<b><r>\\nYOU PASTED THE SCRIPT TWICE!!!</r></b>\") end\n"
        # Entering main scrope
        header_chunk += "do\n"
        header_chunk += "local pshy = {}\n"
        header_chunk += "pshy.PSHY_VERSION = \"{0}\"\n".format(pshy_version)
        if main_version:
            header_chunk += "pshy.MAIN_VERSION = \"{0}\"\n".format(main_version)
        header_chunk += "pshy.BUILD_TIME = \"{0}\"\n".format(str(time.time()))
        header_chunk += "pshy.INIT_TIME = os.time()\n"
        header_chunk += "math.randomseed(os.time())\n"
        header_chunk += "if not _ENV then _ENV = _G end\n"
        header_chunk += "_ENV.pshy = pshy\n"
        header_chunk += "print(\" \")\n"
        return header_chunk

    def GetMergedPostIndexChunk(self):
        """ Generate the chunk that postprocess the module table. """
        postindex_chunk = ""
        postindex_chunk += "pshy.modules = pshy.modules or {}\n"
        postindex_chunk += "for i_module, module in ipairs(pshy.modules_list) do\n"
        postindex_chunk += "	pshy.modules[module.name] = module\n"
        postindex_chunk += "	module.required_modules = {}\n"
        postindex_chunk += "end\n"
        return postindex_chunk

    def GetMergedSourcesChunk(self):
        """ Generate the chunk that adds module sources to module tables. """
        sources_chunk = ""
        for i_module in range(len(self.m_ordered_modules)):
            module = self.m_ordered_modules[i_module]
            if module.m_include_source:
                sources_chunk += "pshy.modules_list[{0}].source = [=[\n{1}]=]\n".format(i_module, module.m_source.replace("[=[", "[=========[").replace("]=]", "]=========]"))
        return sources_chunk

    def GetMergedFooterChunk(self):
        """ Generates the last chunk of the compiled file, finalizing the module initialization. """
        footer_chunk = ""
        # Add command-line requires
        for module_name in self.m_requires:
            footer_chunk += "pshy.require(\"{0}\")\n".format(module_name)
        # Create events
        if "pshy.events" in self.m_modules:
            footer_chunk += "pshy.require(\"pshy.events\").CreateFunctions()\n"
        # Enable Modules
        if "pshy.moduleswitch" in self.m_modules:
            for module_name in self.m_requires:
                if self.m_modules[module_name].m_manually_enabled:
                    footer_chunk += "pshy.EnableModule(\"{0}\")\n".format(module_name)
        # Initialization done
        footer_chunk += "print(string.format(\"<v>Loaded <ch2>%d files</ch2> in <vp>%d ms</vp>.\", #pshy.modules_list, os.time() - pshy.INIT_TIME))\n"
        # Exiting main scrope
        footer_chunk += "end\n"
        # Double Paste Guard
        footer_chunk += "local __PSHY_PASTED__ = true\n"
        return footer_chunk
    
    def AddLocalReferences(self):
        reference_locals = self.m_reference_locals or "pshy.debug.glocals" in self.m_modules
        if not reference_locals:
            return
        localwrapper_header = None
        localwrapper_access = None
        localwrapper_header = LUAModule(self.FindModuleFile("pshy.compiler.localwrapper.header"), "pshy.compiler.localwrapper.header")
        localwrapper_header.RemoveComments()
        localwrapper_access = LUAModule(self.FindModuleFile("pshy.compiler.localwrapper.access"), "pshy.compiler.localwrapper.access")
        localwrapper_access.RemoveComments()
        for i_module in range(len(self.m_ordered_modules)):
            module = self.m_ordered_modules[i_module]
            source_footer = ""
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
            if len(source_footer) > 0:
                module.m_source = utils.InsertBeforeReturn(module.m_source, source_footer)
                if not module.m_source.endswith("\n"):
                    module.m_source += "\n"

    def Merge(self):
        """ Merge the loaded modules. """
        # Options
        reference_locals = self.m_reference_locals or "pshy.debug.glocals" in self.m_modules
        # Chunks Declaration
        header_chunk = self.GetMergedHeaderChunk()			# Contains header comments, define basic environment and compiler generated variables, and other early initialization code
        index_chunk = ""									# Declare a module table with basic information.
        postindex_chunk = self.GetMergedPostIndexChunk()	# Code to postprocess the module table.
        codes_chunk = ""									# Adds module loading functions to module tables.
        sources_chunk = self.GetMergedSourcesChunk()		# If sources are to be included in the module table, this chunk does it.
        footer_chunk = self.GetMergedFooterChunk()			# Finilize initializasion.
        # Compiled module
        self.m_compiled_module = LUAModule()
        # Add the pshy header
        # Add a module map
        # Modules
        index_chunk = "pshy.modules_list = {\n"
        codes_chunk = ""
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
            if "__MODULE__" in module.m_source:
                source_header += "local __MODULE__ = pshy.modules[{0}]\n".format("\"" + module.m_name + "\"")
            # code
            start_line = header_chunk.count('\n') + len(self.m_ordered_modules) + postindex_chunk.count('\n') + codes_chunk.count('\n') + source_header.count('\n') + 4
            end_line = start_line + module.m_source.count('\n')
            source = module.m_source
            if not module.m_preload:
                codes_chunk += "pshy.modules[\"{0}\"].load = function()\n{1}{2}end\n".format(module.m_name, source_header, source)
            else:
                codes_chunk += "do\n{0}{1}end\n".format(source_header, module.m_source)
            if module.m_preload:
                codes_chunk += "pshy.modules[\"{0}\"].loaded = true\n".format(module.m_name)
            if module.m_name == "pshy_require" and self.m_lua_command:
                codes_chunk += "require = pshy.require\n"
            # add index
            additional_values_string = ""
            if module.m_manually_enabled:
                additional_values_string += ", manually_enabled = true"
            if module.m_require_direct_enabling:
                additional_values_string += ", require_direct_enabling = true"
            index_chunk += "[{0}] = {{name = \"{1}\", file = \"{2}\", start_line = {3}, end_line = {4}{5}}},\n".format(i_module + 1, module.m_name, module.m_friendly_file, start_line, end_line, additional_values_string)
        index_chunk += "}\n"
        # add sources (optional)
        # Putting all chunks together
        self.m_compiled_module.m_source = ""
        self.m_compiled_module.m_source += header_chunk
        self.m_compiled_module.m_source += index_chunk
        self.m_compiled_module.m_source += postindex_chunk
        self.m_compiled_module.m_source += codes_chunk
        self.m_compiled_module.m_source += sources_chunk
        self.m_compiled_module.m_source += footer_chunk

    def Compile(self):
        reference_locals = self.m_reference_locals or "pshy.debug.glocals" in self.m_modules
        """ Load dependencies and merge the scripts. """
        if reference_locals:
            self.AddLocalReferences()
        if self.m_lua_command:
            self.m_pathes.extend(self.GetDefaultLuaPathes())
        if not self.m_minify_globally:
            self.Minify()
        self.Merge()
        if self.m_minify_globally:
            self.Minify()
        if self.m_test_init:
            self.TestInit()
        output_len = len(self.m_compiled_module.m_source)
        percent_max_size = output_len / MAX_TFM_SCRIPT_SIZE * 100
        print("-- Generated {0} bytes ({1:.2f}% of max)...".format(output_len, percent_max_size), file=sys.stderr)

    def Minify(self):
        """ Minify loaded scripts. """
        if self.m_minify_globally:
            try:
                self.m_minifier.LoadModule(self.m_compiled_module.m_source)
                self.m_minifier.Minify()
                self.m_compiled_module.m_source = self.m_minifier.GetSource()
            except Exception as ex:
                print("-- ERROR: Cannot minify output: {0}".format(str(ex)), file=sys.stderr)
        else:
            for module in self.m_ordered_modules:
                if not module.m_include_source:
                    #try:
                        self.m_minifier.LoadModule(module.m_source)
                        self.m_minifier.Minify()
                        module.m_source = self.m_minifier.GetSource()
                    #except Exception as ex:
                    #    print("-- ERROR: Cannot minify {0}: {1}".format(module.m_name, str(ex)), file=sys.stderr)

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
            utils.WriteFile(self.m_deps_file, deps_str)

    def OutputResult(self):
        if self.m_out_file != None:
            utils.WriteFile(self.m_out_file, self.m_compiled_module.m_source)
        else:
            print(self.m_compiled_module.m_source)
