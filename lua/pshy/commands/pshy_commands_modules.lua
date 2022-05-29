--- pshy_commands_modules.lua
--
-- Basic commands to control modules.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_commands.lua
-- @require pshy_merge.lua
--
-- @require_priority UTILS



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
pshy.commands["modules"] = {func = pshy.merge_ChatCommandModules, desc = "see a list of loaded modules having a given event", argc_min = 0, argc_max = 1, arg_types = {"string"}, arg_names = {"event_name"}}
pshy.help_pages["pshy_merge"].commands["modules"] = pshy.commands["modules"]
pshy.perms.admins["!modules"] = true



--- !enablemodule
function pshy.merge_ChatCommandModuleenable(user, mname)
	tfm.exec.chatMessage("[Merge] Enabling " .. mname)
	return pshy.merge_EnableModule(mname)
end
pshy.commands["enablemodule"] = {func = pshy.merge_ChatCommandModuleenable, desc = "enable a module (NOT SAFE)", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_merge"].commands["enablemodule"] = pshy.commands["enablemodule"]



--- !disablemodule
function pshy.merge_ChatCommandModuledisable(user, mname)
	tfm.exec.chatMessage("[Merge] Disabling " .. mname)
	return pshy.merge_DisableModule(mname)
end
pshy.commands["disablemodule"] = {func = pshy.merge_ChatCommandModuledisable, desc = "disable a module (NOT SAFE)", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_merge"].commands["disablemodule"] = pshy.commands["disablemodule"]



--- !exit
local function ChatCommandExit(user)
	system.exit()
end 
pshy.commands["exit"] = {func = ChatCommandExit, desc = "stop the module", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_merge"].commands["exit"] = pshy.commands["exit"]
pshy.perms.admins["!exit"] = true



--- !pshyversion
local function ChatCommandPshyversion(user)
	return true, string.format("Pshy repository version: %s", tostring(__PSHY_VERSION__))
end
pshy.commands["pshyversion"] = {func = ChatCommandPshyversion, desc = "Show the last repository version.", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_merge"].commands["pshyversion"] = pshy.commands["pshyversion"]
pshy.commands_aliases["version"] = "pshyversion"
pshy.perms.everyone["!pshyversion"] = true
