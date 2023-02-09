--- pshy.games.soulmate_racing
--
-- Racing with soulmates must win together.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.alternatives.chat")
pshy.require("pshy.anticheats.ban")
pshy.require("pshy.anticheats.loadersync")
local antiemotespam = pshy.require("pshy.anticheats.antiemotespam", false)
local lobby = pshy.require("pshy.bases.lobby")
pshy.require("pshy.bases.version")
pshy.require("pshy.commands")
local command_list = pshy.require("pshy.commands.list")
pshy.require("pshy.commands.list.players")
pshy.require("pshy.commands.list.modules")
pshy.require("pshy.commands.list.room")
pshy.require("pshy.commands.list.tfm")
pshy.require("pshy.events")
pshy.require("pshy.help")
help_pages = pshy.require("pshy.help.pages")
pshy.require("pshy.rotations.list.troll")
pshy.require("pshy.rotations.list.vanillavs")
local newgame = pshy.require("pshy.rotations.newgame")
pshy.require("pshy.tools.fcplatform")
pshy.require("pshy.tools.motd")
pshy.require("pshy.utils.messages")
local players = pshy.require("pshy.players")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Soulmate Racing", commands = {}}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



local GetTarget = pshy.require("pshy.commands.get_target_or_error")



--newgame.update_map_name_on_new_player = true
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



local current_round_number = -1
local max_round_number = 5



local linked_map = false
local link_chance = 50



local function KillPlayer(player_name)
	tfm.exec.movePlayer(player_name, -100, 399)
	tfm.exec.killPlayer(player_name)
end



local function SetPlayerScore(player_name, score)
	player_scores[player_name] = score
	tfm.exec.setPlayerScore(player_name, score, false)
end



local function AddPlayerScore(player_name, score)
	player_scores[player_name] = (player_scores[player_name] or 0) + score
	tfm.exec.setPlayerScore(player_name, player_scores[player_name], false)
end



local function Title(text, player_name)
	if text == nil then
		ui.removeTextArea(23, player_name)
	else
		ui.addTextArea(23, "<font size='24'><fc><p align='center'>" .. text .. "</p></fc></font>", player_name, -1000, 40, 2800, nil, 0x010101, 0x000000, 0.6)
	end
end



--- Get a score and pair of players with he best scores, or nil on tie.
local function BestScoreMates()
	local tie = false
	local best_score = -2
	local best_player = nil
	for player_name in pairs(tfm.get.room.playerList) do
		local mate_name = mates[player_name]
		if mate_name and tfm.get.room.playerList[mate_name] then
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
	SetPlayerScore(player_name, 0)
	assert(player_name)
	local mate_name = mates[player_name]
	mates[player_name] = nil
	KillPlayer(player_name)
	if mate_name and mates[mate_name] == player_name then
		UnSetMate(mate_name)
		tfm.exec.chatMessage(string.format("<vi>Your left <ch2>%s</ch2>.</vi>", mate_name), player_name)
	else
		tfm.exec.chatMessage(string.format("<vi>Your soulmate <ch2>%s</ch2> has got rid of you.</vi>", player_name), mate_name)
	end
	Title("<r>You need a soulmate to play this game!</r>", player_name)
end



--- Set two players as mates.
-- This will also possibly remove their previous mate.
local function SetMates(player_name_1, player_name_2)
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
	end
	if previous_mate_2 then
		UnSetMate(previous_mate_2)
	end
	KillPlayer(player_name_1)
	KillPlayer(player_name_2)
	Title(string.format("<rose>Your soulmate for this game will be <ch2>%s</ch2></rose>.", player_name_1), player_name_2)
	Title(string.format("<rose>Your soulmate for this game will be <ch2>%s</ch2></rose>.", player_name_2), player_name_1)
end



