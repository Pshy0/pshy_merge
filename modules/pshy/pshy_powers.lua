--- pshy_powers.lua
--
-- This module add misc powers available to mice.
--
-- A power may have the specific features:
--	Call a function on click or key press.
--
--
-- @author TFM: Pshy#3752
-- @namespace pshy
-- @require pshy_perms.lua
-- @require pshy_commands.lua



--- Map of available powers.
-- Key is the power name. Value is the power table.
pshy.powers = {}






--- TFM event eventKeyboard
function eventKeyboard(playerName, keyCode, down, xPlayerPosition, yPlayerPosition)
	-- @todo
end



--- TFM event eventMouse
function eventMouse(playerName, xMousePosition, yMousePosition)

    local message = "Le joueur " .. playerName
    message = message .. " a cliqué à la position (" .. xMousePosition .. "," .. yMousePosition .. ")."

    print(message)

end



--- TFM event eventPlayerDied
function eventPlayerDied(playerName)
	-- @todo
end




--- !powerplayer <player> <bind> 
