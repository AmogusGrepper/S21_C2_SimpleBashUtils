CC=gcc
CFLAGS=-Wall -Werror -Wextra -O2 -g --std=gnu11

COMMON_SOURCE=src/common/file_reader.c src/common/utils.c
COMMON_OBJECTIVE=$(COMMON_SOURCE:.c=.o)

CAT_SOURCE=src/cat/main.c src/cat/parse.c src/cat/process.c
CAT_OBJECTIVE=$(CAT_SOURCE:.c=.o)
CAT_EXECUTABLE=s21_cat

GREP_SOURCE=src/grep/main.c src/grep/parse.c src/grep/process.c src/grep/regex.c src/grep/output.c
GREP_OBJECTIVE=$(GREP_SOURCE:.c=.o)
GREP_EXECUTABLE=s21_grep

ALL_SOURCE=$(CAT_SOURCE) $(GREP_SOURCE) $(COMMON_SOURCE)

# tools variables
FORMATER=clang-format

LEAK_CHECKER=valgrind
LEAK_CHECKER_FLAGS=--leak-check=full --show-leak-kinds=all --track-origins=yes --verbose

all: $(CAT_EXECUTABLE) $(GREP_EXECUTABLE)

# ==== DEFAULT ====
%.o: %.c
	$(CC) $(CFLAGS) -c $^ -o $@

# ==== CAT ====
$(CAT_EXECUTABLE): $(COMMON_OBJECTIVE) $(CAT_OBJECTIVE)
	$(CC) $(CFLAGS) $(COMMON_OBJECTIVE) $(CAT_OBJECTIVE) -o $@

# ==== GREP ====
$(GREP_EXECUTABLE): $(COMMON_OBJECTIVE) $(GREP_OBJECTIVE)
	$(CC) $(CFLAGS) $(COMMON_OBJECTIVE) $(GREP_OBJECTIVE) -o $@

# ==== CLEAN ====
clean_cat:
	rm -rf $(CAT_EXECUTABLE) $(CAT_OBJECTIVE)

clean_grep:
	rm -rf $(GREP_EXECUTABLE) $(GREP_OBJECTIVE)

clean_all: clean_cat clean_grep
	rm -rf $(COMMON_OBJECTIVE)

# rebuild
rebuild: clean_all all

# tools
style:
	$(FORMATER) -n ./src/cat/*.c ./src/cat/*.h ./src/grep/*.c ./src/grep/*.h 

format:
	$(FORMATER) -i ./src/cat/*.c ./src/cat/*.h ./src/grep/*.c ./src/grep/*.h 

leak_check_cat: $(CAT_EXECUTABLE)
	$(LEAK_CHECKER) $(LEAK_CHECKER_FLAGS) ./$(CAT_EXECUTABLE) -e "a" data-samples/*.txt || true

leak_check_grep: $(GREP_EXECUTABLE)
	$(LEAK_CHECKER) $(LEAK_CHECKER_FLAGS) ./$(GREP_EXECUTABLE) -e "a" data-samples/*.txt || true

mini_verter: 
	./mini_verter.sh

test_all: format style rebuild leak_check_cat leak_check_grep mini_verter
	./test_cat_comprehensive.sh
	./test_grep_comprehensive.sh
