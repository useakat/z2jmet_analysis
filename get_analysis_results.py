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

S_zz = []
dS_zz = []
S_zw = []
dS_zw = []
S_ww = []
dS_ww = []
SR = []
S95obs = []
S95exp = []

file_zz = results_dir + "/" + analysis + "_" + mass + "/zz/evaluation/" + analysis + "_r_limits.txt"
file_zw = results_dir + "/" + analysis + "_" + mass + "/zw/evaluation/" + analysis + "_r_limits.txt"
file_ww = results_dir + "/" + analysis + "_" + mass + "/ww/evaluation/" + analysis + "_r_limits.txt"

ld = open(file_zz)
lines = ld.readlines()
ld.close
ncol = 0
for line in lines:
    if line != '\n' and line.find("dS_stat") < 0:
        data = line[:-1].split()
        SR.append(data[0])
        S_zz.append(data[1])
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
        dS_zw.append(data[4])

ld = open(file_ww)
lines = ld.readlines()
ld.close
for line in lines:
    if line != '\n' and line.find("dS_stat") < 0:
        data = line[:-1].split()
        S_ww.append(data[1])
        dS_ww.append(data[4])

rmax = -1
for i in xrange(ncol):
    ss = zzfact * float(S_zz[i]) * BRZ**2 * BRzll * BRzvv \
        +zwfact * float(S_zw[i]) * BRZ * BRW * BRzll * BRwlv \
        +wwfact * float(S_ww[i]) * BRW**2 * BRwlv**2

    dss = math.sqrt(zzfact**2 * float(dS_zz[i])**2 * BRZ**4 * BRzll**2 * BRzvv**2 \
              +zwfact**2 * float(dS_zw[i])**2 * BRZ**2 * BRW**2 * BRzll**2 * BRwlv**2 \
              +wwfact**2 * float(dS_ww[i])**2 * BRW**4 * BRwlv**4)

    r = (ss -2*dss)/float(S95exp[i])
    if r > rmax:
        sr_max = SR[i]
        s_max = ss
        ds_max = dss
        s95obs_max = S95obs[i]

print sr_max, s_max, ds_max, s95obs_max


