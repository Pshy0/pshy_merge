--- money_drop.lua
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_quizdb.lua



tfm.exec.disableAutoNewGame(true)
tfm.exec.disableAutoTimeLeft(true)
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAfkDeath(true)



--- Module Settings:
pshy.moneydrop_map = '<C><P F="3" DS="x;260" Ca="" MEDATA=";4,1;;;-0;0:::1-"/><Z><S><S T="12" X="400" Y="375" L="800" H="50" P="0,0,0.3,0.2,0,0,0,0" o="3D0000" c="4"/><S T="12" X="200" Y="380" L="10" H="140" P="0,0,0.3,0,0,0,0,0" o="011F90"/><S T="12" X="400" Y="380" L="10" H="140" P="0,0,0.3,0,0,0,0,0" o="011F90"/><S T="12" X="600" Y="380" L="10" H="140" P="0,0,0.3,0,0,0,0,0" o="011F90"/><S T="12" X="850" Y="200" L="110" H="400" P="0,0,0,0,0,0,0,0" o="011F90"/><S T="12" X="-50" Y="200" L="110" H="400" P="0,0,0,0,0,0,0,0" o="011F90"/></S><D><P X="0" Y="0" T="257" P="0,0"/><P X="135" Y="86" T="43" P="0,0"/><P X="73" Y="228" T="43" P="0,0"/><P X="504" Y="222" T="43" P="0,0"/><P X="386" Y="92" T="43" P="0,0"/><P X="652" Y="144" T="43" P="0,0"/></D><O/><L/></Z></C>'
pshy.moneydrop_question_text_area_id = 33
pshy.moneydrop_question_x = 100					-- question position
pshy.moneydrop_question_y = 30					-- question position
pshy.moneydrop_question_w = 600					-- question position
pshy.moneydrop_question_h = 45					-- question position
pshy.moneydrop_drops = {}						-- money trapdoors
pshy.moneydrop_drops[1] = {answer_x = 10, answer_y = 120, trapdoor_x = 100, trapdoor_y = 350, answer_text_area_id = 34, trapdoor_id = 1}
pshy.moneydrop_drops[2] = {answer_x = 210, answer_y = 120, trapdoor_x = 300, trapdoor_y = 350, answer_text_area_id = 35, trapdoor_id = 2}
pshy.moneydrop_drops[3] = {answer_x = 410, answer_y = 120, trapdoor_x = 500, trapdoor_y = 350, answer_text_area_id = 36, trapdoor_id = 3}
pshy.moneydrop_drops[4] = {answer_x = 610, answer_y = 120, trapdoor_x = 700, trapdoor_y = 350, answer_text_area_id = 37, trapdoor_id = 4}
pshy.moneydrop_drop_answer_w = 180
pshy.moneydrop_drop_answer_h = 100
pshy.moneydrop_drop_trapdoor_w = 180
pshy.moneydrop_drop_trapdoor_h = 30



--- Internal Use:
pshy.moneydrop_empty_question = {text = "QUESTION", answers = {"?", "?", "?", "?"}, correct_answer = 0}
pshy.moneydrop_current_question = {text = "6 x 7 ?", answers = {"41", "42", "43", "44"}, correct_answer = 2}
pshy.moneydrop_init_timers_ids = {}



--- Erase the question and answers.
function pshy.moneydrop_Clear()
	for i_timer, timer_id in pairs(pshy.moneydrop_init_timers_ids) do
		system.removeTimer(timer_id)
	end
	pshy.moneydrop_init_timers_ids = {}
	ui.removeTextArea(pshy.moneydrop_question_text_area_id)
	for i_drop, drop in pairs(pshy.moneydrop_drops) do
		ui.removeTextArea(drop.answer_text_area_id)
	end
end



--- Start another question.
function pshy.moneydrop_NewQuestion()
	pshy.moneydrop_dropping = false
	pshy.moneydrop_Clear()
	pshy.moneydrop_CloseDrops()
	-- display default content
	pshy.moneydrop_current_question = pshy.moneydrop_empty_question
	pshy.moneydrop_DisplayQuestion()
	for i_drop, drop in pairs(pshy.moneydrop_drops) do
		pshy.moneydrop_DisplayAnswer(i_drop)
	end
	pshy.moneydrop_current_question = pshy.quizdb_RandomQuestion(quiz_name)
	-- for the effect, the answers and the question will be shown at a specific interval.
	table.insert(pshy.moneydrop_init_timers_ids, system.newTimer(pshy.moneydrop_DisplayAnswerTimerCallback, 1000, false, 1))
	table.insert(pshy.moneydrop_init_timers_ids, system.newTimer(pshy.moneydrop_DisplayAnswerTimerCallback, 1500, false, 2))
	table.insert(pshy.moneydrop_init_timers_ids, system.newTimer(pshy.moneydrop_DisplayAnswerTimerCallback, 2000, false, 3))
	table.insert(pshy.moneydrop_init_timers_ids, system.newTimer(pshy.moneydrop_DisplayAnswerTimerCallback, 2500, false, 4))
	table.insert(pshy.moneydrop_init_timers_ids, system.newTimer(pshy.moneydrop_DisplayQuestion, 4000, false))
	tfm.exec.setGameTime(60, true)
