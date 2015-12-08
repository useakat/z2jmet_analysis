import sys,os
from subprocess import check_call

run_name = sys.argv[1]
analysis = sys.argv[2]
mass = sys.argv[3]
mg5dir = sys.argv[4]
name = 'output'

############ unzip hep event file
event_file = mg5dir + '/Events/' + run_name + '/tag_1_pythia_events.hep'
if os.path.exists(event_file + ".gz"):
    check_call(["gunzip", event_file + ".gz"])
elif os.path.exists(event_file):
    pass
else:
    print "event file does not exist! quitting program..."
    sys.exit()

############ extract cross section information from MG5 output
# ld = open(mg5dir + "/Events/" + run_name + "/" + run_name + "_tag_1_banner.txt")
# lines = ld.readlines()
# ld.close()
# for line in lines:
#     if line.find("Integrated weight") >= 0:
#         xsec_tmp = line[:-1].split()
#         xsec = xsec_tmp[5]
#         xsec_err = '0'
#         xsec_unit = 'PB'

########## extract cross section information from Hathor output
ld = open("hathor.log")
lines = ld.readlines()
ld.close()
for line in lines:
    if line.find("(pdf)") >= 0:
        xsec_tmp = line[:-1].split()
        xsec = str(float(xsec_tmp[1]))
        xsec_err = str(float(xsec_tmp[3]))
        xsec_unit = 'PB'

########### prepare CheckMATE input
xs = xsec + '*' + xsec_unit
xse = xsec_err + '*' + xsec_unit
arguments = "--name " + name + " -a " + analysis + " -xs " + xs + " -xse " + xse + " -oe overwrite -q " + event_file
#arguments = "--name " + name + " -a " + analysis + " -xs " + xs + " -xse " + xse + " -oe add -q " + event_file
print arguments


