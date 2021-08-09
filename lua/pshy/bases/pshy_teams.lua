--- pshy_teams.lua
--
-- Implement team features.
--
-- @author pshy
-- @require pshy_help.lua
-- @require pshy_scores.lua
-- @require pshy_mapdb.lua
-- @namespace pshy



--- Help page:
pshy.help_pages["pshy_teams"] = {back = "pshy", title = "Teams", text = "This module adds team features.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_teams"] = pshy.help_pages["pshy_teams"]



--- Module settings:
pshy.teams_auto = true					-- automatically players in a team
pshy.teams_rejoin = true				-- players leaving a team will rejoin the same one
pshy.teams_target_score = 10				-- score a team must reach to win
pshy.teams_alternate_scoreboard_ui_arbitrary_id = 768 --
pshy.teams_use_map_name = true
local EMPTY_MAP = [[<C><P /><Z><S /><D /><O /></Z></C>]]
local EMPTY_MAP_PLUS = [[<C><P mc="" Ca="" /><Z><S /><D /><O /></Z></C>]]
local PSHY_WIN_MAP_1 = [[<C><P F="2" /><Z><S><S X="42" o="f8331" L="38" Y="343" H="10" P="0,0,0.0,1.2,30,0,0,0" T="12" /><S X="400" L="2000" Y="400" H="36" P="0,0,,,,0,0,0" T="9" /><S X="400" L="80" Y="110" c="1" H="20" P="0,0,0.3,0,0,0,0,0" T="10" /><S X="400" L="80" Y="250" c="4" H="300" P="0,0,0.3,0,0,0,0,0" T="10" /><S X="400" L="400" Y="400" H="200" P="0,0,0.3,0.2,-10,0,0,0" T="6" /><S X="312" L="120" Y="403" H="200" P="0,0,0.3,0.2,-20,0,0,0" T="6" /><S X="625" L="120" Y="400" H="200" P="0,0,0.3,0.2,10,0,0,0" T="6" /><S X="74" o="324650" L="70" Y="117" H="10" P="0,0,0.3,0.2,0,0,0,0" T="12" /></S><D><P X="602" P="1,0" T="5" Y="299" /><DS X="538" Y="242" /><DC X="398" Y="72" /><P X="216" P="0,0" T="2" Y="331" /><P X="540" P="0,0" T="1" Y="277" /><F X="384" Y="96" /><F X="399" Y="87" /><F X="414" Y="95" /><P X="666" P="0,0" T="252" Y="310" /><P X="468" P="0,0" T="254" Y="288" /><P X="347" P="0,1" T="254" Y="310" /><P X="160" P="0,0" T="249" Y="399" /><P X="81" P="0,1" T="249" Y="403" /><P X="110" P="0,0" T="250" Y="401" /><P X="484" P="0,0" T="230" Y="284" /><P X="17" P="1,0" T="251" Y="400" /><P X="64" P="1,0" T="217" Y="111" /></D><O /></Z></C>]]
pshy.teams_win_map = "teams_win" 			-- win map name



--- Pshy Settings:
pshy.scores_per_first_wins[1] = 1		-- the first earns a point



--- Internal Use:
pshy.teams = {}								-- teams (team_name -> {name, player_names (set of player names), color (hex string), score (number)})
pshy.teams_players_team = {}				-- map of player name -> team reference in wich they are
pshy.teams_winner_index = nil				-- becomes the winning team name (indicates that the next round should be for the winner)
pshy.teams_have_played_winner_round = false	-- indicates that the round for the winner has already started



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



--- pshy event eventTeamWon(team_name)
function eventTeamWon(team_index)
	pshy.teams_winner_index = team_index
	local team = pshy.teams[team_index]
	tfm.exec.setGameTime(8, true)
	pshy.Title("<br><font size='64'><b><p align='center'>Team <font color='#" .. team.color .. "'>" .. team.name .. "</font> wins!</p></b></font>")
	pshy.teams_have_played_winner_round = false
	pshy.mapdb_SetNextMap(pshy.teams_win_map)
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
pshy.chat_commands["teamsadd"] = {func = pshy.teams_AddTeam, desc = "add a new team", no_user = true,  argc_min = 2, argc_max = 2, arg_types = {"string", "hexnumber"}, arg_names = {"team_name", "team_color"}}
pshy.help_pages["pshy_teams"].commands["teamsadd"] = pshy.chat_commands["teamsadd"]
pshy.perms.admins["!teamsadd"] = true