local function TouchPlayer(player_name)
	player_scores[player_name] = 0
	local real_mate_name = tfm.get.room.playerList[player_name].spouseName
	tfm.exec.chatMessage("\n<fc><b>Wecome to Soulmate Racing!</b></fc>\n", player_name)
	Title("<r>You need a soulmate to play this game!</r>", player_name)
	if real_mate_name then
		tfm.exec.chatMessage(string.format("<fc><b>You will be automatically matched with <vi>%s</vi> when they join.</b></fc>", real_mate_name), player_name)
	else
		tfm.exec.chatMessage("<fc><b>You will be automatically matched with your Transformice soulmate when they join.</b></fc>", player_name)
	end
	tfm.exec.chatMessage("<fc><b>To invite someone to be your soulmate, type `<vp>!mate Player#0000</vp>`.</b></fc>", player_name)
	tfm.exec.chatMessage("<fc><b>To be automatically matched, type `<vp>!automate</vp>`.</b></fc>\n", player_name)
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
	local real_mate_name = tfm.get.room.playerList[player_name].spouseName
	local mate_name = mates[player_name]
	if mate_name and tfm.get.room.playerList[mate_name] then
		tfm.exec.chatMessage(string.format("<vi>Your soulmate <ch2>%s</ch2> have returned!</vi>", player_name), mate_name)
		tfm.exec.chatMessage(string.format("<vi>Your soulmate <ch2>%s</ch2> didnt go away!</vi>", mate_name), player_name)
	end
	if real_mate_name and tfm.get.room.playerList[real_mate_name] and real_mate_name ~= mate_name then
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



function eventPlayerLeft(player_name)
	if mates[player_name] then
		tfm.exec.chatMessage(string.format("<vi><ch2>%s</ch2> left the room. You will be able to resume playing if they come back.</vi>", player_name), mates[player_name])
	end
end



function eventPlayerDied(player_name)
	if linked_map and mates[player_name] then
		tfm.exec.killPlayer(mates[player_name])
	end
end



function eventPlayerWon(player_name)
	if not map_have_winner then
		local mate_name = mates[player_name]
		if mate_name then
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
					tfm.exec.setGameTime(12, true)
					lobby.message = string.format("%s and %s won the game!\nThey scored a total of %d points!", player_name, mate_name, player_scores[player_name])
					current_round_number = -1
					newgame.SetNextMap("lobby", true)
					for player_name in pairs(player_scores) do
						player_scores[player_name] = 0
					end
				end
			end
		end
	end
end



function eventNewGame()
	if newgame.current_map_identifying_name == "lobby" then
		linked_map = false
	else
		linked_map = math.random(1, 100) <= link_chance
	end
	Title(nil)
	map_have_winner = false
	for player_name, player in pairs(tfm.get.room.playerList) do
		if not mates[player_name] then
			Title("<r>You need a soulmate to play this game!</r>", player_name)
			KillPlayer(player_name)
		elseif not tfm.get.room.playerList[mates[player_name]] then
			Title("<r>Your mate is not in the room anymore.</r>", player_name)
			KillPlayer(player_name)
		else
			if linked_map then
				tfm.exec.linkMice(player_name, mates[player_name], true)
			else
				tfm.exec.linkMice(player_name, mates[player_name], false)
			end
		end
	end
	current_round_number = current_round_number + 1
	if current_round_number <= max_round_number then
		local shaman_text = string.format("-   <g>|</g>   <n>Round: <v>%d</v> / %d</n>", current_round_number, max_round_number)
		ui.setShamanName(shaman_text)
	else
		local shaman_text = string.format("-   <g>|</g>   <n>Round: <v>%d</v>, <fc><b>Tie breaking!</b></fc></n>", current_round_number, max_round_number)
		ui.setShamanName(shaman_text)
	end
	if current_round_number == max_round_number + 1 then
		tfm.exec.chatMessage("\n<fc><b>Tie break!</b></fc>")
		tfm.exec.chatMessage("<fc>The next duo to score wins if they have the best score!</b></fc>\n")
	end
end



function eventInit()
	for player_name in pairs(tfm.get.room.playerList) do
		TouchPlayer(player_name)
		local real_mate_name = tfm.get.room.playerList[player_name].spouseName
		if real_mate_name then
			if tfm.get.room.playerList[real_mate_name] then
				tfm.exec.chatMessage(string.format("<vi>Your soulmate <ch2>%s</ch2> is in the room!</vi>", real_mate_name), player_name)
				SetMates(player_name, real_mate_name)
			end
		end
	end
