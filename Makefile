#############################################################################
## Makefile -- New Version of my Makefile that works on both linux
##              and mac os x
## Ryan Nichol <rjn@hep.ucl.ac.uk>
##############################################################################
include StandardDefinitions.mk

#Site Specific  Flags
ifeq ($(strip $(BOOST_ROOT)),)
	BOOST_ROOT = /usr/local/include
endif

SYSINCLUDES	= -I/usr/include -I$(BOOST_ROOT) #-I$(PLATFORM_DIR)/include
SYSLIBS         = -L/usr/lib -L/usr/local/lib #-L$(PLATFORM_DIR)/lib

DLLSUF = ${DllSuf}
OBJSUF = ${ObjSuf}
SRCSUF = ${SrcSuf}

#-L/usr/lib -I/usr/include

CXX = g++

#Generic and Site Specific Flags
CXXFLAGS     += $(SYSINCLUDES) $(INC_ARA_UTIL)
LDFLAGS      += -L. -g -I$(BOOST_ROOT) $(ROOTLDFLAGS) $(LD_ARA_UTIL) -Wl,#--no-as-needed
ARA_ROOT_FLAGS = 

# copy from ray_solver_makefile (removed -lAra part)

# added for Fortran to C++


LIBS	= $(ROOTLIBS) -lMinuit $(SYSLIBS) -lsqlite3
GLIBS	= $(ROOTGLIBS) $(SYSLIBS)

# ROOT_LIBRARY = libAra.${DLLSUF}

OBJS = Vector.o EarthModel.o IceModel.o Trigger.o Ray.o Tools.o Efficiencies.o Event.o Detector.o Position.o Spectra.o RayTrace.o RayTrace_IceModels.o signal.o secondaries.o Settings.o Primaries.o counting.o RaySolver.o Report.o eventSimDict.o AraSim.o
CCFILE = Vector.cc EarthModel.cc IceModel.cc Trigger.cc Ray.cc Tools.cc Efficiencies.cc Event.cc Detector.cc Spectra.cc Position.cc RayTrace.cc signal.cc secondaries.cc RayTrace_IceModels.cc Settings.cc Primaries.cc counting.cc RaySolver.cc Report.cc AraSim.cc
CLASS_HEADERS = Trigger.h Detector.h Settings.h Spectra.h IceModel.h Primaries.h Report.h Event.h #need to add headers which added to Tree Branch

PROGRAMS = AraSim

all : $(PROGRAMS) 

AraSim : $(OBJS)
	$(LD) -v -L. $(OBJS) $(LDFLAGS) $(LIBS) -o $(PROGRAMS) 
#	ld -v -L. $(OBJS) $(LDFLAGS) $(LIBS) -o $(PROGRAMS) 
	@echo "done."

#The library
$(ROOT_LIBRARY) :
	@echo "Linking $@ ..."
ifeq ($(PLATFORM),macosx)
# We need to make both the .dylib and the .so
		$(LD) $(SOFLAGS)$@ $(LDFLAGS) $(G77LDFLAGS) $^ $(OutPutOpt) $@
ifneq ($(subst $(MACOSX_MINOR),,1234),1234)
ifeq ($(MACOSX_MINOR),4)
		ln -sf $@ $(subst .$(DllSuf),.so,$@)
else
		$(LD) -dynamiclib -undefined $(UNDEFOPT) $(LDFLAGS) $(G77LDFLAGS) $^ \
		   $(OutPutOpt) $(subst .$(DllSuf),.so,$@)
endif
endif
else
	$(LD) $(SOFLAGS) $(LDFLAGS) $(G77LDFLAGS) $(LIBS) -o $@
endif

##-bundle

#%.$(OBJSUF) : %.$(SRCSUF)
#	@echo "<**Compiling**> "$<
#	$(CXX) $(CXXFLAGS) -c $< -o  $@

%.$(OBJSUF) : %.C
	@echo "<**Compiling**> "$<
	$(CXX) $(CXXFLAGS) $ -c $< -o  $@

%.$(OBJSUF) : %.cc %.h
	@echo "<**Compiling**> "$<
	$(CXX) $(CXXFLAGS) $ -c $< -o  $@

# added for fortran code compiling
%.$(OBJSUF) : %.f
	@echo "<**Compiling**> "$<
	$(G77) -c $<

eventSimDict.C: $(CLASS_HEADERS)
	@echo "Generating dictionary ..."
	@ rm -f *Dict* 
	rootcint -f $@ -c $(DICT_FLAGS) -I./ $(INC_ARA_UTIL) $(CLASS_HEADERS) ${ARA_ROOT_HEADERS} LinkDef.h

clean:
	@rm -f *Dict*
	@rm -f *.${OBJSUF}
	@rm -f $(LIBRARY)
	@rm -f $(ROOT_LIBRARY)
	@rm -f $(subst .$(DLLSUF),.so,$(ROOT_LIBRARY))	
	@rm -f $(TEST)
	@rm -f $(PROGRAMS)

#############################################################################
