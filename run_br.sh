#!/bin/bash

########### Inputs #########################################
<<<<<<< HEAD
run_mode=$1 # 0: don't generate/analyze events
            # 1: don't generate but analyze events
            # 2: generate and analyze events
MBmin=$2
BRZ=$3
=======
MBmin=$1
BRZ=$2
mg5_mode=$3 # 0:don't generate events, 1:generate events
checkmate_mode=$4 # 0:don't generate events, 1:generate events
>>>>>>> master
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

#mg5dir_zz=../MG5/pp_bpbp~_dzd~z_dlld~vv
#mg5dir_zw=../MG5/pp_bpbp~_dzuw_dllulv
#mg5dir_ww=../MG5/pp_bpbp~_uw-u~w+_ulvu~lv
#mg5dir_ww=../MG5/pp_bpbp~_uw-u~w+_all_2
#mg5dir_ww=../MG5/pp_bpbp~_uw-u~w+_all3
mg5dir_zz=../MG5/pp_bpbp~_dzd~z
mg5dir_zw=../MG5/pp_bpbp~_dzuw
mg5dir_ww=../MG5/pp_bpbp~_uw-u~w+
#mg5dir_ww=../MG5/pp_bpbp~_all

<<<<<<< HEAD
runext=100k
#analysisext=brz
#analysisext=brz_2
#analysisext=signal
#analysisext=brz_all
#analysisext=brz_all_2
analysisext=test
nevents=100000

results_dir=results_local_test
#results_dir=results_local_brz4
=======
runext=10k
nevents=10000

#results_dir=results_local_brz3
#results_dir=results_local_brz4
results_dir=results_local_test
>>>>>>> master

MBmax=$MBmin
dMB=20

<<<<<<< HEAD
if [ $analysis == "atlas_1503_03290" -o $analysis == "cms_1502_06031" ];then
    BRzll=0.06729
    BRzvv=0.2
    BRwlv=0.216
    zzfact=2
    zwfact=2
    wwfact=1
elif [ $analysis == "atlas_1405_7875" ];then
    BRzll=1
    BRzvv=1
    BRwlv=1
    zzfact=1
    zwfact=2
    wwfact=1
fi
=======
#BRzll=0.06729
#BRzvv=0.2
#BRwlv=0.216
BRzll=1  # for pp_bpbp~_dzd~z
BRzvv=1  # for pp_bpbp~_dzuw
BRwlv=1  # for pp_bpbp~_uw-u~w+
>>>>>>> master
################## Main Program ##################################
echo ""
rm -rf s.dat
touch s.dat
hathor_mode=$mg5_mode

anaext=${runext}_${analysisext}

i=1
MB=$MBmin
while [ $MB -le $MBmax ];do
    run_name=m_${MB}_${runext}
    BRW=`echo "scale=5; 1 -$BRZ" | bc | sed 's/^\./0./'`

<<<<<<< HEAD
    if [ $run_mode -eq 2 ];then
        # Event generation with MG5-Pythia
	echo "Generating and showering events with MG5-pythia..."
	echo
	./get_events.sh $mg5dir_zz $run_name $nevents $MB
	./get_events.sh $mg5dir_zw $run_name $nevents $MB
	./get_events.sh $mg5dir_ww $run_name $nevents $MB
    fi

    if [ $run_mode -ge 1 ];then    
=======
    if [ $hathor_mode -eq 1 ];then
>>>>>>> master
        # Hathor NNLO cross section calculation
	echo "Calculating NNLO cross section with Hathor..."
	echo
	sed -e "s/double mt = .*/double mt = $MB;/" myprogram.cxx > myprogram.tmp
	mv myprogram.tmp myprogram.cxx
	make myprogram
	./myprogram | tee hathor.log    
<<<<<<< HEAD
	echo ""
	
        # Event analysis with Delphes-CheckMate
	echo "Performing detector simulation with Delphes and analysing events with Checkmate..."
	./get_brevents.sh $run_name $analysis $exp $MB $mg5dir_zz zz $results_dir $anaext
	./get_brevents.sh $run_name $analysis $exp $MB $mg5dir_zw zw $results_dir $anaext
	./get_brevents.sh $run_name $analysis $exp $MB $mg5dir_ww ww $results_dir $anaext
=======
>>>>>>> master
    fi
	
    # Event generation and analysis with MG5-Pythia-delphes-CheckMate
    ./get_brevents.sh $run_name $analysis $exp $MB $mg5dir_zz $nevents zz $results_dir $mg5_mode $checkmate_mode
    ./get_brevents.sh $run_name $analysis $exp $MB $mg5dir_zw $nevents zw $results_dir $mg5_mode $checkmate_mode
    ./get_brevents.sh $run_name $analysis $exp $MB $mg5dir_ww $nevents ww $results_dir $mg5_mode $checkmate_mode

    echo "Obtaining final results..."
    echo    

    # Obtain event numbers passing analysis cuts for each B' decay mode
    results=(`./get_analysis_results.py $results_dir $analysis $MB $zzfact $zwfact $wwfact $BRZ $BRW $BRzll $BRzvv $BRwlv $anaext`)

    s=${results[1]}
    dsstat=${results[2]}
    dssys=${results[3]}
    ds=${results[4]}
    s95=${results[5]}
    r=${results[6]}
    rsys=${results[7]}
    rtot=${results[8]}

    echo $MB $ss >> s.dat
    echo "mass", "S", "     dS_stat", "     dS_sys", " dS_tot", "     S95obs", "r_noerr", "    r_syserr", "    r_toterr"
    echo $MB $s $dsstat $dssys $ds $s95 $r $rsys $rtot
    echo ""

    MB=`expr $MB + $dMB`
    i=`expr $i + 1`
done
echo "Finished !"
echo
