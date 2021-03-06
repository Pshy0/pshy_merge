--- pshy.commands.list.modules
--
-- Basic commands to control modules.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local command_list = pshy.require("pshy.commands.list")
local help_pages = pshy.require("pshy.help.pages")
local EnableModule = pshy.require("pshy.events.enable")
local DisableModule = pshy.require("pshy.events.disable")



--- Module Help Page:
help_pages["pshy_commands_modules"] = {back = "pshy", title = "Modules", commands = {}}
help_pages["pshy"].subpages["pshy_commands_modules"] = help_pages["pshy_commands_modules"]



--- !modules
function pshy.merge_ChatCommandModules(user, event_name)
	tfm.exec.chatMessage("Modules (in require order):", user)
	for i_module, module in pairs(pshy.modules_list) do
		local status
		if not module.loaded then
			status = "(<vi>not loaded</vi>)"
		elseif module.event_count and module.event_count > 0 then
			if module.enabled == false then
				status = string.format("(%d <j>disabled</j> events)", module.event_count)
			elseif module.event_count and module.event_count > 0 then
				status = string.format("(%d <vp>enabled</vp> events)", module.event_count)
			end
		elseif module.loaded then
			status = "(<v>loaded</v>)"
		end
		tfm.exec.chatMessage(string.format("  &gt; <n>%s %s", module.name, status), user)
	end
end
command_list["modules"] = {perms = "admins", func = pshy.merge_ChatCommandModules, desc = "see a list of loaded modules having a given event", argc_min = 0, argc_max = 1, arg_types = {"string"}, arg_names = {"event_name"}}
help_pages["pshy_commands_modules"].commands["modules"] = command_list["modules"]



--- !enablemodule
function pshy.merge_ChatCommandModuleenable(user, mname)
	return EnableModule(mname)
end
command_list["enablemodule"] = {func = pshy.merge_ChatCommandModuleenable, desc = "enable a module (NOT SAFE)", argc_min = 1, argc_max = 1, arg_types = {"string"}}
help_pages["pshy_commands_modules"].commands["enablemodule"] = command_list["enablemodule"]



--- !disablemodule
function pshy.merge_ChatCommandModuledisable(user, mname)
	return DisableModule(mname)
end
command_list["disablemodule"] = {func = pshy.merge_ChatCommandModuledisable, desc = "disable a module (NOT SAFE)", argc_min = 1, argc_max = 1, arg_types = {"string"}}
help_pages["pshy_commands_modules"].commands["disablemodule"] = command_list["disablemodule"]



--- !modulestop
local function ChatCommandModulestop(user)
	print("<j>[Modules] </j>Stopping...")
	tfm.exec.chatMessage("<j>[Modules] </j>Stopping...", user)
	system.exit()
end 
command_list["modulestop"] = {perms = "admins", func = ChatCommandModulestop, desc = "stop the module", argc_min = 0, argc_max = 0}
help_pages["pshy_commands_modules"].commands["modulestop"] = command_list["modulestop"]



--- !pshyversion
local function ChatCommandPshyversion(user)
	return true, string.format("Pshy repository version: <r>%s</r>", tostring(pshy.PSHY_VERSION))
end
command_list["pshyversion"] = {perms = "everyone", func = ChatCommandPshyversion, desc = "show pshy_merge's repository version", argc_min = 0, argc_max = 0}
help_pages["pshy_commands_modules"].commands["pshyversion"] = command_list["pshyversion"]



--- !version
local function ChatCommandScriptversion(user)
	return true, string.format("Script repository version: <vp>%s</vp>", tostring(pshy.MAIN_VERSION or "Not repository version available."))
end
command_list["version"] = {perms = "everyone", func = ChatCommandScriptversion, desc = "show the current script's repository version", argc_min = 0, argc_max = 0}
help_pages["pshy_commands_modules"].commands["pshyversion"] = command_list["pshyversion"]
