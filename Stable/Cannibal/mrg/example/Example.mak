# Microsoft Developer Studio Generated NMAKE File, Based on Example.dsp
!IF "$(CFG)" == ""
CFG=Example - Win32 Debug
!MESSAGE No configuration specified. Defaulting to Example - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "Example - Win32 Release" && "$(CFG)" !=\
 "Example - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Example.mak" CFG="Example - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Example - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "Example - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "Example - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release
# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

!IF "$(RECURSE)" == "0" 

ALL : "$(OUTDIR)\Example.exe"

!ELSE 

ALL : "$(OUTDIR)\Example.exe"

!ENDIF 

CLEAN :
	-@erase "$(INTDIR)\example.obj"
	-@erase "$(INTDIR)\model.obj"
	-@erase "$(INTDIR)\render.obj"
	-@erase "$(INTDIR)\Resource.res"
	-@erase "$(INTDIR)\vc50.idb"
	-@erase "$(OUTDIR)\Example.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP_PROJ=/nologo /MD /W3 /GX /O2 /I "..\include" /D "WIN32" /D "NDEBUG" /D\
 "_WINDOWS" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 
CPP_OBJS=.\Release/
CPP_SBRS=.
MTL_PROJ=/nologo /D "NDEBUG" /mktyplib203 /o NUL /win32 
RSC_PROJ=/l 0x409 /fo"$(INTDIR)\Resource.res" /d "NDEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\Example.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=..\mrg.lib comdlg32.lib user32.lib gdi32.lib opengl32.lib\
 glu32.lib /nologo /subsystem:windows /incremental:no\
 /pdb:"$(OUTDIR)\Example.pdb" /machine:I386 /out:"$(OUTDIR)\Example.exe" 
LINK32_OBJS= \
	"$(INTDIR)\example.obj" \
	"$(INTDIR)\model.obj" \
	"$(INTDIR)\render.obj" \
	"$(INTDIR)\Resource.res"

"$(OUTDIR)\Example.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Example - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug
# Begin Custom Macros
OutDir=.\Debug
# End Custom Macros

!IF "$(RECURSE)" == "0" 

ALL : "$(OUTDIR)\Example.exe"

!ELSE 

ALL : "$(OUTDIR)\Example.exe"

!ENDIF 

CLEAN :
	-@erase "$(INTDIR)\example.obj"
	-@erase "$(INTDIR)\model.obj"
	-@erase "$(INTDIR)\render.obj"
	-@erase "$(INTDIR)\Resource.res"
	-@erase "$(INTDIR)\vc50.idb"
	-@erase "$(INTDIR)\vc50.pdb"
	-@erase "$(OUTDIR)\Example.exe"
	-@erase "$(OUTDIR)\Example.ilk"
	-@erase "$(OUTDIR)\Example.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP_PROJ=/nologo /MDd /W3 /Gm /GX /Zi /Od /I "..\include" /D "WIN32" /D\
 "_DEBUG" /D "_WINDOWS" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 
CPP_OBJS=.\Debug/
CPP_SBRS=.
MTL_PROJ=/nologo /D "_DEBUG" /mktyplib203 /o NUL /win32 
RSC_PROJ=/l 0x409 /fo"$(INTDIR)\Resource.res" /d "_DEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\Example.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=..\mrgd.lib comdlg32.lib user32.lib gdi32.lib opengl32.lib\
 glu32.lib /nologo /subsystem:windows /incremental:yes\
 /pdb:"$(OUTDIR)\Example.pdb" /debug /machine:I386 /out:"$(OUTDIR)\Example.exe"\
 /pdbtype:sept 
LINK32_OBJS= \
	"$(INTDIR)\example.obj" \
	"$(INTDIR)\model.obj" \
	"$(INTDIR)\render.obj" \
	"$(INTDIR)\Resource.res"

"$(OUTDIR)\Example.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

