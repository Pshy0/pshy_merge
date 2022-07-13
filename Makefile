# Author: TFM:Pshy#3752 DC:Pshy#7998
OUT_DIR					= tfm_lua
TEST_RESULTS_DIR		= test_results
DEPS_DIR				= deps

# Modulepacks names:
NAME_PSHYVS				= $(OUT_DIR)/pshy.games.vs.tfm.lua.txt
NAME_PSHYVS_COMMENTATOR	= $(OUT_DIR)/pshy.games.vs_with_commentator.tfm.lua.txt
NAME_PSHYFUN			= $(OUT_DIR)/pshy.games.fun.tfm.lua.txt
NAME_PACMICE			= $(OUT_DIR)/pshy.games.pacmice.tfm.lua.txt
NAME_BONUSES			= $(OUT_DIR)/pshy.rotations.list.bonuses.tfm.lua.txt
NAME_CHICKENGAME		= $(OUT_DIR)/pshy.games.chickengame.tfm.lua.txt
NAME_123SOLEIL			= $(OUT_DIR)/pshy.games.123soleil.tfm.lua.txt
NAME_ESSENTIALS_PLUS	= $(OUT_DIR)/pshy.essentials_plus.tfm.lua.txt
NAME_FASTTIME			= $(OUT_DIR)/pshy.games.fasttime.tfm.lua.txt
NAME_THEBESTSHAMAN		= $(OUT_DIR)/pshy.games.thebestshaman.tfm.lua.txt
NAME_EMOTICONS			= $(OUT_DIR)/pshy.bases.emoticons.tfm.lua.txt
NAME_ANVILCLICK			= $(OUT_DIR)/pshy.games.anvilclick.tfm.lua.txt
NAME_POKEBALL			= $(OUT_DIR)/pshy.games.pokeball.tfm.lua.txt
ALL_NAMES				= $(NAME_PSHYVS) $(NAME_PSHYVS_COMMENTATOR) $(NAME_PSHYFUN) $(NAME_PACMICE) $(NAME_BONUSES) $(NAME_CHICKENGAME) $(NAME_123SOLEIL) $(NAME_ESSENTIALS_PLUS) $(NAME_FASTTIME) $(NAME_THEBESTSHAMAN) $(NAME_EMOTICONS) $(NAME_ANVILCLICK) $(NAME_POKEBALL)
ALL_TESTS				= $(patsubst $(OUT_DIR)/%.tfm.lua.txt, $(TEST_RESULTS_DIR)/%.stdout.txt, $(ALL_NAMES))

# Rules:
all: $(ALL_NAMES)

test: $(ALL_TESTS)

%/:
	mkdir -p $@

-include $(DEPS_DIR)/*.tfm.lua.txt.d

$(OUT_DIR)/%.tfm.lua.txt: | $(OUT_DIR)/ $(DEPS_DIR)/
	@printf "\e[92m Generating %s\n" $@ || true
	@printf "\e[94m" || true
	./combine.py --werror --testinit --deps $(patsubst $(OUT_DIR)/%.tfm.lua.txt, $(DEPS_DIR)/%.tfm.lua.txt.d, $@) --out $@ -- $(patsubst $(OUT_DIR)/%.tfm.lua.txt, %, $@)
	@printf "\e[0m" || true

$(TEST_RESULTS_DIR)/%.stdout.txt: $(OUT_DIR)/%.tfm.lua.txt $(NAME_TFMEMULATOR) | $(TEST_RESULTS_DIR)/
	@printf "\e[93m \nTesting %s:\n" $< || true
	@printf "\e[95m" || true
	#(cat $(NAME_TFMEMULATOR) ; echo "\ntfmenv.BasicTest()\n" ; cat $< ; echo "") > $@.test.lua
	(echo "\npackage.path = ';./lua/?.lua;./lua/?/init.lua'\npshy = {require = require}\ntfmenv = require(\"pshy.tfm_emulator\")\ntfmenv.InitBasicTest()\ntfmenv.LoadModule(\"$<\")\ntfmenv.BasicTest()\n") > $@.test.lua
	@echo 'cat $@.test.lua | lua > $@'
	@echo -n "\e[91m" 1>&2
	@cat $@.test.lua | lua > $@
	@printf "\e[95mSTDOUT: \e[96m\n" || true
	@cat $@
	@printf "\e[0m" || true

.PHONY: clean
clean:
	@printf "\e[91m" || true
	rm -rf $(DEPS_DIR)/*.tfm.lua.txt.d
	rmdir $(DEPS_DIR) || true
	rm -rf $(TEST_RESULTS_DIR)/*.stdout.txt
	rmdir $(TEST_RESULTS_DIR) || true
	@printf "\e[0m" || true

.PHONY: fclean
fclean: clean
	@printf "\e[91m" || true
	rm -rf $(OUT_DIR)/*.tfm.lua.txt
	rmdir $(OUT_DIR) || true
	@printf "\e[0m" || true

.PHONY: re
re: fclean all
