--- pshy.commands.modules
--
-- Basic commands to control modules.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.bases.doc")
local EnableModule = pshy.require("pshy.events.enable")
local DisableModule = pshy.require("pshy.events.disable")



--- !modules
function pshy.merge_ChatCommandModules(user, event_name)
	tfm.exec.chatMessage("<r>[Merge]</r> Modules (in load order):", user)
	for i_module, mod in pairs(pshy.modules_list) do
		if not event_name or mod.events[event_name] then
			local line
			if mod.event_count == 0 then
				line = "<g>"
			elseif mod.enabled then
				line = "<v>"
			else
				line = "<r>"
			end
			line = line .. tostring(mod.index) .. "\t" .. mod.name
			if mod.event_count > 0 then
				line = line .. " \t" .. tostring(mod.event_count) .. " events"
			end
			tfm.exec.chatMessage(line, user)
		end
	end
end
pshy.commands["modules"] = {perms = "admins", func = pshy.merge_ChatCommandModules, desc = "see a list of loaded modules having a given event", argc_min = 0, argc_max = 1, arg_types = {"string"}, arg_names = {"event_name"}}
--pshy.help_pages["pshy_merge"].commands["modules"] = pshy.commands["modules"]



--- !enablemodule
function pshy.merge_ChatCommandModuleenable(user, mname)
	tfm.exec.chatMessage("[Merge] Enabling " .. mname)
	return EnableModule(mname)
end
pshy.commands["enablemodule"] = {func = pshy.merge_ChatCommandModuleenable, desc = "enable a module (NOT SAFE)", argc_min = 1, argc_max = 1, arg_types = {"string"}}
--pshy.help_pages["pshy_merge"].commands["enablemodule"] = pshy.commands["enablemodule"]



--- !disablemodule
function pshy.merge_ChatCommandModuledisable(user, mname)
	tfm.exec.chatMessage("[Merge] Disabling " .. mname)
	return DisableModule(mname)
end
pshy.commands["disablemodule"] = {func = pshy.merge_ChatCommandModuledisable, desc = "disable a module (NOT SAFE)", argc_min = 1, argc_max = 1, arg_types = {"string"}}
--pshy.help_pages["pshy_merge"].commands["disablemodule"] = pshy.commands["disablemodule"]



--- !modulestop
local function ChatCommandModulestop(user)
	system.exit()
end 
pshy.commands["modulestop"] = {perms = "admins", func = ChatCommandModulestop, desc = "stop the module", argc_min = 0, argc_max = 0}
--pshy.help_pages["pshy_merge"].commands["modulestop"] = pshy.commands["modulestop"]



--- !pshyversion
local function ChatCommandPshyversion(user)
	return true, string.format("Pshy repository version: %s", tostring(__PSHY_VERSION__))
end
pshy.commands["pshyversion"] = {aliases = {"version"}, perms = "everyone", func = ChatCommandPshyversion, desc = "Show the last repository version.", argc_min = 0, argc_max = 0}
--pshy.help_pages["pshy_merge"].commands["pshyversion"] = pshy.commands["pshyversion"]
