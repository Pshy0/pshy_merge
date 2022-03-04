--- pshy_teams.lua
--
-- Implement team features.
-- For team scoring features, see `pshy_teams_racingvs`.
--
-- Adds an `eventTeamWon(team_name)` event.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_help.lua
-- @require pshy_scores.lua
-- @require pshy_mapdb.lua
-- @require pshy_newgame.lua



--- Help page:
pshy.help_pages["pshy_teams"] = {back = "pshy", title = "Teams", text = "This module adds team features.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_teams"] = pshy.help_pages["pshy_teams"]



--- Module settings:
pshy.teams_target_score = -1							-- score a team must reach to win
pshy.teams_auto = true									-- automatically players in a team
pshy.teams_rejoin = true								-- players leaving a team will rejoin the same one
pshy.teams_alternate_scoreboard_ui_arbitrary_id = 768	--
pshy.teams_use_map_name = true



--- Internal Use:
pshy.teams = {}								-- teams (team_name -> {name, player_names (set of player names), color (hex string), score (number)})
pshy.teams_players_team = {}				-- map of player name -> team reference in wich they are
pshy.teams_winner_index = nil				-- becomes the winning team name (indicates that the next round should be for the winner)
pshy.teams_have_played_winner_round = false	-- indicates that the round for the winner has already started



--- Pshy event eventTeamWon.
function eventTeamWon(team_name)
	-- By default this does nothing, as this module does not handle gameplay.
end



--- Get a team table by index or name.
-- @public
-- @param team_name The team index (number) or name (string).
-- @return The team's table or nil if not found.
function pshy.teams_GetTeam(team_name)
	team_name = tonumber(team_name) or team_name
	if type(team_name) == "number" then
		return pshy.teams[team_name]
	else
		for team_index, team in pairs(pshy.teams) do
			if team.name == team_name then
				return team
			end
		end
	end
	return nil
end



--- Get the lowest team score.
-- @return The lowest team score.
function pshy.teams_GetLowestTeamScore()
	local lowest_score = nil
	for i_team, team in ipairs(pshy.teams) do
		if not lowest_score or team.score < lowest_score then
			lowest_score = team.score
		end
	end
	return lowest_score
end




--- Get a string line representing the teams scores.
function pshy.teams_GetScoreLine()
	local leading = pshy.teams_GetLeadingTeam()
	local text = "<n>"
	for i_team, team in ipairs(pshy.teams) do
		if #text > 3 then
			text = text .. " - "
		end
		text = text .. ((leading and leading.name == team.name) and "<b>" or "")
		text = text .. "<font color='#" .. team.color .. "'>" 
		text = text .. team.name .. ": " .. tostring(team.score)
		text = text .. "</font>"
		text = text .. ((leading and leading.name == team.name) and "</b>" or "")
	end
	text = text .. "   <g>|</g>   D: " .. tostring(pshy.teams_target_score) .. "</n>"
	return text
end



--- Update the teams scoreboard.
-- @brief player_name optional player name who will see the changes
function pshy.teams_UpdateScoreboard(player_name)
	local text = pshy.teams_GetScoreLine()
	if pshy.TableCountKeys(pshy.teams) <= 4 then
		ui.removeTextArea(pshy.teams_alternate_scoreboard_ui_arbitrary_id, nil)
		ui.setMapName(pshy.teams_GetScoreLine())
	else
		text = "<p align='left'>" .. text .. "</p>"
		ui.addTextArea(pshy.teams_alternate_scoreboard_ui_arbitrary_id, text, player_name, 0, 20, 800, 0, 0, 0, 1.0, false)
	end
end



--- Get the team {} with the highest score, or nil on draw
function pshy.teams_GetLeadingTeam()
	local winning = nil
	local draw = false
	for i_team, team in ipairs(pshy.teams) do
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
function pshy.teams_GetUndernumerousTeam()
	local undernumerous = nil
	for i_team, team in ipairs(pshy.teams) do
		if not undernumerous or pshy.TableCountKeys(team.player_names) < pshy.TableCountKeys(undernumerous.player_names) then
			undernumerous = team
		end
	end
	return undernumerous
end



--- Remove players from teams
function pshy.teams_ClearPlayers()
	for i_team, team in ipairs(pshy.teams) do
		team.player_names = {}
	end
	pshy.teams_players_team = {}
end



