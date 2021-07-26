--- pacmouse.lua
--
-- @require pshy_perms.lua
-- @require pshy_lua_commands.lua
-- @require pshy_fun_commands.lua
-- @require pshy_speedfly.lua
-- @require pshy_keycodes.lua
-- @require pshy_splashscreen.lua
-- @require pshy_utils.lua
-- @require pshy_loopmore.lua
-- @require pshy_fcplatform.lua



--- help Page:
pshy.help_pages["pacmice"] = {back = "", title = "PacMice", text = "Oh no!\n", commands = {}}
pshy.help_pages[""].subpages["pacmice"] = pshy.help_pages["pacmice"]



--- TFM Settings
tfm.exec.disableAutoNewGame(true)
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAfkDeath(true)



--- Pshy Settings:
pshy.perms_auto_admin_authors = true
pshy.authors["Nnaaaz#0000"] = true
pshy.splashscreen_image = "17acb076edb.png"	-- splash image
pshy.splashscreen_x = 150					-- x location
pshy.splashscreen_y = 100					-- y location
pshy.splashscreen_sx = 1					-- scale on x
pshy.splashscreen_sy = 1					-- scale on y
pshy.splashscreen_text = nil
pshy.splashscreen_duration = 8				-- pacmice screen duration



--- Module Settings:
xml = [[<C><P H="720" MEDATA="0,1:1,1:2,1:3,1:4,1:5,1:6,1:7,1:8,1:9,1:10,1:11,1:12,1:13,1:14,1:15,1:16,1:17,1:18,1:19,1:20,1:21,1:22,1:23,1:24,1:25,1:26,1:27,1:28,1:29,1:30,1:31,1:32,1:33,1:34,1:35,1:36,1:37,1:38,1:39,1:40,1:41,1:42,1:43,1:44,1:45,1:46,1:47,1:48,1:49,1:50,1:51,1:52,1:53,1:54,1:55,1:56,1:57,1:58,1:59,1;;;;-0;0::0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147:1-"/><Z><S><S T="12" X="168" Y="107" L="56" H="56" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="613" Y="107" L="56" H="56" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="286" Y="107" L="79" H="56" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="495" Y="107" L="79" H="56" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="247" Y="263" L="10" H="160" P="0,0,0.5,0,0,0,0,0"/><S T="12" X="533" Y="263" L="10" H="160" P="0,0,0.5,0,0,0,0,0"/><S T="12" X="390" Y="29" L="605" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="91" Y="130" L="10" H="210" P="0,0,0.5,0,0,0,0,0"/><S T="12" X="690" Y="130" L="10" H="210" P="0,0,0.5,0,0,0,0,0"/><S T="12" X="141" Y="237" L="110" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="641" Y="237" L="108" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="196" Y="276" L="10" H="87" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="586" Y="277" L="10" H="88" P="0,0,0.5,0,0,0,0,0"/><S T="12" X="143" Y="316" L="113" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="636" Y="316" L="101" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="91" Y="343" L="10" H="60" P="0,0,0.5,0,0,0,0,0"/><S T="12" X="689" Y="342" L="10" H="62" P="0,0,0.5,0,0,0,0,0"/><S T="12" X="145" Y="368" L="111" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="635" Y="368" L="100" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="196" Y="408" L="10" H="83" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="586" Y="406" L="10" H="87" P="0,0,0.5,0,0,0,0,0"/><S T="12" X="145" Y="445" L="105" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="638" Y="445" L="105" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="90" Y="575" L="10" H="270" P="0,0,0.5,0,0,0,0,0"/><S T="12" X="690" Y="575" L="10" H="270" P="0,0,0.5,0,0,0,0,0"/><S T="12" X="390" Y="706" L="608" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="390" Y="82" L="32" H="108" P="0,0,0.5,0,0,0,0,0"/><S T="12" X="392" Y="186" L="180" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="391" Y="445" L="176" H="10" P="0,0,0.3,0,360,0,0,0"/><S T="12" X="389" Y="550" L="177" H="10" P="0,0,0.3,0,360,0,0,0"/><S T="12" X="234" Y="655" L="185" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="547" Y="655" L="184" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="170" Y="186" L="50" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="612" Y="186" L="50" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="390" Y="214" L="32" H="56" P="0,0,0.5,0,0,0,0,0"/><S T="12" X="390" Y="476" L="32" H="55" P="0,0,0.5,0,360,0,0,0"/><S T="12" X="390" Y="603" L="32" H="103" P="0,0,0.5,0,360,0,0,0"/><S T="12" X="172" Y="498" L="55" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="609" Y="498" L="55" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="195" Y="549" L="10" H="107" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="586" Y="549" L="10" H="107" P="0,0,0.5,0,0,0,0,0"/><S T="12" X="286" Y="498" L="73" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="495" Y="498" L="75" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="247" Y="420" L="10" H="55" P="0,0,0.5,0,0,0,0,0"/><S T="12" X="533" Y="420" L="10" H="56" P="0,0,0.5,0,0,0,0,0"/><S T="12" X="248" Y="600" L="10" H="100" P="0,0,0.5,0,0,0,0,0"/><S T="12" X="533" Y="600" L="10" H="99" P="0,0,0.5,0,0,0,0,0"/><S T="12" X="289" Y="238" L="75" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="493" Y="238" L="75" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="118" Y="576" L="52" H="54" P="0,0,0.5,0,0,0,0,0"/><S T="12" X="663" Y="576" L="52" H="54" P="0,0,0.5,0,0,0,0,0"/><S T="12" X="391" Y="393" L="190" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="300" Y="343" L="10" H="109" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="481" Y="343" L="10" H="108" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="325" Y="292" L="60" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="455" Y="292" L="60" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="312" Y="602" L="30" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="469" Y="602" L="30" H="10" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="390" Y="292" L="67" H="10" P="0,0,0.3,0,0,0,0,0" v="60000"/><S T="12" X="387" Y="724" L="10" H="10" P="1,0,0.3,0,0,1,0,0" c="4" v="60000"/></S><D><F X="390" Y="381"/><T X="392" Y="387" D=""/><DS X="388" Y="270"/></D><O/><L><JD c="000000,250,1,0" P1="-1600,800" P2="2400,800"/><JD c="000000,250,1,0" P1="-1600,1000" P2="2400,1000"/><JD c="000000,250,1,0" P1="-1600,1200" P2="2400,1200"/><JD c="000000,250,1,0" P1="-1600,600" P2="2400,600"/><JD c="000000,250,1,0" P1="-1600,400" P2="2400,400"/><JD c="000000,250,1,0" P1="-1600,200" P2="2400,200"/><JD c="000000,250,1,0" P1="-1600,0" P2="2400,0"/><JD c="000000,250,1,0" P1="-1600,-200" P2="2400,-200"/><JD c="000000,250,1,0" P1="-1600,-400" P2="2400,-400"/><JD c="1500fb,10,1,0" P1="91,29" P2="690,29"/><JD c="1500fb,10,1,0" P1="91,706" P2="690,706"/><JD c="1500fb,10,1,0" P1="91,30" P2="91,236"/><JD c="1500fb,10,1,0" P1="690,30" P2="690,236"/><JD c="1500fb,10,1,0" P1="91,446" P2="91,704"/><JD c="1500fb,10,1,0" P1="690,446" P2="690,704"/><JD c="1500fb,10,1,0" P1="91,237" P2="195,237"/><JD c="1500fb,10,1,0" P1="690,237" P2="586,237"/><JD c="1500fb,10,1,0" P1="149,186" P2="191,186"/><JD c="1500fb,10,1,0" P1="632,186" P2="590,186"/><JD c="1500fb,10,1,0" P1="301,292" P2="352,292"/><JD c="1500fb,10,1,0" M1="59" M2="59" P1="363,292" P2="419,292"/><JD c="1500fb,10,1,0" P1="480,292" P2="429,292"/><JD c="1500fb,10,1,0" P1="249,238" P2="322,238"/><JD c="1500fb,10,1,0" P1="532,238" P2="459,238"/><JD c="1500fb,10,1,0" P1="92,316" P2="195,316"/><JD c="1500fb,10,1,0" P1="689,316" P2="586,316"/><JD c="1500fb,10,1,0" P1="92,368" P2="195,368"/><JD c="1500fb,10,1,0" P1="689,368" P2="586,368"/><JD c="1500fb,10,1,0" P1="91,445" P2="195,445"/><JD c="1500fb,10,1,0" P1="690,445" P2="586,445"/><JD c="1500fb,10,1,0" P1="307,445" P2="476,445"/><JD c="1500fb,10,1,0" P1="302,393" P2="479,393"/><JD c="1500fb,10,1,0" P1="307,186" P2="478,186"/><JD c="1500fb,10,1,0" P1="305,550" P2="474,550"/><JD c="1500fb,10,1,0" P1="145,655" P2="323,655"/><JD c="1500fb,10,1,0" P1="636,655" P2="458,655"/><JD c="000000,6,1,0" P1="91,30" P2="91,236"/><JD c="000000,6,1,0" P1="690,30" P2="690,236"/><JD c="000000,6,1,0" P1="91,706" P2="690,706"/><JD c="1500fb,10,1,0" P1="148,498" P2="195,498"/><JD c="1500fb,10,1,0" P1="633,498" P2="586,498"/><JD c="1500fb,10,1,0" P1="254,498" P2="318,498"/><JD c="1500fb,10,1,0" P1="527,498" P2="463,498"/><JD c="1500fb,10,1,0" P1="301,602" P2="322,602"/><JD c="1500fb,10,1,0" P1="480,602" P2="459,602"/><JD c="1500fb,10,1,0" P1="195.5,237.5" P2="195.5,315.5"/><JD c="1500fb,10,1,0" P1="585.5,237.5" P2="585.5,315.5"/><JD c="1500fb,10,1,0" P1="300.5,294" P2="300.5,392"/><JD c="1500fb,10,1,0" P1="480.5,294" P2="480.5,392"/><JD c="1500fb,10,1,0" P1="247.5,186.5" P2="247.5,338.5"/><JD c="1500fb,10,1,0" P1="533.5,186.5" P2="533.5,338.5"/><JD c="1500fb,10,1,0" P1="195.5,368" P2="195.5,445"/><JD c="1500fb,10,1,0" P1="585.5,368" P2="585.5,445"/><JD c="000000,6,1,0" P1="91,446" P2="91,704"/><JD c="000000,6,1,0" P1="690,446" P2="690,704"/><JD c="1500fb,10,1,0" P1="247.5,397" P2="247.5,443"/><JD c="1500fb,10,1,0" P1="533.5,397" P2="533.5,443"/><JD c="1500fb,10,1,0" P1="195.5,498" P2="195.5,600"/><JD c="1500fb,10,1,0" P1="585.5,498" P2="585.5,600"/><JD c="1500fb,10,1,0" P1="247.5,553" P2="247.5,655"/><JD c="1500fb,10,1,0" P1="533.5,553" P2="533.5,655"/><JD c="1500fb,10,1,0" P1="91.5,316" P2="91.5,367"/><JD c="1500fb,10,1,0" P1="689.5,316" P2="689.5,367"/><JD c="000000,6,1,0" P1="91,237" P2="195,237"/><JD c="000000,6,1,0" P1="690,237" P2="586,237"/><JD c="000000,6,1,0" P1="149,186" P2="191,186"/><JD c="000000,6,1,0" P1="632,186" P2="590,186"/><JD c="000000,6,1,0" P1="301,292" P2="352,292"/><JD c="000000,6,1,0" M1="59" M2="59" P1="363,292" P2="419,292"/><JD c="000000,6,1,0" P1="480,292" P2="429,292"/><JD c="000000,6,1,0" P1="249,238" P2="322,238"/><JD c="000000,6,1,0" P1="532,238" P2="459,238"/><JD c="000000,6,1,0" P1="92,316" P2="195,316"/><JD c="000000,6,1,0" P1="689,316" P2="586,316"/><JD c="000000,6,1,0" P1="92,368" P2="195,368"/><JD c="000000,6,1,0" P1="689,368" P2="586,368"/><JD c="000000,6,1,0" P1="91,445" P2="195,445"/><JD c="000000,6,1,0" P1="690,445" P2="586,445"/><JD c="000000,6,1,0" P1="307,445" P2="476,445"/><JD c="000000,6,1,0" P1="302,393" P2="479,393"/><JD c="000000,6,1,0" P1="145,655" P2="323,655"/><JD c="000000,6,1,0" P1="636,655" P2="458,655"/><JD c="000000,6,1,0" P1="148,498" P2="195,498"/><JD c="000000,6,1,0" P1="633,498" P2="586,498"/><JD c="000000,6,1,0" P1="254,498" P2="318,498"/><JD c="000000,6,1,0" P1="527,498" P2="463,498"/><JD c="000000,6,1,0" P1="301,602" P2="322,602"/><JD c="000000,6,1,0" P1="480,602" P2="459,602"/><JD c="000000,6,1,0" P1="195.5,237.5" P2="195.5,315.5"/><JD c="000000,6,1,0" P1="585.5,237.5" P2="585.5,315.5"/><JD c="000000,6,1,0" P1="300.5,294" P2="300.5,392"/><JD c="000000,6,1,0" P1="480.5,294" P2="480.5,392"/><JD c="000000,6,1,0" P1="247.5,186.5" P2="247.5,338.5"/><JD c="000000,6,1,0" P1="533.5,186.5" P2="533.5,338.5"/><JD c="000000,6,1,0" P1="195.5,368" P2="195.5,445"/><JD c="000000,6,1,0" P1="585.5,368" P2="585.5,445"/><JD c="000000,6,1,0" P1="247.5,397" P2="247.5,443"/><JD c="000000,6,1,0" P1="533.5,397" P2="533.5,443"/><JD c="000000,6,1,0" P1="195.5,498" P2="195.5,600"/><JD c="000000,6,1,0" P1="585.5,498" P2="585.5,600"/><JD c="000000,6,1,0" P1="247.5,553" P2="247.5,655"/><JD c="000000,6,1,0" P1="533.5,553" P2="533.5,655"/><JD c="000000,6,1,0" P1="91.5,316" P2="91.5,367"/><JD c="000000,6,1,0" P1="689.5,316" P2="689.5,367"/><JD c="1500fb,3,1,0" P1="141,80" P2="195,80"/><JD c="1500fb,3,1,0" P1="640,80" P2="586,80"/><JD c="1500fb,3,1,0" P1="248,80" P2="324,80"/><JD c="1500fb,3,1,0" P1="533,80" P2="457,80"/><JD c="1500fb,3,1,0" P1="195,81" P2="195,134"/><JD c="1500fb,3,1,0" P1="586,81" P2="586,134"/><JD c="1500fb,3,1,0" P1="324,81" P2="324,134"/><JD c="1500fb,3,1,0" P1="375,33" P2="375,134"/><JD c="1500fb,3,1,0" P1="375,189" P2="375,240"/><JD c="1500fb,3,1,0" P1="375,450" P2="375,502"/><JD c="1500fb,3,1,0" P1="375,553" P2="375,653"/><JD c="1500fb,3,1,0" P1="405,33" P2="405,134"/><JD c="1500fb,3,1,0" P1="405,189" P2="405,240"/><JD c="1500fb,3,1,0" P1="404.88,450" P2="404.88,502"/><JD c="1500fb,3,1,0" P1="405,553" P2="405,653"/><JD c="1500fb,3,1,0" P1="457,81" P2="457,134"/><JD c="1500fb,3,1,0" P1="141,81" P2="141,134"/><JD c="1500fb,3,1,0" P1="640,81" P2="640,134"/><JD c="1500fb,3,1,0" P1="248,81" P2="248,134"/><JD c="000000,6,1,0" P1="307,186" P2="478,186"/><JD c="1500fb,3,1,0" P1="533,81" P2="533,134"/><JD c="1500fb,3,1,0" P1="141,134" P2="195,134"/><JD c="1500fb,3,1,0" P1="640,134" P2="586,134"/><JD c="1500fb,3,1,0" P1="248,134.5" P2="324,134.5"/><JD c="1500fb,3,1,0" P1="375,134.5" P2="405,134.5"/><JD c="000000,6,1,0" P1="305,550" P2="474,550"/><JD c="1500fb,3,1,0" P1="375,240.5" P2="405,240.5"/><JD c="1500fb,3,1,0" P1="375,502.5" P2="405,502.5"/><JD c="000000,6,1,0" P1="91,29" P2="690,29"/><JD c="1500fb,3,1,0" P1="375,653.5" P2="405,653.5"/><JD c="1500fb,3,1,0" P1="533,134" P2="457,134"/><JD c="1500fb,3,1,0" P1="96,551" P2="143,551"/><JD c="1500fb,3,1,0" P1="685,551" P2="638,551"/><JD c="1500fb,3,1,0" P1="96,601" P2="143,601"/><JD c="1500fb,3,1,0" P1="685,601" P2="638,601"/><JD c="1500fb,3,1,0" P1="143,551" P2="143,601"/><JD c="1500fb,3,1,0" P1="638,551" P2="638,601"/><JD c="000000,5,1,0" P1="379,449" P2="401,449"/><JD c="000000,5,1,0" P1="379,554" P2="401,554"/><JD c="000000,5,1,0" P1="379,190" P2="401,190"/><JD c="000000,5,1,0" P1="379,33" P2="401,33"/><JD c="000000,5,1,0" P1="686,555" P2="686,597"/><JD c="000000,5,1,0" P1="95,555" P2="95,597"/><JR M1="25" M2="59"/></L></Z></C>]]
path_cells = {{1, 1}, {2, 1}, {3, 1}, {4, 1}, {5, 1}, {6, 1}, {7, 1}, {8, 1}, {9, 1}, {10, 1}, {13, 1}, {14, 1}, {15, 1}, {16, 1}, {17, 1}, {18, 1}, {19, 1}, {20, 1}, {21, 1}, {22, 1}, {1, 2}, {5, 2}, {10, 2}, {13, 2}, {18, 2}, {22, 2}, {1, 3}, {5, 3}, {10, 3}, {13, 3}, {18, 3}, {22, 3}, {1, 4}, {5, 4}, {10, 4}, {13, 4}, {18, 4}, {22, 4}, {1, 5}, {2, 5}, {3, 5}, {4, 5}, {5, 5}, {6, 5}, {7, 5}, {8, 5}, {9, 5}, {10, 5}, {11, 5}, {12, 5}, {13, 5}, {14, 5}, {15, 5}, {16, 5}, {17, 5}, {18, 5}, {19, 5}, {20, 5}, {21, 5}, {22, 5}, {1, 6}, {5, 6}, {7, 6}, {16, 6}, {18, 6}, {22, 6}, {1, 7}, {2, 7}, {3, 7}, {4, 7}, {5, 7}, {7, 7}, {8, 7}, {9, 7}, {10, 7}, {13, 7}, {14, 7}, {15, 7}, {16, 7}, {18, 7}, {19, 7}, {20, 7}, {21, 7}, {22, 7}, {5, 8}, {10, 8}, {13, 8}, {18, 8}, {5, 9}, {7, 9}, {8, 9}, {9, 9}, {10, 9}, {11, 9}, {12, 9}, {13, 9}, {14, 9}, {15, 9}, {16, 9}, {18, 9}, {5, 10}, {7, 10}, {16, 10}, {18, 10}, {5, 11}, {7, 11}, {16, 11}, {18, 11}, {1, 12}, {2, 12}, {3, 12}, {4, 12}, {5, 12}, {7, 12}, {16, 12}, {18, 12}, {19, 12}, {20, 12}, {21, 12}, {22, 12}, {5, 13}, {6, 13}, {7, 13}, {16, 13}, {17, 13}, {18, 13}, {5, 14}, {7, 14}, {16, 14}, {18, 14}, {5, 15}, {7, 15}, {8, 15}, {9, 15}, {10, 15}, {11, 15}, {12, 15}, {13, 15}, {14, 15}, {15, 15}, {16, 15}, {18, 15}, {5, 16}, {7, 16}, {16, 16}, {18, 16}, {1, 17}, {2, 17}, {3, 17}, {4, 17}, {5, 17}, {6, 17}, {7, 17}, {8, 17}, {9, 17}, {10, 17}, {13, 17}, {14, 17}, {15, 17}, {16, 17}, {17, 17}, {18, 17}, {19, 17}, {20, 17}, {21, 17}, {22, 17}, {1, 18}, {5, 18}, {10, 18}, {13, 18}, {18, 18}, {22, 18}, {1, 19}, {2, 19}, {3, 19}, {5, 19}, {6, 19}, {7, 19}, {8, 19}, {9, 19}, {10, 19}, {11, 19}, {12, 19}, {13, 19}, {14, 19}, {15, 19}, {16, 19}, {17, 19}, {18, 19}, {20, 19}, {21, 19}, {22, 19}, {3, 20}, {5, 20}, {7, 20}, {16, 20}, {18, 20}, {20, 20}, {3, 21}, {5, 21}, {7, 21}, {8, 21}, {9, 21}, {10, 21}, {13, 21}, {14, 21}, {15, 21}, {16, 21}, {18, 21}, {20, 21}, {3, 22}, {5, 22}, {7, 22}, {10, 22}, {13, 22}, {16, 22}, {18, 22}, {20, 22}, {1, 23}, {2, 23}, {3, 23}, {4, 23}, {5, 23}, {7, 23}, {8, 23}, {9, 23}, {10, 23}, {13, 23}, {14, 23}, {15, 23}, {16, 23}, {18, 23}, {19, 23}, {20, 23}, {21, 23}, {22, 23}, {1, 24}, {10, 24}, {13, 24}, {22, 24}, {1, 25}, {2, 25}, {3, 25}, {4, 25}, {5, 25}, {6, 25}, {7, 25}, {8, 25}, {9, 25}, {10, 25}, {11, 25}, {12, 25}, {13, 25}, {14, 25}, {15, 25}, {16, 25}, {17, 25}, {18, 25}, {19, 25}, {20, 25}, {21, 25}, {22, 25}}
map_x = 91
map_y = 29
cell_w = 26
cell_h = 26
grid_w = 40
grid_h = 40
wall_size = 12



