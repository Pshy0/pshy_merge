--- pshy_help.lua
--
-- Add a help commands and in-game help functionalities.
--
-- @author tfm:Pshy#3752
--
-- @require pshy_commands.lua
-- @require pshy_merge.lua
-- @require pshy_perms.lua
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
pshy.help_pages = pshy.help_pages or {}



--- Main help page (`!help`).
-- This page describe the help available.
pshy.help_pages[""] = {title = "Main Help", text = "Use '<j>*</j>' to run a command on all players.\nPrefix commands with `<j>pshy.</j>` or <j>`other.`</j> in case of conflict.\n", subpages = {}}
pshy.help_pages["pshy"] = {back = "", title = "Pshy", text = "Pshy version '<ch2>" .. tostring(__PSHY_VERSION__) .. "</ch2>'.\n", subpages = {}}
pshy.help_pages[""].subpages["pshy"] = pshy.help_pages["pshy"]



--- Module Settings:
local arbitrary_text_id_page_list = 315
local arbitrary_text_id_title_area = 316
local arbitrary_text_id_main_body = 317



--- Internal Use:
local html_page_list = ""
local html_page_list_admins = ""



--- Get a chat command desc text.
-- @param chat_command_name The name of the chat command.
function pshy.GetChatCommandDesc(chat_command_name)
	local cmd = pshy.commands[chat_command_name]
	local desc = cmd.desc or "no description"
	return desc
end



--- Get a chat command help html.
-- @param chat_command_name The name of the chat command.
function pshy.GetChatCommandHelpHtml(command_name)
	local real_command = pshy.GetChatCommand(command_name)
	local html = "<j><i><b>"
	-- usage
	local html = html .. pshy.commands_GetUsage(command_name)
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



--- Get the html to display in the title area.
function pshy.GetHelpPageHtmlTitleArea(page_name, is_admin)
    local page = pshy.help_pages[page_name] or pshy.help_pages[""]
	-- title menu
	local html = "<bv><p align='right'>"
	html = html .. " <bl><a href='event:pcmd man " .. (page.back or "") .. "'>[ ↶ ]</a></bl>"
	html = html .. " <r><a href='event:pcmd closeman'>[ × ]</a></r>"
	html = html .. "</p>"
	-- title
	html = html .. "<p align='center'><font size='16'>" .. (page.title or page_name) .. '</font></p>\n'
	-- text
	if not page.restricted or is_admin then
		html = html .. "<p align='center'>" .. (page.text or "") .. "</p>"
	end
	html = html .. "</bv>"
	return html
end



--- Get the html to display for a page.
function pshy.GetHelpPageHtml(page_name, is_admin)
	local page = pshy.help_pages[page_name]
	page = page or pshy.help_pages[""]
	local html = ""
	-- title menu
	local html = ""
	-- restricted ?
	if page.restricted and not is_admin then
		html = html .. "<p align='center'><r>Access to this page is restricted.</r></p>\n"
		return html
	end
	-- details
	if page.details then
		html = html .. "<p align='center'><vp>" .. page.details .. "</vp></p>"
	end
	-- commands
	if page.commands then
		html = html .. "<bv><p align='center'><font size='16'>Commands" .. "</font></p>\n"
		for cmd_name, cmd in pairs(page.commands) do
			local m1, m2 = pshy.commands_GetPermColorMarkups("!" .. cmd_name)
			--html = html .. '!' .. ex_cmd .. "\t - " .. (cmd.desc or "no description") .. '\n'
			html = html .. m1
			--html = html .. "<u><a href='event:pcmd help " .. cmd_name .. "'>" .. pshy.commands_GetUsage(cmd_name) .. "</a></u>"
			html = html .. "<u>" .. pshy.commands_GetUsage(cmd_name) .. "</u>"
			html = html .. m2
			html = html .. "\t - " .. (cmd.desc or "no description") .. "\n"
		end
		html = html .. "</bv>\n"
	end
	-- examples
	if page.examples then
		html = html .. "<rose><p align='center'><font size='16'>Examples" .. "</font> (click to run)</p>\n"
		for ex_cmd, ex_desc in pairs(page.examples) do
			--html = html .. "!" .. ex_cmd .. "\t - " .. ex_desc .. '\n' 
			html = html .. "<j><i><a href='event:cmd " .. ex_cmd .. "'>!" .. ex_cmd .. "</a></i></j>\t - " .. ex_desc .. '\n' 
		end
		html = html .. "</rose>\n"
	end
	-- subpages
	if page.subpages then
		html = html .. "<ch><p align='center'><font size='16'>Subpages:" .. "</font></p>\n<p align='center'><u>"
		for subpage_name, subpage in pairs(page.subpages) do
			if not subpage.restricted or is_admin then
				--html = html .. subpage .. '\n'
				if subpage and subpage.title then
					html = html .. "<a href='event:pcmd man " .. subpage_name .. "'>" .. subpage.title .. "</a>\n"
				else
					html = html .. "<a href='event:pcmd man " .. subpage_name .. "'>" .. subpage_name .. "</a>\n" 
				end
			end
		end
		html = html .. "</u></p></ch>"
	end
	return html
