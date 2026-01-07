CC=gcc
CFLAGS=-Wall -Werror -Wextra -O2 -g --std=gnu11

COMMON_SOURCE=../common/file_reader.c ../common/utils.c
COMMON_OBJECTIVE=$(COMMON_SOURCE:.c=.o)

CAT_SOURCE=main.c parse.c process.c
CAT_OBJECTIVE=$(CAT_SOURCE:.c=.o)
CAT_EXECUTABLE=s21_cat

GREP_SOURCE=main.c parse.c process.c regex.c output.c
GREP_OBJECTIVE=$(GREP_SOURCE:.c=.o)
GREP_EXECUTABLE=s21_grep

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

