#!/bin/bash

########### Parameters #########################################
analysis=atlas_1503_03290 # signal ATLAS 2lepton jets MET
#analysis=cms_1502_06031 # 2lepton jets MET
#analysis=atlas_1405_7875 # ATLAS 2-6 jet +MET
#analysis=atlas_conf_2013_047 # 2-6 jets +MET
#analysis=atlas_conf_2013_089 # 2leptons +MET no sensitivity
#analysis=atlas_1403_4853 # 2lepton jets MET (Stop search) no sensitivity
#analysis=atlas_1407_0583 # no sensitivity
#analysis=atlas_conf_2013_049 # no sensitivity due to jet veto
exp=atlas # This is not used yet (under construction)
#exp=cms # This is not used yet (under construction)

mg5dir_zz=../MG5/pp_bpbp~_dzd~z_dlld~vv
mg5dir_zw=../MG5/pp_bpbp~_dzuw_dllulv
mg5dir_ww=../MG5/pp_bpbp~_uw-u~w+_ulvu~lv

runext=10k
mg5_mode=1 # 0:don't generate events, 1:generate events
nevents=10000

#results_dir=results_local
#results_dir=results_local_brz2
results_dir=results_local_brz3
#results_dir=results_local_brz_test

MBmin=400
MBmax=400
dMB=20

BRZ=0.6
BRzll=0.03365
BRzvv=0.06667
BRwlv=10.8
################## Main Program ##################################
rm -rf s.dat
touch s.dat

i=1
MB=$MBmin
while [ $MB -le $MBmax ];do
    run_name=m_${MB}_${BRZ}_${runext}

    BRW=`echo "scale=3; 1 -$BRZ" | bc | sed 's/^\./0./'`

    # Hathor NNLO cross section calculation
    sed -e "s/double mt = .*/double mt = $MB;/" myprogram.cxx > myprogram.tmp
    mv myprogram.tmp myprogram.cxx
    make myprogram
    ./myprogram | tee hathor.log    

    echo $run_name $analysis $exp $MB $mg5dir_zz $nevents zz $results_dir
    exit
    if [ $mg5_mode -eq 1 ];then
	./get_brevents.sh $run_name $analysis $exp $MB $mg5dir_zz $nevents zz $results_dir
	./get_brevents.sh $run_name $analysis $exp $MB $mg5dir_zw $nevents zw $results_dir
	./get_brevents.sh $run_name $analysis $exp $MB $mg5dir_ww $nevents ww $results_dir
    fi

    ss_zz=`cat $results_dir/${analysis}_${MB}/s_zz.dat`
    ss_zw=`cat $results_dir/${analysis}_${MB}/s_zw.dat`
    ss_ww=`cat $results_dir/${analysis}_${MB}/s_ww.dat`

    ss=`echo "scale=3; $ss_zz*$BRZ^2*$BRzll*$BRzvv +$ss_zw*$BRZ/0.5*$BRW/0.5*$BRzll*$BRwlv +$ss_ww*$BRW^2*$BRwlv^2" | bc | sed 's/^\./0./'`
    echo $MB $ss >> s.dat

    MB=`expr $MB + $dMB`
    i=`expr $i + 1`
done