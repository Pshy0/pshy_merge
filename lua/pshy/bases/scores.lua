--- pshy.bases.scores
--
-- Provide customisable player scoring.
-- Adds an event "eventPlayerScore(player_name, points)".
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.bases.doc")
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")
pshy.require("pshy.ui.v1")



--- Namespace.
local scores = {}



--- TFM Settings
tfm.exec.disableAutoScore(true)



--- Module Help Page.
--help_pages["pshy_scores"] = {back = "pshy", title = "Scores", text = "This module allows to customize how players make score points.\n", commands = {}}
--help_pages["pshy"].subpages["pshy_scores"] = help_pages["pshy_scores"]



--- Module Settings.
scores.per_win = 0								-- points earned per wins
scores.per_first_wins = {}						-- points earned by the firsts to win
--scores.per_first_wins[1] = 1					-- points for the very first
scores.per_cheese = 0							-- points earned per cheese touched
scores.per_first_cheeses = {}					-- points earned by the firsts to touch the cheese
scores.per_death = 0							-- points earned by death
scores.per_first_deaths = {}					-- points earned by the very first to die
scores.survivors_win = false					-- this round is a survivor round (players win if they survive) (true or the points for surviving)
scores.ui_arbitrary_id = 2918					-- arbitrary ui id
scores.show = true								-- show stats for the map
scores.per_bonus = 0							-- points earned by gettings bonuses of id <= 0
scores.reset_on_leave = true					-- reset points on leave



--- Internal use.
scores.scores = {}						-- total scores points per player
scores.firsts_win = {}				-- total firsts points per player
scores.round_wins = {}				-- current map's first wins
scores.round_cheeses = {}			-- current map's first cheeses
scores.round_deaths = {}			-- current map's first deathes
scores.round_ended = true			-- the round already ended (now counting survivors, or not counting at all)
scores.should_update_ui = false	-- if true, scores ui have to be updated



--- pshy event eventPlayerScore
-- Called when a player earned points according to the module configuration.
function eventPlayerScore(player_name, points)
	tfm.exec.setPlayerScore(player_name, scores.scores[player_name], false)
end



--- Give points to a player
function scores.Add(player_name, points)
	scores.scores[player_name] = scores.scores[player_name] + points
	eventPlayerScore(player_name, points)
end



--- Give points to a player
function scores.Set(player_name, points)
	scores.scores[player_name] = points
	tfm.exec.setPlayerScore(player_name, scores.scores[player_name], false)
end



--- Update the top players scores ui
-- @param player_name optional player who will see the changes
local function ScoresUpdateRoundTop(player_name)
	if ((#scores.round_wins + #scores.round_cheeses + #scores.round_deaths) == 0) then
		return
	end
	local text = "<font size='10'><p align='left'>"
	if #scores.round_wins > 0 then
		text = text .. "<font color='#ff0000'><b> First Win: " .. scores.round_wins[1] .. "</b></font>\n"
	end
	if #scores.round_cheeses > 0 then
		text = text .. "<d><b> First Cheese: " .. scores.round_cheeses[1] .. "</b></d>\n"
	end
	if #scores.round_deaths > 0 then
		text = text .. "<bv><b> First Death: " .. scores.round_deaths[1] .. "</b></bv>\n"
	end
	text = text .. "</p></font>"
	local title = pshy.UICreate(text)
	title.id = scores.ui_arbitrary_id
	title.x = 810
	title.y = 30
	title.w = nil
	title.h = nil
	title.back_color = 0
	title.border_color = 0
	pshy.UIShow(title, player_name)
end



--- Reset a player scores
function scores.ResetPlayer(player_name)
	assert(type(player_name) == "string")
	scores.scores[player_name] = 0
	scores.firsts_win[player_name] = 0
	tfm.exec.setPlayerScore(player_name, 0, false)
end



--- Reset all players scores
function scores.ResetPlayers()
	scores.scores = {}
	for player_name, player in pairs(tfm.get.room.playerList) do
		scores.ResetPlayer(player_name)
	end
end



--- TFM event eventNewGame
function eventNewGame()
	scores.round_wins = {}
	scores.round_cheeses = {}
	scores.round_deaths = {}
	scores.round_ended = false
	scores.should_update_ui = false
	ui.removeTextArea(scores.ui_arbitrary_id, nil)
end



--- TFM event eventLoop
function eventLoop(time, time_remaining)
	-- update score if needed
	if scores.show and scores.should_update_ui then
		ScoresUpdateRoundTop()
		scores.should_update_ui = false
	end
	-- make players win at the end of survivor rounds
	if time_remaining < 1000 and scores.survivors_win ~= false then
		scores.round_ended = true
		for player_name, player in pairs(tfm.get.room.playerList) do
			tfm.giveCheese(player_name, true)
			tfm.playerVictory(player_name)
		end
	end
end



--- TFM event eventPlayerDied
function eventPlayerDied(player_name)
	if not scores.round_ended then
		local points = scores.per_death
		table.insert(scores.round_deaths, player_name)
		local rank = #scores.round_deaths
		if scores.per_first_deaths[rank] then
			points = points + scores.per_first_deaths[rank]
		end
		if points ~= 0 then
			scores.Add(player_name, points)
		end
	end
	scores.should_update_ui = true
end



--- TFM event eventPlayerGetCheese
function eventPlayerGetCheese(player_name)
	if not scores.round_ended then
		local points = scores.per_cheese
		table.insert(scores.round_cheeses, player_name)
		local rank = #scores.round_cheeses
		if scores.per_first_cheeses[rank] then
			points = points + scores.per_first_cheeses[rank]
		end
		if points ~= 0 then
			scores.Add(player_name, points)
		end
	end
	scores.should_update_ui = true
end



--- TFM event eventPlayerLeft
function eventPlayerLeft(player_name)
	if scores.reset_on_leave then
		scores.scores[player_name] = 0
	end
end



--- TFM event eventPlayerWon
function eventPlayerWon(player_name, time_elapsed)
	local points = 0
	if scores.round_ended and scores.survivors_win ~= false then
		-- survivor round
		points = points + ((scores.survivors_win == true) and scores.per_win or scores.survivors_win)
	elseif not scores.round_ended then
		-- normal
		points = points + scores.per_win
		table.insert(scores.round_wins, player_name)
		local rank = #scores.round_wins
		if scores.per_first_wins[rank] then
			points = points + scores.per_first_wins[rank]
		end
		if rank == 1 then
			scores.firsts_win[player_name] = scores.firsts_win[player_name] + points
		end
	end
	if points ~= 0 then
		scores.Add(player_name, points)
	end
	scores.should_update_ui = true
end



--- TFM event eventPlayerBonusGrabbed
function eventPlayerBonusGrabbed(player_name, bonus_id)
	if scores.per_bonus ~= 0 then
		scores.Add(player_name, scores.per_bonus)
	end
end



--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	if not scores.scores[player_name] then
		scores.ResetPlayer(player_name)
	else
		tfm.exec.setPlayerScore(player_name, scores.scores[player_name], false)
	end
end



--- Initialization
scores.ResetPlayers()



return scores
