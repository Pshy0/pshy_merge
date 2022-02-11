# Author: TFM:Pshy#3752 DC:Pshy#7998

# Modulepacks names:
NAME_PSHYVS				= examples/pshyvs.tfm.lua
NAME_PSHYVS_COMMENTATOR	= examples/pshyvs_with_commentator.tfm.lua
NAME_PSHYFUN			= examples/pshyfun.tfm.lua
NAME_MARIO				= examples/mario.tfm.lua
NAME_PACMICE			= examples/pacmice.tfm.lua
NAME_BONUSES			= examples/pshy_bonus_luamaps.tfm.lua
NAME_CHICKENGAME		= examples/pshy_mapdb_chickengame.tfm.lua
ALL_PSHY_NAMES			= $(NAME_PSHYVS) $(NAME_PSHYVS_COMMENTATOR) $(NAME_PSHYFUN) $(NAME_MARIO) $(NAME_PACMICE) $(NAME_BONUSES) $(NAME_CHICKENGAME)
NAME_VS_TEAMS			= examples/modulepack_vsteams.tfm.lua
NAME_VS_TEAMS_ANTIMACRO	= examples/modulepack_vsteamsantimacro.tfm.lua
ALL_NAMES				= $(ALL_PSHY_NAMES) $(NAME_VS_TEAMS) $(NAME_VS_TEAMS_ANTIMACRO) 

# Rules:
all: $(ALL_PSHY_NAMES)

allall: $(ALL_NAMES)

examples/%.lua:
	@printf "\e[92m Generating %s\n" $@ || true
	@printf "\e[94m" || true
	./combine.py pshy_merge.lua -- pshy_essentials.lua -- $(patsubst examples/%.tfm.lua, %.lua, $@) >> $@
	@printf "\e[0m" || true

.PHONY: clean
clean:

.PHONY: fclean
fclean: clean
	@printf "\e[91m" || true
	rm -rf examples/*.tfm.lua
	@printf "\e[0m" || true

.PHONY: re
re: fclean all
