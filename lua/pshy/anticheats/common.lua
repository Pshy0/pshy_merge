--- pshy.anticheats.common
--
-- Base for anticheats module.
-- This mainly provide the common help page.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.bases.doc")
pshy.require("pshy.anticheats.ban")



--- Module Help Page.
pshy.help_pages["pshy_anticheats"] = {text = "Contains several anticheat scripts and related features.", restricted = true, commands = {}, subpages = {}}
pshy.help_pages["pshy_anticheats"].restricted = true
pshy.help_pages["pshy_anticheats"].back = "pshy"
pshy.help_pages["pshy_anticheats"].title = "Anticheats"
pshy.help_pages["pshy"].subpages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"]



--- Ban Page:
pshy.help_pages["pshy_anticheats"].subpages["pshy_ban"] = pshy.help_pages["pshy_ban"]



function eventInit()
	if pshy.perms_cheats_enabled then
		pshy.adminchat_Message("Anticheat", "<b>YOU HAVE ENABLED AN ANTICHEAT IN A SCRIPT THAT IS ALLOWING CHEATS!!!</b>")
	end
end
