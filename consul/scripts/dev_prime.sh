#!/bin/bash
if [ $# -ne 2 ]
then
	echo "$0 < num of processes > < process count > "
	exit
fi

is_number(){
  VAR_NAME=$1
  if [ "$2" -eq  "$2" ] 2>/dev/null
  then
	  echo "" > /dev/null
  else
	  echo ${VAR_NAME}  is not a number
	  exit
  fi
}

run_one(){
	echo "start process $1"
	for i in `seq 1 $2`
	do
		d=`echo 100000/7919|bc`
	done
	echo "finish process $1"
}


is_number "num of processes" $1
is_number "process count" $2

for i in `seq 1 ${1}`
do
	run_one $i $2 &
done
wait
