--- pshy.compiler.tfmenv
--
-- Provides a basic TFM environment.
-- This should be enough to simulate a TFM module initialization.
--
-- Call `tfmenv.SetLauncher(name)` to set who made the script start/opened the module room.
-- Call `tfmenv.SetLoader(name)` to set the script loader/module host (optional).
-- Call `tfmenv.SetPlayer(name, table)` to add a player (optional, automatic for the loader).
-- The environment is accessible as `tfmenv.env`.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local html_ansi = pshy and pshy.require("pshy.enums.html_ansi") or nil



--- Namespace.
local tfmenv = {}



--- Internal Use:
local dummy = function() end
local next_player_id = 8776
local loader_was_set = false



--- Public Members:
tfmenv.launcher = "Loader#0000"
tfmenv.loader = "Loader#0000"
tfmenv.sync = "Loader#0000"



--- Basic environment.
tfmenv.env = {
	assert = assert;
	bit32 = bit32;
	coroutine = coroutine;
	debug = {
		disableEventLog = dummy;
		disableTimerLog = dummy;
		getCurrentThreadName = dummy;
		traceback = debug.traceback;
	};
	error = error;
	getmetatable = getmetatable;
	ipairs = ipairs;
	math = math;
	next = next;
	os = {
		date = os.date;
		difftime = os.difftime;
		time = os.time;
	};
	pairs = pairs;
	pcall = pcall;
	print = print;
	rawequal = rawequal;
	rawget = rawget;
	rawlen = rawlen;
	rawset = rawset;
	select = select;
	setmetatable = setmetatable;
	string = string;
	system = {
		bindKeyboard = dummy;
		bindMouse = dummy;
		disableChatCommandDisplay = dummy;
		exit = dummy;
		giveEventGift = dummy;
		loadFile = dummy;
		loadPlayerData = dummy;
		luaEventLaunchInterval = dummy;
		newTimer = dummy;
		openEventShop = dummy;
		removeTimer = dummy;
		saveFile = dummy;
		savePlayerData = dummy;
		setLuaEventBanner = dummy;
	};
	table = table;
	tfm = {
		enum = {
			bonus = {
				point = 0;
				speed = 1;
				death = 2;
				spring = 3;
				booster = 5;
				electricArc = 6;
			};
			emote = {
				dance = 0;
				laugh = 1;
				cry = 2;
				kiss = 3;
				angry = 4;
				clap = 5;
				sleep = 6;
				facepaw = 7;
				sit = 8;
				confetti = 9;
				flag = 10;
				marshmallow = 11;
				selfie = 12;
				highfive = 13;
				highfive_1 = 14;
				highfive_2 = 15;
				partyhorn = 16;
				hug = 17;
				hug_1 = 18;
				hug_2 = 19;
				jigglypuff = 20;
				kissing = 21;
				kissing_1 = 22;
				kissing_2 = 23;
				carnaval = 24;
				rockpaperscissors = 25;
				rockpaperscissors_1 = 26;
				rockpaperscissor_2 = 27;
			};
			ground = {
				wood = 0;
				ice = 1;
				trampoline = 2;
				lava = 3;
				chocolate = 4;
				earth = 5;
				grass = 6;
				sand = 7;
				cloud = 8;
				water = 9;
				stone = 10;
				snow = 11;
				rectangle = 12;
				circle = 13;
				invisible = 14;
				web = 15;
				yellowGrass = 17;
				pinkGrass = 18;
				acid = 19;
			};
			particle = {
				whiteGlitter = 0;
				blueGlitter = 1;
				orangeGlitter = 2;
				cloud = 3;
				dullWhiteGlitter = 4;
				heart = 5;
				bubble = 6;
				tealGlitter = 9;
				spirit = 10;
				yellowGlitter = 11;
				ghostSpirit = 12;
				redGlitter = 13;
				waterBubble = 14;
				plus1 = 15;
				plus10 = 16;
				plus12 = 17;
				plus14 = 18;
				plus16 = 19;
				meep = 20;
				redConfetti = 21;
				greenConfetti = 22;
				blueConfetti = 23;
				yellowConfetti = 24;
				diagonalRain = 25;
				curlyWind = 26;
				wind = 27;
				rain = 28;
				star = 29;
				littleRedHeart = 30;
				littlePinkHeart = 31;
				daisy = 32;
				bell = 33;
				egg = 34;
				projection = 35;
				mouseTeleportation = 36;
				shamanTeleportation = 37;
				lollipopConfetti = 38;
				yellowCandyConfetti = 39;
				pinkCandyConfetti = 40;
			};
			shamanObject = {
				arrow = 0;
				littleBox = 1;
				box = 2;
				littleBoard = 3;
				board = 4;
				ball = 6;
				trampoline = 7;
				anvil = 10;
				cannon = 17;
				bomb = 23;
				orangePortal = 26;
				blueBalloon = 28;
				redBalloon = 29;
				greenBalloon = 30;
				yellowBalloon = 31;
				rune = 32;
				chicken = 33;
				snowBall = 34;
				cupidonArrow = 35;
				apple = 39;
				sheep = 40;
				littleBoardIce = 45;
				littleBoardChocolate = 46;
				iceCube = 54;
				cloud = 57;
				bubble = 59;
				tinyBoard = 60;
				companionCube = 61;
				stableRune = 62;
				balloonFish = 65;
				longBoard = 67;
				triangle = 68;
				sBoard = 69;
				paperPlane = 80;
				rock = 85;
				pumpkinBall = 89;
				tombstone = 90;
				paperBall = 95;
			};
		};
		exec = {
			addBonus = dummy;
			addConjuration = dummy;
			addImage = dummy;
			addJoint = dummy;
			addNPC = dummy;
			addPhysicObject = dummy;
			addShamanObject = dummy;
			attachBalloon = dummy;
			bindKeyboard = dummy;
			changePlayerSize = dummy;
			chatMessage = dummy;
			disableAfkDeath = dummy;
			disableAllShamanSkills = dummy;
			disableAutoNewGame = dummy;
			disableAutoScore = dummy;
			disableAutoShaman = dummy;
			disableAutoTimeLeft = dummy;
			disableDebugCommand = dummy;
			disableMinimalistMode = dummy;
			disableMortCommand = dummy;
			disablePhysicalConsumables = dummy;
			disablePrespawnPreview = dummy;
			disableWatchCommand = dummy;
			displayParticle = dummy;
			explosion = dummy;
			freezePlayer = dummy;
			getPlayerSync = dummy;
			giveCheese = dummy;
			giveConsumables = dummy;
			giveMeep = dummy;
			giveTransformations = dummy;
			killPlayer = dummy;
			linkMice = dummy;
			lowerSyncDelay = dummy;
			moveObject = dummy;
			movePhysicObject = dummy;
			movePlayer = dummy;
			newGame = dummy;
			playEmote = dummy;
			playerVictory = dummy;
			removeBonus = dummy;
			removeCheese = dummy;
			removeImage = dummy;
			removeJoint = dummy;
			removeObject = dummy;
			removePhysicObject = dummy;
			respawnPlayer = dummy;
			setAieMode = dummy;
			setAutoMapFlipMode = dummy;
			setGameTime = dummy;
			setNameColor = dummy;
			setPlayerGravityScale = dummy;
			setPlayerNightMode = dummy;
			setPlayerScore = dummy;
			setPlayerSync = dummy;
			setRoomMaxPlayers = dummy;
			setRoomPassword = dummy;
			setShaman = dummy;
			setShamanMode = dummy;
			setUIMapName = dummy;
			setUIShamanName = dummy;
			setVampirePlayer = dummy;
			setWorldGravity = dummy;
			snow = dummy;
		};
		get = {
			misc = {
				apiVersion = 0.28;
				transformiceVersion = 8.05;
			};
			room = {
				community = "int";
				currentMap = 0;
				isTribeHouse = false;
				maxPlayers = 50;
				mirroredMap = false;
				name = "@Test";
				objectList = {};
				passwordProtected = false;
				playerList = {};
			};
		};
	};
	tonumber = tonumber;
	tostring = tostring;
	type = type;
	ui = {
		addPopup = dummy;
		addTextArea = dummy;
		removeTextArea = dummy;
		setBackgroundColor = dummy;
		setMapName = dummy;
		setShamanName = dummy;
		showColorPicker = dummy;
		updateTextArea = dummy;
	};
	xpcall = xpcall;
}
tfmenv.env._G = tfmenv.env



