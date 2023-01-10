--- pshy.images.searchimage
--
-- Functions to search images in `pshy.images.list`.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script)
local command_list = pshy.require("pshy.commands.list")
local help_pages = pshy.require("pshy.help.pages")
local images = pshy.require("pshy.images.list")
local utils_strings = pshy.require("pshy.utils.strings")



--- Module Help Page:
help_pages["searchimage"] = {back = "pshy", title = "Image Search", text = "Search for an image.\n", commands = {}}
help_pages["pshy"].subpages["searchimage"] = help_pages["searchimage"]



--- Namespace.
local searchimage = {}



--- Module Settings:
searchimage.max_search_results = 20		-- maximum search displayed results



--- Tell if an image should be oriented
function searchimage.IsOriented(image)
	if type(image) == "string" then
		image = images[image]
	end
	assert(type(image) == "table", "wrong type " .. type(image))
	if image.oriented ~= nil then
		return image.oriented
	end
	if image.meme or image.emoticon or image.w <= 30 then
		return false
	end
	return true
end



--- Search for an image.
-- @private
-- This function is currently for testing only.
-- @param desc Text to find in the image's description.
-- @param words words to search for.
-- @return A list of images matching the search.
function searchimage.Search(words)
	local results = {}
	for image_name, image in pairs(images) do
		local not_matching = false
		for i_word, word in pairs(words) do
			if not string.find(image.desc, word) and not image[word] then
				not_matching = true
				break
			end
		end
		if not not_matching then
			table.insert(results, image_name)
		end
	end
	return results
end



--- !searchimage [words...]
local function ChatCommandSearchimage(user, word)
	local words = utils_strings.Split(word, ' ', 5)
	if #words >= 5 then
		return false, "You can use at most 4 words per search!"
	end
	if #words == 1 and #words[1] <= 1 then
		return false, "Please perform a more accurate search!"
	end
	local image_names = searchimage.Search(words)
	if #image_names == 0 then
		tfm.exec.chatMessage("No image found.", user)
	else
		for i_image, image_name in pairs(image_names) do
			if i_image > searchimage.max_search_results then
				tfm.exec.chatMessage("+ " .. tostring(#image_names - searchimage.max_search_results), user)
				break
			end
			local image = images[image_name]
			tfm.exec.chatMessage(image_name .. "\t - " .. tostring(image.desc) .. " (" .. tostring(image.w) .. "," .. tostring(image.w or image.h) .. ")", user)
		end
	end
	return true
end
command_list["searchimage"] = {perms = "cheats", func = ChatCommandSearchimage, desc = "search for an image", argc_min = 1, argc_max = 1, arg_types = {"string"}}
help_pages["searchimage"].commands["searchimage"] = command_list["searchimage"]



return searchimage
