--- pshy_changeimage.lua
--
-- Allow players to change their image.
--
-- @author TFM:Pshy#3752 DC:Pshy#3752
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_imagedb.lua
-- @require pshy_utils.lua



--- Module Help Page:
pshy.help_pages["pshy_changeimage"] = {back = "pshy", title = "Image Change", text = "Change your image.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_changeimage"] = pshy.help_pages["pshy_changeimage"]



--- Module Settings:
pshy.changesize_keep_changes_on_new_game = true



--- Internal Use:
pshy.changeimage_players = {}



--- Remove an image for a player.
function pshy.changeimage_RemoveImage(player_name)
	if pshy.changeimage_players[player_name].image_id then
		tfm.exec.removeImage(pshy.changeimage_players[player_name].image_id)
	end
	pshy.changeimage_players[player_name] = nil
	tfm.exec.changePlayerSize(player_name, 0.9)
	tfm.exec.changePlayerSize(player_name, 1.0)
end



--- Update a player's image.
function pshy.changeimage_UpdateImage(player_name)
	local player = pshy.changeimage_players[player_name]
	-- get draw settings
	local orientation = player.player_orientation or 1
	if not pshy.imagedb_IsOriented(player.image_name) then
		orientation = 1
	end
	-- skip if update not required
	if player.image_id and player.image_orientation == orientation then
		return
	end
	-- update image
	local old_image_id = player.image_id
	player.image_id = pshy.imagedb_AddImageMin(player.image_name, "%" .. player_name, 0, 0, nil, 40 * orientation, 30, 0.0, 1.0)
	player.image_orientation = orientation
	if old_image_id then
		-- remove previous
		tfm.exec.removeImage(old_image_id)
	end
end



--- Change a player's image.
function pshy.changeimage_ChangeImage(player_name, image_name)
	pshy.changeimage_players[player_name] = pshy.changeimage_players[player_name] or {}
	local player = pshy.changeimage_players[player_name]
	if player.image_id then
		tfm.exec.removeImage(player.image_id)
		player.image_id = nil
	end
	player.image_name = nil
	if image_name then
		-- enable the image
		system.bindKeyboard(player_name, 0, true, true)
		system.bindKeyboard(player_name, 2, true, true)
		player.image_name = image_name
		player.player_orientation = (tfm.get.room.playerList[player_name].isFacingRight) and 1 or -1
		player.available_update_count = 2
		pshy.changeimage_UpdateImage(player_name)
	else
		-- disable the image
		pshy.changeimage_RemoveImage(player_name)
	end
end



function eventKeyboard(player_name, keycode, down, x, y)
	if down and (keycode == 0 or keycode == 2) then
		local player = pshy.changeimage_players[player_name]
		if not player or player.available_update_count <= 0 then
			return
		end
		player.available_update_count = player.available_update_count - 1
		player.player_orientation = (keycode == 2) and 1 or -1
		pshy.changeimage_UpdateImage(player_name)
	end
end



--- TFM event eventPlayerRespawn
function eventPlayerRespawn(player_name)
	if pshy.changeimage_players[player_name] then
		pshy.changeimage_UpdateImage(player_name)
	end
end



--- TFM even eventNewGame.
function eventNewGame()
	-- images are deleted on new games
	for player_name in pairs(tfm.get.room.playerList) do
		if pshy.changeimage_players[player_name] then
			pshy.changeimage_players[player_name].image_id = nil
		end
	end
	-- keep player images
	if pshy.changesize_keep_changes_on_new_game then
		for player_name in pairs(tfm.get.room.playerList) do
			if pshy.changeimage_players[player_name] then
				pshy.changeimage_UpdateImage(player_name)
			end
		end
	end
end



--- TFM event eventPlayerDied
function eventPlayerDied(player_name)
	if pshy.changeimage_players[player_name] then
		pshy.changeimage_players[player_name].image_id = nil
	end
end



--- TFM event eventLoop.
function eventLoop(time, time_remaining)
	for player_name, player in pairs(pshy.changeimage_players) do
		player.available_update_count = 2
	end
end



--- !changeimage <image_name> [player_name]
function pshy.changeimage_ChatCommandChangeimage(user, image_name, target)
	target = pshy.commands_GetTargetOrError(user, target, "!changeimage")
	local image = pshy.imagedb_images[image_name]
	if image_name == "off" then
		pshy.changeimage_ChangeImage(target, nil)
		return
	end
	if not image then
		return false, "Unknown or not approved image."
	end
	if not image.w then
		return false, "This image cannot be used (unknown width)."
	end
	if image.w > 400 or (image.h and image.h > 400)  then
		return false, "This image is too big (w/h > 400)."
	end
	pshy.changeimage_ChangeImage(target, image_name)
	return true, "Image changed!"
end
pshy.chat_commands["changeimage"] = {func = pshy.changeimage_ChatCommandChangeimage, desc = "change your image", argc_min = 1, argc_max = 2, arg_types = {"string", "player"}}
pshy.help_pages["pshy_changeimage"].commands["changeimage"] = pshy.chat_commands["changeimage"]
pshy.perms.cheats["!changeimage"] = true
pshy.perms.admins["!changeimage-others"] = true



--- !randomchangeimage <words>
function pshy.changeimage_ChatCommandRandomchangeimage(user, words)
	local words = pshy.StrSplit(words, ' ', 4)
	local image_names = pshy.imagedb_Search(words)
	return pshy.changeimage_ChatCommandChangeimage(user, image_names[math.random(#image_names)])
end
pshy.chat_commands["randomchangeimage"] = {func = pshy.changeimage_ChatCommandRandomchangeimage, desc = "change your image to a random image matching a search", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_changeimage"].commands["randomchangeimage"] = pshy.chat_commands["randomchangeimage"]
pshy.perms.cheats["!randomchangeimage"] = true



--- !randomchangeimages <words>
function pshy.changeimage_ChatCommandRandomchangeimageeveryone(user, words)
	local words = pshy.StrSplit(words, ' ', 4)
	local image_names = pshy.imagedb_Search(words)
	local r1, r2
	for player_name in pairs(tfm.get.room.playerList) do
		r1, r2 = pshy.changeimage_ChatCommandChangeimage(player_name, image_names[math.random(#image_names)])
		if r1 == false then
			return r1, r2
		end
	end
	return true, "All images changed!"
end
pshy.chat_commands["randomchangeimages"] = {func = pshy.changeimage_ChatCommandRandomchangeimageeveryone, desc = "change everyone's image to a random image matching a search", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_changeimage"].commands["randomchangeimages"] = pshy.chat_commands["randomchangeimages"]
pshy.perms.admins["!randomchangeimages"] = true
