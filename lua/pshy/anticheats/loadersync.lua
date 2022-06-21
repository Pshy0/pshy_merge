--- pshy.anticheats.loadersync
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- Temporary mitigation to TFM sync vulnerability.
pshy.require("pshy.anticheats.adminchat")
pshy.require("pshy.bases.doc")
pshy.require("pshy.bases.perms")
pshy.require("pshy.events")
pshy.require("pshy.utils.print")



--- Module Help Page:
pshy.help_pages["pshy_loadersync"] = {back = "pshy", restricted = true, text = "Enforce the sync to prevent some exploits.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_loadersync"] = pshy.help_pages["pshy_loadersync"]



--- Module Settings:
pshy.loadersync_enabled = true



--- Internal use:
local wished_sync = pshy.loader			-- player wished as sync
local forced_sync = nil					-- player currently being forced as sync



--- Set the player sync to be the host.
tfm.exec.setPlayerSync(wished_sync)
forced_sync = wished_sync



function eventNewGame()
	if pshy.loadersync_enabled then
		if forced_sync and tfm.exec.getPlayerSync() ~= forced_sync then
			pshy.adminchat_Message("pshy_loadersync", string.format("Sync changed from %s to %s, restoring the previous one!", forced_sync, tfm.exec.getPlayerSync()))
			tfm.exec.setPlayerSync(forced_sync)
		end
	end
end



function eventNewPlayer(player_name)
	if pshy.loadersync_enabled then
		if player_name == wished_sync then
			tfm.exec.setPlayerSync(player_name)
			forced_sync = player_name
			pshy.adminchat_Message("pshy_loadersync", string.format("%s returned and set as sync!", player_name))
		end
	end
end



function eventPlayerLeft(player_name)
	if pshy.loadersync_enabled then
		if forced_sync == player_name then
			for player_name in pairs(pshy.admins) do
				if tfm.get.room.playerList[player_name] then
					tfm.exec.setPlayerSync(player_name)
					forced_sync = player_name
					pshy.adminchat_Message("pshy_loadersync", string.format("Sync left, replacing it with %s!", player_name))
					return
				end
			end
			for player_name in pairs(tfm.get.room.playerList) do
				tfm.exec.setPlayerSync(player_name)
				forced_sync = player_name
				print_warn("pshy_loadersync: Sync left, replacing it with %s!", player_name)
				return
			end
		end
	end
end



--- !loadersync
local function ChatCommandLoadersync(user, enabled, sync_player)
	pshy.loadersync_enabled = enabled
	if sync_player then
		wished_sync = sync_player
		tfm.exec.setPlayerSync(sync_player)
		forced_sync = sync_player
	end
	pshy.adminchat_Message("pshy_loadersync", enabled and string.format("Now enforcing the sync to be %s.", forced_sync) or "No longer enforcing the sync.")
	return true 
end
pshy.commands["loadersync"] = {perms = "admins", func = ChatCommandLoadersync, desc = "Enable or disable the enforcing of the sync.", argc_min = 1, argc_max = 2, arg_types = {"boolean", "player"}, arg_names = {"on/off", "sync_player"}}
pshy.help_pages["pshy_loadersync"].commands["loadersync"] = pshy.commands["loadersync"]
