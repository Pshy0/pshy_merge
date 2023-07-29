--- pshy.commands.list.background
--
-- Commands that change the background.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local help_pages = pshy.require("pshy.help.pages")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Background", text = "Change the background."}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.require("pshy.commands.get_target_or_error")



local current_background_id = nil



local backgrounds = {
	-- from https://webninjasi.github.io/tfm-luahelp/image.html
	{image = "166dc37c641.png", color = "#371743"};
	{image = "14e78118c13.jpg", color = "#22367f"};
}



__MODULE__.commands = {
	["backgrounds"] = {
		perms = "admins",
		desc = "List indexed backgrounds.",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			for i_background, background in ipairs(backgrounds) do
				tfm.exec.chatMessage(string.format("%d\t- %s %s", i_background, background.image, background.color or "NA"), user)
			end
			return true
		end
	},
	["background"] = {
		aliases = {"bg"},
		perms = "admins",
		desc = "Display an image in the background.",
		argc_min = 1,
		argc_max = 4,
		arg_types = {"string", "color", "number", "number"},
		arg_names = {"image name or background index", "border color", "sx", "sy"},
		func = function(user, image_name, color, sx, sy)
			if type(color) == "number" then
				color = string.format("#%.6x", color)
			end
			local index = tonumber(image_name)
			if index then
				local background = backgrounds[index]
				if not background then
					return false, string.format("Invalid background index. It must be between 1 and %d!", #backgrounds)
				end
				image_name = background.image
				color = color or background.color
				sx = sx or background.sx or 1
				sy = sy or background.sy or sx
			end
			if color then
				ui.setBackgroundColor(color)
			end
			if current_background_id then
				tfm.exec.removeImage(current_background_id)
			end
			current_background_id = tfm.exec.addImage(image_name, "?1", 0, 0, nil, sx, sy, 0, 1, 0, 0, false)
			return true, string.format("Displayed %s", image_name)
		end
	},
	["backgroundcolor"] = {
		aliases = {"bgcolor", "bgc"},
		perms = "admins",
		desc = "set background color",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"color"},
		arg_names = {"background_color"},
		func = function(user, color)
			assert(type(color) == "number")
			ui.setBackgroundColor(string.format("#%06x", color))
		end
	}
}



function eventNewGame()
	current_background_id = nil
end
