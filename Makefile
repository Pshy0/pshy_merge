# Modulepacks names:
NAME_PSHYVS			= modulepacks/pshyvs.modulepack.lua
NAME_PSHYFUN			= modulepacks/pshyfun.modulepack.lua
NAME_VS_TEAMS			= modulepacks/vsteams.modulepack.lua
NAME_VS_TEAMS_ANTIMACRO	= modulepacks/vsteamsantimacro.modulepack.lua
ALL_PSHY_NAMES			= $(NAME_PSHYVS) $(NAME_PSHYFUN)
ALL_NAMES			= $(ALL_PSHY_NAMES) $(NAME_VS_TEAMS) $(NAME_VS_TEAMS_ANTIMACRO) 

# Rules:
all: $(ALL_PSHY_NAMES)

allall: $(ALL_NAMES)

modulepacks/%.lua:
	@printf "\e[92m Generating %s\n" $@ || true
	@printf "\e[94m" || true
	./compile.py $(patsubst modulepacks/%.modulepack.lua, modulepack_%.lua, $@) >> $@
	@printf "\e[0m" || true

.PHONY: clean
clean:

.PHONY: fclean
fclean: clean
	@printf "\e[91m" || true
	rm -rf modulepacks/*modulepack.lua
	@printf "\e[0m" || true

.PHONY: re
re: fclean all
