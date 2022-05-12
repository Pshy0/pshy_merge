--- pshy_thebestshaman.lua
--
-- Who is the best shaman?
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_essentials.lua
-- @require pshy_emoticons.lua
-- @require pshy_imagedb_misc.lua
-- @require pshy_merge.lua
-- @require pshy_motd.lua
-- @require pshy_newgame.lua
-- @require pshy_perms.lua
-- @require pshy_players.lua
-- @require pshy_players_alive.lua
-- @require pshy_ui.lua
-- @require pshy_version.lua



--- help Page:
pshy.help_pages["thebestshaman"] = {back = "", title = "The Best Shaman", text = "PRO shamans only!", commands = {}}
pshy.help_pages[""].subpages["thebestshaman"] = pshy.help_pages["thebestshaman"]



--- TFM Settings:
tfm.exec.disableAutoNewGame(true)



--- Pshy Settings:
pshy.loadersync_enabled = true



--- Internal Use:
local arbitrary_rating_background_id = 75
local arbitrary_rating_text_area_id = 76
-- Usable symbols: ⚒⚡★⚙♥
local gauges = {
	{name = "Efficiency", symbol = "⚒", color = "#ffff00"};
	{name = "Ingeniosity", symbol = "⚙", color = "#00ffff"};
	{name = "Cuteness", symbol = "♥", color = "#ff00ff"};
}
local ratings = {}
local is_rating_time = false
local shaman_name = nil



--- Get the text to to show for a player to rate the shaman.
local function GetRatingText(player_name)
	local player_ratings = (player_name and ratings[player_name]) or {}
	local text = "\n<p align='center'><font size='24'><font face='Ubuntu'>"
	for i_gauge, gauge in ipairs(gauges) do
		text = text .. string.format("<font color='%s'>%s\n", gauge.color, gauge.name)
		local rank = player_ratings[i_gauge] or 0
		for i = 1,rank do
			text = text .. string.format(" <a href='event:pcmd rank %d %d'>%s</a> ", i_gauge, i, gauge.symbol)
		end
		text = text .. "</font>"
		for i = rank+1,5 do
			text = text .. string.format(" <a href='event:pcmd rank %d %d'>%s</a> ", i_gauge, i, gauge.symbol)
		end
		text = text .. "\n\n"
	end
	return text .. "</font></font></p>"
end



--- Print the shaman's rank in the chat.
local function PrintResults()
	tfm.exec.chatMessage(string.format("<n><b>Rank for <ch>%s</ch>:</b></n>", shaman_name))
	local votes = {}
	local total = {}
	for i_gauge, gauge in ipairs(gauges) do
		votes[i_gauge] = 0
		total[i_gauge] = 0
	end
	for player, player_ratings in pairs(ratings) do
		for i_rating, rating in pairs(player_ratings) do
			votes[i_rating] = votes[i_rating] + 1
			total[i_rating] = total[i_rating] + rating
		end
	end
	for i_gauge, gauge in ipairs(gauges) do
		local rank = total[i_gauge] / votes[i_gauge]
		tfm.exec.chatMessage(string.format("<font color='%s'>%s\t%.2f\t(%d votes)</font>", gauge.color, gauge.symbol, math.ceil(rank * 10) /10, votes[i_gauge]))
	end
end



local function ShowRatingTextArea()
	local text = GetRatingText(nil);
	ui.addTextArea(arbitrary_rating_background_id, "", nil, 200, 75, 400, 250, 0x000001, nil, 0.5, false)
	ui.addTextArea(arbitrary_rating_text_area_id, text, nil, 200, 75, 400, 250, 0x000000, nil, nil, false)
end



function eventNewGame()
	ratings = {}
	is_rating_time = false
	for player_name, player in pairs(tfm.get.room.playerList) do
		if player.isShaman then
			shaman_name = player_name
		end
	end
end



function eventLoop(time, time_remaining)
	if time_remaining <= 0 then
		if not is_rating_time then
			is_rating_time = true
			tfm.exec.setGameTime(10, true)
			ShowRatingTextArea()
		else
			tfm.exec.setGameTime(10, true)
			ui.removeTextArea(arbitrary_rating_background_id)
			ui.removeTextArea(arbitrary_rating_text_area_id)
			PrintResults()
			tfm.exec.newGame()
		end
	end
end



function eventPlayerDied()
	if pshy.players_alive_count <= 0 then
		if not is_rating_time then
			is_rating_time = true
			tfm.exec.setGameTime(10, true)
			ShowRatingTextArea()
		end
	end
end



--- !rank <i_gauge> <rank>
local function ChatCommandRank(user, i_gauge, rank)
	if not gauges[i_gauge] then
		return false, "Invalid gauge."
	end
	if rank < 1 or rank > 5 then
		return false, "The rank must be between 1 and 5 (included)."
	end
	if user == shaman_name then
		return false, "You cannot vote for yourself."
	end
	if not ratings[user] then
		ratings[user] = {}
	end
	ratings[user][i_gauge] = rank
	ui.updateTextArea(arbitrary_rating_text_area_id, GetRatingText(user), user)
	return true
end
pshy.commands["rank"] = {func = ChatCommandRank, desc = "rank the shaman", argc_min = 2, argc_max = 2, arg_types = {"number", "number"}}
pshy.help_pages["thebestshaman"].commands["rank"] = pshy.commands["rank"]
pshy.perms.everyone["!rank"] = true



function eventInit()
	pshy.newgame_SetRotation("P4")
	tfm.exec.chatMessage("<fc>The Best Shaman</fc>", pshy.loader)
	tfm.exec.newGame()
end
