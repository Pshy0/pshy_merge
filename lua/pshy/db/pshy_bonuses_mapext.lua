--- pshy_bonuses_mapext.lua
--
-- Allow maps to contain custom bonuses in the form of 
-- custom foreground invisible and non-colliding circle ground.
--
-- @require pshy_bonuses.lua
-- @require pshy_xmlmap.lua



--- Object bindings:
local bonus_types			= {}
bonus_types["FF0000"] = "BonusShrink"



--- Check a ground.
local function CheckGround(ground)
	if ground["T"] == "13" and ground["L"] == "10" and ground["c"] == "4" and ground["m"] == "" then --  and ground["N"] == ""
		local bonus_color = ground["o"]
		local bonus_x = ground["X"]
		local bonus_y = ground["Y"]
		local bonus_type = bonus_types[ground["o"]]
		if bonus_type then
			print("adding bonus")
			pshy.bonuses_Add(bonus_type, bonus_x, bonus_y)
		end
	end
end



--- TFM event eventNewGame.
function eventNewGame()
	if pshy.xmlmap then
		print("checking objects")
		local grounds_node = pshy.xmlmap_GetGroundNode()
		assert(type(grounds_node) == "table")
		for i_ground_node, ground_node in ipairs(grounds_node.childs) do
			assert(ground_node.type == "S")
			if ground_node.type == "S" then
				CheckGround(ground_node.properties)
			end
		end
	end
end

