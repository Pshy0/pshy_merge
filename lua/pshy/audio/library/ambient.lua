--- pshy.audio.library.ambient
--
-- Collections of sounds.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



local ambient_lib = {}



--- List of ambient sounds.
ambient_lib.ambient_list = {
	"cite18/amb/0";
	"cite18/amb/100";
	--"cite18/amb/101"; -- duplicate
	"cite18/amb/102";
	"cite18/amb/200";
	"cite18/amb/201";
	"cite18/amb/300";
	"cite18/amb/301";
	"cite18/amb/302";
	"cite18/amb/400";
	"cite18/amb/401";
	"cite18/amb/402";
	"cite18/amb/403";
	"cite18/amb/404";
	"cite18/amb/500";
	"cite18/amb/501";
	"cite18/amb/502";
	"cite18/amb/503";
	"cite18/amb/504";
	"cite18/amb/505";
	"cite18/amb/506";
	"cite18/amb/507";
	"cite18/amb/508";
	"cite18/amb/509";
	"cite18/m-amb1";
	"deadmaze/cinematique/tremblement";
	"deadmaze/cinematique/voiture";
	"deadmaze/cuisine";
	"deadmaze/voiture";
	"deadmaze/x_amb_desert";
	"deadmaze/x_amb_feu";
	"deadmaze/x_amb_grotte";
	"deadmaze/x_amb_hiver";
	"deadmaze/x_amb_hiver2";
	"deadmaze/x_amb_interieur";
	"deadmaze/x_amb_neige";
	"deadmaze/x_amb_normandie";
	"deadmaze/x_amb_nuit";
	"deadmaze/x_amb_orage";
	"deadmaze/x_amb_pluie";
	"deadmaze/x_amb_pluie_interieur";
	"deadmaze/x_amb_vent";
	"fortoresse/x_ambiance_1";
	"fortoresse/x_ambiance_2";
	"fortoresse/x_ambiance_3";
	--"tfmadv/ambiance/desert"; -- duplicate
	"tfmadv/ambiance/foret";
	"tfmadv/ambiance/foret2";
	--"tfmadv/ambiance/grotte"; -- duplicate
	--"tfmadv/ambiance/hiver"; -- duplicate
	--"tfmadv/ambiance/hiver2"; -- duplicate
	--"tfmadv/ambiance/orage"; -- duplicate
	--"tfmadv/ambiance/pluie"; -- duplicate
	--"tfmadv/ambiance/pluie-interieur"; -- duplicate
	"tfmadv/ambiance/prairie";
	--"tfmadv/ambiance/vent"; -- duplicate
	"tfmadv/boucle-bulle";
	"tfmadv/boucle-cuisson";
	"tfmadv/bougie";
}



--- Set of game ambients.
ambient_lib.ambient_set = {}
for ambient_index, ambient_name in ipairs(ambient_lib.ambient_list) do
	ambient_lib.ambient_set[ambient_name] = true
end



return ambient_lib
