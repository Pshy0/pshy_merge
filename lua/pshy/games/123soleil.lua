--- pshy.games.123soleil
--
-- Grandmother's footsteps game.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.anticheats.loadersync")
pshy.require("pshy.bases.alternatives")
pshy.require("pshy.bases.doc")
pshy.require("pshy.commands")
pshy.require("pshy.commands.list.players")
pshy.require("pshy.commands.list.modules")
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")



--- help Page:
help_pages["123soleil"] = {back = "", title = "123 Soleil", details = "Do not move when grandma watches you!\n", commands = {}}
help_pages[""].subpages["123soleil"] = help_pages["123soleil"]



--- TFM Settings:
tfm.exec.disableAutoNewGame(true)
tfm.exec.disableAllShamanSkills(true)



---  Internal use.
local sentence = string.lower("123 soleil")
local map_xml = [[<C><P F="2" Ca="" shaman_tools="1" MEDATA=";;2,1;;-0;0:::1-"/><Z><S><S T="6" X="400" Y="380" L="800" H="47" P="0,0,10,0.2,0,0,0,0"/><S T="4" X="770" Y="352" L="60" H="10" P="0,0,200,0.2,0,0,0,0"/></S><D><DC X="771" Y="337"/><T X="716" Y="357"/><F X="714" Y="351"/><DS X="25" Y="343"/></D><O><O X="179" Y="341" C="1" P="0"/><O X="543" Y="326" C="2" P="0"/><O X="372" Y="340" C="6" P="0"/></O><L/></Z></C>]]
local shaman = nil
local shaman_said_remaining = sentence
local shaman_said_soleil = false
local shaman_facing_left = false
local shaman_facing_right_time = os.time()
local moving_left = {}
local moving_right = {}
local first_player = nil



local function TouchPlayer(player_name)
	local player = tfm.get.room.playerList[player_name]
	moving_left[player_name] = 0
	moving_right[player_name] = 0
	tfm.exec.bindKeyboard(player_name, 0, true, true)
	tfm.exec.bindKeyboard(player_name, 0, false, true)
	tfm.exec.bindKeyboard(player_name, 1, true, true)
	tfm.exec.bindKeyboard(player_name, 1, false, true)
	tfm.exec.bindKeyboard(player_name, 2, true, true)
	tfm.exec.bindKeyboard(player_name, 2, false, true)
end



function eventChatMessage(player_name, message)
	if player_name == shaman and not shaman_facing_left then
		local updated_remaining_sentence = false
		message = string.lower(message)
		if message == sentence then
			shaman_said_remaining = ""
			updated_remaining_sentence = true
		elseif string.sub(shaman_said_remaining, 1, #message) == message then
			shaman_said_remaining = string.sub(shaman_said_remaining, #message + 1)
			updated_remaining_sentence = true
		elseif string.sub(message, 1, #shaman_said_remaining) == shaman_said_remaining then
			shaman_said_remaining = ""
			updated_remaining_sentence = true
		end
		while string.sub(shaman_said_remaining, 1, 1) == " " do
			shaman_said_remaining = string.sub(shaman_said_remaining, 2)
		end
		if shaman_said_remaining == "" then
			if (os.time() - shaman_facing_right_time) > 1000 then
				shaman_said_soleil = true
				tfm.exec.chatMessage(string.format("<j>Tu peux te retourner!</j>", sentence), player_name)
			else
				tfm.exec.chatMessage(string.format("<j>Attends au moins <r>une seconde</r>!</j>"), player_name)
			end
		else
			if updated_remaining_sentence then
				tfm.exec.chatMessage(string.format("<j>Il te reste a dire \"<ch2>%s</ch2>\"...</j>", shaman_said_remaining), player_name)
			end
		end
	end
end



function eventKeyboard(player_name, keycode, down)
	if player_name == shaman then
		if down and keycode == 0 then
			shaman_facing_left = true
			if shaman_said_soleil then
				for player_name, player in pairs(tfm.get.room.playerList) do
					if not player_name == shaman then
						if moving_left[player_name] or moving_right[player_name] then
							tfm.exec.killPlayer(player_name)
							tfm.exec.chatMessage(player_name .. " was moving :/")
						end
					end
				end
			else
				tfm.exec.chatMessage(string.format("<j>Tu n'as pas dit \"<ch2>%s</ch2>\"!</j>", sentence), player_name)
			end
		end
		if down and keycode == 2 then
			shaman_facing_left = false
			shaman_said_soleil = false
			shaman_said_remaining = sentence
			shaman_facing_right_time = os.time()
		end
	else
		if keycode == 0 then
			moving_left[player_name] = down and 1 or 0
		end
		if keycode == 2 then
			moving_right[player_name] = down and 1 or 0
		end
		if shaman_facing_left and shaman_said_soleil and keycode < 3 then
			tfm.exec.killPlayer(player_name)
			tfm.exec.chatMessage(player_name .. " moved :/")
		end
	end
end



function eventPlayerWon(player_name)
	if not first_player then
		first_player = player_name
		tfm.exec.chatMessage(string.format("<j><vp>%s</vp> est premier!</j>", player_name))
	end
end



local function CountPlayersAlive()
	local cnt = 0
	for player_name, player in pairs(tfm.get.room.playerList) do
		if not player.isDead then
			cnt = cnt + 1
		end
	end
	return cnt
end



function eventLoop(time)
	if time > 3000 and CountPlayersAlive() <= 1 then
		tfm.exec.newGame(map_xml)
	end
end



function eventNewGame()
	shaman = nil
	shaman_facing_left = false
	shaman_said_soleil = false
	shaman_said_remaining = sentence
	shaman_facing_right_time = os.time()
	first_player = nil
	for player_name, player in pairs(tfm.get.room.playerList) do
		if player.isShaman then
			shaman = player_name
			tfm.exec.setShaman(player_name, false)
		end
	end
	ui.setMapName(string.format("<fc>%s</fc>", sentence))
	tfm.exec.chatMessage(string.format("<ch>Restez immobiles lorsque <j>%s</j> dit \"<ch2>%s</ch2>\" et se retourne!</ch>", shaman, sentence))
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
end



--- !sentence <new_sentence>
local function ChatCommandSentence(user, new_sentence)
	sentence = string.lower(new_sentence)
end
command_list["sentence"] = {perms = "admins", func = ChatCommandSentence, desc = "Set the sentence grandma must say.", argc_min = 1, argc_max = 1, arg_types = {"string"}}
help_pages["123soleil"].commands["sentence"] = command_list["sentence"]



--- Init:
for player_name, player in pairs(tfm.get.room.playerList) do
	TouchPlayer(player_name)
end
tfm.exec.newGame(map_xml)
