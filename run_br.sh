#!/bin/bash

########### Inputs #########################################
BRZ=$1
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

mg5_mode=0 # 0:don't generate events, 1:generate events
runext=10k
nevents=10000

results_dir=results_local_brz3

MBmin=600
MBmax=$MBmin
dMB=20

BRzll=0.06729
BRzvv=0.2
BRwlv=0.216
################## Main Program ##################################
rm -rf s.dat
touch s.dat

i=1
MB=$MBmin
while [ $MB -le $MBmax ];do
    run_name=m_${MB}_${BRZ}_${runext}

    BRW=`echo "scale=5; 1 -$BRZ" | bc | sed 's/^\./0./'`

    if [ $mg5_mode -eq 1 ];then
        # Hathor NNLO cross section calculation
	sed -e "s/double mt = .*/double mt = $MB;/" myprogram.cxx > myprogram.tmp
	mv myprogram.tmp myprogram.cxx
	make myprogram
	./myprogram | tee hathor.log    
	
	# Event generation and analysis with MG5-Pythia-delphes-CheckMate
	./get_brevents.sh $run_name $analysis $exp $MB $mg5dir_zz $nevents zz $results_dir
	./get_brevents.sh $run_name $analysis $exp $MB $mg5dir_zw $nevents zw $results_dir
	./get_brevents.sh $run_name $analysis $exp $MB $mg5dir_ww $nevents ww $results_dir
    fi

    # Obtain event numbers passing analysis cuts for each B' decay mode
    ss_zz2=(`cat $results_dir/${analysis}_${MB}/s_zz.dat`)
    ss_zw2=(`cat $results_dir/${analysis}_${MB}/s_zw.dat`)
    ss_ww2=(`cat $results_dir/${analysis}_${MB}/s_ww.dat`)

    ss_zz=${ss_zz2[0]}
    dss_zz=${ss_zz2[1]}
    ss_zw=${ss_zw2[0]}
    dss_zw=${ss_zw2[1]}
    ss_ww=${ss_ww2[0]}
    dss_ww=${ss_ww2[1]}
    s95=${ss_zz2[2]}

    # Combine results for overall event numbers passing the analysis cuts
    ss=`echo "scale=5; $ss_zz*$BRZ^2*$BRzll*$BRzvv +$ss_zw*$BRZ*$BRW*$BRzll*$BRwlv +$ss_ww*$BRW^2*$BRwlv^2" | bc | sed 's/^\./0./'`
    dss=`echo "scale=5; sqrt($dss_zz^2*$BRZ^4*$BRzll^2*$BRzvv^2 +$dss_zw^2*$BRZ^2*$BRW^2*$BRzll^2*$BRwlv^2 +$dss_ww^2*$BRW^4*$BRwlv^4)" | bc | sed 's/^\./0./'`
    echo $MB $ss >> s.dat
    echo $MB $ss $dss $s95

    MB=`expr $MB + $dMB`
    i=`expr $i + 1`
done