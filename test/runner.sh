#!/bin/bash

if [ $# == 0 ]; then
  LUAJIT=luajit
else
  # For this particular usecase: ./runner.sh qemu -L sysroot luajit
  LUAJIT="$@"
fi

LOGFILE="`pwd`/log.txt"
echo "" > $LOGFILE

RED='\033[0;31m'
GRE='\033[0;32m'
NOC='\033[0m'

$LUAJIT -e '' &>> $LOGFILE
if [ $? -ne 0 ]; then
  echo -e "${RED}Unable to execute LuaJIT (see log.txt for more info).${NOC}"
  exit 1
fi

declare -i passed=0
declare -i failed=0

export LUA_CPATH="../clib/?"

execute_tests() {
  cd $1
  for file in *.lua; do
    if { $LUAJIT $file; } &>> $LOGFILE; then
      # echo "$1/$file passed."
      passed+=1
    else
      echo -e "^^^^^^^^^^^^^^^^^^^ $1/$file ^^^^^^^^^^^^^^^^^^^^^\n" >> $LOGFILE
      echo -e "$RED$1/$file failed.$NOC"
      failed+=1
    fi
  done
  cd ..
}

execute_tests misc
execute_tests ffi

echo "--------------------------------"
echo -e "$GRE$passed tests passed.$NOC"
echo -e "$RED$failed tests failed (see log.txt for more info).$NOC"
