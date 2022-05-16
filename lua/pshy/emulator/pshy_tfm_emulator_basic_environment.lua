--- pshy_tfm_emulator_basic_environment.lua
--
-- Define basic values and placeholder functions accessible to TFM modules.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require_priority DEBUG
pshy = pshy or {}



--- Dummy function that does nothing.
function pshy.tfm_emulator_dummy_function()
end



--- Internal Use:
local f = pshy.tfm_emulator_dummy_function



--- Basic composents of the tfm Lua API:
debug.disableEventLog = f;
debug.disableTimerLog = f;
debug.getCurrentThreadName = debug.getCurrentThreadName or f;
system = {
  bindKeyboard = f;
  bindMouse = f;
  disableChatCommandDisplay = f;
  exit = f;
  giveEventGift = f;
  loadFile = f;
  loadPlayerData = f;
  luaEventLaunchInterval = f;
  newTimer = f;
  openEventShop = f;
  removeTimer = f;
  saveFile = f;
  savePlayerData = f;
  setLuaEventBanner = f;
};
table.foreach = table.foreach or f;
table.foreachi = table.foreach or f;
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
    addBonus = f;
    addConjuration = f;
    addImage = f;
    addJoint = f;
    addNPC = f;
    addPhysicObject = f;
    addShamanObject = f;
    attachBalloon = f;
    bindKeyboard = f;
    changePlayerSize = f;
    chatMessage = f;
    disableAfkDeath = f;
    disableAllShamanSkills = f;
    disableAutoNewGame = f;
    disableAutoScore = f;
    disableAutoShaman = f;
    disableAutoTimeLeft = f;
    disableDebugCommand = f;
    disableMinimalistMode = f;
    disableMortCommand = f;
    disablePhysicalConsumables = f;
    disablePrespawnPreview = f;
    disableWatchCommand = f;
    displayParticle = f;
    explosion = f;
    freezePlayer = f;
    getPlayerSync = f;
    giveCheese = f;
    giveConsumables = f;
    giveMeep = f;
    giveTransformations = f;
    killPlayer = f;
    linkMice = f;
    lowerSyncDelay = f;
    moveObject = f;
    movePhysicObject = f;
    movePlayer = f;
    newGame = f;
    playEmote = f;
    playerVictory = f;
    removeBonus = f;
    removeCheese = f;
    removeImage = f;
    removeJoint = f;
    removeObject = f;
    removePhysicObject = f;
    respawnPlayer = f;
    setAieMode = f;
    setAutoMapFlipMode = f;
    setGameTime = f;
    setNameColor = f;
    setPlayerGravityScale = f;
    setPlayerNightMode = f;
    setPlayerScore = f;
    setPlayerSync = f;
    setRoomMaxPlayers = f;
    setRoomPassword = f;
    setShaman = f;
    setShamanMode = f;
    setUIMapName = f;
    setUIShamanName = f;
    setVampirePlayer = f;
    setWorldGravity = f;
    snow = f;
  };
  get = {
    misc = {
      apiVersion = 0.28;
      transformiceVersion = 8;
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
ui = {
  addPopup = f;
  addTextArea = f;
  removeTextArea = f;
  setBackgroundColor = f;
  setMapName = f;
  setShamanName = f;
  showColorPicker = f;
  updateTextArea = f;
};



--- Returen the string "Module".
if debug.getCurrentThreadName == f then
	debug.getCurrentThreadName = function()
		return "Module"
	end
end



--- Supposed to exit, but throw an error durring emulation.
if system.exit == f then
	system.exit = function(arg)
		error("Called `system.exit`: " .. tostring(arg))
	end
end



--- Run a function for all keys in a table.
if table.foreach == f then
	table.foreach = function(t, f)
		for i_item, item in pairs(t) do
			f(t)
		end
	end
end



--- Run a function for all numeric keys in a table.
if table.foreachi == f then
	table.foreachi = function(t, f)
		for i_item, item in ipairs(t) do
			f(t)
		end
	end
end



--- `pcall` override:
local original_pcall = pcall
pcall = function(...)
	local rst, msg = original_pcall(...)
	if rst == false then
		msg = "Pshy#3752.lua:0: " .. msg
	end
	return rst, msg
end



--- `string.format` override:
local original_string_format = string.format
string.format = function(fmt, ...)
	return original_string_format(string.gsub(fmt, "%%d", "%%f"), ...)
end
