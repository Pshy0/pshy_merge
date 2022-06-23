--- pshy_translations.lua
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
--		`translation_table = translations.translations[original]`
--  - Run a function with a translated message for every player:
--		for player_name, player in pairs(tfm.get.room.playerList) do
--			func(translation_table[player.language] or original, player_name)
--		end
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
pshy.require("pshy.bases.print")



--- Namespace.
local translations = {}



--- Translations:
translations.translations = {}					-- Translations table (translated strings are `translations[original].language`).
translations.translations["Welcome!"] = {
	es = "¡Bienvenido!";
	fr = "Bienvenue !";
	pl = "Witamy!";
	ru = "Добро пожаловать";
}
translations.default_language = tfm.get.room.language
if translations.default_language == "int" then
	translations.default_language = "en"
	print_info("International room: The default language will be 'en'.")
end



--- Internal use:
local translations = translations.translations
local player_languages = {}
local seen_languages = {}				-- set of languages being used by at least 1 player



--- Tell the script a player exist.
local function TouchPlayer(player_name)
	player_languages[player_name] = tfm.get.room.playerList[player_name].language
	if player_languages[player_name] == "int" then
		player_languages[player_name] = "en"
	end
	seen_languages[player_languages[player_name]] = true
end



--- Translate a text using entries in `translations.translations`.
-- @param original The original string to be translated or an unique identifier.
-- @param language The language to translate into, or the Player#0000 for who the message is to be translated, or nil for the room's language.
-- @return The translated text into the required language, or the default language, or the original text.
function pshy.Translate(original, language)
	local translation_table
	if type(original) == "table" then
		translation_table = original
		original = translations[translations.default_language] or "(MISSING TRANSLATION)"
	else
		translation_table = translations[original]
	end
	if not translation_table then
		return original
	else
		if language then
			if player_languages[language] then
				language = player_languages[language]
			end
			if translation_table[language] then
				return translation_table[language]
			end
		end
		if translation_table[translations.default_language] then
			return translation_table[translations.default_language]
		end
		return original
	end
end
local function Translate = pshy.Translate



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
	local translation_table = translations[original]
	for language in pairs(seen_languages) do
		if not translation_table[language] then
			local translated_format = pshy.Translate(format, language)
			if translated_format ~= format then
				local new_args = {}
				for i_arg, arg in ipairs(args) do
					new_args[i_arg] = pshy.Translate(arg, language)
				end
				translation_table[language] = string.format(translated_format, table.unpack(new_args))
			end
		end
	end
	return translation_table
end



--- Send a chat message with a translation per player.
function translations.BroadcastChatMessage(message)
	local translation_table
	if type(message) == "table" then
		translation_table = message
	else
		translation_table = translations[message]
		if not translation_table then
			tfm.exec.chatMessage(message, nil)
			return
		end
	end
	for player_name, player in pairs(tfm.get.room.playerList) do
		tfm.exec.chatMessage(translation_table[player.language] or translation_table[translations.default_language] or message, player_name)
	end
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
end



function eventInit()
	assert(translations == translations.translations, "You must not redefine translations.translations, only insert entries.")
	for player_name in pairs(tfm.get.room.playerList) do
		TouchPlayer(player_name)
	end
	if __IS_MAIN_MODULE__ then
		for player_name, player in pairs(tfm.get.room.playerList) do
			tfm.exec.chatMessage(pshy.translate("Welcome!", player_name), player_name)
		end
		ui.setMapName(pshy.translate("Welcome!"))
		print_info(pshy.translate("Welcome!"))
		print_info(pshy.translate("Welcome!", "ru"))
		print_info(pshy.translate("Welcome!", "pl"))
		print_info(pshy.translate(translations.translations["Welcome!"], "fr"))
	end
end



return translations
