--- pshy.commands.tp
--
-- Commands to teleport.
--
-- @author DC:Pshy#7998 TFM:Pshy#3752
pshy.require("pshy.commands")



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.commands_GetTargetOrError



--- !tpp (teleport to player)
local function ChatCommandTpp(user, destination, target)
	target = GetTarget(user, target, "!tpp")
	destination = pshy.FindPlayerNameOrError(destination)
	tfm.exec.movePlayer(target, tfm.get.room.playerList[destination].x, tfm.get.room.playerList[destination].y, false, 0, 0, true)
	return true, string.format("Teleported %s to %s.", target, destination)
end
pshy.commands["tpp"] = {func = ChatCommandTpp, desc = "teleport to a player", argc_min = 1, argc_max = 2, arg_types = {"player", "player"}, arg_names = {"destination", "target_player"}}
pshy.help_pages["pshy_speedfly"].commands["tpp"] = pshy.commands["tpp"]
pshy.perms.cheats["!tpp"] = true
pshy.perms.admins["!tpp-others"] = true



--- !tpl (teleport to location)
local function ChatCommandTpl(user, x, y, target)
	target = GetTarget(user, target, "!tpl")
	tfm.exec.movePlayer(target, x, y, false, 0, 0, true)
	return true, string.format("Teleported %s to %d; %d.", target, x, y)
end
pshy.commands["tpl"] = {func = ChatCommandTpl, desc = "teleport to a location", argc_min = 2, argc_max = 3, arg_types = {"number", "number", "player"}, arg_names = {"x", "y", "target_player"}}
pshy.help_pages["pshy_speedfly"].commands["tpl"] = pshy.commands["tpl"]
pshy.perms.cheats["!tpl"] = true
pshy.perms.admins["!tpl-others"] = true



--- !coords
local function ChatCommandCoords(user)
	local tfm_player = tfm.get.room.playerList[user]
	return true, string.format("Coordinates: (%d; %d).", tfm_player.x, tfm_player.y)
end
pshy.commands["coords"] = {func = ChatCommandCoords, desc = "get your coordinates", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_speedfly"].commands["coords"] = pshy.commands["coords"]
pshy.perms.cheats["!coords"] = true