--- Remove all players from teams.
function pshy.teams_Reset(count)
	-- optional new team count
	count = count or 2
	assert(count > 0)
	assert(count <= #pshy.teams_default)
	-- clear
	pshy.teams = {}
	pshy.teams_players_team = {}
	-- add default teams
	for i_team = 1, count do
		pshy.teams_AddTeam(pshy.teams_default[i_team].name, pshy.teams_default[i_team].color)
	end
	-- update scoreboard
	pshy.teams_UpdateScoreboard()
end
pshy.teams_default = {}						-- default teams
pshy.teams_default[1] = {name = "Team1", color = 0xff7777}
pshy.teams_default[2] = {name = "Team2", color = 0x77ff77}
pshy.teams_default[3] = {name = "Team3", color = 0x77aaff}
pshy.teams_default[4] = {name = "Team4", color = 0xffff77}



--- Add a new active team.
-- @param team_name The team's name.
-- @param hex_color A hex string representing the team color (without # or 0x).
function pshy.teams_AddTeam(team_name, hex_color)
	local new_team = {}
	new_team.name = team_name
	new_team.color = string.format("%x", hex_color)
	new_team.score = 0
	new_team.player_names = {}
	table.insert(pshy.teams, new_team)
	pshy.teams_UpdateScoreboard()
end
pshy.commands["teamadd"] = {func = pshy.teams_AddTeam, desc = "add a new team", no_user = true,  argc_min = 2, argc_max = 2, arg_types = {"string", "color"}, arg_names = {"team_name", "color"}}
pshy.help_pages["pshy_teams"].commands["teamadd"] = pshy.commands["teamadd"]
pshy.perms.admins["!teamadd"] = true



--- Remove a team.
-- @param team_name The team's name.
-- @param hex_color A hex string representing the team color (without # or 0x).
function pshy.teams_RemoveTeam(team)
	local team_index
	for i_team, a_team in ipairs(pshy.teams) do
		if a_team == team then
			team_index = i_team
			break
		end
	end
	-- @TODO remove players
	table.remove(pshy.teams, team_index)
	pshy.teams_UpdateScoreboard()
end
pshy.commands["teamremove"] = {func = pshy.teams_RemoveTeam, desc = "remove a team", no_user = true,  argc_min = 1, argc_max = 1, arg_types = {pshy.teams_GetTeam}, arg_names = {"team"}}
pshy.help_pages["pshy_teams"].commands["teamremove"] = pshy.commands["teamremove"]
pshy.perms.admins["!teamremove"] = true
pshy.commands_aliases["teamrm"] = "teamremove"



--- Reset teams scores
function pshy.teams_ResetScores()
	for i_team, team in ipairs(pshy.teams) do
		team.score = 0
	end
	pshy.teams_UpdateScoreboard()
end
pshy.commands["teamsreset"] = {func = pshy.teams_ResetScores, no_user = true, desc = "Reset the teams's scores.", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_teams"].commands["teamsreset"] = pshy.commands["teamsreset"]
pshy.perms.admins["!teamsreset"] = true



--- Add a player to a team.
-- The player is also removed from other teams.
-- @param team_name The player's team name or index or table.
-- @param player_name The player's name.
function pshy.teams_AddPlayer(team_name, player_name)
	local team = (type(team_name) == "table") and team_name or pshy.teams_GetTeam(team_name)
	assert(team ~= nil)
	-- unjoin current team
	if pshy.teams_players_team[player_name] then
		pshy.teams_players_team[player_name].player_names[player_name] = nil
	end
	-- join new team
	team.player_names[player_name] = true
	pshy.teams_players_team[player_name] = team
	tfm.exec.setNameColor(player_name, team and tonumber(team.color, 16) or 0xff7777)
end



--- Update player's nick color.
function pshy.teams_RefreshNamesColor()
	for player_name, team in pairs(pshy.teams_players_team) do
		tfm.exec.setNameColor(player_name, tonumber(team.color, 16))
	end
end



--- Shuffle teams
-- Randomly set players in a single team.
function pshy.teams_Shuffle()
	pshy.teams_ClearPlayers()
	local unassigned_players = {}
	for player_name, player in pairs(tfm.get.room.playerList) do
		table.insert(unassigned_players, player_name)
	end
	if #pshy.teams >= 1 then
		while #unassigned_players > 0 do
			for team_name, team in pairs(pshy.teams) do
				if #unassigned_players > 0 then
					local player_name = table.remove(unassigned_players, math.random(1, #unassigned_players))
					pshy.teams_AddPlayer(team_name, player_name)
				end
			end
		end
	end
	pshy.teams_ResetScores()
	pshy.teams_RefreshNamesColor()
end
pshy.commands["teamsshuffle"] = {func = pshy.teams_Shuffle, desc = "shuffle the players in the teams", no_user = true,  argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_teams"].commands["teamsshuffle"] = pshy.commands["teamsshuffle"]
pshy.perms.admins["!teamsshuffle"] = true



--- pshy event eventPlayerScore
function eventPlayerScore(player_name, score)
	local team = pshy.teams_players_team[player_name]
	if team then
		team.score = team.score + score
		pshy.teams_UpdateScoreboard()
		if not pshy.teams_winner_name and team.score >= pshy.teams_target_score then
			eventTeamWon(team.name)
		end
	end
end



--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	if pshy.TableCountKeys(pshy.teams) > 0 and pshy.teams_auto then
		local team = nil
		-- default team is the previous one
		if pshy.teams_rejoin then
			team = pshy.teams_players_team[player_name]
		end
		-- get either the previous team or an undernumerous one
		if not team then
			team = pshy.teams_GetUndernumerousTeam()
		end
		pshy.teams_AddPlayer(team.name, player_name)
	end
	pshy.teams_UpdateScoreboard(player_name)
end



--- TFM event eventPlayerLeft
-- Remove the player from the team list when he leave, but still remember his previous team.
function eventPlayerLeft(player_name)
	local team = pshy.teams_players_team[player_name]
	if team then
		team.player_names[player_name] = nil
	end
end



function eventNewGame()
	pshy.teams_RefreshNamesColor()
	pshy.teams_UpdateScoreboard(player_name)
end



--- !d <D>
function pshy.teams_ChatCommandD(user, d)
	if d < 1 then
		return false, "The minimum target score is 1."
	end
	pshy.teams_target_score = d
	pshy.teams_UpdateScoreboard(player_name)
end
pshy.commands["d"] = {func = pshy.teams_ChatCommandD, desc = "set the target score", argc_min = 1, argc_max = 1, arg_types = {"number"}}
pshy.help_pages["pshy_teams"].commands["d"] = pshy.commands["d"]
pshy.perms.admins["!d"] = true



--- !teamjoin <team> [player]
function pshy.teams_ChatCommandTeamsjoin(user, team, target)
	assert(type(team) == "table")
	target = pshy.commands_GetTargetOrError(user, target, "!teamjoin")
	if team.score > pshy.teams_GetLowestTeamScore() and not pshy.HavePerm(user, "!teamjoin-losing") then
		return false, "You can only join the loosing team."
	end
	pshy.teams_AddPlayer(team, target)
	return true, "Changed " .. user .. "'s team."
end
pshy.commands["teamjoin"] = {func = pshy.teams_ChatCommandTeamsjoin, desc = "join a team", argc_min = 1, argc_max = 2, arg_types = {pshy.teams_GetTeam, "player"}, arg_names = {"team", "target"}}
pshy.help_pages["pshy_teams"].commands["teamjoin"] = pshy.commands["teamjoin"]
pshy.perms.everyone["!teamjoin"] = true
pshy.perms.cheats["!teamjoin-losing"] = true
pshy.perms.admins["!teamjoin-others"] = true



--- Rename a team.
function pshy.teams_Rename(team, new_name)
	assert(#new_name >= 1, "The team name cannot be empty.")
	assert(#new_name <= 16, "The team name's max lenght is 16.")
	team.name = new_name
	pshy.teams_UpdateScoreboard()
end
pshy.commands["teamname"] = {func = pshy.teams_Rename, desc = "rename a team", no_user = true,  argc_min = 2, argc_max = 2, arg_types = {pshy.teams_GetTeam, "string"}, arg_names = {"team"}}
pshy.help_pages["pshy_teams"].commands["teamname"] = pshy.commands["teamname"]
pshy.perms.admins["!teamname"] = true



--- Change a team's color.
function pshy.teams_SetColor(team, hexcolor)
	assert(type(hexcolor) == "number", "expected a color as a number")
	team.color = string.format("%0x", hexcolor)
	pshy.teams_UpdateScoreboard()
end
pshy.commands["teamcolor"] = {func = pshy.teams_SetColor, desc = "change a team's color", no_user = true,  argc_min = 2, argc_max = 2, arg_types = {pshy.teams_GetTeam, "color"}, arg_names = {"team"}}
pshy.help_pages["pshy_teams"].commands["teamcolor"] = pshy.commands["teamcolor"]
pshy.perms.admins["!teamcolor"] = true



--- Change a team's score.
function pshy.teams_SetScore(team, score)
	team.score = score
	pshy.teams_UpdateScoreboard()
end
pshy.commands["teamscore"] = {func = pshy.teams_SetScore, desc = "set a team's score", no_user = true,  argc_min = 2, argc_max = 2, arg_types = {pshy.teams_GetTeam, "number"}, arg_names = {"team", "score"}}
pshy.help_pages["pshy_teams"].commands["teamscore"] = pshy.commands["teamscore"]
pshy.perms.admins["!teamscore"] = true



--- !aj <on|off>
local function ChatCommandAutojoin(user, enabled)
	if not enabled then
		aj = not pshy.teams_auto
	end
	pshy.teams_auto = enabled
	if enabled then
		return true, "Teams auto-join enabled!"
	else
		return true, "Teams auto-join disabled!"
	end
end
pshy.commands["teamsautojoin"] = {func = ChatCommandAutojoin, desc = "Enable or disable team's autojoin.", argc_min = 1, argc_max = 0, arg_types = {"bool"}}
pshy.help_pages["pshy_teams"].commands["teamsautojoin"] = pshy.commands["teamsautojoin"]
pshy.perms.admins["!teamsautojoin"] = true
pshy.commands_aliases["teamsaj"] = "teamsautojoin"
pshy.commands_aliases["aj"] = "teamsautojoin"