end



--- !mate
local function ChatCommandMate(user, player_name)
	if automate_player == player_name or wished_mates[player_name] == user then
		if automate_player == player_name then
			automate_player = nil
		end
		wished_mates[player_name] = nil
		wished_mates[user] = nil
		SetMates(player_name, user)
		return true, string.format("You found a soulmate.", player_name, user)
	else
		wished_mates[user] = player_name
		return true, string.format("Waiting for %s to type `!mate %s`.", player_name, user)
	end
end
command_list["mate"] = {perms = "everyone", func = ChatCommandMate, desc = "Ask a player to be your soulmate.", argc_min = 1, argc_max = 1, arg_types = {'player'}}
help_pages[__MODULE_NAME__].commands["mate"] = command_list["mate"]



--- Automatically find a mate for a player, or add them as pending.
local function AutoMate(player_name)
	if automate_player == player_name then
		automate_player = nil
		return true, "You are no longer looking for a mate."
	end
	if automate_player == nil then
		automate_player = player_name
		return true, "You are now looking for a mate."
	end
	SetMates(player_name, automate_player)
	automate_player = nil
	return true, "It's a match!."
end



--- !automate
local function ChatCommandAutomate(user, target)
	target = GetTarget(user, target, "!playerscore")
	return AutoMate(target)
end
command_list["automate"] = {perms = "everyone", func = ChatCommandAutomate, desc = "Automatically find a soulmate.", argc_min = 0, argc_max = 1, arg_types = {'player'}}
help_pages[__MODULE_NAME__].commands["automate"] = command_list["automate"]



--- !mates
local function ChatCommandMates(user, player_name_1, player_name_2)
	SetMates(player_name_1, player_name_2)
	tfm.exec.chatMessage(string.format("<vi>Your soulmate for this game is now <ch2>%s</ch2>!</vi>", player_name_1), player_name_2)
	tfm.exec.chatMessage(string.format("<vi>Your soulmate for this game is now <ch2>%s</ch2>!</vi>", player_name_2), player_name_1)
	return true, string.format("%s and %s have been hit by cupidon.", player_name_1, player_name_2)
end
command_list["mates"] = {perms = "admins", func = ChatCommandMates, desc = "Force two players to become soulmates.", argc_min = 2, argc_max = 2, arg_types = {'player', 'player'}}
help_pages[__MODULE_NAME__].commands["mates"] = command_list["mates"]



--- !rounds
local function ChatCommandRounds(user, round_count)
	SetMates(player_name_1, player_name_2)
	return true, "Updated target rounds."
end
command_list["rounds"] = {perms = "admins", func = ChatCommandRounds, desc = "Choose how many rounds will play.", argc_min = 1, argc_max = 1, arg_types = {'number'}}
help_pages[__MODULE_NAME__].commands["rounds"] = command_list["rounds"]



--- !linkchance
local function ChatCommandLinkchance(user, rate)
	link_chance = rate
end
command_list["linkchance"] = {perms = "admins", func = ChatCommandLinkchance, desc = "Set how often mice are linked (from 0 to 100).", argc_min = 0, argc_max = 1, arg_types = {'number'}, arg_names = {"0-100"}}
help_pages[__MODULE_NAME__].commands["linkchance"] = command_list["linkchance"]



--- !automates
local function ChatCommandAutomates(user)
	for player_name in pairs(tfm.get.room.playerList) do
		if not mates[player_name] then
			AutoMate(player_name)
		end
	end
end
command_list["automates"] = {perms = "admins", func = ChatCommandAutomates, desc = "Give eryone a mate.", argc_min = 0, argc_max = 0}
help_pages[__MODULE_NAME__].commands["automates"] = command_list["automates"]



newgame.SetRotation("vanilla_vs")
tfm.exec.newGame("lobby")
