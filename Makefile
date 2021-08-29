# Author: TFM:Pshy#3752 DC:Pshy#7998

# Modulepacks names:
NAME_PSHYVS			= combined/pshyvs.combined.lua
NAME_PSHYFUN			= combined/pshyfun.combined.lua
NAME_MARIO			= combined/mario.combined.lua
NAME_PACMICE			= games/pacmice.combined.lua
ALL_PSHY_NAMES			= $(NAME_PSHYVS) $(NAME_PSHYFUN) $(NAME_MARIO) $(NAME_PACMICE)
NAME_VS_TEAMS			= combined/vsteams.combined.lua
NAME_VS_TEAMS_ANTIMACRO		= combined/vsteamsantimacro.combined.lua
ALL_NAMES			= $(ALL_PSHY_NAMES) $(NAME_VS_TEAMS) $(NAME_VS_TEAMS_ANTIMACRO) 

# Rules:
all: $(ALL_PSHY_NAMES)

allall: $(ALL_NAMES)

combined/%.lua:
	@printf "\e[92m Generating %s\n" $@ || true
	@printf "\e[94m" || true
	./combine.py pshy_merge.lua $(patsubst combined/%.combined.lua, modulepack_%.lua, $@) >> $@
	@printf "\e[0m" || true

games/%.lua:
	@printf "\e[92m Generating %s\n" $@ || true
	@printf "\e[94m" || true
	./combine.py pshy_merge.lua $(patsubst games/%.combined.lua, %.lua, $@) >> $@
	@printf "\e[0m" || true

.PHONY: clean
clean:

.PHONY: fclean
fclean: clean
	@printf "\e[91m" || true
	rm -rf combined/*.combined.lua
	rm -rf games/*.combined.lua
	@printf "\e[0m" || true

.PHONY: re
re: fclean all
