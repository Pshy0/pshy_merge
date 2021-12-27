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
-- @require pshy_imagedb.lua
pshy = pshy or {}



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
pshy.bonuses_taken	= {}					-- set of taken bonus indices (non-shared bonuses use a table)



--- Internal Use:
pshy.bonuses_players_image_ids = {}



--- Set the list of bonuses, and show them.
-- @public
function pshy.bonuses_SetList(bonus_list)
	pshy.bonuses_DisableAll()
	pshy.bonuses_list = pshy.ListCopy(bonus_list)
	pshy.bonuses_EnableAll()
end



--- Create and enable a bonus.
-- @public
-- Either use this function or `pshy.bonuses_SetList`, but not both.
-- @param bonus_type The name or table corresponding to the bonus type.
-- @param bonus_x The bonus location.
-- @param bonus_y The bonus location.
-- @param enabled Is the bonus enabled for all players by default (nil is yes but not for new players).
-- @return The id of the created bonus.
function pshy.bonuses_Add(bonus_type_name, bonus_x, bonus_y, bonus_enabled)
	local bonus_type = bonus_type_name
	if type(bonus_type) == "string" then
		assert(pshy.bonuses_types[bonus_type], "invalid bonus type " .. tostring(bonus_type))
		bonus_type = pshy.bonuses_types[bonus_type]
	end
	assert(type(bonus_type) == "table")
	-- insert
	local new_id = #pshy.bonuses_list + 1 -- @TODO: this doesnt allow removing bonuses (IN FACT IT LIMITS ALOT)
	local new_bonus = {id = new_id, type = bonus_type_name, x = bonus_x, y = bonus_y, enabled = bonus_enabled}
	pshy.bonuses_list[new_id] = new_bonus
	-- show
	if bonus_enabled ~= false then
		pshy.bonuses_Enable(new_id)
	end
	return new_id
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
	pshy.bonuses_players_image_ids[player_name] = pshy.bonuses_players_image_ids[player_name] or {}
	local bonus = pshy.bonuses_list[bonus_id]
	local ids = pshy.bonuses_players_image_ids[player_name]
	-- get bonus type
	local bonus_type = bonus.type
	if type(bonus_type) == "string" then
		assert(pshy.bonuses_types[bonus_type], "invalid bonus type " .. tostring(bonus_type))
		bonus_type = pshy.bonuses_types[bonus_type]
	end
	assert(type(bonus_type) == 'table', "bonus type must be a table or a string")
	-- if already shown
	if ids[bonus_id] ~= nil then
		pshy.bonuses_Disable(bonus_id, player_name)
	end
	-- add bonus
	tfm.exec.addBonus(0, bonus.x, bonus.y, bonus_id, 0, false, player_name)
	-- add image
	--ids[bonus_id] = tfm.exec.addImage(bonus.image or bonus_type.image, "!0", bonus.x - 15, bonus.y - 20, player_name) -- todo: location
	ids[bonus_id] = pshy.imagedb_AddImage(bonus.image or bonus_type.image, "!0", bonus.x, bonus.y, player_name, nil, nil, 0, 1.0)
	-- reenabling a bonus cause it to be non-taken
	if bonus.shared or bonus_type.shared then
		pshy.bonuses_taken[bonus_id] = nil
	else
		local player_set = pshy.bonuses_taken[bonus_id]
		if player_set then
			player_set[player_name] = nil
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
	if not pshy.bonuses_players_image_ids[player_name] then
		return
	end
	local bonus = pshy.bonuses_list[bonus_id]
	local ids = pshy.bonuses_players_image_ids[player_name]
	-- if already hidden
	if ids[bonus_id] == nil then
		return
	end
	-- remove bonus
	tfm.exec.removeBonus(bonus_id, player_name)
	-- remove image
	tfm.exec.removeImage(ids[bonus_id])
end



--- Show all bonuses, except the ones with `visible == false`.
-- @private
function pshy.bonuses_EnableAll(player_name)
	for bonus_id, bonus in pairs(pshy.bonuses_list) do
		if not bonus.hidden then
			pshy.bonuses_Enable(bonus_id, player_name)
		end
	end
end



--- Disable all bonuses for all players.
-- @private
function pshy.bonuses_DisableAll(player_name)
	for bonus_id, bonus in pairs(pshy.bonuses_list) do
		pshy.bonuses_Disable(bonus_id, player_name)
	end
end



--- TFM event eventPlayerBonusGrabbed.
function eventPlayerBonusGrabbed(player_name, id)
	if id == 0 then
		print(string.format("DEBUG: %s grabbed a bonus with id %d", player_name, id))
		return
	end
	local bonus = pshy.bonuses_list[id]
	local bonus_type = bonus.type
	if type(bonus_type) == "string" then
		assert(pshy.bonuses_types[bonus_type], "invalid bonus type " .. tostring(bonus_type))
		bonus_type = pshy.bonuses_types[bonus_type]
	end
	-- checking if that bonus was already taken
	if bonus.shared or bonus_type.shared then
		if pshy.bonuses_taken[id] then
			return false
		end
		pshy.bonuses_taken[id] = true
	else
		if not pshy.bonuses_taken[id] then
			pshy.bonuses_taken[id] = {}
		end
		local player_set = pshy.bonuses_taken[id]
		if player_set and player_set[player_name] then
			return false
		end
		player_set[player_name] = true
	end
	-- running the callback
	local func = bonus.func or bonus_type.func
	local pick_rst = nil
	if func then
		pick_rst = func(player_name, bonus)
	end
	-- disable bonus
	if pick_rst ~= false then -- if func returns false then dont unspawn the bonus
		if bonus.shared or (bonus.shared == nil and bonus_type.shared) then
			pshy.bonuses_Disable(id, nil)
			if bonus.remain or (bonus.remain == nil and bonus_type.remain) then
				pshy.bonuses_Enable(id, nil)
			end
		else
			pshy.bonuses_Disable(id, player_name)
			if bonus.remain or (bonus.remain == nil and bonus_type.remain) then
				pshy.bonuses_Enable(id, player_name)
			end
		end
	end
end



--- TFM event eventNewGame.
function eventNewGame()
	pshy.bonuses_list = {}
	pshy.bonuses_players_image_ids = {}
	pshy.bonuses_taken = {}
end



--- TFM event eventPlayerRespawn.
function eventPlayerRespawn(player_name)
	for bonuses_id, bonus in pairs(pshy.bonuses_list) do
		if bonus.respawn then
			pshy.bonuses_Enable(bonuses_id, player_name)
		end
	end
end



--- TFM event eventNewPlayer.
-- Show the bonus, but purely for the spectating player to understand what's going on.
function eventNewPlayer(player_name)
	for bonus_id, bonus in pairs(pshy.bonuses_list) do
		if bonus.respawn then
			pshy.bonuses_Enable(bonus_id, player_name)
		elseif bonus.shared or bonus_type.shared then
			if not pshy.bonuses_taken[bonus_id] then
				pshy.bonuses_Enable(bonus_id, player_name)
			end
		else
			local player_set = pshy.bonuses_taken[bonus_id]
			if not player_set or not player_set[player_name] then
				pshy.bonuses_Enable(bonus_id, player_name)
			end
		end
	end
end



--- TFM event eventPlayerLeft.
function eventPlayerLeft(player_name)
	pshy.bonuses_DisableAll(player_name) -- @todo: is this required?
	pshy.bonuses_players_image_ids[player_name] = nil
end
