--- pshy_reviews.lua
--
-- Allows players to review your FunCorp.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local help_pages = pshy.require("pshy.help.pages")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Reviews", text = "Allows players to make reviews.\n", examples = {}}
help_pages[__MODULE_NAME__].examples["luaget pshy.reviews"] = "list reviews"
help_pages[__MODULE_NAME__].examples["luaget pshy.reviews.Pshy#3752"] = "read the review from Pshy#3752"
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Internal Use:
pshy.reviews = {}		-- general reviews



__MODULE__.commands = {
	["review"] = {
		perms = "everyone",
		desc = "make a review about this funcorp",
		argc_min = 1, argc_max = 1,
		arg_types = {"string"},
		func = function(user, review)
			pshy.reviews[user] = review
			tfm.exec.chatMessage("<fc>[Reviews]</fc> Thank you!")
		end
	}
}
