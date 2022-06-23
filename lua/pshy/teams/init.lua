--- teams.teams
--
-- Implement team features.
-- For team scoring features, see `pshy_teams_racingvs`.
--
-- Adds an `eventTeamWon(team_name)` event.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.bases.doc")
pshy.require("pshy.bases.scores")
pshy.require("pshy.events")
pshy.require("pshy.rotations.newgame")
local perms = pshy.require("pshy.perms")


--- Namespace.
local teams = {}



--- Help page:
pshy.help_pages["pshy_teams"] = {back = "pshy", title = "Teams", text = "This module adds team features.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_teams"] = pshy.help_pages["pshy_teams"]



--- Module settings:
teams.target_score = -1							-- score a team must reach to win
teams.auto = true									-- automatically players in a team
teams.rejoin = true								-- players leaving a team will rejoin the same one
teams.alternate_scoreboard_ui_arbitrary_id = 768	--
teams.use_map_name = true



--- Internal Use:
teams.teams = {}								-- teams (team_name -> {name, player_names (set of player names), color (hex string), score (number)})
teams.players_team = {}				-- map of player name -> team reference in wich they are
teams.winner_index = nil				-- becomes the winning team name (indicates that the next round should be for the winner)
teams.have_played_winner_round = false	-- indicates that the round for the winner has already started



--- Pshy event eventTeamWon.
function eventTeamWon(team_name)
	-- By default this does nothing, as this module does not handle gameplay.
end



--- Get a team table by index or name.
-- @public
-- @param team_name The team index (number) or name (string).
-- @return The team's table or nil if not found.
function teams.GetTeam(team_name)
	team_name = tonumber(team_name) or team_name
	if type(team_name) == "number" then
		return teams.teams[team_name]
	else
		for team_index, team in pairs(teams.teams) do
			if team.name == team_name then
				return team
			end
		end
	end
	return nil
end



--- Get the lowest team score.
-- @return The lowest team score.
function teams.GetLowestTeamScore()
	local lowest_score = nil
	for i_team, team in ipairs(teams.teams) do
		if not lowest_score or team.score < lowest_score then
			lowest_score = team.score
		end
	end
	return lowest_score
end




--- Get a string line representing the teams scores.
function teams.GetScoreLine()
	local leading = teams.GetLeadingTeam()
	local text = "<n>"
	for i_team, team in ipairs(teams.teams) do
		if #text > 3 then
			text = text .. " - "
		end
		text = text .. ((leading and leading.name == team.name) and "<b>" or "")
		text = text .. "<font color='#" .. team.color .. "'>" 
		text = text .. team.name .. ": " .. tostring(team.score)
		text = text .. "</font>"
		text = text .. ((leading and leading.name == team.name) and "</b>" or "")
	end
	text = text .. "   <g>|</g>   D: " .. tostring(teams.target_score) .. "</n>"
	return text
end



--- Update the teams scoreboard.
-- @brief player_name optional player name who will see the changes
function teams.UpdateScoreboard(player_name)
	local text = teams.GetScoreLine()
	if pshy.TableCountKeys(teams.teams) <= 4 then
		ui.removeTextArea(teams.alternate_scoreboard_ui_arbitrary_id, nil)
		ui.setMapName(teams.GetScoreLine())
	else
		text = "<p align='left'>" .. text .. "</p>"
		ui.addTextArea(teams.alternate_scoreboard_ui_arbitrary_id, text, player_name, 0, 20, 800, 0, 0, 0, 1.0, false)
	end
end



--- Get the team {} with the highest score, or nil on draw
function teams.GetLeadingTeam()
	local winning = nil
	local draw = false
	for i_team, team in ipairs(teams.teams) do
		if winning and team.score == winning.score then
			draw = true
		elseif not winning or team.score > winning.score then 
			winning = team
			draw = false
		end
	end
	return (not draw) and winning or nil
end



--- Get one of the teams {} with the fewest players in.
-- @return A team table corresponding to one of the teams with the fewest players.
function teams.GetUndernumerousTeam()
	local undernumerous = nil
	for i_team, team in ipairs(teams.teams) do
		if not undernumerous or pshy.TableCountKeys(team.player_names) < pshy.TableCountKeys(undernumerous.player_names) then
			undernumerous = team
		end
	end
	return undernumerous
end



--- Remove players from teams
function teams.ClearPlayers()
	for i_team, team in ipairs(teams.teams) do
		team.player_names = {}
	end
	teams.players_team = {}
end



