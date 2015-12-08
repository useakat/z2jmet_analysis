#!/bin/bash
selfdir=$(cd $(dirname $0);pwd)

mg5dir=$1
run_name=$2
nevents=$3
MB=$4

cd $mg5dir
sed -e "s/.* = nevents !/$nevents = nevents !/" ./Cards/run_card.def > ./Cards/run_card.dat
sed -e "s/.* # MBP/  6000007 $MB # MBP/" \
    -e "s/DECAY 6000007 .*/DECAY 6000007 Auto/" ./Cards/param_card.def > ./Cards/param_card.dat
if [ 1 -eq 1 ];then
    if [ -e Events/$run_name ];then
	rm -rf Events/$run_name
    fi
    ./bin/generate_events $run_name -f | tee mg5.log
fi
cd $selfdir