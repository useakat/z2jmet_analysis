#!/bin/bash
selfdir=$(cd $(dirname $0);pwd)

run_name=$1
analysis=$2
exp=$3
MB=$4
mg5dir=$5
mode=$6
results_dir=$7
anaext=$8

# Checkmate analysis
python run.py $run_name $analysis $MB $mg5dir | while read i; do python CheckMATE $i; done
python get_checkmate_results.py $exp
ss=`cat s.tmp`
echo $ss > s_$mode.dat
rm -rf s.tmp

# Store analysis results in results_local
analysis_dir=$results_dir/${analysis}_${anaext}_${MB}
if [ -e $analysis_dir ];then
    rm -rf $analysis_dir/$mode
else
    mkdir $analysis_dir
fi
mv $CHECKMATE/results/output $analysis_dir/$mode
rm -rf $analysis_dir/$mode/delphes
mv s_$mode.dat $analysis_dir/.