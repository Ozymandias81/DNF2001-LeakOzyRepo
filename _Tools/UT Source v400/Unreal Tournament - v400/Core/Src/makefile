#=============================================================================
# Unreal Core makefile for Linux.
#
# Revision history:
# 	* Created by Mike Danylchuk
#=============================================================================

# Unreal directory. (Required by makefile-header.)
UNREAL_DIR	= ../..

# Include global definitions.
include $(UNREAL_DIR)/makefile-header

#-----------------------------------------------------------------------------
# Directories.
#-----------------------------------------------------------------------------

SRC_DIRS	= $(CORE_SRC)
BUILD_DIR	= $(CORE_BUILD)

#-----------------------------------------------------------------------------
# Compiler/linker options.
#-----------------------------------------------------------------------------

CXX		= $(STD_CXX)
CXXFLAGS	= $(STD_CXXFLAGS) -Werror -fPIC -I$(CORE_INC) \
			-DGPackage=Core
LDFLAGS		= $(STD_LDFLAGS) -shared -Wl,-soname,$(CORE_SONAME)
LIBS		= $(STD_LIBS)

#-----------------------------------------------------------------------------
# Files.
#-----------------------------------------------------------------------------

OBJS =			\
	Core.o		\
	UExporter.o	\
	UFactory.o	\
	UnAnsi.o	\
	UnBits.o	\
	UnCache.o	\
	UnClass.o	\
	UnCorSc.o	\
	UnCoreNet.o	\
	UnGUID.o	\
	UnUnix.o	\
	UnMath.o	\
	UnMem.o		\
	UnMisc.o	\
	UnName.o	\
	UnObj.o		\
	UnProp.o

OUT = $(CORE)

#-----------------------------------------------------------------------------
# Rules.
#-----------------------------------------------------------------------------

# Use general rules.
include $(UNREAL_DIR)/makefile-general

#-----------------------------------------------------------------------------
# The End.
#-----------------------------------------------------------------------------
