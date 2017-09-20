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

while read -r line; do
  IFS=$' \t' read -ra arg <<< "$line"
  if [ "${arg[1]}" == "x" ]; then
    CMD="$LUAJIT ${arg[0]}.lua ${arg[3]} 2>>$LOGFILE"
  else
    CMD="$LUAJIT ${arg[0]}.lua ${arg[1]} 2>>$LOGFILE"
  fi
  if [ "$(eval $CMD | md5sum -)" == "${arg[2]}  -" ]; then
    echo "${arg[0]}.lua passed."
    passed+=1
  else
    # -e tells echo to evaluate new line, instead of just printing \n.
    echo -e "------------------- $1/$file ---------------------\n" >> $LOGFILE
    echo -e "$RED${arg[0]}.lua failed.$NOC"
    failed+=1
  fi
done < TEST_md5sum.txt

echo "--------------------------------"
echo -e "$GRE$passed tests passed.$NOC"
echo -e "$RED$failed tests failed (see log.txt for more info).$NOC"
