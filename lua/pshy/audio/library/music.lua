--- pshy.audio.library.music
--
-- Collections of sounds.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



local music_lib = {}



--- Categories of musics
music_lib.categories_set = {
	-- Theme categories:
	calm = true;	-- music is not too dynamic
	casual = true;	-- musics good at playing in the background
	disco = true;	-- musics nice to dance on
	epic = true;	-- good musics, subjective
	fight = true;	-- music good for fights (likely epic)
	-- Negative categories:
	duplicate = true;
	individual = true;
	jammed = true;
	mysterious = true;
	quiet = true;
	vanilla = true;	--  vanilla TFM musics
}



--- List of game musics.
music_lib.music_list = {
	{name = "bouboum/x_intro", duration = 54.38, disco = true};
	{name = "cite18/m-intro", duration = 110.19, epic = true};
	{name = "cite18/musique/camp1", duration = 67.5, calm = true};
	{name = "cite18/musique/desert1", duration = 94.42, epic = true};
	{name = "cite18/musique/desert2", duration = 97.62, epic = true};
	{name = "cite18/musique/esprit1", duration = 102.85, disco = true, epic = true, fight = true};
	{name = "cite18/musique/esprit2", duration = 109.66, disco = true, epic = true, fight = true};
	{name = "cite18/musique/intro", duration = 97.10, duplicate = true}; -- duplicate / or not? doesnt begin the same
	{name = "cite18/musique/intro2", duration = 88.51, disco = true, epic = true};
	{name = "cite18/musique/jungle1", duration = 118.76, mysterious = true};
	{name = "cite18/musique/jungle2", duration = 104.34, disco = true, epic = true, fight = true};
	{name = "cite18/musique/museum", duration = 120, casual = true, calm = true, mysterious = true};
	{name = "cite18/musique/museum2", duration = 105, mysterious = true};
	{name = "cite18/musique/toundra1", duration = 90.66, calm = true};
	{name = "cite18/musique/toundra2", duration = 96, casual = true, mysterious = true, calm = true};
	{name = "cite18/musique/volcan1", duration = 120.94, epic = true, mysterious = true, calm = true};
	{name = "cite18/musique/volcan2", duration = 90.70, epic = true, fight = true};
	{name = "deadmaze/cinematique/_cinematique1", duration = 86.56, epic = true, jammed = true};
	{name = "deadmaze/cinematique/cinematique1", duration = 91.04, calm = true};
	{name = "deadmaze/cinematique/rock", duration = 93.96, casual = true};
	{name = "deadmaze/cinematique/vieux_cinematique1", duration = 148.06, epic = true, jammed = true, mysterious = true};
	{name = "deadmaze/intro", duration = 40.85, epic = true, stress = true};
	{name = "deadmaze/intro2", duration = 130.14, calm = true, jammed = true};
	{name = "deadmaze/x_musique_1", duration = 130.04, mysterious = true, quiet = true, stress = true};
	{name = "deadmaze/x_musique_2", duration = 204.48, mysterious = true, quiet = true, stress = true};
	{name = "deadmaze/x_musique_3", duration = 200.04, mysterious = true, quiet = true, stress = true};
	--{name = "fortoresse/x_defaite", duration = 8.96}; -- defeat sound
	{name = "fortoresse/x_temps", duration = 99.03, disco = true, epic = true, fight = true};
	{name = "fortoresse/x_musique_1", duration = 38.42, epic = true, fight = true};
	{name = "fortoresse/x_musique_2", duration = 46.10, epic = true, fight = true};
	--{name = "fortoresse/x_victoire", duration = 5.14}; -- victory sound
	{name = "lua/music_event/final_track", duration = 93.57};
	{name = "lua/music_event/individual/basses", duration = 23.22, individual = true};
	{name = "lua/music_event/individual/bassoon", duration = 23.22, individual = true};
	{name = "lua/music_event/individual/cellos", duration = 23.22, individual = true};
	{name = "lua/music_event/individual/clarinet", duration = 23.22, individual = true};
	{name = "lua/music_event/individual/cymbals", duration = 23.22, individual = true};
	{name = "lua/music_event/individual/euphonium", duration = 23.22, individual = true};
	{name = "lua/music_event/individual/flute", duration = 23.22, individual = true};
	{name = "lua/music_event/individual/french_horn", duration = 23.22, individual = true};
	{name = "lua/music_event/individual/harp", duration = 23.22, individual = true};
	{name = "lua/music_event/individual/marimba", duration = 23.22, individual = true};
	{name = "lua/music_event/individual/oboe", duration = 23.22, individual = true};
	{name = "lua/music_event/individual/saxophone", duration = 23.22, individual = true};
	{name = "lua/music_event/individual/trumpets", duration = 23.22, individual = true};
	{name = "lua/music_event/individual/tuba", duration = 23.22, individual = true};
	{name = "lua/music_event/individual/tubular_bells", duration = 23.22, individual = true};
	{name = "lua/music_event/individual/vibraphone", duration = 23.22, individual = true};
	{name = "lua/music_event/individual/violas", duration = 23.22, individual = true};
	{name = "lua/music_event/individual/violins", duration = 23.22, individual = true};
	{name = "lua/music_event/individual/voice", duration = 23.22, individual = true};
	{name = "nekodancer/x_intro", duration = 64.05, disco = true};
	{name = "tfmadv/musique/amb1", duration = 37.81, calm = true, casual, jammed = true};
	{name = "tfmadv/musique/intro2", duration = 141.34, calm = true, casual = true, jammed = true};
	{name = "tfmadv/musique/tfmadv_combat1", duration = 41.22, epic = true, fight = true, stress = true};
	{name = "tfmadv/musique/tfmadv_combat2", duration = 97.66, epic = true, fight = true};
	{name = "tfmadv/musique/tfmadv_combat3", duration = 68.57, epic = true, fight = true};
	{name = "tfmadv/musique/tfmadv_combat4", duration = 58.17, epic = true, fight = true};
	{name = "tfmadv/musique/tfmadv_intro", duration = 118.51, casual = true};
	{name = "tfmadv/musique/tfmadv_village", duration = 169.77, casual = true, epic = true};
	{name = "transformice/musique/intro", duration = 39.75, casual = true, vanilla = true};
	{name = "transformice/musique/m1", duration = 77.60, vanilla = true};
	{name = "transformice/musique/m2", duration = 156.92, casual = true, vanilla = true};
	{name = "transformice/musique/m3", duration = 113.76, casual = true, vanilla = true};
	{name = "transformice/musique/m4", duration = 93.67, casual = true, vanilla = true};
	{name = "transformice/musique/magasin", duration = 43.67, vanilla = true};
	{name = "transformice/musique/tfm1", duration = 93.71, casual = true, vanilla = true};
	{name = "transformice/musique/tfm2", duration = 69.35, casual = true, vanilla = true};
	{name = "transformice/musique/tfm3", duration = 72.45, casual = true, vanilla = true};
}



--- Dictionary of game musics.
music_lib.music_dict = {}
for music_index, music_table in ipairs(music_lib.music_list) do
	music_lib.music_dict[music_table.name] = music_table
end



local last_random_music_name = nil



--- Get a music name from an index, a path or a category
function music_lib.GetMusic(name_or_category)
	-- from index
	local index = tonumber(name_or_category)
	if index then
		local music = music_lib.music_list[index]
		if not music then
			return nil, string.format("Invalid music index. It must be between 1 and %d!", #music_lib.music_list)
		end
		return music.name
	end
	-- from category
	if music_lib.categories_set[name_or_category] then
		local candidates = {}
		for i_music, music in ipairs(music_lib.music_list) do
			if music[name_or_category] then
				if music.name ~= last_random_music_name then
					if (not music.jammed or name_or_category == "jammed") and (not music.vanilla or name_or_category == "vanilla") and (not music.quiet or name_or_category == "quiet") and (not music.duplicate or name_or_category == "duplicate") then
						table.insert(candidates, music)
					end
				end
			end
		end
		last_random_music_name = candidates[math.random(1, #candidates)].name
		return last_random_music_name
	end
	-- from name
	return name_or_category
end



return music_lib
