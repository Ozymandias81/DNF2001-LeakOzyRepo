TITLE=TEST01.EXE BUILD

#-------------------------------------------------------
# BUILD LIST
#-------------------------------------------------------
BUILD_LIST=obj_dir test01.exe

THISDIR=$(BUILD_ROOT_DUKE)\ximage\tests

!include $(BUILD_ROOT_DUKE)\bin\console.mak

CINCS   = -I$(BUILD_ROOT_DUKE)\core\inc \
          -I$(BUILD_ROOT_DUKE)\xcore \
		  -I$(BUILD_ROOT_DUKE)\ximage \
          -I$(THISDIR)

CFLAGS  = $(CFLAGS) $(CINCS) -FR -MD -GX

XFLAGS  = -DXCORE_PURE

AFLAGS  = $(AFLAGS) $(CINCS)

#-------------------------------------------------------
# Source files
#-------------------------------------------------------
OBJ1    = test01.obj

LLIBS  = user32.lib gdi32.lib kernel32.lib msvcrt.lib \
         $(BUILD_ROOT_DUKE)\xcore\xcore.lib \
		 $(BUILD_ROOT_DUKE)\xcore\xcore_console.lib \
		 $(BUILD_ROOT_DUKE)\ximage\ximage.lib

#-------------------------------------------------------
# Source Dependencies
#-------------------------------------------------------
DEPENDENCIES=$(XCONAPP_DEP) $(XIMAGE_DEP) ..\makefile

test01.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CFLAGS) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp


#-------------------------------------------------------
# Clean
#-------------------------------------------------------
clean:
        @$(CEcho) cleaning $(TITLE)...
        @$(fdeltree) /y obj
		@if exist *.exp del *.exp
		@if exist *.pdb del *.pdb
		@if exist *.bsc del *.bsc

distclean:
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

#-------------------------------------------------------
# Output files
#-------------------------------------------------------
test01.exe: $(OBJ1)
		$(LINK) $(OBJ1) $(LIBS) $(RES1) -out:$(@B).exe $(LFLAGS)
