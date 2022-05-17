--- pshy_tfm_emulator_controls.lua
--
-- Simulate keyboard & mouse features.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_tfm_emulator_basic_environment.lua
--
-- @require_priority DEBUG
pshy = pshy or {}



--- Members:
pshy.tfm_emulator_player_bound_keys = {}
pshy.tfm_emulator_player_bound_mice = {}



--- Internal Use:
local bound_keys = pshy.tfm_emulator_player_bound_keys
local bound_mice = pshy.tfm_emulator_player_bound_mice



--- Simulate a player mouse click.
-- This have no effect if the player mouse is not bound.
function pshy.tfm_emulator_Keyboard(player_name, keycode, down, x, y)
	if eventKeyboard then
		if down == nil then
			down = true
		end
		if bound_keys[player_name] and bound_keys[player_name][keycode] and bound_keys[player_name][keycode][down and 1 or 2] then
			x = x or 400
			y = y or 200
			eventKeyboard(player_name, keycode, down, x, y)
		end
	end
end



--- Reimplementation of `system.bindKeyboard`.
system.bindKeyboard = function(player_name, keycode, down, yes)
	if not bound_keys[player_name] then
		bound_keys[player_name] = {}
	end
	if not bound_keys[player_name][keycode] then
		bound_keys[player_name][keycode] = {}
	end
	bound_keys[player_name][keycode][down and 1 or 2] = yes
end



--- Simulate a player key press.
-- This have no effect if the player key is not bound.
function pshy.tfm_emulator_Mouse(player_name, x, y)
	if eventMouse then
		if bound_mice[player_name] then
			eventMouse(player_name, x, y)
		end
	end
end



--- Reimplementation of `system.bindMouse`.
system.bindMouse = function(player_name, yes)
	bound_mice[player_name] = yes
end