--- Default player.
tfmenv.player = {
	cheeses = 0;
	community = "en";
	gender = 0;
	hasCheese = false;
	id = nil;
	inHardMode = 0;
	isDead = true;
	isFacingRight = true;
	isInvoking = false;
	isJumping = false;
	isShaman = false;
	isVampire = false;
	language = "int";
	look = "1;0,0,0,0,0,0,0,0,0";
	movingLeft = false;
	movingRight = false;
	playerName = nil;
	registrationDate = 1652691762994;
	score = 0;
	shamanMode = 0;
	spouseId = 1;
	spouseName = nil;
	title = 0;
	tribeId = 1234;
	tribeName = "Kikoo";
	vx = 0;
	vy = 0;
	x = 0;
	y = 0;
}



--- Internal Use:
local lua_assert = assert
local lua_getmetatable = getmetatable
local lua_pcall = pcall
local lua_print = print
local lua_setmetatable = setmetatable
local lua_string_format = string.format
local lua_tostring = tostring
local lua_type = type



--- Adds ansi colors from TFM html codes (approximative)
local function ToANSI(text)
	if not html_ansi then
		return text
	end
	for markup, ansi in pairs(html_ansi) do
		text = text:gsub("<" .. markup .. ">", "\x1B[" .. ansi .. "<" .. markup .. ">")
	end
	text = text:gsub("</", "</\x1B[" .. html_ansi["bl"])
	return "\x1B[" .. html_ansi["bl"] .. text .. "\x1B[0m"
