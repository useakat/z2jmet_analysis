#!/bin/bash
selfdir=$(cd $(dirname $0);pwd)

run_name=$1
analysis=$2
exp=$3
MB=$4
mg5dir=$5
<<<<<<< HEAD
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
=======
nevents=$6
mode=$7
results_dir=$8
mg5_mode=$9
checkmate_mode=${10}

if [ $mg5_mode -eq 1 ];then
    cd $mg5dir
    sed	-e "s/.* = nevents !/$nevents = nevents !/" ./Cards/run_card.dat > ./Cards/run_card.tmp
    mv ./Cards/run_card.tmp ./Cards/run_card.dat
    sed -e "s/.* # MBP/  6000007 $MB # MBP/" \
	-e "s/DECAY 6000007 .*/DECAY 6000007 Auto/" ./Cards/param_card.dat > ./Cards/param_card.tmp
    mv ./Cards/param_card.tmp ./Cards/param_card.dat       
    if [ -e Events/$run_name ];then
	rm -rf Events/$run_name
    fi
    ./bin/generate_events $run_name -f | tee mg5.log
fi

if [ $checkmate_mode -eq 1 ];then
    cd $selfdir
    # Checkmate analysis
    python run.py $run_name $analysis $MB $mg5dir | while read i; do python CheckMATE $i; done
    python get_checkmate_results.py $exp
    ss=`cat s.tmp`
    echo $ss > s_$mode.dat
    rm -rf s.tmp

    # Store analysis results in results_local
    if [ ! -d $results_dir ];then
	mkdir $results_dir
    fi
    if [ -e $results_dir/${analysis}_${MB} ];then
	rm -rf $results_dir/${analysis}_$MB/$mode
    else
	mkdir $results_dir/${analysis}_${MB}
    fi
    mv $CHECKMATE/results/output $results_dir/${analysis}_${MB}/$mode
    rm -rf $results_dir/${analysis}_${MB}/$mode/delphes
    mv s_$mode.dat $results_dir/${analysis}_${MB}/.
fi
>>>>>>> master
