--- pshy_antiguest.lua
--
-- Antoban guests and new players from the room.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_ban.lua
-- @require pshy_help
-- @require pshy_merge.lua
pshy = pshy or {}



--- Module Help Page:
pshy.help_pages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"] or {back = "pshy", restricted = true, text = "", commands = {}, subpages = {}}
pshy.help_pages["pshy"].subpages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"]
pshy.help_pages["pshy_antiguest"] = {back = "pshy", text = "Prevent guests and new accounts from joining.\n", examples = {}}
pshy.help_pages["pshy_antiguest"].commands = {}
pshy.help_pages["pshy_antiguest"].examples["luaset pshy.antiguest_required_days -1"] = "allow guests and new accounts"
pshy.help_pages["pshy_antiguest"].examples["luaset pshy.antiguest_required_days 0"] = "disallow guests but allow new accounts"
pshy.help_pages["pshy_antiguest"].examples["luaset pshy.antiguest_required_days 5"] = "disallow guests and accounts of less than 5 days"
pshy.help_pages["pshy_anticheats"].subpages["pshy_antiguest"] = pshy.help_pages["pshy_antiguest"]



--- Module Settings:
pshy.antiguest_required_days = 100		-- required play time, or 0 to only prevent guests from joining, or -1 to disable



--- Internal use:z
pshy.antiguest_start_time = os.time()



--- TFM event eventNewPlayer 
function eventNewPlayer(player_name)
	if pshy.banlist[player_name] then
		return
	end
	tfm_player = tfm.get.room.playerList[player_name]
	if pshy.antiguest_time >= 0 and string.sub(player_name, 1, 1) == "*" then
		pshy.BanPlayer(player_name)
		tfm.exec.chatMessage("<r>[AntiGuest] Sorry, this room is set to deny guest accounts :c</r>", player_name)
		pshy.Log("<j>[AntiGuest] " .. player_name .. " room banned (guest account)!</j>", player_name)
		return
	end
	local account_age_ms = tfm_player.registrationDate - pshy.antiguest_start_time
	local account_age_days = (((account_age_ms / 1000) / 60) / 60) / 24
	if account_age_days < pshy.antiguest_required_days then
		pshy.BanPlayer(player_name)
		tfm.exec.chatMessage("<r>[AntiGuest] Sorry, this room is set to deny accounts of less than " .. tostring(pshy.antiguest_required_days) .. " days :c</r>", player_name)
		pshy.Log("<j>[AntiGuest] " .. player_name .. " room banned (" .. tostring(account_age_days) .. " days account)!</j>", player_name)
		return
	end
end
