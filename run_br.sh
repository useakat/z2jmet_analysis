#!/bin/bash

########### Inputs #########################################
run_mode=$1 # 0: don't generate/analyze events
            # 1: don't generate but analyze events
            # 2: generate and analyze events
MBmin=$2
BRZ=$3
########### Parameters #########################################
#analysis=atlas_1503_03290 # signal ATLAS 2lepton jets MET
analysis=cms_1502_06031 # 2lepton jets MET
#analysis=atlas_1405_7875 # ATLAS 2-6 jet +MET
#analysis=atlas_conf_2013_047 # 2-6 jets +MET
#analysis=atlas_conf_2013_089 # 2leptons +MET no sensitivity
#analysis=atlas_1403_4853 # 2lepton jets MET (Stop search) no sensitivity
#analysis=atlas_1407_0583 # no sensitivity
#analysis=atlas_conf_2013_049 # no sensitivity due to jet veto

#exp=atlas # This is not used yet 
exp=cms # This is not used yet 

runext=100k
#analysisext=brz
#analysisext=brz_2
#analysisext=signal
#analysisext=brz_all
#analysisext=brz_all_2
#analysisext=test
analysisext=zwfulldecay
#analysisext=include-tau
#analysisext=all
nevents=100000

results_dir=results_local_$analysisext
#results_dir=results_local_brz4

MBmax=$MBmin
dMB=20

if [ $analysis == "atlas_1503_03290" -o $analysis == "cms_1502_06031" ];then
    # mg5dir_zz=../MG5/pp_bpbp~_dzd~z_dleplepd~vv
    # mg5dir_zw=../MG5/pp_bpbp~_dzuw_dleplepulepv
    # mg5dir_ww=../MG5/pp_bpbp~_uw-u~w+_ulepvu~lepv
    # BRzll=0.10096
    # BRzvv=0.2
    # BRwlv=0.3257
    # zzfact=2
    # zwfact=2
    # wwfact=1
    mg5dir_zz=../MG5/pp_bpbp~_dzd~z
    mg5dir_zw=../MG5/pp_bpbp~_dzuw
    mg5dir_ww=../MG5/pp_bpbp~_uw-u~w+
    # mg5dir_zz=../MG5/pp_bpbp~_dzd~z_all
    # mg5dir_zw=../MG5/pp_bpbp~_dzuw_all
    # mg5dir_ww=../MG5/pp_bpbp~_uwuw_all
    BRzll=1
    BRzvv=1
    BRwlv=1
    zzfact=1
    zwfact=2
    wwfact=1
elif [ $analysis == "atlas_1405_7875" ];then
    mg5dir_zz=../MG5/pp_bpbp~_dzd~z
    mg5dir_zw=../MG5/pp_bpbp~_dzuw
    mg5dir_ww=../MG5/pp_bpbp~_uw-u~w+
    BRzll=1
    BRzvv=1
    BRwlv=1
    zzfact=1
    zwfact=2
    wwfact=1
fi
################## Main Program ##################################
start=`date`
echo $start

echo ""
rm -rf s.dat
touch s.dat

if [ ! -d $results_dir ];then
    mkdir $results_dir
fi
anaext=${runext}_${analysisext}

i=1
MB=$MBmin
while [ $MB -le $MBmax ];do
    run_name=m_${MB}_${runext}
    BRW=`echo "scale=5; 1 -$BRZ" | bc | sed 's/^\./0./'`

    if [ $run_mode -eq 2 ];then
        # Event generation with MG5-Pythia
	echo "Generating and showering events with MG5-pythia..."
	echo
	./get_events.sh $mg5dir_zz $run_name $nevents $MB
	./get_events.sh $mg5dir_zw $run_name $nevents $MB
	./get_events.sh $mg5dir_ww $run_name $nevents $MB
    fi

    if [ $run_mode -ge 1 ];then    
        # Hathor NNLO cross section calculation
	echo "Calculating NNLO cross section with Hathor..."
	echo
	sed -e "s/double mt = .*/double mt = $MB;/" myprogram.cxx > myprogram.tmp
	mv myprogram.tmp myprogram.cxx
	make myprogram
	./myprogram | tee hathor.log    
	echo ""
	
        # Event analysis with Delphes-CheckMate
	echo "Performing detector simulation with Delphes and analysing events with Checkmate..."
	./get_brevents.sh $run_name $analysis $exp $MB $mg5dir_zz zz $results_dir $anaext
	./get_brevents.sh $run_name $analysis $exp $MB $mg5dir_zw zw $results_dir $anaext
	./get_brevents.sh $run_name $analysis $exp $MB $mg5dir_ww ww $results_dir $anaext
    fi
	
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

#    echo $MB $ss >> s.dat
    echo "mass", "S", "     dS_stat", "     dS_sys", " dS_tot", "     S95obs", "r_noerr", "    r_syserr", "    r_toterr"
    echo $MB $s $dsstat $dssys $ds $s95 $r $rsys $rtot
    echo ""

    MB=`expr $MB + $dMB`
    i=`expr $i + 1`
done
echo "Finished !"
echo $start
echo `date`
echo
