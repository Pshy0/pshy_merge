--- pshy.bases.emotes
--
-- Allow players to use some of the consumable emotes for free using LEFTBRACKET, EQUALS, SEMICOLON, F11 and F12 keys.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")



local player_times = {}



local function TouchPlayer(player_name)
	system.bindKeyboard(player_name, 122, true, true)
	system.bindKeyboard(player_name, 123, true, true)
	system.bindKeyboard(player_name, 219, true, true)
	system.bindKeyboard(player_name, 187, true, true)
	system.bindKeyboard(player_name, 186, true, true)
end



local function PlayEmote(player_name, emote_id)
	if player_times[player_name] and player_times[player_name] + 500 > os.time() then
		return
	end
	tfm.exec.playEmote(player_name, emote_id)
	player_times[player_name] = os.time()
end



function eventKeyboard(player_name, key_code)
	if key_code >= 122 and key_code <= 219 then
		if key_code == 122 then
			PlayEmote(player_name, tfm.enum.emote.marshmallow)
		elseif key_code == 123 then
			PlayEmote(player_name, tfm.enum.emote.selfie)
		elseif key_code == 219 then
			PlayEmote(player_name, tfm.enum.emote.partyhorn)
		elseif key_code == 187 then
			PlayEmote(player_name, tfm.enum.emote.jigglypuff)
		elseif key_code == 186 then
			PlayEmote(player_name, tfm.enum.emote.carnaval)
		end
	end
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
end



--- Init:
for player_name, player in pairs(tfm.get.room.playerList) do
	TouchPlayer(player_name)
end
