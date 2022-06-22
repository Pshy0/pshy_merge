--- pshy.teams.racingvs
--
-- Extends `pshy_teams` with a racing vs scoring system.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.bases.doc")
pshy.require("pshy.bases.scores")
pshy.require("pshy.events")
pshy.require("pshy.rotations.newgame")
local utils_messages = pshy.require("pshy.utils.messages")
local utils_tables = pshy.require("pshy.utils.tables")
local utils_tfm = pshy.require("pshy.utils.tfm")
local maps = pshy.require("pshy.lists.maps")
local rotations = pshy.require("pshy.lists.rotations")



--- Module Settings:
pshy.teams_win_map = "teams_win" 			-- win map name



--- Pshy Settings:
pshy.teams_target_score = 10				-- override the target score
pshy.scores_per_first_wins[1] = 1			-- the first earns a point
pshy.teams_auto = true						-- automatically put players in a team
pshy.teams_rejoin = true					-- players leaving a team will rejoin the same one



--- Replace #ff0000 by the winner team color.
local function ReplaceRedToWinningColor(xml)
	local winner_team = pshy.teams[pshy.teams_winner_index]
	return string.gsub(xml, "ff0000", winner_team.color)
end



--- Maps and Rotations:
maps["teams_win_1"]		= {author = "Pshy#3752", replace_func = ReplaceRedToWinningColor, xml = '<C><P Ca="" mc="" /><Z><S><S X="100" o="0" L="150" Y="320" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="0" o="ff0000" L="300" Y="400" H="300" P="0,0,0.3,0.2,45,0,0,0" T="12" /><S X="700" o="0" L="150" Y="320" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="-20" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="820" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="800" o="ff0000" L="300" Y="400" H="300" P="0,0,0.3,0.2,45,0,0,0" T="12" /><S X="400" o="0" L="200" Y="250" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="400" o="ff0000" L="100" Y="100" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /></S><D><DC X="400" Y="82" /><DS X="400" Y="229" /></D><O><O C="13" X="700" P="0" Y="320" /><O C="12" X="100" P="0" Y="320" /></O></Z></C>'}
maps["teams_win_2"]		= {author = "Pshy#3752", replace_func = ReplaceRedToWinningColor, xml = '<C><P Ca="" mc="" /><Z><S><S X="530" o="0" L="150" Y="330" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="270" o="0" L="150" Y="330" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="-20" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="820" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="400" o="ff0000" L="300" Y="400" H="300" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="400" o="ff0000" L="100" Y="100" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="80" o="0" L="150" Y="190" c="3" H="20" P="0,0,0.3,0.2,10,0,0,0" T="12" /><S X="720" o="0" L="150" Y="190" c="3" H="20" P="0,0,0.3,0.2,-10,0,0,0" T="12" /></S><D><DC X="400" Y="85" /><DS X="400" Y="245" /></D><O><O C="13" X="270" P="0" Y="330" /><O C="12" X="530" P="0" Y="330" /></O></Z></C>'}
maps["teams_win_3"]		= {author = "Pshy#3752", replace_func = ReplaceRedToWinningColor, xml = '<C><P Ca="" mc="" /><Z><S><S X="250" o="0" L="150" Y="300" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="-20" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="540" o="0" L="150" Y="300" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="820" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="690" o="ff0000" L="300" Y="400" H="300" P="0,0,0.3,0.2,-10,0,0,0" T="12" /><S X="700" o="0" L="100" Y="100" c="3" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="110" o="ff0000" L="300" Y="400" H="300" P="0,0,0.3,0.2,10,0,0,0" T="12" /><S X="100" o="0" L="100" Y="100" c="3" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="400" o="ff0000" L="150" Y="150" c="1" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /></S><D><DC X="700" Y="85" /><DS X="100" Y="85" /></D><O><O C="13" X="540" P="0" Y="300" /><O C="12" X="260" P="0" Y="300" /></O></Z></C>'}
maps["teams_win_4"]		= {author = "Pshy#3752", replace_func = ReplaceRedToWinningColor, xml = '<C><P Ca="" mc="" /><Z><S><S X="-20" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="820" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="820" o="ff0000" L="100" Y="240" H="300" P="0,0,0.3,0.2,10,0,0,0" T="12" /><S X="400" o="0" L="100" Y="100" c="3" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="-20" o="ff0000" L="100" Y="240" H="300" P="0,0,0.3,0.2,-10,0,0,0" T="12" /><S X="400" o="0" L="150" Y="200" c="3" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="620" o="ff0000" L="150" Y="250" c="1" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="400" o="0" L="200" Y="300" c="3" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="180" o="ff0000" L="150" Y="250" c="1" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /></S><D><DC X="400" Y="190" /><DS X="400" Y="85" /></D><O><O C="12" X="620" P="0" Y="250" /><O C="13" X="180" P="0" Y="250" /></O></Z></C>'}
rotations["teams_win"]	= {desc = "P0", duration = 30, items = {"teams_win_1", "teams_win_2", "teams_win_3", "teams_win_4"}}



--- pshy event eventTeamWon.
function eventTeamWon(team_name)
	local team = pshy.teams_GetTeam(team_name)
	for i_team, team in ipairs(pshy.teams) do
		if team.name == team_name then
			pshy.teams_winner_index = i_team
			break
		end
	end
	tfm.exec.setGameTime(8, true)
	print("team won")
	utils_messages.Title("<br><font size='64'><b><p align='center'>Team <font color='#" .. team.color .. "'>" .. team.name .. "</font> wins!</p></b></font>")
	pshy.teams_have_played_winner_round = false
	pshy.newgame_SetNextMap(pshy.teams_win_map)
end



function eventNewGame()
	if pshy.teams_winner_index then
		if not pshy.teams_have_played_winner_round then
			-- winner round
			pshy.teams_have_played_winner_round = true
			tfm.exec.setGameTime(13, true)
			local winner_team = pshy.teams_GetTeam(pshy.teams_winner_index)
			for player_name, void in pairs(winner_team.player_names) do
				tfm.exec.setShaman(player_name, true)
			end
			pshy.newgame_SetNextMap("lobby")
		else
			-- first round of new match
			pshy.teams_winner_index = nil
			pshy.teams_have_played_winner_round = false
			pshy.teams_ResetScores()
		end
	end
	utils_messages.Title(nil)
end



function eventPlayerWon(player_name)
	tfm.exec.setGameTime(5, false)
end



function eventPlayerDied(player_name)
	if utils_tfm.CountPlayersAlive() == 0 then
		tfm.exec.setGameTime(5, false)
	end
end



--- Initialization
pshy.teams_Reset(4)
pshy.teams_Shuffle()
pshy.teams_UpdateScoreboard()
