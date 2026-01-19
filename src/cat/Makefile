CC=gcc
CFLAGS=-Wall -Werror -Wextra -O2 -g --std=gnu11

COMMON_SOURCE=../common/file_reader.c ../common/utils.c
COMMON_OBJECTIVE=$(COMMON_SOURCE:.c=.o)

CAT_SOURCE=main.c parse.c process.c
CAT_OBJECTIVE=$(CAT_SOURCE:.c=.o)
CAT_EXECUTABLE=s21_cat

ALL_SOURCE=$(CAT_SOURCE) $(COMMON_SOURCE)

TEST_FILES=../../data-samples/*.txt

# tools variables
FORMATER=clang-format

LEAK_CHECKER=valgrind
LEAK_CHECKER_FLAGS=--leak-check=full --show-leak-kinds=all --track-origins=yes

all: $(CAT_EXECUTABLE) 

# ==== DEFAULT ====
%.o: %.c
	$(CC) $(CFLAGS) -c $^ -o $@

# ==== CAT ====
$(CAT_EXECUTABLE): $(COMMON_OBJECTIVE) $(CAT_OBJECTIVE)
	$(CC) $(CFLAGS) $(COMMON_OBJECTIVE) $(CAT_OBJECTIVE) -o $@

# ==== CLEAN ====
clean_cat:
	rm -rf $(CAT_EXECUTABLE) $(CAT_OBJECTIVE)

clean_all: clean_cat
	rm -rf $(COMMON_OBJECTIVE)

# rebuild
rebuild: clean_all all

# tools
style:
	$(FORMATER) -n ./*.c ./*.h

format:
	$(FORMATER) -i ./*.c ./*.h 

leak_check: $(CAT_EXECUTABLE)
	$(LEAK_CHECKER) $(LEAK_CHECKER_FLAGS) ./$(CAT_EXECUTABLE) $(TEST_FILES)

cppcheck: 
	cppcheck --enable=all --suppress=missingIncludeSystem .
