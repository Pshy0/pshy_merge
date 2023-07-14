--- pshy.bases.emotes
--
-- Allow players to use some of the consumable emotes for free using LEFTBRACKET, EQUALS, SEMICOLON, F11 and F12 keys.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")



local function TouchPlayer(player_name)
	system.bindKeyboard(player_name, 122, true, true)
	system.bindKeyboard(player_name, 123, true, true)
	system.bindKeyboard(player_name, 219, true, true)
	system.bindKeyboard(player_name, 187, true, true)
	system.bindKeyboard(player_name, 186, true, true)
end



function eventKeyboard(player_name, key_code)
	if key_code >= 122 and key_code <= 219 then
		if key_code == 122 then
			tfm.exec.playEmote(player_name, tfm.enum.emote.marshmallow)
		elseif key_code == 123 then
			tfm.exec.playEmote(player_name, tfm.enum.emote.selfie)
		elseif key_code == 219 then
			tfm.exec.playEmote(player_name, tfm.enum.emote.partyhorn)
		elseif key_code == 187 then
			tfm.exec.playEmote(player_name, tfm.enum.emote.jigglypuff)
		elseif key_code == 186 then
			tfm.exec.playEmote(player_name, tfm.enum.emote.carnaval)
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
