--- pshy.tools.untrustedmaps
--
-- Help knowing what untrusted maps were run by the script.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")
local mapinfo = pshy.require("pshy.rotations.mapinfo", false)
local perms = pshy.require("pshy.perms")
pshy.require("pshy.rotations.newgame")
local room = pshy.require("pshy.room")
pshy.require("pshy.utils.print")



--- Namespace.
local untrusted_map_list = {}
local untrusted_map_set = {}
local deleted_map_list = {}
local deleted_map_set = {}



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Untrusted Maps", restricted = true, text = "Help knowing what untrusted maps were run by the script.\n"}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



function eventNewGame()
	local trusted = perms.IsTrustedMap()
	if not trusted and room.is_funcorp and tfm.get.room.xmlMapInfo then
		print_warn("Untrusted map %s from %s.", tostring(tfm.get.room.currentMap), tfm.get.room.xmlMapInfo.author or "?")
		if not untrusted_map_set[tfm.get.room.currentMap] then
			untrusted_map_set[tfm.get.room.currentMap] = true
			untrusted_map_list[#untrusted_map_list + 1] = tfm.get.room.currentMap
			if mapinfo and mapinfo.grounds then
				for i, ground in pairs(mapinfo.grounds) do
					if ground.dynamic then
						print_warn("Untrusted map %s has dynamic ground.", tostring(tfm.get.room.currentMap))
						break
					elseif ground.vanish_time then
						print_warn("Untrusted map %s has dynamic ground.", tostring(tfm.get.room.currentMap))
						break
					end
				end
			end
		end
	end
	if tfm.get.room.xmlMapInfo and (tfm.get.room.xmlMapInfo.permCode == 44 or (mapinfo and (string.lower(mapinfo.mapinfo.title or "") == "map removed" or string.lower(mapinfo.mapinfo.author or "") == "map removed"))) then
		if not deleted_map_set[tfm.get.room.currentMap] then
			deleted_map_set[tfm.get.room.currentMap] = true
			deleted_map_list[#deleted_map_list + 1] = tfm.get.room.currentMap
			print_warn("Deleted map %s from %s.", tostring(tfm.get.room.currentMap), tfm.get.room.xmlMapInfo.author or "?")
		end
	end
end



__MODULE__.commands = {
	["untrustedmaps"] = {
		perms = "admins",
		desc = "list untrusted maps run by the script",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"number"},
		arg_names = {"page"},
		func = function(user, page)
			page = page or 1
			assert(page > 0)
			local maplist = ""
			for i = (page - 1) * 40 + 1, (page - 1) * 40 + 40 do
				if not untrusted_map_list[i] then
					break
				end
				maplist = maplist .. tostring(untrusted_map_list[i]) .. "\n"
			end
			return true, string.format("Untrusted maps, page %d:\n%s", page, maplist)
		end
	},
	["removedmaps"] = {
		perms = "admins",
		desc = "list removed and deleted maps run by the script",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"number"},
		arg_names = {"page"},
		func = function(user, page)
			page = page or 1
			assert(page > 0)
			local maplist = ""
			for i = (page - 1) * 40 + 1, (page - 1) * 40 + 40 do
				if not deleted_map_list[i] then
					break
				end
				maplist = maplist .. tostring(deleted_map_list[i]) .. "\n"
			end
			return true, string.format("Removed maps, page %d:\n%s", page, maplist)
		end
	}
}
