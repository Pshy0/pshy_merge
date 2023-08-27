--- pshy.commands.list.sound
--
-- Commands that plays sounds.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local help_pages = pshy.require("pshy.help.pages")
local music_lib = pshy.require("pshy.audio.library.music")
local ambient_lib = pshy.require("pshy.audio.library.ambient")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Music / Sounds", text = "Play sounds and musics."}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.require("pshy.commands.get_target_or_error")



local music_list = music_lib.music_list



local ambient_list = ambient_lib.ambient_list



__MODULE__.commands = {
	["sound"] = {
		perms = "admins",
		desc = "Play a sound in the room. Can play sounds in parallel.",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"string"},
		arg_names = {"sound path"},
		func = function(user, sound_name)
			tfm.exec.playSound(sound_name)
		end
	},
	["listmusics"] = {
		aliases = {"lsmusics", "lsm", "musics"},
		perms = "admins",
		desc = "List indexed musics.",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			for i_music, music_table in ipairs(music_list) do
				tfm.exec.chatMessage(string.format("%d\t- %s", i_music, music_table.name), user)
			end
			return true
		end
	},
	["musiccategories"] = {
		perms = "admins",
		desc = "List music categories you can une in place of music names.",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			for cat_name in pairs(music_lib.categories_set) do
				tfm.exec.chatMessage(string.format("\t- %s", cat_name), user)
			end
			return true
		end
	},
	["music"] = {
		aliases = {"m"},
		perms = "admins",
		desc = "Play a music. Only one music may play at a time.",
		argc_min = 1,
		argc_max = 3,
		arg_types = {"string", "number", "boolean"},
		arg_names = {"sound path or music index", "volume (0-70-100)", "repeat"},
		func = function(user, sound_name, volume, rep)
			local sound_name, msg = music_lib.GetMusic(sound_name)
			if not sound_name then
				return false, msg
			end
			tfm.exec.playMusic(sound_name, "musique", volume, rep)
			return true, string.format("Playing %s", sound_name)
		end
	},
	["stopmusic"] = {
		perms = "admins",
		desc = "Stops the music.",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			tfm.exec.stopMusic("musique")
			return true, "Music stopped"
		end
	},
	["ambients"] = {
		perms = "admins",
		desc = "List indexed ambient sounds.",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			for i_amb, amb_name in ipairs(ambient_list) do
				tfm.exec.chatMessage(string.format("%d\t- %s", i_amb, amb_name), user)
			end
			return true
		end
	},
	["ambient"] = {
		perms = "admins",
		desc = "Play an ambient sound. The sound will loop. Only one ambient sound may play at a time.",
		argc_min = 1,
		argc_max = 2,
		arg_types = {"string", "number"},
		arg_names = {"sound path or ambient index", "volume (0-100)"},
		func = function(user, sound_name, volume)
			local index = tonumber(sound_name)
			if index then
				sound_name = ambient_list[index]
				if not sound_name then
					return false, string.format("Invalid ambient index. It must be between 1 and %d!", #ambient_list)
				end
			end
			tfm.exec.playMusic(sound_name, 1, volume, true)
			return true, string.format("Playing %s", sound_name)
		end
	},
	["stopambient"] = {
		perms = "admins",
		desc = "Stops the ambient sound.",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			tfm.exec.stopMusic(1)
			return true, "Ambient sound stopped"
		end
	}
}
