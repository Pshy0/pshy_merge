--- pshy_requests.lua
--
-- Allow players to request room admins to use FunCorp-only commands on them.
--
-- @author TFM:Pshy#3753 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_nicks.lua
-- @require pshy_help.lua



--- Module Help Page:
pshy.help_pages["pshy_requests"] = {back = "pshy", title = "Requests", text = "Allow players to request room admins to use FunCorp-only commands on them.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_requests"] = pshy.help_pages["pshy_requests"]



--- Module Settings:
pshy.requests_modify_delay = 20 * 1000		-- delay before being able to modify a non accepted request
pshy.requests_types = {}					-- map of possible requests
pshy.requests_types["changenick"] = {name = "changenick", delay = 240 * 1000, players_next_use_time = {}, players_requests = {}}
pshy.requests_types["colornick"] = {name = "colornick", delay = 120 * 1000, players_next_use_time = {}, players_requests = {}}
pshy.requests_types["colormouse"] = {name = "colormouse", delay = 120 * 1000, players_next_use_time = {}, players_requests = {}}



--- Internal Use:
pshy.requests = {}							-- list of requests
pshy.requests_last_id = 0					-- next unique id to give to a request



--- Add a new player request.
-- @param player_name The Player#0000 name.
-- @param request_type The request type name
function pshy.requests_Add(player_name, request_type_name, value)
	assert(type(player_name) == "string")
	assert(type(request_type_name) == "string")
	local rt = pshy.requests_types[request_type_name]
	if rt.players_requests[player_name] then
		-- delete existing request
		local r = rt.players_requests[player_name]
		pshy.requests_Remove(r)
	end
	-- new request
	pshy.requests_last_id = pshy.requests_last_id + 1
	local r = {}
	r.id = pshy.requests_last_id
	r.request_type = rt
	r.value = value
	r.player_name = player_name
	rt.players_requests[player_name] = r
	table.insert(pshy.requests, r)
	return r.id
end



--- Remove a player request
-- @param r The player's request table.
function pshy.requests_Remove(r)
	assert(type(r) == "table")
	local index
	for i_request, request in ipairs(pshy.requests) do
		if request == r then
			index = i_request
			break
		end
	end
	r.request_type.players_requests[r.player_name] = nil
	table.remove(pshy.requests, index)
end



--- Get a player's request table from its id.
-- @param id The request's id.
-- @return The player's request table.
function pshy.requests_Get(id)
	for i_request, request in ipairs(pshy.requests) do
		if request.id == id then
			return request
		end
	end
end



--- !requestdeny <id> [reason]
function pshy.requests_ChatCommandRequestdeny(user, id, reason)
	local r = pshy.requests_Get(id)
	if not r then
		return false, "No request with id " .. tostring(id) .. "."
	end
	pshy.requests_Remove(r)
	if reason then
		tfm.exec.chatMessage("<r>Your " .. r.request_type.name .. " request have been denied (" .. reason .. ")</r>", r.player_name)
	else
		tfm.exec.chatMessage("<r>Your " .. r.request_type.name .. " request have been denied :c</r>", r.player_name)
	end
end
pshy.chat_commands["requestdeny"] = {func = pshy.requests_ChatCommandRequestdeny, desc = "deny a player's request for a FunCorp command", argc_min = 1, argc_max = 2, arg_types = {"number", "string"}}
pshy.help_pages["pshy_requests"].commands["requestdeny"] = pshy.chat_commands["requestdeny"]
pshy.perms.admins["!requestdeny"] = true



--- !requestaccept <id>
function pshy.requests_ChatCommandRequestaccept(user, id)
	local r = pshy.requests_Get(id)
	if not r then
		return false, "No request with id " .. tostring(id) .. "."
	end
	-- special case
	if r.request_type.name == "changenick" then
		pshy.nicks[r.player_name] = r.value
	end
	-- removing request
	pshy.requests_Remove(r)
	tfm.exec.chatMessage("<fc>Please Enter \t<b>/" .. r.request_type.name .. " <v>" .. r.player_name .. "</v> " .. r.value .. "</b></fc>", user)
	tfm.exec.chatMessage("<vp>Your " .. r.request_type.name .. " request have been accepted :></vp>", r.player_name)
	r.request_type.players_next_use_time[user] = os.time() + r.request_type.delay
end
pshy.chat_commands["requestaccept"] = {func = pshy.requests_ChatCommandRequestaccept, desc = "accept a player's request for a FunCorp command", argc_min = 1, argc_max = 1, arg_types = {"number"}}
pshy.help_pages["pshy_requests"].commands["requestaccept"] = pshy.chat_commands["requestaccept"]
pshy.perms.admins["!requestaccept"] = true



--- !requests
function pshy.requests_ChatCommandRequests(user)
	if #pshy.requests == 0 then
		tfm.exec.chatMessage("<vp>No pending request ;)</vp>", user)
		return
	end
	for i_request, request in ipairs(pshy.requests) do
		tfm.exec.chatMessage("<j>" .. request.id .. "</j>\t<d>/" .. request.request_type.name .. " <v>" .. request.player_name .. "</v> " .. request.value .. "</d>", user)
		if i_request == 8 then
			break
		end
	end
end
pshy.chat_commands["requests"] = {func = pshy.requests_ChatCommandRequests, desc = "show the oldest 8 requests", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_requests"].commands["requests"] = pshy.chat_commands["requests"]
pshy.perms.admins["!request"] = true



--- !request changenick|colornick|colormouse
function pshy.requests_ChatCommandRequest(user, request_type_name, value)
	-- get the request type
	local rt = pshy.requests_types[request_type_name]
	if not rt then
		return false, "Valid requests are changenick, colornick and colormouse."
	end
	local os_time = os.time()
	local delay = rt.players_next_use_time[user] and (rt.players_next_use_time[user] - os_time) or 0
	-- delay check
	if delay > 0 then
		return false, "You must wait " .. tostring(math.floor(delay / 1000)) .. " seconds before the next request."
	end
	-- proceed
	rt.players_next_use_time[user] = os_time + pshy.requests_modify_delay
	pshy.requests_Add(user, request_type_name, value)
	tfm.exec.chatMessage("<j>You will be notified when your " .. request_type_name .. " request will be approved or denied.</j>", user)
end
pshy.chat_commands["request"] = {func = pshy.requests_ChatCommandRequest, desc = "request a FunCorp command to be used on you", argc_min = 2, argc_max = 2, arg_types = {"string", "string"}, arg_names = {"changenick|colornick|colormouse"}}
pshy.perms.everyone["!request"] = true
pshy.help_pages["pshy_requests"].commands["request"] = pshy.chat_commands["request"]



--- !nick (same as `!request changenick <nickname>`)
function requests_ChatCommandNick(user, nickname)
	pshy.requests_ChatCommandRequest(user, "changenick", nickname)
end
--pshy.chat_commands["nick"] = {func = pshy.requests_ChatCommandNick, desc = "request a nick change", argc_min = 1, argc_max = 1, arg_types = {"string"}, arg_names = {"changenick|colornick|colormouse"}}
--pshy.perms.everyone["!nick"] = true
--pshy.help_pages["pshy_requests"].commands["nick"] = pshy.chat_commands["nick"]