.c{$(CPP_OBJS)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(CPP_OBJS)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(CPP_OBJS)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(CPP_SBRS)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(CPP_SBRS)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(CPP_SBRS)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<


!IF "$(CFG)" == "Example - Win32 Release" || "$(CFG)" ==\
 "Example - Win32 Debug"
SOURCE=.\example.cpp

!IF  "$(CFG)" == "Example - Win32 Release"

DEP_CPP_EXAMP=\
	"..\include\mrg\coord.h"\
	"..\include\mrg\manager.h"\
	"..\include\mrg\matrix.h"\
	"..\include\mrg\model.h"\
	"..\include\mrg\object.h"\
	"..\include\mrg\rotation.h"\
	

"$(INTDIR)\example.obj" : $(SOURCE) $(DEP_CPP_EXAMP) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "Example - Win32 Debug"

DEP_CPP_EXAMP=\
	"..\include\mrg\coord.h"\
	"..\include\mrg\manager.h"\
	"..\include\mrg\matrix.h"\
	"..\include\mrg\model.h"\
	"..\include\mrg\object.h"\
	"..\include\mrg\rotation.h"\
	

"$(INTDIR)\example.obj" : $(SOURCE) $(DEP_CPP_EXAMP) "$(INTDIR)"


!ENDIF 

SOURCE=.\model.cpp

!IF  "$(CFG)" == "Example - Win32 Release"

DEP_CPP_MODEL=\
	"..\include\mrg.h"\
	"..\include\mrg\character.h"\
	"..\include\mrg\coord.h"\
	"..\include\mrg\faceset.h"\
	"..\include\mrg\hier.h"\
	"..\include\mrg\manager.h"\
	"..\include\mrg\matrix.h"\
	"..\include\mrg\model.h"\
	"..\include\mrg\object.h"\
	"..\include\mrg\opt.h"\
	"..\include\mrg\pixmap.h"\
	"..\include\mrg\rotation.h"\
	"..\include\mrg\texfaceset.h"\
	"..\include\mrg\timer.h"\
	"..\include\mrg\tri.h"\
	"..\include\mrg\vdata.h"\
	

"$(INTDIR)\model.obj" : $(SOURCE) $(DEP_CPP_MODEL) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "Example - Win32 Debug"

DEP_CPP_MODEL=\
	"..\include\mrg.h"\
	"..\include\mrg\character.h"\
	"..\include\mrg\coord.h"\
	"..\include\mrg\faceset.h"\
	"..\include\mrg\hier.h"\
	"..\include\mrg\manager.h"\
	"..\include\mrg\matrix.h"\
	"..\include\mrg\model.h"\
	"..\include\mrg\object.h"\
	"..\include\mrg\opt.h"\
	"..\include\mrg\pixmap.h"\
	"..\include\mrg\rotation.h"\
	"..\include\mrg\texfaceset.h"\
	"..\include\mrg\timer.h"\
	"..\include\mrg\tri.h"\
	"..\include\mrg\vdata.h"\
	

"$(INTDIR)\model.obj" : $(SOURCE) $(DEP_CPP_MODEL) "$(INTDIR)"


!ENDIF 

SOURCE=.\render.cpp

!IF  "$(CFG)" == "Example - Win32 Release"

DEP_CPP_RENDE=\
	"..\include\mrg.h"\
	"..\include\mrg\character.h"\
	"..\include\mrg\coord.h"\
	"..\include\mrg\faceset.h"\
	"..\include\mrg\hier.h"\
	"..\include\mrg\manager.h"\
	"..\include\mrg\matrix.h"\
	"..\include\mrg\model.h"\
	"..\include\mrg\object.h"\
	"..\include\mrg\opt.h"\
	"..\include\mrg\pixmap.h"\
	"..\include\mrg\rotation.h"\
	"..\include\mrg\texfaceset.h"\
	"..\include\mrg\timer.h"\
	"..\include\mrg\tri.h"\
	"..\include\mrg\vdata.h"\
	

"$(INTDIR)\render.obj" : $(SOURCE) $(DEP_CPP_RENDE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "Example - Win32 Debug"

DEP_CPP_RENDE=\
	"..\include\mrg.h"\
	"..\include\mrg\character.h"\
	"..\include\mrg\coord.h"\
	"..\include\mrg\faceset.h"\
	"..\include\mrg\hier.h"\
	"..\include\mrg\manager.h"\
	"..\include\mrg\matrix.h"\
	"..\include\mrg\model.h"\
	"..\include\mrg\object.h"\
	"..\include\mrg\opt.h"\
	"..\include\mrg\pixmap.h"\
	"..\include\mrg\rotation.h"\
	"..\include\mrg\texfaceset.h"\
	"..\include\mrg\timer.h"\
	"..\include\mrg\tri.h"\
	"..\include\mrg\vdata.h"\
	

"$(INTDIR)\render.obj" : $(SOURCE) $(DEP_CPP_RENDE) "$(INTDIR)"


!ENDIF 

SOURCE=.\Resource.rc

"$(INTDIR)\Resource.res" : $(SOURCE) "$(INTDIR)"
	$(RSC) $(RSC_PROJ) $(SOURCE)



!ENDIF 

