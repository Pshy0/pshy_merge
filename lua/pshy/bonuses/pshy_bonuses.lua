--- pshy_bonus.lua
--
-- Add custom bonuses.
--
-- Either use `pshy.bonuses_SetList()` to set the current bonus list.
-- Or add them individually with `pshy.bonuses_AddNoCopy(bonus_table)`.
--
-- Fields:
--	x (bonus only):				int, bonus location
--	y (bonus only):				int, bonus location
--	image:						string, bonus image name in pshy_imagedb
--	func:						function to call when the bonus is picked
--								if func returns false then the bonus will not be considered picked by the script (but TFM will)
--	behavior:					how respawning the bonus should be handled
--	enabled (bonus only):		if this bonus is enabled/visible by default
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
local new_player_joined = false



--- Set the list of bonuses, and show them.
-- @public
function pshy.bonuses_SetList(bonus_list)
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
-- @deprecated Use pshy.bonuses_AddNoCopy instead.
-- Either use this function or `pshy.bonuses_SetList`, but not both.
-- @param bonus_type The name or table corresponding to the bonus type.
-- @param bonus_x The bonus location.
-- @param bonus_y The bonus location.
-- @param enabled Is the bonus enabled for all players by default (nil is yes but not for new players).
-- @return The id of the created bonus.
function pshy.bonuses_Add(bonus_type_name, bonus_x, bonus_y, bonus_enabled, angle)
	return pshy.bonuses_AddNoCopy({type_name = bonus_type_name, x = bonus_x, y = bonus_y, enabled = bonus_enabled, angle = angle})
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
	if not bonus.angle then
		bonus.angle = 0
	end
	return bonus.id
end



--- Readd a shared image for shared bonuses.
function RefreshSharedBonusesImages()
	for bonus_id, bonus in ipairs(pshy.bonuses_list) do
		if shared_image_ids[bonus_id] then
			-- replace shared bonuses images --@TODO: have separate lists for new players ?
			local bonus_behavior = bonus.behavior or bonus.type.behavior
			local bonus_image = bonus.image or bonus.type.image
			if bonus_behavior == PSHY_BONUS_BEHAVIOR_SHARED or bonus_behavior == PSHY_BONUS_BEHAVIOR_REMAIN then
				if bonus_image then
					local old_image_id = shared_image_ids[bonus_id]
					shared_image_ids[bonus_id] = pshy.imagedb_AddImage(bonus_image, (bonus.foreground or bonus.type.foreground) and "!9999" or "?9999", bonus.x, bonus.y, nil, nil, nil, (bonus.angle or 0) * math.pi * 2 / 360, 1.0)
					if old_image_id then
						tfm.exec.removeImage(old_image_id)
					end
				end 
			end
		end
	end
end



