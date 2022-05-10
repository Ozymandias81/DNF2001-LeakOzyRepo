# Microsoft Developer Studio Project File - Name="GalaxyLib" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Static Library" 0x0104

CFG=GalaxyLib - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "GalaxyLib.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "GalaxyLib.mak" CFG="GalaxyLib - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "GalaxyLib - Win32 Release" (based on "Win32 (x86) Static Library")
!MESSAGE "GalaxyLib - Win32 Debug" (based on "Win32 (x86) Static Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/GalaxyLib", CPNAAAAA"
# PROP Scc_LocalPath "."
CPP=VECTORCL
RSC=rc.exe

!IF  "$(CFG)" == "GalaxyLib - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "GalaxyLib___Win32_Release"
# PROP BASE Intermediate_Dir "GalaxyLib___Win32_Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "GalaxyLib___Win32_Release"
# PROP Intermediate_Dir "GalaxyLib___Win32_Release"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /FD /c
# ADD CPP /nologo /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /FD /c
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=xilink6.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo

!ELSEIF  "$(CFG)" == "GalaxyLib - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /FD /GZ /c
# ADD CPP /nologo /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=xilink6.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo

!ENDIF 

# Begin Target

# Name "GalaxyLib - Win32 Release"
# Name "GalaxyLib - Win32 Debug"
# Begin Source File

SOURCE=.\Hdr\EAX.H
# End Source File
# Begin Source File

SOURCE=.\Hdr\Eax2.h
# End Source File
# Begin Source File

SOURCE=.\Hdr\EaxMan.h
# End Source File
# Begin Source File

SOURCE=.\Hdr\Galaxy.ah
# End Source File
# Begin Source File

SOURCE=.\Galaxy.c
# End Source File
# Begin Source File

SOURCE=.\Hdr\Galaxy.h
# End Source File
# Begin Source File

SOURCE=".\Glx-669.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-669.h"
# End Source File
# Begin Source File

SOURCE=".\glx-ae.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\glx-ae.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-ai.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-ai.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-am.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-am.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-as.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-as.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-au.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-au.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-dls.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-dls.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-dmus.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-dmus.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-far.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-far.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-ima.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-ima.h"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-it.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-mid.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-mid.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-mod.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-mod.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-mpa.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-mpa.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-mtm.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-mtm.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-ptm.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-ptm.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-s3m.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-s3m.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-sf2.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-sf2.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-smp.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-smp.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-st3.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-st3.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-stm.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-stm.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-ult.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-ult.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-voc.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-voc.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-wav.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-wav.h"
# End Source File
# Begin Source File

SOURCE=".\Glx-xm.c"
# End Source File
# Begin Source File

SOURCE=".\Hdr\Glx-xm.h"
# End Source File
# Begin Source File

SOURCE=.\HUFFDEC.C
# End Source File
# Begin Source File

SOURCE=.\hufftab.h
# End Source File
# Begin Source File

SOURCE=.\hufftab2.h
# End Source File
# Begin Source File

SOURCE=.\Hdr\IA3D.H
# End Source File
# Begin Source File

SOURCE=.\Hdr\ia3dapi.h
# End Source File
# Begin Source File

SOURCE=.\K3d.asm

!IF  "$(CFG)" == "GalaxyLib - Win32 Release"

# PROP Ignore_Default_Tool 1
# Begin Custom Build
IntDir=.\GalaxyLib___Win32_Release
InputPath=.\K3d.asm

"$(IntDir)\k3d.obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /Fo$(IntDir)\K3d.obj /c /coff /Cp /Cx $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "GalaxyLib - Win32 Debug"

# PROP Ignore_Default_Tool 1
# Begin Custom Build
IntDir=.\Debug
InputPath=.\K3d.asm

"$(IntDir)\k3d.obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /Fo$(IntDir)\K3d.obj /c /coff /Cp /Cx $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Kni.asm

!IF  "$(CFG)" == "GalaxyLib - Win32 Release"

# PROP Ignore_Default_Tool 1
# Begin Custom Build
IntDir=.\GalaxyLib___Win32_Release
InputPath=.\Kni.asm

"$(IntDir)\kni.obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /Fo$(IntDir)\kni.obj /c /coff /Cp /Cx $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "GalaxyLib - Win32 Debug"

# PROP Ignore_Default_Tool 1
# Begin Custom Build
IntDir=.\Debug
InputPath=.\Kni.asm

"$(IntDir)\kni.obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /Fo$(IntDir)\kni.obj /c /coff /Cp /Cx $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Loaders.c
# End Source File
# Begin Source File

SOURCE=.\Hdr\Loaders.h
# End Source File
# Begin Source File

SOURCE=.\Mmx.asm

!IF  "$(CFG)" == "GalaxyLib - Win32 Release"

# PROP Ignore_Default_Tool 1
# Begin Custom Build
IntDir=.\GalaxyLib___Win32_Release
InputPath=.\Mmx.asm

"$(IntDir)\mmx.obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /Fo$(IntDir)\mmx.obj /c /coff /Cp /Cx $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "GalaxyLib - Win32 Debug"

# PROP Ignore_Default_Tool 1
# Begin Custom Build
IntDir=.\Debug
InputPath=.\Mmx.asm

"$(IntDir)\mmx.obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /Fo$(IntDir)\mmx.obj /c /coff /Cp /Cx $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Sbs.asm

!IF  "$(CFG)" == "GalaxyLib - Win32 Release"

# PROP Ignore_Default_Tool 1
# Begin Custom Build
IntDir=.\GalaxyLib___Win32_Release
InputPath=.\Sbs.asm

"$(IntDir)\sbs.obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /Fo$(IntDir)\sbs.obj /c /coff /Cp /Cx $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "GalaxyLib - Win32 Debug"

# PROP Ignore_Default_Tool 1
# Begin Custom Build
IntDir=.\Debug
InputPath=.\Sbs.asm

"$(IntDir)\sbs.obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /Fo$(IntDir)\sbs.obj /c /coff /Cp /Cx $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\X86.asm

!IF  "$(CFG)" == "GalaxyLib - Win32 Release"

# PROP Ignore_Default_Tool 1
# Begin Custom Build
IntDir=.\GalaxyLib___Win32_Release
InputPath=.\X86.asm

"$(IntDir)\x86.obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /Fo$(IntDir)\x86.obj /c /coff /Cp /Cx $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "GalaxyLib - Win32 Debug"

# PROP Ignore_Default_Tool 1
# Begin Custom Build
IntDir=.\Debug
InputPath=.\X86.asm

"$(IntDir)\x86.obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /Fo$(IntDir)\x86.obj /c /coff /Cp /Cx $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# End Target
# End Project