--- Internal use:
linear_grid = {}		-- every entry represent a cell's path availability
cur_pilot = nil			-- for generating pathes
cur_x = 0
cur_y = 0
cur_generating = false
pacmans = {}			-- map of pacmouces (key is the player name)
auto_respawn = true
pacmouse_count = 0



--- Create a pacman.
-- @player Player's Name#0000.
function CreatePacman(player_name)
	if pacmans[player_name] then
		DestroyPackman(player_name)
	end
	pacmans[player_name] = {}
	local pacman = pacmans[player_name]
	pacman.player_name = player_name
	pacman.cell_x = path_cells[1][1]
	pacman.cell_y = path_cells[1][2]
	pacman.cell_vx = 1
	pacman.cell_vy = 0
	pacman.wish_vx = 1
	pacman.wish_vy = 0
	pacman.image_id = nil
	pacman.direction = 0
	pacman.speed = 50
	pacman.size = 50
	pacman.image_animation_index = 0
	pacman.pacman_index = pacmouse_count
	tfm.exec.setShaman(player_name, false)
	tfm.exec.killPlayer(player_name)
	tfm.exec.removeCheese(player_name)
	--tfm.exec.respawnPlayer(player_name)
	--tfm.exec.movePlayer(player_name, pacman.cell_x * cell_w + map_x, pacman.cell_y * cell_h + map_y)
	--tfm.exec.changePlayerSize(player_name, (pacman.size - 4) / 35 )
	--tfm.exec.freezePlayer(player_name, true)
	pacmouse_count = pacmouse_count + 1
