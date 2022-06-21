--- pshy.tools.entibot
--
-- This script from entibo allows to run maps directly from miceditor.
-- See `https://entibo.github.io/miceditor/`.
--
-- @author TFM:Shize#0000 DC:entibo#5742 (script and bot)
pshy.require("pshy.events")



-- Feel free to customize this module
-- This is the minimum code required to make the bot work
local botName = "Entibot#5692"
system.disableChatCommandDisplay("You", true)

function eventNewPlayer(name)
  if name == botName then
      ui.addPopup(5692, 2, "xml", botName)
  end
end

function eventPopupAnswer(id, name, str)
  if id == 5692 and name == botName then
      tfm.exec.newGame(str)
  end
end
