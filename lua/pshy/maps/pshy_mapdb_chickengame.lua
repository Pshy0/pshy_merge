--- pshy_mapdb_chickengame.lua
--
-- Additional maps for Nnaaaz's currently not named minigame.
--
-- @author: TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_basic_bonuses.lua
-- @require pshy_mapdb.lua
-- @require pshy_newgame.lua



--- Maps:
local maps = {}
-- Pshy map 1 (use your head):
pshy.mapdb_maps["chickengame_pshy_1"] = {author = "Pshy#3752", shamans = 0, autoskip = false, xml = [[<C><P mc="" MEDATA=";;;;-0;0::0,1,2,3,4,5,6,7,8,9,10,11,12:1-"/><Z><S><S T="12" X="400" Y="400" L="800" H="16" P="0,0,0.3,0.2,0,0,0,0" o="292020"/><S T="12" X="76" Y="448" L="20" H="20" P="1,1000000000000,0,0,0,1,0,0" c="2"/><S T="12" X="737" Y="363" L="58" H="14" P="1,1000000,0,0,-90,1,0,0" o="FB0000" c="3"/><S T="12" X="76" Y="481" L="20" H="20" P="1,1000000000000,0,0,0,1,0,0" c="4"/><S T="12" X="76" Y="422" L="80" H="20" P="1,0,0,0,0,1,0,0" c="2"/><S T="12" X="682" Y="324" L="26" H="10" P="1,0,20,0,0,1,0,0" c="2"/><S T="13" X="477" Y="58" L="10" P="0,9999999,0.3,0.2,0,1,Infinity,0" o="00FF2F" c="4" i="-13,-12,17ea2bfde60.png"/><S T="13" X="276" Y="39" L="10" P="0,9999999,0.3,0.2,0,1,Infinity,0" o="1400FF" c="4" i="-13,-12,17ea2c02a61.png"/><S T="13" X="277" Y="88" L="10" P="1,50,0,0,0,0,1,0" c="4"/><S T="13" X="571" Y="65" L="10" P="1,100,0,0,0,0,1,0" c="4"/><S T="13" X="571" Y="65" L="10" P="1,100,0,0,0,0,1,0" c="4" lua="3"/><S T="12" X="653" Y="304" L="10" H="36" P="0,0,0.3,0.2,0,0,0,0" o="451B20"/><S T="13" X="277" Y="88" L="10" P="1,50,0,0,0,0,1,0" c="4" lua="4"/><S T="12" X="711" Y="304" L="10" H="36" P="0,0,0.3,0.2,0,0,0,0" o="451B20"/><S T="12" X="682" Y="324" L="10" H="68" P="0,0,0.3,0.2,-90,0,0,0" o="451B20" c="3"/><S T="12" X="772" Y="339" L="56" H="10" P="0,0,0.3,0.2,0,0,0,0" o="292020"/><S T="12" X="795" Y="365" L="54" H="10" P="0,0,0.3,0.2,90,0,0,0" o="292020"/><S T="12" X="681" Y="305" L="44" H="20" P="0,0,0.3,0.2,0,0,0,0" o="324650" c="4" i="0,0,17eb2ae2806.png"/><S T="13" X="274" Y="84" L="20" P="1,100,0.3,0,0,0,0,0" o="324650" i="-23,-30,17eb2ae7c0c.png"/><S T="12" X="280" Y="215" L="115" H="10" P="0,0,0.1,0.2,5,0,0,0" o="2E190C"/><S T="12" X="226" Y="227" L="43" H="10" P="0,0,0.3,0.2,95,0,0,0" o="2E190C"/><S T="12" X="196" Y="241" L="49" H="10" P="0,0,0.3,0.2,185,0,0,0" o="2E190C"/><S T="12" X="169" Y="223" L="41" H="10" P="0,0,0.3,0.2,275,0,0,0" o="2E190C"/><S T="12" X="98" Y="201" L="154" H="10" P="0,0,0.1,0.2,5,0,0,0" o="2E190C"/><S T="12" X="596" Y="276" L="125" H="10" P="0,0,0.1,0.2,5,0,0,0" o="2E190C"/><S T="12" X="537" Y="287" L="40" H="10" P="0,0,0.3,0.2,95,0,0,0" o="2E190C"/><S T="12" X="515" Y="300" L="49" H="10" P="0,0,0.3,0.2,185,0,0,0" o="2E190C"/><S T="12" X="489" Y="283" L="41" H="10" P="0,0,0.3,0.2,275,0,0,0" o="2E190C"/><S T="12" X="458" Y="263" L="75" H="10" P="0,0,0.1,0,5,0,0,0" o="2E190C"/><S T="12" X="231" Y="114" L="174" H="10" P="0,0,0,0.2,-5,0,0,0" o="2E190C"/><S T="12" X="384" Y="113" L="60" H="10" P="0,0,0.3,0.2,5,0,0,0" o="C3AA7F" c="2" lua="2"/><S T="12" X="124" Y="60" L="30" H="10" P="0,0,0.3,0.2,5,0,0,0" o="C27E7E" c="2" lua="1"/><S T="12" X="26" Y="122" L="154" H="10" P="0,0,0.3,0.2,95,0,0,0" o="2E190C"/><S T="12" X="392" Y="295" L="30" H="10" P="0,0,0.3,0,185,0,0,0" o="2E190C"/><S T="12" X="571" Y="65" L="38" H="38" P="1,0,0.3,0.4,5,1,0,0" o="3CD698"/><S T="12" X="569" Y="90" L="38" H="10" P="0,0,0,0,5,0,0,0" o="324650" c="2" v="6000"/><S T="12" X="712" Y="272" L="30" H="10" P="0,0,0.3,0,275,0,0,0" o="2E190C" c="2" m=""/><S T="13" X="123" Y="68" L="10" P="0,9999999,0.3,0.2,0,1,Infinity,0" o="ED0000" c="4" i="-14,-12,17ea2befa39.png"/><S T="13" X="382" Y="121" L="10" P="0,9999999,0.3,0.2,0,1,Infinity,0" o="FF8A00" c="4" i="-14,-12,17ea2bf9260.png"/></S><D><F X="766" Y="385"/><T X="767" Y="392"/><DS X="400" Y="375"/></D><O><O X="681" Y="290" C="0" P="0"/><O X="125" Y="40" C="1" P="5,0"/><O X="387" Y="77" C="2" P="5,0"/></O><L><JR M1="1"/><JP M1="2" AXIS="0,1"/><JR M1="2" M2="1"/><JP M1="3" AXIS="0,1" LIM1="-100" LIM2="0" MV="Infinity,-1000000"/><JR M1="3" M2="2"/><JP M1="5" AXIS="0,1" LIM1="-1" LIM2="0" MV="867,0"/><JR M1="5" M2="4"/><JD c="584141,3,1,0" AMP="1" HZ="5" M1="9" M2="6"/><JD c="584141,3,1,0" AMP="1" M1="8" M2="7"/><JR M1="8" M2="12"/><JR M1="9" M2="10"/><JR M1="12" M2="18"/><JR M1="10" M2="34"/></L></Z></C>]]}
pshy.mapdb_maps["chickengame_pshy_1"].bonuses = {
	{type = "BonusRemoveGround", image = "17d0739e454.png", x = 30, y = 375, remove_ground_id = {1}};
	{type = "BonusRemoveGround", image = "17d0b98f194.png", x = 90, y = 375, remove_ground_id = {2}};
	{type = "BonusRemoveGround", image = "17d0b990904.png", x = 150, y = 375, remove_ground_id = {3}};
	{type = "BonusRemoveGround", image = "17d0b992075.png", x = 210, y = 375, remove_ground_id = {4}};
}
table.insert(maps, "chickengame_pshy_1")
-- Pshy map 2 (hammer):
pshy.mapdb_maps["chickengame_pshy_2"] = {author = "Pshy#3752", shamans = 0, autoskip = false, xml = [[<C><P Ca="" mc="" MEDATA=";;;;-0;0::0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23:1-"/><Z><S><S T="12" X="390" Y="-154" L="10" H="775" P="1,0,0.3,0.2,-50,0,0,0" o="596574" c="4"/><S T="12" X="673" Y="82" L="114" H="70" P="1,500,0,2,-50,0,0,0" o="A95A5A"/><S T="12" X="400" Y="400" L="800" H="16" P="0,0,0.3,0.2,0,0,0,0" o="292020"/><S T="12" X="76" Y="448" L="20" H="20" P="1,1000000000000,0,0,0,1,0,0" c="2"/><S T="12" X="737" Y="363" L="58" H="14" P="1,1000000,0,0,-90,1,0,0" o="FB0000" c="3"/><S T="12" X="76" Y="481" L="20" H="20" P="1,1000000000000,0,0,0,1,0,0" c="4"/><S T="12" X="76" Y="422" L="80" H="20" P="1,0,0,0,0,1,0,0" c="2"/><S T="12" X="207" Y="253" L="26" H="10" P="1,0,20,0,0,1,0,0" c="2"/><S T="13" X="382" Y="45" L="10" P="0,9999999,0.3,0.2,0,1,Infinity,0" o="00FF2F" c="4" i="-13,-12,17ea2bfde60.png"/><S T="12" X="256" Y="216" L="50" H="10" P="0,0,0.3,0.2,-10,0,0,0" o="77848A" c="2"/><S T="12" X="158" Y="215" L="50" H="10" P="0,0,0.3,0.2,10,0,0,0" o="77848A" c="2"/><S T="13" X="755" Y="53" L="10" P="0,9999999,0.3,0.2,0,1,Infinity,0" o="ED0000" c="4" i="-14,-12,17ea2befa39.png"/><S T="13" X="315" Y="133" L="10" P="0,9999999,0.3,0.2,0,1,Infinity,0" o="1400FF" c="4" i="-13,-12,17ea2c02a61.png"/><S T="13" X="478" Y="32" L="10" P="0,9999999,0.3,0.2,0,1,Infinity,0" o="FF8A00" c="4" i="-14,-12,17ea2bf9260.png"/><S T="13" X="479" Y="225" L="10" P="1,0,0.3,0.2,0,0,1,0" c="4"/><S T="13" X="716" Y="69" L="10" P="1,100,0,0,0,0,1,0" c="4"/><S T="13" X="315" Y="212" L="10" P="1,50,0,0,0,0,1,0" c="4"/><S T="13" X="716" Y="69" L="10" P="1,100,0,0,0,0,1,0" c="4" lua="1"/><S T="13" X="479" Y="225" L="10" P="1,0,0.3,0.2,10,0,1,0" c="4" lua="2"/><S T="13" X="382" Y="96" L="10" P="1,100,0,0,0,0,1,0" c="4"/><S T="13" X="382" Y="96" L="10" P="1,100,0,0,0,0,1,0" c="4" lua="3"/><S T="12" X="178" Y="233" L="10" H="36" P="0,0,0.3,0.2,0,0,0,0" o="451B20"/><S T="13" X="315" Y="212" L="10" P="1,50,0,0,0,0,1,0" c="4" lua="4"/><S T="12" X="236" Y="233" L="10" H="36" P="0,0,0.3,0.2,0,0,0,0" o="451B20"/><S T="12" X="207" Y="253" L="10" H="68" P="0,0,0.3,0.2,-90,0,0,0" o="451B20" c="3"/><S T="12" X="772" Y="339" L="56" H="10" P="0,0,0.3,0.2,0,0,0,0" o="292020"/><S T="12" X="795" Y="365" L="54" H="10" P="0,0,0.3,0.2,90,0,0,0" o="292020"/><S T="12" X="206" Y="234" L="44" H="20" P="0,0,0.3,0.2,0,0,0,0" o="324650" c="4" i="0,0,17eb2ae2806.png"/><S T="13" X="479" Y="225" L="20" P="1,100,0.3,0,0,0,0,0" o="324650" i="-23,-30,17eb2ae7c0c.png"/><S T="12" X="380" Y="104" L="32" H="32" P="1,25,0.4,0.2,0,1,0,0" o="83CC9A"/><S T="1" X="315" Y="232" L="60" H="60" P="1,50,0,0.2,0,1,0,0"/><S T="19" X="-37" Y="197" L="10" H="383" P="0,0,0.3,0,0,0,0,0" c="3"/><S T="12" X="133" Y="183" L="50" H="10" P="0,0,0.3,0.2,90,0,0,0" o="77848A" c="2" m=""/></S><D><F X="766" Y="385"/><T X="767" Y="392"/><DS X="400" Y="375"/></D><O><O X="208" Y="208" C="0" P="0"/><O X="98" Y="-400" C="11" P="0"/><O X="650" Y="62" C="14" P="0"/><O X="675" Y="83" C="14" P="0"/></O><L><JR M1="3" M2="2"/><JP M1="4" M2="2" AXIS="0,1"/><JR M1="4" M2="3"/><JP M1="5" M2="2" AXIS="0,1" LIM1="-100" LIM2="0" MV="Infinity,-1000000"/><JR M1="5" M2="4"/><JP M1="7" M2="2" AXIS="0,1" LIM1="-1" LIM2="0" MV="867,0"/><JR M1="7" M2="6"/><JD c="584141,3,1,0" AMP="1" HZ="5" M1="19" M2="8"/><JD c="584141,3,1,0" AMP="1" HZ="5" M1="15" M2="11"/><JD c="584141,3,1,0" AMP="1" M1="16" M2="12"/><JD c="584141,3,1,0" AMP="1" HZ="5" M1="14" M2="13"/><JR M1="15" M2="17"/><JR M1="16" M2="22"/><JR M1="19" M2="20"/><JR M1="14" M2="18"/><JD c="000000,3,1,1" M1="2" M2="2" P1="725.24,133.03" P2="716.48,134.8"/><JD c="000000,3,1,1" M1="2" M2="2" P1="717.37,139.18" P2="708.6,140.95"/><JD c="000000,3,1,1" M1="2" M2="2" P1="720.32,126.71" P2="716.48,134.8"/><JD c="000000,3,1,1" M1="2" M2="2" P1="712.44,132.88" P2="708.6,140.95"/><JR M2="1"/><JR M1="17" M2="1"/><JR M1="18" M2="28"/><JR M1="20" M2="29"/><JR M1="22" M2="30"/></L></Z></C>]]}
pshy.mapdb_maps["chickengame_pshy_2"].bonuses = {
	{type = "BonusRemoveGround", image = "17d0739e454.png", x = 30, y = 375, remove_ground_id = {1}};
	{type = "BonusRemoveGround", image = "17d0b98f194.png", x = 90, y = 375, remove_ground_id = {2}};
	{type = "BonusRemoveGround", image = "17d0b990904.png", x = 150, y = 375, remove_ground_id = {3}};
	{type = "BonusRemoveGround", image = "17d0b992075.png", x = 210, y = 375, remove_ground_id = {4}};
}
table.insert(maps, "chickengame_pshy_2")



--- Rotation:
pshy.mapdb_rotations["chickengame_pshy"]	= {desc = "", shamans = 0, autoskip = false, is_random = false, items = maps}



function eventInit()
	if __IS_MAIN_MODULE__ then
		tfm.exec.disableAfkDeath()
		pshy.newgame_ChatCommandRotc(nil, "chickengame_pshy")
		tfm.exec.newGame()
		tfm.exec.chatMessages("<b><o>This game is singleplayer (decide who plays each turn)!</o></b>")
		tfm.exec.chatMessages("<j>Help the chicken to return to its eggs.</j>")
		tfm.exec.chatMessages("<j>The game's concept is from Nnaaaz, this script is only here to test maps I made (so 2 in total).</j>")
		tfm.exec.chatMessages("<j>Use '!replay' to retry the map.</j>")
	end
end
