--- pshy_lobby.lua
--
-- @author: TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_mapdb.lua



--- Map began callback.
-- @private
function pshy.lobby_Began()
	tfm.exec.addTextArea(9, "<p align='center'><font size='16'><fc>Lobby</fc></font>\n<j>Waiting for players...</j></p>", nil, 200, 0, 400, 0, 0x1, 0x0, 0.0, false)
end



--- Map began callback.
-- @private
function pshy.lobby_Ended()
	tfm.exec.removeTextArea(9, nil)
end



--- Module Settings:
pshy.lobby_map_name = "lobby"
pshy.mapdb_maps[pshy.lobby_map_name] = {}					-- lobby map in mapdb
pshy.mapdb_maps[pshy.lobby_map_name].author = "Pshy#3752"
pshy.mapdb_maps[pshy.lobby_map_name].xml = '<C><P DS="m;391,267,223,80,25,233,256,266,476,266" Ca="" MEDATA=";2,1;;;-0;0:::1-"/><Z><S><S T="17" X="400" Y="380" L="400" H="200" P="0,0,0.3,0.2,0,0,0,0"/><S T="9" X="400" Y="375" L="800" H="50" P="0,0,0,0,0,0,0,0"/><S T="17" X="837" Y="384" L="80" H="200" P="0,0,0.3,0.2,-30,0,0,0" N=""/><S T="12" X="400" Y="400" L="800" H="100" P="0,0,0.3,1,0,0,0,0" o="008F00" c="4"/><S T="17" X="865" Y="308" L="80" H="200" P="0,0,0.3,0.2,-40,0,0,0" N=""/><S T="17" X="514" Y="444" L="200" H="200" P="0,0,0.3,0.2,-8,0,0,0" N=""/><S T="17" X="888" Y="216" L="80" H="200" P="0,0,0.3,0.2,-70,0,0,0" N=""/><S T="17" X="890" Y="121" L="80" H="200" P="0,0,0.3,0.2,-90,0,0,0" N=""/><S T="17" X="250" Y="422" L="120" H="200" P="0,0,0.3,0.2,-10,0,0,0" N=""/><S T="17" X="371" Y="430" L="200" H="200" P="0,0,0.3,0.2,10,0,0,0" N=""/><S T="17" X="-29" Y="169" L="80" H="200" P="0,0,0.3,0.2,4,0,0,0" N=""/><S T="17" X="-12" Y="344" L="80" H="200" P="0,0,0.3,0.2,4,0,0,0" N=""/><S T="17" X="-7" Y="375" L="80" H="200" P="0,0,0.3,0.2,20,0,0,0" N=""/><S T="19" X="68" Y="286" L="10" H="10" P="1,200,0,1,40,1,0,0"/><S T="19" X="172" Y="323" L="10" H="10" P="1,200,0,1,40,1,0,0"/><S T="19" X="655" Y="324" L="10" H="10" P="1,200,0,1,40,1,0,0"/><S T="19" X="762" Y="303" L="10" H="10" P="1,200,0,1,40,1,0,0"/><S T="2" X="693" Y="369" L="172" H="10" P="0,0,0,1.2,-10,0,0,0" c="2" N="" m=""/><S T="2" X="684" Y="370" L="172" H="10" P="0,0,0,1.2,10,0,0,0" c="2" N="" m=""/><S T="2" X="112" Y="367" L="172" H="10" P="0,0,0,1.2,-10,0,0,0" c="2" N="" m=""/><S T="2" X="109" Y="367" L="172" H="10" P="0,0,0,1.2,10,0,0,0" c="2" N="" m=""/><S T="17" X="869" Y="-22" L="80" H="200" P="0,0,0.3,0.2,-120,0,0,0" N=""/><S T="17" X="-64" Y="-42" L="80" H="200" P="0,0,0.3,0.2,-230,0,0,0" N=""/><S T="12" X="219" Y="101" L="75" H="10" P="0,0,0.3,0.2,0,0,0,0" o="FFFFFF" N="" m=""/><S T="13" X="592" Y="156" L="10" P="0,0,0.3,0.2,0,0,0,0" o="FFFFFF" N="" m=""/><S T="13" X="495" Y="171" L="10" P="0,0,0.3,0.2,0,0,0,0" o="FFFFFF" N="" m=""/><S T="13" X="548" Y="103" L="10" P="0,0,0.3,0.2,0,0,0,0" o="FFFFFF" N="" m=""/><S T="13" X="547" Y="177" L="10" P="0,0,0.3,0.2,0,0,0,0" o="FFFFFF" N="" m=""/></S><D><P X="0" Y="0" T="34" C="00062C" P="0,0"/><P X="211" Y="277" T="2" P="0,0"/><P X="310" Y="279" T="5" P="1,0"/><P X="29" Y="246" T="11" P="0,0"/><P X="209" Y="89" T="156" P="0,0"/><P X="538" Y="340" T="11" P="1,0"/><P X="429" Y="280" T="11" P="0,0"/><P X="536" Y="278" T="42" P="0,0"/><P X="452" Y="345" T="252" P="1,0"/></D><O/><L/></Z></C>'
pshy.mapdb_maps[pshy.lobby_map_name].func_begin = pshy.lobby_Began
pshy.mapdb_maps[pshy.lobby_map_name].func_end = pshy.lobby_Ended



--- Initialization:
function eventInit()
	tfm.exec.disableAutoShaman(true)
	tfm.exec.newGame(pshy.lobby_map_name)
end
