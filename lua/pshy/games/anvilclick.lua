--- pshy.games.anvilclick
--
-- Allow mice to throw 	nvils by clicking.
-- This script can run as a standalone or be bundled with pshy_newgame.
--
-- @author TFM:Pshy#3752 DC:Pshy#3752
pshy.require("pshy.anticheats.loadersync")
pshy.require("pshy.bases.version")
pshy.require("pshy.events")
local newgame = pshy.require("pshy.rotations.newgame")



--- TFM Settings
tfm.exec.disableAutoShaman(true)



--- Internal Use
local objects_speed = 20
local player_object_ids = {}
local players_shot_time = {}
local shaman_item = tfm.enum.shamanObject.anvil
local more_than_3000_ms = false
local delay_between_shots = 1500



local function TouchPlayer(player_name)
	system.bindMouse(player_name, true)
end



function eventMouse(player_name, x, y)
	if not more_than_3000_ms then
		return
	end
	local time = os.time()
	if players_shot_time[player_name] and time - players_shot_time[player_name] < delay_between_shots then
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
	players_shot_time[player_name] = time
end



function eventLoop(time)
	if time > 3000 then
		more_than_3000_ms = true
	end
end



function eventNewGame()
	more_than_3000_ms = false
	player_object_ids = {}
	players_shot_time = {}
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
end



for player_name in pairs(tfm.get.room.playerList) do
	TouchPlayer(player_name)
end



function eventInit()
	if __IS_MAIN_MODULE__ then
		if newgame.SetRotation then
			newgame.SetRotation("vanilla")
			tfm.exec.newGame()
		end
		tfm.exec.chatMessage("===")
		tfm.exec.chatMessage("<b><o>Click to throw an anvil!</o></b>")
		tfm.exec.chatMessage("===")
	end
end
