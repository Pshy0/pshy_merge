--- pshy.bases.emoticons
--
-- Adds emoticons you can use with SHIFT and ALT.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script)
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")
local perms = pshy.require("pshy.perms")



--- Namespace.
local emoticons = {}



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Emoticons", text = "Adds custom emoticons\nUse keys F1 to F10 to use them. You may also use SHIFT or CTRL for more emoticons.\nIncludes emoticons from <ch>Nnaaaz#0000</ch>, <ch>Feverchild#0000</ch> and <ch>Rchl#3416</ch>\n"}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Module Settings:
perms.perms.everyone["emoticons"] = true	-- allow everybody to use emoticons
local emoticons_delay = 256					-- minimum delay between custom emoticons
local emoticons_mod1 = 16 					-- alternative emoji modifier key 1 (18 == ALT, SHIFT == 16)
local emoticons_mod2 = 17 					-- alternative emoji modifier key 2 (17 == CTRL)
--- Emoticon dictionary image -> code, x/y -> top left location, sx/sy -> scale):
emoticons.emoticons = {
	-- vanilla
	["vanilla_voiceless"]	= {image = "178ea94a353.png", x = -15, y = -57, sx = 0.9, sy = 0.9},
	["vanilla_vomit"]		= {image = "16f56cbc4d7.png", x = -14, y = -57},
	["vanilla_pinklove"]	= {image = "178ea9d7876.png", x = -15, y = -57, sx = 0.9, sy = 0.9},
	["vanilla_eyelove"]		= {image = "178ea9d947c.png", x = -15, y = -57, sx = 0.9, sy = 0.9},
	["vanilla_bigeyes"]		= {image = "178ea9d5bc3.png", x = -15, y = -57, sx = 0.9, sy = 0.9},
	-- from https://atelier801.com/topic?f=6&t=894050&p=1#m16
	["cry"]					= {image = "17088661168.png", x = -14, y = -57},
	["rogue"]				= {image = "16f5d8c7401.png", x = -14, y = -57},
	["lol"]					= {image = "16f56ce925e.png", x = -14, y = -57},
	["lol_2"]				= {image = "16f56d09dc2.png", x = -14, y = -57},
	["wonder"]				= {image = "16f56cdf28f.png", x = -14, y = -57},
	-- drawing, unknown author
	["mouse_asleep"]		= {image = "178eac181f1.png", x = -15, y = -57, sx = 0.9, sy = 0.9},
	-- rchl#0000, perm obtained
	["glasses"]				= {image = "178ebdf194a.png", x = -15, y = -59, sx = 0.9, sy = 0.9}, -- based on vanilla emoticon
	["glasses_2"]			= {image = "178ebdf317a.png", x = -15, y = -59, sx = 0.9, sy = 0.9}, -- based on vanilla emoticon
	["clown"]				= {image = "178ebdf0153.png", x = -15, y = -59, sx = 0.9, sy = 0.9},
	["pity_eyes"]			= {image = "178ebdf495d.png", x = -15, y = -59, sx = 0.9, sy = 0.9},
	["vomit"]				= {image = "178ebdee617.png", x = -15, y = -59, sx = 0.9, sy = 0.9}, -- redundant with vanilla but better
	["pity_legs"]			= {image = "17aa125e853.png", x = -15, y = -59, sx = 0.65, sy = 0.65}, -- redundant but good too
	-- feverchild#0000, perm obtained, https://discord.com/channels/246815328103825409/522398576706322454/834007372640419851
	["voiceless"]			= {image = "17aa1264731.png", x = -16, y = -61, sx = 0.61, sy = 0.61},
	["asleep"]				= {image = "17aa1265ea4.png", x = -16, y = -61, sx = 0.61, sy = 0.61},
	-- other emotes from https://webninjasi.github.io/tfm-luahelp/image.html
	["police"]				= {image = "17088637078.png", x = -15, y = -62},
	["sick"]				= {image = "16f56fa27ca.png", x = -15, y = -59},
	["pepe_surprised"]		= {image = "17d482d0006.png", x = -16, y = -60},
	["stonks"]				= {image = "17d482dd358.png", x = -14, y = -60},
	["esman"]				= {image = "17d4830d8f5.png", x = -13, y = -61},
	["gg"]					= {image = "17d4830c183.png", x = -12, y = -60},
	-- Nnaaaz#0000, request
	["pro"]					= {image = "17aa1bcf1d4.png", x = -20, y = -70, sx = 1, sy = 1, reserved = true},
	["pro2"]				= {image = "17aa1bd0944.png", x = -20, y = -70, sx = 1, sy = 1, reserved = true},
	["noob"]				= {image = "17aa1bd3a05.png", x = -30, y = -60, sx = 1, sy = 1, reserved = true},
	["noob2"]				= {image = "17aa1bd20b5.png", x = -30, y = -60, sx = 1, sy = 1, reserved = true},
	["cute"]				= {image = "17f7a2bf818.png", x = -35, y = -55, sx = 1, sy = 1, reserved = true},
	["cute2"]				= {image = "17f7a2c9215.png", x = -35, y = -55, sx = 1, sy = 1, reserved = true},
	["cutest"]				= {image = "17f7a2f6b53.png", x = -25, y = -55, sx = 1, sy = 1, reserved = true},
	-- other https://atelier801.com/topic?f=6&t=827044&p=1#m14
	["WTF_cat"]				= {image = "15565dbc655.png", x = -15, y = -65, sx = 0.75, sy = 0.75},
	["FUUU"]				= {image = "15568238225.png", x = -15, y = -60, sx = 0.75, sy = 0.75},
	["me_gusta"]			= {image = "155682434d5.png", x = -15, y = -60, sx = 0.75, sy = 0.75},
	["trollface"]			= {image = "1556824ac1a.png", x = -15, y = -60, sx = 0.75, sy = 0.75},
	["cheese_right"]		= {image = "155592fd7d0.png", x = -15, y = -55, sx = 0.50, sy = 0.50},
	["cheese_left"]			= {image = "155593003fc.png", x = -15, y = -55, sx = 0.50, sy = 0.50},
}
-- emoticons / index is (key_number + (100 * mod1) + (200 * mod2)) for up to 40 emoticons with only the numbers, ctrl and alt, including the defaults
emoticons.binds = {}
emoticons.binds[100] = "rogue"
emoticons.binds[101] = "wonder"
emoticons.binds[102] = "glasses_2"
emoticons.binds[103] = "lol"
emoticons.binds[104] = "cry"
emoticons.binds[105] = "voiceless"
emoticons.binds[105] = "asleep"
emoticons.binds[106] = "vomit"
emoticons.binds[108] = "pity_eyes"
emoticons.binds[109] = "clown"
emoticons.binds[200] = "vanilla_pinklove"
emoticons.binds[201] = "vanilla_voiceless"
emoticons.binds[202] = "vanilla_bigeyes"
emoticons.binds[203] = "vanilla_vomit"
emoticons.binds[204] = "vanilla_eyelove"
emoticons.binds[205] = "glasses"
emoticons.binds[206] = "lol_2"
emoticons.binds[207] = "sick"
emoticons.binds[208] = "police"
emoticons.binds[209] = "mouse_asleep"
emoticons.binds[300] = "trollface"
emoticons.binds[301] = "stonks"
emoticons.binds[302] = "WTF_cat"
emoticons.binds[303] = "FUUU"
emoticons.binds[304] = "me_gusta"
emoticons.binds[305] = "esman"
emoticons.binds[306] = "pepe_surprised"
emoticons.binds[307] = "cheese_right"
emoticons.binds[308] = "pity_legs"
emoticons.binds[309] = "gg"
-- @todo 30 available slots in total :>



