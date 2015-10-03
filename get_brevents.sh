#!/bin/bash

run_name=$1
analysis=$2
exp=$3
MB=$4
mg5dir=$5
mode=$6
results_dir=$7

# Checkmate analysis
python run.py $run_name $analysis $MB $mg5dir | while read i; do python CheckMATE $i; done
python get_checkmate_results.py $exp
ss=`cat s.tmp`
echo $ss > s_$mode.dat
rm -rf s.tmp

# Store analysis results in results_local
if [ -e $results_dir/${analysis}_${MB} ];then
    rm -rf $results_dir/${analysis}_$MB/$mode
else
    mkdir $results_dir/${analysis}_${MB}
fi
mv $CHECKMATE/results/output $results_dir/${analysis}_${MB}/$mode
rm -rf $results_dir/${analysis}_${MB}/$mode/delphes
mv s_$mode.dat $results_dir/${analysis}_${MB}/.