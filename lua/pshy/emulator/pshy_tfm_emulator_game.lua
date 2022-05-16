--- pshy_tfm_emulator_game.lua
--
-- Simulate gameplay.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_tfm_emulator_basic_environment.lua
-- @require pshy_tfm_emulator_players.lua
--
-- @require_priority DEBUG
pshy = pshy or {}



--- Trigger `eventLoop(time, time_remaining)`.
function pshy.tfm_emulator_Loop(time, time_remaining)
	if eventLoop then
		eventLoop(time, time_remaining)
	end
end
