#!/usr/bin/python3
import sys

import python.compiler as compiler



def Main(argc, argv):
	c = compiler.LUACompiler()
	i_arg = 1
	enabled_modules = True
	require_direct_enabling = False
	include_sources = False
	end_of_options = False
	while i_arg < argc:
		if not end_of_options:
			if argv[i_arg] == "--deps":
				i_arg += 1
				c.m_deps_file = argv[i_arg]
				i_arg += 1
				continue
			elif argv[i_arg] == "--out":
				i_arg += 1
				c.m_out_file = argv[i_arg]
				i_arg += 1
				continue
			elif argv[i_arg] == "--minify-comments":
				c.m_minifier.m_minify_comments = True
				i_arg += 1
				continue
			elif argv[i_arg] == "--minify-spaces":
				c.m_minifier.m_minify_spaces = True
				i_arg += 1
				continue
			elif argv[i_arg] == "--minify":
				c.m_minifier.m_minify_comments = True
				c.m_minifier.m_minify_spaces = True
				i_arg += 1
				continue
			elif argv[i_arg] == "--minify-unreadable":
				c.m_minifier.m_minify_comments = True
				c.m_minifier.m_minify_spaces = True
				c.m_minifier.m_minify_unreadable = True
				i_arg += 1
				continue
			elif argv[i_arg] == "--minify-locals":
				c.m_minifier.m_minify_locals = True
				i_arg += 1
				continue
			elif argv[i_arg] == "--minify-globally":
				c.m_minifier.m_minify_comments = True
				c.m_minifier.m_minify_spaces = True
				c.m_minify_globally = True
				i_arg += 1
				continue
			elif argv[i_arg] == "--minify-strings":
				c.m_minifier.m_minify_strings = True
				i_arg += 1
				continue
			elif argv[i_arg] == "--minify-strings-local-count":
				c.m_minifier.m_minify_strings = True
				i_arg += 1
				c.m_minifier.m_minify_strings_local_count = int(argv[i_arg])
				i_arg += 1
				continue
			elif argv[i_arg] == "--minify-luamin":
				c.m_minify_luamin = True
				i_arg += 1
				continue
			elif argv[i_arg] == "--include-sources":
				include_sources = True
				i_arg += 1
				continue
			elif argv[i_arg] == "--no-include-sources":
				include_sources = False
				i_arg += 1
				continue
			elif argv[i_arg] == "--referencelocals" or argv[i_arg] == "--reference-locals":
				c.m_reference_locals = True
				i_arg += 1
				continue
			elif argv[i_arg] == "--addpath" or argv[i_arg] == "--add-path":
				i_arg += 1
				if argv[i_arg].find('?') == -1:
					print("-- ERROR: A Lua path must contain at least one '?'.", file=sys.stderr)
					return
				c.m_pathes.append(argv[i_arg])
				i_arg += 1
				continue
			elif argv[i_arg] == "--adddir" or argv[i_arg] == "--add-dir":
				i_arg += 1
				c.m_pathes.append(argv[i_arg] + "/?.lua")
				c.m_pathes.append(argv[i_arg] + "/?/init.lua")
				i_arg += 1
				continue
			elif argv[i_arg] == "--luacommand" or argv[i_arg] == "--lua-command":
				c.m_lua_command = argv[i_arg]
				i_arg += 1
				continue
			elif argv[i_arg] == "--testinit" or argv[i_arg] == "--test-init":
				c.m_test_init = True
				i_arg += 1
				continue
			elif argv[i_arg] == "--werror":
				c.m_werror = True
				i_arg += 1
				continue
			elif argv[i_arg] == "--enabled-modules":
				enabled_modules = True
				i_arg += 1
				continue
			elif argv[i_arg] == "--disabled-modules":
				enabled_modules = False
				i_arg += 1
				continue
			elif argv[i_arg] == "--direct-modules":
				require_direct_enabling = True
				i_arg += 1
				continue
			elif argv[i_arg] == "--indirect-modules":
				require_direct_enabling = False
				i_arg += 1
				continue
			elif argv[i_arg] == "--clip":
				c.m_output_to_clipboard = True
				i_arg += 1
				continue
			elif argv[i_arg] == "--old-physics":
				m = c.RequireModule("pshy.patches.old_movephysicobject")
				if enabled_modules:
					c.ManuallyEnableModule("pshy.patches.old_movephysicobject")
				i_arg += 1
				continue
			elif argv[i_arg] == "--":
				end_of_options = True
				i_arg += 1
				continue
			elif argv[i_arg].startswith("-"):
				print("-- ERROR: Unrecognized option `{}`!".format(argv[i_arg]), file=sys.stderr)
				sys.exit(1)
		m = c.RequireModule(argv[i_arg])
		m.m_require_direct_enabling = require_direct_enabling
		m.m_include_source = include_sources
		c.m_main_module = argv[i_arg]
		if enabled_modules:
			c.ManuallyEnableModule(argv[i_arg])
		i_arg += 1
	c.Compile()
	c.Output()
	sys.exit(0)



if __name__ == "__main__":
	Main(len(sys.argv), sys.argv)
