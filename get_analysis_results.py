#! /usr/bin/env python
import sys,os
import math

results_dir = sys.argv[1]
analysis = sys.argv[2]
mass = sys.argv[3]
zzfact = float(sys.argv[4])
zwfact = float(sys.argv[5])
wwfact = float(sys.argv[6])
BRZ = float(sys.argv[7])
BRW = float(sys.argv[8])
BRzll = float(sys.argv[9])
BRzvv = float(sys.argv[10])
BRwlv = float(sys.argv[11])
runext = sys.argv[12]

S_zz = []
dS_zz = []
dSstat_zz = []
dSsys_zz = []
S_zw = []
dS_zw = []
dSstat_zw = []
dSsys_zw = []
S_ww = []
dS_ww = []
dSstat_ww = []
dSsys_ww = []
SR = []
S95obs = []
S95exp = []

file_zz = results_dir + "/" + analysis + "_" + runext + "_" + mass + "/zz/evaluation/" + analysis + "_r_limits.txt"
file_zw = results_dir + "/" + analysis + "_" + runext + "_" + mass + "/zw/evaluation/" + analysis + "_r_limits.txt"
file_ww = results_dir + "/" + analysis + "_" + runext + "_" + mass + "/ww/evaluation/" + analysis + "_r_limits.txt"

ld = open(file_zz)
lines = ld.readlines()
ld.close
ncol = 0
for line in lines:
    if line != '\n' and line.find("dS_stat") < 0:
        data = line[:-1].split()
        SR.append(data[0])
        S_zz.append(data[1])
        dSstat_zz.append(data[2])
        dSsys_zz.append(data[3])
        dS_zz.append(data[4])
        S95obs.append(data[5])
        S95exp.append(data[6])
        ncol = ncol +1

ld = open(file_zw)
lines = ld.readlines()
ld.close
for line in lines:
    if line != '\n' and line.find("dS_stat") < 0:
        data = line[:-1].split()
        S_zw.append(data[1])
        dSstat_zw.append(data[2])
        dSsys_zw.append(data[3])
        dS_zw.append(data[4])

ld = open(file_ww)
lines = ld.readlines()
ld.close
for line in lines:
    if line != '\n' and line.find("dS_stat") < 0:
        data = line[:-1].split()
        S_ww.append(data[1])
        dSstat_ww.append(data[2])
        dSsys_ww.append(data[3])
        dS_ww.append(data[4])

rmax = -1
for i in xrange(ncol):
#    print i
#    print dSstat_zz[i], dSsys_zz[i], dS_zz[i]
#    print dSstat_zw[i], dSsys_zw[i], dS_zw[i]
#    print dSstat_ww[i], dSsys_ww[i], dS_ww[i]

    ss = zzfact * float(S_zz[i]) * BRZ**2 * BRzll * BRzvv \
        +zwfact * float(S_zw[i]) * BRZ * BRW * BRzll * BRwlv \
        +wwfact * float(S_ww[i]) * BRW**2 * BRwlv**2

    dss_stat = math.sqrt(zzfact**2 * float(dSstat_zz[i])**2 * BRZ**4 * BRzll**2 * BRzvv**2 \
              +zwfact**2 * float(dSstat_zw[i])**2 * BRZ**2 * BRW**2 * BRzll**2 * BRwlv**2 \
              +wwfact**2 * float(dSstat_ww[i])**2 * BRW**4 * BRwlv**4)

    dss_sys = zzfact * float(dSsys_zz[i]) * BRZ**2 * BRzll * BRzvv \
        +zwfact * float(dSsys_zw[i]) * BRZ * BRW * BRzll * BRwlv \
        +wwfact * float(dSsys_ww[i]) * BRW**2 * BRwlv**2

    dss = math.sqrt(dss_stat**2 +dss_sys**2)

    dss2 = math.sqrt(zzfact**2 * float(dS_zz[i])**2 * BRZ**4 * BRzll**2 * BRzvv**2 \
              +zwfact**2 * float(dS_zw[i])**2 * BRZ**2 * BRW**2 * BRzll**2 * BRwlv**2 \
              +wwfact**2 * float(dS_ww[i])**2 * BRW**4 * BRwlv**4)

    r = (ss -2*dss)/float(S95exp[i])
    if r > rmax:
        sr_max = SR[i]
        s_max = ss
        dsstat_max = dss_stat
        dssys_max = dss_sys
        ds_max = dss
        ds_max2 = dss2
        s95obs_max = S95obs[i]

        r_max = (s_max -2*ds_max)/float(S95obs[i])

#print "SR", "S", "dS_stat", "dS_sys", "dS_tot", "S95obs", "r"
print sr_max, s_max, dsstat_max, dssys_max, ds_max, s95obs_max, r_max
#print ds_max, ds_max2

