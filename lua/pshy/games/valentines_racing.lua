--- pshy.games.valentines_racing
--
-- Racing with soulmates must win together.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.alternatives.chat")
pshy.require("pshy.anticheats.ban")
pshy.require("pshy.anticheats.loadersync")
local antiemotespam = pshy.require("pshy.anticheats.antiemotespam", false)
local lobby = pshy.require("pshy.bases.lobby")
pshy.require("pshy.bases.new_player_ui_updates")
pshy.require("pshy.bases.version")
pshy.require("pshy.commands")
pshy.require("pshy.commands.list.game")
pshy.require("pshy.commands.list.players")
pshy.require("pshy.commands.list.modules")
pshy.require("pshy.commands.list.room")
pshy.require("pshy.commands.list.tfm")
pshy.require("pshy.events")
pshy.require("pshy.essentials.funcorp")
pshy.require("pshy.help")
help_pages = pshy.require("pshy.help.pages")
pshy.require("pshy.rotations.list.ctmce")
pshy.require("pshy.rotations.list.racing_vanilla")
pshy.require("pshy.rotations.list.racing_troll")
local newgame = pshy.require("pshy.rotations.newgame")
pshy.require("pshy.tools.fcplatform")
pshy.require("pshy.tools.motd")
pshy.require("pshy.tools.untrustedmaps")
pshy.require("pshy.utils.messages")
local players = pshy.require("pshy.players")
pshy.require("pshy.bases.events.soulmatechanged")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Valentines Racing"}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



local GetTarget = pshy.require("pshy.commands.get_target_or_error")



--newgame.update_map_name_on_new_player = true
newgame.delay_next_map = true
if antiemotespam then
	antiemotespam.max_emotes_per_game = 10
end



tfm.exec.disableDebugCommand(true)
tfm.exec.disablePhysicalConsumables(true)
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAfkDeath(true)
tfm.exec.disableAutoTimeLeft(true)
tfm.exec.disableAutoScore(true)
system.disableChatCommandDisplay(nil, true)
math.randomseed(os.time())



local mates = {}
local wished_mates = {}
local automate_player = nil
local player_scores = {}
local player_colors = {}



local current_round_number = -1
local initial_max_round_number = 5
local max_round_number = initial_max_round_number
local is_tie_break = false



local linked_map = false
local link_chance = 25



local background_color = 0xA34F9E



local function RandomColor()
	local rndv = math.random(0x00, 0xff)
	local rndc = math.random(1, 6)
	if rndc == 1 then
		return 0x0000ff + rndv * 0x000100
	elseif rndc == 2 then
		return 0x0000ff + rndv * 0x010000
	elseif rndc == 3 then
		return 0x00ff00 + rndv * 0x000001
	elseif rndc == 4 then
		return 0x00ff00 + rndv * 0x010000
	elseif rndc == 5 then
		return 0xff0000 + rndv * 0x000001
	else
		return 0xff0000 + rndv * 0x000100
	end
end



local function SetPlayerScore(player_name, score)
	player_scores[player_name] = score
	tfm.exec.setPlayerScore(player_name, score, false)
end



local function SetPlayerColor(player_name, color)
	player_colors[player_name] = color
	tfm.exec.setNameColor(player_name, color)
end



local function AddPlayerScore(player_name, score)
	player_scores[player_name] = (player_scores[player_name] or 0) + score
	tfm.exec.setPlayerScore(player_name, player_scores[player_name], false)
end



local function Title(text, player_name)
	if text == nil then
		ui.removeTextArea(23, player_name)
	else
		ui.addTextArea(23, "<font size='24'><fc><p align='center'>" .. text .. "</p></fc></font>", player_name, -1000, 40, 2800, nil, 0x010101, 0x000000, 0.6, true)
	end
end



local function SoulmateLabel(text, player_name)
	if text == nil then
		ui.removeTextArea(24, player_name)
	else
		ui.addTextArea(24, "<rose>" .. text .. "</rose>", player_name, 5, 378, nil, nil, 0x010101, 0x000000, 0.45, true)
	end
end



