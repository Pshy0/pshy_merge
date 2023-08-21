--- pshy.bases.new_player_ui_updates
--
-- Update TFM's ui map name and shaman name for new players.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")



local original_ui_setMapName = ui.setMapName
local original_ui_setShamanName = ui.setShamanName



local ui_map_name = nil
local ui_shaman_name = nil
local ui_update_timer_id = nil			-- not nil when an update is pending



--- Override of ui.setMapName
-- Set internal values, then calls the original.
ui.setMapName = function(map_name, ...)
	ui_map_name = map_name
	return original_ui_setMapName(map_name, ...)
end




--- Override of ui.setMapName
-- Set internal values, then calls the original.
ui.setShamanName = function(shaman_name, ...)
	ui_shaman_name = shaman_name
	return original_ui_setShamanName(shaman_name, ...)
end



function UiUpdateTimerCallback()
	ui_update_timer_id = nil
	if ui_map_name then
		original_ui_setMapName(ui_map_name)
	end
	if ui_shaman_name then
		original_ui_setShamanName(ui_shaman_name)
	end
end



function eventNewPlayer()
	if not ui_update_timer_id and (ui_map_name or ui_shaman_name) then
		ui_update_timer_id = system.newTimer(UiUpdateTimerCallback, false, 2000)
	end
end



function eventNewGame()
	if ui_update_timer_id then
		system.removeTimer(ui_update_timer_id)
		ui_update_timer_id = nil
	end
	local ui_map_name = nil
	local ui_shaman_name = nil
end
