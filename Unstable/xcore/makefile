TITLE=XCORE.DLL BUILD

#-------------------------------------------------------
# BUILD LIST
#-------------------------------------------------------
BUILD_LIST=obj_dir genfiles stdcore.pch xcore.dll install xcore_winapp.lib install_winapp xcore_console.lib install_console

THISDIR=$(BUILD_ROOT_DUKE)\xcore

!include $(BUILD_ROOT_DUKE)\bin\dll.mak

CINCS   = -I$(BUILD_ROOT_DUKE)\core\inc \
          -I$(THISDIR)

CFLAGS  = $(CFLAGS) $(CINCS) -FR -MD -GX

CPP_PREFLAGS = $(CFLAGS)
CPP_PURE = $(CFLAGS)
CPP_GEN = $(CFLAGS) -Yustdcore.h

XFLAGS  = -DXCORE_LIBRARY
XFLAGS2  = -DXCORE_PURE

AFLAGS  = $(AFLAGS) $(CINCS)

#-------------------------------------------------------
# Source files
#-------------------------------------------------------
OBJ1    = list.obj file.obj find.obj malloc.obj winalloc.obj dll.obj error.obj global.obj printf.obj \
          stream.obj string.obj stuff.obj win.obj winfile.obj \
          winmem.obj xmisc.obj flagdata.obj stdcore.obj

OBJ2    = winapp.obj xwnd.obj
OBJ3	= conapp.obj

#SLIBS2  = $(BUILD_ROOT_DUKE)\xcore\xcore.lib

LLIBS  = user32.lib gdi32.lib kernel32.lib msvcrt.lib

#-------------------------------------------------------
# Source Dependencies
#-------------------------------------------------------
DEPENDENCIES=..\makefile ..\xcore.h ..\xclass.h ..\xstring.h ..\xstream.h ..\filex.h

stdcore.pch stdcore.obj: $(DEPENDENCIES)
        $(CL) $(CPP_PREFLAGS) $(XFLAGS) /Ycstdcore.h /Yd /Fpstdcore.pch $(THISDIR)\stdcore.cpp

conapp.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES) ..\conapp.h
        $(CL) $(CFLAGS) $(XFLAGS2) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

dll.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

error.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

file.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

find.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

flagdata.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

global.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

list.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

malloc.obj: $(THISDIR)\$(@B).asm $(DEPENDENCIES)
        $(NASM) $(NFLAGS) -f coff $(THISDIR)\$(@B).asm -o $(@B).obj

printf.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

stat.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

stream.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

string.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

stuff.obj: $(THISDIR)\$(@B).asm $(DEPENDENCIES)
        $(NASM) $(NFLAGS) -f coff $(THISDIR)\$(@B).asm -o $(@B).obj

win.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

winalloc.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

winfile.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

winmem.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

xmisc.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

winapp.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES) ..\winapp.h ..\xwnd.h
        $(CL) $(CPP_PURE) $(XFLAGS2) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

xwnd.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES) ..\winapp.h ..\xwnd.h
        $(CL) $(CPP_PURE) $(XFLAGS2) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

#-------------------------------------------------------
# File Generation
#-------------------------------------------------------
GEN_OBJ = genmem.obj

GEND_OBJ = gendata.obj

GLIBS= user32.lib libcmt.lib kernel32.lib

SRC_DEPEND=../makefile ../winalloc.h ../xcore.h

genfiles: genpre ..\memoff.inc ..\flagdata.cpp genpost

genpre:
       @$(CEcho) ----- Starting File Generation

genpost:
       @$(CEcho) ----- Ending File Generation

memoff.inc : genoff.exe $(SRC_DEPEND)
       genoff.exe > memoff.inc

flagdata.cpp : gendata.exe $(SRC_DEPEND)
       gendata.exe > flagdata.cpp

..\memoff.inc : memoff.inc $(SRC_DEPEND)
       @$(fcopy) /d /f /y memoff.inc ..

..\flagdata.cpp : flagdata.cpp $(SRC_DEPEND)
       @$(fcopy) /d /f /y flagdata.cpp ..

genmem.obj: $(THISDIR)\$(@B).cpp $(SRC_DEPEND)
       $(CL) $(CFLAGS) -Z7 -Fo$(@B).obj $(THISDIR)\$(@B).cpp

