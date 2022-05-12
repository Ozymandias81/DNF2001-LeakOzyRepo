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

SRC_DIRS	= $(XLAUNCH_SRC)
BUILD_DIR	= $(XLAUNCH_BUILD)

#-----------------------------------------------------------------------------
# Compiler/linker options.
#-----------------------------------------------------------------------------

CXX		= $(STD_CXX)
CXXFLAGS	= $(STD_CXXFLAGS) -Werror -fPIC -I$(XLAUNCH_INC) -I$(CORE_INC) \
			-I$(ENGINE_INC) -I$(IPDRV_INC) -DGPackage=GPackageUCC
LDFLAGS		= $(STD_LDFLAGS) -export-dynamic
LIBS		= $(STD_LIBS) $(ENGINE) $(CORE) $(XLIBS)

#-----------------------------------------------------------------------------
# Files.
#-----------------------------------------------------------------------------

OBJS =		\
	XLaunch.o

OUT = $(XLAUNCH)

#-----------------------------------------------------------------------------
# Rules.
#-----------------------------------------------------------------------------

# Use general rules.
include $(UNREAL_DIR)/makefile-general

#-----------------------------------------------------------------------------
# The End.
#-----------------------------------------------------------------------------
