--- pshy.help
--
-- Add a help commands and an in-game help interface.
--
-- @author tfm:Pshy#3752
local commands = pshy.require("pshy.commands")
local command_list = pshy.require("pshy.commands.list")
pshy.require("pshy.events")
pshy.require("pshy.ui.v1")
local perms = pshy.require("pshy.perms")
local pages = pshy.require("pshy.help.pages")
local ids = pshy.require("pshy.utils.ids")



--- Namespace.
local help = {}



--- Module Settings:
local text_id_page_list = ids.AllocTextAreaId()
local text_id_title_area = ids.AllocTextAreaId()
local text_id_main_body = ids.AllocTextAreaId()



--- Internal Use:
local help_pages_lists = {}
local pages_per_page_list = 20
local players_page_list_index = {}



--- Get a chat command desc text.
-- @param chat_command_name The name of the chat command.
function help.GetChatCommandDesc(chat_command_name)
	local cmd = command_list[chat_command_name]
	local desc = cmd.desc or "no description"
	return desc
end



--- Get a chat command help html.
-- @param chat_command_name The name of the chat command.
function help.GetChatCommandHelpHtml(command_name, is_admin)
	local real_command = commands.GetCommand(command_name)
	if not real_command then
		return "<r>This command does not exist or is unavailable.</r>"
	end
	if real_command.restricted and not is_admin then
		return "<r>You do not have permissions to view this.</r>"
	end
	local html = "<j><i><b>"
	-- usage
	local html = html .. real_command.usage or "(no usage, error)"
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
function help.GetHelpPageHtmlTitleArea(page_name, is_admin)
    local page = pages[page_name] or pages[""]
	-- title menu
	local html = "<bv><p align='right'><font size='14'><b>"
	html = html .. " <bl><a href='event:pcmd man " .. (page.back or "") .. "'> ↶ </a></bl>"
	html = html .. " <r><a href='event:pcmd closeman'> × </a></r>        "
	html = html .. "</b></font></p>"
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
function help.GetHelpPageHtml(page_name, is_admin)
	local page = pages[page_name]
	page = page or pages[""]
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
			local m1, m2 = commands.GetPermColorMarkups("!" .. cmd_name)
			--html = html .. '!' .. ex_cmd .. "\t - " .. (cmd.desc or "no description") .. '\n'
			html = html .. m1
			--html = html .. "<u><a href='event:pcmd help " .. cmd_name .. "'>" .. commands.GetUsage(cmd_name) .. "</a></u>"
			html = html .. "<u>" .. (cmd.usage or "(no usage, error)") .. "</u>"
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



local function ShowPagesList(user)
	players_page_list_index[user] = players_page_list_index[user] or 1
	local page_list_text = help_pages_lists[players_page_list_index[user]]
	ui.addTextArea(text_id_page_list, page_list_text, user, 30, 40, 150, 340, 0x010101, 0x010101, 0.95, true)
end



