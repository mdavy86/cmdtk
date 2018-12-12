#!/bin/bash

cd "$(git rev-parse --show-toplevel)"

cpanm --installdeps -n -q --with-feature=packaging .

SCRIPT=switcheroo

rm -f bin/$SCRIPT

pp -B -c -o bin/$SCRIPT scripts/$SCRIPT || echo "FAILED" >&2

if file -b bin/$SCRIPT | grep -iq '^elf' 2>/dev/null ; then
    echo "SUCCESS" >&2
fi
