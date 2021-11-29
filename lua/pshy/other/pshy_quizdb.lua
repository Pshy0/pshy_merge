--- money_drop.lua
--
-- List of questions for use in quizes.
-- This list is public, and therefore not suitable for every animation.
--
-- A question is a table with the following fields:
--	`question`: The question text.
--	`answers`: A list of answers. May also be image file names.
--	`correct_answer`: The index of the correct answer.
--	`ordered`: The order of the answers should not change.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy = pshy or {}



--- Module Settings:
pshy.quizdb_default_quiz_name = "cheese"



--- Quizes:
pshy.quizdb_quizes = {}
-- Cheeze quiz (source: https://www.beelovedcity.com/cheese-quiz)
pshy.quizdb_quizes.cheese = {questions = {}}
table.insert(pshy.quizdb_quizes.cheese.questions, {text = "Which one is not a blue cheese?", answers = {"Gorgonzola", "Roquefort", "Stilton", "Pecorino"}, correct_answer = 4})
table.insert(pshy.quizdb_quizes.cheese.questions, {text = "Which one of these British cheeses is not semi-soft?", answers = {"Stinking Bishop", "Kidderton Ash", "Wigmore", "Cornish Yarg"}, correct_answer = 2})
table.insert(pshy.quizdb_quizes.cheese.questions, {text = "How many pounds of milk do you need to make 1 pound of cheese?", answers = {"3 pounds", "5 pounds", "8 pounds", "10 pounds"}, correct_answer = 4})
table.insert(pshy.quizdb_quizes.cheese.questions, {text = "How much did the heaviest cheese ever produced weigh?", answers = {"37,518 pounds", "47,518 pounds", "57,518 pounds", "67,518 pounds"}, correct_answer = 3})
table.insert(pshy.quizdb_quizes.cheese.questions, {text = "Which one of these cheeses has holes?", answers = {"Gruyere", "Cheshire Cheese", "Leicester", "Gouda"}, correct_answer = 1})
table.insert(pshy.quizdb_quizes.cheese.questions, {text = "When is National Cheese day in the United States?", answers = {"4th of May", "4th of June", "4th of July", "4th of August"}, correct_answer = 2})
table.insert(pshy.quizdb_quizes.cheese.questions, {text = "Why did cheesemakers start dying cheese in Orange?", answers = {"To make people think it was better quality", "To enhance the taste", "To make it stand out on the shelves", "To make it prettier"}, correct_answer = 1})
table.insert(pshy.quizdb_quizes.cheese.questions, {text = "Which dish is made of fries, cheese and gravy?", answers = {"Poutine", "Fish and Chips", "Cottage Pie", "Jacket Potato"}, correct_answer = 1})
table.insert(pshy.quizdb_quizes.cheese.questions, {text = "How many kilos of cheese do French people eat per year on average (per head)?", answers = {"12", "17", "22", "27"}, correct_answer = 4})
table.insert(pshy.quizdb_quizes.cheese.questions, {text = "What cheese, particularly loved by kids, is wrapped in red wax?", answers = {"Kiri", "Laughing Cow", "Strings & Things", "Babybel"}, correct_answer = 4})



--- Get a random question.
-- @return a question table.
function pshy.quizdb_RandomQuestion(quiz_name)
	quiz_name = quiz_name or pshy.quizdb_default_quiz_name
	local quiz = pshy.quizdb_quizes[quiz_name]
	local questions = quiz.questions
	return questions[math.random(#questions)]
end
