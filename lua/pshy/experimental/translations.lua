--- pshy.experimental.translations
--
-- Handles translations.
-- Add translations in the `translations.translations` table.
-- Use `pshy.Translate(message)` for simple per-string translation.
-- Use `translations.Generate(format, ...)` to precompute a translated formated string.
-- See `translations.BroadcastChatMessage(message)` for how to optimize translations (but you are not printing translated messages every second, are you?).
--
-- Tips to create functions with translated content (SOME ARE ALEADY DEFINED IN THIS FILE):
--	- Generate translations for a formated string:
--		`translations.Generate("Go on a %s object within %d seconds!", {"red", 24})`
--	- Get a translation table:
--		`map = translations.translations[original]`
--  - Run a function with a translated message for every player:
--		for player_name, player in pairs(tfm.get.room.playerList) do
--			func(map[player.language] or original, player_name)
--		end
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
pshy.require("pshy.utils.print")



--- Namespace.
local translations = {}



--- Translations:
translations.translations = {}					-- Translations table (translated strings are `translations[original].language`).
translations.translations["Using translations for '%s'."] = {
	fr = "Votre langue est désormais '%s'.";
	ar = "استعمل  هذا الرمز للترجمة  '%s'.";
}
translations.translations["Please use a 2-letters acronym."] = {
	fr = "Veillez utiliser une abréviation en 2 lettres.";
}
translations.default_language = tfm.get.room.language
if translations.default_language == "int" or  translations.default_language == "xx" then
	translations.default_language = "en"
	print_info("International room: The default language will be 'en'.")
end
translations.player_languages = {}



--- Internal use:
local maps = translations.translations
local player_languages = translations.player_languages
local seen_languages = {}				-- set of languages being used by at least 1 player



--- Tell the script a player exist.
local function TouchPlayer(player_name)
	player_languages[player_name] = tfm.get.room.playerList[player_name].community
	if player_languages[player_name] == "int" or player_languages[player_name] == "xx" then
		player_languages[player_name] = "en"
	end
	seen_languages[player_languages[player_name]] = true
end



--- Translate a text using entries in `translations.translations`.
-- @param original The original string to be translated or an unique identifier.
-- @param language The language to translate into, or the Player#0000 for who the message is to be translated, or nil for the room's language.
-- @return The translated text into the required language, or the default language, or the original text.
function translations.Translate(original, language)
	local map
	if type(original) == "table" then
		map = original
		original = maps[translations.default_language] or "(MISSING TRANSLATION)"
	else
		map = maps[original]
	end
	if not map then
		return original
	else
		if language then
			if player_languages[language] then
				language = player_languages[language]
			end
			if map[language] then
				return map[language]
			end
		end
		if map[translations.default_language] then
			return map[translations.default_language]
		end
		return original
	end
end
local Translate = translations.Translate



--- Run a function to generate translations in all current player languages using `string.format`.
-- This is for precomputing formated strings to improve performances.
-- Translations are not generated if no translation exists for the format (even if it does not contain any word).
-- Avoid generating translations before `eventInit()`.
-- @param format A format.
-- @param args Strings to insert in the format.
-- @return A new translation table for the original text built by `string.format(format, table.unpack(args))`.
function translations.Generate(format, args)
	local original = string.format(format, table.unpack(args))
	if not translations[original] then
		translations[original] = {}
	end
	local map = maps[original]
	for language in pairs(seen_languages) do
		if not map[language] then
			local translated_format = Translate(format, language)
			if translated_format ~= format then
				local new_args = {}
				for i_arg, arg in ipairs(args) do
					new_args[i_arg] = Translate(arg, language)
				end
				map[language] = string.format(translated_format, table.unpack(new_args))
			end
		end
	end
	return map
end



--- Send a chat message with a translation per player.
-- This function is more an example than something you should use.
-- For instance, it does not support formatting the text.
function translations.ChatMessage(message, player_name)
	local map
	if type(message) == "table" then
		map = message
	else
		map = maps[message]
		if not map then
			tfm.exec.chatMessage(message, player_name)
			return
		end
	end
	if player_name then
		local player = tfm.get.room.playerList[player_name];
		tfm.exec.chatMessage(map[player.community] or map[translations.default_language] or message, player_name)
	else
		for player_name, player in pairs(tfm.get.room.playerList) do
			tfm.exec.chatMessage(map[player.community] or map[translations.default_language] or message, player_name)
		end
	end
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
end



function eventInit()
	assert(maps == translations.translations, "You must not redefine translations.translations, only insert entries.")
	for player_name in pairs(tfm.get.room.playerList) do
		TouchPlayer(player_name)
	end
	if __IS_MAIN_MODULE__ then
		translations.translations["Welcome!"] = {
			es = "¡Bienvenido!";
			fr = "Bienvenue !";
			pl = "Witamy!";
			ru = "Добро пожаловать";
			ar = "مرحبا";
		}
		for player_name, player in pairs(tfm.get.room.playerList) do
			tfm.exec.chatMessage(translations.Translate("Welcome!", player_name), player_name)
		end
		ui.setMapName(translations.Translate("Welcome!"))
		print_info(translations.Translate("Welcome!"))
		print_info(translations.Translate("Welcome!", "ru"))
		print_info(translations.Translate("Welcome!", "pl"))
		print_info(translations.Translate(translations.translations["Welcome!"], "fr"))
		translations.ChatMessage("Welcome!")
		for player_name in pairs(tfm.get.room.playerList) do
			translations.ChatMessage("Welcome!", player_name)
		end
	end
end



__MODULE__.commands = {
	["lang"] = {
		aliases = {"language"},
		perms = "everyone",
		desc = "Change your language.",
		argc_min = 1, argc_max = 1,
		arg_types = {"string"},
		arg_names = {"language"},
		func = function(user, language)
			if language == "int" or language == "xx" then
				language = translations.default_language
			end
			if #language ~= 2 then
				return false, Translate("Please use a 2-letters acronym.", player_languages[user])
			end
			player_languages[user] = language
			return true, string.format(Translate("Using translations for '%s'.", language), language)
		end 
	}
}



return translations
