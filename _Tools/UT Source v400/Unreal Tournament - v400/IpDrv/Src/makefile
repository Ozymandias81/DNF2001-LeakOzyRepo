#=============================================================================
# Unreal IpDrv makefile for Linux.
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

SRC_DIRS	= $(IPDRV_SRC)
BUILD_DIR	= $(IPDRV_BUILD)

#-----------------------------------------------------------------------------
# Compiler/linker options.
#-----------------------------------------------------------------------------

CXX		= $(STD_CXX)
CXXFLAGS	= $(STD_CXXFLAGS) -fPIC -I$(IPDRV_INC) -I$(ENGINE_INC) \
			-I$(CORE_INC) -DGPackage=GPackageIpDrv
LDFLAGS		= $(STD_LDFLAGS) -shared -Wl,-soname,$(IPDRV_SONAME)
LIBS		= $(STD_LIBS) $(CORE) $(ENGINE) -D_REENTRANT -lpthread

#-----------------------------------------------------------------------------
# Files.
#-----------------------------------------------------------------------------

OBJS =			\
	IpDrv.o		\
	InternetLink.o	\
	TcpLink.o	\
	UdpLink.o	\
	UnSocket.o	\
	TcpNetDriver.o	\
	UUpdateServerCommandlet.o	\
	UMasterServerCommandlet.o

OUT = $(IPDRV)

#-----------------------------------------------------------------------------
# Rules.
#-----------------------------------------------------------------------------

# Use general rules.
include $(UNREAL_DIR)/makefile-general

#-----------------------------------------------------------------------------
# The End.
#-----------------------------------------------------------------------------