--- Remove a team.
-- @param team_name The team's name.
-- @param hex_color A hex string representing the team color (without # or 0x).
function pshy.teams_RemoveTeam(team)
	local team_index
	for i_team, a_team in ipairs(teams) do
		if a_team == team then
			team_index = index
			break
		end
	end
	-- @TODO remove players
	table.remove(pshy.teams, team_index)
	pshy.teams_UpdateScoreboard()
end
pshy.chat_commands["teamsremove"] = {func = pshy.teams_RemoveTeam, desc = "remove a team", no_user = true,  argc_min = 1, argc_max = 1, arg_types = {pshy.teams_GetTeam}, arg_names = {"team"}}
pshy.help_pages["pshy_teams"].commands["teamsremove"] = pshy.chat_commands["teamsremove"]
pshy.perms.admins["!teamsremove"] = true
pshy.commands_aliases["teamsrm"] = "teamsremove"



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



--- Reset teams scores
function pshy.teams_ResetScores()
	for i_team, team in ipairs(pshy.teams) do
		team.score = 0
	end
	pshy.teams_UpdateScoreboard()
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



--- Add a player to a team.
-- The player is also removed from other teams.
-- @team_name The player's team name.
-- @player_name The player's name.
function pshy.teams_AddPlayer(team_name, player_name)
	local team = pshy.teams[team_name]
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
	while #unassigned_players > 0 do
		for team_name, team in pairs(pshy.teams) do
			if #unassigned_players > 0 then
				local player_name = table.remove(unassigned_players, math.random(1, #unassigned_players))
				pshy.teams_AddPlayer(team_name, player_name)
			end
		end
	end
	pshy.teams_ResetScores()
	pshy.teams_RefreshNamesColor()
end
pshy.chat_commands["teamsshuffle"] = {func = pshy.teams_Shuffle, desc = "shuffle the players in the teams", no_user = true,  argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_teams"].commands["teamsshuffle"] = pshy.chat_commands["teamsshuffle"]
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
			team = pshy.TeamsGetUndernumerousTeam()
		end
		pshy.TeamsAddPlayer(team.name, player_name)
	end
	pshy.teams_UpdateScoreboard(player_name)
end



--- TFM event eventPlayerLeft
-- Remove the player from the team list when he leave, but still remember his previous team
function eventPlayerLeft(player_name)
	local team = pshy.teams_players_team[player_name]
	if team then
		team.player_names[player_name] = nil
	end
end



--- TFM event eventPlayerWon.
function eventPlayerWon(player_name)
	tfm.exec.setGameTime(5, false)
end



--- TFM event eventPlayerDied.
function eventPlayerDied(player_name)
	if pshy.CountPlayersAlive() == 0 then
		tfm.exec.setGameTime(5, false)
	end
end



--- TFM event eventNewGame
function eventNewGame()
	if pshy.teams_winner_name then
		if not pshy.teams_have_played_winner_round then
			-- winner round
			pshy.teams_have_played_winner_round = true
			tfm.exec.setGameTime(13, true)
			local winner_team = pshy.teams[pshy.teams_winner_name]
			for player_name, void in pairs(winner_team.player_names) do
				tfm.exec.setShaman(player_name, true)
			end
			pshy.Title(nil)
			pshy.mapdb_SetNextMap("lobby")
		else
			-- first round of new match
			pshy.teams_winner_name = nil
			pshy.teams_have_played_winner_round = false
			pshy.teams_ResetScores()
			pshy.Title(nil)
		end
	end
	pshy.teams_RefreshNamesColor()
	pshy.teams_UpdateScoreboard(player_name)
end



--- Replace #ff0000 by the winner team color
function pshy.teams_ReplaceRedToWinningColor(map)
	local winner_team = pshy.teams[pshy.teams_winner_name]
	return string.gsub(map, "ff0000", winner_team.color)
end



--- !d <D>
function pshy.teams_ChatCommandD(user, d)
	if d < 1 then
		return false, "The minimum target score is 1."
	end
	pshy.teams_target_score = d
	pshy.teams_UpdateScoreboard(player_name)
end
pshy.chat_commands["d"] = {func = pshy.teams_ChatCommandD, desc = "set the target score", argc_min = 1, argc_max = 1, arg_types = {"number"}}
pshy.help_pages["pshy_teams"].commands["d"] = pshy.chat_commands["d"]
pshy.perms.admins["!d"] = true



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



--- !teamsjoin <team> [player]
function pshy.teams_ChatCommandTeamsjoin(user, team, target)
	assert(type(team) == "table")
	target = pshy.commands_GetTargetOrError(user, target, "!teamsjoin")
	if team.score > pshy.teams_GetLowestTeamScore() and not pshy.HavePerm(user, "!teamsjoin-losing") then
		return false, "You can only join a team with the worst score."
	end
	pshy.teams_AddPlayer("", target)
	return true, "Changed " .. user .. "'s team"
end
pshy.chat_commands["teamsjoin"] = {func = pshy.teams_ChatCommandTeamsjoin, desc = "set the target score", argc_min = 1, argc_max = 2, arg_types = {pshy.teams_GetTeam, "player"}, arg_names = {"team", "target"}}
pshy.help_pages["pshy_teams"].commands["teamsjoin"] = pshy.chat_commands["teamsjoin"]
pshy.perms.cheats["!teamsjoin"] = true
pshy.perms.admins["!teamsjoin-others"] = true
pshy.perms.cheats["!teamsjoin-any"] = true



--- Initialization
-- winner maps rotation:
pshy.mapdb_maps["teams_win_1"] = {author = "Pshy#3752", func_begin = nil, func_end = nil, func_replace = pshy.teams_ReplaceRedToWinningColor, xml = '<C><P Ca="" mc="" /><Z><S><S X="100" o="0" L="150" Y="320" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="0" o="ff0000" L="300" Y="400" H="300" P="0,0,0.3,0.2,45,0,0,0" T="12" /><S X="700" o="0" L="150" Y="320" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="-20" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="820" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="800" o="ff0000" L="300" Y="400" H="300" P="0,0,0.3,0.2,45,0,0,0" T="12" /><S X="400" o="0" L="200" Y="250" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="400" o="ff0000" L="100" Y="100" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /></S><D><DC X="400" Y="82" /><DS X="400" Y="229" /></D><O><O C="13" X="700" P="0" Y="320" /><O C="12" X="100" P="0" Y="320" /></O></Z></C>'}
pshy.mapdb_maps["teams_win_2"] = {author = "Pshy#3752", func_begin = nil, func_end = nil, func_replace = pshy.teams_ReplaceRedToWinningColor, xml = '<C><P Ca="" mc="" /><Z><S><S X="530" o="0" L="150" Y="330" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="270" o="0" L="150" Y="330" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="-20" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="820" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="400" o="ff0000" L="300" Y="400" H="300" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="400" o="ff0000" L="100" Y="100" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="80" o="0" L="150" Y="190" c="3" H="20" P="0,0,0.3,0.2,10,0,0,0" T="12" /><S X="720" o="0" L="150" Y="190" c="3" H="20" P="0,0,0.3,0.2,-10,0,0,0" T="12" /></S><D><DC X="400" Y="85" /><DS X="400" Y="245" /></D><O><O C="13" X="270" P="0" Y="330" /><O C="12" X="530" P="0" Y="330" /></O></Z></C>'}
pshy.mapdb_maps["teams_win_3"] = {author = "Pshy#3752", func_begin = nil, func_end = nil, func_replace = pshy.teams_ReplaceRedToWinningColor, xml = '<C><P Ca="" mc="" /><Z><S><S X="250" o="0" L="150" Y="300" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="-20" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="540" o="0" L="150" Y="300" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="820" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="690" o="ff0000" L="300" Y="400" H="300" P="0,0,0.3,0.2,-10,0,0,0" T="12" /><S X="700" o="0" L="100" Y="100" c="3" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="110" o="ff0000" L="300" Y="400" H="300" P="0,0,0.3,0.2,10,0,0,0" T="12" /><S X="100" o="0" L="100" Y="100" c="3" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="400" o="ff0000" L="150" Y="150" c="1" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /></S><D><DC X="700" Y="85" /><DS X="100" Y="85" /></D><O><O C="13" X="540" P="0" Y="300" /><O C="12" X="260" P="0" Y="300" /></O></Z></C>'}
pshy.mapdb_maps["teams_win_4"] = {author = "Pshy#3752", func_begin = nil, func_end = nil, func_replace = pshy.teams_ReplaceRedToWinningColor, xml = '<C><P Ca="" mc="" /><Z><S><S X="-20" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="820" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="820" o="ff0000" L="100" Y="240" H="300" P="0,0,0.3,0.2,10,0,0,0" T="12" /><S X="400" o="0" L="100" Y="100" c="3" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="-20" o="ff0000" L="100" Y="240" H="300" P="0,0,0.3,0.2,-10,0,0,0" T="12" /><S X="400" o="0" L="150" Y="200" c="3" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="620" o="ff0000" L="150" Y="250" c="1" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="400" o="0" L="200" Y="300" c="3" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="180" o="ff0000" L="150" Y="250" c="1" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /></S><D><DC X="400" Y="190" /><DS X="400" Y="85" /></D><O><O C="12" X="620" P="0" Y="250" /><O C="13" X="180" P="0" Y="250" /></O></Z></C>'}
pshy.mapdb_rotations["teams_win"]				= {desc = "P0", duration = 30, items = {"teams_win_1", "teams_win_2", "teams_win_3", "teams_win_4"}}
pshy.teams_Reset(4)
pshy.teams_Shuffle()
pshy.teams_UpdateScoreboard()