--- Get a score and pair of players with he best scores, or nil on tie.
local function BestScoreMates()
	local tie = false
	local best_score = -2
	local best_player = nil
	local tfm_player_list = tfm.get.room.playerList
	for player_name in pairs(tfm_player_list) do
		local mate_name = mates[player_name]
		if mate_name and tfm_player_list[mate_name] then
			if player_scores[player_name] > best_score then
				best_score = player_scores[player_name]
				best_player = player_name
			elseif player_scores[player_name] == best_score and mates[best_player] ~= player_name then
				tie = true
			end
		end
	end
	if tie then
		return best_score, nil, nil
	else
		return best_score, best_player, mates[best_player]
	end
end



--- Cause the player to loose their mate.
local function UnSetMate(player_name)
	SoulmateLabel("<r>You do not have a soulmate for this game.</r>", player_name)
	SetPlayerScore(player_name, 0)
	SetPlayerColor(player_name, 0x303030)
	assert(player_name)
	local mate_name = mates[player_name]
	mates[player_name] = nil
	if mate_name and mates[mate_name] == player_name then
		UnSetMate(mate_name)
	end
	Title("<r>You need a soulmate to play this game!</r>", player_name)
end



--- Set two players as mates.
-- This will also possibly remove their previous mate.
local function SetMates(player_name_1, player_name_2)
	if player_name_1 == player_name_2 then
		tfm.exec.chatMessage("<r>Well tried</r>", player_name_1)
		return
	end
	SetPlayerScore(player_name_1, 0)
	SetPlayerScore(player_name_2, 0)
	assert(player_name_1)
	local previous_mate_1 = mates[player_name_1]
	local previous_mate_2 = mates[player_name_2]
	mates[player_name_1] = player_name_2
	mates[player_name_2] = player_name_1
	if automate_player == player_name_1 or automate_player == player_name_2 then
		automate_player = nil
	end
	if player_name_1 == previous_mate_2 and player_name_2 == previous_mate_1 then
		return
	end
	if previous_mate_1 then
		UnSetMate(previous_mate_1)
		tfm.exec.chatMessage(string.format("<vi>Your soulmate <ch2>%s</ch2> has got rid of you.</vi>", player_name_1), previous_mate_1)
	end
	if previous_mate_2 then
		UnSetMate(previous_mate_2)
		tfm.exec.chatMessage(string.format("<vi>Your soulmate <ch2>%s</ch2> has got rid of you.</vi>", player_name_2), previous_mate_2)
	end
	Title(string.format("<rose>Your soulmate for this game will be <ch2>%s</ch2>.</rose>", player_name_1), player_name_2)
	Title(string.format("<rose>Your soulmate for this game will be <ch2>%s</ch2>.</rose>", player_name_2), player_name_1)
	SoulmateLabel("Your soulmate is <ch2>" .. player_name_2 .. "</ch2>", player_name_1)
	SoulmateLabel("Your soulmate is <ch2>" .. player_name_1 .. "</ch2>", player_name_2)
	local c = RandomColor()
	SetPlayerColor(player_name_1, c)
	SetPlayerColor(player_name_2, c)
end



