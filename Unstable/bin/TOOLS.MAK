# Tools setup makefile assist file
# Author: Andy Hanson
# Created 7/5/98

RC      = "$(C32RC)\rc.exe"
CL      = "$(C32BIN)\cl.exe"
LINK    = "$(C32BIN)\link.exe"
MLIB    = "$(C32BIN)\lib.exe"
ML      = "$(MASM_BIN)\ml.exe"
NASM    = "$(BUILD_ROOT_DUKE)\bin\nasm\nasm.exe"

CEcho   = $(BUILD_ROOT_DUKE)\bin\cecho.exe
cecho   = $(BUILD_ROOT_DUKE)\bin\cecho.exe
fdeltree= $(BUILD_ROOT_DUKE)\bin\fdeltree.exe
fcopy   = $(BUILD_ROOT_DUKE)\bin\fcopy.exe

AFLAGS=$(AFLAGS) -W3 -WX -c -D__MSC__ -DWIN32 -D__WIN32__ -coff -nologo
NFLAGS=$(NFLAGS) -f win32 -DWIN32
LIB_FLAGS=-nologo

!if "$(DEBUG)"== "1"
AFLAGS  =-Zi -DDEBUG $(AFLAGS)
NFLAGS  =-g $(NFLAGS)
!endif

