--- pshy.games.thebestshaman
--
-- Who is the best shaman?
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.alternatives.chat")
pshy.require("pshy.bases.emoticons")
pshy.require("pshy.bases.version")
pshy.require("pshy.commands")
local command_list = pshy.require("pshy.commands.list")
pshy.require("pshy.help")
pshy.require("pshy.commands.list.modules")
pshy.require("pshy.commands.list.players")
pshy.require("pshy.essentials")
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")
pshy.require("pshy.images.list.misc")
local players = pshy.require("pshy.players")
local player_list = players.list			-- optimization
pshy.require("pshy.players.alive")
local newgame = pshy.require("pshy.rotations.newgame")
pshy.require("pshy.tools.motd")
pshy.require("pshy.ui.v1")
local room = pshy.require("pshy.room")



--- help Page:
help_pages["thebestshaman"] = {back = "", title = "The Best Shaman", text = "PRO shamans only!", commands = {}}
help_pages[""].subpages["thebestshaman"] = help_pages["thebestshaman"]



--- TFM Settings:
tfm.exec.disableAutoNewGame(true)



--- Internal Use:
local arbitrary_rating_background_id = 75
local arbitrary_rating_text_area_id = 76
-- Usable symbols: ⚒⚡★⚙♥⚖♞☁☀
local gauges_default = {
	{name = "Efficiency", symbol = "⚒", color = "#ffff00"};
	{name = "Ingeniosity", symbol = "⚙", color = "#00ffff"};
	{name = "Cuteness", symbol = "♥", color = "#ff00ff"};
}
local gauges_1stapril = {
	{name = "Style", symbol = "☀", color = "#ff8080"};
	{name = "Lazyness", symbol = "☁", color = "#8080ff"};
	{name = "Stupidity", symbol = "♞", color = "#80ff80"};
}
local gauges = gauges_default
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
	if shaman_name then
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
			tfm.exec.chatMessage(string.format("<font color='%s'>%s %12s\t%.2f\t(%d votes)</font>", gauge.color, gauge.symbol, gauge.name, math.ceil(rank * 10) /10, votes[i_gauge]))
		end
	end
end



local function ShowRatingTextArea()
	local text = GetRatingText(nil);
	ui.addTextArea(arbitrary_rating_background_id, "", nil, 200, 75, 400, 250, 0x000001, nil, 0.5, true)
	ui.addTextArea(arbitrary_rating_text_area_id, text, nil, 200, 75, 400, 250, 0x000000, nil, nil, true)
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
	if players.alive_count <= 0 then
		if not is_rating_time then
			is_rating_time = true
			tfm.exec.setGameTime(10, true)
			ShowRatingTextArea()
		end
	end
end



function eventPlayerWon()
	if players.alive_count <= 0 then
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
	if players.in_room_count > 1 and user == shaman_name then
		return false, "You cannot vote for yourself."
	end
	if not ratings[user] then
		ratings[user] = {}
	end
	ratings[user][i_gauge] = rank
	ui.updateTextArea(arbitrary_rating_text_area_id, GetRatingText(user), user)
	return true
end
command_list["rank"] = {perms = "everyone", func = ChatCommandRank, desc = "rank the shaman", argc_min = 2, argc_max = 2, arg_types = {"number", "number"}}
help_pages["thebestshaman"].commands["rank"] = command_list["rank"]



--- !ranknameset <n>
local function ChatCommandRanknameset(user, i_set)
	if i_set < 1 or i_set > 2 then
		return false, "Invalid set."
	end
	if i_set == 1 then
		gauges = gauges_default
	else
		gauges = gauges_1stapril
	end
	return true
end
command_list["ranknameset"] = {perms = "admins", func = ChatCommandRanknameset, desc = "set the rank names set", argc_min = 1, argc_max = 1, arg_types = {"number"}}
help_pages["thebestshaman"].commands["ranknameset"] = command_list["ranknameset"]



function eventInit()
	newgame.SetRotation("P4")
	tfm.exec.chatMessage("<fc>The Best Shaman</fc>", room.loader)
	tfm.exec.newGame()
end
