--- pshy.commands.list.modules
--
-- Basic commands to control modules.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local help_pages = pshy.require("pshy.help.pages")
pshy.require("pshy.moduleswitch")
local events = pshy.require("pshy.events")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Modules"}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



__MODULE__.commands = {
	["modules"] = {
		perms = "admins",
		desc = "see a list of loaded modules having a given event",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"string"},
		arg_names = {"event_name"},
		func = function(user, event_name)
			tfm.exec.chatMessage("Modules (in require order):", user)
			for i_module, module in pairs(pshy.modules_list) do
				local status
				if not module.loaded then
					status = "(<vi>not loaded</vi>)"
				elseif module.event_count and module.event_count > 0 then
					if module.enabled == false then
						status = string.format("(%d <j>disabled</j> events)", module.event_count)
					elseif module.event_count and module.event_count > 0 then
						status = string.format("(%d %s<vp>enabled</vp> events, %d ons)", module.event_count, module.manually_enabled and "manu " or "auto ", module.enable_count)
					end
				elseif module.loaded then
					status = string.format("(<v>loaded</v>, %d ons)", module.enable_count or 0)
				end
				tfm.exec.chatMessage(string.format("  &gt; <n>%s %s", module.name, status), user)
			end
		end
	},
	["enablemodule"] = {
		desc = "enable a module",
		argc_min = 1,
		argc_max = 2,
		arg_types = {"string", "bool"},
		func = function(user, mname, force)
			if not pshy.modules[mname] then
				return false, "No such module."
			end
			if force then
				return pshy.EnableModule(mname)
			else
				local module = pshy.modules[mname]
				if module.manually_enabled then
					return false, "This module is already enabled."
				else
					module.manually_enabled = true
					pshy.EnableModule(mname)
				end
			end
		end
	},
	["disablemodule"] = {
		desc = "disable a module",
		argc_min = 1,
		argc_max = 2,
		arg_types = {"string", "bool"},
		func = function(user, mname, force)
			if not pshy.modules[mname] then
				return false, "No such module."
			end
			if force then
				return pshy.DisableModule(mname)
			else
				local module = pshy.modules[mname]
				if not module.manually_enabled then
					if module.enabled then
						return false, string.format("This module is to be disabled, but %d module(s) still need it.", module.enable_count)
					else
						return false, "This module is already disabled."
					end
				else
					module.manually_enabled = false
					pshy.DisableModule(mname)
				end
			end
		end
	},
	["modulestop"] = {
		perms = "admins",
		desc = "stop the module",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			print(string.format("<j>[Modules] </j>%s Stopped the module.", user))
			system.exit()
		end
	},
	["modulereload"] = {
		perms = "admins",
		desc = "reload the module (dangerous)",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"string"},
		func = function(user, mname)
			local m = pshy.modules[mname]
			if not m then
				return false, "No such module."
			end
			m.value = m.load()
			events.UpdateEventFunctions(mname)
		end
	},
	["pshyversion"] = {
		perms = "everyone",
		desc = "show pshy_merge's repository version",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			return true, string.format("Pshy repository version: <r>%s</r>", tostring(pshy.PSHY_VERSION))
		end
	},
	["version"] = {
		perms = "everyone",
		desc = "show the current script's repository version",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			return true, string.format("Script repository version: <vp>%s</vp>", tostring(pshy.MAIN_VERSION or "Not repository version available."))
		end
	},
	["bug"] = {
		perms = "everyone",
		desc = "show the link to report bugs",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			tfm.exec.chatMessage(string.format("<vi><b>Report pshy_merge bugs at <bl><u>https://github.com/Pshy0/pshy_merge/issues/new/choose</u></bl></b></vi>"), user)
			tfm.exec.chatMessage(string.format(
				"<vi>You may need the following information:</vi>\nMain module name: %s\nModule count: %s\nScript version: %s\npshy_merge version: %s",
				pshy.MAIN_MODULE_NAME,
				#pshy.modules_list,
				tostring(pshy.MAIN_VERSION or "No repository version available."),
				tostring(pshy.PSHY_VERSION)
			), user)
			return true
		end
	}
}
