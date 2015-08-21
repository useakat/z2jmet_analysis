ifeq ($(LHAPDF),)
   LHAPDF = $(HOME)/local/lhapdf
endif 

LHAPDFINC = $(shell $(LHAPDF)/bin/lhapdf-config --incdir)
LHAPDFLIB = $(shell $(LHAPDF)/bin/lhapdf-config --libdir)


HATHORPATH = $(HATHOR)

CC  = gcc
CXX = g++
FC  = gfortran
AR  = ar
RANLIB = ranlib

IFLAGS = -I. -I$(LHAPDFINC) -I$(HATHORPATH)/include
MYLIBS =  -L $(HATHORPATH)/lib -lHathor -L $(LHAPDFLIB) -lLHAPDF -lff 

LFLAGS := $(MYLIBS) $(LFLAGS) -lgfortranbegin -lgfortran -lm

# default configuration
CFLAGS := $(CFLAGS) -O2 -Wall
FFLAGS := $(FFLAGS)

#DEMOS =  demo demo_sgtop
DEMOS =  myprogram

all: $(DEMOS)

%: %.cxx
	$(CXX) $(CFLAGS) $(IFLAGS) -o $@ $< $(LFLAGS)

clean:
	rm -f $(DEMOS) 

distclean: clean