end



--- Destroy a pacman.
-- @player Player's Name#0000.
function DestroyPacman(player_name)
	if pacmans[player_name] then
		local pacman = pacmans[player_name]
		if pacman.image_id then
			tfm.exec.removeImage(pacman.image_id)
		end
		tfm.exec.killPlayer(player_name)
		pacmans[player_name] = nil
	end
	pacmouse_count = pacmouse_count - 1
end



--- Draw a pacman.
-- @player Player's Name#0000.
function DrawPacman(player_name)
	local pacman = pacmans[player_name]
	local x = pacman.cell_x * cell_w + map_x
	local y = pacman.cell_y * cell_h + map_y
	-- next image
	pacman.image_animation_index = (pacman.image_animation_index + 1) % 2
	local image_code = ({"17ad578a939.png", "17ad578c0aa.png"})[pacman.image_animation_index + 1] -- jerry: 1718e698ac9.png -- pacman: 
	-- @todo
	old_image_id = pacman.image_id
	local size = (cell_w * 2) - wall_size
	--tfm.exec.addPhysicObject(5, x, y, {type = tfm.enum.ground.rectangle, width = size, height = size, foreground = false, color = 0xffff00, miceCollision = false})
	pacman.image_id = tfm.exec.addImage(image_code, "!0", x, y, nil, 1.0, 1.0, pacman.direction, 1.0, 0.5, 0.5)
	--pacman.image_id = tfm.exec.addImage("1718e698ac9.png", "$" .. player_name, 0, 0, nil, 0.5, 0.5, pacman.direction, 1.0, 0.5, 0.5)
	if old_image_id then
		tfm.exec.removeImage(old_image_id)
	end
	-- acid
	tfm.exec.addPhysicObject(pacman.pacman_index * 2 + 1, x, y, {type = tfm.enum.ground.acid, width = size, height = size, foreground = false, color = 0x0, miceCollision = true})
	tfm.exec.addPhysicObject(pacman.pacman_index * 2 + 2, x, y, {type = tfm.enum.ground.rectangle, width = size, height = size, foreground = false, color = 0x1, miceCollision = false})
