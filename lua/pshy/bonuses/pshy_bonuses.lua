--- pshy_bonus.lua
--
-- Add custom bonuses.
--
-- Either use `pshy.bonuses_SetList()` to set the current bonus list.
-- Or add them individually with `pshy.bonuses_Add()`.
--
-- Fields:
--	x (bonus only):				int, bonus location
--	y (bonus only):				int, bonus location
--	image:						string, bonus image name in pshy_imagedb
--	func:						function to call when the bonus is picked
--								if func returns false then the bonus will not be considered picked by the script (but TFM will)
--	shared:						bool, do this bonus disapear when picked by any player
--	remain:						bool, do this bonus never disapear, even when picked
--	enabled (bonus only):		if this bonus is enabled/visible by default
--	autorespawn (bonus only):	bool, do this respawn automatically
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @optional_require pshy_ban.lua
-- @optional_require pshy_deathmaze_anticheat_ext.lua
-- @require pshy_imagedb_bonuses.lua
-- @require pshy_merge.lua
-- @require pshy_print.lua
-- @require pshy_utils_tables.lua
--
-- @require_priority UTILS
pshy = pshy or {}



--- Bonuses behaviors.
_G.PSHY_BONUS_BEHAVIOR_STANDARD = nil	-- Standard bonus that can be taken once per player.
_G.PSHY_BONUS_BEHAVIOR_SHARED = 1		-- Shared bonus that disapear for everyone if someone takes it.
_G.PSHY_BONUS_BEHAVIOR_REMAIN = 2		-- Bonus that cannot be taken but still does its effect to players passing on it.
_G.PSHY_BONUS_BEHAVIOR_RESPAWN = 3		-- Standard bonus that respawn when the player respawn.
local PSHY_BONUS_BEHAVIOR_STANDARD = _G.PSHY_BONUS_BEHAVIOR_STANDARD
local PSHY_BONUS_BEHAVIOR_SHARED = _G.PSHY_BONUS_BEHAVIOR_SHARED
local PSHY_BONUS_BEHAVIOR_REMAIN = _G.PSHY_BONUS_BEHAVIOR_REMAIN
local PSHY_BONUS_BEHAVIOR_RESPAWN = _G.PSHY_BONUS_BEHAVIOR_RESPAWN



--- Temporary function to convert from the old format to the new one.
local function ConvertBonus(bonus)
	if type(bonus.type) == "table" then
		bonus.type_name = bonus.type_name or "UNKNOWN"
	elseif type(bonus.type) == "string" then
		bonus.type_name = bonus.type
		bonus.type = nil
	end
	if not bonus.type then
		bonus.type = pshy.bonuses_types[bonus.type_name]
		assert(bonus.type, string.format("bonus type %s not found", bonus.type_name))
	end
	if not bonus.behavior then
		if bonus.shared or bonus.type.shared then
			bonus.behavior = PSHY_BONUS_BEHAVIOR_SHARED
		elseif bonus.remain or bonus.type.remain then
			bonus.behavior = PSHY_BONUS_BEHAVIOR_REMAIN
		elseif bonus.respawn or bonus.type.respawn then
			bonus.behavior = PSHY_BONUS_BEHAVIOR_RESPAWN
		end
	end
	assert(bonus.type)
	assert(bonus.type_name)
end



--- Bonus types.
-- @public
-- List of bonus types and informations.
pshy.bonuses_types = {}						-- default bonus properties



--- Bonus List.
-- Keys: The bonus ids.
-- Values: A table with the folowing fields:
--	- type: Bonus type, as a table.
--	- x: Bonus coordinates.
--	- y: Bonus coordinates.
--	- enabled: Is it enabled by default (true == always, false == never/manual, nil == once only).
pshy.bonuses_list	= {}					-- list of ingame bonuses
local bonuses_taken	= {}					-- set of taken bonus indices (non-shared bonuses use a table)



--- Internal Use:
local bonuses_list = pshy.bonuses_list
local players_image_ids = {}					-- Table of players's list of bonus image ids.
local shared_image_ids = {}						-- List of shared bonuses image ids.
local delayed_player_bonuses_refresh = {}		-- Per-player lists of bonuses to readd to the map.
local taken_shared_bonuses = {}					-- Map of taken shared bonuses.
local players_taken_bonuses = {}				-- Per-player map of taken bonuses.



