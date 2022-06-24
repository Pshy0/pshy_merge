--- pshy.bases.autorespawn
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy = pshy or {}



--- Namespace.
local autorespawn = {}



--- Should players respawn on death or win?
autorespawn.on_died = true
autorespawn.on_won = true



--- Internal use:
local pending_respawn = {}
local pending_respawn_2 = {}



function eventPlayerDied(player_name)
	if autorespawn.on_died then
		table.insert(pending_respawn, player_name)
	end
end



function eventPlayerWon(player_name)
	if autorespawn.on_won then
		table.insert(pending_respawn, player_name)
	end
end



function eventLoop()
	if #pending_respawn > 0 then
		for i_died, player_name in pairs(pending_respawn) do
			tfm.exec.respawnPlayer(player_name)
		end
		pending_respawn = {}
	end
	if #pending_respawn > 0 then
		pending_respawn_2 = pending_respawn
	end
end



return autorespawn