end



--- !help [command]
-- Get general help or help about a specific page/command.
local function ChatCommandMan(user, page_name)
	if page_name == nil then
		html = pshy.GetHelpPageHtml(nil)
	elseif string.sub(page_name, 1, 1) == '!' then
		html = pshy.GetChatCommandHelpHtml(string.sub(page_name, 2, #page_name))
		tfm.exec.chatMessage(html, user)
		return true
	elseif pshy.help_pages[page_name] then
		html = pshy.GetHelpPageHtml(page_name, pshy.admins[user])
	elseif pshy.commands[page_name] then
		html = pshy.GetChatCommandHelpHtml(page_name)
		tfm.exec.chatMessage(html, user)
		return true
	else
		html = pshy.GetHelpPageHtml(page_name)
	end
	html = "<font size='10'><b><n>" .. html .. "</n></b></font>"
	if #html > 2000 then
		error("#html is too big: == " .. tostring(#html))
	end

	
	local page_list_text = pshy.admins[user] and html_page_list_admins or html_page_list
	ui.addTextArea(arbitrary_text_id_page_list, page_list_text, user, 30, 40, 150, 340, 0x010101, 0xffffff, 0.95, true)
	local title_area_text = pshy.GetHelpPageHtmlTitleArea(page_name, pshy.admins[user])
	ui.addTextArea(arbitrary_text_id_title_area, title_area_text, user, 200, 40, 570, 100, 0x010101, 0xffffff, 0.95, true)
	local main_body_text = html
	ui.addTextArea(arbitrary_text_id_main_body, main_body_text, user, 200, 160, 570, 220, 0x010101, 0xffffff, 0.95, true)
	return true
end
pshy.commands["man"] = {func = ChatCommandMan, desc = "show a help panel", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.perms.everyone["!man"] = true
pshy.commands_aliases["help"] = "man"



--- !closehelp
local function ChatCommandCloseman(user, page_name)
	ui.removeTextArea(arbitrary_text_id_page_list, user)
	ui.removeTextArea(arbitrary_text_id_title_area, user)
	ui.removeTextArea(arbitrary_text_id_main_body, user)
end
pshy.commands["closeman"] = {func = ChatCommandCloseman, desc = "hide the help panel", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.perms.everyone["!closeman"] = true
pshy.commands_aliases["closehelp"] = "closeman"



--- Pshy event eventInit
function eventInit()
	-- other page
	--pshy.help_pages["other"] = {title = "Other Pages", subpages = {}}
	--for page_name, help_page in pairs(pshy.help_pages) do
	--	if not help_page.back then
	--		pshy.help_pages["other"].subpages[page_name] = help_page
	--	end
	--end
	--pshy.help_pages["pshy"].subpages["other"] = pshy.help_pages["other"]
	-- all page
	--pshy.help_pages["all"] = {title = "All Pages", subpages = {}}
	--for page_name, help_page in pairs(pshy.help_pages) do
	--	pshy.help_pages["all"].subpages[page_name] = help_page
	--end
	--pshy.help_pages["pshy"].subpages["all"] = pshy.help_pages["all"]
	-- html page lists
	html_page_list = "<ch><b><p align='center'>"
	html_page_list_admins = "<ch><b><p align='center'>"
	for page_name, page in pairs(pshy.help_pages) do
		if not page.back or page.back == "" or page.back == "pshy" then
			local line =  "<u><a href='event:pcmd help " .. page_name .. "'>" .. (page.title or page_name) .. "</a></u>\n"
			if not page.restricted then
				html_page_list = html_page_list .. line
				html_page_list_admins = html_page_list_admins .. line
			else
				html_page_list_admins = html_page_list_admins .. "<r>" .. line .. "</r>"
			end
		end
	end
	html_page_list = html_page_list .. "</p></b></ch>"
	html_page_list_admins = html_page_list_admins .. "</p></b></ch>"
end
