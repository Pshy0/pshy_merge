--- pshy_emotes.lua
--
-- Allow players to use some of the consumable emotes for free using F8-F12 keys.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_merge.lua
--
-- @require_priority UTILS



local function TouchPlayer(player_name)
	system.bindKeyboard(player_name, 119, true, true)
	system.bindKeyboard(player_name, 120, true, true)
	system.bindKeyboard(player_name, 121, true, true)
	system.bindKeyboard(player_name, 122, true, true)
	system.bindKeyboard(player_name, 123, true, true)
end



function eventKeyboard(player_name, key_code)
	if key_code >= 119 and key_code <= 123 then
		if key_code == 119 then
			tfm.exec.playEmote(player_name, tfm.enum.emote.marshmallow)
		elseif key_code == 120 then
			tfm.exec.playEmote(player_name, tfm.enum.emote.selfie)
		elseif key_code == 121 then
			tfm.exec.playEmote(player_name, tfm.enum.emote.partyhorn)
		elseif key_code == 122 then
			tfm.exec.playEmote(player_name, tfm.enum.emote.jigglypuff)
		elseif key_code == 123 then
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
