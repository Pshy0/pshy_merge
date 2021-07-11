--- pshy_antiguest.lua
--
-- Antoban guests and new players from the room.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_ban.lua
-- @require pshy_help.lua
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
pshy.antiguest_required_days = 5		-- required play time, or 0 to only prevent guests from joining, or -1 to disable



--- Internal use:
pshy.antiguest_start_time = os.time()
pshy.antiguest_banlist = {}



--- Get an account age in days
function pshy.AntiguestGetAccountAge(player_name)
	local account_age_ms = pshy.antiguest_start_time - tfm_player.registrationDate
	local account_age_days = (((account_age_ms / 1000) / 60) / 60) / 24
	return (account_age_days)
end



--- Check a possible guest player and ban him if necessary.
function pshy.AntiguestCheckPlayer(player_name)
	if pshy.banlist[player_name] then
		return
	end
	tfm_player = tfm.get.room.playerList[player_name]
	local account_age_days = pshy.AntiguestGetAccountAge(player_name)
	if pshy.antiguest_required_days >= 0 and string.sub(player_name, 1, 1) == "*" then
		pshy.BanPlayer(player_name)
		pshy.antiguest_banlist[player_name] = true
		tfm.exec.chatMessage("<r>[AntiGuest] Sorry, this room is set to deny guest accounts :c</r>", player_name)
		tfm.exec.chatMessage("<r>[AntiGuest] Also, this room is set to deny accounts of less than " .. tostring(pshy.antiguest_required_days) .. " days.</r>", player_name)
		pshy.Log("<j>[AntiGuest] " .. player_name .. " room banned (guest account)!</j>", player_name)
		return
	end
	if account_age_days < pshy.antiguest_required_days then
		pshy.BanPlayer(player_name)
		pshy.antiguest_banlist[player_name] = true
		tfm.exec.chatMessage("<r>[AntiGuest] Sorry, this room is set to deny accounts of less than " .. tostring(pshy.antiguest_required_days) .. " days :c</r>", player_name)
		pshy.Log("<j>[AntiGuest] " .. player_name .. " room banned (" .. tostring(account_age_days) .. " days account)!</j>", player_name)
		return
	end
end



--- TFM event eventNewPlayer 
function eventNewPlayer(player_name)
	pshy.AntiguestCheckPlayer(player_name)
end



--- TFM event eventPlayerLeft(player_name)
-- unban blocked guests who leave
function eventPlayerLeft(player_name)
	if pshy.antiguest_banlist[player_name] then
		pshy.UnbanPlayer(player_name)
		pshy.antiguest_banlist[player_name] = nil
	end
end



--- Initialization:
for player_name, player in pairs(tfm.get.room.playerList) do
	pshy.AntiguestCheckPlayer(player_name)
end
