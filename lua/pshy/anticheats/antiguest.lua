--- pshy.anticheats.antiguest
--
-- Antoban guests and new players from the room.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local adminchat = pshy.require("pshy.anticheats.adminchat")
local ban = pshy.require("pshy.anticheats.ban")
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", restricted = true, title = "AntiGuest", text = "Require players to use an account of a specific age for playing.\n", examples = {}}
help_pages[__MODULE_NAME__].commands = {}
help_pages[__MODULE_NAME__].examples["antiguestdays -1"] = "allow guests and new accounts"
help_pages[__MODULE_NAME__].examples["antiguestdays 0"] = "disallow guests but allow new accounts"
help_pages[__MODULE_NAME__].examples["antiguestdays 0.25"] = "disallow guests and accounts of less than 6 hours"
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



local antiguest = {}



--- Module Settings:
antiguest.required_days = 0		-- required play time, or 0 to only prevent guests from joining, or -1 to disable



--- Action to take when the player is disallowed.
-- You can change this if needed from another module.
antiguest.DisallowedPlayerAction = function(player_name, reason, message)
	ban.KickPlayer(player_name, reason)
	tfm.exec.chatMessage(string.format("<b><r>%s</r></b>", message), player_name)
	adminchat.Message("AntiGuest", string.format("%s script-kicked: %s", player_name, reason))
end



--- Internal use:
antiguest.start_time = os.time()



--- Get an account age in days.
-- @param player_name The player's Name#0000.
-- @return How old is the account, in days.
local function GetAccountAge(player_name)
	local tfm_player = tfm.get.room.playerList[player_name]
	local account_age_ms = antiguest.start_time - tfm_player.registrationDate
	local account_age_days = (((account_age_ms / 1000) / 60) / 60) / 24
	return (account_age_days)
end



--- Check a possible guest player and ban him if necessary.
-- @param player_name The player's Name#0000.
local function KickPlayerIfGuest(player_name)
	local tfm_player = tfm.get.room.playerList[player_name]
	if antiguest.required_days == 0 and string.sub(player_name, 1, 1) == "*" then
		antiguest.DisallowedPlayerAction(player_name, "Guest account.",
			"This room does not allow guest accounts, nor accounts that were created after the script started.")
	elseif antiguest.required_days >= 0 then
		if string.sub(player_name, 1, 1) == "*" then
			antiguest.DisallowedPlayerAction(player_name, "Guest account.",
				string.format("Your account needs to be %f days old to play in this room.", antiguest.required_days))
		else
			local account_age_days = GetAccountAge(player_name)
			if account_age_days < 0 then
				antiguest.DisallowedPlayerAction(player_name, "Just-created account.",
					string.format("This room does not allow accounts that were created after the script started.", antiguest.required_days))
			elseif account_age_days < antiguest.required_days then
				antiguest.DisallowedPlayerAction(player_name, string.format("%f days old account.", account_age_days),
					string.format("Your account needs to be %f days old to play in this room.", antiguest.required_days))
			end
		end
	end
end



function eventNewPlayer(player_name)
	KickPlayerIfGuest(player_name)
end



function eventInit()
	for player_name in pairs(tfm.get.room.playerList) do
		KickPlayerIfGuest(player_name)
	end
end



__MODULE__.commands = {
	["antiguestdays"] = {
		perms = "admins",
		desc = "See or set how old an account should be to play in this room (in days, -1 to disable).",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"number"},
		func = function(user, days)
			antiguest.required_days = days or antiguest.required_days
			if antiguest.required_days > 0 then
				adminchat.Message("AntiGuest", string.format("Accounts must now be %f days old to play in this room.", days))
			elseif antiguest.required_days == 0 then
				adminchat.Message("AntiGuest", "Accounts must now be non-guest to play in this room.")
			else
				adminchat.Message("AntiGuest", "All accounts can now play in this room.")
			end
			for player_name in pairs(tfm.get.room.playerList) do
				KickPlayerIfGuest(player_name)
			end
			return true
		end
	}
}



return antiguest
