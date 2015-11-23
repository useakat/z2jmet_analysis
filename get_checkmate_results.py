import sys,os

exp = sys.argv[1]

# extract signal event number
#ld = open("/Users/yoshi/packages/checkmate_v1.2.1/results/output/evaluation/best_signal_regions.txt")
ld = open("/home/yoshitar/packages/CheckMATE-1.2.2/results/output/evaluation/best_signal_regions.txt")
lines = ld.readlines()
ld.close()
for line in lines:
    if line.find(exp) >= 0: 
        ss = line[:-1].split()[4]
        se = line[:-1].split()[7]
        s95 = line[:-1].split()[8]
        print ss, se, s95
        
f = open('s.tmp', 'w')
f.write(ss + " " + se + " " + s95)
f.close()
