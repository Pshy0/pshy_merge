--- pshy_loadersync.lua
--
-- Temporary mitigation to TFM sync vulnerability.
--
-- @require pshy_adminchat.lua
-- @require pshy_merge.lua
-- @require pshy_perms.lua
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



--- Set the player sync to be the host.
tfm.exec.setPlayerSync(pshy.loader)



function eventNewPlayer(player_name)
	if player_name == pshy.loader then
		tfm.exec.setPlayerSync(player_name)
		pshy.adminchat_Message("pshy_loadersync", "Loader returned and set as sync!")
	end
end



function eventPlayerLeft(player_name)
	if (player_name == pshy.loader or pshy.admins[player_name]) and tfm.exec.getPlayerSync() == player_name then
		for player_name in pairs(pshy.admins) do
			if tfm.get.room.playerList[player_name] then
				tfm.exec.setPlayerSync(player_name)
				pshy.adminchat_Message("pshy_loadersync", string.format("Loader left, setting %s as sync!", player_name))
				return
			end
		end
		for player_name in pairs(tfm.get.room.playerList) do
			tfm.exec.setPlayerSync(player_name)
			print_warn("pshy_loadersync: Loader left, setting %s as sync!", player_name)
			return
		end
	end
end
