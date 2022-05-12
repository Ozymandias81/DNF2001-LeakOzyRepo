#=============================================================================
# Unreal Render makefile for Linux.
#
# Revision history:
# 	* Created by Brandon Reinhart 
#=============================================================================

# Unreal directory. (Required by makefile-header.)
UNREAL_DIR	= ../..

# Include global definitions.
include $(UNREAL_DIR)/makefile-header

#-----------------------------------------------------------------------------
# Directories.
#-----------------------------------------------------------------------------

SRC_DIRS	= $(RENDER_SRC)
BUILD_DIR	= $(RENDER_BUILD)

#-----------------------------------------------------------------------------
# Compiler/linker options.
#-----------------------------------------------------------------------------

CXX		= $(STD_CXX)
CXXFLAGS	= $(STD_CXXFLAGS) -Werror -fPIC -I$(ENGINE_INC) -I$(CORE_INC) \
			-DGPackage=GPackageRender
LDFLAGS		= $(STD_LDFLAGS) -shared -Wl,-soname,$(RENDER_SONAME)
LIBS		= $(STD_LIBS) $(CORE) $(ENGINE)

#-----------------------------------------------------------------------------
# Files.
#-----------------------------------------------------------------------------

OBJS =			\
	Render.o	\
	UnLight.o	\
	UnMeshRn.o	\
	UnRandom.o	\
	UnRender.o	\
	UnSoftLn.o	\
	UnSpan.o	\
	UnSprite.o

OUT = $(RENDER)

#-----------------------------------------------------------------------------
# Rules.
#-----------------------------------------------------------------------------

# Use general rules.
include $(UNREAL_DIR)/makefile-general

#-----------------------------------------------------------------------------
# The End.
#-----------------------------------------------------------------------------
