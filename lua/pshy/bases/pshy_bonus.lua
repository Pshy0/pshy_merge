--- pshy_bonus.lua
--
-- Add custom bonuses.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_imagedb.lua
pshy = pshy or {}



--- Bonus types.
-- @public
-- List of bonus types and informations.
--	- image:	Image to display as the bonus.
--	- func:		Function to call when the bonus is picked.
--				Passed arguments are the player name and the bonus table.
pshy.bonus_types = {}						-- default bonus properties
pshy.bonus_types["pickable_cheese_example"]	= {image = "155593003fc.png", func = tfm.exec.giveCheese}
pshy.bonus_types["pickable_win_example"]	= {image = "17aa6f22c53.png", func = tfm.exec.playerVictory}



--- Bonus List.
-- Keys: The bonus ids.
-- Values: A table with the folowing fields:
--	- type: Bonus type, as a table.
--	- x: Bonus coordinates.
--	- y: Bonus coordinates.
--	- enabled: Is it enabled by default (true == always, false == never/manual, nil == once only).
pshy.bonus_list	= {}						-- list of ingame bonuses



--- Internal Use:
pshy.bonus_players_image_ids = {}



--- Set the list of bonuses, and show them.
-- @public
function pshy.bonus_SetList(bonus_list)
	pshy.bonus_HideAll()
	pshy.bonus_list = bonus_list
	pshy.bonus_ShowAll()
end



--- Create and enable a bonus.
-- @public
-- Either use this function or `pshy.bonus_SetList`, but not both.
-- @param bonus_type The name or table corresponding to the bonus type.
-- @param bonus_x The bonus location.
-- @param bonus_y The bonus location.
-- @param enabled Is the bonus enabled for all players by default (nil is yes but not for new players).
-- @return The id of the created bonus.
function pshy.bonus_Add(bonus_type, bonus_x, bonus_y, bonus_enabled)
	if type(bonus_type) == "string" then
		bonus_type = pshy.bonus_types[bonus_type]
	end
	assert(type(bonus_type) == "table")
	-- insert
	local new_id = #pshy.bonus_list + 1
	local new_bonus = {id = new_id, type = bonus_type, x = bonus_x, y = bonus_y, enabled = bonus_enabled}
	pshy.bonus_list[new_id] = new_bonus
	-- show
	if bonus_enabled ~= false then
		pshy.bonus_Enable(bonus_id)
	end
	return new_id
end



--- Enable a bonus.
-- @public
-- When a bonus is enabled, it can be picked by players.
function pshy.bonus_Enable(bonus_id, player_name)
	if player_name == nil then
		for player_name in pairs(tfm.get.room.playerList) do
			pshy.bonus_Enable(bonus_id, player_name)
		end
	end
	pshy.bonus_players_image_ids[player_name] = pshy.bonus_players_image_ids[player_name] or {}
	local bonus = pshy.bonus_list[bonus_id]
	local ids = pshy.bonus_players_image_ids[player_name]
	-- if already shown
	if ids[bonus_id] ~= nil then
		pshy.bonus_Hide(bonus_id, player_name)
	end
	-- add bonus
	tfm.exec.addBonus(0, bonus.x, bonus.y, bonus_id, 0, false, player_name)
	-- add image
	ids[bonus_id] = tfm.exec.addImage(bonus.image or bonus.type.image, "?226", bonus.x - 15, bonus.y - 20, player_name) -- todo: location
end



--- Hide a bonus.
-- @public
-- This prevent the bonus from being picked, without deleting it.
function pshy.bonus_Disable(bonus_id, player_name)
	if player_name == nil then
		for player_name in pairs(tfm.get.room.playerList) do
			pshy.bonus_Disable(bonus_id, player_name)
		end
	end
	if not pshy.bonus_players_image_ids[player_name] then
		return
	end
	local bonus = pshy.bonus_list[bonus_id]
	local ids = pshy.bonus_players_image_ids[player_name]
	-- if already hidden
	if ids[bonus_id] == nil then
		return
	end
	-- remove bonus
	tfm.exec.removeBonus(bonus_id, player_name)
	-- remove image
	tfm.exec.removeImage(ids[bonus_id], "!0", point.x - 15, point.y - 20, player_name)
end



--- Show all bonuses, except the ones with `visible == false`.
-- @private
function pshy.bonus_EnableAll(player_name)
	for bonus_id, bonus in pairs(pshy.bonus_list) do
		if not bonus.hidden then
			pshy.bonus_Enable(bonus_id, player_name)
		end
	end
end



--- Disable all bonuses for all players.
-- @private
function pshy.bonus_DisableAll(player_name)
	for bonus_id, bonus in pairs(pshy.bonus_list) do
		pshy.bonus_Disable(bonus_id, player_name)
	end
end



--- TFM event eventPlayerBonusGrabbed.
function eventPlayerBonusGrabbed(player_name, id)
	local bonus = pshy.bonus_list[id]
	-- running the callback
	local func = bonus.func or bonus.type.func
	if func then
		func(player_name, bonus)
	end
	pshy.bonus_Disable(id, player_name)
	-- if callback done then skip other bonus events
	if func then
		return false
	end
end



--- TFM event eventNewGame.
function eventNewGame()
	pshy.bonus_list = {}
	pshy.bonus_players_image_ids = {}
end



--- TFM event eventPlayerrespawn.
function eventPlayerRespawn(player_name)
	for bonus_id, bonus in pairs(pshy.bonus_list) do
		if bonus.enabled == true then
			pshy.bonus_Enable(bonus_id, player_name)
		end
	end
end



--- TFM event eventNewPlayer.
function eventNewPlayer(player_name)
	for bonus_id, bonus in pairs(pshy.bonus_list) do
		if bonus.enabled == true then
			pshy.bonus_Enable(bonus_id, player_name)
		end
	end
end



--- TFM event eventPlayerLeft.
function eventPlayerLeft(player_name)
	pshy.bonus_DisableAll(player_name) -- @todo: is this required?
	pshy.bonus_players_image_ids[player_name] = nil
end
