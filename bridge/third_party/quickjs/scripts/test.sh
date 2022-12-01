#!/bin/bash

set -x

cd ..

if [ ! -d test262 ]; then
    git clone https://github.com/tc39/test262.git test262
fi

cd test262
patch -y -p1 < ../tests/test262.patch
cd ..
touch test262_errors.txt
./bin/run-test262 -m -c test262.conf -a