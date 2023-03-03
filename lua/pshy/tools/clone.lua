--- pshy.tools.clone
--
-- Spawn a clone of yourself.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local command_list = pshy.require("pshy.commands.list")
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Clone", text = "Clone yourself.\n", examples = {}}
help_pages[__MODULE_NAME__].commands = {}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- !clone
local function ChatCommandMotd(user, count, target)
	target = target or user
	count = count or 1
	assert(count > 0)
	assert(count <= 20)
	local tfm_player = tfm.get.room.playerList[user]
	local spawn_name
	for i = 1, count do
		local spawn_x
		local spawn_y
		local left
		if i == 1 then
			spawn_name = user
			spawn_x = tfm_player.x
			spawn_y = tfm_player.y
			left = tfm_player.facingLeft
		else
			spawn_x = math.random(0, 800)
			spawn_y = math.random(0, 800)
			left = (math.random(0, 1) == 0)
		end
		tfm.exec.addNPC(spawn_name, {title = tfm_player.title, look = tfm_player.look, x = spawn_x, y = spawn_y, female = (tfm_player.gender == 2), lookLeft = left})
		spawn_name = " " .. spawn_name .. " "
	end
end
command_list["clone"] = {perms = "admins", func = ChatCommandMotd, desc = "Clone yourself.", argc_min = 0, argc_max = 1, arg_types = {'number', 'player'}}
help_pages[__MODULE_NAME__].commands["clone"] = command_list["clone"]
