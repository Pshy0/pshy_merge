--- pshy.tools.loadxml
--
-- Adds a command to load a map from xml.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")
local ids = pshy.require("pshy.utils.ids")
local perms = pshy.require("pshy.perms")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Load XML", text = "Load a map from its xml.\n"}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Internal use.
local popup_id = ids.AllocPopupId()
local players_loading_xml = {}



function eventPopupAnswer(p_id, player_name, answer)
	if p_id == popup_id then
		if perms.HavePerm(player_name, "!loadxml") then
			if not players_loading_xml[player_name] then
				return
			end
			if answer == "" then
				players_loading_xml[player_name] = nil
				return
			end
			local error_msg = ""
			if string.sub(answer, 1, 1) == "<" and string.sub(answer, -1) == ">" then
				table.insert(players_loading_xml[player_name], answer)
			else
				error_msg = "ERROR: Chunks must start with `&lt;` and end with `&gt;`."
			end
			if string.sub(answer, -4) == "</C>" then
				tfm.exec.newGame(table.concat(players_loading_xml[player_name]))
				players_loading_xml[player_name] = nil
			else
				ui.addPopup(popup_id, 2, string.format("XML (chunk %d):%s", #players_loading_xml[player_name] + 1, error_msg), user, 0, 200, 800, true)
			end
		end
	end
end



__MODULE__.commands = {
	["loadxml"] = {
		perms = "admins",
		desc = "Load a map from xml chunks.",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			players_loading_xml[user] = {}
			ui.addPopup(popup_id, 2, "XML (chunk 1):", user, 0, 200, 800, true)
			return true, "You now need to provide xml chunks one by one."
		end
	}
}
