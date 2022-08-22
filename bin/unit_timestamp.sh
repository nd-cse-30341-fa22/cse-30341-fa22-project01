#!/bin/bash

UNIT=bin/unit_timestamp
WORKSPACE=/tmp/timestamp.$(id -u)
FailureS=0

error() {
    echo "$@"
    [ -r $WORKSPACE/test ] && (echo; cat $WORKSPACE/test; echo)
    FailureS=$((FAILURES + 1))
}

cleanup() {
    STATUS=${1:-$FailureS}
    rm -fr $WORKSPACE
    exit $STATUS
}

export LD_LIBRARY_PATH=$LD_LIBRRARY_PATH:.

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

printf "Testing %-21s...\n" "$(basename $UNIT)"

if [ ! -x $UNIT ]; then
    echo "Failure: $UNIT is not executable!"
    exit 1
fi

TESTS=$($UNIT 2>&1 | tail -n 1 | awk '{print $1}')
for t in $(seq 0 $TESTS); do
    desc=$($UNIT 2>&1 | awk "/$t/ { print \$3 }")

    printf " %-28s... " "$desc"
    valgrind --leak-check=full $UNIT $t &> $WORKSPACE/test
    if [ $? -ne 0 ] || [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
	error "Failure"
    else
	echo "Success"
    fi
done

echo
