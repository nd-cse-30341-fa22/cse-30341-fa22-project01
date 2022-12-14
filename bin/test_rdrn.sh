#!/bin/sh

LOGFILE=tests/test_rdrn.log

# Functions

pqsh_test_commands() {
    cat <<EOF
add bin/worksim 2
add bin/worksim 2
add bin/worksim 2
add bin/worksim 2
EOF
    sleep 10
    echo "status"
}

pqsh_check_output() {
    python3 <<EOF
import re
import sys

lines = open("$LOGFILE").readlines()
try:
    running, waiting, finished, turnaround, response = \
	[float(line.split('=')[-1]) for line in lines[-10].split(',')]
except ValueError:
    sys.exit(1)

if running != 0 or waiting != 0 or finished != 4:
    sys.exit(2)

if not (8.25 <= turnaround <= 9.25):
    sys.exit(3)

if not (0.00 <= response <= 1.00):
    sys.exit(4)
EOF
}

# Main Execution

printf "Testing %-21s...\n" "$(basename $LOGFILE .log)"

if [ ! -x bin/pqsh ]; then
    echo "ERROR: Please build bin/pqsh"
    exit 1
fi

echo -n "  Running PQSH commands      ... "
if pqsh_test_commands | valgrind --leak-check=full bin/pqsh -p rdrn > $LOGFILE 2> $LOGFILE.valgrind; then
    echo "Success"
else
    echo "Failure"
    exit 2
fi

echo -n "  Verifying PQSH output      ... "
if pqsh_check_output; then
    echo "Success"
else
    echo "Failure"
    exit 3
fi

echo -n "  Verifying PQSH memory      ... "
if [ $(awk '/ERROR SUMMARY:/ {print $4}' $LOGFILE.valgrind) -eq 0 ]; then
    echo "Success"
else
    echo "Failure"
    exit 4
fi

echo
