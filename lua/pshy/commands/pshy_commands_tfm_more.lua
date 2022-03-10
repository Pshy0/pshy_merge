--- pshy_commands_tfm_more.lua
--
-- Adds commands to call basic tfm functions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_perms.lua
--
-- @require_priority UTILS



--- Module Help Page:
pshy.help_pages["pshy_commands_tfm_more"] = {back = "pshy", title = "TFM more commands", text = "More commands calling functions from the TFM api.", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_commands_tfm"] = pshy.help_pages["pshy_commands_tfm"]



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.commands_GetTargetOrError



--- !mapflipmode
local function ChatCommandMapflipmode(user, mapflipmode)
	tfm.exec.setAutoMapFlipMode(mapflipmode)
end
pshy.commands["mapflipmode"] = {func = ChatCommandMapflipmode, desc = "Set TFM to use mirrored maps (yes/no or no param for default)", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm_more"].commands["mapflipmode"] = pshy.commands["mapflipmode"]
pshy.perms.admins["!mapflipmode"] = true



--- !shamanskills
local function ChatCommandShamanskills(user, shamanskills)
	if shamanskills == nil then
		shamanskills = true
	end
	tfm.exec.disableAllShamanSkills(not shamanskills)
end
pshy.commands["shamanskills"] = {func = ChatCommandShamanskills, desc = "enable (or disable) TFM shaman's skills", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm_more"].commands["shamanskills"] = pshy.commands["shamanskills"]
pshy.perms.admins["!shamanskills"] = true



--- !autoscore
local function ChatCommandAutoscore(user, autoscore)
	if autoscore == nil then
		autoscore = true
	end
	tfm.exec.disableAutoScore(not autoscore)
end
pshy.commands["autoscore"] = {func = ChatCommandAutoscore, desc = "enable (or disable) TFM score handling", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm_more"].commands["autoscore"] = pshy.commands["autoscore"]
pshy.perms.admins["!autoscore"] = true



--- !prespawnpreview
local function ChatCommandPrespawnpreview(user, prespawnpreview)
	tfm.exec.disablePrespawnPreview(not prespawnpreview)
end
pshy.commands["prespawnpreview"] = {func = ChatCommandPrespawnpreview, desc = "show (or hide) what the shaman is spawning", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_commands_tfm_more"].commands["prespawnpreview"] = pshy.commands["prespawnpreview"]
pshy.perms.admins["!prespawnpreview"] = true



--- !backgroundcolor
local function ChatCommandBackgroundcolor(user, color)
	assert(type(color) == "number")
	ui.setBackgroundColor(string.format("#%06x", color))
end
pshy.commands["backgroundcolor"] = {func = ChatCommandBackgroundcolor, desc = "set background color", argc_min = 1, argc_max = 1, arg_types = {"color"}, arg_names = {"background_color"}}
pshy.help_pages["pshy_commands_tfm_more"].commands["backgroundcolor"] = pshy.commands["backgroundcolor"]
pshy.perms.admins["!backgroundcolor"] = true
