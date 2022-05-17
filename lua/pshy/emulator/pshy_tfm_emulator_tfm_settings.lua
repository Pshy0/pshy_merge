--- pshy_tfm_emulator_tfm_settings.lua
--
-- Implement TFM settings functions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_tfm_emulator_basic_environment.lua
--
-- @require_priority DEBUG



--- Internal Use:
local lua_print = pshy.lua_print



--- Members:
pshy.tfm_emulator_tfm_auto_map_flip_mode = false
pshy.tfm_emulator_tfm_auto_new_game = true
pshy.tfm_emulator_tfm_auto_shaman = true
pshy.tfm_emulator_tfm_shaman_skills = true
pshy.tfm_emulator_tfm_auto_time_left = true
pshy.tfm_emulator_tfm_auto_score = true
pshy.tfm_emulator_tfm_afk_death = true
pshy.tfm_emulator_tfm_mort_command = true
pshy.tfm_emulator_tfm_watch_command = true
pshy.tfm_emulator_tfm_debug_command = true
pshy.tfm_emulator_tfm_minimalist_mode = true
pshy.tfm_emulator_tfm_physical_consumables = true
pshy.tfm_emulator_tfm_chat_commands_display = true
pshy.tfm_emulator_tfm_disabled_commands_display = {}



tfm.exec.setAutoMapFlipMode = function(yes)
	pshy.tfm_emulator_tfm_auto_map_flip_mode = yes
end



tfm.exec.disableAutoNewGame = function(yes)
	pshy.tfm_emulator_tfm_auto_new_game = not yes
end



tfm.exec.disableAutoShaman = function(yes)
	pshy.tfm_emulator_tfm_auto_shaman = not yes
end



tfm.exec.disableAllShamanSkills = function(yes)
	pshy.tfm_emulator_tfm_shaman_skills = not yes
end



tfm.exec.disableAutoTimeLeft = function(yes)
	pshy.tfm_emulator_tfm_auto_time_left = not yes
end



tfm.exec.disableAutoScore = function(yes)
	pshy.tfm_emulator_tfm_auto_score = not yes
end



tfm.exec.disableAfkDeath = function(yes)
	pshy.tfm_emulator_tfm_afk_death = not yes
end



tfm.exec.disableMortCommand = function(yes)
	pshy.tfm_emulator_tfm_mort_command = not yes
end



tfm.exec.disableWatchCommand = function(yes)
	pshy.tfm_emulator_tfm_watch_command = not yes
end



tfm.exec.disableDebugCommand = function(yes)
	pshy.tfm_emulator_tfm_debug_command = not yes
end



tfm.exec.disableMinimalistMode = function(yes)
	pshy.tfm_emulator_tfm_minimalist_mode = not yes
end



tfm.exec.disablePhysicalConsumables = function(yes)
	pshy.tfm_emulator_tfm_physical_consumables = not yes
end



tfm.exec.disableChatCommandDisplay = function(command, yes)
	if command then
		pshy.tfm_emulator_tfm_disabled_commands_display[command] = yes
	else
		pshy.tfm_emulator_tfm_chat_commands_display = not yes
	end
end



debug.disableTimerLog = function()
	lua_print("/!\\ Used deprecated `debug.disableTimerLog`!")
end



debug.disableEventLog = function(yes)
	pshy.tfm_emulator_log_events = not yes
end