-- Internal Use:
local emoticons_players_mod2 = {}				-- shift keys state
local emoticons_players_mod1 = {}				-- alt keys state
local emoticons_last_loop_time = 0				-- last loop time
local emoticons_players_image_ids = {}			-- the emote id started by the player
local emoticons_players_emoticon = {}			-- the current emoticon of players
local emoticons_players_end_times = {}			-- time at wich players started an emote / NOT DELETED
local emoticons_players_start_times = {}



--- Tell the script that a player used an emoticon.
-- Kill the player if they abuse too much.
-- @return false if the custom emoticon should be aborted (rate limit).
local function PlayedEmoticon(player_name)
	-- @todo implement
end



--- Listen for a players modifiers:
local function TouchPlayer(player_name)
	system.bindKeyboard(player_name, emoticons_mod1, true, true)
	system.bindKeyboard(player_name, emoticons_mod1, false, true)
	system.bindKeyboard(player_name, emoticons_mod2, true, true)
	system.bindKeyboard(player_name, emoticons_mod2, false, true)
	--for number = 0, 9 do -- numbers
	--	system.bindKeyboard(player_name, 48 + number, true, true)
	--end
	for number = 0, 9 do -- numpad numbers
		system.bindKeyboard(player_name, 96 + number, true, true)
	end
	for number = 0, 9 do -- F1- F10
		system.bindKeyboard(player_name, 112 + number, true, true)
	end
	emoticons_players_start_times[player_name] = os.time()
end



--- Stop an imoticon from playing over a player.
local function EmoticonsStop(player_name)
	if emoticons_players_image_ids[player_name] then
		tfm.exec.removeImage(emoticons_players_image_ids[player_name])
	end
	emoticons_players_end_times[player_name] = nil
	emoticons_players_image_ids[player_name] = nil
	emoticons_players_emoticon[player_name] = nil
end