end



--- Open the wrong drops (not instant).
-- Locks choices then start timers to open the drops
function pshy.moneydrop_Drop()
	pshy.moneydrop_dropping = true
	tfm.exec.setGameTime(10, true)
	pshy.moneydrop_LockChoices()
	for i_answer, answer in pairs(pshy.moneydrop_drops) do
		if i_answer ~= pshy.moneydrop_current_question.correct_answer then
			table.insert(pshy.moneydrop_init_timers_ids, system.newTimer(pshy.moneydrop_OpenDropTimerCallback, math.random(1000, 5000), false, i_answer))
		end
	end
end



--- Timer callback wrapper for pshy.moneydrop_DisplayAnswer.
function pshy.moneydrop_DisplayAnswerTimerCallback(timer_id, index, open)
	pshy.moneydrop_DisplayAnswer(index, open)
end



--- Display an answer.
-- @param index Index of the question to display.
function pshy.moneydrop_DisplayAnswer(index, open)
	local drop = pshy.moneydrop_drops[index]
	local question = pshy.moneydrop_current_question
	local answer_text = question.answers[index]
	print("open " .. tostring(open))
	if not open then
		ui.addTextArea(drop.answer_text_area_id, "<bv><p align='left'>" .. string.char(64 + index) .. ":\n‾‾‾‾‾‾‾‾</p></bv>\n<ch><p align='center'><font size='16'>" .. answer_text .. "</font></p></ch>", nil, drop.answer_x, drop.answer_y, pshy.moneydrop_drop_answer_w, pshy.moneydrop_drop_answer_h, 0x010144, 0x4444ff, 0.8, true)
	else
		ui.addTextArea(drop.answer_text_area_id, "<r><p align='left'>" .. string.char(64 + index) .. ":\n‾‾‾‾‾‾‾‾</p></r>\n<r><p align='center'><font size='16'>" .. answer_text .. "</font></p></r>", nil, drop.answer_x, drop.answer_y, pshy.moneydrop_drop_answer_w, pshy.moneydrop_drop_answer_h, 0x010144, 0x4444ff, 0.8, true)
	end
end



--- Display the question.
function pshy.moneydrop_DisplayQuestion()
	local question = pshy.moneydrop_current_question
	ui.addTextArea(pshy.moneydrop_question_text_area_id, "<p align='center'><font size='16'><n><b>" .. question.text .. "</b></n></font></p>", nil, pshy.moneydrop_question_x, pshy.moneydrop_question_y, pshy.moneydrop_question_w, pshy.moneydrop_question_h, 0x010101, 0x0000ff, 0.8, true)
end



--- Timer callback wrapper for pshy.moneydrop_OpenDrop(index).
function pshy.moneydrop_OpenDropTimerCallback(timer_id, index)
	pshy.moneydrop_OpenDrop(index)
end



--- Open a drop.
-- This removes the trapdoor object.
function pshy.moneydrop_OpenDrop(index)
	pshy.moneydrop_DisplayAnswer(index, true)
	local drop = pshy.moneydrop_drops[index]
	tfm.exec.removePhysicObject(drop.trapdoor_id)
end



--- Lock Choices.
function pshy.moneydrop_LockChoices()
	-- @TODO: summon invisible ice walls
end



--- Close drops.
function pshy.moneydrop_CloseDrops(index)
	for i_drop, drop in pairs(pshy.moneydrop_drops) do
		 tfm.exec.addPhysicObject(drop.trapdoor_id, drop.trapdoor_x, drop.trapdoor_y, {type = 12, width = pshy.moneydrop_drop_trapdoor_w, height = pshy.moneydrop_drop_trapdoor_h, foreground = true, friction = 0.3, restitution = 0.4, angle = 0, color = 0x4444ff, miceCollision = true, groundCollision = true})
	end
end



--- TFM event eventNewGame.
function eventNewGame()
	pshy.moneydrop_Clear()
	pshy.moneydrop_NewQuestion()
	pshy.mapdb_current_map_autoskip = false
end



--- TFM event eventLoop
function eventLoop(time, time_remaining)
	if time_remaining <= 0 then
		if not pshy.moneydrop_dropping then
			pshy.moneydrop_Drop()
		else
			pshy.moneydrop_NewQuestion()
		end
	end
end



--- pshy event eventInit
function eventInit()
	tfm.exec.newGame(pshy.moneydrop_map)
end
