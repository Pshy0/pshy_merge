--- pshy.commands.list.sound
--
-- Commands that plays sounds.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local help_pages = pshy.require("pshy.help.pages")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Music / Sounds", text = "Play dsounds and musics."}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.require("pshy.commands.get_target_or_error")



local musics = {
	"bouboum/x_intro";
	"cite18/m-intro";
	"cite18/musique/camp1";
	"cite18/musique/desert1";
	"cite18/musique/desert2";
	"cite18/musique/esprit1";
	"cite18/musique/esprit2";
	-- "cite18/musique/intro"; -- duplicate
	"cite18/musique/intro2";
	"cite18/musique/jungle1";
	"cite18/musique/jungle2";
	"cite18/musique/museum";
	"cite18/musique/museum2";
	"cite18/musique/toundra1";
	"cite18/musique/toundra2";
	"cite18/musique/volcan1";
	"cite18/musique/volcan2";
	"deadmaze/cinematique/_cinematique1";
	"deadmaze/cinematique/cinematique1";
	"deadmaze/cinematique/rock";
	"deadmaze/cinematique/vieux_cinematique1";
	"deadmaze/intro";
	"deadmaze/intro2";
	"deadmaze/x_musique_1";
	"deadmaze/x_musique_2";
	"deadmaze/x_musique_3";
	"fortoresse/x_defaite";
	"fortoresse/x_temps";
	"fortoresse/x_musique_1";
	"fortoresse/x_musique_2";
	"fortoresse/x_victoire";
	"lua/music_event/final_track";
	"lua/music_event/individual/harp";
	"lua/music_event/individual/piano";
	"nekodancer/x_intro";
	"tfmadv/musique/amb1";
	"tfmadv/musique/intro2"; -- has "django"
	"tfmadv/musique/tfmadv_combat1";
	"tfmadv/musique/tfmadv_combat2";
	"tfmadv/musique/tfmadv_combat3";
	"tfmadv/musique/tfmadv_combat4";
	"tfmadv/musique/tfmadv_intro";
	-- "transformice/musique/intro"; -- vanilla
	-- "transformice/musique/m1"; -- vanilla
	-- "transformice/musique/m2"; -- vanilla
	-- "transformice/musique/m3"; -- vanilla
	-- "transformice/musique/m4"; -- vanilla
	-- "transformice/musique/magasin"; -- vanilla
	-- "transformice/musique/tfm1"; -- vanilla
	-- "transformice/musique/tfm2"; -- vanilla
	-- "transformice/musique/tfm3"; -- vanilla
}



local ambients = {
	"cite18/amb/0";
	"cite18/amb/100";
	--"cite18/amb/101"; -- duplicate
	"cite18/amb/102";
	"cite18/amb/200";
	"cite18/amb/201";
	"cite18/amb/300";
	"cite18/amb/301";
	"cite18/amb/302";
	"cite18/amb/400";
	"cite18/amb/401";
	"cite18/amb/402";
	"cite18/amb/403";
	"cite18/amb/404";
	"cite18/amb/500";
	"cite18/amb/501";
	"cite18/amb/502";
	"cite18/amb/503";
	"cite18/amb/504";
	"cite18/amb/505";
	"cite18/amb/506";
	"cite18/amb/507";
	"cite18/amb/508";
	"cite18/amb/509";
	"cite18/m-amb1";
	"deadmaze/cinematique/tremblement";
	"deadmaze/cinematique/voiture";
	"deadmaze/cuisine";
	"deadmaze/voiture";
	"deadmaze/x_amb_desert";
	"deadmaze/x_amb_feu";
	"deadmaze/x_amb_grotte";
	"deadmaze/x_amb_hiver";
	"deadmaze/x_amb_hiver2";
	"deadmaze/x_amb_interieur";
	"deadmaze/x_amb_neige";
	"deadmaze/x_amb_normandie";
	"deadmaze/x_amb_nuit";
	"deadmaze/x_amb_orage";
	"deadmaze/x_amb_pluie";
	"deadmaze/x_amb_pluie_interieur";
	"deadmaze/x_amb_vent";
	"fortoresse/x_ambiance_1";
	"fortoresse/x_ambiance_2";
	"fortoresse/x_ambiance_3";
	--"tfmadv/ambiance/desert"; -- duplicate
	"tfmadv/ambiance/foret";
	"tfmadv/ambiance/foret2";
	--"tfmadv/ambiance/grotte"; -- duplicate
	--"tfmadv/ambiance/hiver"; -- duplicate
	--"tfmadv/ambiance/hiver2"; -- duplicate
	--"tfmadv/ambiance/orage"; -- duplicate
	--"tfmadv/ambiance/pluie"; -- duplicate
	--"tfmadv/ambiance/pluie-interieur"; -- duplicate
	"tfmadv/ambiance/prairie";
	--"tfmadv/ambiance/vent"; -- duplicate
	"tfmadv/boucle-bulle";
	"tfmadv/boucle-cuisson";
	"tfmadv/bougie";
}



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
	["musics"] = {
		perms = "admins",
		desc = "List indexed musics.",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			for i_music, music_name in ipairs(musics) do
				tfm.exec.chatMessage(string.format("%d\t- %s", i_music, music_name), user)
			end
			return true
		end
	},
	["music"] = {
		perms = "admins",
		desc = "Play a music. Only one music may play at a time.",
		argc_min = 1,
		argc_max = 2,
		arg_types = {"string", "number"},
		arg_names = {"sound path or music index", "volume (0-100)"},
		func = function(user, sound_name, volume)
			local index = tonumber(sound_name)
			if index then
				sound_name = musics[index]
				if not sound_name then
					return false, string.format("Invalid music index. It must be between 1 and %d!", #musics)
				end
			end
			tfm.exec.playMusic(sound_name, "musique", volume, false)
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
			for i_amb, amb_name in ipairs(ambients) do
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
				sound_name = ambients[index]
				if not sound_name then
					return false, string.format("Invalid ambient index. It must be between 1 and %d!", #ambients)
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
