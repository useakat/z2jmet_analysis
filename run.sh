#!/bin/bash

rm -rf s.dat
touch s.dat
########### Parameters #########################################
#analysis=atlas_1503_03290 # signal ATLAS 2lepton jets MET
#analysis=cms_1502_06031 # 2lepton jets MET
analysis=atlas_1405_7875 # ATLAS 2-6 jet +MET
#analysis=atlas_conf_2013_047 # 2-6 jets +MET
#analysis=atlas_conf_2013_089 # 2leptons +MET no sensitivity
#analysis=atlas_1403_4853 # 2lepton jets MET (Stop search) no sensitivity
#analysis=atlas_1407_0583 # no sensitivity
#analysis=atlas_conf_2013_049 # no sensitivity due to jet veto
exp=atlas # This is not used yet (under construction)
#exp=cms # This is not used yet (under construction)

#mg5dir=../MG5/pp_bpbp~_dzld~zv # for atlas_1503_03290, cms_1502_0631, atlas_1403_4853
#mg5dir=../MG5/pp_bpbp~_dzd~z # for atlas_1503_03290, cms_1502_0631
mg5dir=../MG5/pp_bpbp~_uw-u~w+ # for atlas_1503_03290, cms_1502_0631

mg5_mode=1 # 0:don't generate events, 1:generate events
runext=10k
nevents=10000



MBmin=620
MBmax=760
dMB=20
################## Main Program ##################################
i=1
MB=$MBmin
while [ $MB -le $MBmax ];do
#    run_name=m_${MB}
    run_name=m_${MB}_$runext

    cd $mg5dir
    sed	-e "s/.* = nevents !/$nevents = nevents !/" ./Cards/run_card.dat > ./Cards/run_card.tmp
    mv ./Cards/run_card.tmp ./Cards/run_card.dat
    sed -e "s/.* # MBP/  6000007 $MB # MBP/" \
	-e "s/DECAY 6000007 .*/DECAY 6000007 Auto/" ./Cards/param_card.def > ./Cards/param_card.dat
    if [ $mg5_mode -eq 1 ];then
	if [ -e Events/$run_name ];then
	    rm -rf Events/$run_name
	fi
	./bin/generate_events $run_name -f | tee mg5.log
    fi

    cd ../../analysis
    sed -e "s/double mt = .*/double mt = $MB;/" myprogram.cxx > myprogram.tmp
    mv myprogram.tmp myprogram.cxx
    make myprogram
    ./myprogram | tee hathor.log    

    python run.py $run_name $analysis $MB $mg5dir | while read i; do python CheckMATE $i; done
    python get_checkmate_results.py $exp
    ss=`cat s.tmp`
    echo $MB $ss >> s.dat
    rm -rf s.tmp
    if [ -e results_local/${analysis}_$MB ];then
	rm -rf results_local/${analysis}_$MB
    fi
    mv $CHECKMATE/results/output results_local/${analysis}_$MB
    MB=`expr $MB + $dMB`
    i=`expr $i + 1`
done