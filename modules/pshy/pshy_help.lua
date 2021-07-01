--- pshy_help.lua
--
-- Add a help commands and in-game help functionalities.
--
-- @author tfm:Pshy#3752
-- @hardmerge
-- @require pshy_commands.lua
-- @require pshy_ui.lua



--- Help pages.
-- Key is the name page.
-- Value is the help table (help page).
-- Help pages fields:
--	string:back		- upper page.
--	string:title		- title of the page.
--	string:text		- text to display at the top of the page.
--	set:commands		- set of chat command names.
--	set:examples		- map of action (string) -> command (string) (click to run).
--	set:subpages		- set of pages to be listed in that one at the bottom.
--	bool:restricted	- if true, require the permission "!help page_name"
pshy.help_pages = {}



--- Main help page (`!help`).
-- This page describe the help available.
pshy.help_pages[""] = {title = "Main Help", text = "This page list the available help pages.\n", subpages = {}}
pshy.help_pages["pshy"] = {back = "", title = "Pshy modules Help", text = "You may optionaly prefix pshy's commands by `pshy.` to avoid conflicts with other modules.\n", subpages = {}}
pshy.help_pages[""].subpages["pshy"] = pshy.help_pages["pshy"]



--- Get a chat command desc text.
-- @param chat_command_name The name of the chat command.
function pshy.GetChatCommandDesc(chat_command_name)
	local cmd = pshy.chat_commands[chat_command_name]
	local desc = cmd.desc or "no description"
	return desc
end



--- Get a chat command help html.
-- @param chat_command_name The name of the chat command.
function pshy.GetChatCommandHelpHtml(command_name)
	local real_command = pshy.GetChatCommand(command_name)
	local html = "<j><i><b>"
	-- usage
	local html = html .. pshy.GetChatCommandUsage(command_name)
	-- short description
	html = html .. "</b></i>\t - " .. (real_command.desc and tostring(real_command.desc) or "no description")
	-- help + other info
	if real_command.help then
		html = html .. "\n" .. real_command.help
	end
	if not real_command.func then
		html = html .. "\nThis command is not handled by pshy_commands."
	end
	html = html .. "</j>"
	return html
end



--- Get the html to display for a page.
function pshy.GetHelpPageHtml(page_name)
	local page = pshy.help_pages[page_name]
	page = page or pshy.help_pages[""]
	local html = ""
	-- title
	html = html .. "<p align='center'><font size='16'>" .. (page.title or page_name) .. '</font></p>\n'
	-- restricted ?
	if page.restricted and not pshy.HavePerm("!help " .. page_name) then
		html = html .. "<p align='center'><font color='#ff4444'>Access to this page is restricted.</font></p>\n"
		html = html .. "<p align='right'><font color='#4444ff'><a href='event:pcmd pshy.help " .. (page.back or "") .. "'>[ &lt; BACK ]</a></font></p>"
		return html
	end
	-- text
	html = html .. "<p align='center'>" .. (page.text or "") .. "</p>"
	-- commands
	if page.commands then
		html = html .. "<font color='#aaaaff'><p align='center'><font size='16'>Commands" .. "</font> (click for details)</p>\n"
		for cmd_name, cmd in pairs(page.commands) do
			--html = html .. '!' .. ex_cmd .. "\t - " .. (cmd.desc or "no description") .. '\n' 
			html = html .. "<font color='#" .. (pshy.perms.everyone["!" .. cmd_name] and "55ee55" or "ff5555") .. "'><u><a href='event:pcmd pshy.help " .. cmd_name .. "'>" .. pshy.GetChatCommandUsage(cmd_name) .. "</a></u></font>\t - " .. (cmd.desc or "no description") .. "\n" 
		end
		html = html .. "</font>\n"
	end
	-- examples
	if page.examples then
		html = html .. "<font color='#ffaaaa'><p align='center'><font size='16'>Examples" .. "</font> (click to run)</p>\n"
		for ex_cmd, ex_desc in pairs(page.examples) do
			--html = html .. "!" .. ex_cmd .. "\t - " .. ex_desc .. '\n' 
			html = html .. "<font color='#ffff00'><i><a href='event:cmd " .. ex_cmd .. "'>!" .. ex_cmd .. "</a></i></font>\t - " .. ex_desc .. '\n' 
		end
		html = html .. "</font>\n"
	end
	-- subpages
	if page.subpages then
		html = html .. "<font color='#ffaaff'><p align='center'><font size='16'>Subpages:" .. "</font></p>\n<p align='center'>"
		for subpage, void in pairs(page.subpages) do
			--html = html .. subpage .. '\n' 
			html = html .. "&gt; <u><a href='event:pcmd pshy.help " .. subpage .. "'>" .. subpage .. "</a></u><br>" 
		end
		html = html .. "</p></font>"
	end
	html = html .. "<p align='right'><font color='#4444ff'><a href='event:pcmd pshy.help " .. (page.back or "") .. "'>[ &lt; BACK ]</a></font></p>"
	return html
end



--- !help [command]
-- Get general help or help about a specific page/command.
function pshy.ChatCommandHelp(user, page_name)
	local html = ""
	if page_name == nil then
		html = pshy.GetHelpPageHtml()
	elseif string.sub(page_name, 1, 1) == '!' then
		html = pshy.GetChatCommandHelpHtml(string.sub(page_name, 2, #page_name))
		tfm.exec.chatMessage(html, user)
		return true
	elseif pshy.help_pages[page_name] then
		html = pshy.GetHelpPageHtml(page_name)
	elseif pshy.chat_commands[page_name] then
		html = pshy.GetChatCommandHelpHtml(page_name)
		tfm.exec.chatMessage(html, user)
		return true
	else
		html = pshy.GetHelpPageHtml(page_name)
	end
	html = html .. "<p align='right'><font color='#ff0000'><a href='event:close'>[ X CLOSE ]</a></font></p>"
	html = "<font size='12' color='#ddffdd' face='Consolas'><b>" .. html .. "</b></font>"
	local ui = pshy.UICreate(html)
	ui.x = 50
	ui.y = 40
	ui.w = 700
	--ui.h = 440
	ui.back_color = 0x003311
	ui.border_color = 0x77ff77
	ui.alpha = 0.9
	pshy.UIShow(ui, user)
	return true
end
pshy.chat_commands["help"] = {func = pshy.ChatCommandHelp, desc = "list pshy's available commands", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.perms.everyone["help"] = false

