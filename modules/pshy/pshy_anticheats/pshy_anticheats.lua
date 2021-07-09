--- pshy_anticheats.lua
--
-- Modulepack containing all pshy's anticheat modules.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @hardmerge
-- @namespace pshy
-- @require pshy_ban.lua
-- @require pshy_antileve.lua
-- @require pshy_antimacro.lua
-- @require pshy_antihack.lua
-- @require pshy_antiguest.lua



--- Module Help Page:
-- All anticheats use this page.
pshy.help_pages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"] or {text = "", commands = {}, subpages = {}}
pshy.help_pages["pshy_anticheats"].restricted = true
pshy.help_pages["pshy_anticheats"].back = "pshy"
pshy.help_pages["pshy_anticheats"].text = "Gather anticheat features.\n" .. pshy.help_pages["pshy_anticheats"].text
pshy.help_pages["pshy"].subpages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"]