local function TouchPlayer(player_name)
	player_scores[player_name] = 0
	local real_mate_name = tfm.get.room.playerList[player_name].spouseName
	tfm.exec.chatMessage("\n<fc><b>Wecome to Valentines Racing!</b></fc>\n", player_name)
	Title("<r>You need a soulmate to play this game!</r>", player_name)
	if real_mate_name then
		tfm.exec.chatMessage(string.format("<fc><b>You will be automatically matched with <vi>%s</vi> when they join.</b></fc>", real_mate_name), player_name)
	else
		tfm.exec.chatMessage("<fc><b>You will be automatically matched with your Transformice soulmate when they join.</b></fc>", player_name)
	end
	tfm.exec.chatMessage("<fc><b>To invite someone to be your soulmate, type `<vp>!mate Player#0000</vp>`.</b></fc>", player_name)
	tfm.exec.chatMessage("<fc><b>To find someone automatically, type `<vp>!automate</vp>`.</b></fc>\n", player_name)
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
	local tfm_player_list = tfm.get.room.playerList
	local real_mate_name = tfm_player_list[player_name].spouseName
	local mate_name = mates[player_name]
	if mate_name and tfm_player_list[mate_name] then
		tfm.exec.chatMessage(string.format("<vi>Your soulmate <ch2>%s</ch2> have returned!</vi>", player_name), mate_name)
		tfm.exec.chatMessage(string.format("<vi>Your soulmate <ch2>%s</ch2> didnt go away!</vi>", mate_name), player_name)
	end
	if real_mate_name and tfm_player_list[real_mate_name] and real_mate_name ~= mate_name then
		if not mates[player_name] and not mates[real_mate_name] then
			tfm.exec.chatMessage(string.format("<vi>Your real soulmate <ch2>%s</ch2> have joined you!</vi>", player_name), real_mate_name)
			tfm.exec.chatMessage(string.format("<vi>Your real soulmate <ch2>%s</ch2> was waiting for you!</vi>", real_mate_name), player_name)
			SetMates(player_name, real_mate_name)
		elseif mates[player_name] ~= mates[real_mate_name] then
			if mates[real_mate_name] then
				tfm.exec.chatMessage(string.format("<vi>Your real soulmate <ch2>%s</ch2> entered the room.</vi>", player_name), real_mate_name)
				tfm.exec.chatMessage(string.format("<vi>Your real soulmate <ch2>%s</ch2> is cheating on you with <r>%s</r>.</vi>", real_mate_name, mates[real_mate_name]), player_name)
			elseif mates[player_name] then
				tfm.exec.chatMessage(string.format("<vi>Your real soulmate <ch2>%s</ch2> is cheating on you with <r>%s</r>.</vi>", player_name, mates[player_name]), real_mate_name)
				tfm.exec.chatMessage(string.format("<vi>Your real soulmate <ch2>%s</ch2> entered the room.</vi>", real_mate_name), player_name)
			end
		end
	end
end



function eventSoulmateChanged(player_name, soulmate_name)
	if tfm.get.room.playerList[player_name] and tfm.get.room.playerList[soulmate_name] then
		if mates[player_name] ~= soulmate_name then
			if player_scores[player_name] <= 2 and player_scores[soulmate_name] <= 2 then
				tfm.exec.chatMessage(string.format("<vi>Congratulations to you and <ch2>%s</ch2>, you will be soulmates for this game!</vi>", player_name), soulmate_name)
				tfm.exec.chatMessage(string.format("<vi>Congratulations to you and <ch2>%s</ch2>, you will be soulmates for this game!</vi>", soulmate_name), player_name)
				Title(string.format("<rose>Your soulmate for this game will be <ch2>%s</ch2>.</rose>", player_name), soulmate_name)
				Title(string.format("<rose>Your soulmate for this game will be <ch2>%s</ch2>.</rose>", soulmate_name), player_name)
				SetMates(player_name, soulmate_name)
			else
				tfm.exec.chatMessage("<r>Your mate did not change for this game because either you or your new soulmate would loose their current score.</r>", player_name)
			end
		end
	end
end



function eventPlayerLeft(player_name)
	if mates[player_name] and tfm.get.room.playerList[mates[player_name]] then
		tfm.exec.chatMessage(string.format("<vi><ch2>%s</ch2> left the room. You will be able to resume playing if they come back.</vi>", player_name), mates[player_name])
		Title("<r>Your mate have just left the room.</r>", mates[player_name])
	end
end



function eventPlayerDied(player_name)
	if linked_map and mates[player_name] then
		tfm.exec.killPlayer(mates[player_name])
	end
end



local function Reset()
	is_tie_break = false
	current_round_number = -1
	max_round_number = initial_max_round_number
	local tfm_player_list = tfm.get.room.playerList
	for player_name in pairs(player_scores) do
		player_scores[player_name] = 0
	end
	for player_name in pairs(tfm.get.room.playerList) do
		SetPlayerScore(player_name, 0)
	end
end



