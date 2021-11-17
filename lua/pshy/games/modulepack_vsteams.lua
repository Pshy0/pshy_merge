--- modulepack_vsteams.lua
--
-- This module pack is based on the team vs module.
-- It also set the Normal mode to be 66% vanilla / 34% racing.
--
-- Type "!pshy.help" for a list of pshy commands.
-- Type "!pshy.help <command>" for help about a specific pshy command.
-- The vs module recognize "!help", but this will also be recognized by the pshy module.
--
-- The modules are merged using pshy_merge.
-- This mean that the final lua script contains every single whole module, unmodified.
--
-- @require pshy_anticheats.lua
-- @require pshy_bindkey.lua
-- @require pshy_bindmouse.lua
-- @require pshy_emoticons.lua
-- @require pshy_essentials.lua
-- @require pshy_fcplatform.lua
-- @require pshy_help.lua
-- @require pshy_lua_commands.lua
-- @require pshy_merge.lua
-- @require pshy_motd.lua
-- @require pshy_nicks.lua
-- @require pshy_rain.lua
-- @require mattseba_vs_teams_without_antimacro.lua



--- Module settings:
pshy.vs5050 = true			-- Auto change between vanilla/racing ?
pshy.vs_ratio = 0.66			-- ratio of vanilla map
pshy.perms.everyone["!nick"] = false	-- can players use !nick
pshy.perms.everyone["!nicks"] = true	-- can players use !nicks



--- Modulepack help page:
pshy.help_pages["vs"] = {back = "", title = "V/S Teams (module pack help)", text = "This module is a combination of pshy's module and mattseba's VS module.\n<u><a href='event:cmd help\nclose'>Click here to show the module help!</a></u>\n", examples = {}}
pshy.help_pages["vs"].examples["luaset pshy.vs5050 true"] = "Enable the vanilla/racing mode."
pshy.help_pages["vs"].examples["luaset pshy.vs_ratio 0.75"] = "Set 75% of vanilla map."
pshy.help_pages["vs"].examples["luaset pshy.vs_ratio 0.50"] = "Set 50% of vanilla map."
pshy.help_pages[""].subpages["vs"] = pshy.help_pages["vs"]



--- Internal use.
pshy.vs_vanilla_ratio_count = 0.0



--- TFM event eventNewGame
function eventNewGame()
    if pshy.vs5050 then
    	pshy.vs_vanilla_ratio_count = pshy.vs_vanilla_ratio_count + pshy.vs_ratio
    	if pshy.vs_vanilla_ratio_count >= 1 then
			pshy.vs_vanilla_ratio_count = pshy.vs_vanilla_ratio_count - 1
			Mode = "Vanilla"
		else
			Mode = "Racing"
		end
    end
end



--Mix = true
tfm.exec.chatMessage("<b><j>Type '!pshy.help vs' for help about this modulepack!</j></b>", pshy.host)
