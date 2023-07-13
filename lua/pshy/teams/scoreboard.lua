--- pshy.teams.scoreboard
--
-- Adds a team scoreboard.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")
local teams = pshy.require("pshy.teams")
pshy.require("pshy.utils.print")
local ids = pshy.require("pshy.utils.ids")



--- Help page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Teams Scoreboard", text = "This module adds a scoreboard displayed between rounds.\n"}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



local ns = {}



local scoreboard_enabled = false
local scoreboard_displayed = false
local displays_ui_ids = {}
local displays_ui_ids2 = {}
for i = 1,4 do
	displays_ui_ids[i] = ids.AllocTextAreaId()
	displays_ui_ids2[i] = ids.AllocTextAreaId()
end



local function GetTeamScoreboardTexts(i_team)
	local team = teams.teams[i_team]
	local text1 = "<font color='#" .. team.color .. "'><b>"
	local text2 = "<b><n><p align='right'>"
	for player_name in pairs(team.player_names) do
		if tfm.get.room.playerList[player_name] then
			local score = tfm.get.room.playerList[player_name].score
			if score > 0 then
				text1 = text1 .. player_name .. "\n"
				text2 = text2 .. tostring(score) .. "\n"
			end
		end
	end
	text1 = text1 .. "</b></font>"
	local text2 = text2 .. "</p></b><n>"
	return text1, text2
end



function ns.Show()
	local team_count = #teams.teams
	if team_count < 1 or team_count > 4 then
		return print_error("Too little or many teams!")
	end
	local x_margin = 400 - 100 * team_count
	for i = 1, team_count do
		local text1, text2 = GetTeamScoreboardTexts(i)
		ui.addTextArea(displays_ui_ids[i], text1, nil, x_margin + 10 + (i - 1) * 200, 60, 180, 300, 0x010000, tonumber(teams.teams[i].color), 0.7, true)
		ui.addTextArea(displays_ui_ids2[i], text2, nil, x_margin + 10 + (i - 1) * 200, 60, 180, 300, 0x0, tonumber(teams.teams[i].color), 0.0, true)
	end
	scoreboard_displayed = true
end



function ns.Hide()
	for i_display in ipairs(displays_ui_ids) do
		ui.removeTextArea(displays_ui_ids[i_display])
		ui.removeTextArea(displays_ui_ids2[i_display])
	end
	scoreboard_displayed = false
end



function eventPlayerScore()
	if scoreboard_enabled and not scoreboard_displayed then
		ns.Show()
	end
end



function eventNewGame()
	if scoreboard_displayed then
		ns.Hide()
	end
end



__MODULE__.commands = {
	["teamsroundscoreboard"] = {
		perms = "admins",
		desc = "Enable or disable team's scoreboard between rounds.",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"bool"},
		func = function(user, enabled)
			if not enabled then
				enabled = not scoreboard_enabled
			end
			scoreboard_enabled = enabled
			return true, string.format("%s teams scoreboard between rounds", (enabled and "Enabled" or "Disabled"))
		end
	}
}



return ns
