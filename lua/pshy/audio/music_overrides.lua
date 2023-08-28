--- pshy.audio.music_overrides
--
-- Add and improve TFM audio features.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local music_lib = pshy.require("pshy.audio.library.music")
pshy.require("pshy.utils.print")



local original_tfm_exec_playMusic = tfm.exec.playMusic
local original_tfm_exec_stopMusic = tfm.exec.stopMusic
local current_music = nil
local current_music_volume = nil
local current_music_end_timer = nil



local function MusicOverCallback(timer_id)
	current_music_end_timer = nil
	-- here we will restart the music for incoming players after the music finishes
	tfm.exec.playMusic(current_music, "musique", current_music_volume, true)
end



--- Override for tfm.exec.playMusic
-- Ensure repeating musics also plays for new players by repeating them
tfm.exec.playMusic = function(music, channel, volume, loop, fade, target_player, ...)
	if channel == "musique" and target_player == nil then
		current_music = music
		current_music_volume = volume
		-- abort music repetition
		if current_music_end_timer then
			system.removeTimer(current_music_end_timer)
			current_music_end_timer = nil
		end
		-- support music indices and category names
		music = music_lib.GetMusic(music) or music
		print(string.format("<n2>㉧﹅ playing <b>%s</b></n2>", music))
		-- handle looping musics ourselves
		if loop then
			if music_lib.music_dict[music] and music_lib.music_dict[music].duration then
				current_music_end_timer = system.newTimer(MusicOverCallback, music_lib.music_dict[music].duration * 1000 + 500)
				loop = false
			end
		end
	end
	return original_tfm_exec_playMusic(music, channel, volume, loop, fade, target_player, ...) 
end



tfm.exec.stopMusic = function(channel, player_name, ...)
	if channel == "musique" then
		if target_player == nil then
			current_music = nil
			current_music_volume = nil
			if current_music_end_timer then
				system.removeTimer(current_music_end_timer)
				current_music_end_timer = nil
			end
		else
			print_warn("pshy.audio: stopMusic: not handling the case for non-nil player_name very well")
		end
	end
	return original_tfm_exec_stopMusic(channel, player_name, ...)
end