function eventPlayerWon(player_name)
	local mate_name = mates[player_name]
	if not mate_name then
		tfm.exec.chatMessage("<r>Your score wont count until you find a soulmate.\nUse `!automate` to find one automatically, or `!mate <Player#NNNN>` if someone agreed to be yours.</r>", player_name)
		Title("<r>Your score wont count until you find a soulmate.</r>", player_name)
	elseif not map_have_winner then
		map_have_winner = true
		AddPlayerScore(player_name, 1)
		AddPlayerScore(mate_name, 1)
		tfm.exec.giveCheese(mate_name)
		tfm.exec.playerVictory(mate_name)
		Title(string.format("<rose>♥  <ch2><b>%s</b></ch2> scored for <ch2><b>%s</b></ch2>!  ♥</rose>", player_name, mate_name))
		tfm.exec.setGameTime(6, true)
		if current_round_number >= max_round_number then
			best_score, best_mate_1, best_mate_2 = BestScoreMates()
			if player_name == best_mate_1 or player_name == best_mate_2 then
				Title(string.format("<fc><b><rose>♥</rose>  <ch2><b>%s</b></ch2> and <ch2><b>%s</b></ch2> have won the game!  <rose>♥</rose></b></fc>", player_name, mate_name))
				lobby.message = string.format("%s and %s won the game!\nThey scored %d times over %d rounds!", player_name, mate_name, player_scores[player_name], current_round_number)
				Reset()
				tfm.exec.setGameTime(12, true)
				newgame.SetNextMap("lobby", true)
			end
		end
	end
end



function eventNewGame()
	ui.setBackgroundColor(string.format("#%6x", background_color)) --7F269C -- A34F9E -- 8F007C
	ui.setMapName("<rose>Valentines Racing</rose>")
	Title(nil)
	if newgame.current_map_identifying_name == "lobby" then
		linked_map = false
	else
		linked_map = math.random(1, 100) <= link_chance
	end
	local tfm_player_list = tfm.get.room.playerList
	for player_name, player in pairs(tfm_player_list) do
		if not mates[player_name] then
			Title("<r>You need a soulmate to play this game!</r>", player_name)
		elseif not tfm_player_list[mates[player_name]] then
			Title("<r>Your mate is not in the room anymore.</r>", player_name)
		else
			if player_colors[player_name] then
				tfm.exec.setNameColor(player_name, player_colors[player_name])
			end
			if linked_map then
				tfm.exec.linkMice(player_name, mates[player_name], true)
			else
				tfm.exec.linkMice(player_name, mates[player_name], false)
			end
		end
	end
	if current_round_number > 0 and not map_have_winner then
		max_round_number = max_round_number + 1
	end
	current_round_number = current_round_number + 1
	if not is_tie_break then
		local shaman_text = string.format("-   <g>|</g>   <n>Round: <v>%d</v> / %d</n>", current_round_number, max_round_number)
		ui.setShamanName(shaman_text)
	else
		local shaman_text = string.format("-   <g>|</g>   <n>Round: <v>%d</v>, <fc><b>Tie breaking!</b></fc></n>", current_round_number, max_round_number)
		ui.setShamanName(shaman_text)
	end
	if current_round_number >= max_round_number and not is_tie_break then
		is_tie_break = true
		tfm.exec.chatMessage("\n<fc><b>Tie break!</b></fc>")
		tfm.exec.chatMessage("<fc>The next valentines to score wins if they have the best score!</b></fc>\n")
	end
	map_have_winner = false
end



function eventInit()
	local tfm_player_list = tfm.get.room.playerList
	for player_name in pairs(tfm_player_list) do
		TouchPlayer(player_name)
		local real_mate_name = tfm_player_list[player_name].spouseName
		if real_mate_name then
			if tfm_player_list[real_mate_name] then
				tfm.exec.chatMessage(string.format("<vi>Your real soulmate <ch2>%s</ch2> is in the room!</vi>", real_mate_name), player_name)
				SetMates(player_name, real_mate_name)
			end
		end
	end
end


--- Automatically find a mate for a player, or add them as pending.
local function AutoMate(player_name)
	if automate_player == player_name then
		automate_player = nil
		return true, "You deleted your micetic profile. Better single?"
	end
	if automate_player == nil then
		automate_player = player_name
		return true, "You registered on micetic. I hope you find someone."
	end
	SetMates(player_name, automate_player)
	automate_player = nil
	return true, "It's a match!."
end



