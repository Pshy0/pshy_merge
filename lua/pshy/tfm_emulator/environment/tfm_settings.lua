--- pshy.tfm_emulator.environment.tfm_settings
--
-- Implement TFM settings functions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.tfm_emulator.environment.base")
local tfmenv = pshy.require("pshy.compiler.tfmenv")



--- Internal Use:
local lua_print = print



--- Members:
tfmenv.tfm_auto_map_flip_mode = false
tfmenv.tfm_auto_new_game = true
tfmenv.tfm_auto_shaman = true
tfmenv.tfm_shaman_skills = true
tfmenv.tfm_auto_time_left = true
tfmenv.tfm_auto_score = true
tfmenv.tfm_afk_death = true
tfmenv.tfm_mort_command = true
tfmenv.tfm_watch_command = true
tfmenv.tfm_debug_command = true
tfmenv.tfm_minimalist_mode = true
tfmenv.tfm_physical_consumables = true
tfmenv.tfm_chat_commands_display = true
tfmenv.tfm_disabled_commands_display = {}



tfmenv.env.tfm.exec.setAutoMapFlipMode = function(yes)
	tfmenv.tfm_auto_map_flip_mode = yes
end



tfmenv.env.tfm.exec.disableAutoNewGame = function(yes)
	tfmenv.tfm_auto_new_game = not yes
end



tfmenv.env.tfm.exec.disableAutoShaman = function(yes)
	tfmenv.tfm_auto_shaman = not yes
end



tfmenv.env.tfm.exec.disableAllShamanSkills = function(yes)
	tfmenv.tfm_shaman_skills = not yes
end



tfmenv.env.tfm.exec.disableAutoTimeLeft = function(yes)
	tfmenv.tfm_auto_time_left = not yes
end



tfmenv.env.tfm.exec.disableAutoScore = function(yes)
	tfmenv.tfm_auto_score = not yes
end



tfmenv.env.tfm.exec.disableAfkDeath = function(yes)
	tfmenv.tfm_afk_death = not yes
end



tfmenv.env.tfm.exec.disableMortCommand = function(yes)
	tfmenv.tfm_mort_command = not yes
end



tfmenv.env.tfm.exec.disableWatchCommand = function(yes)
	tfmenv.tfm_watch_command = not yes
end



tfmenv.env.tfm.exec.disableDebugCommand = function(yes)
	tfmenv.tfm_debug_command = not yes
end



tfmenv.env.tfm.exec.disableMinimalistMode = function(yes)
	tfmenv.tfm_minimalist_mode = not yes
end



tfmenv.env.tfm.exec.disablePhysicalConsumables = function(yes)
	tfmenv.tfm_physical_consumables = not yes
end



tfmenv.env.tfm.exec.disableChatCommandDisplay = function(command, yes)
	if command then
		tfmenv.tfm_disabled_commands_display[command] = yes
	else
		tfmenv.tfm_chat_commands_display = not yes
	end
end



tfmenv.env.debug.disableTimerLog = function()
	lua_print("/!\\ Used deprecated `debug.disableTimerLog`!")
end



tfmenv.env.debug.disableEventLog = function(yes)
	tfmenv.log_events = not yes
end
