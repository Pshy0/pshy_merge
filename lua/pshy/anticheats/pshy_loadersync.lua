--- pshy_loadersync.lua
--
-- Temporary mitigation to TFM sync vulnerability.
--
-- @require pshy_merge.lua
-- @require pshy_perms.lua
-- @require pshy_print.lua
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



--- Set the player sync to be the host.
tfm.exec.setPlayerSync(pshy.loader)



function eventNewPlayer(player_name)
	if player_name == pshy.loader then
		tfm.exec.setPlayerSync(pshy.loader)
	end
end



function eventPlayerLeft(player_name)
	if player_name == pshy.loader then
		for player_name in pairs(pshy.admins) do
			tfm.exec.setPlayerSync(player_name)
			return
		end
		print_warn("pshy_loadersync: Loader left and no room admin were available, using a random player!")
		for player_name in pairs(tfm.get.room.playerList) do
			tfm.exec.setPlayerSync(player_name)
			return
		end
	end
end
