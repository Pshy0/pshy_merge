--- pshy.debug.watchlogs
--
-- Copy logs to chat for players enabling it.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local command_list = pshy.require("pshy.commands.list")
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")



--- Namespace.
local log_watchers = {}



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Watch Logs", restricted = true, text = "Copy logs to chat.\n", commands = {}}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



function eventInit()
	local original_print = print
	print = function(arg1, ...)
		original_print(arg1, ...)
		for player_name in pairs(log_watchers) do
			tfm.exec.chatMessage("<ch>• </ch><j># </j>" .. tostring(arg1), player_name)
		end
	end
end



--- !watchlogs <on/off> <target>
local function ChatCommandWatchLogs(user, enabled, target)
	target = target or user
	if enabled == nil then
		enabled = not log_watchers[target]
	end
	if enabled then
		log_watchers[target] = true
	else
		log_watchers[target] = nil
	end
	return true, string.format("%s is %s watching logs.", target, enabled and "now" or "no longer")
end
command_list["watchlogs"] = {perms = "admins", func = ChatCommandWatchLogs, desc = "copy logs to chat", argc_min = 0, argc_max = 2, arg_types = {"bool", "player"}}
help_pages[__MODULE_NAME__].commands["watchlogs"] = command_list["watchlogs"]
