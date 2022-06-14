# Author: TFM:Pshy#3752 DC:Pshy#7998
OUT_DIR					= tfm.lua
TEST_RESULTS_DIR		= test_results
DEPS_DIR				= deps

# Modulepacks names:
NAME_PSHYVS				= $(OUT_DIR)/pshy_vs.tfm.lua.txt
NAME_PSHYVS_COMMENTATOR	= $(OUT_DIR)/pshy_vs_with_commentator.tfm.lua.txt
NAME_PSHYFUN			= $(OUT_DIR)/pshy_fun.tfm.lua.txt
NAME_MARIO				= $(OUT_DIR)/pshy_mario.tfm.lua.txt
NAME_PACMICE			= $(OUT_DIR)/pshy_pacmice.tfm.lua.txt
NAME_BONUSES			= $(OUT_DIR)/pshy_mapdb_bonuses.tfm.lua.txt
NAME_CHICKENGAME		= $(OUT_DIR)/pshy_mapdb_chickengame.tfm.lua.txt
NAME_123SOLEIL			= $(OUT_DIR)/pshy_123soleil.tfm.lua.txt
NAME_ESSENTIALS_PLUS	= $(OUT_DIR)/pshy_essentials_plus.tfm.lua.txt
NAME_FASTTIME			= $(OUT_DIR)/pshy_fasttime.tfm.lua.txt
NAME_THEBESTSHAMAN		= $(OUT_DIR)/pshy_thebestshaman.tfm.lua.txt
NAME_TFMEMULATOR		= $(OUT_DIR)/pshy_tfm_emulator.tfm.lua.txt
NAME_EMOTICONS			= $(OUT_DIR)/pshy_emoticons.tfm.lua.txt
NAME_ANVILCLICK			= $(OUT_DIR)/pshy_anvilclick.tfm.lua.txt
ALL_NAMES				= $(NAME_PSHYVS) $(NAME_PSHYVS_COMMENTATOR) $(NAME_PSHYFUN) $(NAME_MARIO) $(NAME_PACMICE) $(NAME_BONUSES) $(NAME_CHICKENGAME) $(NAME_123SOLEIL) $(NAME_ESSENTIALS_PLUS) $(NAME_FASTTIME) $(NAME_THEBESTSHAMAN) $(NAME_TFMEMULATOR) $(NAME_EMOTICONS) $(NAME_ANVILCLICK)
ALL_TESTS				= $(patsubst $(OUT_DIR)/%.tfm.lua.txt, $(TEST_RESULTS_DIR)/%.stdout.txt, $(ALL_NAMES))

# Rules:
all: $(ALL_NAMES)

test: $(ALL_TESTS)

%/:
	mkdir -p $@

include $(DEPS_DIR)/*.tfm.lua.txt.d

$(OUT_DIR)/%.tfm.lua.txt: | $(OUT_DIR)/ $(DEPS_DIR)/
	@printf "\e[92m Generating %s\n" $@ || true
	@printf "\e[94m" || true
	./combine.py --deps $(patsubst $(OUT_DIR)/%.tfm.lua.txt, $(DEPS_DIR)/%.tfm.lua.txt.d, $@) --out $@ -- $(patsubst $(OUT_DIR)/%.tfm.lua.txt, %.lua, $@)
	@printf "\e[0m" || true

$(TEST_RESULTS_DIR)/%.stdout.txt: $(OUT_DIR)/%.tfm.lua.txt $(NAME_TFMEMULATOR) | $(TEST_RESULTS_DIR)/
	@printf "\e[93m \nTesting %s:\n" $< || true
	@printf "\e[95m" || true
	(cat $(NAME_TFMEMULATOR) ; echo "\npshy.tfm_emulator_init_BasicTest()\n" ; cat $< ; echo "") > $@.test.lua
	@echo '(cat $@.test.lua ; echo "\npshy.tfm_emulator_BasicTest()") | lua > $@'
	@echo -n "\e[91m" 1>&2
	@(cat $@.test.lua ; echo "\npshy.tfm_emulator_BasicTest()") | lua > $@
	@printf "\e[95mSTDOUT: \e[96m" || true
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
