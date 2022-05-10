TITLE=XIMAGE.LIB BUILD

#-------------------------------------------------------
# BUILD LIST
#-------------------------------------------------------
BUILD_LIST=obj_dir ximage.dll install

THISDIR=$(BUILD_ROOT_DUKE)\ximage

!include $(BUILD_ROOT_DUKE)\bin\dll.mak

CINCS   = -I$(BUILD_ROOT_DUKE)\core\inc \
          -I$(BUILD_ROOT_DUKE)\xcore \
          -I$(THISDIR)

CFLAGS  = $(CFLAGS) $(CINCS) -FR -MD -GX

CPP_PREFLAGS = $(CFLAGS)
CPP_PURE = $(CFLAGS)

XFLAGS  = -DXCORE_PURE -DXIMAGE_LIBRARY

AFLAGS  = $(AFLAGS) $(CINCS)

#-------------------------------------------------------
# Source files
#-------------------------------------------------------
OBJ1    = dll.obj tga.obj image.obj bmp.obj


LLIBS  = user32.lib gdi32.lib kernel32.lib msvcrt.lib \
         $(BUILD_ROOT_DUKE)\xcore\xcore.lib

#-------------------------------------------------------
# Source Dependencies
#-------------------------------------------------------
DEPENDENCIES=$(XCORE_DEP) ..\makefile ..\ximage.h ..\xtga.h ..\xbmp.h

bmp.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_PURE) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

dll.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_PURE) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

image.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_PURE) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

tga.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_PURE) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

#-------------------------------------------------------
# Clean
#-------------------------------------------------------
clean:
        @$(CEcho) cleaning $(TITLE)...
        @$(fdeltree) /y obj
		@if exist *.lib del *.lib
		@if exist *.dll del *.dll
		@if exist *.exp del *.exp
		@if exist *.pdb del *.pdb
		@if exist *.bsc del *.bsc

distclean: dist_clean_tests
        @$(CEcho) Fully Cleaning $(TITLE)...
        @$(fdeltree) /y obj
		@if exist *.lib del *.lib
		@if exist *.dll del *.dll
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
ximage.dll: $(OBJ1) $(THISDIR)\$(@B).def
        $(LINK) $(LFLAGS) -def:$(THISDIR)\$(@B).def -base:0x22000000 -out:$(@B).dll $(OBJ1) $(LLIBS)

#-------------------------------------------------------
# Install Section
#-------------------------------------------------------
install:
        @$(cecho) Installing $(TITLE)...
        @$(fcopy) /d /f /y ximage.lib $(THISDIR)
        @$(fcopy) /d /f /y ximage.dll $(BUILD_ROOT_DUKE)\system
        @$(fcopy) /d /f /y ximage.dll $(BUILD_ROOT_DUKE)\meshed
