--- pshy.bases.hasfuncorpvariant
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
local room = pshy.require("pshy.room")



local ns = {}



ns.funcorp_variant = false



local fc_variant_available_disclaimer = "<font color='#ff8000'><b>Non-FunCorp Script.</b></font>\n\nA FunCorp-Only variant of this script, with anticheat features, is available.\nYou may ask Pshy#3752 to obtain it.\n\nYou may still run the current script durring an animation, but those features will be missing."
local fc_is_variant_disclaimer = "<b><font color='#ff00ff'>/!\\ This script is <font color='#ff8000'>FUNCORP-ONLY</font>!</font></b>\n\n<font color='#ff0000'>It contains code that must not be shared with players.</font>"



function eventInit()
	if room.is_funcorp and not ns.funcorp_variant then
		ui.addPopup(-1, 0, fc_variant_available_disclaimer, room.loader, 300, 150, 200, true)
	elseif ns.funcorp_variant then
		ui.addPopup(-1, 0, fc_is_variant_disclaimer, room.loader, 300, 150, 200, true)
		print("<o><b>/!\\ FunCorp-only script! /!\\</b></o>", room.loader)
	end
	tfm.exec.getPlayerSync()
	if not room.is_funcorp and ns.funcorp_variant then
		eventNewGame = system.exit
	end
end



return ns
