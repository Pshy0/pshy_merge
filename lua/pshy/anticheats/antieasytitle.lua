--- pshy.anticheats.antieasytitle
--
-- Antokick players with some titles.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local adminchat = pshy.require("pshy.anticheats.adminchat")
local ban = pshy.require("pshy.anticheats.ban")
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", restricted = true, title = "AntiTitle", text = "Require players to use an account of a specific age for playing.\n", examples = {}}
help_pages[__MODULE_NAME__].commands = {}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Namespace.
local antieasytitle = {}
antieasytitle.enabled = false



--- Internal use:
local easy_titles = {
	[0] = true;		-- default
	[1] = true;		-- 10 saves
	[5] = true;		-- 5 c
	[6] = true;		-- 20 c
	[7] = true;		-- 100 c
	[9] = true;		-- 1 fc
	[10] = true;	-- 10 fc
	[11] = true;	-- 100 fs
	[115] = true;	-- 1 item
	[116] = true;	-- 2 items
	[117] = true;	-- 5 items
	[118] = true;	-- 10 items
	[256] = true;	-- 1 bc
	[257] = true;	-- 3 bc
	[258] = true;	-- 5 bc
	[259] = true;	-- 7 bc
	[260] = true;	-- 10 bc
	[261] = true;	-- 15 bc
	[262] = true;	-- 20 bc
}



--- Action to take when the player is disallowed.
-- You can change this if needed from another module.
antieasytitle.DisallowedPlayerAction = function(player_name)
	ban.KickPlayer(player_name, "Easy Title.")
	adminchat.Message("AntiTitle", string.format("%s not allowed (easy title)!", player_name))
	tfm.exec.chatMessage(string.format("<b><r>Please rejoin the room after picking a title that is harder to obtain.</r></b>", reason), player_name)
end



--- Check that a player made some progress in the game before allowing them to play.
-- @param player_name The player's Name#0000.
local function CheckPlayer(player_name)
	local tfm_player = tfm.get.room.playerList[player_name]
	if not antieasytitle.enabled then
		return
	end
	-- Hard mode implies that some progress have been made
	if tfm_player.shamanMode > 0 or tfm_player.inHardMode then
		return true
	end
	-- Check the title
	local title = tfm.get.room.playerList[player_name]
	if easy_titles[title] then
		antieasytitle.DisallowedPlayerAction(player_name)
	end
end



function eventNewPlayer(player_name)
	CheckPlayer(player_name)
end



function eventInit()
	for player_name in pairs(tfm.get.room.playerList) do
		CheckPlayer(player_name)
	end
end



__MODULE__.commands = {
	["antieasytitle"] = {
		perms = "admins",
		desc = "Prevent accounts with easy-to-get titles from playing.",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"bool"},
		func = function(user, enabled)
			antieasytitle.enabled = enabled
			adminchat.Message("AntiTitle", "Accounts with easy titles are " .. (enabled and "no longer" or "now") .. " allowed.")
			return true
		end
	}
}



return antieasytitle