--- Set the list of bonuses, and show them.
-- @public
function pshy.bonuses_SetList(bonus_list)
	-- @TODO: why enabling all bonuses, even `enabled == false` ones ?
	DisableAllBonuses()
	pshy.bonuses_list = pshy.ListCopy(bonus_list)
	bonuses_list = pshy.bonuses_list
	for bonus_id, bonus in ipairs(bonuses_list) do
		ConvertBonus(bonus)
	end
	EnableAllBonuses()
end



--- Create and enable a bonus.
-- @public
-- Either use this function or `pshy.bonuses_SetList`, but not both.
-- @param bonus_type The name or table corresponding to the bonus type.
-- @param bonus_x The bonus location.
-- @param bonus_y The bonus location.
-- @param enabled Is the bonus enabled for all players by default (nil is yes but not for new players).
-- @return The id of the created bonus.
function pshy.bonuses_Add(bonus_type_name, bonus_x, bonus_y, bonus_enabled, angle)
	return pshy.bonuses_AddNoCopy({type_name = bonus_type_name, x = bonus_x, y = bonus_y, enabled = bonus_enabled, angle = angle or 0})
end



--- Add a compy of a bonus to the map,.
function pshy.bonuses_AddCopy(bonus)
	return pshy.bonuses_AddNoCopy(pshy.TableCopy(bonus))
end



--- Add a bonus to the map.
function pshy.bonuses_AddNoCopy(bonus)
	-- converty bonus type
	ConvertBonus(bonus)
	-- id
	bonus.id = #pshy.bonuses_list + 1
	-- insert
	pshy.bonuses_list[bonus.id] = bonus
	-- enable/show
	if bonus.enabled ~= false then
		pshy.bonuses_Enable(bonus.id)
	end
	bonus.angle = bonus.angle or 0
	return bonus.id
end



--- Enable a bonus.
-- @public
-- When a bonus is enabled, it can be picked by players.
function pshy.bonuses_Enable(bonus_id, player_name)
	assert(type(bonus_id) == "number")
	if player_name == nil then
		for player_name in pairs(tfm.get.room.playerList) do
			pshy.bonuses_Enable(bonus_id, player_name)
		end
		return
	end
	if not players_image_ids[player_name] then
		players_image_ids[player_name] = {}
	end
	local bonus = pshy.bonuses_list[bonus_id]
	local ids = players_image_ids[player_name]
	-- get bonus type
	local bonus_type = bonus.type
	-- if already shown
	if ids[bonus_id] ~= nil then
		tfm.exec.removeBonus(bonus_id, player_name) -- @TODO: this may need to be run anyway
		tfm.exec.removeImage(ids[bonus_id])
	end
	-- add bonus
	tfm.exec.addBonus(0, bonus.x, bonus.y, bonus_id, 0, false, player_name)
	-- add image
	local bonus_image = bonus.image or bonus_type.image
	local bonus_foreground = bonus.foreground or bonus_type.foreground
	if bonus_image then
		ids[bonus_id] = pshy.imagedb_AddImage(bonus_image, bonus_foreground and "!9999" or "?9999", bonus.x, bonus.y, player_name, nil, nil, (bonus.angle or 0) * math.pi * 2 / 360, 1.0)
	end
	-- reenabling a bonus cause it to be non-taken
	if (bonus.bahavior or bonus_type.behavior) == PSHY_BONUS_BEHAVIOR_SHARED then
		taken_shared_bonuses[bonus_id] = nil
	else
		if players_taken_bonuses[player_name] then
			players_taken_bonuses[player_name][bonus_id] = nil
		end
	end
end



--- Hide a bonus.
-- @public
-- This prevent the bonus from being picked, without deleting it.
function pshy.bonuses_Disable(bonus_id, player_name)
	assert(type(bonus_id) == "number")
	if player_name == nil then
		for player_name in pairs(tfm.get.room.playerList) do
			pshy.bonuses_Disable(bonus_id, player_name)
		end
		return
	end
	if not players_image_ids[player_name] then
		return
	end
	local bonus = pshy.bonuses_list[bonus_id]
	local ids = players_image_ids[player_name]
	-- if already hidden
	if ids[bonus_id] == nil then
		return
	end
	-- remove bonus
	tfm.exec.removeBonus(bonus_id, player_name)
	-- remove image
	tfm.exec.removeImage(ids[bonus_id])
end



