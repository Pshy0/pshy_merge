# Author: TFM:Pshy#3752 DC:Pshy#7998

# Modulepacks names:
NAME_PSHYVS				= examples/pshy_vs.tfm.lua.txt
NAME_PSHYVS_COMMENTATOR	= examples/pshy_vs_with_commentator.tfm.lua.txt
NAME_PSHYFUN			= examples/pshy_fun.tfm.lua.txt
NAME_MARIO				= examples/pshy_mario.tfm.lua.txt
NAME_PACMICE			= examples/pshy_pacmice.tfm.lua.txt
NAME_BONUSES			= examples/pshy_mapdb_bonuses.tfm.lua.txt
NAME_CHICKENGAME		= examples/pshy_mapdb_chickengame.tfm.lua.txt
NAME_123SOLEIL			= examples/pshy_123soleil.tfm.lua.txt
NAME_ESSENTIALS_PLUS	= examples/pshy_essentials_plus.tfm.lua.txt
NAME_FASTTIME			= examples/pshy_fasttime.tfm.lua.txt
NAME_THEBESTSHAMAN		= examples/pshy_thebestshaman.tfm.lua.txt
NAME_TFMEMULATOR		= examples/pshy_tfm_emulator.tfm.lua.txt
ALL_PSHY_NAMES			= $(NAME_PSHYVS) $(NAME_PSHYVS_COMMENTATOR) $(NAME_PSHYFUN) $(NAME_MARIO) $(NAME_PACMICE) $(NAME_BONUSES) $(NAME_CHICKENGAME) $(NAME_123SOLEIL) $(NAME_ESSENTIALS_PLUS) $(NAME_FASTTIME) $(NAME_THEBESTSHAMAN) $(NAME_TFMEMULATOR)
NAME_VS_TEAMS			= examples/modulepack_vsteams.tfm.lua.txt
NAME_VS_TEAMS_ANTIMACRO	= examples/modulepack_vsteamsantimacro.tfm.lua.txt
ALL_NAMES				= $(ALL_PSHY_NAMES) $(NAME_VS_TEAMS) $(NAME_VS_TEAMS_ANTIMACRO) 

# Rules:
all: $(ALL_PSHY_NAMES)

allall: $(ALL_NAMES)

examples/%tfm.lua.txt:
	@printf "\e[92m Generating %s\n" $@ || true
	@printf "\e[94m" || true
	./combine.py pshy_merge.lua -- pshy_essentials.lua -- $(patsubst examples/%.tfm.lua.txt, %.lua, $@) >> $@
	@printf "\e[0m" || true

.PHONY: clean
clean:

.PHONY: fclean
fclean: clean
	@printf "\e[91m" || true
	rm -rf examples/*.tfm.lua
	rm -rf examples/*.tfm.lua.txt
	@printf "\e[0m" || true

.PHONY: re
re: fclean all
