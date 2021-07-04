--- pshy_teams.lua
--
-- Implement team features in a module.
--
-- `pshy.teams` is used to store the teams state.
-- pshy.players[X].team represent the last team the player was in.
--
-- @author pshy
-- @namespace pshy



--- Module options:
pshy.teams_auto = true		-- Automatically put players in a team



--- Teams infos.
-- Map of teams (index is the team name).
-- A team have the folowing properties:
--	name			- The display name of the team
--	player_names	- set of player names
--	color			- hexadecimal string
--	score			- number
pshy.teams = {}



--- Map of player's team.
-- Keys are players names.
-- Values are team table refs.
pshy.players_team = {}



--- List of default teams.
pshy.default_teams = {}
pshy.default_teams[1] = {name = "Red", color = "ff0000"}
pshy.default_teams[2] = {name = "Green", color = "00ff00"}
pshy.default_teams[3] = {name = "Blue", color = "0000ff"}
pshy.default_teams[4] = {name = "Yellow", color = "ffff00"}



--- Create a new team that the module will consider.
-- @param name The team's name.
-- @param hex_color A hex string representing the team color (without # or 0x).
function pshy.AddTeam(name, hex_color)
	local new_team = {}
	new_team.name = name
	new_team.color = hex_color
	new_team.score = 0
	new_team.player_names = {}
	pshy.teams[name] = new_team
end



--- Remove all players from teams.
function pshy.ClearTeams()
	for player_name, player in pairs(pshy.players_team) do
		player.team = nil
	end
	pshy.players_team = {}
end



--- Load default teams.
-- @param count Amount of teams to create.
function pshy.LoadDefaultTeams(count)
	count = count or 2
	assert(count > 0)
	assert(count <= #pshy.default_teams)
	pshy.teams = {}
	pshy.players_team = {}
	for i_team, team in ipairs(pshy.default_teams) do
		pshy.AddTeam(team.name, team.color)
	end
end



--- Get the team {} with the highest score, or nil on draw
function GetWinningTeam()
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
function GetUndernumerousTeam()
	local undernumerous = nil
	for team_name, team in pairs(pshy.teams) do
		if not undernumerous or #team.players < undernumerous.players then
			undernumerous = team
		end
	end
	return undernumerous
end



--- Add a player to a team.
-- The player is also removed from other teams.
-- @player_name The player's name.
-- @team_name The player's team name.
function TeamAddPlayer(team, player_name)
	if pshy.players_team[player_name] then
		pshy.teams[pshy.players_team[player_name]].player_names[player_name] = nil
	end
	team.player_names[player_name] = true
	pshy.players_team[player_name] = team
	tfm.exec.setNameColor(player_name, "Ox" .. (team and team.color or "dddddd"))
end



--- Shuffle teams
-- Randomly set players in a single team.
function ShuffleTeams()
	local unassigned_players = {}
	for player_name, player in pairs(tfm.get.room.playerList) do
		table.insert(unassigned_players, player_name)
	end
	while #unassigned_players > 0 do
		for team_name, team in pairs(pshy.teams) do
			if #unassigned_players > 0 then
				local player_name = table.remove(unassigned_players, math.random(1, #unassigned_players))
				pshy.TeamAddPlayer(team, player_name)
			end
		end
	end
end



--- TFM event eventNewPlayer
function eventNewPlayer(playerName)
	if pshy.teams_auto then
		local team
		-- get either the previous team or an undernumerous one
		if pshy.players_team[playerName] then
			team = pshy.players_team[playerName]
		else
			team = pshy.GetUndernumerousTeam()
		end
		pshy.TeamAddPlayer(team, playerName)
	end
end



--- TFM event eventPlayerLeft
function eventPlayerLeft(playerName)
	local team = pshy.players_team[playerName]
	if team then
		team.player_names[playerName] = nil
		pshy.players_team[playerName] = nil
	end
end



--- Initialization
pshy.LoadDefaultTeams(4)