--- Get an emoticon from name or bind index.
local function EmoticonsGetEmoticon(emoticon)
	if type(emoticon) == "number" then
		emoticon = emoticons.binds[emoticon]
	end
	if type(emoticon) == "string" then
		emoticon = emoticons.emoticons[emoticon]
	end
	return emoticon
end



--- Play an emoticon over a player.
-- Also removes the current one if being played.
-- Does nothing if the emoticon is invalid
-- @param player_name The name of the player.
-- @param emoticon Emoticon table, bind index, or name.
-- @param end_time Optional end time (relative to the current round).
local function EmoticonsPlay(player_name, emoticon, end_time)
	end_time = end_time or emoticons_last_loop_time + 4500
	if type(emoticon) ~= "table" then
		emoticon = EmoticonsGetEmoticon(emoticon)
	end
	if not emoticon then
		if emoticons_players_emoticon[player_name] and not emoticons_players_emoticon[player_name].keep then
			EmoticonsStop(player_name)
		end
		return
	end
	if emoticons_players_emoticon[player_name] ~= emoticon then
		if emoticons_players_image_ids[player_name] then
			tfm.exec.removeImage(emoticons_players_image_ids[player_name])
		end
		emoticons_players_image_ids[player_name] = tfm.exec.addImage(emoticon.image, (emoticon.replace and "%" or "$") .. player_name, emoticon.x, emoticon.y, nil, emoticon.sx or 1, emoticon.sy or 1)
		emoticons_players_emoticon[player_name] = emoticon
	end
	emoticons_players_start_times[player_name] = os.time()
	emoticons_players_end_times[player_name] = end_time
end



function eventNewGame()
	local timeouts = {}
	for player_name, end_time in pairs(emoticons_players_end_times) do
		timeouts[player_name] = true
	end
	for player_name in pairs(timeouts) do
		EmoticonsStop(player_name)
	end
	emoticons_last_loop_time = 0
end



function eventLoop(time, time_remaining)
	local timeouts = {}
	for player_name, end_time in pairs(emoticons_players_end_times) do
		if end_time < time then
			timeouts[player_name] = true
		end
	end
	for player_name in pairs(timeouts) do
		EmoticonsStop(player_name)
	end
	emoticons_last_loop_time = time
end



function eventKeyboard(player_name, key_code, down, x, y)
	if down then
		--elseif key_code >= 48 and key_code < 58 then -- numbers
		--	local index = (key_code - 48) + (emoticons_players_mod1[player_name] and 100 or 0) + (emoticons_players_mod2[player_name] and 200 or 0)
		--	emoticons_players_emoticon[player_name] = nil -- todo sadly, native emoticons will always replace custom ones
		--	EmoticonsPlay(player_name, index, emoticons_last_loop_time + 4500)
		local emoticon_index
		if key_code >= 112 and key_code < 122 then
			emoticon_index = (key_code - 112) + (emoticons_players_mod2[player_name] and 200 or (emoticons_players_mod1[player_name] and 300 or 100))
		elseif key_code >= 96 and key_code < 106 then
			emoticon_index = (key_code - 96) + (emoticons_players_mod2[player_name] and 200 or (emoticons_players_mod1[player_name] and 300 or 100))
		end
		if emoticon_index then -- numpad numbers
			if emoticons_players_start_times[player_name] + emoticons_delay > os.time() then
				return false
			end
			if not perms.HavePerm(player_name, "emoticons") then
				return
			end
			emoticons_players_emoticon[player_name] = nil -- todo sadly, native emoticons will always replace custom ones
			EmoticonsPlay(player_name, emoticon_index, emoticons_last_loop_time + 4500)
			return
		end
	end
	if key_code == emoticons_mod1 then
		emoticons_players_mod1[player_name] = down
	elseif key_code == emoticons_mod2 then
		emoticons_players_mod2[player_name] = down
	end
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
end



function eventInit()
	for player_name in pairs(tfm.get.room.playerList) do
		TouchPlayer(player_name)
	end
	if __IS_MAIN_MODULE__ then
		system.disableChatCommandDisplay(nil, true)
	end
end



__MODULE__.commands = {
	["emoticon"] = {
		aliases = {"em"},
		perms = "everyone",
		desc = "show an emoticon",
		argc_min = 1,
		argc_max = 2,
		arg_types = {"string", "player"},
		func = function(user, emoticon_name, target)
			if not target then
				target = user
			elseif not perms.HavePerm(user, "!emoticon-others") then
				return false, "You are not allowed to use this command on others :c"
			end
			EmoticonsPlay(target, emoticon_name, emoticons_last_loop_time + 4500)
			return true
		end
	},
	["emoticons"] = {
		perms = "admins",
		desc = "list hidden emoticons",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			tfm.exec.chatMessage("Available emoticons:", user)
			for emoticon_name in pairs(emoticons.emoticons) do
				tfm.exec.chatMessage(string.format(" - %s", emoticon_name), user)
			end
			return true
		end
	}
}



return emoticons