end



--- Get a cell value.
function GridGet(x, y)
	return linear_grid[y * grid_w + x]
end



--- Set a cell value.
function GridSet(x, y, value)
	linear_grid[y * grid_w + x] = value
end



--- Redraw the cursor.
function DrawCursor()
	local x = cur_x * cell_w + map_x
	local y = cur_y * cell_h + map_y
	if cur_pilot then
		tfm.exec.addPhysicObject(1, x + cell_w / 2, y, {type = tfm.enum.ground.rectangle, width = 5, height = 2000, foreground = false, color = 0xdd4400, miceCollision = false})
		tfm.exec.addPhysicObject(2, x - cell_w / 2, y, {type = tfm.enum.ground.rectangle, width = 5, height = 2000, foreground = false, color = 0xdd4400, miceCollision = false})
		tfm.exec.addPhysicObject(3, x, y + cell_h / 2, {type = tfm.enum.ground.rectangle, width = 2000, height = 5, foreground = false, color = 0xdd4400, miceCollision = false})
		tfm.exec.addPhysicObject(4, x, y - cell_h / 2, {type = tfm.enum.ground.rectangle, width = 2000, height = 5, foreground = false, color = 0xdd4400, miceCollision = false})
	else
		tfm.exec.removeObject(1)
		tfm.exec.removeObject(2)
		tfm.exec.removeObject(3)
		tfm.exec.removeObject(4)
	end
