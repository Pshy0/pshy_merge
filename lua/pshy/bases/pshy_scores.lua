--- pshy_scores.lua
--
-- Provide customisable player scoring.
-- Adds an event "eventPlayerScore(player_name, points)".
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_merge.lua
-- @require pshy_ui.lua



--- TFM Settings
tfm.exec.disableAutoScore(true)



--- Module Help Page.
--pshy.help_pages["pshy_scores"] = {back = "pshy", title = "Scores", text = "This module allows to customize how players make score points.\n", commands = {}}
--pshy.help_pages["pshy"].subpages["pshy_scores"] = pshy.help_pages["pshy_scores"]



--- Module Settings.
pshy.scores_per_win = 0								-- points earned per wins
pshy.scores_per_first_wins = {}						-- points earned by the firsts to win
--pshy.scores_per_first_wins[1] = 1					-- points for the very first
pshy.scores_per_cheese = 0							-- points earned per cheese touched
pshy.scores_per_first_cheeses = {}					-- points earned by the firsts to touch the cheese
pshy.scores_per_death = 0							-- points earned by death
pshy.scores_per_first_deaths = {}					-- points earned by the very first to die
pshy.scores_survivors_win = false					-- this round is a survivor round (players win if they survive) (true or the points for surviving)
pshy.scores_ui_arbitrary_id = 2918					-- arbitrary ui id
pshy.scores_show = true								-- show stats for the map
pshy.scores_per_bonus = 0							-- points earned by gettings bonuses of id <= 0
pshy.scores_reset_on_leave = true					-- reset points on leave



--- Internal use.
pshy.scores = {}						-- total scores points per player
pshy.scores_firsts_win = {}				-- total firsts points per player
pshy.scores_round_wins = {}				-- current map's first wins
pshy.scores_round_cheeses = {}			-- current map's first cheeses
pshy.scores_round_deaths = {}			-- current map's first deathes
pshy.scores_round_ended = true			-- the round already ended (now counting survivors, or not counting at all)
pshy.scores_should_update_ui = false	-- if true, scores ui have to be updated



--- pshy event eventPlayerScore
-- Called when a player earned points according to the module configuration.
function eventPlayerScore(player_name, points)
	tfm.exec.setPlayerScore(player_name, pshy.scores[player_name], false)
end



--- Give points to a player
function pshy.scores_Add(player_name, points)
	pshy.scores[player_name] = pshy.scores[player_name] + points
	eventPlayerScore(player_name, points)
end



--- Give points to a player
function pshy.scores_Set(player_name, points)
	pshy.scores[player_name] = points
	tfm.exec.setPlayerScore(player_name, pshy.scores[player_name], false)
end



--- Update the top players scores ui
-- @param player_name optional player who will see the changes
local function ScoresUpdateRoundTop(player_name)
	if ((#pshy.scores_round_wins + #pshy.scores_round_cheeses + #pshy.scores_round_deaths) == 0) then
		return
	end
	local text = "<font size='10'><p align='left'>"
	if #pshy.scores_round_wins > 0 then
		text = text .. "<font color='#ff0000'><b> First Win: " .. pshy.scores_round_wins[1] .. "</b></font>\n"
	end
	if #pshy.scores_round_cheeses > 0 then
		text = text .. "<d><b> First Cheese: " .. pshy.scores_round_cheeses[1] .. "</b></d>\n"
	end
	if #pshy.scores_round_deaths > 0 then
		text = text .. "<bv><b> First Death: " .. pshy.scores_round_deaths[1] .. "</b></bv>\n"
	end
	text = text .. "</p></font>"
	local title = pshy.UICreate(text)
	title.id = pshy.scores_ui_arbitrary_id
	title.x = 810
	title.y = 30
	title.w = nil
	title.h = nil
	title.back_color = 0
	title.border_color = 0
	pshy.UIShow(title, player_name)
end



--- Reset a player scores
function pshy.scores_ResetPlayer(player_name)
	assert(type(player_name) == "string")
	pshy.scores[player_name] = 0
	pshy.scores_firsts_win[player_name] = 0
	tfm.exec.setPlayerScore(player_name, 0, false)
end



--- Reset all players scores
function pshy.scores_ResetPlayers()
	pshy.scores = {}
	for player_name, player in pairs(tfm.get.room.playerList) do
		pshy.scores_ResetPlayer(player_name)
	end
end



--- TFM event eventNewGame
function eventNewGame()
	pshy.scores_round_wins = {}
	pshy.scores_round_cheeses = {}
	pshy.scores_round_deaths = {}
	pshy.scores_round_ended = false
	pshy.scores_should_update_ui = false
	ui.removeTextArea(pshy.scores_ui_arbitrary_id, nil)
end



--- TFM event eventLoop
function eventLoop(time, time_remaining)
	-- update score if needed
	if pshy.scores_show and pshy.scores_should_update_ui then
		ScoresUpdateRoundTop()
		pshy.scores_should_update_ui = false
	end
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
			pshy.scores_Add(player_name, points)
		end
	end
	pshy.scores_should_update_ui = true
end



--- TFM event eventPlayerGetCheese
function eventPlayerGetCheese(player_name)
	if not pshy.scores_round_ended then
		local points = pshy.scores_per_cheese
		table.insert(pshy.scores_round_cheeses, player_name)
		local rank = #pshy.scores_round_cheeses
		if pshy.scores_per_first_cheeses[rank] then
			points = points + pshy.scores_per_first_cheeses[rank]
		end
		if points ~= 0 then
			pshy.scores_Add(player_name, points)
		end
	end
	pshy.scores_should_update_ui = true
end



--- TFM event eventPlayerLeft
function eventPlayerLeft(player_name)
	if pshy.scores_reset_on_leave then
		pshy.scores[player_name] = 0
	end
end



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
		if rank == 1 then
			pshy.scores_firsts_win[player_name] = pshy.scores_firsts_win[player_name] + points
		end
	end
	if points ~= 0 then
		pshy.scores_Add(player_name, points)
	end
	pshy.scores_should_update_ui = true
end



--- TFM event eventPlayerBonusGrabbed
function eventPlayerBonusGrabbed(player_name, bonus_id)
	if pshy.scores_per_bonus ~= 0 then
		pshy.scores_Add(player_name, pshy.scores_per_bonus)
	end
end



--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	if not pshy.scores[player_name] then
		pshy.scores_ResetPlayer(player_name)
	else
		tfm.exec.setPlayerScore(player_name, pshy.scores[player_name], false)
	end
end



--- Initialization
pshy.scores_ResetPlayers()
