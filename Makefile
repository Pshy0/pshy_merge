# Author: TFM:Pshy#3752 DC:Pshy#7998
OUT_DIR					= examples
TEST_RESULTS_DIR		= test_results

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
ALL_NAMES				= $(NAME_PSHYVS) $(NAME_PSHYVS_COMMENTATOR) $(NAME_PSHYFUN) $(NAME_MARIO) $(NAME_PACMICE) $(NAME_BONUSES) $(NAME_CHICKENGAME) $(NAME_123SOLEIL) $(NAME_ESSENTIALS_PLUS) $(NAME_FASTTIME) $(NAME_THEBESTSHAMAN) $(NAME_TFMEMULATOR)
ALL_TESTS				= $(patsubst $(OUT_DIR)/%.tfm.lua.txt, $(TEST_RESULTS_DIR)/%.stdout.txt, $(ALL_NAMES))

# Rules:
all: $(ALL_NAMES)

test: $(ALL_TESTS)

$(OUT_DIR)/%tfm.lua.txt: 
	@printf "\e[92m Generating %s\n" $@ || true
	@printf "\e[94m" || true
	./combine.py $(patsubst $(OUT_DIR)/%.tfm.lua.txt, %.lua, $@) >> $@
	@printf "\e[0m" || true

$(TEST_RESULTS_DIR)/%stdout.txt: $(OUT_DIR)/%tfm.lua.txt $(NAME_TFMEMULATOR)
	@printf "\e[93m \nTesting %s:\n" $< || true
	@printf "\e[95m" || true
	mkdir -p $(TEST_RESULTS_DIR)
	(cat $(NAME_TFMEMULATOR) ; cat $< ; echo "") > $@.test.lua
	(cat $@.test.lua ; echo "\npshy.tfm_emulator_BasicTest()") | lua > $@
	@printf "STDOUT: \e[96m" || true
	@cat $@
	@printf "\e[0m" || true

.PHONY: clean
clean:

.PHONY: fclean
fclean: clean
	@printf "\e[91m" || true
	rm -rf $(OUT_DIR)/*.tfm.lua
	rm -rf $(OUT_DIR)/*.tfm.lua.txt
	rm -rf $(TEST_RESULTS_DIR)/*.stdout.txt
	@printf "\e[0m" || true

.PHONY: re
re: fclean all