__MODULE__.commands = {
	["man"] = {
		aliases = {"help"},
		perms = "everyone",
		desc = "show a help panel",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"string"},
		func = function(user, page_name)
			if page_name == nil then
				page_name = ""
			end
			local page = pages[page_name]
			local title_area_text
			local main_body_text
			if page then
				if not page.restricted or perms.admins[user] then
					title_area_text = page and page.html_1 or help.GetHelpPageHtmlTitleArea(page_name, perms.admins[user])
					main_body_text = page.html_2
				else
					title_area_text = page and page.html_1 or help.GetHelpPageHtmlTitleArea(page_name, perms.admins[user])
					main_body_text = "<p align='center'><font size='16'><r>This page is restricted.</r></font></p>"
				end
			elseif string.sub(page_name, 1, 1) == '!' then
				main_body_text = help.GetChatCommandHelpHtml(string.sub(page_name, 2, #page_name), perms.admins[user])
				tfm.exec.chatMessage(main_body_text, user)
				return true
			elseif command_list[page_name] then
				main_body_text = help.GetChatCommandHelpHtml(page_name)
				tfm.exec.chatMessage(main_body_text, user)
				return true
			else
				main_body_text = help.GetHelpPageHtml(page_name, perms.admins[user])
				title_area_text = help.GetHelpPageHtmlTitleArea(page_name, perms.admins[user])
			end
			main_body_text = "<font size='10'><b><n>" .. main_body_text .. "</n></b></font>"
			if #main_body_text > 2000 then
				error("#html is too big: == " .. tostring(#main_body_text))
			end
			ui.addTextArea(text_id_title_area, title_area_text, user, 200, 40, 570, 100, 0x010101, 0x010101, 0.95, true)
			ui.addTextArea(text_id_main_body, main_body_text, user, 200, 160, 570, 220, 0x010101, 0x010101, 0.95, true)
			-- page list:
			ShowPagesList(user)
			return true
		end
	},
	["closeman"] = {
		aliases = {"closehelp"},
		perms = "everyone",
		desc = "hide the help panel",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"string"},
		func = function(user, page_name)
			ui.removeTextArea(text_id_page_list, user)
			ui.removeTextArea(text_id_title_area, user)
			ui.removeTextArea(text_id_main_body, user)
			return true
		end
	},
	["nextmanlist"] = {
		perms = "everyone",
		desc = "show the next help pages list",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"number"},
		func = function(user, list_number)
			if list_number < 0 or list_number > # help_pages_lists then
				return false, "No such pages list."
			end
			if list_number == #help_pages_lists and not perms.admins[user] then
				return false, "Next pages are room-admin-only."
			end
			players_page_list_index[user] = list_number
			ShowPagesList(user)
			return true
		end
	}
}



--- Pshy event eventInit
function eventInit()
	local html_page_list_header = "<vi><b>Help Pages:</b></vi>\n\n<ch><b><p align='center'>"
	local html_page_list_footer = "</p></b></ch>"
	local html_page_list = html_page_list_header
	local pages_in_list = 0
	for page_name, page in pairs(pages) do
		if not page.back or page.back == "" or page.back == "pshy" then
			local line =  "<u><a href='event:pcmd help " .. page_name .. "'>" .. (page.title or page_name) .. "</a></u>\n"
			if not page.restricted then
				pages_in_list = pages_in_list + 1
				html_page_list = html_page_list .. line
				if pages_in_list == pages_per_page_list then
					html_page_list = html_page_list .. html_page_list_footer
					table.insert(help_pages_lists, html_page_list)
					html_page_list = html_page_list_header
					pages_in_list = 0
				end
			end
		end
	end
	for i = pages_in_list, pages_per_page_list - 1 do
		html_page_list = html_page_list .. "\n"
	end
	html_page_list = html_page_list .. html_page_list_footer
	table.insert(help_pages_lists, html_page_list)
	-- add admin page list
	html_page_list = "<vi><b>Admin Help Pages:</b></vi>\n\n<ch><b><p align='center'>"
	pages_in_list = 0
	for page_name, page in pairs(pages) do
		if not page.back or page.back == "" or page.back == "pshy" then
			if page.restricted then
				local line =  "<u><a href='event:pcmd help " .. page_name .. "'>" .. (page.title or page_name) .. "</a></u>\n"
				html_page_list = html_page_list .. line
				pages_in_list = pages_in_list + 1
			end
		end
	end
	for i = pages_in_list, pages_per_page_list - 1 do
		html_page_list = html_page_list .. "\n"
	end
	html_page_list = html_page_list .. "</p></b></ch>"
	table.insert(help_pages_lists, html_page_list)
	-- add pages list footer
	for i_page_list, page_list_text in ipairs(help_pages_lists) do
		local footer = "<p align='center'><font size='24'>"
		if i_page_list > 1 then
			footer = footer .. string.format("<a href='event:pcmd nextmanlist %d'><n> &lt; </n></a>", i_page_list - 1)
		else
			footer = footer .. "<n2> &lt; </n2>"
		end
		if i_page_list < #help_pages_lists then
			footer = footer .. string.format("<a href='event:pcmd nextmanlist %d'><n> &gt; </n></a>", i_page_list + 1)
		else
			footer = footer .. "<n2> &gt; </n2>"
		end
		footer = footer .. "</font></p>"
		help_pages_lists[i_page_list] = page_list_text .. footer
	end
	-- precompute html help pages
	for page_name, page in pairs(pages) do
		page.html_1 = help.GetHelpPageHtmlTitleArea(page_name, true)
		page.html_2 = help.GetHelpPageHtml(page_name, true)
	end
end



return help
