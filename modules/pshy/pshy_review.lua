--- pshy_reviews.lua
--
-- Allows players to review your FunCorp.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_commands.lua



--- Module Help Page:
pshy.help_pages["pshy_reviews"] = {back = "pshy", text = "Allows players to make reviews.\n", examples = {}, commands = {}}
pshy.help_pages["pshy_reviews"].examples["luaget pshy.reviews"] = "list reviews"
pshy.help_pages["pshy_reviews"].examples["luaget pshy.reviews.Pshy#3752"] = "read the review from Pshy#3752"
--pshy.help_pages["pshy_rotations"].examples["luaset pshy.rotations_win_shorting_player_count 3"] = "Short the timer when 3 players won."
--pshy.help_pages["pshy_rotations"].examples["luaset pshy.rotations_win_shorting_time 10"] = "Set the time remaining after a few players won to 10 seconds."
pshy.help_pages["pshy"].subpages["pshy_reviews"] = pshy.help_pages["pshy_reviews"]



--- Internal Use:
pshy.reviews = {}		-- general reviews



--- !review <review_msg>
function pshy.ChatCommandReview(user, review)
	pshy.reviews[user] = review
	tfm.exec.chatMessage("<fc>[Reviews]</fc> Thank you!")
end
pshy.chat_commands["review"] = {func = pshy.RotationsSkipMap, desc = "make a review about this funcorp", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_reviews"].commands["review"] = pshy.chat_commands["review"]