--- Enable a bonus.
-- @public
-- When a bonus is enabled, it can be picked by players.
function pshy.bonuses_Enable(bonus_id, player_name)
	assert(type(bonus_id) == "number")
	local bonus = pshy.bonuses_list[bonus_id]
	-- get bonus type
	local bonus_type = bonus.type
	local bonus_behavior = bonus.behavior or bonus_type.behavior
	local bonus_image = bonus.image or bonus_type.image
	local bonus_foreground = bonus.foreground or bonus_type.foreground
	-- add bonus
	tfm.exec.removeBonus(bonus_id, player_name)
	tfm.exec.addBonus(0, bonus.x, bonus.y, bonus_id, 0, false, player_name)
	-- add image
	if bonus_image then
		if bonus_behavior == PSHY_BONUS_BEHAVIOR_SHARED or bonus_behavior == PSHY_BONUS_BEHAVIOR_REMAIN then
			assert(player_name == nil, "Bonuses of behavior type SHARED or REMAIN can only be enabled/disabled for all players.")
			if not shared_image_ids[bonus_id] then
				shared_image_ids[bonus_id] = pshy.imagedb_AddImage(bonus_image, (bonus.foreground or bonus.type.foreground) and "!9999" or "?9999", bonus.x, bonus.y, nil, nil, nil, (bonus.angle or 0) * math.pi * 2 / 360, 1.0)
			end	
		else
			for player_name in pairs(player_name and {[player_name] = true} or pshy.players_in_room) do
				if not players_image_ids[player_name] then
					players_image_ids[player_name] = {}
				end
				local ids = players_image_ids[player_name]
				if bonus_image and not ids[bonus_id] then
					ids[bonus_id] = pshy.imagedb_AddImage(bonus_image, bonus_foreground and "!9999" or "?9999", bonus.x, bonus.y, player_name, nil, nil, (bonus.angle or 0) * math.pi * 2 / 360, 1.0)
				end
			end
		end
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
-- @deprecated Being reworked.
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
	print_warn("called EnableAllBonuses() but it isnt supposed to be used")
	-- add bonuses
	for bonus_id, bonus in pairs(pshy.bonuses_list) do
		if bonus.enabled ~= false then
			tfm.exec.removeBonus(bonus.id, nil)
			tfm.exec.addBonus(0, bonus.x, bonus.y, bonus.id, 0, false, nil)
			-- add shared bonuses images
			local bonus_behavior = bonus.behavior or bonus.type.behavior
			if bonus_behavior == PSHY_BONUS_BEHAVIOR_SHARED or bonus_behavior == PSHY_BONUS_BEHAVIOR_REMAIN then
				if bonus.image then
					shared_image_ids[bonus_id] = pshy.imagedb_AddImage(bonus.image, (bonus.foreground or bonus.type.foreground) and "!9999" or "?9999", bonus.x, bonus.y, nil, nil, nil, (bonus.angle or 0) * math.pi * 2 / 360, 1.0)
				end 
			end
		end
	end
	-- add player bonuses images
	for player_name in pairs(pshy.players_in_room) do
		local images_ids = players_image_ids[player_name]
		for bonus_id, bonus in pairs(pshy.bonuses_list) do
			if bonus.enabled ~= false then
				local bonus_behavior = bonus.behavior or bonus.type.behavior
				if bonus_behavior == PSHY_BONUS_BEHAVIOR_STANDARD or bonus_behavior == PSHY_BONUS_BEHAVIOR_RESPAWN then
					images_ids[bonus_id] = pshy.imagedb_AddImage(bonus.image, (bonus.foreground or bonus.type.foreground) and "!9999" or "?9999", bonus.x, bonus.y, player_name, nil, nil, (bonus.angle or 0) * math.pi * 2 / 360, 1.0)
				end
			end
		end
	end
	-- non-taken
	taken_shared_bonuses = {}
	players_taken_bonuses = {}
end



--- Disable all bonuses for all players.
local function DisableAllBonuses()
	-- remove bonuses
	for bonus_id, bonus in pairs(pshy.bonuses_list) do
		tfm.exec.removeBonus(bonus.id, nil)
	end
	-- remove images
	for bonus_id, image_id in pairs(shared_image_ids) do
		tfm.exec.removeImage(image_id)
	end
	shared_image_ids = {}
	for player_name, images_ids in pairs(players_image_ids) do
		for bonus_id, image_id in pairs(images_ids) do
			tfm.exec.removeImage(image_id)
		end
	end
	players_image_ids = {}
end



--- Cause a shared bonus to be considered taken.
local function SharedBonusTaken(bonus)
	assert(bonus.behavior == PSHY_BONUS_BEHAVIOR_SHARED or bonus.type.behavior == PSHY_BONUS_BEHAVIOR_SHARED)
	taken_shared_bonuses[bonus.id] = true
	-- remove bonus
	tfm.exec.removeBonus(bonus.id, nil)
	-- remove image
	tfm.exec.removeImage(shared_image_ids[bonus.id])
	shared_image_ids[bonus.id] = nil
	-- set as taken
	taken_shared_bonuses[bonus.id] = bonus
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
			SharedBonusTaken(id)
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
	new_player_joined = true
	local taken_set = players_taken_bonuses[player_name]
	for bonus_id, bonus in pairs(pshy.bonuses_list) do
		local bonus_behavior = bonus.behavior or bonus.type.behavior
		-- decide wether to spawn bonus in		
		if bonus_behavior == PSHY_BONUS_BEHAVIOR_RESPAWN then
			-- respawn when respawning:
			--pshy.bonuses_Enable(bonus_id, player_name)
		elseif bonus_behavior == PSHY_BONUS_BEHAVIOR_SHARED or bonus_behavior == PSHY_BONUS_BEHAVIOR_REMAIN then
			if not taken_shared_bonuses[bonus_id] then
				tfm.exec.addBonus(0, bonus.x, bonus.y, bonus.id, 0, false, player_name)
				-- redrawn on refresh:
				--pshy.bonuses_Enable(bonus_id, player_name)
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
	-- refresh shared bonuses on new players
	if new_player_joined then
		new_player_joined = false
		RefreshSharedBonusesImages()
	end
	-- readd 'remain' bonuses that were taken between last loop.
	for player_name, bonus_list in pairs(delayed_player_bonuses_refresh) do
		for i_bonus, bonus in ipairs(bonus_list) do
			tfm.exec.addBonus(0, bonus.x, bonus.y, bonus.id, 0, false, player_name)
		end
	end
	delayed_player_bonuses_refresh = {}
end