gendata.obj: $(THISDIR)\$(@B).cpp $(SRC_DEPEND)
       $(CL) $(CFLAGS) -Z7 -Fo$(@B).obj $(THISDIR)\$(@B).cpp

genoff.exe: $(GEN_OBJ) $(RES1) $(OBJ_DEPEND)
       $(LINK) $(GEN_OBJ) $(GLIBS) $(LIBS) -nodefaultlib -out:$(@B).exe -debug -debugtype:both $(LFLAGS_CEXE)

gendata.exe: $(GEND_OBJ) $(RES1) $(OBJ_DEPEND)
       $(LINK) $(GEND_OBJ) $(GLIBS) $(LIBS) -nodefaultlib -out:$(@B).exe -debug -debugtype:both $(LFLAGS_CEXE)

#-------------------------------------------------------
# Clean
#-------------------------------------------------------
clean:
        @$(CEcho) cleaning $(TITLE)...
        @$(fdeltree) /y obj
        @if exist memoff.inc del memoff.inc
        @if exist flagdata.cpp del flagdata.cpp
        @if exist *.dll del *.dll
        @if exist *.lib del *.lib
        @if exist *.exp del *.exp
        @if exist *.pdb del *.pdb
        @if exist *.bsc del *.bsc

distclean: dist_clean_tests
        @$(CEcho) Fully Cleaning $(TITLE)...
        @$(fdeltree) /y obj
        @if exist memoff.inc del memoff.inc
        @if exist flagdata.cpp del flagdata.cpp
        @if exist *.dll del *.dll
        @if exist *.lib del *.lib
        @if exist *.exp del *.exp
        @if exist *.pdb del *.pdb
        @if exist *.bsc del *.bsc
        @if exist *.ncb del *.ncb
        @if exist *.opt del *.opt
        @if exist *.scc attrib -r *.scc
        @if exist *.scc del *.scc
        @if exist *.plg del *.plg

dist_clean_tests:
        @$(CEcho) Fully Cleaning Tests
        @if exist tests\debug $(fdeltree) /y tests\debug
        @if exist tests\release $(fdeltree) /y tests\release
        @if exist tests\*.scc attrib -r tests\*.scc
        @if exist tests\*.scc del tests\*.scc
        @if exist tests\*.plg del tests\*.plg

#-------------------------------------------------------
# Output files
#-------------------------------------------------------
xcore.dll: $(OBJ1) $(THISDIR)\$(@B).def
        $(LINK) $(LFLAGS) -def:$(THISDIR)\$(@B).def -base:0x21000000 -out:$(@B).dll $(OBJ1) $(LLIBS) $(HW_LIB)
		bscmake.exe -nologo -o $(@B).bsc *.sbr

xcore_winapp.lib: $(OBJ2) $(SLIBS2)
		$(MLIB) $(SLIBS) $(SLIBS2) $(LIB_FLAGS) -out:$(@B).lib $(OBJ2)

xcore_console.lib: $(OBJ3) $(SLIBS2)
		$(MLIB) $(SLIBS) $(SLIBS2) $(LIB_FLAGS) -out:$(@B).lib $(OBJ3)

#-------------------------------------------------------
# Install Section
#-------------------------------------------------------
install:
        @$(cecho) Installing $(TITLE)...
        @$(fcopy) /d /f /y xcore.lib $(THISDIR)
        @$(fcopy) /d /f /y xcore.dll $(BUILD_ROOT_DUKE)\system
        @$(fcopy) /d /f /y xcore.dll $(BUILD_ROOT_DUKE)\cannibaleditor
        @$(fcopy) /d /f /y xcore.dll $(BUILD_ROOT_DUKE)\meshed
        @$(fcopy) /d /f /y xcore.dll $(BUILD_ROOT_DUKE)\meshed3
        @$(fcopy) /d /f /y xcore.bsc $(THISDIR)

install_winapp:
        @$(cecho) Installing XCORE_WINAPP.LIB...
        @$(fcopy) /d /f /y xcore_winapp.lib $(THISDIR)

install_console:
        @$(cecho) Installing XCORE_CONSOLE.LIB...
        @$(fcopy) /d /f /y xcore_console.lib $(THISDIR)