__MODULE__.commands = {
	["automate"] = {
		perms = "everyone",
		desc = "Automatically find a soulmate.",
		argc_min = 0,
		argc_max = 1,
		arg_types = {'player'},
		func = function(user, target)
			target = GetTarget(user, target, "!playerscore")
			return AutoMate(target)
		end
	},
	["mates"] = {
		perms = "admins",
		desc = "Force two players to become soulmates.",
		argc_min = 2,
		argc_max = 2,
		arg_types = {'player', 'player'},
		func = function(user, player_name_1, player_name_2)
			SetMates(player_name_1, player_name_2)
			tfm.exec.chatMessage(string.format("<vi>Your soulmate for this game is now <ch2>%s</ch2>!</vi>", player_name_1), player_name_2)
			tfm.exec.chatMessage(string.format("<vi>Your soulmate for this game is now <ch2>%s</ch2>!</vi>", player_name_2), player_name_1)
			return true, string.format("%s and %s have been hit by cupidon.", player_name_1, player_name_2)
		end
	},
	["rounds"] = {
		perms = "admins",
		aliases = {"d"},
		desc = "Choose how many rounds will play.",
		argc_min = 1,
		argc_max = 1,
		arg_types = {'number'},
		func = function(user, round_count)
			assert(round_count >= 1)
			max_round_number = round_count
			initial_max_round_number = round_count
			return true, "Updated target rounds."
		end
	},
	["linkchance"] = {
		perms = "admins",
		desc = "Set how often mice are linked (from 0 to 100).",
		argc_min = 0,
		argc_max = 1,
		arg_types = {'number'},
		arg_names = {"0-100"},
		func = function(user, rate)
			link_chance = rate
		end
	},
	["automates"] = {
		perms = "admins",
		desc = "Give single mice a mate.",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			count = 0
			for player_name in pairs(tfm.get.room.playerList) do
				if not mates[player_name] then
					count = count + 1
					AutoMate(player_name)
				end
			end
			return true, string.format("Cupidon have hit %d lone souls.", count)
		end
	},
	["getmate"] = {
		perms = "everyone",
		desc = "See who is the mate of someone.",
		argc_min = 0,
		argc_max = 1,
		arg_types = {'player'},
		func = function(user, target)
			target = target or user
			if mates[target] then
				return true, string.format("%s's soulmate is %s.", target, mates[target])
			else
				return true, string.format("%s's have no soulmate.", target)
			end
		end
	},
	["color"] = {
		perms = "everyone",
		desc = "Choose your team's color.",
		argc_min = 1,
		argc_max = 1,
		arg_types = {'color'},
		func = function(user, color)
			local target = target or user
			if mates[target] then
				SetPlayerColor(target, color)
				SetPlayerColor(mates[target], color)
			else
				return true, string.format("You need a soulmate to use this command.", target)
			end
		end
	},
	["backgroundcolor"] = {
		perms = "admins",
		desc = "Choose your team's color.",
		argc_min = 1,
		argc_max = 1,
		arg_types = {'color'},
		func = function(user, color)
			background_color = color
			ui.setBackgroundColor(string.format("#%6x", background_color))
		end
	},
	["reset"] = {
		perms = "admins",
		no_user = true,
		desc = "Reset scores, round number, and enter lobby.",
		argc_min = 0,
		argc_max = 0,
		func = function()
			Reset()
			tfm.exec.newGame("lobby")
		end
	},
	["mate"] = {
		perms = "everyone",
		desc = "Ask a player to be your soulmate.",
		argc_min = 1,
		argc_max = 1,
		arg_types = {'player'},
		func = function(user, player_name)
			if user == player_name then
				return false, "Well tried."
			end
			if automate_player == player_name or wished_mates[player_name] == user then
				if automate_player == player_name then
					automate_player = nil
				end
				wished_mates[player_name] = nil
				wished_mates[user] = nil
				SetMates(player_name, user)
				return true, string.format("Congratulations, your soulmate is now %s!", player_name, user)
			else
				wished_mates[user] = player_name
				return true, string.format("Waiting for %s to type `!mate %s`... Or not...", player_name, user)
			end
		end
	}
}



newgame.SetRotation("racing_p1_ctmce")
tfm.exec.newGame("lobby")
