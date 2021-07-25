# Modulepacks names:
NAME_PSHYVS			= modulepacks/pshyvs.combined.lua
NAME_PSHYFUN			= modulepacks/pshyfun.combined.lua
NAME_MARIO			= modulepacks/mario.combined.lua
NAME_VS_TEAMS			= modulepacks/vsteams.combined.lua
NAME_VS_TEAMS_ANTIMACRO		= modulepacks/vsteamsantimacro.combined.lua
ALL_PSHY_NAMES			= $(NAME_PSHYVS) $(NAME_PSHYFUN) $(NAME_MARIO)
ALL_NAMES			= $(ALL_PSHY_NAMES) $(NAME_VS_TEAMS) $(NAME_VS_TEAMS_ANTIMACRO) 

# Rules:
all: $(ALL_PSHY_NAMES)

allall: $(ALL_NAMES)

modulepacks/%.lua:
	@printf "\e[92m Generating %s\n" $@ || true
	@printf "\e[94m" || true
	./combine.py $(patsubst modulepacks/%.modulepack.lua, modulepack_%.lua, $@) >> $@
	@printf "\e[0m" || true

.PHONY: clean
clean:

.PHONY: fclean
fclean: clean
	@printf "\e[91m" || true
	rm -rf combined/*.combined.lua
	@printf "\e[0m" || true

.PHONY: re
re: fclean all
