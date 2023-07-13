--- pshy.tools.requests
--
-- Allow players to request room admins to use FunCorp-only commands on them.
--
-- @author TFM:Pshy#3753 DC:Pshy#7998
local adminchat = pshy.require("pshy.anticheats.adminchat")
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")
local players = pshy.require("pshy.players")
local player_list = players.list			-- optimization



--- Namespace.
local requests = {}



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Requests", text = "Allow players to request room admins to use FunCorp-only commands on them.\n"}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Module Settings:
requests.delay = 30							-- seconds to wait between requests
requests.count = 3								-- how many requests can be done before being limited by the delay
requests.changenick_insert_old_name = true		-- if true, the old nickname is inserted in place of the player's tag
requests.changenick_length_min = 1				-- minimum length for nicks
requests.changenick_length_min = 24			-- maximul length for nicks



--- Tell the script an user have used a request command.
-- @return The amount of seconds the player needs to wait, or 0.
local function PopRequestDelay(player_name)
	local player = player_list[player_name]
	local os_time = os.time()
	if player.request_next_time == nil or player.request_next_time < os_time then
		player.request_next_time = os_time
	end
	local diff = player.request_next_time - os_time
	local wait_time = math.max(0, diff - requests.delay * requests.count)
	if wait_time == 0 then
		player.request_next_time = player.request_next_time + requests.delay
	end
	return wait_time
end



__MODULE__.commands = {
	["colornick"] = {
		perms = "everyone",
		desc = "Choose a color for your nickname (a FunCorp will run the command).",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"color"},
		func = function(user, color)
			if PopRequestDelay(user) > 0 then
				return false, string.format("You must wait %d seconds before using this command again.")
			end
			adminchat.Message(nil, string.format("<j>/colornick %s <font color='#%06x'>#%06x</font>", user, color, color))
			return true, "Request received, your nickname color should be changed soon."
		end
	},
	["colormouse"] = {
		perms = "everyone",
		desc = "Choose a color for your mouse fur (a FunCorp will run the command).",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"color"},
		func = function(user, color)
			if PopRequestDelay(user) > 0 then
				return false, string.format("You must wait %d seconds before using this command again.")
			end
			adminchat.Message(nil, string.format("<j>/colormouse %s <font color='#%06x'>#%06x</font>", user, color, color))
			return true, "Request received, your mouse color should be changed soon."
		end
	},
	["changenick"] = {
		perms = "everyone",
		desc = "Choose a nickname (a FunCorp will run the command).",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"string"},
		func = function(user, nickname)
			if #nickname < requests.changenick_length_min then
				return false, "This nickname is too short."
			end
			if #nickname > requests.changenick_length_max then
				return false, "This nickname is too long."
			end
			if string.match(nickname, "#") then
				return false, "Your nickname cannot contain '#'."
			end
			local delay = PopRequestDelay(user)
			if PopRequestDelay(user) > 0 then
				return false, string.format("You must wait %d seconds before using this command again.")
			end
			if requests.changenick_insert_old_name then
				nickname = nickname .. "#" .. nickname
			end
			adminchat.Message(nil, string.format("<j>/changenick %s %s", user, nickname))
			return true, "Request received, your nickname should be changed soon."
		end
	},
}



return requests
