--- pshy_requests.lua
--
-- Allow players to request room admins to use FunCorp-only commands on them.
--
-- @author TFM:Pshy#3753 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_adminchat.lua
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_players.lua
--
-- @require_priority UTILS



--- Module Help Page:
pshy.help_pages["pshy_requests"] = {back = "pshy", title = "Requests", text = "Allow players to request room admins to use FunCorp-only commands on them.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_requests"] = pshy.help_pages["pshy_requests"]



--- Module Settings:
pshy.requests_delay = 30							-- seconds to wait between requests
pshy.requests_count = 3								-- how many requests can be done before being limited by the delay
pshy.requests_changenick_insert_old_name = true		-- if true, the old nickname is inserted in place of the player's tag
pshy.requests_changenick_length_min = 1				-- minimum length for nicks
pshy.requests_changenick_length_min = 24			-- maximul length for nicks



--- Tell the script an user have used a request command.
-- @return The amount of seconds the player needs to wait, or 0.
local function PopRequestDelay(player_name)
	local player = pshy.players[player_name]
	local os_time = os.time()
	if player.request_next_time == nil or player.request_next_time < os_time then
		player.request_next_time = os_time
	end
	local diff = player.request_next_time - os_time
	local wait_time = math.max(0, diff - pshy.requests_delay * pshy.requests_count)
	if wait_time == 0 then
		player.request_next_time = player.request_next_time + pshy.requests_delay
	end
	return wait_time
end



--- !colornick
local function ChatCommandColornick(user, color)
	if PopRequestDelay(user) > 0 then
		return false, string.format("You must wait %d seconds before using this command again.")
	end
	pshy.adminchat_Message(nil, string.format("<j>/colornick %s <font color='#%06x'>#%06x</font>", user, color, color))
	return true, "Request received, your nickname color should be changed soon."
end
pshy.commands["colornick"] = {func = ChatCommandColornick, desc = "Choose a color for your nickname (a FunCorp will run the command).", argc_min = 1, argc_max = 1, arg_types = {"color"}}
pshy.help_pages["pshy_requests"].commands["colornick"] = pshy.commands["colornick"]
pshy.perms.everyone["!colornick"] = true



--- !colormouse
local function ChatCommandColormouse(user, color)
	if PopRequestDelay(user) > 0 then
		return false, string.format("You must wait %d seconds before using this command again.")
	end
	pshy.adminchat_Message(nil, string.format("<j>/colormouse %s <font color='#%06x'>#%06x</font>", user, color, color))
	return true, "Request received, your mouse color should be changed soon."
end
pshy.commands["colormouse"] = {func = ChatCommandColormouse, desc = "Choose a color for your mouse fur (a FunCorp will run the command).", argc_min = 1, argc_max = 1, arg_types = {"color"}}
pshy.help_pages["pshy_requests"].commands["colormouse"] = pshy.commands["colormouse"]
pshy.perms.everyone["!colormouse"] = true



--- !changenick
local function ChatCommandChangenick(user, nickname)
	if #nickname < pshy.requests_changenick_length_min then
		return false, "This nickname is too short."
	end
	if #nickname > pshy.requests_changenick_length_max then
		return false, "This nickname is too long."
	end
	if string.match(nickname, "#") then
		return false, "Your nickname cannot contain '#'."
	end
	local delay = PopRequestDelay(user)
	if PopRequestDelay(user) > 0 then
		return false, string.format("You must wait %d seconds before using this command again.")
	end
	if pshy.requests_changenick_insert_old_name then
		nickname = nickname .. "#" .. nickname
	end
	pshy.adminchat_Message(nil, string.format("<j>/changenick %s %s", user, nickname))
	return true, "Request received, your nickname should be changed soon."
end
pshy.commands["changenick"] = {func = ChatCommandChangenick, desc = "Choose a nickname (a FunCorp will run the command).", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_requests"].commands["changenick"] = pshy.commands["changenick"]
pshy.perms.everyone["!changenick"] = true
