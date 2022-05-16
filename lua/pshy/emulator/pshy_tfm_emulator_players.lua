--- pshy_tfm_emulator_players.lua
--
-- Simulate players.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_tfm_emulator_basic_environment.lua
--
-- @require_priority DEBUG
pshy = pshy or {}



--- Simulate a player being in the room when the script started.
function pshy.tfm_emulator_init_NewPlayer(joining_player_name, properties)
	-- add the new player
	tfm.get.room.playerList[joining_player_name] = {
		cheeses = 0;
		community = "int";
		gender = 0;
		hasCheese = false;
		id = 0;
		inHardMode = 0;
		isDead = true;
		isFacingRight = true;
		isInvoking = false;
		isJumping = false;
		isShaman = false;
		isVampire = false;
		language = int;
		look = "1;0,0,0,0,0,0,0,0,0";
		movingLeft = false;
		movingRight = false;
		playerName = joining_player_name;
		registrationDate = 1652691762994;
		score = 0;
		shamanMode = 0;
		spouseId = 1;
		spouseName = nil;
		title = 0;
		tribeId = nil;
		tribeName = nil;
		vx = 0;
		vy = 0;
		x = 0;
		y = 0;
	}
	if properties then
		local joining_player = new_player_map[joining_player_name]
		for p_name, p_value in pairs(properties) do
			joining_player[p_name] = p_value
		end
	end
end



--- Simulate a joining player.
-- @note The table is recreated because so do TFM.
function pshy.tfm_emulator_NewPlayer(joining_player_name, properties)
	-- change the player map reference:
	local old_player_map = tfm.get.room.playerList
	new_player_map = {}
	tfm.get.room.playerList = new_player_map
	for player_name, player in pairs(old_player_map) do
		new_player_map[player_name] = player
	end
	-- add the new player
	new_player_map[joining_player_name] = {
		cheeses = 0;
		community = "int";
		gender = 0;
		hasCheese = false;
		id = 0;
		inHardMode = 0;
		isDead = true;
		isFacingRight = true;
		isInvoking = false;
		isJumping = false;
		isShaman = false;
		isVampire = false;
		language = int;
		look = "1;0,0,0,0,0,0,0,0,0";
		movingLeft = false;
		movingRight = false;
		playerName = joining_player_name;
		registrationDate = 1652691762994;
		score = 0;
		shamanMode = 0;
		spouseId = 1;
		spouseName = nil;
		title = 0;
		tribeId = nil;
		tribeName = nil;
		vx = 0;
		vy = 0;
		x = 0;
		y = 0;
	}
	if properties then
		local joining_player = new_player_map[joining_player_name]
		for p_name, p_value in pairs(properties) do
			joining_player[p_name] = p_value
		end
	end
	-- event:
	if eventNewPlayer then
		eventNewPlayer(joining_player_name)
	end
end



--- Simulate a leaving player.
-- @note The table is recreated because so do TFM.
function pshy.tfm_emulator_PlayerLeft(leaving_player_name)
	-- change the player map reference:
	local old_player_map = tfm.get.room.playerList
	new_player_map = {}
	tfm.get.room.playerList = new_player_map
	for player_name, player in pairs(old_player_map) do
		new_player_map[player_name] = player
	end
	-- removing the player:
	new_player_map[leaving_player_name] = nil
	-- event:
	if eventPlayerLeft then
		eventPlayerLeft(leaving_player_name)
	end
end



--- Simulate a player obtaining the cheese.
function pshy.tfm_emulator_PlayerGetCheese(player_name)
	local player = tfm.get.room.playerList[player_name]
	player.hasCheese = true
	player.cheeses = player.cheeses + 1
	if eventPlayerGetCheese then
		eventPlayerGetCheese(player_name)
	end
end



--- Override `tfm.exec.giveCheese`
tfm.exec.giveCheese = function(player_name)
	pshy.tfm_emulator_PlayerGetCheese(player_name)
end



--- Override `tfm.exec.removeCheese`
tfm.exec.removeCheese = function(player_name)
	local player = tfm.get.room.playerList[player_name]
	player.hasCheese = true
	player.cheeses = player.cheeses + 1
end



--- Simulate a player dying.
function pshy.tfm_emulator_PlayerDied(player_name)
	local player = tfm.get.room.playerList[player_name]
	player.isDead = true
	if eventPlayerDied then
		eventPlayerDied(player_name)
	end
end



--- Override `tfm.exec.killPlayer`
tfm.exec.killPlayer = function(player_name)
	pshy.tfm_emulator_PlayerDied(player_name)
end



--- Simulate a player winning.
function pshy.tfm_emulator_PlayerWon(player_name)
	local player = tfm.get.room.playerList[player_name]
	player.isDead = true
	if eventPlayerWon then
		eventPlayerWon(player_name)
	end
end



--- Override `tfm.exec.playerVictory`
tfm.exec.playerVictory = function(player_name)
	local player = tfm.get.room.playerList[player_name]
	if player.hasCheese then
		pshy.tfm_emulator_PlayerWon(player_name)
	end
end
