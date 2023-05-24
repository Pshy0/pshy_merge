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
local function ChatCommandClones(user, target, count)
	target = target or user
	count = count or 1
	if count < 1 or count > 20 then
		return false, "Please pick a number between 1 and 20."
	end
	local tfm_player = tfm.get.room.playerList[target]
	local spawn_name = target
	for i = 1, count do
		local spawn_x
		local spawn_y
		local left
		if i == 1 then
			spawn_x = tfm_player.x
			spawn_y = tfm_player.y
			left = not tfm_player.isFacingRight
		else
			spawn_x = math.random(tfm_player.x - 400, tfm_player.x + 400)
			spawn_y = math.random(tfm_player.y - 200, tfm_player.y + 200)
			left = (math.random(0, 1) == 0)
		end
		tfm.exec.addNPC(spawn_name, {title = tfm_player.title, look = tfm_player.look, x = spawn_x, y = spawn_y, female = (tfm_player.gender == 2), lookLeft = left})
		spawn_name = "​<wbr>" .. spawn_name
	end
end
command_list["clone"] = {perms = "admins", func = ChatCommandClones, desc = "Clone yourself.", argc_min = 0, argc_max = 2, arg_types = {'player', 'number'}}
help_pages[__MODULE_NAME__].commands["clone"] = command_list["clone"]



--- !rmclone
local function ChatCommandRmclones(user, target, count)
	target = target or user
	count = count or 1
	if count < 1 or count > 20 then
		return false, "Please pick a number between 1 and 20."
	end
	local spawn_name = target
	for i = 1, count do
		local spawn_x = -1000
		local spawn_y = -1000
		tfm.exec.addNPC(spawn_name, {x = spawn_x, y = spawn_y})
		spawn_name = "​<wbr>" .. spawn_name
	end
end
command_list["rmclone"] = {perms = "admins", func = ChatCommandRmclones, desc = "Remove clones.", argc_min = 0, argc_max = 2, arg_types = {'player', 'number'}}
help_pages[__MODULE_NAME__].commands["rmclone"] = command_list["rmclone"]