--- Remove all players from teams.
function teams.Reset(count)
	-- optional new team count
	count = count or 2
	assert(count > 0)
	assert(count <= #teams.default)
	-- clear
	teams.teams = {}
	teams.players_team = {}
	-- add default teams
	for i_team = 1, count do
		teams.AddTeam(teams.default[i_team].name, teams.default[i_team].color)
	end
	-- update scoreboard
	teams.UpdateScoreboard()
end
teams.default = {}						-- default teams
teams.default[1] = {name = "Team1", color = 0x70c0ff}
teams.default[2] = {name = "Team2", color = 0xffb070}
teams.default[3] = {name = "Team3", color = 0x70ffa0}
teams.default[4] = {name = "Team4", color = 0xff70e0}



--- Add a new active team.
-- @param team_name The team's name.
-- @param hex_color A hex string representing the team color (without # or 0x).
function teams.AddTeam(team_name, hex_color)
	local new_team = {}
	new_team.name = team_name
	new_team.color = string.format("%x", hex_color)
	new_team.score = 0
	new_team.player_names = {}
	table.insert(teams.teams, new_team)
	teams.UpdateScoreboard()
end
pshy.commands["teamadd"] = {perms = "admins", func = teams.AddTeam, desc = "add a new team", no_user = true,  argc_min = 2, argc_max = 2, arg_types = {"string", "color"}, arg_names = {"team_name", "color"}}
pshy.help_pages["pshy_teams"].commands["teamadd"] = pshy.commands["teamadd"]



--- Remove a team.
-- @param team_name The team's name.
-- @param hex_color A hex string representing the team color (without # or 0x).
function teams.RemoveTeam(team)
	local team_index
	for i_team, a_team in ipairs(teams.teams) do
		if a_team == team then
			team_index = i_team
			break
		end
	end
	-- @TODO remove players
	table.remove(teams.teams, team_index)
	teams.UpdateScoreboard()
end
pshy.commands["teamremove"] = {aliases = {"teamrm"}, perms = "admins", func = teams.RemoveTeam, desc = "remove a team", no_user = true,  argc_min = 1, argc_max = 1, arg_types = {teams.GetTeam}, arg_names = {"team"}}
pshy.help_pages["pshy_teams"].commands["teamremove"] = pshy.commands["teamremove"]



--- Reset teams scores
function teams.ResetScores()
	for i_team, team in ipairs(teams.teams) do
		team.score = 0
	end
	teams.UpdateScoreboard()
end
pshy.commands["teamsreset"] = {perms = "admins", func = teams.ResetScores, no_user = true, desc = "Reset the teams's scores.", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_teams"].commands["teamsreset"] = pshy.commands["teamsreset"]



--- Add a player to a team.
-- The player is also removed from other teams.
-- @param team_name The player's team name or index or table.
-- @param player_name The player's name.
function teams.AddPlayer(team_name, player_name)
	local team = (type(team_name) == "table") and team_name or teams.GetTeam(team_name)
	assert(team ~= nil)
	-- unjoin current team
	if teams.players_team[player_name] then
		teams.players_team[player_name].player_names[player_name] = nil
	end
	-- join new team
	team.player_names[player_name] = true
	teams.players_team[player_name] = team
	tfm.exec.setNameColor(player_name, team and tonumber(team.color, 16) or 0xff7777)
end



--- Update player's nick color.
function teams.RefreshNamesColor()
	for player_name, team in pairs(teams.players_team) do
		tfm.exec.setNameColor(player_name, tonumber(team.color, 16))
	end
end



--- Shuffle teams
-- Randomly set players in a single team.
function teams.Shuffle()
	teams.ClearPlayers()
	local unassigned_players = {}
	for player_name, player in pairs(tfm.get.room.playerList) do
		table.insert(unassigned_players, player_name)
	end
	if #teams.teams >= 1 then
		while #unassigned_players > 0 do
			for team_name, team in pairs(teams.teams) do
				if #unassigned_players > 0 then
					local player_name = table.remove(unassigned_players, math.random(1, #unassigned_players))
					teams.AddPlayer(team_name, player_name)
				end
			end
		end
	end
	teams.ResetScores()
	teams.RefreshNamesColor()
end
pshy.commands["teamsshuffle"] = {perms = "admins", func = teams.Shuffle, desc = "shuffle the players in the teams", no_user = true,  argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_teams"].commands["teamsshuffle"] = pshy.commands["teamsshuffle"]



--- pshy event eventPlayerScore
function eventPlayerScore(player_name, score)
	local team = teams.players_team[player_name]
	if team then
		team.score = team.score + score
		teams.UpdateScoreboard()
		if not teams.winner_name and team.score >= teams.target_score then
			eventTeamWon(team.name)
		end
	end
end



--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	if pshy.TableCountKeys(teams.teams) > 0 and teams.auto then
		local team = nil
		-- default team is the previous one
		if teams.rejoin then
			team = teams.players_team[player_name]
		end
		-- get either the previous team or an undernumerous one
		if not team then
			team = teams.GetUndernumerousTeam()
		end
		teams.AddPlayer(team.name, player_name)
	end
	if pshy.newgame_update_map_name_on_new_player then
		teams.UpdateScoreboard(player_name)
	end
end



--- TFM event eventPlayerLeft
-- Remove the player from the team list when he leave, but still remember his previous team.
function eventPlayerLeft(player_name)
	local team = teams.players_team[player_name]
	if team then
		team.player_names[player_name] = nil
	end
end



function eventNewGame()
	teams.RefreshNamesColor()
	teams.UpdateScoreboard(player_name)
end



--- !d <D>
function teams.ChatCommandD(user, d)
	if d < 1 then
		return false, "The minimum target score is 1."
	end
	teams.target_score = d
	teams.UpdateScoreboard(player_name)
end
pshy.commands["d"] = {perms = "admins", func = teams.ChatCommandD, desc = "set the target score", argc_min = 1, argc_max = 1, arg_types = {"number"}}
pshy.help_pages["pshy_teams"].commands["d"] = pshy.commands["d"]



--- !teamjoin <team> [player]
function teams.ChatCommandTeamsjoin(user, team, target)
	assert(type(team) == "table")
	target = pshy.commands_GetTargetOrError(user, target, "!teamjoin")
	if team.score > teams.GetLowestTeamScore() and not perms.HavePerm(user, "!teamjoin-losing") then
		return false, "You can only join the loosing team."
	end
	teams.AddPlayer(team, target)
	return true, "Changed " .. user .. "'s team."
end
pshy.commands["teamjoin"] = {perms = "everyone", func = teams.ChatCommandTeamsjoin, desc = "join a team", argc_min = 1, argc_max = 2, arg_types = {teams.GetTeam, "player"}, arg_names = {"team", "target"}}
pshy.help_pages["pshy_teams"].commands["teamjoin"] = pshy.commands["teamjoin"]
perms.perms.cheats["!teamjoin-losing"] = true



--- Rename a team.
function teams.Rename(team, new_name)
	assert(#new_name >= 1, "The team name cannot be empty.")
	assert(#new_name <= 16, "The team name's max lenght is 16.")
	team.name = new_name
	teams.UpdateScoreboard()
end
pshy.commands["teamname"] = {perms = "admins", func = teams.Rename, desc = "rename a team", no_user = true,  argc_min = 2, argc_max = 2, arg_types = {teams.GetTeam, "string"}, arg_names = {"team"}}
pshy.help_pages["pshy_teams"].commands["teamname"] = pshy.commands["teamname"]



--- Change a team's color.
function teams.SetColor(team, hexcolor)
	assert(type(hexcolor) == "number", "expected a color as a number")
	team.color = string.format("%0x", hexcolor)
	teams.UpdateScoreboard()
end
pshy.commands["teamcolor"] = {perms = "admins", func = teams.SetColor, desc = "change a team's color", no_user = true,  argc_min = 2, argc_max = 2, arg_types = {teams.GetTeam, "color"}, arg_names = {"team"}}
pshy.help_pages["pshy_teams"].commands["teamcolor"] = pshy.commands["teamcolor"]



--- Change a team's score.
function teams.SetScore(team, score)
	team.score = score
	teams.UpdateScoreboard()
end
pshy.commands["teamscore"] = {perms = "admins", func = teams.SetScore, desc = "set a team's score", no_user = true,  argc_min = 2, argc_max = 2, arg_types = {teams.GetTeam, "number"}, arg_names = {"team", "score"}}
pshy.help_pages["pshy_teams"].commands["teamscore"] = pshy.commands["teamscore"]



--- !aj <on|off>
local function ChatCommandAutojoin(user, enabled)
	if not enabled then
		aj = not teams.auto
	end
	teams.auto = enabled
	return true, string.format("%s teams auto-join", (enabled and "Enabled" or "Disabled"))
end
pshy.commands["teamsautojoin"] = {aliases = {"teamsaj", "aj"}, perms = "admins", func = ChatCommandAutojoin, desc = "Enable or disable team's autojoin.", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_teams"].commands["teamsautojoin"] = pshy.commands["teamsautojoin"]



return teams