end



--- Move the generation cursor, handling colisions.
function MoveCursor(x, y)
	if not cur_generating then
		-- map bounds
		if x < 0 or y < 0 or x >= grid_w or y >= grid_h then
			return
		end
		-- walls
		if not GridGet(x, y) then
			return
		end
	end
	cur_x = x
	cur_y = y
	if cur_generating then
		GridSet(x, y, true)
	end
end



--- Get a vector from a direction key.
function KeycodeToVector(keycode)
	if keycode == pshy.keycodes.UP then
		return 0, -1
	elseif keycode == pshy.keycodes.DOWN then
		return 0, 1
	elseif keycode == pshy.keycodes.LEFT then
		return -1, 0
	elseif keycode == pshy.keycodes.RIGHT then
		return 1, 0
	end
end



--- Get a direction from a vector.
function VectorToDirection(x, y)
	if x == 1 and y == 0 then
		return 0
	elseif x == 0 and y == 1 then
		return (math.pi / 2) * 1
	elseif x == -1 and y == 0 then
		return (math.pi / 2) * 2
	elseif x == 0 and y == -1 then
		return (math.pi / 2) * 3
	end
	error("unexpected")
end



--- Generate a default grid.
function GenerateGrid(w, h)
	grid_w = w
	grid_h = h
	for y = 0, (h - 1) do
		for x = 0, (w - 1) do
			--linear_grid[y * w] = nil
		end
	end
