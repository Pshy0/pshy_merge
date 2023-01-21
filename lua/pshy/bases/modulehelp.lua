--- pshy.bases.modulehelp
--
-- Adds a button to show a customizable help image.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
local ids = pshy.require("pshy.utils.ids")
local command_list = pshy.require("pshy.commands.list")
pshy.require("pshy.ui.v1")



local namespace = {}



--- Module Settings:
namespace.help_button_x = 10
namespace.help_button_y = 10
namespace.help_button_w = 38
namespace.help_button_h = 38
namespace.help_button_image = "1810297bd81.png"
namespace.help_image = "180a9f1cf9c.png"
namespace.help_image_x = 200
namespace.help_image_y = 50
namespace.close_button_x = 560
namespace.close_button_y = 70
namespace.close_button_w = 30
namespace.close_button_h = 30



local help_btn_id = ids.AllocTextAreaId()
local close_help_btn_id = ids.AllocTextAreaId()



local modulehelp_images = {}



local function TouchPlayer(player_name)
	tfm.exec.addImage(namespace.help_button_image, ":0", namespace.help_button_x, namespace.help_button_y, player_name)
	ui.addTextArea(help_btn_id, "<p align='center'><font size='128'><a href='event:pcmd modulehelp'>        </a></font></p>", player_name, namespace.help_button_x, namespace.help_button_y, namespace.help_button_w, namespace.help_button_h, 0xff0000, 0xff0000, 0.02, true)
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
end



function eventInit()
	for player_name, player in pairs(tfm.get.room.playerList) do
		TouchPlayer(player_name)
	end
end



--- !modulehelp
local function ChatCommandModulehelp(user)
	if modulehelp_images[user] then
		tfm.exec.removeImage(modulehelp_images[user])
		modulehelp_images[user] = nil
		ui.removeTextArea(close_help_btn_id, user)
	else
		modulehelp_images[user] = tfm.exec.addImage(namespace.help_image, ":0", namespace.help_image_x, namespace.help_image_y, user)
		ui.addTextArea(close_help_btn_id, "<p align='center'><font size='128'><a href='event:pcmd modulehelp'>        </a></font></p>", user, namespace.close_button_x, namespace.close_button_y, namespace.close_button_w, namespace.close_button_h, 0xff0000, 0xff0000, 0.02, true)		
	end
	return true
end
command_list["modulehelp"] = {perms = "everyone", func = ChatCommandModulehelp, desc = "Show the module help.", argc_min = 0, argc_max = 0}



return namespace
