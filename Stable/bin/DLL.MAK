# Dll makefile assist file
# Author: Andy Hanson
# Created 7/5/98

!include $(BUILD_ROOT_DUKE)\bin\validate.mak
!include $(BUILD_ROOT_DUKE)\bin\tools.mak
!include $(BUILD_ROOT_DUKE)\bin\env.mak

!if "$(debug)"==""
config=RETAIL
!else
config=DEBUG
!endif

CFLAGS=$(CFLAGS) -FAs -W3 -WX -c -D__MSC__ -DWIN32 -D__WIN32__ -nologo
AFLAGS=$(AFLAGS) -W3 -WX -c -D__MSC__ -DWIN32 -D__WIN32__ -coff -nologo
!if "$(DEBUG)"== "1"
CFLAGS  =-Z7 -DDEBUG $(CFLAGS)
AFLAGS  =-Zd -Zi -Zf $(AFLAGS)
!else
CFLAGS  =-Ox $(CFLAGS)
!endif

RCFLAGS=$(RCFLAGS) -l 0x409
!if "$(DEBUG)"== "1"
RCFLAGS =$(RCFLAGS) /d_DEBUG -nologo
!else
!endif

!if "$(DEBUG)"== "1"
LFLAGS=$(LFLAGS) -dll -debug -debugtype:both -map -subsystem:windows -nodefaultlib -nologo
LFLAGS_WEXE=$(LFLAGS_WEXE) -debug -debugtype:both -map -subsystem:windows -nologo
LFLAGS_CEXE=$(LFLAGS_CEXE) -debug -debugtype:both -map -nologo -subsystem:console
!else
LFLAGS=$(LFLAGS) -dll -map -subsystem:windows -nodefaultlib -nologo
LFLAGS_WEXE=$(LFLAGS_WEXE) -map -subsystem:windows -nologo
LFLAGS_CEXE=$(LFLAGS_CEXE) -map -nologo -subsystem:console
!endif


LIBS=$(LIBS) $(LLIBS)

!include $(BUILD_ROOT_DUKE)\bin\basic.mak
