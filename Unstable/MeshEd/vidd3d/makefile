TITLE=VIDD3D.DLL BUILD

#PCH=1
#-------------------------------------------------------
# BUILD LIST
#-------------------------------------------------------
BUILD_LIST=obj_dir stdd3d.pch vidd3d.dll install

THISDIR=$(BUILD_ROOT_DUKE)\MeshEd\vidd3d

!include $(BUILD_ROOT_DUKE)\bin\dll.mak

CINCS   = -I$(BUILD_ROOT_DUKE)\core\inc \
          -I$(BUILD_ROOT_DUKE)\xcore \
		  -I$(BUILD_ROOT_DUKE)\ximage \
          -I$(BUILD_ROOT_DUKE)\DirectX8\Inc \
          -I$(BUILD_ROOT_DUKE)\MeshEd

CFLAGS  = $(CFLAGS) $(CINCS) -FR -MD -D_AFXDLL -D_AFX_NOFORCE_LIBS

CPP_PREFLAGS = $(CFLAGS)
CPP_PURE = $(CFLAGS)
!ifdef PCH
CPP_GEN = $(CFLAGS) -Yustdd3d.h -Yd
!else
CPP_GEN = $(CFLAGS) -Yd
!endif

XFLAGS  = -DXCORE_PURE

AFLAGS  = $(AFLAGS) $(CINCS)

#-------------------------------------------------------
# Source files
#-------------------------------------------------------
OBJ1    = font.obj vbuffer.obj main.obj dev.obj vidif.obj tex.obj

LLIBS  = user32.lib gdi32.lib kernel32.lib msvcrt.lib \
         $(BUILD_ROOT_DUKE)\DirectX8\lib\d3d8.lib \
		 $(BUILD_ROOT_DUKE)\DirectX8\lib\d3dx8.lib \
         $(BUILD_ROOT_DUKE)\xcore\xcore.lib \
		 $(BUILD_ROOT_DUKE)\ximage\ximage.lib

#-------------------------------------------------------
# Source Dependencies
#-------------------------------------------------------
DEPENDENCIES=$(XCORE_DEP) $(ROOT_XCORE)\xwnd.h $(XIMAGE_DEP) \
		 ..\makefile ..\vidd3d.h ..\stdd3d.h ..\..\vid_main.h

stdd3d.pch: $(DEPENDENCIES)
        $(CL) $(CPP_PREFLAGS) $(XFLAGS) /Ycstdd3d.h /Yd /Fpstdd3d.pch $(THISDIR)\stdd3d.cpp

dev.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

font.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

main.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

tex.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

vbuffer.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

vidif.obj: $(THISDIR)\$(@B).cpp $(DEPENDENCIES)
        $(CL) $(CPP_GEN) $(XFLAGS) -Fo$(@B).obj $(THISDIR)\$(@B).cpp

#-------------------------------------------------------
# Clean
#-------------------------------------------------------
clean:
        @$(CEcho) cleaning $(TITLE)...
		@if exist stdd3d.pch del stdd3d.pch
        @$(fdeltree) /y obj

#-------------------------------------------------------
# Output files
#-------------------------------------------------------
vidd3d.dll: $(OBJ1) $(THISDIR)\$(@B).def
        $(LINK) $(LFLAGS) -pdb:none -def:$(THISDIR)\$(@B).def -base:0x23000000 -out:$(@B).dll $(OBJ1) $(LLIBS)
		bscmake.exe -nologo -o $(@B).bsc *.sbr

#-------------------------------------------------------
# Install Section
#-------------------------------------------------------
install:
        @$(cecho) Installing $(TITLE)...
        @$(fcopy) /d /f /y vidd3d.dll $(THISDIR)\..\drivers
