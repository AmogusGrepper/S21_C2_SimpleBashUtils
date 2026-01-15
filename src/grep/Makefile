CC=gcc
CFLAGS=-Wall -Werror -Wextra -O2 -g --std=gnu11

COMMON_SOURCE=../common/file_reader.c ../common/utils.c
COMMON_OBJECTIVE=$(COMMON_SOURCE:.c=.o)

GREP_SOURCE=main.c parse.c process.c regex.c output.c
GREP_OBJECTIVE=$(GREP_SOURCE:.c=.o)
GREP_EXECUTABLE=s21_grep

ALL_SOURCE=$(GREP_SOURCE) $(COMMON_SOURCE)

TEST_FILES=../../data-samples/*.txt

# tools variables
FORMATER=clang-format

LEAK_CHECKER=valgrind
LEAK_CHECKER_FLAGS=--leak-check=full --show-leak-kinds=all --track-origins=yes --verbose

all: $(GREP_EXECUTABLE)

# ==== DEFAULT ====
%.o: %.c
	$(CC) $(CFLAGS) -c $^ -o $@

# ==== GREP ====
$(GREP_EXECUTABLE): $(COMMON_OBJECTIVE) $(GREP_OBJECTIVE)
	$(CC) $(CFLAGS) $(COMMON_OBJECTIVE) $(GREP_OBJECTIVE) -o $@

# ==== CLEAN ====
clean_grep:
	rm -rf $(GREP_EXECUTABLE) $(GREP_OBJECTIVE)

clean_all: clean_grep
	rm -rf $(COMMON_OBJECTIVE)

# rebuild
rebuild: clean_all all

# tools
style:
	$(FORMATER) -n ./*.c ./*.h

format:
	$(FORMATER) -i ./*.c ./*.h 

leak_check: $(GREP_EXECUTABLE)
	$(LEAK_CHECKER) $(LEAK_CHECKER_FLAGS) ./$(GREP_EXECUTABLE) -e "a" $(TEST_FILES)
