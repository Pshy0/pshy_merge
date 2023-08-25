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
local auto_background = false
local players_to_display_background_to = {}



local backgrounds = {
	-- from https://webninjasi.github.io/tfm-luahelp/image.html
	{image = "166dc37c641.png", color = "#371743"};
	{image = "14e78118c13.jpg", color = "#22367f"};
	-- from trexexjc's ground is lava:
	{image = "17797e64da7.png", color = "#3b646d", sx = 0.5};
	{image = "17797f4e3d5.png", color = "#30445f", sx = 0.5};
	{image = "17797f50022.png", color = "#5f3e1c", sx = 0.5};
	{image = "17797f52874.png", color = "#8e9238", sx = 0.5};
	{image = "17797f54f94.png", color = "#443018", sx = 0.5};
	{image = "17797f58132.png", color = "#507ca9", sx = 0.5};
	--{image = "17797f59fb7.png", color = "#3b646d", sx = 0.5}; -- duplicate
	{image = "17797f5bbfa.png", color = "#7960ae", sx = 0.5};
	{image = "17797f5dc3c.png", color = "#b3a163", sx = 0.5};
	{image = "17797f6134e.png", color = "#3dd7eb", sx = 0.5};
	{image = "17797f63455.png", color = "#2a95e0", sx = 0.5};
	{image = "17797f64dbb.png", color = "#beb678", sx = 0.5};
	{image = "17797f667ac.png", color = "#315771", sx = 0.5};
	{image = "177f2ef5a32.png", color = "#59413c", sx = 0.5};
	{image = "177f2ef7c59.png", color = "#475d5c", sx = 0.5};
	{image = "177f2ef9fa4.png", color = "#131d20", sx = 0.5};
	{image = "177f2efe17e.png", color = "#4a7c4f", sx = 0.5};
	{image = "177f2f0038c.png", color = "#272330", sx = 0.5};
	{image = "177f2f02cdf.png", color = "#2a5052", sx = 0.5};
	{image = "177f2f063da.png", color = "#526879", sx = 0.5};
	--{image = "17864c917a9.png", color = "#3b646d", sx = 0.5}; -- bad
	{image = "1784a3ea316.png", color = "#de8062", sx = 0.5};
	{image = "1784a3ec88c.png", color = "#201b18", sx = 0.5};
	{image = "1784a3ee346.png", color = "#012d54", sx = 0.5};
	{image = "1784a3efc97.png", color = "#6eb7e3", sx = 0.5};
	{image = "1784a3f1a8f.png", color = "#674965", sx = 0.5};
	{image = "1784a3f3611.png", color = "#203038", sx = 0.5};
	{image = "1784a3f4fa1.png", color = "#bf1d3e", sx = 0.5};
	{image = "1784a3f68a0.png", color = "#424055", sx = 0.5};
	{image = "1784a3f8177.png", color = "#8dccde", sx = 0.5};
	{image = "1784a3f9c4d.png", color = "#6bcbf3", sx = 0.5};
	{image = "1784a3fb259.png", color = "#353f1d", sx = 0.5};
	{image = "1784a3fd2a2.png", color = "#512779", sx = 0.5};
	{image = "1784a3fefaa.png", color = "#b7b4d3", sx = 0.5};
	{image = "1784a4005b3.png", color = "#7ca65e", sx = 0.5};
	{image = "178fa86eeaa.png", color = "#7e5ab4", sx = 0.5};
	{image = "178fa86d772.png", color = "#78a0c3", sx = 0.5};
	{image = "178fa86c20d.png", color = "#d795a0", sx = 0.5};
	{image = "178fa86a901.png", color = "#905279", sx = 0.5};
	{image = "178fa869307.png", color = "#5fa3f4", sx = 0.5};
	-- uploaded by Darkkiyah (https://atelier801.com/topic?f=6&t=893819&p=3#m45)
	{image = "177a312dda6.jpg", color = "#084f46"};
	--{image = "177a3131d38.png", color = "#905279", sx = ?}; -- not scaled
	--{image = "177a3133176.jpg", color = "#5fa3f4", sx = ?}; -- not scaled
	-- uploaded by Iago#5826 (https://atelier801.com/topic?f=6&t=893819&p=8#m151)
	{image = "1793551dfae.png", color = "#62114c", sx = 0.8};
	--{image = "1793551f767.jpeg", color = "#5fa3f4", sx = 0.8}; -- tfm bug
	--{image = "17935520c9d.jpg", color = "#111825", sx = 0.8335}; -- has white border
	--{image = "17935523246.jpg", color = "#000000", sx = 0.3125}; -- bad
	-- referenced by Travonrodfer (https://atelier801.com/topic?f=6&t=877911#m6)
	{image = "14abae230c8.jpg", color = "#000035"};
	-- uploaded by Hufdasr#0000 (https://atelier801.com/topic?f=6&t=893819&p=9#m169)
	{image = "17975c69e48.png", color = "#776880"};
	-- uploaded by Hufdasr#0000 (https://atelier801.com/topic?f=6&t=893819&p=13#m252)
	{image = "17bc5838243.png", color = "#3a382d"};
	-- uploaded by Shadow#5397 (https://atelier801.com/topic?f=6&t=893819&p=16#m302)
	{image = "17c8e689b5b.png", color = "#362162"};
	-- uploaded by Jayd3n#2829 (https://atelier801.com/topic?f=6&t=893819&p=18#m343)
	{image = "17e973ba565.png", color = "#621b10", sx = 0.4168};
	--{image = "17e973bf5ae.png"}; -- too big
	--{image = "17e973c4fdd.png"}; -- too big
	{image = "17e973ca07f.png", color = "#050d12", sx = 0.417};
	{image = "17e973cf25b.png", color = "#00050b", sx = 0.417};
	{image = "17e973d451b.png", color = "#041213", sx = 0.417};
	--{image = "17e973da54f.png", color = "#000000", sx = 0.4165}; -- too big
	{image = "17e973df7ad.png", color = "#030303", sx = 0.4762};
	--{image = "17e973e456a.png", color = "#000000", sx = 0.4165}; -- too big
	-- Pshy#3752 (AI generated) - free to use in TFM scripts
	{image = "189f0510e74.png", color = "#9196bd", sx = 1.137}; -- epic
	{image = "189f030da2e.png", color = "#030303", sx = 1.137}; -- epic
	{image = "189f0585007.png", color = "#e0df92", sx = 1.137}; -- excellent
	{image = "189f04975b6.png", color = "#212e17", sx = 1.137}; -- excellent
	{image = "189f03beaaf.png", color = "#452814", sx = 1.137}; -- epic, not horizontal, colors: aa703d
	{image = "189f0599319.png", color = "#bfaaad", sx = 1.137}; -- epic, not horizontal
	{image = "189f05643cc.png", color = "#6789d0", sx = 1.137}; -- good
	{image = "189f05ecf80.png", color = "#8b6969", sx = 1.137}; -- good
	{image = "189f0608719.png", color = "#ab7e6b", sx = 1.137}; -- good
	{image = "189f04cb483.png", color = "#638d78", sx = 1.137}; -- good
	{image = "189f0783d76.png", color = "#466f9a", sx = 1.137}; -- good
	{image = "189f07b0700.png", color = "#93a1ba", sx = 1.137}; -- good, grayscale
	{image = "189f07f7831.png", color = "#4c6355", sx = 1.137}; -- good, make some items hard to see
	{image = "189f04b465b.png", color = "#9aa9b9", sx = 1.137}; -- good, does not fit all maps
	{image = "189f05d6d09.png", color = "#c6ad8d", sx = 1.137}; -- good, epic, not horizontal, fits little as a background
	{image = "189f0543813.png", color = "#d0b3f6", sx = 1.137}; -- average+, does not fit all maps
	{image = "189f04df2f2.png", color = "#8b743c", sx = 1.137}; -- average
	{image = "189f04fc06a.png", color = "#a9acc0", sx = 1.137}; -- average
	{image = "189f053244a.png", color = "#8f726e", sx = 1.137}; -- average
	{image = "189f05adb1b.png", color = "#5f64a8", sx = 1.137}; -- average, does not fit all maps
	{image = "189f044359d.png", color = "#cd643c", sx = 1.137}; -- good but does not fit right in tfm
	{image = "189f05bef8e.png", color = "#4a5060", sx = 1.137}; -- average, does not fit tfm
	-- uploaded by Jayd3n#2829 (https://atelier801.com/topic?f=6&t=893819&p=21#m419)
	-- TODO
	-- uploaded by Kytroxz#2950 (https://atelier801.com/topic?f=6&t=893819&p=23#m459)
	-- TODO
	-- uploaded by Homerre#0000 (https://atelier801.com/topic?f=6&t=893819&p=29#m578)
	-- TODO
	
}



local function ChangeBackground(image_name, color, sx, sy)
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
		sx = sx or background.sx
		sy = sy or background.sy
	end
	sx = sx or 1
	sy = sy or sx
	if color then
		ui.setBackgroundColor(color)
	end
	if current_background_id then
		tfm.exec.removeImage(current_background_id)
	end
	for player_name in pairs(players_to_display_background_to) do
		current_background_id = tfm.exec.addImage(image_name, "?1", 0, 0, player_name, sx, sy, 0, 1, 0, 0, false)
	end
	return true
end



__MODULE__.commands = {
	["background"] = {
		aliases = {"bg"},
		perms = "everyone",
		desc = "Toggles whether you see the background images.",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"boolean"},
		arg_names = {"see the background image?"},
		func = function(user, enable_bg)
			if enable_bg == nil then
				enable_bg = not players_to_display_background_to[user]
			end
			players_to_display_background_to[user] = enable_bg and true or nil
			if enable_bg then
				return true, "Enabled background images"
			else
				return true, "Disabled background images"
			end
		end
	},
	["listbackgrounds"] = {
		aliases = {"lsbg"},
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
	["changebackground"] = {
		aliases = {"chbg"},
		perms = "admins",
		desc = "Display an image in the background.",
		argc_min = 1,
		argc_max = 4,
		arg_types = {"string", "color", "number", "number"},
		arg_names = {"image name or background index", "border color", "sx", "sy"},
		func = function(user, image_name, color, sx, sy)
			local success, msg = ChangeBackground(image_name, color, sx, sy)
			if not success then
				return false, msg
			end
			return true, string.format("Displayed %s", image_name)
		end
	},
	["changebackgroundcolor"] = {
		aliases = {"chbgcolor", "chbgc"},
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
	},
	["autobackground"] = {
		aliases = {"autobg"},
		perms = "admins",
		desc = "toggles automatic background images",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"boolean"},
		func = function(user, enabled)
			if enabled == nil then
				enabled = not auto_background
			end
			auto_background = enabled
			if auto_background then
				return true, "Enabled automatic background images"
			else
				return true, "Disabled automatic background images"
			end
		end
	}
}



function eventNewGame()
	current_background_id = nil
	if auto_background then
		local background_index = math.random(1, #backgrounds)
		ChangeBackground(background_index)
	end
end



function eventNewPlayer(player_name)
	players_to_display_background_to[player_name] = true
end



function eventPlayerLeft(player_name)
	players_to_display_background_to[player_name] = nil
end



for player_name in pairs(tfm.get.room.playerList) do
	eventNewPlayer(player_name)
end
