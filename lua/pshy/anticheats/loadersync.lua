--- pshy.anticheats.loadersync
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- Temporary mitigation to TFM sync vulnerability.
local adminchat = pshy.require("pshy.anticheats.adminchat")
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")
pshy.require("pshy.utils.print")
local room = pshy.require("pshy.room")
local perms = pshy.require("pshy.perms")



--- Namespace.
local loadersync = {}



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", restricted = true, text = "Enforce the sync to prevent some exploits.\n"}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Module Settings:
loadersync.enabled = true



--- Internal use:
local wished_sync = room.loader			-- player wished as sync
local forced_sync = nil					-- player currently being forced as sync
local is_get_player_sync_available = (tfm.exec.getPlayerSync() ~= nil)



function eventNewGame()
	if loadersync.enabled then
		if forced_sync and tfm.exec.getPlayerSync() ~= forced_sync then
			adminchat.Message("loadersync", string.format("Sync changed from %s to %s, restoring the previous one!", forced_sync or "nil", tfm.exec.getPlayerSync() or "nil"))
			tfm.exec.setPlayerSync(forced_sync)
		end
	end
end



function eventNewPlayer(player_name)
	if loadersync.enabled then
		if player_name == wished_sync then
			tfm.exec.setPlayerSync(player_name)
			forced_sync = player_name
			adminchat.Message("loadersync", string.format("%s returned and set as sync!", player_name))
		end
	end
end



function eventPlayerLeft(player_name)
	if loadersync.enabled then
		if forced_sync == player_name then
			for player_name in pairs(perms.admins) do
				if tfm.get.room.playerList[player_name] then
					tfm.exec.setPlayerSync(player_name)
					forced_sync = player_name
					adminchat.Message("loadersync", string.format("Sync left, replacing it with %s!", player_name))
					return
				end
			end
			for player_name in pairs(tfm.get.room.playerList) do
				tfm.exec.setPlayerSync(player_name)
				forced_sync = player_name
				print_warn(__MODULE_NAME__ .. ": Sync left, replacing it with %s!", player_name)
				return
			end
		end
	end
end



function eventInit()
	if not is_get_player_sync_available then
		loadersync.enabled = false
	else
		--- Set the player sync to be the host.
		tfm.exec.setPlayerSync(wished_sync)
		forced_sync = wished_sync
	end
end



__MODULE__.commands = {
	["loadersync"] = {
		perms = "admins",
		desc = "Enable or disable the enforcing of the sync.",
		argc_min = 1,
		argc_max = 2,
		arg_types = {"boolean", "player"},
		arg_names = {"on/off", "sync_player"},
		func = function(user, enabled, sync_player)
			loadersync.enabled = enabled
			if sync_player then
				wished_sync = sync_player
				tfm.exec.setPlayerSync(sync_player)
				forced_sync = sync_player
			end
			adminchat.Message("loadersync", enabled and string.format("Now enforcing the sync to be %s.", forced_sync) or "No longer enforcing the sync.")
			return true
		end
	}
}



return loadersync
