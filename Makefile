# Configuration

CC		= gcc
LD		= gcc
AR		= ar
CFLAGS		= -g -std=gnu99 -Wall -Iinclude -fPIC #-DDEBUG=1
LDFLAGS		= -Llib
ARFLAGS		= rcs

# Variables

LIBRARY_HEADERS = $(wildcard include/pq/*.h)
LIBRARY_SOURCES = src/options.c src/process.c src/queue.c src/signal.c \
		  src/scheduler.c src/scheduler_fifo.c src/scheduler_rdrn.c \
		  src/timestamp.c
LIBRARY_OBJECTS	= $(LIBRARY_SOURCES:.c=.o)
STATIC_LIBRARY  = lib/libpqsh.a
PQSH_PROGRAM	= bin/pqsh

TEST_SOURCES    = $(wildcard tests/test_*.c)
TEST_OBJECTS	= $(TEST_SOURCES:.c=.o)
TEST_PROGRAMS   = $(subst tests,bin,$(basename $(TEST_OBJECTS)))
TEST_SCRIPTS	= $(subst bin/,,$(basename $(shell ls bin/test_*.sh)))

UNIT_SOURCES    = $(wildcard tests/unit_*.c)
UNIT_OBJECTS	= $(UNIT_SOURCES:.c=.o)
UNIT_PROGRAMS   = $(subst tests,bin,$(basename $(UNIT_OBJECTS)))
UNIT_SCRIPTS	= $(subst bin/,,$(basename $(shell ls bin/unit_*.sh)))

# Rules

all:	$(PQSH_PROGRAM)

%.o:	%.c $(LIBRARY_HEADERS)
	@echo "Compiling $@"
	@$(CC) $(CFLAGS) -c -o $@ $<

bin/%:	tests/%.o $(STATIC_LIBRARY)
	@echo "Linking $@"
	@$(LD) $(LDFLAGS) -o $@ $^

$(PQSH_PROGRAM):	src/pqsh.o $(STATIC_LIBRARY)
	@echo "Linking $@"
	@$(LD) $(LDFLAGS) -o $@ $^

$(STATIC_LIBRARY):	$(LIBRARY_OBJECTS)
	@echo "Linking $@"
	@$(AR) $(ARFLAGS) $@ $^

test:		$(PQSH_PROGRAM)
	@$(MAKE) -sk test-all

test-all:	test-units test-scripts

test-units:	$(UNIT_PROGRAMS) $(UNIT_SCRIPTS)

unit_%:		bin/unit_%.sh
	@./bin/$@.sh

test-scripts:	$(TEST_PROGRAMS) $(TEST_SCRIPTS)

test_%:		bin/test_%.sh
	@./bin/$@.sh

clean:
	@echo "Removing objects"
	@rm -f $(LIBRARY_OBJECTS) $(TEST_OBJECTS) $(UNIT_OBJECTS) src/*.o

	@echo "Removing static library"
	@rm -f $(STATIC_LIBRARY)

	@echo "Removing tests"
	@rm -f $(TEST_PROGRAMS) $(UNIT_PROGRAMS)

	@echo "Removing pqsh"
	@rm -f $(PQSH_PROGRAM)
	
	@echo "Removing logs"
	@rm -f tests/*.log tests/*.log.valgrind

.PRECIOUS: %.o
