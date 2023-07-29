--
-- Allow players to change their image.
--
-- @author TFM:Pshy#3752 DC:Pshy#3752
local addimage = pshy.require("pshy.images.addimage")
local searchimage = pshy.require("pshy.images.searchimage")
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")
local utils_strings = pshy.require("pshy.utils.strings")
local images = pshy.require("pshy.images.list")



--- Namespace.
local changeimage = {}



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Image Change", text = "Change your image.\n"}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Module Settings:
pshy.changesize_keep_changes_on_new_game = true



--- Internal Use:
local players = {}



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.require("pshy.commands.get_target_or_error")



--- Remove an image for a player.
function changeimage.RemoveImage(player_name)
	if players[player_name].image_id then
		tfm.exec.removeImage(players[player_name].image_id)
	end
	players[player_name] = nil
	tfm.exec.changePlayerSize(player_name, 0.9)
	tfm.exec.changePlayerSize(player_name, 1.0)
end



--- Update a player's image.
function changeimage.UpdateImage(player_name)
	local player = players[player_name]
	-- get draw settings
	local orientation = player.player_orientation or 1
	if not searchimage.IsOriented(player.image_name) then
		orientation = 1
	end
	-- skip if update not required
	if player.image_id and player.image_orientation == orientation then
		return
	end
	-- update image
	local old_image_id = player.image_id
	player.image_id = addimage.AddImageMin(player.image_name, "%" .. player_name, 0, 0, nil, 40 * orientation, 30, 0.0, 1.0)
	player.image_orientation = orientation
	if old_image_id then
		-- remove previous
		tfm.exec.removeImage(old_image_id)
	end
end



--- Change a player's image.
function changeimage.ChangeImage(player_name, image_name)
	players[player_name] = players[player_name] or {}
	local player = players[player_name]
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
		changeimage.UpdateImage(player_name)
	else
		-- disable the image
		changeimage.RemoveImage(player_name)
	end
end



function eventKeyboard(player_name, keycode, down, x, y)
	if down and (keycode == 0 or keycode == 2) then
		local player = players[player_name]
		if not player or player.available_update_count <= 0 then
			return
		end
		player.available_update_count = player.available_update_count - 1
		player.player_orientation = (keycode == 2) and 1 or -1
		changeimage.UpdateImage(player_name)
	end
end



--- TFM event eventPlayerRespawn
function eventPlayerRespawn(player_name)
	if players[player_name] then
		changeimage.UpdateImage(player_name)
	end
end



--- TFM even eventNewGame.
function eventNewGame()
	-- images are deleted on new games
	for player_name in pairs(tfm.get.room.playerList) do
		if players[player_name] then
			players[player_name].image_id = nil
		end
	end
	-- keep player images
	if pshy.changesize_keep_changes_on_new_game then
		for player_name in pairs(tfm.get.room.playerList) do
			if players[player_name] then
				changeimage.UpdateImage(player_name)
			end
		end
	end
end



--- TFM event eventPlayerDied
function eventPlayerDied(player_name)
	if players[player_name] then
		players[player_name].image_id = nil
	end
end



--- TFM event eventLoop.
function eventLoop(time, time_remaining)
	for player_name, player in pairs(players) do
		player.available_update_count = 2
	end
end



__MODULE__.commands = {
	["changeimage"] = {
		perms = "cheats",
		desc = "change your image",
		argc_min = 1,
		argc_max = 2,
		arg_types = {"string", "player"},
		func = function(user, image_name, target)
			target = GetTarget(user, target, "!changeimage")
			local image = images[image_name]
			if image_name == "off" then
				changeimage.ChangeImage(target, nil)
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
			changeimage.ChangeImage(target, image_name)
			return true, "Image changed!"
		end
	},
	["randomchangeimage"] = {
		perms = "cheats",
		desc = "change your image to a random image matching a search",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"string"},
		func = function(user, words)
			words = utils_strings.Split(words, ' ', 4)
			local image_names = searchimage.Search(words)
			return __MODULE__.commands.changeimage.func(user, image_names[math.random(#image_names)])
		end
	},
	["randomchangeimages"] = {
		perms = "admins",
		desc = "change everyone's image to a random image matching a search",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"string"},
		func = function(user, words)
			local words = utils_strings.Split(words, ' ', 4)
			local image_names = searchimage.Search(words)
			local r1, r2
			for player_name in pairs(tfm.get.room.playerList) do
				r1, r2 = __MODULE__.commands.changeimage.func(player_name, image_names[math.random(#image_names)])
				if r1 == false then
					return r1, r2
				end
			end
			return true, "All images changed!"
		end
	}
}



return changeimage
