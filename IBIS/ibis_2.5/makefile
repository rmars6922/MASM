VERSION = 2.5

COMFILES = com1d.h    comatm.h   combcs.h   comhyd.h   \
           commac.h   compar.h   comsat.h   comsno.h   \
           comsoi.h   comsum.h   comveg.h   comwork.h  \
           comdiag.h  implicit.h

F77_OPTIONS = -O2 -col120      

#  WARNING - DO NOT USE -Ofast OPTION DURING COMPILING
#  Useful options for debugging on SGI:
#  F77_OPTIONS = -col120 -c -O0 -g -C -trapuv

INCLUDE_DIRS  = -I/usr/local/include
LD_OPTIONS_NETCDF  = -L/usr/local/lib -lnetcdf

ibisnetcdf: biogeochem.o canopy.o climate.o diagnostics.o ies-io.o \
        initial.o io.o main.o math.o physiology.o radiation.o \
        snow.o soil.o stats.o utilities.o vegetation.o weather.o \
        $(COMFILES)

biogeochem.o:	biogeochem.f    $(COMFILES)
canopy.o:	canopy.f        $(COMFILES)
climate.o:	climate.f       $(COMFILES)
diagnostics.o:	diagnostics.f   $(COMFILES)
ies-io.o:       ies-io.f        $(COMFILES)
initial.o:	initial.f       $(COMFILES)
io.o:		io.f            $(COMFILES)
main.o:		main.f          $(COMFILES)
math.o:		math.f          $(COMFILES)
physiology.o:	physiology.f    $(COMFILES)
radiation.o:	radiation.f     $(COMFILES)
snow.o:		snow.f          $(COMFILES)
soil.o:		soil.f          $(COMFILES)
stats.o:	stats.f         $(COMFILES)
utilities.o:	utilities.f     $(COMFILES)
vegetation.o:	vegetation.f    $(COMFILES)
weather.o:	weather.f	$(COMFILES)

ibisnetcdf:
	f77 biogeochem.o canopy.o climate.o diagnostics.o ies-io.o \
        initial.o io.o main.o math.o physiology.o radiation.o \
        snow.o soil.o stats.o utilities.o vegetation.o weather.o \
        $(F77_OPTIONS) $(INCLUDE_DIRS) $(LD_OPTIONS_NETCDF) -o ibisnetcdf


.f.o:
	f77 $(F77_OPTIONS) $(INCLUDE_DIRS) -c -o $*.o $*.f

#------------------------------------------------------------------------
# To put all necessary files in one file ready for distribution,
# make sure the value for VERSION (at top of this file) is correct.
# then, type:
# make tardist
# you may then gzip or compress the file ibis_VERSION.tar
# If you make changes to the names of .f files (above), or add more .f
# files, you must change/add to the list below.

tardist:
	tar -cvLf ibis_$(VERSION).tar README-1st.txt READMEnet.txt \
  READMEnotes.txt history \
  diag.infile ibis.infile \
  makefile $(COMFILES) \
  biogeochem.f canopy.f climate.f diagnostics.f ies-io.f initial.f \
  io.f main.f math.f physiology.f radiation.f snow.f \
  soil.f stats.f utilities.f vegetation.f weather.f

