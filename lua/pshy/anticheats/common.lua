--- pshy.anticheats.common
--
-- Base for anticheats module.
-- This mainly provide the common help page.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local adminchat = pshy.require("pshy.anticheats.adminchat")
local ban = pshy.require("pshy.anticheats.ban")
local help_pages = pshy.require("pshy.help.pages")
local perms = pshy.require("pshy.perms")



--- Module Help Page.
help_pages[__MODULE_NAME__] = {text = "Contains several anticheat scripts and related features.", restricted = true, commands = {}, subpages = {}}
help_pages[__MODULE_NAME__].restricted = true
help_pages[__MODULE_NAME__].back = "pshy"
help_pages[__MODULE_NAME__].title = "Anticheats"
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Ban Page:
help_pages[__MODULE_NAME__].subpages["pshy.anticheats.ban"] = help_pages["pshy.anticheats.ban"]



function eventInit()
	if perms.cheats_enabled then
		adminchat.Message("Anticheat", "<b>YOU HAVE ENABLED AN ANTICHEAT IN A SCRIPT THAT IS ALLOWING CHEATS!!!</b>")
	end
end