end



--- Get grid coordinates from a point on screen.
function GetGridCoords(x, y)
	x = math.floor((x - map_x) / cell_w + 0.5)
	y = math.floor((y - map_y) / cell_h + 0.5)
	return x, y
end



--- Export the grid.
function GridExportPathes(player_name)
	local total = "{"
	-- generate export string
	for y = 0, (grid_h - 1) do
		for x = 0, (grid_w - 1) do
			if GridGet(x, y) then
				if #total > 1 then
					total = total .. ", "
				end
				total = total .. "{" .. tostring(x) .. ", " .. tostring(y) .. "}"
			end
		end
	end
	total = total .. "}"
	-- export
	while #total > 0 do
		subtotal = string.sub(total, 1, 180)
		tfm.exec.chatMessage(subtotal, player_name)
		total = string.sub(total, 181, #total)
	end
end



--- TFM event eventMouse.
function eventMouse(player_name, x, y)
	if player_name == cur_pilot then
		x, y = GetGridCoords(x, y)
		MoveCursor(x, y)
		DrawCursor()
		return true
	end
end



--- TFM event eventkeyboard.
function eventKeyboard(player_name, keycode, down, x, y)
	if player_name == cur_pilot and (keycode == 0 or keycode == 1 or keycode == 2 or keycode == 3) then
		vx, vy = KeycodeToVector(keycode)
		MoveCursor(cur_x + vx, cur_y + vy)
		DrawCursor()
	else
		local pacman = pacmans[player_name]
		if pacman then
			pacman.wish_vx, pacman.wish_vy = KeycodeToVector(keycode)
		end
	end
end



--- TFM event eventLoop.
function eventLoopMore(time, time_remaining)
	for player_name, pacman in pairs(pacmans) do
		--pacman.cell_x, pacman.cell_y = GetGridCoords(tfm.get.room.playerList[player_name].x, tfm.get.room.playerList[player_name].y)
		local wish_x = pacman.cell_x + pacman.wish_vx
		local wish_y = pacman.cell_y + pacman.wish_vy
		if GridGet(wish_x, wish_y) then
			pacman.cell_vx = pacman.wish_vx
			pacman.cell_vy = pacman.wish_vy
		end
		if pacman.cell_vx ~= 0 or pacman.cell_vy ~= 0 then
			local seen_x = pacman.cell_x + pacman.cell_vx
			local seen_y = pacman.cell_y + pacman.cell_vy
			if GridGet(seen_x, seen_y) then
				pacman.cell_x = seen_x
				pacman.cell_y = seen_y
				pacman.direction = VectorToDirection(pacman.cell_vx, pacman.cell_vy)
			else		
				pacman.cell_vx = 0
				pacman.cell_vy = 0
			end
		end
--		pacman.cell_vx = pacman.wish_vx
--		pacman.cell_vy = pacman.wish_vy
--		pacman.direction = VectorToDirection(pacman.cell_vx, pacman.cell_vy)
--		tfm.exec.movePlayer(player_name, 0, 0, true, pacman.cell_vx * pacman.speed, pacman.cell_vy * pacman.speed, false)
		DrawPacman(player_name)
	end
end



--- TFM event eventnewPlayer.
function eventNewPlayer(player_name)
	if auto_respawn and not pacmans[player_name] then
		tfm.exec.respawnPlayer(player_name)
	end
end



--- TFM event eventPlayerDied.
function eventPlayerDied(player_name)
	if auto_respawn and not pacmans[player_name] then
		tfm.exec.respawnPlayer(player_name)
	end
end



--- !pacmouse
function ChatCommandPackmouse(user, target)
	target = target or user
	if target ~= user and not pshy.HavePerm(user, "!pacmouse-others") then
		return false, "You cant use this command on others :c"
	end
	if pacmans[target] then
		DestroyPacman(target)
	else
		if pacmouse_count >= 2 then
			return false, "Too many pacmice :c"
		end
		CreatePacman(target)
	end
end
pshy.chat_commands["pacmouse"] = {func = ChatCommandPackmouse, desc = "be a pacmouse", argc_min = 0, argc_max = 1, arg_types = {"string"}, arg_names = {"Target#0000"}}
pshy.help_pages["pacmice"].commands["pacmouse"] = pshy.chat_commands["pacmouse"]
pshy.perms.everyone["!pacmouse"] = false



--- !clear
function ChatCommandPackmouse(user, target)
	tfm.exec.chatMessage("\n\n\n\n\n\n\n\n\n\n\n\n\n", nil)
end
pshy.chat_commands["clear"] = {func = ChatCommandPackmouse, desc = "clear the chat", argc_min = 0, argc_max = 0}
pshy.help_pages["pacmice"].commands["clear"] = pshy.chat_commands["clear"]
pshy.perms.everyone["!clear"] = false



--- Initialization:
GenerateGrid(grid_w, grid_h)
for i_path, path in ipairs(path_cells) do
	GridSet(path[1], path[2], true)
end
for player_name in pairs(tfm.get.room.playerList) do
	system.bindMouse(player_name, true)
	system.bindKeyboard(player_name, pshy.keycodes.UP, true, true)
	system.bindKeyboard(player_name, pshy.keycodes.DOWN, true, true)
	system.bindKeyboard(player_name, pshy.keycodes.LEFT, true, true)
	system.bindKeyboard(player_name, pshy.keycodes.RIGHT, true, true)
end
tfm.exec.newGame(xml)
