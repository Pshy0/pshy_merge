--- pshy_teams.lua
--
-- Implement team features.
--
-- @author pshy
-- @require pshy_scores.lua
-- @require pshy_help.lua
-- @namespace pshy



--- Help page:
pshy.help_pages["pshy_teams"] = {back = "pshy", text = "This module adds team features.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_teams"] = pshy.help_pages["pshy_teams"]



--- Module settings:
pshy.teams_auto = true					-- automatically players in a team
pshy.teams_rejoin = true				-- players leaving a team will rejoin the same one



--- Active teams map.
-- Key is the team name.
--	name			- display name of the team
--	player_names		- set of player names
--	color			- hexadecimal string
--	score			- number
pshy.teams = {}
pshy.teams_players_team = {}	-- map of player name -> team reference in wich they are



--- Add a new active team.
-- @param name The team's name.
-- @param hex_color A hex string representing the team color (without # or 0x).
function pshy.TeamsAddTeam(name, hex_color)
	local new_team = {}
	new_team.name = name
	new_team.color = hex_color
	new_team.score = 0
	new_team.player_names = {}
	pshy.teams[name] = new_team
end



--- Remove all players from teams.
function pshy.TeamsReset(count)
	-- optional new team count
	count = count or 2
	assert(count > 0)
	assert(count <= #pshy.teams_default)
	-- clear
	pshy.teams = {}
	pshy.teams_players_team = {}
	-- add default teams
	for i_team = 1, count do
		pshy.TeamsAddTeam(pshy.teams_default[i_team].name, pshy.teams_default[i_team].color)
	end
end
pshy.teams_default = {}					-- default teams list
pshy.teams_default[1] = {name = "Red", color = "ff0000"}
pshy.teams_default[2] = {name = "Green", color = "00ff00"}
pshy.teams_default[3] = {name = "Blue", color = "0000ff"}
pshy.teams_default[4] = {name = "Yellow", color = "ffff00"}
pshy.teams_default[5] = {name = "Magenta", color = "ff00ff"}
pshy.teams_default[6] = {name = "Cyan", color = "00ffff"}




--- Remove players from teams
function pshy.TeamsClearPlayers()
	for team_name, team in pairs(pshy.teams) do
		team.player_names = {}
	end
	pshy.teams_players_team = {}
end



--- Get the team {} with the highest score, or nil on draw
function pshy.TeamsGetWinningTeam()
	local winning = nil
	local draw = false
	for team_name, team in pairs(pshy.teams) do
		if winning and team.score == winning.score then
			draw = true
		elseif not winning or team.score > winning.score then 
			winning = team
			draw = false
		end
	end
	return draw and nil or winning
end



--- Get one of the teams {} with the fewest players in
function pshy.TeamsGetUndernumerousTeam()
	local undernumerous = nil
	for team_name, team in pairs(pshy.teams) do
		if not undernumerous or #team.player_names < #undernumerous.player_names then
			undernumerous = team
		end
	end
	return undernumerous
end



--- Add a player to a team.
-- The player is also removed from other teams.
-- @team_name The player's team name.
-- @player_name The player's name.
function pshy.TeamsAddPlayer(team_name, player_name)
	local team = pshy.teams[team_name]
	assert(type(team) == "table")
	-- unjoin current team
	if pshy.teams_players_team[player_name] then
		pshy.teams_players_team[player_name].player_names[player_name] = nil
	end
	-- join new team
	team.player_names[player_name] = true
	pshy.teams_players_team[player_name] = team
	tfm.exec.setNameColor(player_name, "Ox" .. (team and team.color or "dddddd"))
end



--- Shuffle teams
-- Randomly set players in a single team.
function pshy.TeamsShuffle()
	pshy.TeamsClearPlayers()
	local unassigned_players = {}
	for player_name, player in pairs(tfm.get.room.playerList) do
		table.insert(unassigned_players, player_name)
	end
	while #unassigned_players > 0 do
		for team_name, team in pairs(pshy.teams) do
			if #unassigned_players > 0 then
				local player_name = table.remove(unassigned_players, math.random(1, #unassigned_players))
				pshy.TeamsAddPlayer(team_name, player_name)
			end
		end
	end
end



--- Get a string line representing the teams scores
function pshy.TeamsGetScoreLine()
	local text = "<b>"
	for team_name, team in pairs(pshy.teams) do
		if #text > 4 then
			text = text .. " - "
		end
		text = text .. "<font color='#" .. team.color .. "'>" .. team.name .. ": " .. tostring(team.score) .. "</font>"
	end
	text = text .. "</b>"
	return text
end



--- pshy event eventPlayerScore
function eventPlayerScore(player_name, score)
	local team = pshy.teams_players_team[player_name]
	if team then
		team.score = team.score + score
		ui.setMapName(pshy.TeamsGetScoreLine())
	end
end



--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	if #pshy.teams > 0 and pshy.teams_auto then
		local team = nil
		-- default team is the previous one
		if pshy.teams_rejoin then
			team = pshy.teams_players_team[player_name]
		end
		-- get either the previous team or an undernumerous one
		if not team then
			team = pshy.GetUndernumerousTeam()
		end
		pshy.TeamsAddPlayer(team.name, player_name)
	end
end



--- TFM event eventPlayerLeft
-- Remove the player from the team list when he leave, but still remember his previous team
function eventPlayerLeft(player_name)
	local team = pshy.teams_players_team[player_name]
	if team then
		team.player_names[player_name] = nil
	end
end



--- TFM event eventNewGame
function eventNewGame()
	ui.setMapName(pshy.TeamsGetScoreLine())
end



--- Initialization
pshy.TeamsReset(4)
pshy.TeamsShuffle()
