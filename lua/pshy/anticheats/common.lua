--- pshy.anticheats.common
--
-- Base for anticheats module.
-- This mainly provide the common help page.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.anticheats.ban")
local help_pages = pshy.require("pshy.help.pages")
local perms = pshy.require("pshy.perms")



--- Module Help Page.
help_pages["pshy_anticheats"] = {text = "Contains several anticheat scripts and related features.", restricted = true, commands = {}, subpages = {}}
help_pages["pshy_anticheats"].restricted = true
help_pages["pshy_anticheats"].back = "pshy"
help_pages["pshy_anticheats"].title = "Anticheats"
help_pages["pshy"].subpages["pshy_anticheats"] = help_pages["pshy_anticheats"]



--- Ban Page:
help_pages["pshy_anticheats"].subpages["pshy_ban"] = help_pages["pshy_ban"]



function eventInit()
	if perms.cheats_enabled then
		pshy.adminchat_Message("Anticheat", "<b>YOU HAVE ENABLED AN ANTICHEAT IN A SCRIPT THAT IS ALLOWING CHEATS!!!</b>")
	end
end