end



--- Reimplemntation of `debug.getCurrentThreadName`.
-- Always returns 'Module'.
tfmenv.env.debug.getCurrentThreadName = function()
	return "Module"
end



--- Reimplementation of `getmetatable`.
-- Only accepts tables.
tfmenv.env.getmetatable = function(t)
	lua_assert(lua_type(t) == "table")
	return lua_getmetatable(t)
end



--- Reimplementation of `pcall`:
tfmenv.env.pcall = function(...)
	local rst, msg = lua_pcall(...)
	if rst == false then
		msg = "Pshy#3752.lua:0: " .. msg
	end
	return rst, msg
end



--- Reimplementation of `print`:
tfmenv.env.print = function(o1, ...)
	if o1 ~= nil then
		return lua_print("#lua:   • # " .. ToANSI(tostring(o1)), ...)
	else
		return lua_print("#lua:   • # nil")
	end
end



--- Reimplementation of `setmetatable`.
-- Only accepts tables.
tfmenv.env.setmetatable = function(t, mt)
	lua_assert(lua_type(t) == "table")
	return lua_setmetatable(t, mt)
end



--- Reimplementation of `string.format`:
tfmenv.env.string.format = function(fmt, ...)
	return lua_string_format(string.gsub(fmt, "%%d", "%%.0f"), ...)
end



--- Reimplementation of `system.exit`.
-- Supposed to exit, but throw an error durring emulation.
tfmenv.env.system.exit = function(arg)
	error("Called `system.exit`: " .. tostring(arg))
end



--- Reimplementation of `table.foreach`.
-- Run a function for all keys in a table.
tfmenv.env.table.foreach = table.foreach or function(t, f)
	for i_item, item in pairs(t) do
		f(i_item, item)
	end
end



--- Reimplementation of `table.foreachi`.
-- Run a function for all numeric keys in a table.
tfmenv.env.table.foreachi = table.foreachi or function(t, f)
	for i_item, item in ipairs(t) do
		f(i_item, item)
	end
end



--- Reimplementation of `tfm.exec.chatMessage`.
tfmenv.env.tfm.exec.chatMessage = function(msg, user)
	if user == nil then
		lua_print("#room:  " .. ToANSI(tostring(msg)))
	elseif user == pshy.tfm_emulator_loader then
		lua_print("*room:  " .. ToANSI(tostring(msg)))
	end
end



--- Reimplementation of `tfm.exec.getPlayerSync`.
tfmenv.env.tfm.exec.getPlayerSync = function()
	return tfmenv.sync
end



--- Reimplementation of `tfm.exec.setPlayerSync`.
tfmenv.env.tfm.exec.setPlayerSync = function(player_name)
	if tfmenv.env.tfm.get.room.playerList[player_name] then
		tfmenv.sync = player_name
	end
end



--- Set the script launcher in the environment.
-- Also sets a default player for this loader.
function tfmenv.SetLauncher(launcher_name)
	tfmenv.launcher = tfmenv.launcher or launcher_name
	if not loader_was_set == true then
		tfmenv.loader = tfmenv.launcher
	end
	tfmenv.sync = tfmenv.launcher
	tfmenv.SetPlayer(launcher_name)
end



--- Set the script loader in the environment.
function tfmenv.SetLoader(loader_name)
	tfmenv.loader = tfmenv.loader or loader_name
	loader_was_set = true
end



--- Add a player to the environment.
function tfmenv.SetPlayer(player_name, player_table)
	player_table = player_table or {}
	player_table.playerName = player_table.playerName or player_name
	if not player_table.id then
		player_table.id = next_player_id
		next_player_id = next_player_id + 15
	end
	for p_name, p_value in pairs(tfmenv.player) do
		if not player_table[p_name] then
			player_table[p_name] = p_value
		end
	end
	tfmenv.env.tfm.get.room.playerList[player_name] = player_table
end



return tfmenv
