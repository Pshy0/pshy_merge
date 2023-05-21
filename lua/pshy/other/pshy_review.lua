--- pshy_reviews.lua
--
-- Allows players to review your FunCorp.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local command_list = pshy.require("pshy.commands.list")
local help_pages = pshy.require("pshy.help.pages")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Reviews", text = "Allows players to make reviews.\n", examples = {}, commands = {}}
help_pages[__MODULE_NAME__].examples["luaget pshy.reviews"] = "list reviews"
help_pages[__MODULE_NAME__].examples["luaget pshy.reviews.Pshy#3752"] = "read the review from Pshy#3752"
--help_pages[__MODULE_NAME__].examples["luaset pshy.rotations_win_shorting_player_count 3"] = "Short the timer when 3 players won."
--help_pages[__MODULE_NAME__].examples["luaset pshy.rotations_win_shorting_time 10"] = "Set the time remaining after a few players won to 10 seconds."
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Internal Use:
pshy.reviews = {}		-- general reviews



--- !review <review_msg>
local function ChatCommandReview(user, review)
	pshy.reviews[user] = review
	tfm.exec.chatMessage("<fc>[Reviews]</fc> Thank you!")
end
command_list["review"] = {perms = "everyone", func = ChatCommandReview, desc = "make a review about this funcorp", argc_min = 1, argc_max = 1, arg_types = {"string"}}
help_pages[__MODULE_NAME__].commands["review"] = command_list["review"]
