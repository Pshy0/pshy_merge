--- pshy.games.anvilclick
--
-- Allow mice to throw 	nvils by clicking.
-- This script can run as a standalone or be bundled with pshy_newgame.
--
-- @author TFM:Pshy#3752 DC:Pshy#3752
pshy.require("pshy.events")



--- TFM Settings
tfm.exec.disableAutoShaman(true)



--- Internal Use
local player_object_ids = {}
local objects_speed = 20
local players_who_shot_this_loop = {}
local shaman_item = tfm.enum.shamanObject.anvil



local function TouchPlayer(player_name)
	system.bindMouse(player_name, true)
end



function eventMouse(player_name, x, y)
	if players_who_shot_this_loop[player_name] then
		return
	end
	local tfm_player = tfm.get.room.playerList[player_name]
	if tfm_player.isDead or tfm_player.isShaman then
		return
	end
	if player_object_ids[player_name] then
		tfm.exec.removeObject(player_object_ids[player_name])
	end
	local vec_x = (x - tfm_player.x) / 10
	local vec_y = (y - tfm_player.y) / 10
	local magnitude = math.sqrt(vec_x * vec_x + vec_y * vec_y)
	vec_x = vec_x * objects_speed / magnitude
	vec_y = vec_y * objects_speed / magnitude
	player_object_ids[player_name] = tfm.exec.addShamanObject(shaman_item, tfm_player.x + vec_x, tfm_player.y + vec_y, 0, vec_x, vec_y)
	tfm.exec.playEmote(player_name, tfm.enum.emote.highfive_1, nil)
	players_who_shot_this_loop[player_name] = true
end



function eventLoop()
	players_who_shot_this_loop = {}
end



function eventNewGame()
	player_object_ids = {}
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
end



for player_name in pairs(tfm.get.room.playerList) do
	TouchPlayer(player_name)
end



function eventInit()
	if __IS_MAIN_MODULE__ then
		if pshy.newgame_SetRotation then
			pshy.newgame_SetRotation("vanilla")
			tfm.exec.newGame()
		end
		tfm.exec.chatMessage("===")
		tfm.exec.chatMessage("<b><o>Click to throw an anvil!</o></b>")
		tfm.exec.chatMessage("===")
	end
end