--- Show all bonuses.
local function EnableAllBonuses()
	for bonus_id, bonus in pairs(pshy.bonuses_list) do
		pshy.bonuses_Enable(bonus_id, player_name)
	end
end



--- Disable all bonuses for all players.
local function DisableAllBonuses()
	for bonus_id, bonus in pairs(pshy.bonuses_list) do
		pshy.bonuses_Disable(bonus_id, player_name)
	end
end



--- TFM event eventPlayerBonusGrabbed.
function eventPlayerBonusGrabbed(player_name, id)
	-- test for invalid ids
	if id < 1 or id > #pshy.bonuses_list then
		print_warn("%s grabbed a bonus with id %d", player_name, id)
		return
	end
	-- getting the bonus	
	local bonus = pshy.bonuses_list[id]
	if not bonus then
		print_error("%s grabbed non-existing bonus with id %d", player_name, id)
		return
	end
	-- getting bonus type
	local bonus_type = bonus.type
	local bonus_behavior = bonus.behavior or bonus_type.behavior
	-- checking if that bonus was already taken
	if bonus_behavior == PSHY_BONUS_BEHAVIOR_SHARED and taken_shared_bonuses[id] then
		return false
		-- @TODO: in case of abuse, check if non-shared bonuses were taken already
	end
	-- running the callback
	local func = bonus.func or bonus_type.func
	local pick_rst = nil
	if func then
		pick_rst = func(player_name, bonus)
	end
	-- bonus fate
	if pick_rst == false or bonus_behavior == PSHY_BONUS_BEHAVIOR_REMAIN then
		-- bonus remain
		if not delayed_player_bonuses_refresh[player_name] then
			delayed_player_bonuses_refresh[player_name] = {}
		end
		table.insert(delayed_player_bonuses_refresh[player_name], bonus)
	else
		-- bonus is to be removed
		if bonus_behavior == PSHY_BONUS_BEHAVIOR_SHARED then
			taken_shared_bonuses[id] = true
			pshy.bonuses_Disable(id, nil)
		else
			-- set bonus as taken
			if not players_taken_bonuses[player_name] then
				players_taken_bonuses[player_name] = {}
			end
			local taken_set = players_taken_bonuses[player_name]
			taken_set[id] = true
			-- remove image
			if players_image_ids[player_name] then
				tfm.exec.removeImage(players_image_ids[player_name][id])
			end
		end
	end
end



function eventNewGame()
	pshy.bonuses_list = {}
	bonuses_list = pshy.bonuses_list
	players_image_ids = {}
	shared_image_ids = {}
	delayed_player_bonuses_refresh = {}
	taken_shared_bonuses = {}
	players_taken_bonuses = {}
end



function eventPlayerRespawn(player_name)
	for bonuses_id, bonus in pairs(pshy.bonuses_list) do
		local bonus_behavior = bonus.behavior or bonus.type.behavior
		if bonus_behavior == PSHY_BONUS_BEHAVIOR_RESPAWN then
			pshy.bonuses_Enable(bonus_id, player_name)
		end
	end
end



function eventNewPlayer(player_name)
	local taken_set = players_taken_bonuses[player_name]
	for bonus_id, bonus in pairs(pshy.bonuses_list) do
		local bonus_behavior = bonus.behavior or bonus.type.behavior
		-- decide wether to spawn bonus in		
		if bonus_behavior == PSHY_BONUS_BEHAVIOR_RESPAWN then
			-- respawn when respawning
			--pshy.bonuses_Enable(bonus_id, player_name)
		elseif bonus_behavior == PSHY_BONUS_BEHAVIOR_SHARED then
			if not taken_shared_bonuses[bonus_id] then
				pshy.bonuses_Enable(bonus_id, player_name)
			end
		else
			if not taken_set or not taken_set[bonus_id] then
				pshy.bonuses_Enable(bonus_id, player_name)
			end
		end
	end
end



function eventPlayerLeft(player_name)
	players_image_ids[player_name] = nil
end



function eventLoop()
	-- readd 'remain' bonuses that were taken between last loop.
	for player_name, bonus_list in pairs(delayed_player_bonuses_refresh) do
		for i_bonus, bonus in ipairs(bonus_list) do
			tfm.exec.addBonus(0, bonus.x, bonus.y, bonus.id, 0, false, player_name)
		end
	end
	delayed_player_bonuses_refresh = {}
end
