--- pshy.maps.list
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script)



--- Map of maps.
local maps = {}



--- Test Map:
maps["test"]		= {author = "Test#0801", title = "Test Map", title_color="#ff7700", background_color = "#FF00FF", xml = [[<C><P F="0" shaman_tools="1,33,102,110,111,202,302,402,608,1002,2802,2,2806" MEDATA=";;;;-0;0:::1-"/><Z><S><S T="6" X="400" Y="250" L="120" H="40" P="0,0,0.3,0.2,0,0,0,0"/></S><D><F X="432" Y="218"/><P X="393" Y="230" T="11" P="0,0"/><DC X="362" Y="213"/><DS X="436" Y="107"/></D><O/><L/></Z></C>]]}
maps["error_map"]	= {author = "Error", duration = 20, title = "an error happened", xml = 7893612}



return maps
