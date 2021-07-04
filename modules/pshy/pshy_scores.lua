--- pshy_scores.lua
--
-- Provide customisable player scoring.
-- Adds an event "eventPlayerScore(player_name, points)".
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_utils.lua
-- @require pshy_ui.lua
-- @require pshy_help.lua



--- Module Help Page.
pshy.help_pages["pshy_scores"] = {back = "pshy", text = "This module allows to customize how players make score points.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_scores"] = pshy.help_pages["pshy_scores"]



--- Module Settings.
pshy.scores_per_win = 0				-- points earned by wins
pshy.scores_per_first_wins = {}			-- points earned by the firsts to win
pshy.scores_per_firsts[1] = 1				-- points for the very first
--pshy.teams_cheese_gathered_firsts_points[2] = 1	-- points for the second...
pshy.scores_per_cheese = 0				-- points earned per cheese touched
pshy.scores_per_first_cheeses = {}			-- points earned by the firsts to touch the cheese
pshy.scores_per_death = 0				-- points earned by death
pshy.scores_per_first_deaths = {}			-- points earned by the very first to die
pshy.scores_survivors_win = false			-- this round is a survivor round (players win if they survive) (true or the points for surviving)
pshy.scores_ui_arbitrary_id = 2918			-- arbitrary ui id
pshy.scores_show = true				-- show stats for the map



--- Internal use.
pshy.scores = {}					-- total scores points per player
pshy.scores_round_wins = {}				-- current map's first wins
pshy.scores_round_cheeses = {}			-- current map's first cheeses
pshy.scores_round_deaths = {}				-- current map's first deathes
pshy.scores_round_ended = true			-- the round already ended (now counting survivors, or not counting at all)
pshy.scores_ui_update_requested = false		--



--- pshy event eventPlayerScore
-- Called when a player earned points according to the module configuration.
function eventPlayerScore(player_name, points)
	tfm.exec.chatMessage(player_name .. " earned " .. tostring(points).. " points!", nil)
end



--- Update the top players scores ui
function ScoresUpdateRoundTop()
	if ((pshy.scores_round_wins + pshy.scores_round_cheeses + pshy.scores_round_deathes) == 0) then
		return
	end
	local text = "<font size='16'><p align='center'>"
	if #pshy.scores_round_cheeses > 0 then
		text = text .. "<d><b> Cheese First: " .. pshy.scores_round_cheeses[1] .. "</b></d>\n"
	end
	if #pshy.scores_round_wins > 0 then
		text = text .. "<ch2><b> First Win: " .. pshy.scores_round_wins[1] .. "</b></ch2>\n"
	end
	if #pshy.scores_round_deaths > 0 then
		text = text .. "<bv><b> First death: " .. pshy.scores_round_deaths[1] .. "</b></bv>\n"
	end
	text = text .. "</p>"
	local title = pshy.UICreate(text)
	title.x = 0
	title.y = 40
	title.w = 800
	title.h = nil
	title.back_color = 0
	title.border_color = 0
	pshy.UIShow(title)
end



--- Reset a player scores
function pshy.ScoresResetPlayer(player_name)
	assert(type(player_name) == "string")
	pshy.scores[player_name] = 0
end



--- Reset all players scores
function pshy.ScoresResetPlayers()
	for player_name, player in pairs(tfm.get.room.playerList) do
		pshy.scoresResetPlayer(player_name)
	end
end



--- TFM event eventNewGame
function eventNewGame()
	pshy.scores_round_wins = {}
	pshy.scores_round_deaths = {}
	pshy.scores_round_ended = false
	pshy.scores_ui_update_requested = false
	ui.removeTextArea(pshy.scores_ui_arbitrary_id, nil)
end



--- TFM event eventLoop
function eventLoop(time, time_remaining)
	-- make players win at the end of survivor rounds
	if time_remaining < 1000 and pshy.scores_survivors_win ~= false then
		pshy.scores_round_ended = true
		for player_name, player in pairs(tfm.get.room.playerList) do
			tfm.giveCheese(player_name, true)
			tfm.playerVictory(player_name)
		end
	end
end



--- TFM event eventPlayerDied
function eventPlayerDied(player_name)
	if not pshy.scores_round_ended then
		local points = pshy.scores_per_death
		table.insert(pshy.scores_round_deaths, player_name)
		local rank = #pshy.scores_round_deaths
		if pshy.scores_per_first_deaths[rank] then
			points = points + pshy.scores_per_first_deaths[rank]
		end
		if points ~= 0 then
			eventPlayerScore(player_name, points)
		end
	end
	pshy.scores_ui_update_requested = true
end



--- TFM event eventPlayerGetCheese
function eventPlayerGetCheese(playerName)
	if not pshy.scores_round_ended then
		local points = pshy.scores_per_cheese
		table.insert(pshy.scores_round_cheeses, player_name)
		local rank = #pshy.scores_round_cheeses
		if pshy.scores_per_first_cheeses[rank] then
			points = points + pshy.scores_per_first_cheeses[rank]
		end
		if points ~= 0 then
			eventPlayerScore(player_name, points)
		end
	end
	pshy.scores_ui_update_requested = true
end



--- TFM event eventPlayerLeft
--function eventPlayerLeft(playerName)
--end



--- TFM event eventPlayerWon
function eventPlayerWon(player_name, time_elapsed)
	local points = 0
	if pshy.scores_round_ended and pshy.scores_survivors_win ~= false then
		-- survivor round
		points = points + ((pshy.scores_survivors_win == true) and pshy.scores_per_win or pshy.scores_survivors_win)
	elseif not pshy.scores_round_ended then
		-- normal
		points = points + pshy.scores_per_win
		table.insert(pshy.scores_round_wins, player_name)
		local rank = #pshy.scores_round_wins
		if pshy.scores_per_first_wins[rank] then
			points = points + pshy.scores_per_first_wins[rank]
		end
	end
	if points ~= 0 then
		eventPlayerScore(player_name, points)
	end
	pshy.scores_ui_update_requested = true
end



--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	pshy.ScoresResetPlayer(player_name)
end



--- Initialization
pshy.ScoresResetPlayers()
